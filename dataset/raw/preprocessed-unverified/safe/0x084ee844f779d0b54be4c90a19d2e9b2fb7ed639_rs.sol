pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Token Holder with vesting period
 * @dev holds any amount of tokens and allows to release selected number of tokens after every vestingInterval seconds
 */
contract TokenHolder is Ownable {
    using SafeMath for uint;

    event Released(uint amount);

    /**
     * @dev start of the vesting period
     */
    uint public start;
    /**
     * @dev interval between token releases
     */
    uint public vestingInterval;
    /**
     * @dev already released value
     */
    uint public released;
    /**
     * @dev value can be released every period
     */
    uint public value;
    /**
     * @dev holding token
     */
    ERC20Basic public token;

    constructor(uint _start, uint _vestingInterval, uint _value, ERC20Basic _token) public {
        start = _start;
        vestingInterval = _vestingInterval;
        value = _value;
        token = _token;
    }

    /**
     * @dev transfers vested tokens to beneficiary (to the owner of the contract)
     * @dev automatically calculates amount to release
     */
    function release() onlyOwner public {
        uint toRelease = calculateVestedAmount().sub(released);
        uint left = token.balanceOf(this);
        if (left < toRelease) {
            toRelease = left;
        }
        require(toRelease > 0, "nothing to release");
        released = released.add(toRelease);
        require(token.transfer(msg.sender, toRelease));
        emit Released(toRelease);
    }

    function calculateVestedAmount() view internal returns (uint) {
        return now.sub(start).div(vestingInterval).mul(value);
    }
}