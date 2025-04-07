/**

 *Submitted for verification at Etherscan.io on 2018-10-15

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



/**

 * @title Contributions

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Utility contract where to save any information about Crowdsale contributions

 */

contract Contributions is RBAC, Ownable {



  using SafeMath for uint256;



  string public constant ROLE_OPERATOR = "operator";



  modifier onlyOperator () {

    checkRole(msg.sender, ROLE_OPERATOR);

    _;

  }



  uint256 public totalSoldTokens;

  uint256 public totalWeiRaised;

  mapping(address => uint256) public tokenBalances;

  mapping(address => uint256) public weiContributions;

  address[] public addresses;



  constructor() public {}



  /**

   * @dev add contribution into the contributions array

   * @param _address address

   * @param _weiAmount uint256

   * @param _tokenAmount uint256

   */

  function addBalance(

    address _address,

    uint256 _weiAmount,

    uint256 _tokenAmount

  )

  public

  onlyOperator

  {

    if (weiContributions[_address] == 0) {

      addresses.push(_address);

    }

    weiContributions[_address] = weiContributions[_address].add(_weiAmount);

    totalWeiRaised = totalWeiRaised.add(_weiAmount);



    tokenBalances[_address] = tokenBalances[_address].add(_tokenAmount);

    totalSoldTokens = totalSoldTokens.add(_tokenAmount);

  }



  /**

   * @dev add a operator role to an address

   * @param _operator address

   */

  function addOperator(address _operator) public onlyOwner {

    addRole(_operator, ROLE_OPERATOR);

  }



  /**

   * @dev remove a operator role from an address

   * @param _operator address

   */

  function removeOperator(address _operator) public onlyOwner {

    removeRole(_operator, ROLE_OPERATOR);

  }



  /**

   * @dev return the contributions length

   * @return uint256

   */

  function getContributorsLength() public view returns (uint) {

    return addresses.length;

  }

}