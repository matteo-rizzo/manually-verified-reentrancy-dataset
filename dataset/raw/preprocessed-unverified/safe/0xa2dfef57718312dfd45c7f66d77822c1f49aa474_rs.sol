/**

 *Submitted for verification at Etherscan.io on 2018-09-24

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: openzeppelin-solidity/contracts/access/rbac/Roles.sol



/**

 * @title Roles

 * @author Francisco Giordano (@frangio)

 * @dev Library for managing addresses assigned to a Role.

 * See RBAC.sol for example usage.

 */





// File: openzeppelin-solidity/contracts/access/rbac/RBAC.sol



/**

 * @title RBAC (Role-Based Access Control)

 * @author Matt Condon (@Shrugs)

 * @dev Stores and provides setters and getters for roles and addresses.

 * Supports unlimited numbers of roles and addresses.

 * See //contracts/mocks/RBACMock.sol for an example of usage.

 * This RBAC method uses strings to key roles. It may be beneficial

 * for you to write your own implementation of this interface using Enums or similar.

 */

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



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/crowdsale/utils/Contributions.sol



contract Contributions is RBAC, Ownable {

  using SafeMath for uint256;



  string public constant ROLE_MINTER = "minter";



  modifier onlyMinter () {

    checkRole(msg.sender, ROLE_MINTER);

    _;

  }



  mapping(address => uint256) public tokenBalances;

  mapping(address => uint256) public ethContributions;

  address[] public addresses;



  constructor() public {}



  function addBalance(

    address _address,

    uint256 _weiAmount,

    uint256 _tokenAmount

  )

  public

  onlyMinter

  {

    if (ethContributions[_address] == 0) {

      addresses.push(_address);

    }

    ethContributions[_address] = ethContributions[_address].add(_weiAmount);

    tokenBalances[_address] = tokenBalances[_address].add(_tokenAmount);

  }



  /**

   * @dev add a minter role to an address

   * @param _minter address

   */

  function addMinter(address _minter) public onlyOwner {

    addRole(_minter, ROLE_MINTER);

  }



  /**

   * @dev add a minter role to an array of addresses

   * @param _minters address[]

   */

  function addMinters(address[] _minters) public onlyOwner {

    require(_minters.length > 0);

    for (uint i = 0; i < _minters.length; i++) {

      addRole(_minters[i], ROLE_MINTER);

    }

  }



  /**

   * @dev remove a minter role from an address

   * @param _minter address

   */

  function removeMinter(address _minter) public onlyOwner {

    removeRole(_minter, ROLE_MINTER);

  }



  function getContributorsLength() public view returns (uint) {

    return addresses.length;

  }

}