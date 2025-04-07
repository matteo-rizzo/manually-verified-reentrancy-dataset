/**

 *Submitted for verification at Etherscan.io on 2019-01-28

*/



pragma solidity ^0.4.24;



// File: node_modules/openzeppelin-solidity/contracts/access/Roles.sol



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */





// File: node_modules/openzeppelin-solidity/contracts/access/roles/PauserRole.sol



contract PauserRole {

  using Roles for Roles.Role;



  event PauserAdded(address indexed account);

  event PauserRemoved(address indexed account);



  Roles.Role private pausers;



  constructor() internal {

    _addPauser(msg.sender);

  }



  modifier onlyPauser() {

    require(isPauser(msg.sender));

    _;

  }



  function isPauser(address account) public view returns (bool) {

    return pausers.has(account);

  }



  function addPauser(address account) public onlyPauser {

    _addPauser(account);

  }



  function renouncePauser() public {

    _removePauser(msg.sender);

  }



  function _addPauser(address account) internal {

    pausers.add(account);

    emit PauserAdded(account);

  }



  function _removePauser(address account) internal {

    pausers.remove(account);

    emit PauserRemoved(account);

  }

}



// File: node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is PauserRole {

  event Paused(address account);

  event Unpaused(address account);



  bool private _paused;



  constructor() internal {

    _paused = false;

  }



  /**

   * @return true if the contract is paused, false otherwise.

   */

  function paused() public view returns(bool) {

    return _paused;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!_paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(_paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() public onlyPauser whenNotPaused {

    _paused = true;

    emit Paused(msg.sender);

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyPauser whenPaused {

    _paused = false;

    emit Unpaused(msg.sender);

  }

}



// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/IBounty.sol







// File: contracts/Role/WhitelistAdminRole.sol



/**

 * @title WhitelistAdminRole

 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.

 */

contract WhitelistAdminRole {

  using Roles for Roles.Role;



  event WhitelistAdminAdded(address indexed account);

  event WhitelistAdminRemoved(address indexed account);



  Roles.Role private _whitelistAdmins;



  constructor () internal {

    _addWhitelistAdmin(msg.sender);

  }



  modifier onlyWhitelistAdmin() {

    require(isWhitelistAdmin(msg.sender));

    _;

  }



  function isWhitelistAdmin(address account) public view returns (bool) {

    return _whitelistAdmins.has(account);

  }



  function addWhitelistAdmin(address account) public onlyWhitelistAdmin {

    _addWhitelistAdmin(account);

  }



  function renounceWhitelistAdmin() public {

    _removeWhitelistAdmin(msg.sender);

  }



  function _addWhitelistAdmin(address account) internal {

    _whitelistAdmins.add(account);

    emit WhitelistAdminAdded(account);

  }



  function _removeWhitelistAdmin(address account) internal {

    _whitelistAdmins.remove(account);

    emit WhitelistAdminRemoved(account);

  }

}



// File: contracts/Role/WhitelistedRole.sol



/**

 * @title WhitelistedRole

 * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a

 * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove

 * it), and not Whitelisteds themselves.

 */

contract WhitelistedRole is WhitelistAdminRole {

  using Roles for Roles.Role;



  event WhitelistedAdded(address indexed account);

  event WhitelistedRemoved(address indexed account);



  Roles.Role private _whitelisteds;



  modifier onlyWhitelisted() {

    require(isWhitelisted(msg.sender));

    _;

  }



  function isWhitelisted(address account) public view returns (bool) {

    return _whitelisteds.has(account);

  }



  function addWhitelisted(address account) public onlyWhitelistAdmin {

    _addWhitelisted(account);

  }



  function removeWhitelisted(address account) public onlyWhitelistAdmin {

    _removeWhitelisted(account);

  }



  function renounceWhitelisted() public {

    _removeWhitelisted(msg.sender);

  }



  function _addWhitelisted(address account) internal {

    _whitelisteds.add(account);

    emit WhitelistedAdded(account);

  }



  function _removeWhitelisted(address account) internal {

    _whitelisteds.remove(account);

    emit WhitelistedRemoved(account);

  }

}



// File: contracts/SafeMath.sol



/**

 * @title SafeMath

 */





// File: contracts/Bounty.sol











contract Bounty is WhitelistedRole, IBounty, Pausable {



  using SafeMath for *;



  address public erc20Address;

  address public bountyNFTAddress;



  struct Bounty {

    uint256 needHopsAmount;

    address[] tokenAddress;

    uint256[] tokenAmount;

  }



  bytes32[] public planBaseIds;



  mapping (uint256 => Bounty) bountyIdToBounty;



  constructor (address _erc20Address, address _bountyNFTAddress) {

    erc20Address = _erc20Address;

    bountyNFTAddress = _bountyNFTAddress;

  }



  function packageBounty (

    address owner,

    uint256 needHopsAmount,

    address[] tokenAddress,

    uint256[] tokenAmount

  ) whenNotPaused external returns (bool) {

    require(isWhitelisted(msg.sender)||isWhitelistAdmin(msg.sender));

    Bounty memory bounty = Bounty(needHopsAmount, tokenAddress, tokenAmount);

    (bool success, uint256 bountyId) = IERC721(bountyNFTAddress).mintTo(owner);

    require(success);

    bountyIdToBounty[bountyId] = bounty;

    emit BountyEvt(bountyId, owner, needHopsAmount, tokenAddress, tokenAmount);

  }



  function openBounty(uint256 bountyId)

    whenNotPaused external returns (bool) {

    Bounty storage bounty = bountyIdToBounty[bountyId];

    require(IERC721(bountyNFTAddress).ownerOf(bountyId) == msg.sender);



    require(IERC721(bountyNFTAddress).isApprovedForAll(msg.sender, address(this)));

    require(IERC20(erc20Address).balanceOf(msg.sender) >= bounty.needHopsAmount);

    require(IERC20(erc20Address).allowance(msg.sender, address(this)) >= bounty.needHopsAmount);

    IERC20(erc20Address).burnFrom(msg.sender, bounty.needHopsAmount);



    for (uint8 i = 0; i < bounty.tokenAddress.length; i++) {

      require(IERC20(bounty.tokenAddress[i]).transfer(msg.sender, bounty.tokenAmount[i]));

    }



    IERC721(bountyNFTAddress).burn(bountyId);

    delete bountyIdToBounty[bountyId];



    emit OpenBountyEvt(bountyId, msg.sender, bounty.needHopsAmount, bounty.tokenAddress, bounty.tokenAmount);

  }



  function checkBounty(uint256 bountyId) external view returns (

    address,

    uint256,

    address[],

    uint256[]) {

    Bounty storage bounty = bountyIdToBounty[bountyId];

    address owner = IERC721(bountyNFTAddress).ownerOf(bountyId);

    return (owner, bounty.needHopsAmount, bounty.tokenAddress, bounty.tokenAmount);

  }

}