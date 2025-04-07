/**
 *Submitted for verification at Etherscan.io on 2021-04-15
*/

pragma solidity 0.6.12;// SPDX-License-Identifier: MIT



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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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



/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */











/**
 * @dev Collection of functions related to the address type
 */






/**
 * @title SafeERC20Detailed
 * @dev Wrappers around SafeERC20Detailed operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20Detailed for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */















contract Treasury is Ownable {
	using SafeMath for uint256;
	using SafeERC20Detailed for IERC20Detailed;

	address public immutable externalRewardToken;

	mapping(address => uint256) public liquidityDrawn;
	IUniswapV2Router public immutable uniswapRouter;
	
	constructor(address _uniswapRouter, address _externalRewardToken) public {
		require(_uniswapRouter != address(0x0), "Treasury:: Uniswap router cannot be 0");
		require(_externalRewardToken != address(0x0), "Treasury:: External reward token not set");
		uniswapRouter = IUniswapV2Router(_uniswapRouter);
		externalRewardToken = _externalRewardToken;
	}

	function withdrawLiquidity(address[] calldata rewardPools, uint256[] calldata amounts) public onlyOwner {
		require(rewardPools.length == amounts.length, "withdrawLiquidity:: pools and amounts do not match");
		for (uint256 i = 0; i < rewardPools.length; i++) {
			liquidityDrawn[rewardPools[i]] = liquidityDrawn[rewardPools[i]].add(amounts[i]);
			ITreasuryOperated(rewardPools[i]).withdrawStake(amounts[i]);
		}
	}

	function returnLiquidity(address[] calldata rewardPools, uint[] calldata externalRewards) public onlyOwner {
		require(rewardPools.length == externalRewards.length, "returnLiquidity:: pools and external tokens do not match");
		for (uint256 i = 0; i < rewardPools.length; i++) {
			address stakingToken = IRewardsPoolBase(rewardPools[i]).stakingToken();
			
			uint256 drawnLiquidity = liquidityDrawn[rewardPools[i]];
			liquidityDrawn[rewardPools[i]] = 0;
			IERC20Detailed(stakingToken).safeTransfer(rewardPools[i], drawnLiquidity);
			
			if(externalRewards[i] == 0) {
				continue;
			}
			IERC20Detailed(externalRewardToken).safeApprove(rewardPools[i], externalRewards[i]);
			ITreasuryOperated(rewardPools[i]).notifyExternalReward(externalRewards[i]);
		}
	}

	function addUniswapLiquidity(
		address tokenA,
		address tokenB,
		uint256 amountADesired,
		uint256 amountBDesired,
		uint256 amountAMin,
		uint256 amountBMin,
		uint256 deadline
	) external onlyOwner returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
		IERC20Detailed(tokenA).safeApprove(address(uniswapRouter), amountADesired);
		IERC20Detailed(tokenB).safeApprove(address(uniswapRouter), amountBDesired);
		return uniswapRouter.addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, address(this), deadline);
	}
	
	function removeUniswapLiquidity(
		address tokenA,
		address tokenB,
		address lpToken,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		uint256 deadline
	) external onlyOwner returns (uint256 amountA, uint256 amountB) {
		IERC20Detailed(lpToken).safeApprove(address(uniswapRouter), liquidity);
		return uniswapRouter.removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, address(this), deadline);
	}

	function withdrawToken(address token, uint256 amount) external onlyOwner {
		IERC20Detailed(token).safeTransfer(msg.sender, amount);
	}

}