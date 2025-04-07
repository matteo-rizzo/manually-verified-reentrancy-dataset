/**

 *Submitted for verification at Etherscan.io on 2019-01-07

*/



pragma solidity ^0.4.24;

// produced by the Solididy File Flattener (c) David Appleton 2018

// contact : [emailÂ protected]

// released under Apache 2.0 licence













contract RBAC {

  using Roles for Roles.Role;



  mapping (string => Roles.Role) private roles;



  event RoleAdded(address addr, string roleName);

  event RoleRemoved(address addr, string roleName);



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

  function addRole(address addr, string roleName)

    internal

  {

    roles[roleName].add(addr);

    emit RoleAdded(addr, roleName);

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

    emit RoleRemoved(addr, roleName);

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

   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)

   * @param roleNames the names of the roles to scope access to

   * // reverts

   *

   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this

   *  see: https://github.com/ethereum/solidity/issues/2467

   */

  // modifier onlyRoles(string[] roleNames) {

  //     bool hasAnyRole = false;

  //     for (uint8 i = 0; i < roleNames.length; i++) {

  //         if (hasRole(msg.sender, roleNames[i])) {

  //             hasAnyRole = true;

  //             break;

  //         }

  //     }



  //     require(hasAnyRole);



  //     _;

  // }

}



contract Whitelist is Ownable, RBAC {

  event WhitelistedAddressAdded(address addr);

  event WhitelistedAddressRemoved(address addr);



  string public constant ROLE_WHITELISTED = "whitelist";



  /**

   * @dev Throws if called by any account that's not whitelisted.

   */

  modifier onlyWhitelisted() {

    checkRole(msg.sender, ROLE_WHITELISTED);

    _;

  }



  /**

   * @dev add an address to the whitelist

   * @param addr address

   * @return true if the address was added to the whitelist, false if the address was already in the whitelist

   */

  function addAddressToWhitelist(address addr)

    onlyOwner

    public

  {

    addRole(addr, ROLE_WHITELISTED);

    emit WhitelistedAddressAdded(addr);

  }



  /**

   * @dev getter to determine if address is in whitelist

   */

  function whitelist(address addr)

    public

    view

    returns (bool)

  {

    return hasRole(addr, ROLE_WHITELISTED);

  }



  /**

   * @dev add addresses to the whitelist

   * @param addrs addresses

   * @return true if at least one address was added to the whitelist,

   * false if all addresses were already in the whitelist

   */

  function addAddressesToWhitelist(address[] addrs)

    onlyOwner

    public

  {

    for (uint256 i = 0; i < addrs.length; i++) {

      addAddressToWhitelist(addrs[i]);

    }

  }



  /**

   * @dev remove an address from the whitelist

   * @param addr address

   * @return true if the address was removed from the whitelist,

   * false if the address wasn't in the whitelist in the first place

   */

  function removeAddressFromWhitelist(address addr)

    onlyOwner

    public

  {

    removeRole(addr, ROLE_WHITELISTED);

    emit WhitelistedAddressRemoved(addr);

  }



  /**

   * @dev remove addresses from the whitelist

   * @param addrs addresses

   * @return true if at least one address was removed from the whitelist,

   * false if all addresses weren't in the whitelist in the first place

   */

  function removeAddressesFromWhitelist(address[] addrs)

    onlyOwner

    public

  {

    for (uint256 i = 0; i < addrs.length; i++) {

      removeAddressFromWhitelist(addrs[i]);

    }

  }



}



contract StartersProxy is Whitelist{

    using SafeMath for uint256;



    uint256 public TX_PER_SIGNER_LIMIT = 5;          //limit of metatx per signer

    uint256 public META_BET = 1 finney;              //wei, equal to 0.001 ETH

    uint256 public DEBT_INCREASING_FACTOR = 3;       //increasing factor (times) applied on the bet



    struct Record {

        uint256 nonce;

        uint256 debt;

    }

    mapping(address => Record) signersBacklog;

    event Received (address indexed sender, uint value);

    event Forwarded (address signer, address destination, uint value, bytes data);



    function() public payable {

        emit Received(msg.sender, msg.value);

    }



    constructor(address[] _senders) public {

        addAddressToWhitelist(msg.sender);

        addAddressesToWhitelist(_senders);

    }



    function forwardPlay(address signer, address destination, bytes data, bytes32 hash, bytes signature) onlyWhitelisted public {

        require(signersBacklog[signer].nonce < TX_PER_SIGNER_LIMIT, "Signer has reached the tx limit");



        signersBacklog[signer].nonce++;

        //we increase the personal debt here

        //it grows much (much) faster than the actual bet to compensate sender's and proxy's expenses

        uint256 debtIncrease = META_BET.mul(DEBT_INCREASING_FACTOR);

        signersBacklog[signer].debt = signersBacklog[signer].debt.add(debtIncrease);



        forward(signer, destination, META_BET, data, hash, signature);

    }



    function forwardWin(address signer, address destination, bytes data, bytes32 hash, bytes signature) onlyWhitelisted public {

        require(signersBacklog[signer].nonce > 0, 'Hm, no meta plays for this signer');



        forward(signer, destination, 0, data, hash, signature);

    }



    function forward(address signer, address destination,  uint256 value, bytes data, bytes32 hash, bytes signature) internal {

        require(recoverSigner(hash, signature) == signer);



        //execute the transaction with all the given parameters

        require(executeCall(destination, value, data));

        emit Forwarded(signer, destination, value, data);

    }



    //borrowed from OpenZeppelin's ESDA stuff:

    //https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/cryptography/ECDSA.sol

    function recoverSigner(bytes32 _hash, bytes _signature) onlyWhitelisted public view returns (address){

        bytes32 r;

        bytes32 s;

        uint8 v;

        // Check the signature length

        require (_signature.length == 65);

        // Divide the signature in r, s and v variables

        // ecrecover takes the signature parameters, and the only way to get them

        // currently is to use assembly.

        assembly {

            r := mload(add(_signature, 32))

            s := mload(add(_signature, 64))

            v := byte(0, mload(add(_signature, 96)))

        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions

        if (v < 27) {

            v += 27;

        }

        // If the version is correct return the signer address

        require(v == 27 || v == 28);

        return ecrecover(keccak256(

                abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)

            ), v, r, s);

    }



    // this originally was copied from GnosisSafe

    // https://github.com/gnosis/gnosis-safe-contracts/blob/master/contracts/GnosisSafe.sol

    function executeCall(address to, uint256 value, bytes data) internal returns (bool success) {

        assembly {

            success := call(gas, to, value, add(data, 0x20), mload(data), 0, 0)

        }

    }



    function payDebt(address signer) public payable{

        require(signersBacklog[signer].nonce > 0, "Provided address has no debt");

        require(signersBacklog[signer].debt >= msg.value, "Address's debt is less than payed amount");



        signersBacklog[signer].debt = signersBacklog[signer].debt.sub(msg.value);

    }



    function debt(address signer) public view returns (uint256) {

        return signersBacklog[signer].debt;

    }



    function gamesLeft(address signer) public view returns (uint256) {

        return TX_PER_SIGNER_LIMIT.sub(signersBacklog[signer].nonce);

    }



    function withdraw(uint256 amountWei) onlyWhitelisted public {

        msg.sender.transfer(amountWei);

    }



    function setMetaBet(uint256 _newMetaBet) onlyWhitelisted public {

        META_BET = _newMetaBet;

    }



    function setTxLimit(uint256 _newTxLimit) onlyWhitelisted public {

        TX_PER_SIGNER_LIMIT = _newTxLimit;

    }



    function setDebtIncreasingFactor(uint256 _newFactor) onlyWhitelisted public {

        DEBT_INCREASING_FACTOR = _newFactor;

    }





}