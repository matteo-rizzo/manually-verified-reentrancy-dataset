/**
 *Submitted for verification at Etherscan.io on 2021-04-02
*/

pragma solidity ^0.5.17;


/**

Buy The Floor 

Demand-side NFT exchange that allows buyers to make offchain blanket bids for NFTs based on type.  

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

 
 
 


/// @title ERC-721 Non-Fungible Token Standard
       /// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
       ///  Note: the ERC-165 identifier for this interface is 0x80ac58cd
       interface ERC721 /* is ERC165 */ {
           /// @dev This emits when ownership of any NFT changes by any mechanism.
           ///  This event emits when NFTs are created (`from` == 0) and destroyed
           ///  (`to` == 0). Exception: during contract creation, any number of NFTs
           ///  may be created and assigned without emitting Transfer. At the time of
           ///  any transfer, the approved address for that NFT (if any) is reset to none.
           event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

           /// @dev This emits when the approved address for an NFT is changed or
           ///  reaffirmed. The zero address indicates there is no approved address.
           ///  When a Transfer event emits, this also indicates that the approved
           ///  address for that NFT (if any) is reset to none.
           event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

           /// @dev This emits when an operator is enabled or disabled for an owner.
           ///  The operator can manage all NFTs of the owner.
           event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

           /// @notice Count all NFTs assigned to an owner
           /// @dev NFTs assigned to the zero address are considered invalid, and this
           ///  function throws for queries about the zero address.
           /// @param _owner An address for whom to query the balance
           /// @return The number of NFTs owned by `_owner`, possibly zero
           function balanceOf(address _owner) external view returns (uint256);

           /// @notice Find the owner of an NFT
           /// @dev NFTs assigned to zero address are considered invalid, and queries
           ///  about them do throw.
           /// @param _tokenId The identifier for an NFT
           /// @return The address of the owner of the NFT
           function ownerOf(uint256 _tokenId) external view returns (address);

           /// @notice Transfers the ownership of an NFT from one address to another address
           /// @dev Throws unless `msg.sender` is the current owner, an authorized
           ///  operator, or the approved address for this NFT. Throws if `_from` is
           ///  not the current owner. Throws if `_to` is the zero address. Throws if
           ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
           ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
           ///  `onERC721Received` on `_to` and throws if the return value is not
           ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
           /// @param _from The current owner of the NFT
           /// @param _to The new owner
           /// @param _tokenId The NFT to transfer
           /// @param data Additional data with no specified format, sent in call to `_to`
           function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

           /// @notice Transfers the ownership of an NFT from one address to another address
           /// @dev This works identically to the other function with an extra data parameter,
           ///  except this function just sets data to ""
           /// @param _from The current owner of the NFT
           /// @param _to The new owner
           /// @param _tokenId The NFT to transfer
           function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

           /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
           ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
           ///  THEY MAY BE PERMANENTLY LOST
           /// @dev Throws unless `msg.sender` is the current owner, an authorized
           ///  operator, or the approved address for this NFT. Throws if `_from` is
           ///  not the current owner. Throws if `_to` is the zero address. Throws if
           ///  `_tokenId` is not a valid NFT.
           /// @param _from The current owner of the NFT
           /// @param _to The new owner
           /// @param _tokenId The NFT to transfer
           function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

           /// @notice Set or reaffirm the approved address for an NFT
           /// @dev The zero address indicates there is no approved address.
           /// @dev Throws unless `msg.sender` is the current NFT owner, or an authorized
           ///  operator of the current owner.
           /// @param _approved The new approved NFT controller
           /// @param _tokenId The NFT to approve
           function approve(address _approved, uint256 _tokenId) external payable;

           /// @notice Enable or disable approval for a third party ("operator") to manage
           ///  all of `msg.sender`'s assets.
           /// @dev Emits the ApprovalForAll event. The contract MUST allow
           ///  multiple operators per owner.
           /// @param _operator Address to add to the set of authorized operators.
           /// @param _approved True if the operator is approved, false to revoke approval
           function setApprovalForAll(address _operator, bool _approved) external;

           /// @notice Get the approved address for a single NFT
           /// @dev Throws if `_tokenId` is not a valid NFT
           /// @param _tokenId The NFT to find the approved address for
           /// @return The approved address for this NFT, or the zero address if there is none
           function getApproved(uint256 _tokenId) external view returns (address);

           /// @notice Query if an address is an authorized operator for another address
           /// @param _owner The address that owns the NFTs
           /// @param _operator The address that acts on behalf of the owner
           /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
           function isApprovedForAll(address _owner, address _operator) external view returns (bool);
       }

       

       
        
        



// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------






contract ECRecovery {

  /**
   * @dev Recover signer address from a message by using their signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes memory sig) internal  pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    //Check the signature length
    if (sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

}


/*
ERC20 tokens must be approved to this contract ! 
Then, the buyer will perform an offchain metatx personalsign for their bid 

NFT must also be approved to this contract - setApprovalForAll
*/

contract BuyTheFloorExchange is Owned, ECRecovery  {

  using SafeMath for uint;

    
  mapping (bytes32 => uint) public burnedSignatures; 
    
  uint256 public _fee_pct;
  uint256 public _chain_id;
 
  constructor( uint chainId, uint fee_pct) public { 
    require(fee_pct >= 0 && fee_pct <100);

    _fee_pct = fee_pct;
    _chain_id = chainId;
  }


  //Do not allow ETH to enter
   function() external payable {
    revert();
  }
  
  event BuyTheFloor(address indexed bidderAddress, address indexed sellerAddress, address indexed nftContractAddress, uint256 tokenId, address currencyTokenAddress, uint currencyTokenAmount);
  event SignatureBurned(address indexed bidderAddress, bytes32 hash);
  
  struct BidPacket {
    address bidderAddress;
    address nftContractAddress;
    address currencyTokenAddress;
    uint256 currencyTokenAmount;
    bool requireProjectId;
    uint256 projectId;
    uint256 expires;
  }
  
  
     bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
          "EIP712Domain(string contractName,string version,uint256 chainId,address verifyingContract)"
      );

   function getBidDomainTypehash() public pure returns (bytes32) {
      return EIP712DOMAIN_TYPEHASH;
   }

   function getEIP712DomainHash(string memory contractName, string memory version, uint256 chainId, address verifyingContract) public pure returns (bytes32) {

      return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(contractName)),
            keccak256(bytes(version)),
            chainId,
            verifyingContract
        ));
    }


  bytes32 constant BIDPACKET_TYPEHASH = keccak256(
      "BidPacket(address bidderAddress,address nftContractAddress,address currencyTokenAddress,uint256 currencyTokenAmount,bool requireProjectId,uint256 projectId,uint256 expires)"
  );



    function getBidPacketTypehash()  public pure returns (bytes32) {
      return BIDPACKET_TYPEHASH;
  }
  
  function getBidPacketHash(address bidderAddress,address nftContractAddress,address currencyTokenAddress, uint256 currencyTokenAmount,bool requireProjectId,uint256 projectId,uint256 expires) public pure returns (bytes32) {
          return keccak256(abi.encode(
              BIDPACKET_TYPEHASH,
              bidderAddress,
              nftContractAddress,
              currencyTokenAddress,
              currencyTokenAmount,
              requireProjectId,
              projectId,
              expires
          ));
      }

  function getBidTypedDataHash(address bidderAddress,address nftContractAddress,address currencyTokenAddress, uint256 currencyTokenAmount,bool requireProjectId,uint256 projectId,uint256 expires) public view returns (bytes32) {


              
              bytes32 digest = keccak256(abi.encodePacked(
                  "\x19\x01",
                  getEIP712DomainHash('BuyTheFloor','2',_chain_id,address(this)),
                  getBidPacketHash(bidderAddress,nftContractAddress,currencyTokenAddress,currencyTokenAmount,requireProjectId,projectId,expires)
              ));
              return digest;
          }
  

  //require pre-approval from the buyer in the form of a personal sign 
  function sellNFT(address nftContractAddress, uint256 tokenId, address from, address to, address currencyToken, uint256 currencyAmount, bool requireProjectId,uint256 projectId, uint256 expires, bytes memory buyerSignature) public returns (bool){
      
      //require personalsign from buyer to be submitted by seller  
      bytes32 sigHash = getBidTypedDataHash(to,nftContractAddress,currencyToken,currencyAmount,requireProjectId,projectId,expires);

      address recoveredSignatureSigner = recover(sigHash,buyerSignature);


      //make sure the signer is the depositor of the tokens
      require(to == recoveredSignatureSigner, 'Invalid signature');
      require(from == msg.sender, 'Not NFT Owner');
      
      
      require(block.number < expires || expires == 0, 'bid expired');
     
      require(burnedSignatures[sigHash] == 0, 'signature already used');
      burnedSignatures[sigHash] = 0x1;
      
      if(requireProjectId){
          require(ProjectBasedNFT(nftContractAddress).tokenIdToProjectId(tokenId) == projectId , 'Incorrect Project Id');
      }
      
      
      ERC721(nftContractAddress).safeTransferFrom(from, to, tokenId);
      
      _transferCurrencyForSale(from,to,currencyToken,currencyAmount);
      
      
      emit BuyTheFloor(to, from, nftContractAddress, tokenId, currencyToken, currencyAmount);
      emit SignatureBurned(to, sigHash);

      return true;
  }
  
  function _transferCurrencyForSale(address from, address to, address currencyToken, uint256 currencyAmount) internal returns (bool){
    uint256 feeAmount = currencyAmount.mul(_fee_pct).div(100);

    require( IERC20(currencyToken).transferFrom(to, from, currencyAmount.sub(feeAmount) ), 'unable to pay' );
    require( IERC20(currencyToken).transferFrom(to, owner, feeAmount ), 'unable to pay'  );
    
    return true;
  }
  
   
  function cancelBid(address nftContractAddress, address to, address currencyToken, uint256 currencyAmount,  bool requireProjectId, uint256 projectId, uint256 expires, bytes memory buyerSignature ) public returns (bool){
      bytes32 sigHash = getBidTypedDataHash(to,nftContractAddress,currencyToken,currencyAmount,requireProjectId,projectId,expires);
      address recoveredSignatureSigner = recover(sigHash,buyerSignature);
      
      require(to == recoveredSignatureSigner, 'Invalid signature');
      require(msg.sender == recoveredSignatureSigner, 'Not bid owner');
      require(burnedSignatures[sigHash]==0, 'Already burned');
      
      burnedSignatures[sigHash] = 0x2;
      emit SignatureBurned(to, sigHash);
      
      return true;
  }
  
  
  
}