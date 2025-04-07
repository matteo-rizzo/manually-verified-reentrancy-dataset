pragma solidity ^0.4.15;

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
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ArbiPreIco is Ownable {
    using SafeMath for uint256;
    
    //the token being sold
    ERC20 arbiToken;
    address public tokenAddress;

    /* owner of tokens to spend */ 
    address public tokenOwner;
    
    uint public startTime;
    uint public endTime;
    uint public price;

    uint public hardCapAmount = 33333200;

    uint public tokensRemaining = hardCapAmount;

    /**
    * event for token purchase logging
    * @param beneficiary who got the tokens
    * @param amount amount of tokens purchased
    */ 
    event TokenPurchase(address indexed beneficiary, uint256 amount);

    function ArbiPreIco(address token, address owner, uint start, uint end) public {
        tokenAddress = token;
        tokenOwner = owner;
        arbiToken = ERC20(token);
        startTime = start;
        endTime = end;
        price = 0.005 / 100 * 1 ether; //1.00 token = 0.005 ether
    }

    /**
    * fallback function to receive ether 
    */
    function () payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(isActive());
        require(msg.value >= 0.01 ether);
        uint amount = msg.value;
        uint tokenAmount = amount.div(price);
        makePurchase(beneficiary, tokenAmount);
    }

    function sendEther(address _to, uint amount) onlyOwner {
        _to.transfer(amount);
    }
    
    function isActive() constant returns (bool active) {
        return now >= startTime && now <= endTime && tokensRemaining > 0;
    }
    
    /** 
    * function for external token purchase 
    * @param _to receiver of tokens
    * @param amount of tokens to send
    */
    function sendToken(address _to, uint256 amount) onlyOwner {
        makePurchase(_to, amount);
    }

    function makePurchase(address beneficiary, uint256 amount) private {
        require(amount <= tokensRemaining);
        arbiToken.transferFrom(tokenOwner, beneficiary, amount);
        tokensRemaining = tokensRemaining.sub(amount);
        TokenPurchase(beneficiary, amount);
    }
    
}