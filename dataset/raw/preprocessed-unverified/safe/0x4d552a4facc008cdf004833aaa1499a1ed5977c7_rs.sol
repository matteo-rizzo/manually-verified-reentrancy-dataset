pragma solidity 0.4.20;



/**

 * @title  PriceOracle

 * @author Kirill Varlamov (@ongrid)

 * @dev    Oracle for keeping actual ETH price (USD cents per 1 ETH).

 */

 

 

/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Roles

 * @author Francisco Giordano (@frangio)

 * @dev Library for managing addresses assigned to a Role.

 *      See RBAC.sol for example usage.

 */







/**

 * @title RBAC (Role-Based Access Control)

 * @author Matt Condon (@Shrugs)

 * @dev Stores and provides setters and getters for roles and addresses.

 *      Supports unlimited numbers of roles and addresses.

 *      See //contracts/mocks/RBACMock.sol for an example of usage.

 * This RBAC method uses strings to key roles. It may be beneficial

 *  for you to write your own implementation of this interface using Enums or similar.

 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,

 *  to avoid typos.

 */

contract RBAC {

  using Roles for Roles.Role;



  mapping (string => Roles.Role) private roles;



  event RoleAdded(address addr, string roleName);

  event RoleRemoved(address addr, string roleName);



  /**

   * A constant role name for indicating admins.

   */

  string public constant ROLE_ADMIN = "admin";



  /**

   * @dev constructor. Sets msg.sender as admin by default

   */

  function RBAC()

    public

  {

    addRole(msg.sender, ROLE_ADMIN);

  }



  /**

   * @dev reverts if addr does not have role

   * @param addr address

   * @param roleName the name of the role

   * // reverts

   */

  function checkRole(address addr, string roleName)

    view

    public

  {

    roles[roleName].check(addr);

  }



  /**

   * @dev determine if addr has role

   * @param addr address

   * @param roleName the name of the role

   * @return bool

   */

  function hasRole(address addr, string roleName)

    view

    public

    returns (bool)

  {

    return roles[roleName].has(addr);

  }



  /**

   * @dev add a role to an address

   * @param addr address

   * @param roleName the name of the role

   */

  function adminAddRole(address addr, string roleName)

    onlyAdmin

    public

  {

    addRole(addr, roleName);

  }



  /**

   * @dev remove a role from an address

   * @param addr address

   * @param roleName the name of the role

   */

  function adminRemoveRole(address addr, string roleName)

    onlyAdmin

    public

  {

    removeRole(addr, roleName);

  }



  /**

   * @dev add a role to an address

   * @param addr address

   * @param roleName the name of the role

   */

  function addRole(address addr, string roleName)

    internal

  {

    roles[roleName].add(addr);

    RoleAdded(addr, roleName);

  }



  /**

   * @dev remove a role from an address

   * @param addr address

   * @param roleName the name of the role

   */

  function removeRole(address addr, string roleName)

    internal

  {

    roles[roleName].remove(addr);

    RoleRemoved(addr, roleName);

  }



  /**

   * @dev modifier to scope access to a single role (uses msg.sender as addr)

   * @param roleName the name of the role

   * // reverts

   */

  modifier onlyRole(string roleName)

  {

    checkRole(msg.sender, roleName);

    _;

  }



  /**

   * @dev modifier to scope access to admins

   * // reverts

   */

  modifier onlyAdmin()

  {

    checkRole(msg.sender, ROLE_ADMIN);

    _;

  }

}





/**

 * @title  PriceOracle

 * @dev    Contract for actual ETH price injection into Ethereum ledger.

 *         Contract gets periodically updated by external script polling major exchanges for actual ETH/SDH price.

 * @author Kirill Varlamov, OnGrid systems

 */

contract PriceOracle is RBAC {

    using SafeMath for uint256;

    string constant ROLE_BOT = "bot";

    // current ETHereum price in USD cents.

    uint256 public priceUSDcETH;

    event PriceUpdate(uint256 price);



    /**

     * @param _initialPrice Starting ETHereum price in USD cents.

     */

    function PriceOracle(uint256 _initialPrice) RBAC() public {

        priceUSDcETH = _initialPrice;

        addRole(msg.sender, ROLE_BOT);

    }



    /**

     * @dev Updates in-contract price upon external bot request.

     *      New price is checked for validity (the single-request change is limited to 10%)

     * @param _priceUSDcETH Requested ETHereum price in USD cents.

     */

    function setPrice(uint256 _priceUSDcETH) public onlyRole(ROLE_BOT) {

        // don't allow to change price more than 10%

        // to avoid typos

        assert(_priceUSDcETH < priceUSDcETH.mul(110).div(100));

        assert(_priceUSDcETH > priceUSDcETH.mul(90).div(100));

        priceUSDcETH = _priceUSDcETH;

        PriceUpdate(priceUSDcETH);

    }

}