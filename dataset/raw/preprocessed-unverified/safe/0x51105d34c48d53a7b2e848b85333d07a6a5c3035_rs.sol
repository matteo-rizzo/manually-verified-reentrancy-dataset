pragma solidity ^0.4.24;





/**

 * @title SafeMath

 * @dev Interface for ERC223

 */







/**

 * @title ERC223ReceivingContract

 * @dev Contract for ERC223 fallback

 */

contract ERC223ReceivingContract {

    function tokenFallback(address _from, uint _value, bytes _data) public;

}





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract C3Coin is ERC223, Ownable {

    using SafeMath for uint;

    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 public totalSupply;

    

    constructor() public {

        name = "C3 Coin";

        symbol = "CCC";

        decimals = 18;

        totalSupply = 100000000000000000000000000000;

        balances[msg.sender] = totalSupply;

    } 

    

    mapping (address => uint256) internal balances;

    

    address public icoContract;





    /**

    * @dev Getters

    */ 

    // Function to access name of token .

    function name() external constant returns (string _name) {

      return name;

    }

    // Function to access symbol of token .

    function symbol() external constant returns (string _symbol) {

        return symbol;

    }

    // Function to access decimals of token .

    function decimals() external constant returns (uint8 _decimals) {

        return decimals;

    }

    // Function to access total supply of tokens .

    function totalSupply() external constant returns (uint256 _totalSupply) {

        return totalSupply;

    }



    





   /**

   * @notice This function is modified for erc223 standard

   * @dev ERC20 transfer function added for backward compatibility.

   * @param _to Address of token receiver

   * @param _value Number of tokens to send

   */

   function transfer(address _to, uint256 _value) external returns (bool) {

     require(_to != address(0));

     require(_value <= balances[msg.sender] && balances[_to] + _value >= balances[_to]);

     require(!isContract(_to));

     balances[msg.sender] = balances[msg.sender].sub(_value);

     balances[_to] = balances[_to].add(_value);

     emit Transfer(msg.sender, _to, _value);

     return true;

   }

   

   

  /**

   * @dev Get balance of a token owner

   * @param _owner address The address which one owns tokens

   */

  function balanceOf(address _owner) external constant returns (uint256 balance) {

    return balances[_owner];

   }

  

  /**

   * @notice Instead of sending byte string for the transaction data, string type is used for more detailed description.

   * @dev ERC223 transfer function 

   * @param _to Address of token receiver

   * @param _value Number of tokens to send

   * @param _data information for the transaction

   */ 

  function transfer(address _to, uint _value, bytes _data) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[msg.sender] && balances[_to] + _value >= balances[_to]);

    if(isContract(_to)) {

        ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);

        receiver.tokenFallback(msg.sender, _value, _data);

    }

        

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit ERC223Transfer(msg.sender, _to, _value, _data);

    return true;

    }

  

  /**

   * @dev Check if the given address is non-user

   * @param _addr address to check

   */   

  function isContract(address _addr) private returns (bool is_contract) {

      uint length;

      assembly {

            //retrieve the size of the code on target address, this needs assembly

            length := extcodesize(_addr)

      }

      return (length>0);

  }

  

  

  /**

   * @dev Set ICO contract address to supply tokens

   * @param _icoContract address of an ICO smart contract

   */   

  function setIcoContract(address _icoContract) public onlyOwner {

    if (_icoContract != address(0)) {

      icoContract = _icoContract;

    }

  }

  

  /**

   * @dev Supply tokens to ICO contract

   * @param _value uint256 amount of tokens to sell

   */

  function sell(uint256 _value) public onlyOwner returns (bool) {

    require(icoContract != address(0));

    require(_value <= balances[msg.sender] && balances[icoContract] + _value >= balances[icoContract]); 

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[icoContract] = balances[icoContract].add(_value);

    emit Sell(msg.sender, _value);

    return true;

  }

  

  /**

   * @dev default payable function executed after receiving ether

   */ 

  function () public payable {

        // contract does not accept ether

        revert();

  }

}