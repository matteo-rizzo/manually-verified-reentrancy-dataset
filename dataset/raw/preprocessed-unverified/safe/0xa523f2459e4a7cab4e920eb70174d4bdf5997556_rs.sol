/**
 *Submitted for verification at Etherscan.io on 2021-04-17
*/

//https://kovan.etherscan.io/tx/0x98d60c8ff791d17417bf0ba72ee5eeabaf271f72179f790123057b409f3cbe33
//SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;




contract Context {
    constructor () public { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}


contract ERC20 is Context, IERC20, Ownable{
    using SafeMath for uint;

    mapping (address => uint) internal _balances;

    mapping (address => mapping (address => uint)) internal _allowances;

    uint internal _totalSupply;
   
    
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override  returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
   
 
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
  
    
}
contract ERC20Detailed is ERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public{
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}







  

contract PriceConsumerV3_1 {

    AggregatorV3Interface internal priceFeed;

    constructor() public {
        // Mainnet address : 0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46
        //Kovan test netwoek: 0x0bF499444525a23E7Bb61997539725cA2e928138
        priceFeed = AggregatorV3Interface(0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
    
}

contract PriceConsumerV3_2 {

    AggregatorV3Interface internal priceFeed_2;

    constructor() public {
        // Mainnet address : 0x449d117117838fFA61263B61dA6301AA2a88B13A
        //Kovan test netwoek: 0xed0616BeF04D374969f302a34AE4A63882490A8C
        priceFeed_2 = AggregatorV3Interface(0x449d117117838fFA61263B61dA6301AA2a88B13A);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice_2() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed_2.latestRoundData();
        return price;
    }
    
}

contract SSC is ERC20, ERC20Detailed, PriceConsumerV3_1, PriceConsumerV3_2{
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;

  constructor () ERC20Detailed("Sovran Shopping Club", "SSC", 18) PriceConsumerV3_1() public{

    _totalSupply =  400000000 * (10**uint256(18)) ;
	_balances[msg.sender] = _totalSupply;
  }
}


contract tokenSale is Ownable, PriceConsumerV3_1, PriceConsumerV3_2{
     
    using SafeMath for uint256;

  // The token being sold
    ERC20 public token;
    address public _owner = msg.sender;
    address payable wallet;
   
    constructor(ERC20 _token) public
    {
         
         require(address(_token) != address(0));

    
    wallet = 0x2BE3d6A94449464b01377d43bDb1e005C2D91659;
    token = _token;
    }
    fallback () payable external{
        buy(msg.sender);
    }
    
    receive() payable external {
        buy(msg.sender);
    }
    uint256 public weiUSD;
    uint256 public USDCHF;
   
    uint256 public amountOfTokens;
    uint256 public amountOfTokens2;
    
    
    function _forwardFunds(uint256 _weiUSD) internal 
    {
        wallet.transfer(_weiUSD);
    }
    
    function buy(address beneficiary) payable  public
    {
        require(msg.value > 0 ," No value transfered");
        weiUSD = (uint256)(getLatestPrice());
        require(weiUSD != 0, " No exchange value returned. Try again");
        
      
       
        uint256 unitPrice = msg.value.div(weiUSD);
        
        amountOfTokens =  unitPrice * uint256(10**18); //1 SSC token * USDC amount of Value
        
         USDCHF = (uint256)(getLatestPrice_2());
         
         uint256 unitPrice2 = amountOfTokens.div(USDCHF);
         
          amountOfTokens2 =  unitPrice2 * uint256(10**8); // 1 SSC token * CHF amount of value
        
        _forwardFunds(weiUSD);
      

        token.transfer(beneficiary, amountOfTokens2);
    
    }
   
}