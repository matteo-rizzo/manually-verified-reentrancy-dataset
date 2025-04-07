/**
 *Submitted for verification at Etherscan.io on 2021-04-29
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: MIT



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












interface IWETH is StakedToken{
    function withdraw(uint256 amount) external returns(uint256);
}


contract YearnStrategy is Ownable {
    using SafeMath for uint256;

     uint256 public lastEpochTime;
     uint256 public lastBalance;
     uint256 public lastYieldWithdrawed;

     uint256 public yearFeesPercent = 0;

     uint256 public ethPushedToYearn = 0;

     IStakeAndYield public vault;
     StakedToken public token;


    IController public controller;
    
    IYearnWETH public yweth = IYearnWETH(0xa9fE4601811213c340e850ea305481afF02f5b28);
    IWETH public weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    address public operator;

    modifier onlyOwnerOrOperator(){
        require(
            msg.sender == owner() || msg.sender == operator,
            "!owner"
        );
        _;
    }

    constructor(
        address _vault,
        address _controller
    ) public{
        vault = IStakeAndYield(_vault);
        controller = IController(_controller);
    }

    // Since Owner is calling this function, we can pass
    // the ETHPerToken amount
    function epoch(uint256 ETHPerToken) public onlyOwnerOrOperator{
        uint256 balance = pendingBalance();
        //require(balance > 0, "balance is 0");
        harvest(balance.mul(ETHPerToken).div(1 ether));
        lastEpochTime = block.timestamp;
        lastBalance = lastBalance.add(balance);

        uint256 currentWithdrawd = vault.totalYieldWithdrawed();
        uint256 withdrawAmountToken = currentWithdrawd.sub(lastYieldWithdrawed);
        if(withdrawAmountToken > 0){
            lastYieldWithdrawed = currentWithdrawd;
            uint256 ethWithdrawed = withdrawAmountToken.mul(
                ETHPerToken
            ).div(1 ether);
            
            withdrawFromYearn(ethWithdrawed);
            ethPushedToYearn = ethPushedToYearn.sub(ethWithdrawed);
        }
    }

    function harvest(uint256 ethBalance) private{
        uint256 rewards = calculateRewards();
        if(ethBalance > rewards){
            //deposit to yearn
            controller.depositForStrategy(ethBalance.sub(rewards), address(this));
            ethPushedToYearn = ethPushedToYearn.add(
                ethBalance).sub(rewards);
        }else{
            // withdraw rest of rewards from YEARN
            rewards = withdrawFromYearn(rewards.sub(ethBalance));
        }
        // get DEA and send to Vault
        if(rewards > 0){
            controller.buyForStrategy(
                rewards,
                vault.getRewardToken(),
                address(vault)
            );
        }
    }

    function withdrawFromYearn(uint256 ethAmount) private returns(uint256){
        uint256 yShares = yweth.balanceOf(address(this));

        uint256 sharesToWithdraw = ethAmount.div(
            yweth.pricePerShare()
        ).mul(1 ether);
        require(yShares >= sharesToWithdraw, "Not enough shares");

        return yweth.withdraw(sharesToWithdraw, address(controller));
    }

    function calculateRewards() public view returns(uint256){
        uint256 yShares = yweth.balanceOf(address(this));
        uint256 yETHBalance = yShares.mul(
            yweth.pricePerShare()
        ).div(1 ether);

        yETHBalance = yETHBalance.mul(1000 - yearFeesPercent).div(1000);
        if(yETHBalance > ethPushedToYearn){
            return yETHBalance - ethPushedToYearn;
        }
        return 0;
    }

    function pendingBalance() public view returns(uint256){
        uint256 vaultBalance = vault.totalSupply(2);
        if(vaultBalance < lastBalance){
            return 0;
        }
        return vaultBalance.sub(lastBalance);
    }

    function getLastEpochTime() public view returns(uint256){
        return lastEpochTime;
    }

    function setYearnFeesPercent(uint256 _val) public onlyOwner{
        yearFeesPercent = _val;
    }

    function setOperator(address _addr) public onlyOwner{
        operator = _addr;
    }

    function setController(address _controller, address _vault) public onlyOwner{
        if(_controller != address(0)){
            controller = IController(_controller);
        }
        if(_vault != address(0)){
            vault = IStakeAndYield(_vault);
        }
    }

    function emergencyWithdrawETH(uint256 amount, address addr) public onlyOwner{
        require(addr != address(0));
        payable(addr).transfer(amount);
    }

    function emergencyWithdrawERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        StakedToken(_tokenAddr).transfer(_to, _amount);
    }
}