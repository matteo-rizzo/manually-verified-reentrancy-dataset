pragma solidity ^0.4.21;





/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}













/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */















contract Operational is Ownable {

    address public operator;



    function Operational(address _operator) public {

      operator = _operator;

    }



    modifier onlyOperator() {

      require(msg.sender == operator);

      _;

    }



    function transferOperator(address newOperator) public onlyOwner {

      require(newOperator != address(0));

      operator = newOperator;

    }



}



















/**

 * @title Claimable

 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.

 * This allows the new owner to accept the transfer.

 */

contract Claimable is Ownable {

  address public pendingOwner;



  /**

   * @dev Modifier throws if called by any account other than the pendingOwner.

   */

  modifier onlyPendingOwner() {

    require(msg.sender == pendingOwner);

    _;

  }



  /**

   * @dev Allows the current owner to set the pendingOwner address.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) onlyOwner public {

    pendingOwner = newOwner;

  }



  /**

   * @dev Allows the pendingOwner address to finalize the transfer.

   */

  function claimOwnership() onlyPendingOwner public {

    emit OwnershipTransferred(owner, pendingOwner);

    owner = pendingOwner;

    pendingOwner = address(0);

  }

}









/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */



























/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  uint256 totalSupply_;



  /**

  * @dev total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);



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













/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}







/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * @dev https://github.com/ethereum/EIPs/issues/20

 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) internal allowed;





  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }



  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   *

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

  function allowance(address _owner, address _spender) public view returns (uint256) {

    return allowed[_owner][_spender];

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   *

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   *

   * approve should be called when allowed[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}









/**

 * @title Helps contracts guard agains reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>

 * @notice If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /**

   * @dev We use a single lock for the whole contract.

   */

  bool private reentrancyLock = false;



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * @notice If you mark a function `nonReentrant`, you should also

   * mark it `external`. Calling one nonReentrant function from

   * another is not supported. Instead, you can implement a

   * `private` function doing the actual work, and a `external`

   * wrapper marked as `nonReentrant`.

   */

  modifier nonReentrant() {

    require(!reentrancyLock);

    reentrancyLock = true;

    _;

    reentrancyLock = false;

  }



}













/**

 * @title Burnable Token

 * @dev Token that can be irreversibly burned (destroyed).

 */

contract BurnableToken is BasicToken {



  event Burn(address indexed burner, uint256 value);



  /**

   * @dev Burns a specific amount of tokens.

   * @param _value The amount of token to be burned.

   */

  function burn(uint256 _value) public {

    _burn(msg.sender, _value);

  }



  function _burn(address _who, uint256 _value) internal {

    require(_value <= balances[_who]);

    // no need to require value <= totalSupply, since that would imply the

    // sender's balance is greater than the totalSupply, which *should* be an assertion failure



    balances[_who] = balances[_who].sub(_value);

    totalSupply_ = totalSupply_.sub(_value);

    emit Burn(_who, _value);

    emit Transfer(_who, address(0), _value);

  }

}











contract BonusToken is BurnableToken, Operational, StandardToken {

    using SafeMath for uint;

    using DateTime for uint256;



    uint256 public createTime;

    uint256 standardDecimals = 100000000;

    uint256 minMakeBonusAmount = standardDecimals.mul(10);



    function BonusToken() public Operational(msg.sender) {}



    function makeBonus(address[] _to, uint256[] _bonus) public returns(bool) {

        for(uint i = 0; i < _to.length; i++){

            require(transfer(_to[i], _bonus[i]));

        }

        return true;

    }



}





contract KuaiMintableToken is BonusToken {





    uint256 public standardDailyLimit; // maximum amount of token can mint per day

    uint256 public dailyLimitLeft = standardDecimals.mul(1000000); // daily limit left

    uint256 public lastMintTime = 0;



    event Mint(address indexed operator, uint256 value, uint256 mintTime);

    event SetDailyLimit(address indexed operator, uint256 time);



    function KuaiMintableToken(

                    address _owner,

                    uint256 _dailyLimit

                ) public BonusToken() {

        totalSupply_ = 0;

        createTime = block.timestamp;

        lastMintTime = createTime;

        owner = _owner;

        standardDailyLimit = standardDecimals.mul(_dailyLimit);

        dailyLimitLeft = standardDailyLimit;

    }



    // mint mintAmount token

    function mint(uint256 mintAmount) public onlyOperator returns(uint256 _actualRelease) {

        uint256 timestamp = block.timestamp;

        require(!judgeIsReachDailyLimit(mintAmount, timestamp));

        balances[owner] = balances[owner].add(mintAmount);

        totalSupply_ = totalSupply_.add(mintAmount);

        emit Mint(msg.sender, mintAmount, timestamp);

        emit Transfer(address(0), owner, mintAmount);

        return mintAmount;

    }



    function judgeIsReachDailyLimit(uint256 mintAmount, uint256 timestamp) internal returns(bool _exist) {

        bool reached = false;

        if ((timestamp.parseTimestamp().year == lastMintTime.parseTimestamp().year)

            && (timestamp.parseTimestamp().month == lastMintTime.parseTimestamp().month)

            && (timestamp.parseTimestamp().day == lastMintTime.parseTimestamp().day)) {

            if (dailyLimitLeft < mintAmount) {

                reached = true;

            } else {

                dailyLimitLeft = dailyLimitLeft.sub(mintAmount);

                lastMintTime = timestamp;

            }

        } else {

            dailyLimitLeft = standardDailyLimit;

            lastMintTime = timestamp;

            if (dailyLimitLeft < mintAmount) {

                reached = true;

            } else {

                dailyLimitLeft = dailyLimitLeft.sub(mintAmount);

            }

        }

        return reached;

    }





    // set standard daily limit

    function setDailyLimit(uint256 _dailyLimit) public onlyOwner returns(bool){

        standardDailyLimit = _dailyLimit;

        emit SetDailyLimit(msg.sender, block.timestamp);

        return true;

    }

}





contract KuaiToken is KuaiMintableToken {

    string public standard = '20180609';

    string public name = 'KuaiToken';

    string public symbol = 'KT';

    uint8 public decimals = 8;



    function KuaiToken(

                    address _owner,

                    uint256 dailyLimit

                     ) public KuaiMintableToken(_owner, dailyLimit) {}



}