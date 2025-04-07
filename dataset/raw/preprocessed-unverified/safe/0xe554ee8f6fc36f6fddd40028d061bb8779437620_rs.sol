/**

 *Submitted for verification at Etherscan.io on 2018-12-03

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



  uint256 private constant TIER_DELETED = 999;

  string public constant ROLE_MINTER = "minter";

  string public constant ROLE_OPERATOR = "operator";



  uint256 public tierLimit;



  modifier onlyMinter () {

    checkRole(msg.sender, ROLE_MINTER);

    _;

  }



  modifier onlyOperator () {

    checkRole(msg.sender, ROLE_OPERATOR);

    _;

  }



  uint256 public totalSoldTokens;

  mapping(address => uint256) public tokenBalances;

  mapping(address => uint256) public ethContributions;

  mapping(address => uint256) private _whitelistTier;

  address[] public tokenAddresses;

  address[] public ethAddresses;

  address[] private whitelistAddresses;



  constructor(uint256 _tierLimit) public {

    addRole(owner, ROLE_OPERATOR);

    tierLimit = _tierLimit;

  }



  function addMinter(address minter) external onlyOwner {

    addRole(minter, ROLE_MINTER);

  }



  function removeMinter(address minter) external onlyOwner {

    removeRole(minter, ROLE_MINTER);

  }



  function addOperator(address _operator) external onlyOwner {

    addRole(_operator, ROLE_OPERATOR);

  }



  function removeOperator(address _operator) external onlyOwner {

    removeRole(_operator, ROLE_OPERATOR);

  }



  function addTokenBalance(

    address _address,

    uint256 _tokenAmount

  )

    external

    onlyMinter

  {

    if (tokenBalances[_address] == 0) {

      tokenAddresses.push(_address);

    }

    tokenBalances[_address] = tokenBalances[_address].add(_tokenAmount);

    totalSoldTokens = totalSoldTokens.add(_tokenAmount);

  }



  function addEthContribution(

    address _address,

    uint256 _weiAmount

  )

    external

    onlyMinter

  {

    if (ethContributions[_address] == 0) {

      ethAddresses.push(_address);

    }

    ethContributions[_address] = ethContributions[_address].add(_weiAmount);

  }



  function setTierLimit(uint256 _newTierLimit) external onlyOperator {

    require(_newTierLimit > 0, "Tier must be greater than zero");



    tierLimit = _newTierLimit;

  }



  function addToWhitelist(

    address _investor,

    uint256 _tier

  )

    external

    onlyOperator

  {

    require(_tier == 1 || _tier == 2, "Only two tier level available");

    if (_whitelistTier[_investor] == 0) {

      whitelistAddresses.push(_investor);

    }

    _whitelistTier[_investor] = _tier;

  }



  function removeFromWhitelist(address _investor) external onlyOperator {

    _whitelistTier[_investor] = TIER_DELETED;

  }



  function whitelistTier(address _investor) external view returns (uint256) {

    return _whitelistTier[_investor] <= 2 ? _whitelistTier[_investor] : 0;

  }



  function getWhitelistedAddresses(

    uint256 _tier

  )

    external

    view

    returns (address[])

  {

    address[] memory tmp = new address[](whitelistAddresses.length);



    uint y = 0;

    if (_tier == 1 || _tier == 2) {

      uint len = whitelistAddresses.length;

      for (uint i = 0; i < len; i++) {

        if (_whitelistTier[whitelistAddresses[i]] == _tier) {

          tmp[y] = whitelistAddresses[i];

          y++;

        }

      }

    }



    address[] memory toReturn = new address[](y);



    for (uint k = 0; k < y; k++) {

      toReturn[k] = tmp[k];

    }



    return toReturn;

  }



  function isAllowedPurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    external

    view

    returns (bool)

  {

    if (_whitelistTier[_beneficiary] == 2) {

      return true;

    } else if (_whitelistTier[_beneficiary] == 1 && ethContributions[_beneficiary].add(_weiAmount) <= tierLimit) {

      return true;

    }



    return false;

  }



  function getTokenAddressesLength() external view returns (uint) {

    return tokenAddresses.length;

  }



  function getEthAddressesLength() external view returns (uint) {

    return ethAddresses.length;

  }

}