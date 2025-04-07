pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/ECRecovery.sol



/**

 * @title Eliptic curve signature operations

 *

 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d

 *

 * TODO Remove this library once solidity supports passing a signature to ecrecover.

 * See https://github.com/ethereum/solidity/issues/864

 *

 */







// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;





  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() onlyOwner whenNotPaused public {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() onlyOwner whenPaused public {

    paused = false;

    emit Unpause();

  }

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts/Airdrop.sol



contract KMHTokenInterface {

  function checkRole(address addr, string roleName) public view;



  function mint(address _to, uint256 _amount) public returns (bool);

}



contract NameRegistryInterface {

  function registerName(address addr, string name) public;

  function finalizeName(address addr, string name) public;

}



// Pausable is Ownable

contract Airdrop is Pausable {

  using SafeMath for uint;

  using ECRecovery for bytes32;



  event Distribution(address indexed to, uint256 amount);



  mapping(bytes32 => address) public users;

  mapping(bytes32 => uint) public unclaimedRewards;



  address public signer;



  KMHTokenInterface public token;

  NameRegistryInterface public nameRegistry;



  constructor(address _token, address _nameRegistry, address _signer) public {

    require(_token != address(0));

    require(_nameRegistry != address(0));

    require(_signer != address(0));



    token = KMHTokenInterface(_token);

    nameRegistry = NameRegistryInterface(_nameRegistry);

    signer = _signer;

  }



  function setSigner(address newSigner) public onlyOwner {

    require(newSigner != address(0));



    signer = newSigner;

  }



  function claim(

    address receiver,

    bytes32 id,

    string username,

    bool verified,

    uint256 amount,

    bytes32 inviterId,

    uint256 inviteReward,

    bytes sig

  ) public whenNotPaused {

    require(users[id] == address(0));



    bytes32 proveHash = getProveHash(receiver, id, username, verified, amount, inviterId, inviteReward);

    address proveSigner = getMsgSigner(proveHash, sig);

    require(proveSigner == signer);



    users[id] = receiver;



    uint256 unclaimedReward = unclaimedRewards[id];

    if (unclaimedReward > 0) {

      unclaimedRewards[id] = 0;

      _distribute(receiver, unclaimedReward.add(amount));

    } else {

      _distribute(receiver, amount);

    }



    if (verified) {

      nameRegistry.finalizeName(receiver, username);

    } else {

      nameRegistry.registerName(receiver, username);

    }



    if (inviterId == 0) {

      return;

    }



    if (users[inviterId] == address(0)) {

      unclaimedRewards[inviterId] = unclaimedRewards[inviterId].add(inviteReward);

    } else {

      _distribute(users[inviterId], inviteReward);

    }

  }



  function getAccountState(bytes32 id) public view returns (address addr, uint256 unclaimedReward) {

    addr = users[id];

    unclaimedReward = unclaimedRewards[id];

  }



  function getProveHash(

    address receiver, bytes32 id, string username, bool verified, uint256 amount, bytes32 inviterId, uint256 inviteReward

  ) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(receiver, id, username, verified, amount, inviterId, inviteReward));

  }



  function getMsgSigner(bytes32 proveHash, bytes sig) public pure returns (address) {

    return proveHash.recover(sig);

  }



  function _distribute(address to, uint256 amount) internal {

    token.mint(to, amount);

    emit Distribution(to, amount);

  }

}