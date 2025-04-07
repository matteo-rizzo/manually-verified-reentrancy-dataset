/**
 *Submitted for verification at Etherscan.io on 2021-04-09
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




// Root file: contracts/FMTTeamTokenVesting.sol


pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// import "contracts/BokkyPooBahsDateTimeLibrary.sol";

contract FMTTeamTokenVesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event DistributionAdded(
        address indexed investor,
        address indexed caller,
        uint256 allocation
    );

    event DistributionRemoved(
        address indexed investor,
        address indexed caller,
        uint256 allocation
    );

    event WithdrawnTokens(address indexed investor, uint256 value);

    event RecoverToken(address indexed token, uint256 indexed amount);

    enum DistributionType {FOUNDATION, TEAM}

    uint256 private _initialTimestamp;
    IERC20 private _fmtToken;

    struct Distribution {
        address beneficiary;
        uint256 withdrawnTokens;
        uint256 tokensAllotment;
        DistributionType distributionType;
    }

    mapping(DistributionType => Distribution) public distributionInfo;

    /// @dev Boolean variable that indicates whether the contract was initialized.
    bool public isInitialized = false;
    /// @dev Boolean variable that indicates whether the investors set was finalized.
    bool public isFinalized = false;

    address FOUNDATION_ADDRESS = 0x982e39e5B4e56fE66BA4A19E9F5CFb0A057A5AEa;
    address TEAM_ADDRESS = 0xbb0d72070791193b5C87A0e8f24E392657e0ecd5;

    uint256 constant _SCALING_FACTOR = 10**18; // decimals

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

    constructor(address _token) {
        require(
            address(_token) != address(0x0),
            "Finminity token address is not valid"
        );
        _fmtToken = IERC20(_token);

        _addDistribution(
            FOUNDATION_ADDRESS,
            DistributionType.FOUNDATION,
            2920000 * _SCALING_FACTOR
        );
        _addDistribution(
            TEAM_ADDRESS,
            DistributionType.TEAM,
            750000 * _SCALING_FACTOR
        );
    }

    /// @dev Returns initial timestamp
    function getInitialTimestamp() public view returns (uint256 timestamp) {
        return _initialTimestamp;
    }

    /// @dev Adds Distribution. This function doesn't limit max gas consumption,
    /// so adding too many investors can cause it to reach the out-of-gas error.
    /// @param _beneficiary The address of distribution.
    /// @param _tokensAllotment The amounts of the tokens that belong to each investor.
    function _addDistribution(
        address _beneficiary,
        DistributionType _distributionType,
        uint256 _tokensAllotment
    ) internal {
        require(_beneficiary != address(0), "Invalid address");
        require(
            _tokensAllotment > 0,
            "the investor allocation must be more than 0"
        );
        Distribution storage distribution = distributionInfo[_distributionType];

        require(distribution.tokensAllotment == 0, "investor already added");

        distribution.beneficiary = _beneficiary;
        distribution.tokensAllotment = _tokensAllotment;
        distribution.distributionType = _distributionType;

        emit DistributionAdded(_beneficiary, _msgSender(), _tokensAllotment);
    }

    function withdrawTokens(uint256 _distributionType)
        external
        onlyOwner()
        initialized()
    {
        Distribution storage distribution =
            distributionInfo[DistributionType(_distributionType)];

        uint256 tokensAvailable =
            withdrawableTokens(DistributionType(_distributionType));

        require(tokensAvailable > 0, "no tokens available for withdrawl");

        distribution.withdrawnTokens = distribution.withdrawnTokens.add(
            tokensAvailable
        );
        _fmtToken.safeTransfer(distribution.beneficiary, tokensAvailable);

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

    function withdrawableTokens(DistributionType distributionType)
        public
        view
        returns (uint256 tokens)
    {
        Distribution storage distribution = distributionInfo[distributionType];
        uint256 availablePercentage =
            _calculateAvailablePercentage(distributionType);
        uint256 noOfTokens =
            _calculatePercentage(
                distribution.tokensAllotment,
                availablePercentage
            );
        uint256 tokensAvailable = noOfTokens.sub(distribution.withdrawnTokens);
        return tokensAvailable;
    }

    function _calculatePercentage(uint256 _amount, uint256 _percentage)
        private
        pure
        returns (uint256 percentage)
    {
        return _amount.mul(_percentage).div(100).div(1e18);
    }

    function _getTeamPercentage(uint256 _currentTimeStamp)
        private
        view
        returns (uint256 _availablePercentage)
    {
        // TEAM 60 Days Lock from TGE, Released daily over 300 Days after 60 days cliff
        uint256 cliffDuration = _initialTimestamp + 60 days;
        uint256 oneYear = _initialTimestamp + 300 days + 60 days;
        uint256 remainingDistroPercentage = 100;
        uint256 noOfRemaingDays = 300;
        uint256 everyDayReleasePercentage =
            remainingDistroPercentage.mul(1e18).div(noOfRemaingDays);

        if (_currentTimeStamp <= cliffDuration) {
            return uint256(0);
        }
        if (
            _currentTimeStamp > cliffDuration && _currentTimeStamp < oneYear
        ) {
            uint256 noOfDays =
                BokkyPooBahsDateTimeLibrary.diffDays(
                    cliffDuration,
                    _currentTimeStamp
                );
            uint256 currentUnlockedPercentage =
                noOfDays.mul(everyDayReleasePercentage);
            return currentUnlockedPercentage;
        } else {
            return uint256(100).mul(1e18);
        }
    }

    function _getFoundationPercentage(uint256 _currentTimeStamp)
        private
        view
        returns (uint256 _availablePercentage)
    {
        // FOUNDATION 60 Days Lock from TGE, Released daily over 300 Days after 60 days cliff
        uint256 cliffDuration = _initialTimestamp + 60 days;
        uint256 oneYear = _initialTimestamp + 300 days + 60 days;
        uint256 remainingDistroPercentage = 100;
        uint256 noOfRemaingDays = 300;
        uint256 everyDayReleasePercentage =
            remainingDistroPercentage.mul(1e18).div(noOfRemaingDays);

        if (_currentTimeStamp <= cliffDuration) {
            return uint256(0);
        } else if (
            _currentTimeStamp > cliffDuration && _currentTimeStamp < oneYear
        ) {
            uint256 noOfDays =
                BokkyPooBahsDateTimeLibrary.diffDays(
                    cliffDuration,
                    _currentTimeStamp
                );
            uint256 currentUnlockedPercentage =
                noOfDays.mul(everyDayReleasePercentage);

            return currentUnlockedPercentage;
        } else {
            return uint256(100).mul(1e18);
        }
    }

    function _calculateAvailablePercentage(DistributionType distributionType)
        private
        view
        returns (uint256 _availablePercentage)
    {
        uint256 currentTimeStamp = block.timestamp;

        if (currentTimeStamp > _initialTimestamp) {
            if (distributionType == DistributionType.FOUNDATION) {
                return _getFoundationPercentage(currentTimeStamp);
            } else if (distributionType == DistributionType.TEAM) {
                return _getTeamPercentage(currentTimeStamp);
            }
        }
    }
}