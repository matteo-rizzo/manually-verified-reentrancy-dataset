/**
 *Submitted for verification at Etherscan.io on 2021-08-19
*/

pragma solidity ^0.8.4;

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
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



/**
 * @dev Collection of functions related to the address type
 */



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}




contract ZAuction {
    using ECDSA for bytes32;

    IERC20 public token;
    IRegistrar public registrar;
    mapping(address => mapping(uint256 => bool)) public consumed;
    mapping(address => mapping(uint256 => uint256)) cancelprice;

    event Cancelled(
        address indexed bidder,
        uint256 indexed auctionid,
        uint256 price
    );
    event BidAccepted(
        uint256 auctionid,
        address indexed bidder,
        address indexed seller,
        uint256 amount,
        address nftaddress,
        uint256 tokenid,
        uint256 expireblock
    );

    constructor(IERC20 tokenAddress, IRegistrar registrarAddress) {
        token = tokenAddress;
        registrar = registrarAddress;
    }

    /// recovers bidder's signature based on seller's proposed data and, if bid data hash matches the message hash, transfers nft and payment
    /// @param signature type encoded message signed by the bidder
    /// @param auctionid unique per address auction identifier chosen by seller
    /// @param bidder address of who the seller says the bidder is, for confirmation of the recovered bidder
    /// @param bid token amount bid
    /// @param nftaddress contract address of the nft we are transferring
    /// @param tokenid token id we are transferring
    /// @param minbid minimum bid allowed
    /// @param startblock block number at which acceptBid starts working
    /// @param expireblock block number at which acceptBid stops working
    function acceptBid(
        bytes memory signature,
        uint256 auctionid,
        address bidder,
        uint256 bid,
        address nftaddress,
        uint256 tokenid,
        uint256 minbid,
        uint256 startblock,
        uint256 expireblock
    ) external {
        require(startblock <= block.number, "zAuction: auction hasnt started");
        require(expireblock > block.number, "zAuction: auction expired");
        require(minbid <= bid, "zAuction: cant accept bid below min");
        require(bidder != msg.sender, "zAuction: sale to self");
        //require(registrar.isDomainMetadataLocked(tokenid), "zAuction: ZNS domain metadata must be locked");

        bytes32 data = createBid(
            auctionid,
            bid,
            nftaddress,
            tokenid,
            minbid,
            startblock,
            expireblock
        );
        require(
            bidder == recover(toEthSignedMessageHash(data), signature),
            "zAuction: recovered incorrect bidder"
        );
        require(
            !consumed[bidder][auctionid],
            "zAuction: data already consumed"
        );
        require(
            bid > cancelprice[bidder][auctionid],
            "zAuction: below cancel price"
        );

        IERC721 nftcontract = IERC721(nftaddress);
        consumed[bidder][auctionid] = true;
        SafeERC20.safeTransferFrom(token, bidder, msg.sender, bid - (bid / 10));
        SafeERC20.safeTransferFrom(
            token,
            bidder,
            registrar.minterOf(tokenid),
            bid / 10
        );
        nftcontract.safeTransferFrom(msg.sender, bidder, tokenid);
        emit BidAccepted(
            auctionid,
            bidder,
            msg.sender,
            bid,
            address(nftcontract),
            tokenid,
            expireblock
        );
    }

    function createBid(
        uint256 auctionid,
        uint256 bid,
        address nftaddress,
        uint256 tokenid,
        uint256 minbid,
        uint256 startblock,
        uint256 expireblock
    ) public view returns (bytes32 data) {
        data = keccak256(
            abi.encode(
                auctionid,
                address(this),
                block.chainid,
                bid,
                nftaddress,
                tokenid,
                minbid,
                startblock,
                expireblock
            )
        );
    }

    /// invalidates all sender's bids at and under given price
    /// @param auctionid unique per address auction identifier chosen by seller
    /// @param price token amount to cancel at and under
    function cancelBidsUnderPrice(uint256 auctionid, uint256 price) external {
        cancelprice[msg.sender][auctionid] = price;
        emit Cancelled(msg.sender, auctionid, price);
    }

    function recover(bytes32 hash, bytes memory signature)
        public
        pure
        returns (address)
    {
        return hash.recover(signature);
    }

    function toEthSignedMessageHash(bytes32 hash)
        public
        pure
        returns (bytes32)
    {
        return hash.toEthSignedMessageHash();
    }
}