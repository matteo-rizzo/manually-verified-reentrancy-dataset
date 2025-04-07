/**

 *Submitted for verification at Etherscan.io on 2018-10-17

*/



pragma  solidity ^0.4.24;



















contract Locklisted  {



  Locklist.List private _list;

  

  modifier onlyLocklisted() {

    require(Locklist.check(_list, msg.sender) == true);

    _;

  }



  event AddressAdded(address _addr);

  event AddressRemoved(address _addr);

  

  function LocklistedAddress()

  public

  {

    Locklist.add(_list, msg.sender);

  }



  function LocklistAddressenable(address _addr)

    public

  {

    Locklist.add(_list, _addr);

    emit AddressAdded(_addr);

  }



  function LocklistAddressdisable(address _addr)

    public

  {

    Locklist.remove(_list, _addr);

   emit AddressRemoved(_addr);

  }

  

  function LocklistAddressisListed(address _addr)

  public

  view

  returns (bool)

  {

      return Locklist.check(_list, _addr);

  }

}



contract VTEXP is Ownable,Locklisted {

 

  event Mint(address indexed to, uint256 amount);

  event MintFinished();



  event Transfer(address indexed from, address indexed to, uint256 value);

  using SafeMath for uint256;

  string public constant name = "VTEX Promo Token";

  string public constant symbol = "VTEXP";

  uint8 public constant decimals = 5;  // 18 is the most common number of decimal places

  bool public mintingFinished = false;

  uint256 public totalSupply;

  mapping(address => uint256) balances;



  modifier canMint() {

    require(!mintingFinished);

    _;

  }

 

  /**

  * @dev Function to mint tokens

  * @param _to The address that will receive the minted tokens.

  * @param _amount The amount of tokens to mint.

  * @return A boolean that indicates if the operation was successful.

  */

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

    require(!LocklistAddressisListed(_to));

    totalSupply = totalSupply.add(_amount);

    require(totalSupply <= 10000000000000);

    balances[_to] = balances[_to].add(_amount);

    emit  Mint(_to, _amount);

    emit Transfer(address(0), _to, _amount);



    return true;

  }



  /**

  * @dev Function to stop minting new tokens.

  * @return True if the operation was successful.

  */

  function finishMinting() onlyOwner canMint public returns (bool) {

    mintingFinished = true;

    emit MintFinished();

    return true;

  }

 

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= totalSupply);

    require(!LocklistAddressisListed(_to));

      balances[_to] = balances[_to].add(_value);

      totalSupply = totalSupply.sub(_value);

      balances[msg.sender] = balances[msg.sender].sub(_value);

      emit Transfer(msg.sender, _to, _value);

      return true;

  }

 

 

  function transferFrom(address _from, address _to, uint256 _value) onlyOwner public returns (bool) {

    require(!LocklistAddressisListed(_to));

    require(_to != address(0));

    require(_value <= balances[_from]);

    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }

 

 

 





  function balanceOf(address _owner) public constant returns (uint256 balance) {

    return balances[_owner];

  }



  function balanceEth(address _owner) public constant returns (uint256 balance) {

    return _owner.balance;

  }

    



}