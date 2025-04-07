/**

 *Submitted for verification at Etherscan.io on 2018-09-20

*/



pragma solidity ^0.4.24;



contract RBAC {

  using Roles for Roles.Role;



  mapping (string => Roles.Role) private roles;



  event RoleAdded(address indexed operator, string role);

  event RoleRemoved(address indexed operator, string role);



  /**

   * @dev reverts if addr does not have role

   * @param _operator address

   * @param _role the name of the role

   * // reverts

   */

  function checkRole(address _operator, string _role)

    public

    view

  {

    roles[_role].check(_operator);

  }



  /**

   * @dev determine if addr has role

   * @param _operator address

   * @param _role the name of the role

   * @return bool

   */

  function hasRole(address _operator, string _role)

    public

    view

    returns (bool)

  {

    return roles[_role].has(_operator);

  }



  /**

   * @dev add a role to an address

   * @param _operator address

   * @param _role the name of the role

   */

  function addRole(address _operator, string _role)

    internal

  {

    roles[_role].add(_operator);

    emit RoleAdded(_operator, _role);

  }



  /**

   * @dev remove a role from an address

   * @param _operator address

   * @param _role the name of the role

   */

  function removeRole(address _operator, string _role)

    internal

  {

    roles[_role].remove(_operator);

    emit RoleRemoved(_operator, _role);

  }



  /**

   * @dev modifier to scope access to a single role (uses msg.sender as addr)

   * @param _role the name of the role

   * // reverts

   */

  modifier onlyRole(string _role)

  {

    checkRole(msg.sender, _role);

    _;

  }



  /**

   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)

   * @param _roles the names of the roles to scope access to

   * // reverts

   *

   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this

   *  see: https://github.com/ethereum/solidity/issues/2467

   */

  // modifier onlyRoles(string[] _roles) {

  //     bool hasAnyRole = false;

  //     for (uint8 i = 0; i < _roles.length; i++) {

  //         if (hasRole(msg.sender, _roles[i])) {

  //             hasAnyRole = true;

  //             break;

  //         }

  //     }



  //     require(hasAnyRole);



  //     _;

  // }

}















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

  function transferOwnership(address newOwner) public onlyOwner {

    pendingOwner = newOwner;

  }



  /**

   * @dev Allows the pendingOwner address to finalize the transfer.

   */

  function claimOwnership() public onlyPendingOwner {

    emit OwnershipTransferred(owner, pendingOwner);

    owner = pendingOwner;

    pendingOwner = address(0);

  }

}



contract SimpleFlyDropToken is Claimable {

    using SafeMath for uint256;



    ERC20 internal erc20tk;



    function setToken(address _token) onlyOwner public {

        require(_token != address(0));

        erc20tk = ERC20(_token);

    }



    /**

     * @dev Send tokens to other multi addresses in one function

     *

     * @param _destAddrs address The addresses which you want to send tokens to

     * @param _values uint256 the amounts of tokens to be sent

     */

    function multiSend(address[] _destAddrs, uint256[] _values) onlyOwner public returns (uint256) {

        require(_destAddrs.length == _values.length);



        uint256 i = 0;

        for (; i < _destAddrs.length; i = i.add(1)) {

            if (!erc20tk.transfer(_destAddrs[i], _values[i])) {

                break;

            }

        }



        return (i);

    }

}



contract DelayedClaimable is Claimable {



  uint256 public end;

  uint256 public start;



  /**

   * @dev Used to specify the time period during which a pending

   * owner can claim ownership.

   * @param _start The earliest time ownership can be claimed.

   * @param _end The latest time ownership can be claimed.

   */

  function setLimits(uint256 _start, uint256 _end) public onlyOwner {

    require(_start <= _end);

    end = _end;

    start = _start;

  }



  /**

   * @dev Allows the pendingOwner address to finalize the transfer, as long as it is called within

   * the specified start and end time.

   */

  function claimOwnership() public onlyPendingOwner {

    require((block.number <= end) && (block.number >= start));

    emit OwnershipTransferred(owner, pendingOwner);

    owner = pendingOwner;

    pendingOwner = address(0);

    end = 0;

  }



}



contract Poweruser is DelayedClaimable, RBAC {

  string public constant ROLE_POWERUSER = "poweruser";



  constructor () public {

    addRole(msg.sender, ROLE_POWERUSER);

  }



  /**

   * @dev Throws if called by any account that's not a superuser.

   */

  modifier onlyPoweruser() {

    checkRole(msg.sender, ROLE_POWERUSER);

    _;

  }



  modifier onlyOwnerOrPoweruser() {

    require(msg.sender == owner || isPoweruser(msg.sender));

    _;

  }



  /**

   * @dev getter to determine if address has poweruser role

   */

  function isPoweruser(address _addr)

    public

    view

    returns (bool)

  {

    return hasRole(_addr, ROLE_POWERUSER);

  }



  /**

   * @dev Add a new account address as power user.

   * @param _newPoweruser The address to be as a power user.

   */

  function addPoweruser(address _newPoweruser) public onlyOwner {

    require(_newPoweruser != address(0));

    addRole(_newPoweruser, ROLE_POWERUSER);

  }



  /**

   * @dev Remove a new account address from power user list.

   * @param _oldPoweruser The address to be as a power user.

   */

  function removePoweruser(address _oldPoweruser) public onlyOwner {

    require(_oldPoweruser != address(0));

    removeRole(_oldPoweruser, ROLE_POWERUSER);

  }

}



contract FlyDropTokenMgr is Poweruser {

    using SafeMath for uint256;



    address[] dropTokenAddrs;

    SimpleFlyDropToken currentDropTokenContract;

    // mapping(address => mapping (address => uint256)) budgets;



    /**

     * @dev Send tokens to other multi addresses in one function

     *

     * @param _rand a random index for choosing a FlyDropToken contract address

     * @param _from address The address which you want to send tokens from

     * @param _value uint256 the amounts of tokens to be sent

     * @param _token address the ERC20 token address

     */

    function prepare(uint256 _rand,

                     address _from,

                     address _token,

                     uint256 _value) onlyOwnerOrPoweruser public returns (bool) {

        require(_token != address(0));

        require(_from != address(0));

        require(_rand > 0);



        if (ERC20(_token).allowance(_from, this) < _value) {

            return false;

        }



        if (_rand > dropTokenAddrs.length) {

            SimpleFlyDropToken dropTokenContract = new SimpleFlyDropToken();

            dropTokenAddrs.push(address(dropTokenContract));

            currentDropTokenContract = dropTokenContract;

        } else {

            currentDropTokenContract = SimpleFlyDropToken(dropTokenAddrs[_rand.sub(1)]);

        }



        currentDropTokenContract.setToken(_token);

        return ERC20(_token).transferFrom(_from, currentDropTokenContract, _value);

        // budgets[_token][_from] = budgets[_token][_from].sub(_value);

        // return itoken(_token).approveAndCall(currentDropTokenContract, _value, _extraData);

        // return true;

    }



    // function setBudget(address _token, address _from, uint256 _value) onlyOwner public {

    //     require(_token != address(0));

    //     require(_from != address(0));



    //     budgets[_token][_from] = _value;

    // }



    /**

     * @dev Send tokens to other multi addresses in one function

     *

     * @param _destAddrs address The addresses which you want to send tokens to

     * @param _values uint256 the amounts of tokens to be sent

     */

    function flyDrop(address[] _destAddrs, uint256[] _values) onlyOwnerOrPoweruser public returns (uint256) {

        require(address(currentDropTokenContract) != address(0));

        return currentDropTokenContract.multiSend(_destAddrs, _values);

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