/**
 *Submitted for verification at Etherscan.io on 2020-12-14
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: UNLICENSED

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */

contract airdrop{
    
    using SafeMath for uint256;
    // ECDSA Address
    using ECDSA for address;

    address public sam;
    address public samx;
    bool public pause;
    
    modifier constractStatus(){
        require(!pause,"contract locked");
        _;
    } 
    
    address private signer;
 
    // Contract owner address
    address public owner;
    
      // Signature Message Hash
    mapping(bytes32 => bool)public msgHash;
      
    constructor (address _sam,address _samx, address _signer) public {
      sam = _sam;
      samx = _samx;
      signer = _signer;
      owner = msg.sender;
    }  
      
    mapping(address => bool) public userStatus;
      
    function claim(uint256 deadline, bytes calldata signature) public constractStatus{
        
        require(!userStatus[tx.origin]," claim: Duplicate ");
        require(deadline > now , "time Expired" );
        
        uint256 _amount = IERC20(sam).balanceOf(tx.origin);
        //messageHash can be used only once
        bytes32 messageHash = message(tx.origin, _amount, deadline);
        require(!msgHash[messageHash], "claim: signature duplicate");
        
         //Verifes signature    
        address src = verifySignature(messageHash, signature);
        require(signer == src, " claim: unauthorized");
        
        userStatus[msg.sender] = true;
        uint256 totalToken;
        totalToken = (_amount.mul(45)).div(10);
        IERC20(samx).transfer(tx.origin, totalToken);
         
    }
    
    /**
    * @dev Ethereum Signed Message, created from `hash`
    * @dev Returns the address that signed a hashed message (`hash`) with `signature`.
    */
    function verifySignature(bytes32 _messageHash, bytes memory _signature) 
        public pure returns (address signatureAddress)
    {
        
        bytes32 hash = ECDSA.toEthSignedMessageHash(_messageHash);
        signatureAddress = ECDSA.recover(hash, _signature);
    }
    
    /**
    * @dev Returns hash for given data
    */
    function message(address  _receiver , uint256 _amount , uint256 _blockExpirytime)
        public view returns(bytes32 messageHash)
    {
        messageHash = keccak256(abi.encodePacked(address(this), _receiver, _amount, _blockExpirytime));
    }
    
        /**
     * @notice claimPendingToken Owner can withdraw pending tokens from contract.
     * @param tokenAddr  token address. 
     */
    function claimPendingToken(address tokenAddr) 
        public 
    {
        // Owner call check
        require(msg.sender == owner, " only Owner");
        // Pending token transfer
        IERC20(tokenAddr).transfer(msg.sender, IERC20(samx).balanceOf(address(this)));

    }
    function setStatus(bool _status )public {
        require(msg.sender == owner, " only Owner");
        pause=_status;
    }
    
}