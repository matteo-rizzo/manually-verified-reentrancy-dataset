/**

 *Submitted for verification at Etherscan.io on 2018-11-16

*/



pragma solidity ^0.4.24;



contract Config {

    uint256 public constant jvySupply = 333333333333333;

    uint256 public constant bonusSupply = 83333333333333;

    uint256 public constant saleSupply =  250000000000000;

    uint256 public constant hardCapUSD = 8000000;



    uint256 public constant preIcoBonus = 25;

    uint256 public constant minimalContributionAmount = 0.4 ether;



    function getStartPreIco() public view returns (uint256) {

        // solium-disable-next-line security/no-block-members

        uint256 nowTime = block.timestamp;

        // uint256 _preIcoStartTime = nowTime + 2 days;

        uint256 _preIcoStartTime = nowTime + 1 minutes;

        return _preIcoStartTime;

    }



    function getStartIco() public view returns (uint256) {

        // solium-disable-next-line security/no-block-members

        // uint256 nowTime = block.timestamp;

        // uint256 _icoStartTime = nowTime + 20 days;

        uint256 _icoStartTime = 1543554000;

        return _icoStartTime;

    }



    function getEndIco() public view returns (uint256) {

        // solium-disable-next-line security/no-block-members

        // uint256 nowTime = block.timestamp;

        // uint256 _icoEndTime = nowTime + 50 days;

        uint256 _icoEndTime = 1551416400;

        return _icoEndTime;

    }

}



contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}









contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}





contract DetailedERC20 is ERC20 {

  string public name;

  string public symbol;

  uint8 public decimals;



  constructor(string _name, string _symbol, uint8 _decimals) public {

    name = _name;

    symbol = _symbol;

    decimals = _decimals;

  }

}



contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) internal balances;



  uint256 internal totalSupply_;



  /**

  * @dev Total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev Transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_value <= balances[msg.sender]);

    require(_to != address(0));



    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];

  }



}



contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) internal allowed;





  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(

    address _from,

    address _to,

    uint256 _value

  )

    public

    returns (bool)

  {

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);

    require(_to != address(0));



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }



  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   * Beware that changing an allowance with this method brings the risk that someone may use both the old

   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param _spender The address which will spend the funds.

   * @param _value The amount of tokens to be spent.

   */

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);

    return true;

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param _owner address The address which owns the funds.

   * @param _spender address The address which will spend the funds.

   * @return A uint256 specifying the amount of tokens still available for the spender.

   */

  function allowance(

    address _owner,

    address _spender

   )

    public

    view

    returns (uint256)

  {

    return allowed[_owner][_spender];

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(

    address _spender,

    uint256 _addedValue

  )

    public

    returns (bool)

  {

    allowed[msg.sender][_spender] = (

      allowed[msg.sender][_spender].add(_addedValue));

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(

    address _spender,

    uint256 _subtractedValue

  )

    public

    returns (bool)

  {

    uint256 oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue >= oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}







contract JavvyToken is DetailedERC20, StandardToken, Ownable, Config {

    address public crowdsaleAddress;

    address public bonusAddress;

    address public multiSigAddress;



    constructor(

        string _name, 

        string _symbol, 

        uint8 _decimals

    ) public

    DetailedERC20(_name, _symbol, _decimals) {

        require(

            jvySupply == saleSupply + bonusSupply,

            "Sum of provided supplies is not equal to declared total Javvy supply. Check config!"

        );

        totalSupply_ = tokenToDecimals(jvySupply);

    }



    function initializeBalances(

        address _crowdsaleAddress,

        address _bonusAddress,

        address _multiSigAddress

    ) public 

    onlyOwner() {

        crowdsaleAddress = _crowdsaleAddress;

        bonusAddress = _bonusAddress;

        multiSigAddress = _multiSigAddress;



        _initializeBalance(_crowdsaleAddress, saleSupply);

        _initializeBalance(_bonusAddress, bonusSupply);

    }



    function _initializeBalance(address _address, uint256 _supply) private {

        require(_address != address(0), "Address cannot be equal to 0x0!");

        require(_supply != 0, "Supply cannot be equal to 0!");

        balances[_address] = tokenToDecimals(_supply);

        emit Transfer(address(0), _address, _supply);

    }



    function tokenToDecimals(uint256 _amount) private view returns (uint256){

        // NOTE for additional accuracy, we're using 6 decimal places in supply

        return _amount * (10 ** 12);

    }



    function getRemainingSaleTokens() external view returns (uint256) {

        return balanceOf(crowdsaleAddress);

    }



}