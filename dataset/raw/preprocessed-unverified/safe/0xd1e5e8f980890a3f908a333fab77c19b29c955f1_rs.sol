/**
 *Submitted for verification at Etherscan.io on 2021-02-17
*/

// SPDX-License-Identifier: (c) Armor.Fi DAO, 2021

pragma solidity ^0.6.6;



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * 
 * @dev Completely default OpenZeppelin.
 */




/**
 * @dev Each arCore contract is a module to enable simple communication and interoperability. ArmorMaster.sol is master.
**/
contract ArmorModule {
    IArmorMaster internal _master;

    using Bytes32 for bytes32;

    modifier onlyOwner() {
        require(msg.sender == Ownable(address(_master)).owner(), "only owner can call this function");
        _;
    }

    modifier doKeep() {
        _master.keep();
        _;
    }

    modifier onlyModule(bytes32 _module) {
        string memory message = string(abi.encodePacked("only module ", _module.toString()," can call this function"));
        require(msg.sender == getModule(_module), message);
        _;
    }

    /**
     * @dev Used when multiple can call.
    **/
    modifier onlyModules(bytes32 _moduleOne, bytes32 _moduleTwo) {
        string memory message = string(abi.encodePacked("only module ", _moduleOne.toString()," or ", _moduleTwo.toString()," can call this function"));
        require(msg.sender == getModule(_moduleOne) || msg.sender == getModule(_moduleTwo), message);
        _;
    }

    function initializeModule(address _armorMaster) internal {
        require(address(_master) == address(0), "already initialized");
        require(_armorMaster != address(0), "master cannot be zero address");
        _master = IArmorMaster(_armorMaster);
    }

    function changeMaster(address _newMaster) external onlyOwner {
        _master = IArmorMaster(_newMaster);
    }

    function getModule(bytes32 _key) internal view returns(address) {
        return _master.getModule(_key);
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IarNFT is IERC721 {
    function getToken(uint256 _tokenId) external returns (uint256, uint8, uint256, uint16, uint256, address, bytes4, uint256, uint256, uint256);
    function submitClaim(uint256 _tokenId) external;
    function redeemClaim(uint256 _tokenId) external;
}







/**
 * @dev This contract holds all NFTs. The only time it does something is if a user requests a claim.
 * @notice We need to make sure a user can only claim when they have balance.
**/
contract ClaimManager is ArmorModule, IClaimManager {
    bytes4 public constant ETH_SIG = bytes4(0x45544800);

    // Mapping of hacks that we have confirmed to have happened. (keccak256(protocol ID, timestamp) => didithappen).
    mapping (bytes32 => bool) confirmedHacks;
    
    // Emitted when a new hack has been recorded.
    event ConfirmedHack(bytes32 indexed hackId, address indexed protocol, uint256 timestamp);
    
    // Emitted when a user successfully receives a payout.
    event ClaimPayout(bytes32 indexed hackId, address indexed user, uint256 amount);

    // for receiving redeemed ether
    receive() external payable {
    }
    
    /**
     * @dev Start the contract off by giving it the address of Nexus Mutual to submit a claim.
    **/
    function initialize(address _armorMaster)
      public
      override
    {
        initializeModule(_armorMaster);
    }
    
    /**
     * @dev User requests claim based on a loss.
     *      Do we want this to be callable by anyone or only the person requesting?
     *      Proof-of-Loss must be implemented here.
     * @param _hackTime The given timestamp for when the hack occurred.
     * @notice Make sure this cannot be done twice. I also think this protocol interaction can be simplified.
    **/
    function redeemClaim(address _protocol, uint256 _hackTime, uint256 _amount)
      external
      doKeep
    {
        bytes32 hackId = keccak256(abi.encodePacked(_protocol, _hackTime));
        require(confirmedHacks[hackId], "No hack with these parameters has been confirmed.");
        
        // Gets the coverage amount of the user at the time the hack happened.
        // TODO check if plan is not active now => to prevent users paying more than needed
        (uint256 planIndex, bool covered) = IPlanManager(getModule("PLAN")).checkCoverage(msg.sender, _protocol, _hackTime, _amount);
        require(covered, "User does not have cover for hack");
        
        IPlanManager(getModule("PLAN")).planRedeemed(msg.sender, planIndex, _protocol);
        msg.sender.transfer(_amount);
        
        emit ClaimPayout(hackId, msg.sender, _amount);
    }
    
    /**
     * @dev Submit any NFT that was active at the time of a hack on its protocol.
     * @param _nftId ID of the NFT to submit.
     * @param _hackTime The timestamp of the hack that occurred. Hacktime is the START of the hack if not a single tx.
    **/
    function submitNft(uint256 _nftId,uint256 _hackTime)
      external
      doKeep
    {
        (/*cid*/, uint8 status, uint256 sumAssured, uint16 coverPeriod, uint256 validUntil, address scAddress,
        bytes4 currencyCode, /*premiumNXM*/, /*coverPrice*/, /*claimId*/) = IarNFT(getModule("ARNFT")).getToken(_nftId);
        bytes32 hackId = keccak256(abi.encodePacked(scAddress, _hackTime));
        
        require(confirmedHacks[hackId], "No hack with these parameters has been confirmed.");
        require(currencyCode == ETH_SIG, "Only ETH nft can be submitted");
        
        // Make sure arNFT was active at the time
        require(validUntil >= _hackTime, "arNFT was not valid at time of hack.");
        
        // Make sure NFT was purchased before hack.
        uint256 generationTime = validUntil - (uint256(coverPeriod) * 1 days);
        require(generationTime <= _hackTime, "arNFT had not been purchased before hack.");

        // Subtract amount it was protecting from total staked for the protocol if it is not expired (in which case it already has been subtracted).
        uint256 weiSumAssured = sumAssured * (1e18);
        if (status != 3) IStakeManager(getModule("STAKE")).subtractTotal(_nftId, scAddress, weiSumAssured);
        // subtract balance here

        IarNFT(getModule("ARNFT")).submitClaim(_nftId);
    }
    
    /**
     * @dev Calls the arNFT contract to redeem a claim (receive funds) if it has been accepted.
     *      This is callable by anyone without any checks--either we receive money or it reverts.
     * @param _nftId The ID of the yNft token.
    **/
    function redeemNft(uint256 _nftId)
      external
      doKeep
    {
        IarNFT(getModule("ARNFT")).redeemClaim(_nftId);
    }
    
    /**
     * @dev Used by StakeManager in case a user wants to withdraw their NFT.
     * @param _to Address to send the NFT to.
     * @param _nftId ID of the NFT to be withdrawn.
    **/
    function transferNft(address _to, uint256 _nftId)
      external
      override
      onlyModule("STAKE")
    {
        IarNFT(getModule("ARNFT")).safeTransferFrom(address(this), _to, _nftId);
    }
    
    /**
     * @dev Called by Armor for now--we confirm a hack happened and give a timestamp for what time it was.
     * @param _protocol The address of the protocol that has been hacked (address that would be on yNFT).
     * @param _hackTime The timestamp of the time the hack occurred.
    **/
    function confirmHack(address _protocol, uint256 _hackTime)
      external
      onlyOwner
    {
        require(_hackTime < now, "Cannot confirm future");
        bytes32 hackId = keccak256(abi.encodePacked(_protocol, _hackTime));
        confirmedHacks[hackId] = true;
        emit ConfirmedHack(hackId, _protocol, _hackTime);
    }

    /**
     * @dev ExchangeManager may withdraw Ether from ClaimManager to then exchange for wNXM then deposit to arNXM vault.
     * @param _amount Amount in Wei to send to ExchangeManager.
    **/
    function exchangeWithdrawal(uint256 _amount)
      external
      override
      onlyModule("EXCHANGE")
    {
        msg.sender.transfer(_amount);
    }

}