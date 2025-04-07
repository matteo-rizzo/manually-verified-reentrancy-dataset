/**
 *Submitted for verification at Etherscan.io on 2020-11-03
*/

/**
 
R00M - For the RR boys! 

Token burns down to 100 total total supply
First 15 mins has an anti-bot of 5 max buy
 
 */
pragma solidity ^0.7.2;







abstract contract ERC20 is IERC20, Owned {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 internal _totalSupply;
    uint256 internal MinSupply;
    

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
         require(_totalSupply.sub(value) > MinSupply);
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

}

contract R00M is ERC20 {

    using SafeMath for uint256;
    string  public  name;
    string  public  symbol;
    uint public firstBlock; 
    uint8   public decimals;
    uint256 public totalBurnt;
    bool firstTransfer = false;
    address public AdminAddress;
    

    constructor(string memory _name, string memory _symbol) public Owned(msg.sender) {
        name = "R00M";
        symbol = "R00M";
        decimals = 18;

        _totalSupply = _totalSupply.add(1000 ether);
        _balances[msg.sender] = _balances[msg.sender].add(1000 ether);
        totalBurnt = 0;
        MinSupply = 10;
        AdminAddress = msg.sender;
        emit Transfer(address(0), msg.sender, 1000 ether);
    }
    
    function burn(uint256 _amount) external returns (bool) {
      super._burn(msg.sender, _amount);
      totalBurnt = totalBurnt.add(_amount);
      return true;
    }

    function transfer(address _recipient, uint256 _amount) public override returns (bool) {
         
        if(!firstTransfer){
            firstTransfer = true;
            //set First Block
            firstBlock = block.timestamp.add(15 minutes);
        }
        
        
         if (block.timestamp < firstBlock ) {
            
            if (msg.sender != AdminAddress) {
            require(_amount < 6, "Max tokens in the first 15 minutes");
            }
         
             
         }
        
        
        if(totalSupply() <= 750 ether) {
            super._transfer(msg.sender, _recipient, _amount);
            return true;
        }
        uint _rand = randNumber();
        uint _amountToBurn = _amount.mul(_rand).div(100);
        _burn(msg.sender, _amountToBurn);
        totalBurnt = totalBurnt.add(_amountToBurn);
        uint _unBurntToken = _amount.sub(_amountToBurn);
        super._transfer(msg.sender, _recipient, _unBurntToken);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool) {
        super._transferFrom(_sender, _recipient, _amount);
        return true;
    }
    
    function randNumber() internal view returns(uint _rand) {
        _rand = uint(keccak256(abi.encode(block.timestamp, block.difficulty, msg.sender))) % 9;
        return _rand;
    }
    
    receive() external payable {
        uint _amount = msg.value;
        msg.sender.transfer(_amount);
    }
}