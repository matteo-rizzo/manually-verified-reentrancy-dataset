/**

 *Submitted for verification at Etherscan.io on 2018-12-14

*/



pragma solidity ^0.4.25;



// File: openzeppelin-solidity/contracts/access/Roles.sol



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */





// File: openzeppelin-solidity/contracts/access/roles/SignerRole.sol



contract SignerRole {

  using Roles for Roles.Role;



  event SignerAdded(address indexed account);

  event SignerRemoved(address indexed account);



  Roles.Role private signers;



  constructor() internal {

    _addSigner(msg.sender);

  }



  modifier onlySigner() {

    require(isSigner(msg.sender));

    _;

  }



  function isSigner(address account) public view returns (bool) {

    return signers.has(account);

  }



  function addSigner(address account) public onlySigner {

    _addSigner(account);

  }



  function renounceSigner() public {

    _removeSigner(msg.sender);

  }



  function _addSigner(address account) internal {

    signers.add(account);

    emit SignerAdded(account);

  }



  function _removeSigner(address account) internal {

    signers.remove(account);

    emit SignerRemoved(account);

  }

}



// File: openzeppelin-solidity/contracts/cryptography/ECDSA.sol



/**

 * @title Elliptic curve signature operations

 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d

 * TODO Remove this library once solidity supports passing a signature to ecrecover.

 * See https://github.com/ethereum/solidity/issues/864

 */







// File: openzeppelin-solidity/contracts/drafts/SignatureBouncer.sol



/**

 * @title SignatureBouncer

 * @author PhABC, Shrugs and aflesher

 * @dev SignatureBouncer allows users to submit a signature as a permission to

 * do an action.

 * If the signature is from one of the authorized signer addresses, the

 * signature is valid.

 * Note that SignatureBouncer offers no protection against replay attacks, users

 * must add this themselves!

 *

 * Signer addresses can be individual servers signing grants or different

 * users within a decentralized club that have permission to invite other

 * members. This technique is useful for whitelists and airdrops; instead of

 * putting all valid addresses on-chain, simply sign a grant of the form

 * keccak256(abi.encodePacked(`:contractAddress` + `:granteeAddress`)) using a

 * valid signer address.

 * Then restrict access to your crowdsale/whitelist/airdrop using the

 * `onlyValidSignature` modifier (or implement your own using _isValidSignature).

 * In addition to `onlyValidSignature`, `onlyValidSignatureAndMethod` and

 * `onlyValidSignatureAndData` can be used to restrict access to only a given

 * method or a given method with given parameters respectively.

 * See the tests in SignatureBouncer.test.js for specific usage examples.

 *

 * @notice A method that uses the `onlyValidSignatureAndData` modifier must make

 * the _signature parameter the "last" parameter. You cannot sign a message that

 * has its own signature in it so the last 128 bytes of msg.data (which

 * represents the length of the _signature data and the _signaature data itself)

 * is ignored when validating. Also non fixed sized parameters make constructing

 * the data in the signature much more complex.

 * See https://ethereum.stackexchange.com/a/50616 for more details.

 */

contract SignatureBouncer is SignerRole {

  using ECDSA for bytes32;



  // Function selectors are 4 bytes long, as documented in

  // https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector

  uint256 private constant _METHOD_ID_SIZE = 4;

  // Signature size is 65 bytes (tightly packed v + r + s), but gets padded to 96 bytes

  uint256 private constant _SIGNATURE_SIZE = 96;



  constructor() internal {}



  /**

   * @dev requires that a valid signature of a signer was provided

   */

  modifier onlyValidSignature(bytes signature)

  {

    require(_isValidSignature(msg.sender, signature));

    _;

  }



  /**

   * @dev requires that a valid signature with a specifed method of a signer was provided

   */

  modifier onlyValidSignatureAndMethod(bytes signature)

  {

    require(_isValidSignatureAndMethod(msg.sender, signature));

    _;

  }



  /**

   * @dev requires that a valid signature with a specifed method and params of a signer was provided

   */

  modifier onlyValidSignatureAndData(bytes signature)

  {

    require(_isValidSignatureAndData(msg.sender, signature));

    _;

  }



  /**

   * @dev is the signature of `this + sender` from a signer?

   * @return bool

   */

  function _isValidSignature(address account, bytes signature)

    internal

    view

    returns (bool)

  {

    return _isValidDataHash(

      keccak256(abi.encodePacked(address(this), account)),

      signature

    );

  }



  /**

   * @dev is the signature of `this + sender + methodId` from a signer?

   * @return bool

   */

  function _isValidSignatureAndMethod(address account, bytes signature)

    internal

    view

    returns (bool)

  {

    bytes memory data = new bytes(_METHOD_ID_SIZE);

    for (uint i = 0; i < data.length; i++) {

      data[i] = msg.data[i];

    }

    return _isValidDataHash(

      keccak256(abi.encodePacked(address(this), account, data)),

      signature

    );

  }



  /**

    * @dev is the signature of `this + sender + methodId + params(s)` from a signer?

    * @notice the signature parameter of the method being validated must be the "last" parameter

    * @return bool

    */

  function _isValidSignatureAndData(address account, bytes signature)

    internal

    view

    returns (bool)

  {

    require(msg.data.length > _SIGNATURE_SIZE);

    bytes memory data = new bytes(msg.data.length - _SIGNATURE_SIZE);

    for (uint i = 0; i < data.length; i++) {

      data[i] = msg.data[i];

    }

    return _isValidDataHash(

      keccak256(abi.encodePacked(address(this), account, data)),

      signature

    );

  }



  /**

   * @dev internal function to convert a hash to an eth signed message

   * and then recover the signature and check it against the signer role

   * @return bool

   */

  function _isValidDataHash(bytes32 hash, bytes signature)

    internal

    view

    returns (bool)

  {

    address signer = hash

      .toEthSignedMessageHash()

      .recover(signature);



    return signer != address(0) && isSigner(signer);

  }

}



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract ERC20 is IERC20 {

  using SafeMath for uint256;



  mapping (address => uint256) private _balances;



  mapping (address => mapping (address => uint256)) private _allowed;



  uint256 private _totalSupply;



  /**

  * @dev Total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return _totalSupply;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param owner The address to query the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address owner) public view returns (uint256) {

    return _balances[owner];

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param owner address The address which owns the funds.

   * @param spender address The address which will spend the funds.

   * @return A uint256 specifying the amount of tokens still available for the spender.

   */

  function allowance(

    address owner,

    address spender

   )

    public

    view

    returns (uint256)

  {

    return _allowed[owner][spender];

  }



  /**

  * @dev Transfer token for a specified address

  * @param to The address to transfer to.

  * @param value The amount to be transferred.

  */

  function transfer(address to, uint256 value) public returns (bool) {

    _transfer(msg.sender, to, value);

    return true;

  }



  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   * Beware that changing an allowance with this method brings the risk that someone may use both the old

   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param spender The address which will spend the funds.

   * @param value The amount of tokens to be spent.

   */

  function approve(address spender, uint256 value) public returns (bool) {

    require(spender != address(0));



    _allowed[msg.sender][spender] = value;

    emit Approval(msg.sender, spender, value);

    return true;

  }



  /**

   * @dev Transfer tokens from one address to another

   * @param from address The address which you want to send tokens from

   * @param to address The address which you want to transfer to

   * @param value uint256 the amount of tokens to be transferred

   */

  function transferFrom(

    address from,

    address to,

    uint256 value

  )

    public

    returns (bool)

  {

    require(value <= _allowed[from][msg.sender]);



    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    _transfer(from, to, value);

    return true;

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed_[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param spender The address which will spend the funds.

   * @param addedValue The amount of tokens to increase the allowance by.

   */

  function increaseAllowance(

    address spender,

    uint256 addedValue

  )

    public

    returns (bool)

  {

    require(spender != address(0));



    _allowed[msg.sender][spender] = (

      _allowed[msg.sender][spender].add(addedValue));

    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed_[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param spender The address which will spend the funds.

   * @param subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseAllowance(

    address spender,

    uint256 subtractedValue

  )

    public

    returns (bool)

  {

    require(spender != address(0));



    _allowed[msg.sender][spender] = (

      _allowed[msg.sender][spender].sub(subtractedValue));

    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

    return true;

  }



  /**

  * @dev Transfer token for a specified addresses

  * @param from The address to transfer from.

  * @param to The address to transfer to.

  * @param value The amount to be transferred.

  */

  function _transfer(address from, address to, uint256 value) internal {

    require(value <= _balances[from]);

    require(to != address(0));



    _balances[from] = _balances[from].sub(value);

    _balances[to] = _balances[to].add(value);

    emit Transfer(from, to, value);

  }



  /**

   * @dev Internal function that mints an amount of the token and assigns it to

   * an account. This encapsulates the modification of balances such that the

   * proper events are emitted.

   * @param account The account that will receive the created tokens.

   * @param value The amount that will be created.

   */

  function _mint(address account, uint256 value) internal {

    require(account != 0);

    _totalSupply = _totalSupply.add(value);

    _balances[account] = _balances[account].add(value);

    emit Transfer(address(0), account, value);

  }



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account.

   * @param account The account whose tokens will be burnt.

   * @param value The amount that will be burnt.

   */

  function _burn(address account, uint256 value) internal {

    require(account != 0);

    require(value <= _balances[account]);



    _totalSupply = _totalSupply.sub(value);

    _balances[account] = _balances[account].sub(value);

    emit Transfer(account, address(0), value);

  }



  /**

   * @dev Internal function that burns an amount of the token of a given

   * account, deducting from the sender's allowance for said account. Uses the

   * internal burn function.

   * @param account The account whose tokens will be burnt.

   * @param value The amount that will be burnt.

   */

  function _burnFrom(address account, uint256 value) internal {

    require(value <= _allowed[account][msg.sender]);



    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,

    // this function needs to emit an event with the updated approval.

    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(

      value);

    _burn(account, value);

  }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol



/**

 * @title Burnable Token

 * @dev Token that can be irreversibly burned (destroyed).

 */

contract ERC20Burnable is ERC20 {



  /**

   * @dev Burns a specific amount of tokens.

   * @param value The amount of token to be burned.

   */

  function burn(uint256 value) public {

    _burn(msg.sender, value);

  }



  /**

   * @dev Burns a specific amount of tokens from the target address and decrements allowance

   * @param from address The address which you want to send tokens from

   * @param value uint256 The amount of token to be burned

   */

  function burnFrom(address from, uint256 value) public {

    _burnFrom(from, value);

  }

}



// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/misc/AbstractAmbix.sol



/**

  @dev Ambix contract is used for morph Token set to another

  Token's by rule (recipe). In distillation process given

  Token's are burned and result generated by emission.

  

  The recipe presented as equation in form:

  (N1 * A1 & N'1 * A'1 & N''1 * A''1 ...)

  | (N2 * A2 & N'2 * A'2 & N''2 * A''2 ...) ...

  | (Nn * An & N'n * A'n & N''n * A''n ...)

  = M1 * B1 & M2 * B2 ... & Mm * Bm 

    where A, B - input and output tokens

          N, M - token value coeficients

          n, m - input / output dimetion size 

          | - is alternative operator (logical OR)

          & - is associative operator (logical AND)

  This says that `Ambix` should receive (approve) left

  part of equation and send (transfer) right part.

*/

contract AbstractAmbix is Ownable {

    using SafeERC20 for ERC20Burnable;

    using SafeERC20 for ERC20;



    address[][] public A;

    uint256[][] public N;

    address[] public B;

    uint256[] public M;



    /**

     * @dev Append token recipe source alternative

     * @param _a Token recipe source token addresses

     * @param _n Token recipe source token counts

     **/

    function appendSource(

        address[] _a,

        uint256[] _n

    ) external onlyOwner {

        uint256 i;



        require(_a.length == _n.length && _a.length > 0);



        for (i = 0; i < _a.length; ++i)

            require(_a[i] != 0);



        if (_n.length == 1 && _n[0] == 0) {

            require(B.length == 1);

        } else {

            for (i = 0; i < _n.length; ++i)

                require(_n[i] > 0);

        }



        A.push(_a);

        N.push(_n);

    }



    /**

     * @dev Set sink of token recipe

     * @param _b Token recipe sink token list

     * @param _m Token recipe sink token counts

     */

    function setSink(

        address[] _b,

        uint256[] _m

    ) external onlyOwner{

        require(_b.length == _m.length);



        for (uint256 i = 0; i < _b.length; ++i)

            require(_b[i] != 0);



        B = _b;

        M = _m;

    }



    function _run(uint256 _ix) internal {

        require(_ix < A.length);

        uint256 i;



        if (N[_ix][0] > 0) {

            // Static conversion



            // Token count multiplier

            uint256 mux = ERC20(A[_ix][0]).allowance(msg.sender, this) / N[_ix][0];

            require(mux > 0);



            // Burning run

            for (i = 0; i < A[_ix].length; ++i)

                ERC20Burnable(A[_ix][i]).burnFrom(msg.sender, mux * N[_ix][i]);



            // Transfer up

            for (i = 0; i < B.length; ++i)

                ERC20(B[i]).safeTransfer(msg.sender, M[i] * mux);



        } else {

            // Dynamic conversion

            //   Let source token total supply is finite and decrease on each conversion,

            //   just convert finite supply of source to tokens on balance of ambix.

            //         dynamicRate = balance(sink) / total(source)



            // Is available for single source and single sink only

            require(A[_ix].length == 1 && B.length == 1);



            ERC20Burnable source = ERC20Burnable(A[_ix][0]);

            ERC20 sink = ERC20(B[0]);



            uint256 scale = 10 ** 18 * sink.balanceOf(this) / source.totalSupply();



            uint256 allowance = source.allowance(msg.sender, this);

            require(allowance > 0);

            source.burnFrom(msg.sender, allowance);



            uint256 reward = scale * allowance / 10 ** 18;

            require(reward > 0);

            sink.safeTransfer(msg.sender, reward);

        }

    }

}



// File: contracts/misc/KycAmbix.sol



contract KycAmbix is AbstractAmbix, SignatureBouncer {

    /**

     * @dev Run distillation process

     * @param _ix Source alternative index

     * @param _signature KYC indulgence (KYC signature of concatenated sender and contract address)

     */

    function run(uint256 _ix, bytes _signature) external onlyValidSignature(_signature)

    { _run(_ix); }

}