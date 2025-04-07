/**
 *Submitted for verification at Etherscan.io on 2021-02-28
*/

//////////////////////////////////////////
// PROJECT HYDRO
// Multi Chain Token
//////////////////////////////////////////
pragma solidity ^0.6.0;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */








contract HydroToken is Ownable,IERC20 {
    using SafeMath for uint256;

    string public _name;
    string public _symbol;
    uint8 public _decimals;            // Number of decimals of the smallest unit
    uint public _totalSupply;
    address public raindropAddress;
    uint256 ratio;
    uint256 public MAX_BURN= 100000000000000000; //0.1 hydro tokens

    mapping (address => uint256) public balances;
    // `allowed` tracks any extra transfer rights as in all ERC20 tokens
    mapping (address => mapping (address => uint256)) public allowed;
    mapping(address=>bool) public whitelistedDapps; //dapps that can burn tokens
    
    //makes sure only dappstore apps can burn tokens
    modifier onlyFromDapps(address _dapp){
        require(whitelistedDapps[msg.sender]==true,'Hydro: Burn error');
        _;
    }
    
    event dappBurned(address indexed _dapp, uint256 _amount );

////////////////
// Constructor
////////////////

    /// @notice Constructor to create a HydroToken
    constructor(uint256 _ratio) public {
        _name='HYDRO TOKEN';
        _symbol='HYDRO';
        _decimals=18;
        raindropAddress=address(0);
       _totalSupply = (11111111111 * 10**18)/_ratio;
        // Give the creator all initial tokens
        balances[msg.sender] = _totalSupply;
        ratio = _ratio;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    


///////////////////
// ERC20 Methods
///////////////////

    //transfers an amount of tokens from one account to another
    //accepts two variables
    function transfer(address _to, uint256 _amount) public override  returns (bool success) {
        doTransfer(msg.sender, _to, _amount);
        return true;
}

  /**
   * @dev Returns the token symbol.
   */
  function symbol() public override view returns (string memory) {
    return _symbol;
  }
  
  /**
  * @dev Returns the token name.
  */
  function name() public override view returns (string memory) {
    return _name;
  }
  
    //transfers an amount of tokens from one account to another
    //accepts three variables
    function transferFrom(address _from, address _to, uint256 _amount
    ) public override returns (bool success) {
        // The standard ERC 20 transferFrom functionality
        require(allowed[_from][msg.sender] >= _amount);
        allowed[_from][msg.sender] -= _amount;
        doTransfer(_from, _to, _amount);
        return true;
    }
    
    //allows the owner to change the MAX_BURN amount
    function changeMaxBurn(uint256 _newBurn) public onlyOwner returns(uint256 ) {
        MAX_BURN=_newBurn;
        return (_newBurn);
    }

    //internal function to implement the transfer function and perform some safety checks
    function doTransfer(address _from, address _to, uint _amount
    ) internal {
        // Do not allow transfer to 0x0 or the token contract itself
        require((_to != address(0)) && (_to != address(this)));
        require(_amount <= balances[_from]);
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
    }

    //returns balance of an address
    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }

    //allows an address to approve another address to spend its tokens
    function approve(address _spender, uint256 _amount) public override returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    //sends the approve function but with a data argument
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public  returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }
    
   /**
   * @dev Returns the token decimals.
   */
  function decimals() external view override returns (uint8) {
    return _decimals;
  }



    //returns the allowance an address has granted a spender
    function allowance(address _owner, address _spender
    ) public view override returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    //allows an owner to whitelist a dapp so it can burn tokens
    function _whiteListDapp(address _dappAddress) public onlyOwner returns(bool){
        whitelistedDapps[_dappAddress]=true;
        return true;
    }
    
    //allows an owner to blacklist a dapp so it can stop burn tokens
    function _blackListDapp(address _dappAddress) public onlyOwner returns(bool){
         whitelistedDapps[_dappAddress]=false;
         return false;
    }

    //returns current hydro totalSupply
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    //allows the owner to set the Raindrop
    function setRaindropAddress(address _raindrop) public onlyOwner {
        raindropAddress = _raindrop;
    }
    
    //the main public burn function which uses the internal burn function
    function burn(address _from,uint256 _value) external returns(uint burnAmount) {
    _burn(_from,_value);
    emit dappBurned(msg.sender,_value);
    return(burnAmount);
    }

    function authenticate(uint _value, uint _challenge, uint _partnerId) public  {
        Raindrop raindrop = Raindrop(raindropAddress);
        raindrop.authenticate(msg.sender, _value, _challenge, _partnerId);
        doTransfer(msg.sender, owner, _value);
    }

    //internal burn function which makes sure that only whitelisted addresses can burn
    function _burn(address account, uint256 amount) internal onlyFromDapps(msg.sender) {
    require(account != address(0), "ERC20: burn from the zero address");
    require(amount >= MAX_BURN,'ERC20: Exceeds maximum burn amount');
    balances[account] = balances[account].sub(amount); 
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }
}