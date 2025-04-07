pragma solidity ^0.4.15;

/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) constant returns (uint256);

  function transfer(address to, uint256 value) returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}

/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





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

  function transferOwnership(address newOwner) onlyOwner {

    pendingOwner = newOwner;

  }

  /**

   * @dev Allows the pendingOwner address to finalize the transfer.

   */

  function claimOwnership() onlyPendingOwner {

    owner = pendingOwner;

    pendingOwner = 0x0;

  }

}

contract Operational is Claimable {

    address public operator;

    function Operational(address _operator) {

      operator = _operator;

    }

    modifier onlyOperator() {

      require(msg.sender == operator);

      _;

    }

    function transferOperator(address newOperator) onlyOwner {

      require(newOperator != address(0));

      operator = newOperator;

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

  /**

  * @dev transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) returns (bool) {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);



    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    Transfer(msg.sender, _to, _value);

    return true;

  }

  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of. 

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) constant returns (uint256 balance) {

    return balances[_owner];

  }

}

/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) returns (bool);

  function approve(address spender, uint256 value) returns (bool);

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

  mapping (address => mapping (address => uint256)) allowed;

  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amout of tokens to be transfered

   */

  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {

    require(_to != address(0));

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    Transfer(_from, _to, _value);

    return true;

  }

  /**

   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.

   * @param _spender The address which will spend the funds.

   * @param _value The amount of tokens to be spent.

   */

  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`

    //  allowance to zero by calling `approve(_spender, 0)` if it is not

    //  already 0 to mitigate the race condition described here:

    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;

    Approval(msg.sender, _spender, _value);

    return true;

  }

  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param _owner address The address which owns the funds.

   * @param _spender address The address which will spend the funds.

   * @return A uint256 specifing the amount of tokens still available for the spender.

   */

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

    return allowed[_owner][_spender];

  }

}

/**

 * @title Helps contracts guard agains rentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>

 * @notice If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {

  /**

   * @dev We use a single lock for the whole contract.

   */

  bool private rentrancy_lock = false;

  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * @notice If you mark a function `nonReentrant`, you should also

   * mark it `external`. Calling one nonReentrant function from

   * another is not supported. Instead, you can implement a

   * `private` function doing the actual work, and a `external`

   * wrapper marked as `nonReentrant`.

   */

  modifier nonReentrant() {

    require(!rentrancy_lock);

    rentrancy_lock = true;

    _;

    rentrancy_lock = false;

  }

}

/**

 * @title Burnable Token

 * @dev Token that can be irreversibly burned (destroyed).

 */

contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**

     * @dev Burns a specific amount of tokens.

     * @param _value The amount of token to be burned.

     */

    function burn(uint256 _value) public returns (bool) {

        require(_value > 0);

        require(_value <= balances[msg.sender]);

        // no need to require value <= totalSupply, since that would imply the

        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;

        balances[burner] = balances[burner].sub(_value);

        totalSupply = totalSupply.sub(_value);

        Burn(burner, _value);

        return true;

    }

}

contract FrozenableToken is Operational, BurnableToken, ReentrancyGuard {

            using DateTime for uint256;

    uint256 public createTime;

    uint256 public frozenForever;

    uint256 public frozenAnnually;



    struct FrozenRecord {

        uint256 value;

        uint256 day;

    }

    mapping (uint256 => FrozenRecord) public frozenBalances;



    event FreezeForOwner(address indexed owner, uint256 value, uint256 unFrozenTime);

    event Unfreeze(address indexed owner, uint256 value);

    // freeze _value token to _unFrozenTime



    function freezeForOwner(uint256 _value, uint256 _unFrozenTime) onlyOperator returns(bool) {

        require(balances[owner] >= _value);

        require(_unFrozenTime > createTime);

        require(_unFrozenTime > now);  

        balances[owner] = balances[owner].sub(_value);

        if (_unFrozenTime.parseTimestamp().year - createTime.parseTimestamp().year > 10 ){

                frozenForever = frozenForever.add(_value);

        } else {

                uint256 day = _unFrozenTime.toDay();

                frozenAnnually = frozenAnnually.add(_value);

                frozenBalances[day] = FrozenRecord({value: _value, day:day});

        }



        FreezeForOwner(owner, _value, _unFrozenTime);

        return true;

    }



    // unfreeze frozen amount

    function unfreeze(uint256 _unFrozenTime) onlyOperator returns (bool) {

        require(_unFrozenTime < block.timestamp);

        uint256 day = _unFrozenTime.toDay();

        uint256 _value = frozenBalances[day].value;

        if (_value>0) {

                frozenBalances[day].value = 0;

                frozenAnnually = frozenAnnually.sub(_value);

                balances[owner] = balances[owner].add(_value);

                Unfreeze(owner, _value);

        }

        return true;

    }



}

contract DragonReleaseableToken is FrozenableToken {

    using SafeMath for uint;

    using DateTime for uint256;

    uint256 standardDecimals = 100000000; // match decimals

    uint256 public award = standardDecimals.mul(51200); // award per day

    event ReleaseSupply(address indexed receiver, uint256 value, uint256 releaseTime);

    struct ReleaseRecord {

        uint256 amount; // release amount

        uint256 releasedDay;

    }

    mapping (uint256 => ReleaseRecord) public releasedRecords;

    function DragonReleaseableToken(

                    address operator

                ) Operational(operator) {

        createTime = 1509580800;

    }

    function releaseSupply(uint256 timestamp) onlyOperator returns(uint256 _actualRelease) {

        require(timestamp >= createTime && timestamp <= now);

        require(!judgeReleaseRecordExist(timestamp));

        updateAward(timestamp);

        balances[owner] = balances[owner].add(award);

        totalSupply = totalSupply.add(award);

        uint256 releasedDay = timestamp.toDay();

        releasedRecords[releasedDay] = ReleaseRecord(award, releasedDay);

        ReleaseSupply(owner, award, timestamp);

        return award;

    }

    function judgeReleaseRecordExist(uint256 timestamp) internal returns(bool _exist) {

        bool exist = false;

        uint256 day = timestamp.parseTimestamp().year * 10000 + timestamp.parseTimestamp().month * 100 + timestamp.parseTimestamp().day;

        if (releasedRecords[day].releasedDay == day){

            exist = true;

        }

        return exist;

    }

    function updateAward(uint256 timestamp) internal {

        if (timestamp < createTime.add(1 years)) {

            award = standardDecimals.mul(51200);

        } else if (timestamp < createTime.add(2 years)) {

            award = standardDecimals.mul(25600);

        } else if (timestamp < createTime.add(3 years)) {

            award = standardDecimals.mul(12800);

        } else if (timestamp < createTime.add(4 years)) {

            award = standardDecimals.mul(6400);

        } else if (timestamp < createTime.add(5 years)) {

            award = standardDecimals.mul(3200);

        } else if (timestamp < createTime.add(6 years)) {

            award = standardDecimals.mul(1600);

        } else if (timestamp < createTime.add(7 years)) {

            award = standardDecimals.mul(800);

        } else if (timestamp < createTime.add(8 years)) {

            award = standardDecimals.mul(400);

        } else if (timestamp < createTime.add(9 years)) {

            award = standardDecimals.mul(200);

        } else if (timestamp < createTime.add(10 years)) {

            award = standardDecimals.mul(100);

        } else {

            award = 0;

        }

    }

}

contract DragonToken is DragonReleaseableToken {

    string public standard = '2017111504';

    string public name = 'DragonToken';

    string public symbol = 'DT';

    uint8 public decimals = 8;

    function DragonToken(

                     address operator

                     ) DragonReleaseableToken(operator) {}

}