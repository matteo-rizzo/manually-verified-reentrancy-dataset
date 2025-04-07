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

 * @title Burnable Token

 * @dev Token that can be irreversibly burned (destroyed).

 */

contract BurnableToken is BasicToken {



  event Burn(address indexed burner, uint256 value);



  /**

   * @dev Burns a specific amount of tokens.

   * @param _value The amount of token to be burned.

   */

  function burn(uint256 _value) public returns (bool) {

    _burn(msg.sender, _value);

    return true;

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









contract Operational is Claimable {

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





contract YunMint is Operational, ReentrancyGuard, BurnableToken, StandardToken {

    using SafeMath for uint;

    using SafeMath for uint256;

    using DateTime for uint256;





    event Release(address operator, uint256 value, uint256 releaseTime);

    event Burn(address indexed burner, uint256 value);

    event Freeze(address indexed owner, uint256 value, uint256 releaseTime);

    event Unfreeze(address indexed owner, uint256 value, uint256 releaseTime);



    struct FrozenBalance {address owner; uint256 value; uint256 unFrozenTime;}

    mapping (uint => FrozenBalance) public frozenBalances;

    uint public frozenBalanceCount = 0;



    //init 303000000

    uint256 constant valueTotal = 303000000 * (10 ** 8);

    /* uint256 public totalSupply = 0; */





    uint256 public releasedSupply;

    uint    public releasedCount = 0;

    uint    public cycleCount = 0;

    uint256 public firstReleaseAmount;

    uint256 public curReleaseAmount;



    uint256 public createTime = 0;

    uint256 public lastReleaseTime = 0;



    modifier validAddress(address _address) {

        assert(0x0 != _address);

        _;

    }



    function YunMint(address _operator) public validAddress(_operator) Operational(_operator) {

        createTime = block.timestamp;

        totalSupply_ = valueTotal;

        firstReleaseAmount = 200000 * (10 ** 8);

    }



    function batchTransfer(address[] _to, uint256[] _amount) public returns(bool success) {

        for(uint i = 0; i < _to.length; i++){

            require(transfer(_to[i], _amount[i]));

        }

        return true;

    }



    function release(uint256 timestamp) public onlyOperator returns(bool) {

        require(timestamp <= block.timestamp);

        if(lastReleaseTime > 0){

            require(timestamp > lastReleaseTime);

        }

        require(!hasItBeenReleased(timestamp));



        cycleCount = releasedCount.div(30);

        require(cycleCount < 100);

        require(releasedSupply < valueTotal);



        curReleaseAmount = firstReleaseAmount - (cycleCount * 2000 * (10 ** 8));

        balances[owner] = balances[owner].add(curReleaseAmount);

        releasedSupply = releasedSupply.add(curReleaseAmount);





        lastReleaseTime = timestamp;

        releasedCount = releasedCount + 1;

        emit Release(msg.sender, curReleaseAmount, lastReleaseTime);

        emit Transfer(address(0), owner, curReleaseAmount);

        return true;

    }





    function hasItBeenReleased(uint256 timestamp) internal view returns(bool _exist) {

        bool exist = false;

        if ((lastReleaseTime.parseTimestamp().year == timestamp.parseTimestamp().year)

            && (lastReleaseTime.parseTimestamp().month == timestamp.parseTimestamp().month)

            && (lastReleaseTime.parseTimestamp().day == timestamp.parseTimestamp().day)) {

            exist = true;

        }

        return exist;

    }







    function freeze(uint256 _value, uint256 _unFrozenTime) nonReentrant public returns (bool) {

        require(balances[msg.sender] >= _value);

        require(_unFrozenTime > createTime);

        require(_unFrozenTime > block.timestamp);



        balances[msg.sender] = balances[msg.sender].sub(_value);

        frozenBalances[frozenBalanceCount] = FrozenBalance({owner: msg.sender, value: _value, unFrozenTime: _unFrozenTime});

        frozenBalanceCount++;

        emit Freeze(msg.sender, _value, _unFrozenTime);

        return true;

    }





    function frozenBalanceOf(address _owner) constant public returns (uint256 value) {

        for (uint i = 0; i < frozenBalanceCount; i++) {

            FrozenBalance storage frozenBalance = frozenBalances[i];

            if (_owner == frozenBalance.owner) {

                value = value.add(frozenBalance.value);

            }

        }

        return value;

    }





    function unfreeze() public returns (uint256 releaseAmount) {

        uint index = 0;

        while (index < frozenBalanceCount) {

            if (now >= frozenBalances[index].unFrozenTime) {

                releaseAmount += frozenBalances[index].value;

                unFrozenBalanceByIndex(index);

            } else {

                index++;

            }

        }

        return releaseAmount;

    }



    function unFrozenBalanceByIndex(uint index) internal {

        FrozenBalance storage frozenBalance = frozenBalances[index];

        balances[frozenBalance.owner] = balances[frozenBalance.owner].add(frozenBalance.value);

        emit Unfreeze(frozenBalance.owner, frozenBalance.value, frozenBalance.unFrozenTime);

        frozenBalances[index] = frozenBalances[frozenBalanceCount - 1];

        delete frozenBalances[frozenBalanceCount - 1];

        frozenBalanceCount--;

    }

}





contract YunToken is YunMint {

    string public standard = '2018062301';

    string public name = 'YunToken';

    string public symbol = 'YUN';

    uint8 public decimals = 8;

    function YunToken(address _operator) YunMint(_operator) public {}

}