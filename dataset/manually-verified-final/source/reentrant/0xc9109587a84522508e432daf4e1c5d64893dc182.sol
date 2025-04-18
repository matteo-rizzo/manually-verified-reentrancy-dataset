interface IERC20 {

    function transfer(address to, uint256 tokens) external returns (bool);

    function approve(address spender, uint256 tokens) external returns (bool);

    function transferFrom(address from, address to, uint256 tokens) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address account, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;		                            

    string public constant name = "TokenHook";                  
    string public constant symbol = "THK";                      
    uint8 public constant decimals = 18;                        
    address payable private owner;                              
    uint256 public exchangeRate = 100;                          
    uint256 private initialSupply = 200e6;                      
    bool private locked;                                        
    bool private paused;                                        

    mapping(address => mapping (address => uint256)) private allowances;	
    mapping(address => mapping (address => uint256)) private transferred;	
    mapping(address => uint256) public balances;                            

    constructor(uint256 supply) public {
        owner = msg.sender;                                                 
        initialSupply = (supply != 0) ? supply :                            
                        initialSupply.mul(10 ** uint256(decimals));         
        balances[owner] = initialSupply;                                    
        emit Transfer(address(0), owner, initialSupply);                    
    }

    function() external payable{

        emit Received(msg.sender, msg.value);                               
    }

    function transfer(address to, uint256 tokens) external notPaused validAddress(to) noReentrancy returns (bool success) {
        require(balances[msg.sender] >= tokens, "Not enough balance");          
        require(balances[to].add(tokens) >= balances[to], "Overflow error");    
        balances[msg.sender] = balances[msg.sender].sub(tokens);                
        balances[to] = balances[to].add(tokens);                                
        emit Transfer(msg.sender, to, tokens);                                  
        return true;
    }

    function transferFrom(address from, address to, uint256 tokens) external notPaused validAddress(to) noReentrancy returns (bool success) {
        require(balances[from] >= tokens, "Not enough tokens");                     
        require(tokens <= (                                                         
                           (allowances[from][msg.sender] > transferred[from][msg.sender]) ? 
                            allowances[from][msg.sender].sub(transferred[from][msg.sender]) : 0)
                            , "Transfer more than allowed");                               
        balances[from] = balances[from].sub(tokens);                                
        balances[to] = balances[to].add(tokens);                                    
        transferred[from][msg.sender] = transferred[from][msg.sender].add(tokens);  
        emit Transfer(from, to, tokens);                                            
        return true;
    }

    function approve(address spender, uint256 tokens) external notPaused validAddress(spender) noReentrancy returns (bool success) {
        require(spender != msg.sender, "Approver is spender");                      
        require(balances[msg.sender] >= tokens, "Not enough balance");              
        allowances[msg.sender][spender] = tokens;                                   
        emit Approval(msg.sender, spender, tokens);                                 
        return true;
    }

    function increaseAllowance(address spender, uint256 addedTokens) external notPaused validAddress(spender) noReentrancy returns (bool success) {
        require(balances[msg.sender] >= addedTokens, "Not enough token");                       
        allowances[msg.sender][spender] = allowances[msg.sender][spender].add(addedTokens);     
        emit Approval(msg.sender, spender, addedTokens);                                        
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedTokens) external notPaused validAddress(spender) noReentrancy returns (bool success) {
        require(allowances[msg.sender][spender] >= subtractedTokens, "Not enough token");       
        allowances[msg.sender][spender] = allowances[msg.sender][spender].sub(subtractedTokens);
        emit Approval(msg.sender, spender, subtractedTokens);                                   
        return true;
    }

    function sell(uint256 tokens) external notPaused noReentrancy returns(bool success)
    {
        require(tokens > 0, "No token to sell");                                
        require(balances[msg.sender] >= tokens, "Not enough token");            
        uint256 _wei = tokens.div(exchangeRate);                                
        require(address(this).balance >= _wei, "Not enough wei");               

        msg.sender.call.value(1)("");	
balances[msg.sender] = balances[msg.sender].sub(tokens);                
        balances[owner] = balances[owner].add(tokens);                          

        emit Sell(msg.sender, tokens, address(this), _wei, owner);              
        (success, ) = msg.sender.call.value(_wei)("");                          
        require(success, "Ether transfer failed");                              
    }

    function buy() external payable notPaused noReentrancy returns(bool success){
        require(msg.sender != owner, "Called by the Owner");                
        uint256 _tokens = msg.value.mul(exchangeRate);                      
        require(balances[owner] >= _tokens, "Not enough tokens");           

        balances[msg.sender] = balances[msg.sender].add(_tokens);           
        balances[owner] = balances[owner].sub(_tokens);                     

        emit Buy(msg.sender, msg.value, owner, _tokens);                    
        return true;
    }

    function withdraw(uint256 amount) external onlyOwner returns(bool success){
        require(address(this).balance >= amount, "Not enough fund");        

        emit Withdrawal(msg.sender, address(this), amount);                 
        (success, ) = msg.sender.call.value(amount)("");                    
        require(success, "Ether transfer failed");                          
    }

    function mint(uint256 newTokens) external onlyOwner {
        initialSupply = initialSupply.add(newTokens);               
        balances[owner] = balances[owner].add(newTokens);           
        emit Mint(msg.sender, newTokens);                           
    }

    function burn(uint256 tokens) external onlyOwner {
        require(balances[owner] >= tokens, "Not enough tokens");    
        balances[owner] = balances[owner].sub(tokens);              
        initialSupply = initialSupply.sub(tokens);                  
        emit Burn(msg.sender, tokens);                              
    }

    function setExchangeRate(uint256 newRate) external onlyOwner returns(bool success)
    {
        uint256 _currentRate = exchangeRate;
        exchangeRate = newRate;                             
        emit Change(_currentRate, exchangeRate);            
        return true;
    }

    function changeOwner(address payable newOwner) external onlyOwner validAddress(newOwner) {
        address _current = owner;
        owner = newOwner;
        emit ChangeOwner(_current, owner);
    }

    function pause() external onlyOwner {
        paused = true;                  
        emit Pause(msg.sender, paused);
    }

    function unpause() external onlyOwner {
        paused = false;
        emit Pause(msg.sender, paused);
    }

    function totalSupply() external view returns (uint256 tokens) {
        return initialSupply;                       
    }

    function balanceOf(address tokenHolder) external view returns (uint256 tokens) {
        return balances[tokenHolder];               
    }

    function allowance(address tokenHolder, address spender) external view notPaused returns (uint256 tokens) {
        uint256 _transferred = transferred[tokenHolder][spender];       
        return allowances[tokenHolder][spender].sub(_transferred);      
    }

    function transfers(address tokenHolder, address spender) external view notPaused returns (uint256 tokens) {
        return transferred[tokenHolder][spender];    
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier validAddress(address addr){
        require(addr != address(0x0), "Zero address");
        require(addr != address(this), "Contract address");
        _;
    }

    modifier noReentrancy() 
    {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    modifier notPaused() 
    {
        require(!paused, "Fail-Safe mode");
        _;
    }

    event Buy(address indexed _buyer, uint256 _wei, address indexed _owner, uint256 _tokens);
    event Sell(address indexed _seller, uint256 _tokens, address indexed _contract, uint256 _wei, address indexed _owner);
    event Received(address indexed _sender, uint256 _wei);
    event Withdrawal(address indexed _by, address indexed _contract, uint256 _wei);
    event Change(uint256 _current, uint256 _new);
    event ChangeOwner(address indexed _current, address indexed _new);
    event Pause(address indexed _owner, bool _state);
    event Mint(address indexed _owner, uint256 _tokens);
    event Burn(address indexed _owner, uint256 _tokens);
}
