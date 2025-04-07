/**

 *Submitted for verification at Etherscan.io on 2019-05-03

*/



pragma solidity 0.5.6;



/**

 * @dev Xcert nutable interface.

 */

interface XcertMutable // is Xcert

{

  

  /**

   * @dev Updates Xcert imprint.

   * @param _tokenId Id of the Xcert.

   * @param _imprint New imprint.

   */

  function updateTokenImprint(

    uint256 _tokenId,

    bytes32 _imprint

  )

    external;



}



/**

 * @dev Math operations with safety checks that throw on error. This contract is based on the 

 * source code at: 

 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol.

 */





/**

 * @title Contract for setting abilities.

 * @dev For optimization purposes the abilities are represented as a bitfield. Maximum number of

 * abilities is therefore 256. This is an example(for simplicity is made for max 8 abilities) of how

 * this works. 

 * 00000001 Ability A - number representation 1

 * 00000010 Ability B - number representation 2

 * 00000100 Ability C - number representation 4

 * 00001000 Ability D - number representation 8

 * 00010000 Ability E - number representation 16

 * etc ... 

 * To grant abilities B and C, we would need a bitfield of 00000110 which is represented by number

 * 6, in other words, the sum of abilities B and C. The same concept works for revoking abilities

 * and checking if someone has multiple abilities.

 */

contract Abilitable

{

  using SafeMath for uint;



  /**

   * @dev Error constants.

   */

  string constant NOT_AUTHORIZED = "017001";

  string constant CANNOT_REVOKE_OWN_SUPER_ABILITY = "017002";

  string constant INVALID_INPUT = "017003";



  /**

   * @dev Ability 1 (00000001) is a reserved ability called super ability. It is an

   * ability to grant or revoke abilities of other accounts. Other abilities are determined by the

   * implementing contract.

   */

  uint8 constant SUPER_ABILITY = 1;



  /**

   * @dev Maps address to ability ids.

   */

  mapping(address => uint256) public addressToAbility;



  /**

   * @dev Emits when an address is granted an ability.

   * @param _target Address to which we are granting abilities.

   * @param _abilities Number representing bitfield of abilities we are granting.

   */

  event GrantAbilities(

    address indexed _target,

    uint256 indexed _abilities

  );



  /**

   * @dev Emits when an address gets an ability revoked.

   * @param _target Address of which we are revoking an ability.

   * @param _abilities Number representing bitfield of abilities we are revoking.

   */

  event RevokeAbilities(

    address indexed _target,

    uint256 indexed _abilities

  );



  /**

   * @dev Guarantees that msg.sender has certain abilities.

   */

  modifier hasAbilities(

    uint256 _abilities

  ) 

  {

    require(_abilities > 0, INVALID_INPUT);

    require(

      addressToAbility[msg.sender] & _abilities == _abilities,

      NOT_AUTHORIZED

    );

    _;

  }



  /**

   * @dev Contract constructor.

   * Sets SUPER_ABILITY ability to the sender account.

   */

  constructor()

    public

  {

    addressToAbility[msg.sender] = SUPER_ABILITY;

    emit GrantAbilities(msg.sender, SUPER_ABILITY);

  }



  /**

   * @dev Grants specific abilities to specified address.

   * @param _target Address to grant abilities to.

   * @param _abilities Number representing bitfield of abilities we are granting.

   */

  function grantAbilities(

    address _target,

    uint256 _abilities

  )

    external

    hasAbilities(SUPER_ABILITY)

  {

    addressToAbility[_target] |= _abilities;

    emit GrantAbilities(_target, _abilities);

  }



  /**

   * @dev Unassigns specific abilities from specified address.

   * @param _target Address of which we revoke abilites.

   * @param _abilities Number representing bitfield of abilities we are revoking.

   * @param _allowSuperRevoke Additional check that prevents you from removing your own super

   * ability by mistake.

   */

  function revokeAbilities(

    address _target,

    uint256 _abilities,

    bool _allowSuperRevoke

  )

    external

    hasAbilities(SUPER_ABILITY)

  {

    if (!_allowSuperRevoke && msg.sender == _target)

    {

      require((_abilities & 1) == 0, CANNOT_REVOKE_OWN_SUPER_ABILITY);

    }

    addressToAbility[_target] &= ~_abilities;

    emit RevokeAbilities(_target, _abilities);

  }



  /**

   * @dev Check if an address has a specific ability. Throws if checking for 0.

   * @param _target Address for which we want to check if it has a specific abilities.

   * @param _abilities Number representing bitfield of abilities we are checking.

   */

  function isAble(

    address _target,

    uint256 _abilities

  )

    external

    view

    returns (bool)

  {

    require(_abilities > 0, INVALID_INPUT);

    return (addressToAbility[_target] & _abilities) == _abilities;

  }

  

}



/**

 * @title XcertUpdateProxy - updates a token on behalf of contracts that have been approved via

 * decentralized governance.

 * @notice There is a possibility of unintentional behavior when token imprint can be overwritten

 * if more than one claim is active. Be aware of this when implementing.

 */

contract XcertUpdateProxy is

  Abilitable

{



  /**

   * @dev List of abilities:

   * 2 - Ability to execute create.

   */

  uint8 constant ABILITY_TO_EXECUTE = 2;



  /**

   * @dev Updates imprint of an existing Xcert.

   * @param _xcert Address of the Xcert contract on which the update will be perfomed.

   * @param _id The Xcert we will update.

   * @param _imprint Cryptographic asset imprint.

   */

  function update(

    address _xcert,

    uint256 _id,

    bytes32 _imprint

  )

    external

    hasAbilities(ABILITY_TO_EXECUTE)

  {

    XcertMutable(_xcert).updateTokenImprint(_id, _imprint);

  }



}