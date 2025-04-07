/**
 *Submitted for verification at Etherscan.io on 2021-03-07
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;




contract Context {
    constructor () public { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}


contract ERC20 is Context, IERC20 {
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
    function _transfer(address sender, address recipient, uint amount) public {
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
    
 
    
    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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







  

contract PriceConsumerV3 {

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

contract GoldT is ERC20, ERC20Detailed, PriceConsumerV3{
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;
  
  
  address public ownership;

  constructor () ERC20Detailed("GoldToken", "GoldT", 18) PriceConsumerV3() public{
      ownership = msg.sender;
    _totalSupply = 10000000000 * (10**uint256(18)) ;
	_balances[ownership] = _totalSupply;
  }
}


contract tokenSale is Ownable, PriceConsumerV3{
     
    using SafeMath for uint256;

  // The token being sold
    ERC20 public token;
    address public _owner = msg.sender;
    address payable wallet = msg.sender;
    address[] tokenHolders;
    constructor(ERC20 _token) public
    {
         
         require(address(_token) != address(0));

    
    wallet = msg.sender;
    token = _token;
    }
    fallback () payable external{
        buy(msg.sender);
    }
    
    receive() payable external {
        buy(msg.sender);
    }
    uint256 public weiUSD;
   
    uint256 public amountOfTokens;
    
    
    function _forwardFunds(uint256 _weiUSD) internal 
    {
        wallet.transfer(_weiUSD);
    }
    
    function buy(address beneficiary) payable  public
    {
        require(msg.value > 0 ether," No value transfered");
        weiUSD = (uint256)(getLatestPrice());
        require(weiUSD != 0, " No exchange value returned. Try again");
       
        uint256 unitPrice = msg.value.div(weiUSD);
        
        amountOfTokens =  unitPrice * uint256(10**18); //1 GoldT token * USD amount of Value
        
        _forwardFunds(weiUSD);
        uint256 twoPercent = calculateTwoPercent(amountOfTokens);

        token.transfer(beneficiary, (amountOfTokens + twoPercent));
    
    } 
  
    function calculateTwoPercent(uint256 _amountOfTokens) internal returns (uint256)
    {
         uint256 _twoPercent = 2 * amountOfTokens / 100 ;
         return _twoPercent;
    }
    
    address burnAddress = 0x000000000000000000000000000000000000dEaD;
  
    function getGoldCoin(address _beneficiary) public returns(string memory)
    {
      require(_beneficiary != address(0), "It should be real address" );
      if(token.balanceOf(_beneficiary) >= 1050 * (10**18))
      {
          token._transfer(_beneficiary, wallet, 50*(10**18));
        
          token._transfer(_beneficiary, burnAddress, 1000 * (10**18));
          
          tokenHolders.push(_beneficiary);
       
          return "Hurrah !! You can claim your Gold Coin.";
           
      }
      else
      {
          return "Alert !! You should have 1000 GoldT tokens to claim a real Gold Coin.";
      }
      
    }

  
    function claimCoin(address claimer) public returns (bytes memory)
    {
        require(claimer != address(0),"It should be a real address");
        for(uint256 a= 0 ; a<= tokenHolders.length; a++)
        {
            if(tokenHolders[a] == claimer)
            {
            return 'Congratulations!! You will be rewarded with a physical gold coin. Please connect with us to get your reward.';
            break;
            }
           
        }
        
      
    }
    function getHolders() public onlyOwner returns(address[] memory)
    {
        return tokenHolders;
    }
    
   
}