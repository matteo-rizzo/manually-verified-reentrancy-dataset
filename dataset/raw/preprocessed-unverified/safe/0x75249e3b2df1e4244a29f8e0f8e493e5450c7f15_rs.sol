/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;





enum OrderState {Placed, Cancelled, Executed}



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
contract Ownable is Context {
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


contract LK3RsExecutingOnUnitrade is Ownable{

    UnitradeInterface iUniTrade = UnitradeInterface(
        0xC1bF1B4929DA9303773eCEa5E251fDEc22cC6828
    );

    //change this to lock3r on deploy
    ILock3rV1Mini public LK3R;
    uint public minKeep = 100e18;

    bool TryDeflationaryOrders = false;
    bool public payoutETH = true;
    bool public payoutLK3R = true;

    mapping(address => bool) public tokenOutSkip;


    constructor(address lockertoken) public {
        LK3R = ILock3rV1Mini(lockertoken);
        addSkipTokenOut(0x610c67be018A5C5bdC70ACd8DC19688A11421073);
    }

    modifier upkeep() {
        require(LK3R.isMinLocker(msg.sender, minKeep, 0, 0), "::isLocker: locker is not registered");
        _;
        if(payoutLK3R) {
            //Payout LK3R
            LK3R.worked(msg.sender);
        }
    }

    function togglePayETH() public onlyOwner {
        payoutETH = !payoutETH;
    }

    function togglePayLK3R() public onlyOwner {
        payoutLK3R = !payoutLK3R;
    }

    function addSkipTokenOut(address token) public onlyOwner {
        tokenOutSkip[token] = true;
    }

    function setMinKeep(uint _keep) public onlyOwner {
        minKeep = _keep;
    }

    //Use this to depricate this job to move rlr to another job later
    function destructJob() public onlyOwner {
     //Get the credits for this job first
     uint256 currLK3RCreds = LK3R.credits(address(this),address(LK3R));
     uint256 currETHCreds = LK3R.credits(address(this),LK3R.ETH());
     //Send out LK3R Credits if any
     if(currLK3RCreds > 0) {
        //Invoke receipt to send all the credits of job to owner
        LK3R.receipt(address(LK3R),owner(),currLK3RCreds);
     }
     //Send out ETH credits if any
     if (currETHCreds > 0) {
        LK3R.receiptETH(owner(),currETHCreds);
     }
     //Finally self destruct the contract after sending the credits
     selfdestruct(payable(owner()));
    }

    function setTryBurnabletokens(bool fTry) public onlyOwner{
        TryDeflationaryOrders = fTry;
    }


    function getIfExecuteable(uint256 i) public view returns (bool) {
        (
            ,
            ,
            address tokenIn,
            address tokenOut,
            uint256 amountInOffered,
            uint256 amountOutExpected,
            uint256 executorFee,
            ,
            OrderState orderState,
            bool deflationary
        ) = iUniTrade.getOrder(i);
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        if(executorFee <= 0) return false;//Dont execute unprofitable orders
        if(deflationary && !TryDeflationaryOrders) return false;//Skip deflationary token orders as it is not supported atm
        if(tokenOutSkip[tokenOut]) return false;//Skip tokens that are set in mapping
        uint256[] memory amounts = UniswapV2Library.getAmountsOut(
            iUniTrade.uniswapV2Factory(),
            amountInOffered,
            path
        );
        if (
            amounts[1] >= amountOutExpected && orderState == OrderState.Placed
        ) {
            return true;
        }
        return false;
    }

    function hasExecutableOrdersPending() public view returns (bool) {
        for (uint256 i = 0; i < iUniTrade.getActiveOrdersLength() - 1; i++) {
            if (getIfExecuteable(iUniTrade.getActiveOrderId(i))) {
                return true;
            }
        }
        return false;
    }

    //Get count of executable orders
    function getExectuableOrdersCount() public view returns (uint count){
        for (uint256 i = 0; i < iUniTrade.getActiveOrdersLength() - 1; i++) {
            if (getIfExecuteable(iUniTrade.getActiveOrderId(i))) {
                count++;
            }
        }
    }

    function getExecutableOrdersList() public view returns (uint[] memory) {
        uint[] memory orderArr = new uint[](getExectuableOrdersCount());
        uint index = 0;
        for (uint256 i = 0; i < iUniTrade.getActiveOrdersLength() - 1; i++) {
            if (getIfExecuteable(iUniTrade.getActiveOrderId(i))) {
                orderArr[index] = iUniTrade.getActiveOrderId(i);
                index++;
            }
        }
        return orderArr;
    }

    receive() external payable {}

    function sendETHRewards() internal {
        if(!payoutETH) {
            //Transfer received eth to treasury
            (bool success,  ) = payable(owner()).call{value : address(this).balance}("");
            require(success,"!treasurysend");
        }
        else {
            (bool success,  ) = payable(msg.sender).call{value : address(this).balance}("");
            require(success,"!sendETHRewards");
        }
    }

    function workable() public view returns (bool) {
        return hasExecutableOrdersPending();
    }

    function work() public upkeep{
        require(workable(),"!workable");
        for (uint256 i = 0; i < iUniTrade.getActiveOrdersLength() - 1; i++) {
            if (getIfExecuteable(iUniTrade.getActiveOrderId(i))) {
                iUniTrade.executeOrder(i);
            }
        }
        //After order executions send all the eth to locker
        sendETHRewards();
    }

    //Use this to save on gas
    function workBatch(uint[] memory orderList) public upkeep {
        require(workable(),"!workable");
        for (uint256 i = 0; i < orderList.length; i++) {
            iUniTrade.executeOrder(orderList[i]);
        }
        //After order executions send all the eth to locker
        sendETHRewards();
    }
}