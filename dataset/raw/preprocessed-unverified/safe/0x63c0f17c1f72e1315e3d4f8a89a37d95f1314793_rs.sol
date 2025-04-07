pragma solidity ^0.4.11;

/**
 * Math operations with safety checks
 */


contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
}

/*  ERC 20 token */
contract PreSaleToken is Token {

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    mapping (address => uint256) balances;
}

contract MASSTokenPreSale is PreSaleToken {
    using SafeMath for uint256;

    uint256 public constant decimals = 18;
    
    bool public isEnded = false;
    address public contractOwner;
    address public massEthFund;
    uint256 public presaleStartBlock;
    uint256 public presaleEndBlock;
    uint256 public constant tokenExchangeRate = 1300;
    uint256 public constant tokenCap = 13 * (10**6) * 10**decimals;
    
    event CreatePreSale(address indexed _to, uint256 _amount);
    
    function MASSTokenPreSale(address _massEthFund, uint256 _presaleStartBlock, uint256 _presaleEndBlock) {
        massEthFund = _massEthFund;
        presaleStartBlock = _presaleStartBlock;
        presaleEndBlock = _presaleEndBlock;
        contractOwner = massEthFund;
        totalSupply = 0;
    }
    
    function () payable public {
        if (isEnded) throw;
        if (block.number < presaleStartBlock) throw;
        if (block.number > presaleEndBlock) throw;
        if (msg.value == 0) throw;
        
        uint256 tokens = msg.value.mul(tokenExchangeRate);
        uint256 checkedSupply = totalSupply.add(tokens);
        
        if (tokenCap < checkedSupply) throw;
        
        totalSupply = checkedSupply;
        balances[msg.sender] += tokens;
        CreatePreSale(msg.sender, tokens);
    }
    
    function endPreSale() public {
        require (msg.sender == contractOwner);
        if (isEnded) throw;
        if (block.number < presaleEndBlock && totalSupply != tokenCap) throw;
        isEnded = true;
        if (!massEthFund.send(this.balance)) throw;
    }
}