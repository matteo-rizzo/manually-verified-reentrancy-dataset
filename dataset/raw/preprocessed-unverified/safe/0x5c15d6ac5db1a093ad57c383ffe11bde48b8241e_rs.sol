pragma solidity ^0.4.18;
    
    
    
    contract owned {
    
    
    	    address public owner;
    
    
    	    function owned() payable public {
    	        owner = msg.sender;
    	    }
    	    
    	    modifier onlyOwner {
    	        require(owner == msg.sender);
    	        _;
    	    }
    
    
    	    function changeOwner(address _owner) onlyOwner public {
    	        owner = _owner;
    	    }
    	}
    contract Crowdsale is owned {
    	    
    	    uint256 public totalSupply;
    	
    	    mapping (address => uint256) public balanceOf;
    
    
    	    event Transfer(address indexed from, address indexed to, uint256 value);
    	    
    	    function Crowdsale() payable owned() public {
                totalSupply = 1000000000 * 1000000000000000000; 
                // ico
    	        balanceOf[this] = 900000000 * 1000000000000000000;   
    	        balanceOf[owner] = totalSupply - balanceOf[this];
    	        Transfer(this, owner, balanceOf[owner]);
    	    }
    
    	    function () payable public {
    	        require(balanceOf[this] > 0);
    	        
    	        uint256 tokensPerOneEther = 200000 * 1000000000000000000;
    	        uint256 tokens = tokensPerOneEther * msg.value / 1000000000000000000;
    	        if (tokens > balanceOf[this]) {
    	            tokens = balanceOf[this];
    	            uint valueWei = tokens * 1000000000000000000 / tokensPerOneEther;
    	            msg.sender.transfer(msg.value - valueWei);
    	        }
    	        require(tokens > 0);
    	        balanceOf[msg.sender] += tokens;
    	        balanceOf[this] -= tokens;
    	        Transfer(this, msg.sender, tokens);
    	    }
    	}
    contract PerfectCoin is Crowdsale {
        
            using SafeMath for uint256;
            string  public name        = 'PerfectCoin';
    	    string  public symbol      = 'PC';
    	    string  public standard    = 'PerfectCoin 0.1';
            
    	    uint8   public decimals    = 18;
    	    mapping (address => mapping (address => uint256)) internal allowed;
    	    
    	    function PerfectCoin() payable Crowdsale() public {}
    	    
    	    function transfer(address _to, uint256 _value) public {
    	        require(balanceOf[msg.sender] >= _value);
    	        balanceOf[msg.sender] -= _value;
    	        balanceOf[_to] += _value;
    	        Transfer(msg.sender, _to, _value);
    	    }
    	}
    contract PerfectCoinControl is PerfectCoin {
    	    function PerfectCoinControl() payable PerfectCoin() public {}
    	    function withdraw() onlyOwner {    
    	        owner.transfer(this.balance);  
    	    }
    	    function killMe()  onlyOwner {
    	        selfdestruct(owner);
    	    }
    	}