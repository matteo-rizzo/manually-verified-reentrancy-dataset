pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol
// Subject to the MIT license.
/**
 * @dev String operations.
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
 * @title ERC 20 Token Standard Interface
 *  https://eips.ethereum.org/EIPS/eip-20
 */

 /*
 * @dev Collection of functions related to the address type
 */



/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */

contract CallOption {
  using SafeMath for uint256;
  using Strings for uint256;
  using Address for address;

  struct PremiumInfo {
    address premiumToken;
    uint premiumAmt;
    bool premiumRedeemed;
    uint premiumPlatformFee;
    uint sellerPremium;
  }

  struct UnderlyingInfo {
    address underlyingCurrency;
    uint underlyingAmt;
    bool redeemed;
    bool isCall;
  }

  struct Option {
    // Proposal high level
    uint proposalExpiresAt;
    address seller;
    address buyer;
    
    // Proposal premium
    PremiumInfo premiumInfo;
    
    // Underlying
    UnderlyingInfo underlyingInfo;

    // Strike price
    address strikeCurrency;
    uint strikeAmt;
  
    // Acceptance state
    bool sellerAccepted;
    bool buyerAccepted;

    // Option 
    uint optionExpiresAt;
    bool cancelled;
    bool executed;
  }

  event UnderlyingDeposited(uint indexed optionUID, address seller, address token, uint amount);  
  event PremiumDeposited(uint indexed optionUID, address buyer, address token, uint amount);  
  event SellerAccepted(uint indexed optionUID, address seller);
  event BuyerAccepted(uint indexed optionUID, address buyer);
  event BuyerCancelled(uint indexed optionUID, address buyer);
  event SellerCancelled(uint indexed optionUID, address seller);
  event BuyerPremiumRefunded(uint indexed optionUID, address buyer);
  event SellerUnderlyingRedeemed(uint indexed optionUID, address seller);
  event SellerRedeemedPremium(uint indexed optionUID, address seller);
  event TransferSeller(uint indexed optionUID, address oldSeller, address newSeller);
  
  event OptionExecuted(uint indexed optionUID);

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

  // Maps user to the IDS of their associated options
  mapping(address => uint[]) public userOptions;
  
  // Stores the state of all the options
  Option[] public options;

  // Fee taken out of the premiums collected
  uint public platformFee = 5; // 0.005 
 
  // Address which collected fees are directed to
  address public feeBeneficiaryAddress;

  // Fees that are withdrawable
  mapping(address => uint) public platformFeeBalances;

  // Mapping from token ID to approved address
  mapping (uint256 => address) private _tokenApprovals;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) private _operatorApprovals;

  string public constant symbol = "OPTION-SWAP";
  string public constant name = "ERC-20 Option (OptionSwap.finance)";

  address public admin;

  constructor() public {
    admin = msg.sender;
  }


  /**
   * @notice Propose a new option with the following criteria 
   */
  function propose(address seller, address buyer, uint proposalExpiresAt, uint optionExpiresAt, 
                        address premiumToken, uint premiumAmt, 
                        address underlyingCurrency, uint underlyingAmt, 
                        address strikeCurrency, uint strikeAmt, bool isCall) public {
    
    require((seller == msg.sender) || (buyer == msg.sender), "Must be either the seller or buyer");

    require(proposalExpiresAt <= optionExpiresAt, "Option cannot expire before proposal");

    // Compute the seller premium to be earned and associated platform fee from the premium
    (uint sellerPremium, uint platformFeePremium) = _computePremiumSplit(premiumAmt, EIP20Interface(premiumToken).decimals());
    
    // Add the option to list of options
    options.push(Option(
      { 
          seller: seller, 
          buyer: buyer, 
          proposalExpiresAt: proposalExpiresAt, 
          premiumInfo: PremiumInfo({ 
            premiumToken: premiumToken, 
            premiumAmt: premiumAmt, 
            premiumRedeemed: false,
            premiumPlatformFee: platformFeePremium,
            sellerPremium: sellerPremium}),
          underlyingInfo: UnderlyingInfo({ 
            underlyingCurrency: underlyingCurrency, 
            underlyingAmt: underlyingAmt, 
            isCall: isCall,
            redeemed: false }),
          strikeCurrency: strikeCurrency,
          strikeAmt: strikeAmt,
          optionExpiresAt: optionExpiresAt,
          cancelled: false,
          executed: false,
          sellerAccepted: false,
          buyerAccepted: false
      }));
    
    // If sender is the seller, transfer underlying and update tracking state
    if (msg.sender == seller) {
      _acceptSeller(options.length - 1);
    }
    
    // If sender is the buyer, transfer premium and update tracking state 
    if (msg.sender == buyer) {
      _acceptBuyer(options.length - 1);
    }
  }
  
  /**
   * @notice Compute how much of the premium goes to the seller and how much to the platform 
   */
  function _computePremiumSplit(uint premium, uint decimals) public view returns(uint, uint) {
    require(decimals <= 78, "_computePremiumSplit(): too many decimals will overflow"); 
    require(decimals >= 3, "_computePremiumSplit(): too few decimals will underflow"); 
    uint platformFeeDoubleScaled = premium.mul(platformFee * (10 ** (decimals - 3)));
    
    uint platformFeeCollected = platformFeeDoubleScaled.div(10 ** (decimals));

    uint redeemable = premium.sub(platformFeeCollected);
    return (redeemable, platformFeeCollected);
  }

  /**
   * @notice Allows Seller to redeem their premium after the option has been accepted by the buyer 
   */
  function redeemPremium(uint optionUID) public {
    Option storage option = options[optionUID];
    
    // Can only redeem premium once
    require(!option.premiumInfo.premiumRedeemed, "redeemPremium(): premium already redeemed");
    
    if(option.cancelled || proposalExpired(optionUID)){
      bool isBuyer = option.buyer == msg.sender; 
      require(isBuyer, "redeemPremium(): only buyer can redeem when proposal expired");
     
      // Track premium redeemed 
      option.premiumInfo.premiumRedeemed = true; 
    
      // Transfer buyer's premium back to themself 
      EIP20Interface token = EIP20Interface(option.premiumInfo.premiumToken);
      bool success = token.transfer(option.buyer, option.premiumInfo.premiumAmt);
      require(success, "redeemPremium(): premium transfer failed"); 
     
      emit BuyerPremiumRefunded(optionUID, msg.sender);
      return;
    }
    
    // Only the seller may redeem the premium 
    bool isSeller = option.seller == msg.sender; 
    
    require(isSeller, "redeemPremium(): only option seller can redeem");
    
    // Cannot redeem an option that hasn't been accepted  
    require(option.buyerAccepted && option.sellerAccepted, "redeemPremium(): option hasn't been accepted");
    
    // Track premium redeemed 
    option.premiumInfo.premiumRedeemed = true; 
    
    // Update platform fee balances to include their split of the premium 
    platformFeeBalances[option.premiumInfo.premiumToken] = platformFeeBalances[option.premiumInfo.premiumToken].add(option.premiumInfo.premiumPlatformFee);
    
    // Transfer seller's premium earned to themself 
    EIP20Interface token = EIP20Interface(option.premiumInfo.premiumToken);
    bool success = token.transfer(option.seller, option.premiumInfo.sellerPremium);
    require(success, "redeemPremium(): premium transfer failed"); 
  
    emit SellerRedeemedPremium(optionUID, msg.sender);
  }

  /**
   * @notice Status for whether time has expired for the option to be executed 
   */
  function optionExpired(uint optionUID) public view returns(bool) {
    Option memory option = options[optionUID];
    if (option.optionExpiresAt > now) 
      return false;
    else
      return true;
  }

  /**
   * @notice Status for whether time has expired for the option proposal to be accepted 
   */
  function proposalExpired(uint optionUID) public view returns (bool) {
    Option memory option = options[optionUID];
    if (option.sellerAccepted && option.buyerAccepted)
      return false;
    if (option.proposalExpiresAt > now) 
      return false;
    else
      return true;
  }

  /**
   * @notice Allow the seller to redeem their underlying if option goes unused (cancelled, proposal expired, option expired)
   */
  function redeemUnderlying(uint optionUID) public {
    Option storage option = options[optionUID];
    
    // Must be seller to redeem underlying
    bool isSeller = option.seller == msg.sender; 
    require(isSeller, "redeemUnderlying(): only seller may redeem");
    
    require(!option.underlyingInfo.redeemed, "redeemUnderlying(): redeemed, nothing remaining to redeem");
    require(!option.executed, "redeemUnderlying(): executed, nothing to redeem");
    require(option.cancelled || optionExpired(optionUID) || proposalExpired(optionUID), "redeemUnderlying(): must be cancelled or expired to redeem");

    // Mark as redeemed to ensure only gets redeemed once 
    option.underlyingInfo.redeemed = true;
   
    emit SellerUnderlyingRedeemed(optionUID, msg.sender);

    // Transfer underlying back to the seller
    EIP20Interface token = EIP20Interface(option.underlyingInfo.underlyingCurrency);
    bool success = token.transfer(option.seller, option.underlyingInfo.underlyingAmt);
    require(success, "redeemUnderlying(): premium transfer failed"); 
  }

  /**
   * @notice Allows buyer to transfer ownership of option to another user 
   */
  function transferSeller(uint optionUID, address newSeller) public {
    Option storage option = options[optionUID];
    
    // Only the seller may transfer an option
    bool isSeller = option.seller == msg.sender; 
    require(isSeller, "transferSeller(): must be seller");
    
    // Update option buyer 
    option.seller = newSeller; 
    userOptions[newSeller].push(optionUID);
    
    emit TransferSeller(optionUID, msg.sender, newSeller);
  }

  /**
   * @notice Buyer supplies strike amount from strike currency to receive underlying 
   */
  function execute(uint optionUID) public {
    Option storage option = options[optionUID];
    
    // Only the buyer may execute the option
    bool isBuyer = option.buyer == msg.sender; 
    require(isBuyer, "execute(): Must be option owner");
    
    // Nothing to execute w/o both accepting the option
    require(option.buyerAccepted && option.sellerAccepted, "execute(): must be a fully accepted option");
    
    // Cannot execute once expired
    require(!optionExpired(optionUID), "execute(): option expired");
    
    // Cannot execute more than once
    require(!option.executed, "execute(): already executed");

    // Mark as executed
    option.executed = true;
     
    // 1st Transfer the strike amount from the option buyer
    EIP20Interface token = EIP20Interface(option.strikeCurrency);
    bool success = token.transferFrom(option.buyer, address(this), option.strikeAmt);
    require(success, "execute(): strike transfer failed"); 
    
    // 2nd Transfer the strike amount to the option seller 
    success = token.transfer(option.seller, option.strikeAmt);
    require(success, "execute(): strike transfer failed"); 
    
    // 3rd Transfer the underlying to the option buyer
    EIP20Interface tokenUnderlying = EIP20Interface(option.underlyingInfo.underlyingCurrency);
    success = tokenUnderlying.transfer(option.buyer, option.underlyingInfo.underlyingAmt);
    
    emit OptionExecuted(optionUID);

    require(success, "execute(): underlying transfer failed"); 
  }

  /**
   * @notice If buyer or seller sets status fields and transfers either the premium or underlying  
   */
  function accept(uint optionUID) public {
    Option memory option = options[optionUID];
    bool isSeller = option.seller == msg.sender || option.seller == address(0);
    bool isBuyer = option.buyer == msg.sender || option.buyer == address(0);
    require(isSeller || isBuyer, "accept(): Must either buyer or seller");

    if (isBuyer){ 
      _acceptBuyer(optionUID);
    }
    else if (isSeller) {
      _acceptSeller(optionUID);
    }
  }

  /**
   * @notice If buyer or seller sets status fields and transfers either the premium or underlying  
   */
  function cancel(uint optionUID) public {
    Option memory option = options[optionUID];
    bool isSeller = option.seller == msg.sender; 
    bool isBuyer = option.buyer == msg.sender; 
    require(isSeller || isBuyer, "cancel(): only sellers and buyers can cancel"); 
    
    if (isSeller) {
      _cancelSeller(optionUID);
    }
    else if (isBuyer) {
      _cancelBuyer(optionUID);
    }
  }

  /**
   * @notice Seller calls cancel before buyer accepts, returns underlying 
   */
  function _cancelSeller(uint optionUID) internal {
    Option memory option = options[optionUID];
    require(option.sellerAccepted, "_cancelSeller(): cannot cancel before accepting");
    require(!option.buyerAccepted, "_cancelSeller(): already accepted");
    require(!option.cancelled, "_cancelSeller(): already cancelled");
    // Cancel the option
    options[optionUID].cancelled = true;
  
    emit SellerCancelled(optionUID, msg.sender);
    
    // Redeem the underlying
    redeemUnderlying(optionUID);
  }

  /**
   * @notice Buyer calls cancel before buyer accepts, returns full premium no fees deducted 
   */
  function _cancelBuyer(uint optionUID) internal {
    Option memory option = options[optionUID];
    require(option.buyerAccepted, "_cancelBuyer(): cannot cancel before accepting");
    require(!option.sellerAccepted, "_cancelBuyer(): already accepted");
    require(!option.cancelled, "already cancelled");
    
    // Cancel the option
    options[optionUID].cancelled = true;
    
    emit BuyerCancelled(optionUID, msg.sender);
    
    // Return the buyers premium  
    redeemPremium(optionUID);
  }

  /**
   * @notice Seller accepts option, transfers underlying amount, if buyer paid premium redeem it 
   */
  function _acceptSeller(uint optionUID) internal {
    Option storage option = options[optionUID];
    require(!option.sellerAccepted, "seller already accepted");
    
    // Mark as seller accepted
    option.sellerAccepted = true;
    
    // transfer specified tokens
    EIP20Interface token = EIP20Interface(option.underlyingInfo.underlyingCurrency);
    bool success = token.transferFrom(msg.sender, address(this), option.underlyingInfo.underlyingAmt);
    require(success, "_acceptSeller(): Failed to transfer underlying");

    // Emit event
    emit UnderlyingDeposited(optionUID, msg.sender, option.underlyingInfo.underlyingCurrency, option.underlyingInfo.underlyingAmt);

    // If option seller was universal, set it to the sender
    if (option.seller == address(0)) {
      options[optionUID].seller = msg.sender;
    }
    userOptions[msg.sender].push(optionUID);

    // If buyer already accepted, redeem premium
    if (option.buyerAccepted) {
      redeemPremium(optionUID);
    }

    emit SellerAccepted(optionUID, msg.sender);
  }

  /**
   * @notice Buyer accepts option, transfers premium 
   */
  function _acceptBuyer(uint optionUID) internal {
    Option storage option = options[optionUID];
    require(!option.buyerAccepted, "buyer already accepted");
    
    // Mark as buyer accepted
    option.buyerAccepted = true;
   
    // transfer specified premium 
    EIP20Interface token = EIP20Interface(option.premiumInfo.premiumToken);
    bool success = token.transferFrom(msg.sender, address(this), option.premiumInfo.premiumAmt);
    require(success, "Failed to transfer premium");
    
    // If option buyer was universal, set it to the sender
    if (option.buyer == address(0)) {
      options[optionUID].buyer = msg.sender;
    }
      
    userOptions[msg.sender].push(optionUID);
    
    emit PremiumDeposited(optionUID, msg.sender, option.premiumInfo.premiumToken, option.premiumInfo.premiumAmt);
    emit BuyerAccepted(optionUID, msg.sender);
  }
  
  //------------------------
  //  Status functions
  //------------------------
  
  function canAccept(uint optionUID) public view returns(bool) {
    Option memory option = options[optionUID];
    return (!option.buyerAccepted || !option.sellerAccepted) && !proposalExpired(optionUID); 
  }

  function canCancel(uint optionUID) public view returns(bool) {
    Option memory option = options[optionUID];
    return (!option.buyerAccepted || !option.sellerAccepted) && !proposalExpired(optionUID); 
  }

  function canExecute(uint optionUID) public view returns(bool) {
    Option memory option = options[optionUID];
    return !option.executed && (option.buyerAccepted && option.sellerAccepted) && !optionExpired(optionUID); 
  }
  
  function canRedeemPremium(uint optionUID) public view returns(bool) {
    Option memory option = options[optionUID];
    return (option.buyerAccepted && option.sellerAccepted) && !option.premiumInfo.premiumRedeemed; 
  }
  
  function canRedeemUnderlying(uint optionUID) public view returns(bool) {
    Option memory option = options[optionUID];
    if (option.cancelled || optionExpired(optionUID) || proposalExpired(optionUID))
      return !option.underlyingInfo.redeemed && !option.executed;
    else
      return false;
  }
  
  //------------------------
  // NFT Functions
  //------------------------
    function balanceOf(address _owner) external view returns (uint256) {
      uint count = 0;
      for(uint i; i< options.length; i++) {
        if(options[i].seller == _owner || options[i].buyer == _owner) {
          if(options[i].sellerAccepted && options[i].buyerAccepted) {
            count += 1;
          }
        }
      }
      return count;
    }

    function totalSupply() public view returns (uint256) {
      uint count = 0;
      for(uint i; i< options.length; i++) {
        if(options[i].sellerAccepted && options[i].buyerAccepted) {
          count += 1;
        }
      }
      return count;
    }

    function baseTokenURI() public view returns (string memory) {
      return "https://metadata.optionswap.finance/";
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(baseTokenURI(), tokenId.toString()));
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
      Option memory option = options[_tokenId];
      return option.buyer;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return options[tokenId].buyer != address(0); 
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
  
     /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        Option storage option = options[tokenId];
        option.buyer = to;
        userOptions[to].push(tokenId);

        emit Transfer(from, to, tokenId);
    }

     /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        bytes4 _ERC721_RECEIVED = 0x150b7a02;
        if (to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            msg.sender,
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal {}

  //------------------------
  //  Lens functions
  //------------------------
 
  // Returns the options data for a given account
  function optionsForAccount(address account) public view returns(uint[] memory) {
    if (userOptions[account].length == 0) {
      uint[] memory blank;
      return blank;
    }
    return userOptions[account];
  }
  
  // Returns all the options 
  function getOptions() public view returns(Option[] memory) {
    return options;
  }


  //------------------------
  //  Admin functions
  //------------------------
  
  // Updates the platform fee, only affects new options created
  function __updateFee(uint newPlatformFee) public {
    require(msg.sender == admin, "__updateFee(): must be admin");
    platformFee = newPlatformFee;
  }

  function __redeemPlatformFee(uint amount, address tokenAddress) public {
    require(msg.sender == admin, "__redeemPlatformFee(): must be admin");
    require(platformFeeBalances[tokenAddress] >= amount, "__redeemPlatformFee(): requested redemption too large");

    // Update total balance
    platformFeeBalances[tokenAddress] = platformFeeBalances[tokenAddress].sub(amount);
    
    // Perform transfer
    EIP20Interface token = EIP20Interface(tokenAddress);
    bool success = token.transfer(msg.sender, amount);
    require(success, "Failed to transfer premium");
  }


}