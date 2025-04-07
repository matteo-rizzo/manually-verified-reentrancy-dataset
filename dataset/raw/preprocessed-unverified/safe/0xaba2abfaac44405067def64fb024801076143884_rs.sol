/**
 *Submitted for verification at Etherscan.io on 2021-07-20
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
/**
 * @dev Collection of functions related to the address type
 */




// 
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



// 
contract ExchangeWorker is Ownable {
	using SafeERC20 for IERC20;
	address public balToken;
	address public outToken;
	address public worker;
	IVault public bVault;
	bytes32 public bPoolIdOne;
	bytes32 public bPoolIdTwo;
	address public bIntermediateToken;

	constructor (
			address balToken_,
			address outToken_,
			address worker_,
			IVault bVault_,
			bytes32 bPoolIdOne_,
			bytes32 bPoolIdTwo_,
			address bIntermediateToken_
		)
	{
		balToken = balToken_;
		outToken = outToken_;
		worker = worker_;
		bVault = bVault_;
		setPools(bPoolIdOne_, bPoolIdTwo_, bIntermediateToken_);
		IERC20(balToken).safeApprove(address(bVault), type(uint256).max);
		if(outToken != bIntermediateToken)
			IERC20(bIntermediateToken).safeApprove(address(bVault), type(uint256).max);
	}

	function setPools(bytes32 bPoolIdOne_, bytes32 bPoolIdTwo_, address bIntermediateToken_)
		public
		onlyOwner
	{
		bPoolIdOne = bPoolIdOne_;
		bPoolIdTwo = bPoolIdTwo_;
		bIntermediateToken = bIntermediateToken_;
	}

	function exchangeBal(uint256 balAmount_)
		external
	{
		IERC20(balToken).safeTransferFrom(msg.sender, address(this), balAmount_);
		IVault.FundManagement memory _funds;
		_funds.sender = address(this);
		if(outToken == bIntermediateToken)
			_funds.recipient = payable(worker);
		else
			_funds.recipient = payable(address(this));
		IVault.SingleSwap memory _singleSwap;
		_singleSwap.kind = IVault.SwapKind.GIVEN_IN;

		_singleSwap.poolId = bPoolIdOne;
		_singleSwap.assetIn = balToken;
		_singleSwap.assetOut = bIntermediateToken;
		_singleSwap.amount = balAmount_;
		uint256 _amountOut = bVault.swap(_singleSwap, _funds, 0, block.timestamp+1);
		if(outToken != bIntermediateToken){
			_funds.recipient = payable(worker);
			_singleSwap.poolId = bPoolIdTwo;
			_singleSwap.assetIn = bIntermediateToken;
			_singleSwap.assetOut = outToken;
			_singleSwap.amount = _amountOut;
			_amountOut = bVault.swap(_singleSwap, _funds, 0, block.timestamp+1);
		}
	}
}