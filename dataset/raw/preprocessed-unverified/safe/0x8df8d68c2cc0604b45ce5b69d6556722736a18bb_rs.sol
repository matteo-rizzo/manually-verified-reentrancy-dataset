/**

 *Submitted for verification at Etherscan.io on 2018-09-24

*/



pragma solidity 0.4.25;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */



















/**

 * @title TokenTimelock

 * @dev TokenTimelock is a token holder contract that will allow a

 * beneficiary to extract the tokens after a given release time

 */

contract Escrow is Ownable {

    using SafeMath for uint256;



    struct Stage {

        uint releaseTime;

        uint percent;

        bool transferred;

    }



    mapping (uint => Stage) public stages;

    uint public stageCount;



    uint public stopDay;

    uint public startBalance = 0;





    constructor(uint _stopDay) public {

        stopDay = _stopDay;

    }



    function() payable public {



    }



    //1% - 100, 10% - 1000 50% - 5000

    function addStage(uint _releaseTime, uint _percent) onlyOwner public {

        require(_percent >= 100);

        require(_releaseTime > stages[stageCount].releaseTime);

        stageCount++;

        stages[stageCount].releaseTime = _releaseTime;

        stages[stageCount].percent = _percent;

    }





    function getETH(uint _stage, address _to) onlyManager external {

        require(stages[_stage].releaseTime < now);

        require(!stages[_stage].transferred);

        require(_to != address(0));



        if (startBalance == 0) {

            startBalance = address(this).balance;

        }



        uint val = valueFromPercent(startBalance, stages[_stage].percent);

        stages[_stage].transferred = true;

        _to.transfer(val);

    }





    function getAllETH(address _to) onlyManager external {

        require(stopDay < now);

        require(address(this).balance > 0);

        require(_to != address(0));



        _to.transfer(address(this).balance);

    }





    function transferETH(address _to) onlyOwner external {

        require(address(this).balance > 0);

        require(_to != address(0));

        _to.transfer(address(this).balance);

    }





    //1% - 100, 10% - 1000 50% - 5000

    function valueFromPercent(uint _value, uint _percent) internal pure returns (uint amount)    {

        uint _amount = _value.mul(_percent).div(10000);

        return (_amount);

    }



    function setStopDay(uint _stopDay) onlyOwner external {

        stopDay = _stopDay;

    }

}