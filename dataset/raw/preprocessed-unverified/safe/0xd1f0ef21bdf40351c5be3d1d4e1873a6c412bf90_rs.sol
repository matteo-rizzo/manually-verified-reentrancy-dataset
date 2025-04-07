/**
 *Submitted for verification at Etherscan.io on 2021-04-12
*/

// File: IERC20.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;


// File: EnumerableSet.sol


// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol
// Subject to the MIT license.


/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */

// File: Context.sol


// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/GSN/Context.sol
// Subject to the MIT license.


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// File: Ownable.sol


// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
// Subject to the MIT license.


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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
// File: PresaleSettings.sol

// @Credits Unicrypt Network 2021

// Settings to initialize presale contracts and edit fees.



contract PresaleSettings is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    EnumerableSet.AddressSet private EARLY_ACCESS_TOKENS;
    mapping(address => uint256) public EARLY_ACCESS_MAP;
    
    EnumerableSet.AddressSet private ALLOWED_REFERRERS;
    
    struct Settings {
        uint256 BASE_FEE; // base fee divided by 1000
        uint256 TOKEN_FEE; // token fee divided by 1000
        uint256 REFERRAL_FEE; // a referrals percentage of the presale profits divided by 1000
        address payable ETH_FEE_ADDRESS;
        address payable TOKEN_FEE_ADDRESS;
        uint256 ETH_CREATION_FEE; // fee to generate a presale contract on the platform
        uint256 ROUND1_LENGTH; // length of round 1 in blocks
        uint256 MAX_PRESALE_LENGTH; // maximum difference between start and endblock
    }
    
    Settings public SETTINGS;
    
    constructor() public {
        SETTINGS.BASE_FEE = 18; // 1.8%
        SETTINGS.TOKEN_FEE = 18; // 1.8%
        SETTINGS.REFERRAL_FEE = 200; // 20%
        SETTINGS.ETH_CREATION_FEE = 5e17;
        SETTINGS.ETH_FEE_ADDRESS = msg.sender;
        SETTINGS.TOKEN_FEE_ADDRESS = msg.sender;
        SETTINGS.ROUND1_LENGTH = 10; // 553 blocks = 2 hours
        SETTINGS.MAX_PRESALE_LENGTH = 93046; // 2 weeks
    }
    
    function getRound1Length () external view returns (uint256) {
        return SETTINGS.ROUND1_LENGTH;
    }

    function getMaxPresaleLength () external view returns (uint256) {
        return SETTINGS.MAX_PRESALE_LENGTH;
    }
    
    function getBaseFee () external view returns (uint256) {
        return SETTINGS.BASE_FEE;
    }
    
    function getTokenFee () external view returns (uint256) {
        return SETTINGS.TOKEN_FEE;
    }
    
    function getReferralFee () external view returns (uint256) {
        return SETTINGS.REFERRAL_FEE;
    }
    
    function getEthCreationFee () external view returns (uint256) {
        return SETTINGS.ETH_CREATION_FEE;
    }
    
    function getEthAddress () external view returns (address payable) {
        return SETTINGS.ETH_FEE_ADDRESS;
    }
    
    function getTokenAddress () external view returns (address payable) {
        return SETTINGS.TOKEN_FEE_ADDRESS;
    }
    
    function setFeeAddresses(address payable _ethAddress, address payable _tokenFeeAddress) external onlyOwner {
        SETTINGS.ETH_FEE_ADDRESS = _ethAddress;
        SETTINGS.TOKEN_FEE_ADDRESS = _tokenFeeAddress;
    }
    
    function setFees(uint256 _baseFee, uint256 _tokenFee, uint256 _ethCreationFee, uint256 _referralFee) external onlyOwner {
        SETTINGS.BASE_FEE = _baseFee;
        SETTINGS.TOKEN_FEE = _tokenFee;
        SETTINGS.REFERRAL_FEE = _referralFee;
        SETTINGS.ETH_CREATION_FEE = _ethCreationFee;
    }
    
    function setRound1Length(uint256 _round1Length) external onlyOwner {
        SETTINGS.ROUND1_LENGTH = _round1Length;
    }

    function setMaxPresaleLength(uint256 _maxLength) external onlyOwner {
        SETTINGS.MAX_PRESALE_LENGTH = _maxLength;
    }
    
    function editAllowedReferrers(address payable _referrer, bool _allow) external onlyOwner {
        if (_allow) {
            ALLOWED_REFERRERS.add(_referrer);
        } else {
            ALLOWED_REFERRERS.remove(_referrer);
        }
    }
    
    function editEarlyAccessTokens(address _token, uint256 _holdAmount, bool _allow) external onlyOwner {
        if (_allow) {
            EARLY_ACCESS_TOKENS.add(_token);
        } else {
            EARLY_ACCESS_TOKENS.remove(_token);
        }
        EARLY_ACCESS_MAP[_token] = _holdAmount;
    }
    
    // there will never be more than 10 items in this array. Care for gas limits will be taken.
    // We are aware too many tokens in this unbounded array results in out of gas errors.
    function userHoldsSufficientRound1Token (address _user) external view returns (bool) {
        if (earlyAccessTokensLength() == 0) {
            return true;
        }
        for (uint i = 0; i < earlyAccessTokensLength(); i++) {
          (address token, uint256 amountHold) = getEarlyAccessTokenAtIndex(i);
          if (IERC20(token).balanceOf(_user) >= amountHold) {
              return true;
          }
        }
        return false;
    }
    
    function getEarlyAccessTokenAtIndex(uint256 _index) public view returns (address, uint256) {
        address tokenAddress = EARLY_ACCESS_TOKENS.at(_index);
        return (tokenAddress, EARLY_ACCESS_MAP[tokenAddress]);
    }
    
    function earlyAccessTokensLength() public view returns (uint256) {
        return EARLY_ACCESS_TOKENS.length();
    }
    
    // Referrers
    function allowedReferrersLength() external view returns (uint256) {
        return ALLOWED_REFERRERS.length();
    }
    
    function getReferrerAtIndex(uint256 _index) external view returns (address) {
        return ALLOWED_REFERRERS.at(_index);
    }
    
    function referrerIsValid(address _referrer) external view returns (bool) {
        return ALLOWED_REFERRERS.contains(_referrer);
    }
    
}