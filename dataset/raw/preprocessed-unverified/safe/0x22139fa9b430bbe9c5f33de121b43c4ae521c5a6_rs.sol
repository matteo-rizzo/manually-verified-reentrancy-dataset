/**

 *Submitted for verification at Etherscan.io on 2018-10-08

*/



pragma solidity ^0.4.19;





contract HHRinterface {

    uint256 public totalSupply;

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool); 

}

contract HHRLocker is Ownable {

    using SafeMath for uint;

    uint lockTime;

    uint[] frozenAmount=[7500000000000,3750000000000,1875000000000,937500000000,468750000000,234375000000,117187500000,58593750000,29296875000,0];

    HHRinterface HHR;

    

    function HHRFallback(address _from, uint _value, uint _code){

        

    } //troll's trap

    function getToken(uint _amount,address _to) onlyOwner {

        uint deltaTime = now-lockTime;

        uint yearNum = deltaTime.div(1 years);

        if (_amount>frozenAmount[yearNum]){

            revert();

        }

        else{

            HHR.transfer(_to,_amount);

        }        

    }

    function setLockTime() onlyOwner {

        lockTime=now;

    }

    function HHRLocker(){

        lockTime = now;

    }

    function cashOut(uint amount) onlyOwner{

        HHR.transfer(owner,amount);

    }

    function setHHRAddress(address HHRAddress) onlyOwner{

        HHR = HHRinterface(HHRAddress);

    }

}