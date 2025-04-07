/**

 *Submitted for verification at Etherscan.io on 2019-01-28

*/



pragma solidity ^0.4.24;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */













/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Elliptic curve signature operations

 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d

 * TODO Remove this library once solidity supports passing a signature to ecrecover.

 * See https://github.com/ethereum/solidity/issues/864

 */











contract Redeemer is Ownable {

  using SafeMath for uint256;

  using QueryDB for address;



  // Need this struct because of stack too deep error

  struct Code {

    address user;

    uint256 value;

    uint256 unlockTimestamp;

    uint256 entropy;

    bytes signature;

    bool deactivated;

    uint256 velocity;

  }



  address public DB;

  address[] public SIGNERS;



  mapping(bytes32 => Code) public codes;



  event AddSigner(address indexed owner, address signer);

  event RemoveSigner(address indexed owner, address signer);

  event RevokeAllToken(address indexed owner, address recipient, uint256 value);

  event SupportUser(address indexed owner, address indexed user, uint256 value, uint256 unlockTimestamp, uint256 entropy, bytes signature, uint256 velocity);

  event DeactivateCode(address indexed owner, address indexed user, uint256 value, uint256 unlockTimestamp, uint256 entropy, bytes signature);

  event Redeem(address indexed user, uint256 value, uint256 unlockTimestamp, uint256 entropy, bytes signature, uint256 velocity);



  /**

   * Constructor

   */

  constructor (address _db) public {

    DB = _db;

    SIGNERS = [msg.sender];

  }





  /**

   * Modifiers

   */

  modifier isValidCode(Code _code) {

    bytes32 _hash = hash(_code);

    require(!codes[_hash].deactivated, "Deactivated code.");

    require(now >= _code.unlockTimestamp, "Lock time is not over.");

    require(validateSignature(_hash, _code.signature), "Invalid signer.");

    _;

  }



  modifier isValidCodeOwner(address _codeOwner) {

    require(_codeOwner != address(0), "Invalid sender.");

    require(msg.sender == _codeOwner, "Invalid sender.");

    _;

  }



  modifier isValidBalance(uint256 _value) {

    require(_value <= myBalance(), "Not enough balance.");

    _;

  }



  modifier isValidAddress(address _who) {

    require(_who != address(0), "Invalid address.");

    _;

  }





  /**

   * Private functions

   */

  

  // Hash function

  function hash(Code _code) private pure returns (bytes32) {

    return keccak256(abi.encode(_code.user, _code.value, _code.unlockTimestamp, _code.entropy));

  }



  // Check signature

  function validateSignature(bytes32 _hash, bytes _signature) private view returns (bool) {

    address _signer = ECDSA.recover(_hash, _signature);

    return signerExists(_signer);

  }



  // Transfer KAT

  function transferKAT(address _to, uint256 _value) private returns (bool) {

    bool ok = TokenInterface(DB.getAddress("TOKEN")).transfer(_to, _value);

    if(!ok) return false;

    return true;    

  }





  /**

   * Management functions

   */



  // Balance of KAT

  function myBalance() public view returns (uint256) {

     return TokenInterface(DB.getAddress("TOKEN")).balanceOf(address(this));

  }

  

  // Check address whether is in signer list

  function signerExists(address _signer) public view returns (bool) {

    if(_signer == address(0)) return false;

    for(uint256 i = 0; i < SIGNERS.length; i++) {

      if(_signer == SIGNERS[i]) return true;

    }

    return false;

  }



  // Add a signer

  function addSigner(address _signer) public onlyOwner isValidAddress(_signer) returns (bool) {

    if(signerExists(_signer)) return true;

    SIGNERS.push(_signer);

    emit AddSigner(msg.sender, _signer);

    return true;

  }



  // Remove a signer

  function removeSigner(address _signer) public onlyOwner isValidAddress(_signer) returns (bool) {

    for(uint256 i = 0; i < SIGNERS.length; i++) {

      if(_signer == SIGNERS[i]) {

        SIGNERS[i] = SIGNERS[SIGNERS.length - 1];

        delete SIGNERS[SIGNERS.length - 1];

        emit RemoveSigner(msg.sender, _signer);

        return true;

      }

    }

    return true;

  }



  // Revoke all KAT in case

  function revokeAllToken(address _recipient) public onlyOwner returns (bool) {

    uint256 _value = myBalance();

    emit RevokeAllToken(msg.sender, _recipient, _value);

    return transferKAT(_recipient, _value);

  }



  // Kambria manually supports user in case they don't controll

  function supportUser(

    address _user,

    uint256 _value,

    uint256 _unlockTimestamp,

    uint256 _entropy,

    bytes _signature

  )

    public

    onlyOwner

    isValidCode(Code(_user, _value, _unlockTimestamp, _entropy, _signature, false, 0))

    returns (bool)

  {

    uint256 _velocity = now - _unlockTimestamp;

    Code memory _code = Code(_user, _value, _unlockTimestamp, _entropy, _signature, true, _velocity);

    bytes32 _hash = hash(_code);

    codes[_hash] = _code;

    emit SupportUser(msg.sender, _code.user, _code.value, _code.unlockTimestamp, _code.entropy, _code.signature, _code.velocity);

    return transferKAT(_code.user, _code.value);

  }



  // Kambria manually deactivate code

  function deactivateCode(

    address _user,

    uint256 _value,

    uint256 _unlockTimestamp,

    uint256 _entropy,

    bytes _signature

  ) 

    public

    onlyOwner

    returns (bool)

  {

    Code memory _code = Code(_user, _value, _unlockTimestamp, _entropy, _signature, true, 0);

    bytes32 _hash = hash(_code);

    codes[_hash] = _code;

    emit DeactivateCode(msg.sender, _code.user, _code.value, _code.unlockTimestamp, _code.entropy, _code.signature);

    return true;

  }



  /**

   * User functions

   */

  

  // Redeem

  function redeem(

    address _user,

    uint256 _value,

    uint256 _unlockTimestamp,

    uint256 _entropy,

    bytes _signature

  )

    public

    isValidBalance(_value)

    isValidCodeOwner(_user)

    isValidCode(Code(_user, _value, _unlockTimestamp, _entropy, _signature, false, 0))

    returns (bool)

  {

    uint256 _velocity = now - _unlockTimestamp;

    Code memory _code = Code(_user, _value, _unlockTimestamp, _entropy, _signature, true, _velocity);

    bytes32 _hash = hash(_code);

    codes[_hash] = _code;

    emit Redeem(_code.user, _code.value, _code.unlockTimestamp, _code.entropy, _code.signature, _code.velocity);

    return transferKAT(_code.user, _code.value);

  }

}