pragma solidity ^0.4.13;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract PreIco is Ownable {
    using SafeMath for uint;

    uint public decimals = 18;

    uint256 public initialSupply = 4000000 * 10 ** decimals;  // 4 milions XCC

    uint256 public remainingSupply = initialSupply;

    uint256 public tokenValue;  // value in wei

    address public updater;  // account in charge of updating the token value

    uint256 public startBlock;  // block number of contract deploy

    uint256 public endTime;  // seconds from 1970-01-01T00:00:00Z

    function PreIco(uint256 initialValue, address initialUpdater, uint256 end) {
        tokenValue = initialValue;
        updater = initialUpdater;
        startBlock = block.number;
        endTime = end;
    }

    event UpdateValue(uint256 newValue);

    function updateValue(uint256 newValue) {
        require(msg.sender == updater || msg.sender == owner);
        tokenValue = newValue;
        UpdateValue(newValue);
    }

    function updateUpdater(address newUpdater) onlyOwner {
        updater = newUpdater;
    }

    function updateEndTime(uint256 newEnd) onlyOwner {
        endTime = newEnd;
    }

    event Withdraw(address indexed to, uint value);

    function withdraw(address to, uint256 value) onlyOwner {
        to.transfer(value);
        Withdraw(to, value);
    }

    modifier beforeEndTime() {
        require(now < endTime);
        _;
    }

    event AssignToken(address indexed to, uint value);

    function () payable beforeEndTime {
        require(remainingSupply > 0);
        address sender = msg.sender;
        uint256 value = msg.value.mul(10 ** decimals).div(tokenValue);
        if (remainingSupply >= value) {
            AssignToken(sender, value);
            remainingSupply = remainingSupply.sub(value);
        } else {
            AssignToken(sender, remainingSupply);
            remainingSupply = 0;
        }
    }
}