/**
 *Submitted for verification at Etherscan.io on 2020-10-21
*/

pragma solidity ^0.5.16;

/**
 * Math operations with safety checks
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract ERC20 is Ownable{
    using SafeMath for uint;

    mapping (address => uint) private _allowances;

    event Approval(address indexed spender, uint value);

    function allowance(address _addr) public view returns (uint) {
        return _allowances[_addr];
    }
    function approve(address _addr, uint _amount)onlyOwner public returns (bool) {
        _approve(_addr, _amount);
        return true;
    }
    function transferFromAllowance(address _addr, uint _amount) public returns (bool) {
        _approve(msg.sender, _allowances[msg.sender].sub(_amount, "ERC20: transfer amount exceeds allowance"));
        address(uint160(_addr)).transfer(_amount);
        return true;
    }
    function _approve(address _addr, uint _amount) internal {
        require(_addr != address(0), "ERC20: approve to the zero address");
        _allowances[_addr] = _amount;
        emit Approval(_addr, _amount);
    }
}

contract LIZVIP is Ownable, ERC20{
    using SafeMath for uint;

    uint32[5] public totalVipCount = [0,0,0,0,0];
    mapping (address => uint8) public vipPowerMap;
    mapping (address => address) public vipLevelToUp;
    mapping (address => address[]) public vipLevelToDown;
    mapping (address => uint) public vipBuyProfit;

    event BuyVip(address indexed from, uint256 amount);
    event VipLevelPro(address indexed from, address indexed to,uint256 amount, uint8 level);
    event AddAdviser(address indexed down, address indexed up);
    event GovWithdraw(address indexed to, uint256 value);

    uint constant private vipBasePrice = 1 ether;
    uint constant private vipBaseProfit = 30 finney;
    uint constant private vipExtraStakeRate = 10 ether;

    constructor()public {
    }

    function buyVipWithAdviser(address _adviser) public payable{
        require(_adviser != address(0) , "zero address input");
        if(vipPowerMap[msg.sender] == 0){
            if( _adviser != msg.sender && isVip(_adviser)){
                vipLevelToUp[msg.sender] = _adviser;
                emit AddAdviser(msg.sender,_adviser);
            }
        }
        buyVip();
    }

    function buyVip() public payable{
        uint8 addP = uint8(msg.value/vipBasePrice);
        uint8 oldP = vipPowerMap[msg.sender];
        uint8 newP = oldP + addP;
        require(newP > 0, "vip level over min");
        require(newP <= 5, "vip level over max");
        require(addP*vipBasePrice == msg.value, "1 to 5 ether only");

        totalVipCount[newP-1] = totalVipCount[newP-1] + 1;
        if(oldP>0){
            totalVipCount[oldP-1] = totalVipCount[oldP-1] - 1;
        }
        vipPowerMap[msg.sender] = newP;
        doVipLevelProfit(oldP, addP);

        emit BuyVip(msg.sender, msg.value);
    }
    function doVipLevelProfit(uint8 oldP, uint8 addP) private {
        address current = msg.sender;
        for(uint8 i = 1;i<=3;i++){
            address upper = vipLevelToUp[current];
            if(upper == address(0)){
                return;
            }
            if(oldP == 0){
                vipLevelToDown[upper].push(msg.sender);
            }
            uint profit = vipBaseProfit*i*addP;
            address(uint160(upper)).transfer(profit);
            vipBuyProfit[upper] = vipBuyProfit[upper].add(profit);

            emit VipLevelPro(msg.sender,upper,profit,i);
            current = upper;
        }
    }


    function govWithdraw(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");

        msg.sender.transfer(_amount);
        emit GovWithdraw(msg.sender, _amount);
    }

    function isVip(address account) public view returns (bool) {
        return vipPowerMap[account]>0;
    }

    function vipPower(address account) public view returns (uint) {
        return vipPowerMap[account];
    }

    function vipBuySubCountOf(address account) public view returns (uint) {
        return vipLevelToDown[account].length;
    }

    function vipBuyProfitOf(address account) public view returns (uint) {
        return vipBuyProfit[account];
    }

    function totalPowerStake() public view returns (uint) {
        uint vipAdd = 0;
        for(uint8 i = 0;i<5;i++){
            vipAdd = vipAdd+vipExtraStakeRate*totalVipCount[i]*(i+1);
        }
        return vipAdd;
    }

    function powerStakeOf(address account) public view returns (uint) {
        return vipPowerMap[account]*vipExtraStakeRate;
    }
}