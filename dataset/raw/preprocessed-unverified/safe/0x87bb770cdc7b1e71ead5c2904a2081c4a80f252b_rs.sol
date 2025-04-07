/**
 *Submitted for verification at Etherscan.io on 2021-05-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;


abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// 
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



// 




contract Exchange is ReentrancyGuard, Ownable {
	using SafeMath for uint256;

	ILiquidityPool public liquidityPool;
	uint256 pctPrecision;

	event SetLiquidityPool(address indexed liquidityPool);
	event Swap(address indexed user, uint256 inTokenIndex, uint256 outTokenIndex, uint256 inAmount, uint256 outAmount);

	constructor(address liquidityPool_) 
	{
		setLiquidityPool(liquidityPool_);
	}

	/***************************************
					ADMIN
	****************************************/	

	function setLiquidityPool(address liquidityPool_)
		public
		onlyOwner
	{
		liquidityPool = ILiquidityPool(liquidityPool_);
		pctPrecision = liquidityPool.PCT_PRECISION(); 
		emit SetLiquidityPool(liquidityPool_);
	}

	/***************************************
					PRIVATE
	****************************************/

	function _calculateOut(
		uint256 inTokenIndex_, 
		uint256 outTokenIndex_, 
		uint256 inAmount_
	)
		private
		view
		returns(uint256)
	{
		uint256 _borrowFee = liquidityPool.borrowFee();
		uint256 _inAmountNorm = inAmount_.mul(liquidityPool.TOKENS_MUL(inTokenIndex_));
		uint256 _outAmountNorm = _inAmountNorm.mul(pctPrecision).div(_borrowFee.add(pctPrecision)); 
		return _outAmountNorm.div(liquidityPool.TOKENS_MUL(outTokenIndex_));
	}

	/***************************************
					ACTIONS
	****************************************/

	function swap( 
		uint256 inTokenIndex_, 
		uint256 outTokenIndex_, 
		uint256 inAmount_
	)
		external
		nonReentrant
		returns (uint256)
	{
		address _inToken = liquidityPool.TOKENS(inTokenIndex_);
		address _outToken = liquidityPool.TOKENS(outTokenIndex_);
		uint256[5] memory _amounts;
		_amounts[outTokenIndex_] = _calculateOut(inTokenIndex_, outTokenIndex_, inAmount_);
		bytes memory _data = abi.encodeWithSignature(
			"callBack(address,uint256,uint256)",
			msg.sender, _inToken, inAmount_
		);
		liquidityPool.borrow(_amounts, _data);
		IERC20(_outToken).transfer(msg.sender, _amounts[outTokenIndex_]);
		emit Swap(msg.sender, inTokenIndex_,outTokenIndex_, inAmount_, _amounts[outTokenIndex_]);
		return _amounts[outTokenIndex_];
	}

	function callBack(
		address sender_,
		uint256 inToken_,
		uint256 inAmount_
	)
		external
	{
		require(msg.sender == address(liquidityPool), "wrong caller");
		IERC20(inToken_).transferFrom(sender_, address(liquidityPool), inAmount_);
	}

	/***************************************
					GETTERS
	****************************************/

	function calculateOut(
		uint256 inTokenIndex_, 
		uint256 outTokenIndex_, 
		uint256 inAmount_
	)
		external
		view
		returns(uint256)
	{
		return _calculateOut(inTokenIndex_, outTokenIndex_, inAmount_);
	}

}