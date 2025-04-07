/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.9;

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


// File: contracts/openzeppelin/TokenTimelock.sol


/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time.
 */
contract TokenTimelock {
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 private _token;

    // beneficiary of tokens after they are released
    address private _beneficiary;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    constructor (IERC20 token, address beneficiary, uint256 releaseTime) public {
        // solhint-disable-next-line not-rely-on-time
        require(releaseTime > block.timestamp, "TokenTimelock: release time is before current time");
        _token = token;
        _beneficiary = beneficiary;
        _releaseTime = releaseTime;
    }

    /**
     * @return the token being held.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= _releaseTime, "TokenTimelock: current time is before release time");

        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        _token.safeTransfer(_beneficiary, amount);
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

// File: contracts/logics/AkropolisTimeLock.sol


//Beneficieries template


contract AkropolisTimeLock is TokenTimelock, BeneficiaryOperations {

        address private _pendingBeneficiary;


        event LogBeneficiaryTransferProposed(address _beneficiary);
        event LogBeneficiaryTransfered(address _beneficiary);

        /**
        * @notice Constructor.
        * @param _token  Address of AKRO token
        * @param _releaseTime Timestamp date
        */

        constructor (IERC20 _token, uint256 _releaseTime) public
            TokenTimelock(_token, msg.sender, _releaseTime) {
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
            * @param _newHowManyBeneficiariesDecide defines how many beneficiaries can decide
        */
        function transferBeneficiaryShipWithHowMany(address[] memory _newBeneficiaries, uint256 _newHowManyBeneficiariesDecide) public {
            super.transferBeneficiaryShipWithHowMany(_newBeneficiaries, _newHowManyBeneficiariesDecide);
            _setPendingBeneficiary(beneficiaries[0]);
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