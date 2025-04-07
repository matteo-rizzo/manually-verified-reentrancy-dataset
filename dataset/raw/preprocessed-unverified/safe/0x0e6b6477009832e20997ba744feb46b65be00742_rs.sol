/**

 *Submitted for verification at Etherscan.io on 2018-08-22

*/



pragma solidity 0.4.24;











contract Claimable is Ownable {

  address public pendingOwner;



  /**

   * @dev Modifier throws if called by any account other than the pendingOwner.

   */

  modifier onlyPendingOwner() {

    require(msg.sender == pendingOwner);

    _;

  }



  /**

   * @dev Allows the current owner to set the pendingOwner address.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) onlyOwner public {

    pendingOwner = newOwner;

  }



  /**

   * @dev Allows the pendingOwner address to finalize the transfer.

   */

  function claimOwnership() onlyPendingOwner public {

    emit OwnershipTransferred(owner, pendingOwner);

    owner = pendingOwner;

    pendingOwner = 0x0;

  }

}



contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) public constant returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract RedemptionCertificate is Claimable {

    using ECRecovery for bytes32;



    /// @dev A set of addresses that are approved to sign on behalf of this contract

    mapping(address => bool) public signers;



    /// @dev The nonce associated with each hash(accountId).  In this case, the account is an external

    /// concept that does not correspond to an Ethereum address.  Therefore, the hash of the accountId

    /// is used

    mapping(bytes32 => uint256) public nonces;



    address public token;

    address public tokenHolder;



    event TokenHolderChanged(address oldTokenHolder, address newTokenHolder);

    event CertificateRedeemed(string accountId, uint256 amount, address recipient);

    event SignerAdded(address signer);

    event SignerRemoved(address signer);



    constructor(address _token, address _tokenHolder)

    public

    {

        token = _token;

        tokenHolder = _tokenHolder;

    }





    /**

     * @dev ensures that the hash was signed by a valid signer.  Also increments the associated

     * account nonce to ensure that the same hash/signature cannot be used again

     */

    modifier onlyValidSignatureOnce(string accountId, bytes32 hash, bytes signature) {

        address signedBy = hash.recover(signature);

        require(signers[signedBy]);

        _;

        nonces[hashAccountId(accountId)]++;

    }





    /**

     * @dev Attempts to withdraw tokens from this contract, using the signature as proof

     * that the caller is entitled to the specified amount.

     */

    function withdraw(string accountId, uint256 amount, address recipient, bytes signature)

    onlyValidSignatureOnce(

        accountId,

        generateWithdrawalHash(accountId, amount, recipient),

        signature)

    public

    returns (bool)

    {

        require(ERC20(token).transferFrom(tokenHolder, recipient, amount));

        emit CertificateRedeemed(accountId, amount, recipient);

        return true;

    }









    /// Helper Methods



    /**

     * @dev Generates the hash of the message that needs to be signed by an approved signer.

     * The nonce is read directly from the contract's state.

     */

    function generateWithdrawalHash(string accountId, uint256 amount, address recipient)

     view

     public

    returns (bytes32)

    {

        bytes32 accountHash = hashAccountId(accountId);

        bytes memory message = abi.encodePacked(address(this), recipient, amount, nonces[accountHash]);

        bytes32 messageHash = keccak256(message);

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

    }



    /**

     * @dev converts and accoutId to a bytes32

     */

    function hashAccountId(string accountId)

    pure

    internal

    returns (bytes32)

    {

        return keccak256(abi.encodePacked(accountId));

    }













    /// Admin Methods



    function updateTokenHolder(address newTokenHolder)

     onlyOwner

      external

    {

        address oldTokenHolder = tokenHolder;

        tokenHolder = newTokenHolder;

        emit TokenHolderChanged(oldTokenHolder, newTokenHolder);

    }



    function addSigner(address signer)

     onlyOwner

     external

    {

        signers[signer] = true;

        emit SignerAdded(signer);

    }



    function removeSigner(address signer)

     onlyOwner

     external

    {

        signers[signer] = false;

        emit SignerRemoved(signer);

    }

}