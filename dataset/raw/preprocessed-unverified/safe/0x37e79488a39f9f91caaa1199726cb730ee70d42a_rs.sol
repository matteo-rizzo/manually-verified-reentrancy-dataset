/**
 *Submitted for verification at Etherscan.io on 2020-11-21
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


contract ETH2Validator is Ownable{
    using SafeMath for uint;
    mapping (address => uint8) private _vipPowerMap;

    mapping (uint32  => address) private _userList;
    uint32 private _currentUserCount;

    event BuyPower(address indexed from, uint256 amount);
    event GovWithdraw(address indexed to, uint256 value);

    uint constant private basePrice = 1 ether;

    constructor()public {
    }

    function buyPower() public payable{
        uint8 addP = uint8(msg.value/ basePrice);
        uint8 oldP = _vipPowerMap[msg.sender];
        uint8 newP = oldP + addP;
        require(newP > 0, "vip level over min");
        require(newP <= 10, "vip level over max");
        require(addP* basePrice == msg.value, "1 to 10 ether only");
        
        if(oldP==0){
            _userList[_currentUserCount] = msg.sender;
            _currentUserCount++;
        }
        
        _vipPowerMap[msg.sender] = newP;
        emit BuyPower(msg.sender, msg.value);
    }

    function govWithdraw(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");

        msg.sender.transfer(_amount);
        emit GovWithdraw(msg.sender, _amount);
    }

    function powerOf(address account) public view returns (uint) {
        return _vipPowerMap[account];
    }

    function currentUserCount() public view returns (uint32) {
        return _currentUserCount;
    }

    function userList(uint32 i) public view returns (address) {
        return _userList[i];
    }

}