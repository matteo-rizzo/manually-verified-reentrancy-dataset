/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity 0.5.10;




contract ERC20 {
	   event Transfer(address indexed from, address indexed to, uint256 tokens);
       event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

   	   function totalSupply() public view returns (uint256);
       function balanceOf(address tokenOwner) public view returns (uint256 balance);
       function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

       function transfer(address to, uint256 tokens) public returns (bool success);
       
       function approve(address spender, uint256 tokens) public returns (bool success);
       function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
}

contract WDAI is Ownable {
    string public name     = "Wrapped DAI";
    string public symbol   = "WDAI";
    uint8  public decimals = 18;
    string public company  = "ShuttleOne Pte Ltd";

    event  Approval(address indexed _tokenOwner, address indexed _spender, uint256 _amount);
    event  Transfer(address indexed _from, address indexed _to, uint256 _amount);
    
    event  Deposit(address indexed _from, uint256 _amount);
    event  Withdraw(address indexed _to, uint256 _amount);

    mapping (address => uint256) public  balance;
    mapping (address => mapping (address => uint256))  public  allowed;

    mapping (address => bool)  public allowTransfer;

    ERC20  daiToken;
    
     constructor() public {
         daiToken = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); //Dai Stablecoin (DAI)
         
     }
     
    function deposit(address _from,uint256 amount) public returns (bool) {
        
        if(daiToken.transferFrom(_from,address(this),amount) == true){
            balance[_from] += amount;
            emit Deposit(_from,amount);
            emit Transfer(address(0),_from,amount);
        }
    }
    
    function withdraw(uint256 _amount) public {
        require(balance[msg.sender] >= _amount,"WDAI/ERROR-out-of-balance-withdraw");
        balance[msg.sender] -= _amount;
        daiToken.transfer(msg.sender,_amount);
        emit Withdraw(msg.sender, _amount);
        emit Transfer(msg.sender,address(0),_amount);
    }

    function balanceOf(address _addr) public view returns (uint256){
        return balance[_addr]; 
     }

    function totalSupply() public view returns (uint) {
        return daiToken.balanceOf(address(this));
    }

     function approve(address _spender, uint256 _amount) public returns (bool){
            allowed[msg.sender][_spender] = _amount;
            emit Approval(msg.sender, _spender, _amount);
            return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256){
          return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(balance[msg.sender] >= _amount,"WDAI/ERROR-out-of-balance-transfer");
        require(_to != address(0),"WDAI/ERROR-transfer-addr-0");
        require(allowTransfer[msg.sender],"WDAI/ERROR-transfer-not-allow");

        balance[msg.sender] -= _amount;
        balance[_to] += _amount;
        emit Transfer(msg.sender,_to,_amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool)
    {
        require(balance[_from] >= _amount,"WDAI/ERROR-transFrom-out-of");
        require(allowed[_from][msg.sender] >= _amount,"WDAI/ERROR-spender-outouf"); 
        require(allowTransfer[msg.sender],"WDAI/ERROR-transfrom-not-allow");

        balance[_from] -= _amount;
        balance[_to] += _amount;
        allowed[_from][msg.sender] -= _amount;
        emit Transfer(_from, _to, _amount);

        return true;
    }
    
    function intTransfer(address _from, address _to, uint256 _amount) external onlyOwners returns(bool){
           require(balance[_from] >= _amount,"WDAI/ERROR-intran-outof");
           require(_to != address(0),"WDAI/ERROR-intran-addr0");
           
           balance[_from] -= _amount; 
           balance[_to] += _amount;
    
           emit Transfer(_from,_to,_amount);
           return true;
    }
     
    function intWithdraw(address _to,uint256 _amount) public onlyOwners returns(bool){
        require(balance[_to] >= _amount,"WDAI/ERROR-withdraw-outof");
        balance[_to] -= _amount;
        daiToken.transfer(_to,_amount);
        emit Withdraw(_to, _amount);
        emit Transfer(_to,address(0),_amount);
    } 
    
    function setAllowTransfer(address _addr,bool _allow) public onlyOwners returns(bool){
        allowTransfer[_addr] = _allow;
    }
    
}