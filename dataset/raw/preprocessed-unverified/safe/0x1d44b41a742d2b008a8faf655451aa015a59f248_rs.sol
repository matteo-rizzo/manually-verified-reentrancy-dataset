/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

pragma solidity ^0.5.9;

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */


// File: openzeppelin-solidity/contracts/math/SafeMath.sol


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


// File: openzeppelin-solidity/contracts/utils/Address.sol

/**
 * @dev Collection of functions related to the address type,
 */


// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: openzeppelin-solidity/contracts/ownership/Ownable.sol


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */


// File: contracts/openzeppelin/TokenVesting.sol


/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract TokenVesting is Ownable {
    // The vesting schedule is time-based (i.e. using block timestamps as opposed to e.g. block numbers), and is
    // therefore sensitive to timestamp manipulation (which is something miners can do, to a certain degree). Therefore,
    // it is recommended to avoid using short time durations (less than a minute). Typical vesting schemes, with a
    // cliff period of a year and a duration of four years, are safe to use.
    // solhint-disable not-rely-on-time

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(address token, uint256 amount);
    event TokenVestingRevoked(address token);

    // beneficiary of tokens after they are released
    address private _beneficiary;

    // Durations and timestamps are expressed in UNIX time, the same units as block.timestamp.
    uint256 private _cliff;
    uint256 private _start;
    uint256 private _duration;

    bool private _revocable;

    mapping (address => uint256) private _released;
    mapping (address => bool) private _revoked;

    /**
     * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
     * beneficiary, gradually in a linear fashion until start + duration. By then all
     * of the balance will have vested.
     * @param beneficiary address of the beneficiary to whom vested tokens are transferred
     * @param cliffDuration duration in seconds of the cliff in which tokens will begin to vest
     * @param start the time (as Unix time) at which point vesting starts
     * @param duration duration in seconds of the period in which the tokens will vest
     * @param revocable whether the vesting is revocable or not
     */
    constructor (address beneficiary, uint256 start, uint256 cliffDuration, uint256 duration, bool revocable) public {
        require(beneficiary != address(0), "TokenVesting: beneficiary is the zero address");
        // solhint-disable-next-line max-line-length
        require(cliffDuration <= duration, "TokenVesting: cliff is longer than duration");
        require(duration > 0, "TokenVesting: duration is 0");
        // solhint-disable-next-line max-line-length
        require(start.add(duration) > block.timestamp, "TokenVesting: final time is before current time");

        _beneficiary = beneficiary;
        _revocable = revocable;
        _duration = duration;
        _cliff = start.add(cliffDuration);
        _start = start;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the cliff time of the token vesting.
     */
    function cliff() public view returns (uint256) {
        return _cliff;
    }

    /**
     * @return the start time of the token vesting.
     */
    function start() public view returns (uint256) {
        return _start;
    }

    /**
     * @return the duration of the token vesting.
     */
    function duration() public view returns (uint256) {
        return _duration;
    }

    /**
     * @return true if the vesting is revocable.
     */
    function revocable() public view returns (bool) {
        return _revocable;
    }

    /**
     * @return the amount of the token released.
     */
    function released(address token) public view returns (uint256) {
        return _released[token];
    }

    /**
     * @return true if the token is revoked.
     */
    function revoked(address token) public view returns (bool) {
        return _revoked[token];
    }

    /**
     * @notice Transfers vested tokens to beneficiary.
     * @param token ERC20 token which is being vested
     */
    function release(IERC20 token) public {
        uint256 unreleased = _releasableAmount(token);

        require(unreleased > 0, "TokenVesting: no tokens are due");

        _released[address(token)] = _released[address(token)].add(unreleased);

        token.safeTransfer(_beneficiary, unreleased);

        emit TokensReleased(address(token), unreleased);
    }

    /**
     * @notice Allows the owner to revoke the vesting. Tokens already vested
     * remain in the contract, the rest are returned to the owner.
     * @param token ERC20 token which is being vested
     */
    function revoke(IERC20 token) public onlyOwner {
        require(_revocable, "TokenVesting: cannot revoke");
        require(!_revoked[address(token)], "TokenVesting: token already revoked");

        uint256 balance = token.balanceOf(address(this));

        uint256 unreleased = _releasableAmount(token);
        uint256 refund = balance.sub(unreleased);

        _revoked[address(token)] = true;

        token.safeTransfer(owner(), refund);

        emit TokenVestingRevoked(address(token));
    }

    /**
     * @dev Calculates the amount that has already vested but hasn't been released yet.
     * @param token ERC20 token which is being vested
     */
    function _releasableAmount(IERC20 token) private view returns (uint256) {
        return _vestedAmount(token).sub(_released[address(token)]);
    }

    /**
     * @dev Calculates the amount that has already vested.
     * @param token ERC20 token which is being vested
     */
    function _vestedAmount(IERC20 token) private view returns (uint256) {
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(_released[address(token)]);

        if (block.timestamp < _cliff) {
            return 0;
        } else if (block.timestamp >= _start.add(_duration) || _revoked[address(token)]) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(_start)).div(_duration);
        }
    }

     /**
     * @return change the beneficiary of tokens
     */

    function _changeBeneficiary(address _newBeneficiary) internal {
        _beneficiary = _newBeneficiary;
    }
}

// File: contracts/helpers/BeneficiaryOperations.sol

/*
  License: MIT
  Copyright Bitclave, 2018
  It's modified contract BeneficiaryOperations from https://github.com/bitclave/BeneficiaryOperations
*/


contract BeneficiaryOperations {

    using SafeMath for uint256;

    using SafeMath for uint8;
    // VARIABLES

    uint256 public beneficiariesGeneration;
    uint256 public howManyBeneficiariesDecide;
    address[] public beneficiaries;
    bytes32[] public allOperations;
    address internal insideCallSender;
    uint256 internal insideCallCount;
    

    // Reverse lookup tables for beneficiaries and allOperations
    mapping(address => uint8) public beneficiariesIndices; // Starts from 1, size 255
    mapping(bytes32 => uint) public allOperationsIndicies;
    

    // beneficiaries voting mask per operations
    mapping(bytes32 => uint256) public votesMaskByOperation;
    mapping(bytes32 => uint256) public votesCountByOperation;

    //operation -> beneficiaryIndex
    mapping(bytes32 => uint8) internal  operationsByBeneficiaryIndex;
    mapping(uint8 => uint8) internal operationsCountByBeneficiaryIndex;
    // EVENTS

    event BeneficiaryshipTransferred(address[] previousbeneficiaries, uint howManyBeneficiariesDecide, address[] newBeneficiaries, uint newHowManybeneficiarysDecide);
    event OperationCreated(bytes32 operation, uint howMany, uint beneficiariesCount, address proposer);
    event OperationUpvoted(bytes32 operation, uint votes, uint howMany, uint beneficiariesCount, address upvoter);
    event OperationPerformed(bytes32 operation, uint howMany, uint beneficiariesCount, address performer);
    event OperationDownvoted(bytes32 operation, uint votes, uint beneficiariesCount,  address downvoter);
    event OperationCancelled(bytes32 operation, address lastCanceller);
    
    // ACCESSORS

    function isExistBeneficiary(address wallet) public view returns(bool) {
        return beneficiariesIndices[wallet] > 0;
    }


    function beneficiariesCount() public view returns(uint) {
        return beneficiaries.length;
    }

    function allOperationsCount() public view returns(uint) {
        return allOperations.length;
    }

    /*
      Internal functions
    */

    function _operationLimitByBeneficiaryIndex(uint8 beneficiaryIndex) internal view returns(bool) {
        return (operationsCountByBeneficiaryIndex[beneficiaryIndex] <= 3);
    }
    
    function _cancelAllPending() internal {
        for (uint i = 0; i < allOperations.length; i++) {
            delete(allOperationsIndicies[allOperations[i]]);
            delete(votesMaskByOperation[allOperations[i]]);
            delete(votesCountByOperation[allOperations[i]]);
            //delete operation->beneficiaryIndex
            delete(operationsByBeneficiaryIndex[allOperations[i]]);
        }

        allOperations.length = 0;
        //delete operations count for beneficiary
        for (uint8 j = 0; j < beneficiaries.length; j++) {
            operationsCountByBeneficiaryIndex[j] = 0;
        }
    }


    // MODIFIERS

    /**
    * @dev Allows to perform method by any of the beneficiaries
    */
    modifier onlyAnyBeneficiary {
        if (checkHowManyBeneficiaries(1)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = 1;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    /**
    * @dev Allows to perform method only after many beneficiaries call it with the same arguments
    */
    modifier onlyManyBeneficiaries {
        if (checkHowManyBeneficiaries(howManyBeneficiariesDecide)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = howManyBeneficiariesDecide;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    /**
    * @dev Allows to perform method only after all beneficiaries call it with the same arguments
    */
    modifier onlyAllBeneficiaries {
        if (checkHowManyBeneficiaries(beneficiaries.length)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = beneficiaries.length;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    /**
    * @dev Allows to perform method only after some beneficiaries call it with the same arguments
    */
    modifier onlySomeBeneficiaries(uint howMany) {
        require(howMany > 0, "onlySomeBeneficiaries: howMany argument is zero");
        require(howMany <= beneficiaries.length, "onlySomeBeneficiaries: howMany argument exceeds the number of Beneficiaries");
        
        if (checkHowManyBeneficiaries(howMany)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = howMany;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    // CONSTRUCTOR

    constructor() public {
        beneficiaries.push(msg.sender);
        beneficiariesIndices[msg.sender] = 1;
        howManyBeneficiariesDecide = 1;
    }

    // INTERNAL METHODS

    /**
     * @dev onlyManybeneficiaries modifier helper
     */
    function checkHowManyBeneficiaries(uint howMany) internal returns(bool) {
        if (insideCallSender == msg.sender) {
            require(howMany <= insideCallCount, "checkHowManyBeneficiaries: nested beneficiaries modifier check require more beneficiarys");
            return true;
        }
        
        
        require((isExistBeneficiary(msg.sender) && (beneficiariesIndices[msg.sender] <= beneficiaries.length)), "checkHowManyBeneficiaries: msg.sender is not an beneficiary");

        uint beneficiaryIndex = beneficiariesIndices[msg.sender].sub(1);
        
        bytes32 operation = keccak256(abi.encodePacked(msg.data, beneficiariesGeneration));

        require((votesMaskByOperation[operation] & (2 ** beneficiaryIndex)) == 0, "checkHowManyBeneficiaries: beneficiary already voted for the operation");
        //check limit for operation
        require(_operationLimitByBeneficiaryIndex(uint8(beneficiaryIndex)), "checkHowManyBeneficiaries: operation limit is reached for this beneficiary");

        votesMaskByOperation[operation] |= (2 ** beneficiaryIndex);
        uint operationVotesCount = votesCountByOperation[operation].add(1);
        votesCountByOperation[operation] = operationVotesCount;

        if (operationVotesCount == 1) {
            allOperationsIndicies[operation] = allOperations.length;
            
            operationsByBeneficiaryIndex[operation] = uint8(beneficiaryIndex);
            
            operationsCountByBeneficiaryIndex[uint8(beneficiaryIndex)] = uint8(operationsCountByBeneficiaryIndex[uint8(beneficiaryIndex)].add(1));
            
            allOperations.push(operation);
            
            
            emit OperationCreated(operation, howMany, beneficiaries.length, msg.sender);
        }
        emit OperationUpvoted(operation, operationVotesCount, howMany, beneficiaries.length, msg.sender);

        // If enough beneficiaries confirmed the same operation
        if (votesCountByOperation[operation] == howMany) {
            deleteOperation(operation);
            emit OperationPerformed(operation, howMany, beneficiaries.length, msg.sender);
            return true;
        }

        return false;
    }

    /**
    * @dev Used to delete cancelled or performed operation
    * @param operation defines which operation to delete
    */
    function deleteOperation(bytes32 operation) internal {
        uint index = allOperationsIndicies[operation];
        if (index < allOperations.length - 1) { // Not last
            allOperations[index] = allOperations[allOperations.length.sub(1)];
            allOperationsIndicies[allOperations[index]] = index;
        }
        allOperations.length = allOperations.length.sub(1);

        uint8 beneficiaryIndex = uint8(operationsByBeneficiaryIndex[operation]);
        operationsCountByBeneficiaryIndex[beneficiaryIndex] = uint8(operationsCountByBeneficiaryIndex[beneficiaryIndex].sub(1));

        delete votesMaskByOperation[operation];
        delete votesCountByOperation[operation];
        delete allOperationsIndicies[operation];
        delete operationsByBeneficiaryIndex[operation];
    }

    // PUBLIC METHODS

    /**
    * @dev Allows beneficiaries to change their mind by cancelling votesMaskByOperation operations
    * @param operation defines which operation to delete
    */
    function cancelPending(bytes32 operation) public onlyAnyBeneficiary {

        require((isExistBeneficiary(msg.sender) && (beneficiariesIndices[msg.sender] <= beneficiaries.length)), "checkHowManyBeneficiaries: msg.sender is not an beneficiary");

        uint beneficiaryIndex = beneficiariesIndices[msg.sender].sub(1);
        require((votesMaskByOperation[operation] & (2 ** beneficiaryIndex)) != 0, "cancelPending: operation not found for this user");
        votesMaskByOperation[operation] &= ~(2 ** beneficiaryIndex);
        uint operationVotesCount = votesCountByOperation[operation].sub(1);
        votesCountByOperation[operation] = operationVotesCount;
        emit OperationDownvoted(operation, operationVotesCount, beneficiaries.length, msg.sender);
        if (operationVotesCount == 0) {
            deleteOperation(operation);
            emit OperationCancelled(operation, msg.sender);
        }
    }

    /**
    * @dev Allows beneficiaries to change their mind by cancelling all operations
    */

    function cancelAllPending() public onlyManyBeneficiaries {
       _cancelAllPending();
    }



    /**妤快把快扭我扼忘找抆*/

    /**
    * @dev Allows beneficiaries to change beneficiariesship
    * @param newBeneficiaries defines array of addresses of new beneficiaries
    */
    function transferBeneficiaryShip(address[] memory newBeneficiaries) public {
        transferBeneficiaryShipWithHowMany(newBeneficiaries, newBeneficiaries.length);
    }

    /**
    * @dev Allows beneficiaries to change beneficiaryShip
    * @param newBeneficiaries defines array of addresses of new beneficiaries
    * @param newHowManyBeneficiariesDecide defines how many beneficiaries can decide
    */
    function transferBeneficiaryShipWithHowMany(address[] memory newBeneficiaries, uint256 newHowManyBeneficiariesDecide) public onlyManyBeneficiaries {
        require(newBeneficiaries.length > 0, "transferBeneficiaryShipWithHowMany: beneficiaries array is empty");
        require(newBeneficiaries.length < 256, "transferBeneficiaryshipWithHowMany: beneficiaries count is greater then 255");
        require(newHowManyBeneficiariesDecide > 0, "transferBeneficiaryshipWithHowMany: newHowManybeneficiarysDecide equal to 0");
        require(newHowManyBeneficiariesDecide <= newBeneficiaries.length, "transferBeneficiaryShipWithHowMany: newHowManybeneficiarysDecide exceeds the number of beneficiarys");

        // Reset beneficiaries reverse lookup table
        for (uint j = 0; j < beneficiaries.length; j++) {
            delete beneficiariesIndices[beneficiaries[j]];
        }
        for (uint i = 0; i < newBeneficiaries.length; i++) {
            require(newBeneficiaries[i] != address(0), "transferBeneficiaryShipWithHowMany: beneficiaries array contains zero");
            require(beneficiariesIndices[newBeneficiaries[i]] == 0, "transferBeneficiaryShipWithHowMany: beneficiaries array contains duplicates");
            beneficiariesIndices[newBeneficiaries[i]] = uint8(i.add(1));
        }
        
        emit BeneficiaryshipTransferred(beneficiaries, howManyBeneficiariesDecide, newBeneficiaries, newHowManyBeneficiariesDecide);
        beneficiaries = newBeneficiaries;
        howManyBeneficiariesDecide = newHowManyBeneficiariesDecide;

        _cancelAllPending();
       
        beneficiariesGeneration++;
    }
}

// File: contracts/logics/AkropolisTokenVesting.sol

//Beneficieries template


contract AkropolisTokenVesting is TokenVesting, BeneficiaryOperations {

    IERC20 private token;

    address private _pendingBeneficiary;

    event LogBeneficiaryTransferProposed(address _beneficiary);
    event LogBeneficiaryTransfered(address _beneficiary);

    constructor (IERC20 _token, uint256 _start, uint256 _cliffDuration, uint256 _duration) public 
        TokenVesting(msg.sender, _start, _cliffDuration, _duration, false) {
            token = _token;
        }

     /**
     * @notice Transfers vested tokens to beneficiary.
     */

    function release() public {
        super.release(token);
    }


     /**
     * @return the token being held.
     */
    function tokenAddress() public view returns (IERC20) {
        return token;
    }

    // MODIFIERS
    /**
    * @dev Allows to perform method by existing beneficiary
    */
    modifier onlyExistingBeneficiary(address _beneficiary) {
        require(isExistBeneficiary(_beneficiary), "address is not in beneficiary array");
        _;
    }

    /**
    * @dev Allows to perform method by pending beneficiary
    */

    modifier onlyPendingBeneficiary {
        require(msg.sender  == _pendingBeneficiary, "Unpermitted operation.");
        _;
    }

    function pendingBeneficiary() public view returns (address) {
        return _pendingBeneficiary;
    }

     /**
        * @dev Allows beneficiaries to change beneficiaryShip and set first beneficiary as default
        * @param _newBeneficiaries defines array of addresses of new beneficiaries
    */
    function transferBeneficiaryShip(address[] memory _newBeneficiaries) public {
        super.transferBeneficiaryShip(_newBeneficiaries);
        _setPendingBeneficiary(beneficiaries[0]);
    }

     /**
        * @dev Allows beneficiaries to change beneficiaryShip and set first beneficiary as default
        * @param _newBeneficiaries defines array of addresses of new beneficiaries
        * @param _newHowManyBeneficiariesDecide defines how many beneficiaries can decide
    */
    
    function transferBeneficiaryShipWithHowMany(address[] memory _newBeneficiaries, uint256 _newHowManyBeneficiariesDecide) public  {
        super.transferBeneficiaryShipWithHowMany(_newBeneficiaries, _newHowManyBeneficiariesDecide);
        _setPendingBeneficiary(beneficiaries[0]);
    }

    /**
        * @dev Allows beneficiaries to change beneficiary as default
         * @param _newBeneficiary defines address of new beneficiary
    */
    function changeBeneficiary(address _newBeneficiary) public onlyManyBeneficiaries {
        _setPendingBeneficiary(_newBeneficiary);
    }

    /**
        * @dev Claim Beneficiary
    */
    function claimBeneficiary() public onlyPendingBeneficiary {
        _changeBeneficiary(_pendingBeneficiary);
        emit LogBeneficiaryTransfered(_pendingBeneficiary);
        _pendingBeneficiary = address(0);
    }

    /*
     * Internal Functions
     *
     */
    /**
        * @dev Set pending Beneficiary address
        * @param _newBeneficiary defines address of new beneficiary
    */
    function _setPendingBeneficiary(address _newBeneficiary) internal onlyExistingBeneficiary(_newBeneficiary) {
        _pendingBeneficiary = _newBeneficiary;
        emit LogBeneficiaryTransferProposed(_newBeneficiary);
    }
}