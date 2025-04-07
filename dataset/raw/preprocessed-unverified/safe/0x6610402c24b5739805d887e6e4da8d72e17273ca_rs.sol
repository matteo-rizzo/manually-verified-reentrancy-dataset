/**
 *Submitted for verification at Etherscan.io on 2021-04-07
*/

// Dependency file: @openzeppelin/contracts/utils/Context.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// Dependency file: @openzeppelin/contracts/utils/math/SafeMath.sol


// pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: contracts/BokkyPooBahsDateTimeLibrary.sol


// pragma solidity ^0.8.0;

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.01
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------




// Root file: contracts/FMTAdvisorVesting.sol


pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// import "contracts/BokkyPooBahsDateTimeLibrary.sol";

contract FMTAdvisorVesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event AdvisorsAdded(
        address[] advisors,
        uint256[] tokenAllocations,
        address caller
    );

    event AdvisorAdded(
        address indexed advisor,
        address indexed caller,
        uint256 allocation
    );

    event AdvisorRemoved(
        address indexed advisor,
        address indexed caller,
        uint256 allocation
    );

    event WithdrawnTokens(address indexed advisor, uint256 value);

    event DepositInvestment(address indexed advisor, uint256 value);

    event TransferInvestment(address indexed owner, uint256 value);

    event RecoverToken(address indexed token, uint256 indexed amount);

    uint256 private _totalAllocatedAmount;
    uint256 private _initialTimestamp;
    IERC20 private _fmtToken;
    address[] public advisors;

    uint256 private constant _remainingDistroPercentage = 95;
    uint256 private constant _noOfRemaingDays = 300;

    struct Advisor {
        bool exists;
        uint256 withdrawnTokens;
        uint256 tokensAllotment;
    }

    mapping(address => Advisor) public advisorsInfo;

    /// @dev Boolean variable that indicates whether the contract was initialized.
    bool public isInitialized = false;
    /// @dev Boolean variable that indicates whether the advisors set was finalized.
    bool public isFinalized = false;

    /// @dev Checks that the contract is initialized.
    modifier initialized() {
        require(isInitialized, "not initialized");
        _;
    }

    /// @dev Checks that the contract is initialized.
    modifier notInitialized() {
        require(!isInitialized, "initialized");
        _;
    }

    modifier onlyAdvisor() {
        require(advisorsInfo[_msgSender()].exists, "Only advisors allowed");
        _;
    }

    constructor(address _token) {
        _fmtToken = IERC20(_token);
    }

    function getInitialTimestamp() public view returns (uint256 timestamp) {
        return _initialTimestamp;
    }

    /// @dev release tokens to all the advisors
    function releaseTokens() external onlyOwner initialized() {
        for (uint8 i = 0; i < advisors.length; i++) {
            Advisor storage advisor = advisorsInfo[advisors[i]];
            uint256 tokensAvailable = withdrawableTokens(advisors[i]);
            if (tokensAvailable > 0) {
                advisor.withdrawnTokens = advisor.withdrawnTokens.add(
                    tokensAvailable
                );
                _fmtToken.safeTransfer(advisors[i], tokensAvailable);
            }
        }
    }

    /// @dev Adds advisors. This function doesn't limit max gas consumption,
    /// so adding too many advisors can cause it to reach the out-of-gas error.
    /// @param _advisors The addresses of new advisors.
    /// @param _tokenAllocations The amounts of the tokens that belong to each advisor.
    function addAdvisors(
        address[] calldata _advisors,
        uint256[] calldata _tokenAllocations
    ) external onlyOwner {
        require(
            _advisors.length == _tokenAllocations.length,
            "different arrays sizes"
        );
        for (uint256 i = 0; i < _advisors.length; i++) {
            _addAdvisor(_advisors[i], _tokenAllocations[i]);
        }
        emit AdvisorsAdded(_advisors, _tokenAllocations, msg.sender);
    }

    // 5% at TGE, 95% released daily over 300 Days, no Cliff
    function withdrawTokens() external onlyAdvisor() initialized() {
        Advisor storage advisor = advisorsInfo[_msgSender()];

        uint256 tokensAvailable = withdrawableTokens(_msgSender());

        require(tokensAvailable > 0, "no tokens available for withdrawl");

        advisor.withdrawnTokens = advisor.withdrawnTokens.add(tokensAvailable);
        _fmtToken.safeTransfer(_msgSender(), tokensAvailable);

        emit WithdrawnTokens(_msgSender(), tokensAvailable);
    }

    /// @dev The starting time of TGE
    /// @param _timestamp The initial timestamp, this timestap should be used for vesting
    function setInitialTimestamp(uint256 _timestamp)
        external
        onlyOwner()
        notInitialized()
    {
        isInitialized = true;
        _initialTimestamp = _timestamp;
    }

    /// @dev withdrawble tokens for an address
    /// @param _advisor whitelisted advisor address
    function withdrawableTokens(address _advisor)
        public
        view
        returns (uint256 tokens)
    {
        if (!isInitialized) {
            return 0;
        }
        Advisor storage advisor = advisorsInfo[_advisor];
        uint256 availablePercentage = _calculateAvailablePercentage();
        uint256 noOfTokens =
            _calculatePercentage(advisor.tokensAllotment, availablePercentage);
        uint256 tokensAvailable = noOfTokens.sub(advisor.withdrawnTokens);

        return tokensAvailable;
    }

    /// @dev Adds advisor. This function doesn't limit max gas consumption,
    /// so adding too many advisors can cause it to reach the out-of-gas error.
    /// @param _advisor The addresses of new advisors.
    /// @param _tokensAllotment The amounts of the tokens that belong to each advisor.
    function _addAdvisor(address _advisor, uint256 _tokensAllotment)
        internal
        onlyOwner
    {
        require(_advisor != address(0), "Invalid address");
        require(
            _tokensAllotment > 0,
            "the advisor allocation must be more than 0"
        );
        Advisor storage advisor = advisorsInfo[_advisor];

        require(advisor.tokensAllotment == 0, "advisor already added");

        advisor.tokensAllotment = _tokensAllotment;
        advisor.exists = true;
        advisors.push(_advisor);
        _totalAllocatedAmount = _totalAllocatedAmount.add(_tokensAllotment);
        emit AdvisorAdded(_advisor, _msgSender(), _tokensAllotment);
    }

    /// @dev calculate percentage value from amount
    /// @param _amount amount input to find the percentage
    /// @param _percentage percentage for an amount
    function _calculatePercentage(uint256 _amount, uint256 _percentage)
        private
        pure
        returns (uint256 percentage)
    {
        return _amount.mul(_percentage).div(100).div(1e18);
    }

    function _calculateAvailablePercentage()
        private
        view
        returns (uint256 availablePercentage)
    {
        // 500000 FMT assigned
        // 25000 tokens on TGE - 5% on TGE
        // 475000 tokens distributed for 300 days - 95% remaining
        // 475000/300 = 1583 tokens per day
        // 95/300 = 0.3167% every day released
        uint256 oneDays = _initialTimestamp + 1 days;
        uint256 vestingDuration = _initialTimestamp + 300 days;

        uint256 everyDayReleasePercentage =
            _remainingDistroPercentage.mul(1e18).div(_noOfRemaingDays);

        uint256 currentTimeStamp = block.timestamp;

        if (currentTimeStamp > _initialTimestamp) {
            if (currentTimeStamp <= oneDays) {
                return uint256(5).mul(1e18);
            } else if (
                currentTimeStamp > oneDays && currentTimeStamp < vestingDuration
            ) {
                uint256 noOfDays =
                    BokkyPooBahsDateTimeLibrary.diffDays(
                        _initialTimestamp,
                        currentTimeStamp
                    );
                uint256 currentUnlockedPercentage =
                    noOfDays.mul(everyDayReleasePercentage);

                return uint256(5).mul(1e18).add(currentUnlockedPercentage);
            } else {
                return uint256(100).mul(1e18);
            }
        }
    }

    function recoverToken(address _token, uint256 amount) external onlyOwner {
        IERC20(_token).safeTransfer(_msgSender(), amount);
        emit RecoverToken(_token, amount);
    }
}