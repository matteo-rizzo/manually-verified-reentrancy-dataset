/**
 *Submitted for verification at Etherscan.io on 2020-11-20
*/

/**
 *Submitted for verification at Etherscan.io on 2020-11-18
 */

/**
 *Submitted for verification at Etherscan.io on 2020-11-15
 */

pragma solidity ^0.6.12;

// SPDX-License-Identifier: UNLICENSED
/**
 * @dev Standard math utilities missing in the Solidity language.
 */


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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




contract StakeForIphoneComponent is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public YFOS;
    INFT public NFT;
    uint256 public minStakeAmount = 10 * 10**18;

    function handlerNumberOfProps(uint256 amount)
        internal
        view
        returns (uint256)
    {
        uint256 estimateAmount = amount.div(minStakeAmount);
        return estimateAmount > 10 ? 10 : estimateAmount;
    }

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _stakes;

    constructor(address _YFOS, address _NFT) public {
        YFOS = IERC20(_YFOS);
        NFT = INFT(_NFT);
    }

    function createdIphoneMade() public view returns (uint256) {
        return NFT.createdIphoneMade();
    }

    function successIphoneMade() public view returns (uint256) {
        return NFT.successIphoneMade();
    }

    function IPHONE_MADE_MAX() public view returns (uint256) {
        return NFT.IPHONE_MADE_MAX();
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function checkStaked(address account) public view returns (bool) {
        return _stakes[account];
    }

    function _stake(uint256 amount) internal {
        require(amount >= minStakeAmount);
        require(!_stakes[_msgSender()]);
        require(successIphoneMade() < IPHONE_MADE_MAX());
        YFOS.safeTransferFrom(_msgSender(), address(this), amount);
        _stakes[_msgSender()] = true;
        _balances[_msgSender()] = amount;
    }

    uint256 public FEE_RATE = 0;
    uint256 public constant PERCENTS_DIVIDER = 1000;

    function estimateNFT(address account) public view returns (uint256) {
        return handlerNumberOfProps(balanceOf(account));
    }

    function withdraw(address feeAddress) internal {
        require(_stakes[_msgSender()]);
        uint256 amount = balanceOf(_msgSender());
        uint256 fee = amount.div(PERCENTS_DIVIDER).mul(FEE_RATE);
        YFOS.safeTransfer(feeAddress, fee);
        YFOS.safeTransfer(_msgSender(), amount.sub(fee));
        _mint();
    }

    function _mint() private {
        uint256 amountOfStake = estimateNFT(_msgSender());
        if (amountOfStake == 1) NFT.mintTo(_msgSender());
        else NFT.multiMint(_msgSender(), amountOfStake);
        _stakes[_msgSender()] = false;
        _balances[_msgSender()] = 0;
    }

}

contract IphoneManufactory is
    StakeForIphoneComponent(
        0xCd254568EBF88f088E40f456db9E17731243cb25,
        0x8224CCCE8A2833DF69B7ECb897a3F5E1DfC4aD9F
    )
{
    using SafeMath for uint256;
    uint256 public constant DURATION_STAKE = 1 days;

    bool public stakeable = false;
    address public FEE_ADDRESS;
    mapping(address => uint256) public _stakeTimes;

    modifier checkStart() {
        require(stakeable, "Staking is not started.");
        _;
    }

    constructor() public {
        FEE_ADDRESS = _msgSender();
    }

    function setFeeAddress(address _feeAddress) public onlyOwner {
        FEE_ADDRESS = _feeAddress;
    }

    function start() public onlyOwner {
        require(!stakeable, "Staking is started.");
        stakeable = true;
    }

    function stake(uint256 amount) public checkStart {
        require(amount > 0, "Cannot stake 0");
        _stakeTimes[_msgSender()] = block.timestamp;
        super._stake(amount);
    }

    function claimIphoneComponent() public {
        require(_stakeTimes[_msgSender()] > 0);
        require(
            block.timestamp > _stakeTimes[_msgSender()].add(DURATION_STAKE)
        );
        _stakeTimes[_msgSender()] = 0;
        super.withdraw(FEE_ADDRESS);
    }
}