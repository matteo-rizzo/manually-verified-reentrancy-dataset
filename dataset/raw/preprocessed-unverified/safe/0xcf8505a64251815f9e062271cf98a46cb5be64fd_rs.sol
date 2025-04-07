/**
 *Submitted for verification at Etherscan.io on 2020-10-29
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


contract LIZSAKE is Ownable{
    using SafeMath for uint;
    uint256 public totalStake;

    uint8  public governanceRate = 12;
    uint public vipMaxStake = 32 ether;

    mapping (address => uint256) private _stakes;

    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed to, uint256 value);
    event GovWithdraw(address indexed to, uint256 value);

    uint constant private minInvestmentLimit = 10 finney;

    constructor()public {
    }


    function deposit()payable public {
        require(msg.value > 0, "!value");
        if(_stakes[msg.sender] == 0){
            require(msg.value >= minInvestmentLimit,"!deposit limit");
        }
        totalStake = totalStake.add(msg.value);
        _stakes[msg.sender] = _stakes[msg.sender].add(msg.value);
        emit Deposit(msg.sender,msg.value);
    }

    function withdraw(uint256 _amount) public {
        require(_amount > 0, "!value");
        uint reduceAmount = _amount;
        if(governanceRate > 0){
            reduceAmount = _amount.mul(100).div(100-governanceRate);
        }
        _stakes[msg.sender] = _stakes[msg.sender].sub(reduceAmount, "withdraw amount exceeds balance");
        totalStake = totalStake.sub(reduceAmount, "withdraw amount exceeds totalStake");
        msg.sender.transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }

    function govWithdraw(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");
        msg.sender.transfer(_amount);
        emit GovWithdraw(msg.sender, _amount);
    }


    function changeRate(uint8 _rate)onlyOwner public {
        require(100 > _rate, "governanceRate big than 100");
        governanceRate = _rate;
    }

    function vitailk(uint _newMax)onlyOwner public {
        vipMaxStake = _newMax;
    }

    function() external payable {
    }

    function stakeOf(address account) public view returns (uint) {
        return _stakes[account];
    }
}