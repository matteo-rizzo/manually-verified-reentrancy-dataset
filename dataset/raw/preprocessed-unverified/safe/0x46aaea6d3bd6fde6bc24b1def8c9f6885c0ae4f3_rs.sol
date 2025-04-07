/**

 *Submitted for verification at Etherscan.io on 2018-10-19

*/



pragma solidity ^0.4.24;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */









/**

 * @title Roles

 * @author Francisco Giordano (@frangio)

 * @dev Library for managing addresses assigned to a Role.

 * See RBAC.sol for example usage.

 */









/**

 * @title RBAC (Role-Based Access Control)

 * @author Matt Condon (@Shrugs)

 * @dev Stores and provides setters and getters for roles and addresses.

 * Supports unlimited numbers of roles and addresses.

 * See //contracts/mocks/RBACMock.sol for an example of usage.

 * This RBAC method uses strings to key roles. It may be beneficial

 * for you to write your own implementation of this interface using Enums or similar.

 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,

 * to avoid typos.

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

    view

    public

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

    view

    public

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





/**

 * @title Whitelist

 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.

 * This simplifies the implementation of "user permissions".

 */

contract Whitelist is Ownable, RBAC {

  string public constant ROLE_WHITELISTED = "whitelist";



  /**

   * @dev Throws if operator is not whitelisted.

   * @param _operator address

   */

  modifier onlyIfWhitelisted(address _operator) {

    checkRole(_operator, ROLE_WHITELISTED);

    _;

  }



  /**

   * @dev add an address to the whitelist

   * @param _operator address

   * @return true if the address was added to the whitelist, false if the address was already in the whitelist

   */

  function addAddressToWhitelist(address _operator)

    onlyOwner

    public

  {

    addRole(_operator, ROLE_WHITELISTED);

  }



  /**

   * @dev getter to determine if address is in whitelist

   */

  function whitelist(address _operator)

    public

    view

    returns (bool)

  {

    return hasRole(_operator, ROLE_WHITELISTED);

  }



  /**

   * @dev add addresses to the whitelist

   * @param _operators addresses

   * @return true if at least one address was added to the whitelist,

   * false if all addresses were already in the whitelist

   */

  function addAddressesToWhitelist(address[] _operators)

    onlyOwner

    public

  {

    for (uint256 i = 0; i < _operators.length; i++) {

      addAddressToWhitelist(_operators[i]);

    }

  }



  /**

   * @dev remove an address from the whitelist

   * @param _operator address

   * @return true if the address was removed from the whitelist,

   * false if the address wasn't in the whitelist in the first place

   */

  function removeAddressFromWhitelist(address _operator)

    onlyOwner

    public

  {

    removeRole(_operator, ROLE_WHITELISTED);

  }



  /**

   * @dev remove addresses from the whitelist

   * @param _operators addresses

   * @return true if at least one address was removed from the whitelist,

   * false if all addresses weren't in the whitelist in the first place

   */

  function removeAddressesFromWhitelist(address[] _operators)

    onlyOwner

    public

  {

    for (uint256 i = 0; i < _operators.length; i++) {

      removeAddressFromWhitelist(_operators[i]);

    }

  }



}





/******************************************/

/*       ADVANCED TOKEN STARTS HERE       */

/******************************************/



contract HKHcoin is Whitelist {

    // Public variables of the token

    string public name;

    string public symbol;

    uint8 public decimals = 18;



    // This creates an array with all balances

    mapping (address => uint256) public balanceOf;



    // This generates a public event on the blockchain that will notify clients

    event Mint(address indexed to, uint256 value);



    // This notifies clients about the amount burnt

    event Burn(address indexed from, uint256 value);



    /* Initializes contract with initial supply tokens to the creator of the contract */

    constructor (

        string tokenName,

        string tokenSymbol

    ) public {

        name = tokenName;     // Set the name for display purposes

        symbol = tokenSymbol; // Set the symbol for display purposes

    }



    /// @notice Create `mintedAmount` tokens and send it to `target`

    /// @param target Address to receive the tokens

    /// @param mintedAmount the amount of tokens it will receive

    function mintToken(address target, uint256 mintedAmount) 

        onlyIfWhitelisted(msg.sender) 

        public

    {

        balanceOf[target] += mintedAmount;

        emit Mint(target, mintedAmount);

    }



    /**

     * Destroy tokens from other account

     *

     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.

     *

     * @param _from the address of the sender

     * @param _value the amount of money to burn

     */

    function burnFrom(address _from, uint256 _value) 

        onlyIfWhitelisted(msg.sender) 

        public 

        returns (bool success)

    {

        require(balanceOf[_from] >= _value); // Check if the targeted balance is enough

        balanceOf[_from] -= _value;          // Subtract from the targeted balance

        emit Burn(_from, _value);

        return true;

    }

}