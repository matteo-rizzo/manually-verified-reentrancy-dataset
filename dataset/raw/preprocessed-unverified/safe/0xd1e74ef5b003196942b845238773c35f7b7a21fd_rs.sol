pragma solidity ^0.4.18;



contract ERC20 {
    function totalSupply() public constant returns (uint256 supply);
    function balanceOf(address who) public constant returns (uint value);
    function allowance(address owner, address spender) public constant returns (uint _allowance);

    function transfer(address to, uint value) public returns (bool ok);
    function transferFrom(address from, address to, uint value) public returns (bool ok);
    function approve(address spender, uint value) public returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract AmirNessSpecial is ERC20{
    using itMaps for itMaps.itMapAddressUint;
   
    
    uint256 initialSupply = 30000;
string public constant name = "AmirNessSpecial";
string public constant symbol = "Amir";
uint currentUSDExchangeRate = 1100;
uint priceUSD = 1;
address AmirAddress;
itMaps.itMapAddressUint balances;
mapping (address => mapping (address => uint256)) allowed;
mapping (address => uint256) approvedDividends;
    event Burned(address indexed from, uint amount);
event DividendsTransfered(address to, uint amount);

modifier onlyOwner {
   if (msg.sender == AmirAddress) {
       _;
   }
}

function totalSupply() public constant returns (uint256) {
return initialSupply;
    }
    
    function balanceOf(address tokenHolder) public view returns (uint256 balance) {
return balances.get(tokenHolder);
    }

function allowance(address owner, address spender) public constant returns (uint256) {
return allowed[owner][spender];
    }


function transfer(address to, uint value) public returns (bool success) {
if (balances.get(msg.sender) >= value && value > 0) {
   
   balances.insert(msg.sender, balances.get(msg.sender)-value);
if (balances.contains(to)) {
   balances.insert(to, balances.get(to)+value);
}
else {
   balances.insert(to, value);
}
Transfer(msg.sender, to, value);
        
return true;
} else return false;
    }

function transferFrom(address from, address to, uint256 value) public returns (bool success) {
if (balances.get(from) >= value && allowed[from][msg.sender] >= value && value > 0) {
 
 uint amountToInsert = value;
 
 if (balances.contains(to))
   amountToInsert = amountToInsert+balances.get(to);
   
 balances.insert(to, amountToInsert);
 balances.insert(from, balances.get(from) - value);
 allowed[from][msg.sender] = allowed[from][msg.sender] - value;
 Transfer(from, to, value);
 return true;
} else 
 return false;
}
 
function approve(address spender, uint value) public returns (bool success) {
if ((value != 0) && (balances.get(msg.sender) >= value)){
    allowed[msg.sender][spender] = value;
   	Approval(msg.sender, spender, value);
   return true;
} else{
   return false;
}
}

function AmirNessSpecial() public {
        AmirAddress = msg.sender;
        balances.insert(AmirAddress, initialSupply);
    }

function setCurrentExchangeRate (uint rate) public onlyOwner{
currentUSDExchangeRate = rate;
}

function () public payable{
   uint amountInUSDollars = msg.value * currentUSDExchangeRate / 10**18;
   uint valueToPass = amountInUSDollars / priceUSD;
   
   if (balances.get(AmirAddress) >= valueToPass) {
            if (balances.contains(msg.sender)) {
   balances.insert(msg.sender, balances.get(msg.sender)+valueToPass);
}
else {
   balances.insert(msg.sender, valueToPass);
}
            balances.insert(AmirAddress, balances.get(AmirAddress)-valueToPass);
            Transfer(AmirAddress, msg.sender, valueToPass);
        }
}

function approveDividends (uint totalDividendsAmount) public onlyOwner {
uint256 dividendsPerToken = totalDividendsAmount*10**18 / initialSupply; 
for (uint256 i = 0; i<balances.size(); i += 1) {
address tokenHolder = balances.getKeyByIndex(i);
if (balances.get(tokenHolder)>0)
   approvedDividends[tokenHolder] = balances.get(tokenHolder)*dividendsPerToken;
}
}
function burnUnsold() public onlyOwner returns (bool success) {
   uint burningAmount = balances.get(AmirAddress);
    initialSupply -= burningAmount;
balances.insert(AmirAddress, 0);
Burned(AmirAddress, burningAmount);
        return true;
    }

function approvedDividendsOf(address tokenHolder) public view returns (uint256) {
   return approvedDividends[tokenHolder];
}

function transferAllDividends() public onlyOwner{
for (uint256 i = 0; i< balances.size(); i += 1) {
address tokenHolder = balances.getKeyByIndex(i);
if (approvedDividends[tokenHolder] > 0)
{
   tokenHolder.transfer(approvedDividends[tokenHolder]);
   DividendsTransfered (tokenHolder, approvedDividends[tokenHolder]);
   approvedDividends[tokenHolder] = 0;
}
}
}
function withdraw(uint amount) public onlyOwner{
        AmirAddress.transfer(amount*10**18);
}
}