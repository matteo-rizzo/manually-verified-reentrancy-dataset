/**
 *Submitted for verification at Etherscan.io on 2021-07-01
*/

// SPDX-License-Identifier: Apache License, Version 2.0

pragma solidity 0.7.6;



// Part: Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: ECDSA

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */


// Part: IERC165

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


// Part: IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: ReentrancyGuard

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// Part: SafeMath

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


// Part: EIP712

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private _CACHED_DOMAIN_SEPARATOR;
    uint256 private _CACHED_CHAIN_ID;

    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private _TYPE_HASH;
    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    //    constructor(string memory name, string memory version) {
    //        bytes32 hashedName = keccak256(bytes(name));
    //        bytes32 hashedVersion = keccak256(bytes(version));
    //        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    //        _HASHED_NAME = hashedName;
    //        _HASHED_VERSION = hashedVersion;
    //        _CACHED_CHAIN_ID = _getChainId();
    //        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
    //        _TYPE_HASH = typeHash;
    //    }
    /**
     * for proxy, use initialize instead.
     * set 'owner', 'galaxy community' and register 1155, metadata interface.
     */
    function initialize() internal {
        // EIP712("Galaxy", "1.0.0");
        string memory name = "Galaxy";
        string memory version = "1.0.0";
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = _getChainId();
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (_getChainId() == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                _getChainId(),
                address(this)
            )
        );
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    function _getChainId() private view returns (uint256 chainId) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        // solhint-disable-next-line no-inline-assembly
        assembly {
            chainId := chainid()
        }
    }
}

// Part: IERC1155

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

// Part: IStarNFT

/**
 * @title IStarNFT
 * @author Galaxy Protocol
 *
 * Interface for operating with StarNFTs.
 */
interface IStarNFT is IERC1155 {
    /* ============ Events =============== */
//    event PowahUpdated(uint256 indexed id, uint256 indexed oldPoints, uint256 indexed newPoints);

    /* ============ Functions ============ */

    function isOwnerOf(address, uint256) external view returns (bool);
//    function starInfo(uint256) external view returns (uint128 powah, uint128 mintBlock, address originator);
//    function quasarInfo(uint256) external view returns (uint128 mintBlock, IERC20 stakeToken, uint256 amount, uint256 campaignID);
//    function superInfo(uint256) external view returns (uint128 mintBlock, IERC20[] memory stakeToken, uint256[] memory amount, uint256 campaignID);

    // mint
    function mint(address account, uint256 powah) external returns (uint256);
    function mintBatch(address account, uint256 amount, uint256[] calldata powahArr) external returns (uint256[] memory);
    function burn(address account, uint256 id) external;
    function burnBatch(address account, uint256[] calldata ids) external;

    // asset-backing mint
//    function mintQuasar(address account, uint256 powah, uint256 cid, IERC20 stakeToken, uint256 amount) external returns (uint256);
//    function burnQuasar(address account, uint256 id) external;

    // asset-backing forge
//    function mintSuper(address account, uint256 powah, uint256 campaignID, IERC20[] calldata stakeTokens, uint256[] calldata amounts) external returns (uint256);
//    function burnSuper(address account, uint256 id) external;
    // update
//    function updatePowah(address owner, uint256 id, uint256 powah) external;
}

// File: SpaceStation.sol

/**
 * @title SpaceStation
 * @author Galaxy Protocol
 *
 * Campaign contract that allows privileged DAOs to initiate campaigns for members to claim StarNFTs.
 */
contract SpaceStation is ReentrancyGuard, EIP712 {
    using Address for address;
    using SafeMath for uint256;

    /* ============ Events ============ */
    event EventActivateCampaign(uint256 _cid);
    event EventActivateStakeCampaign(uint256 _cid);
    event EventExpireCampaign(uint256 _cid);
    event EventClaim(uint256 _cid, uint256 _dummyId, uint256 _nftID, address _sender);
    event EventClaimBatch(uint256 _cid, uint256[] _dummyIdArr, uint256[] _nftIDArr, address _sender);
    event EventStakeIn(uint256 _cid, address _sender, uint256 _stakeAmount, address _erc20);
    event EventStakeOut(address _starNFT, uint256 _nftID);
    event EventForgeNoStake(uint256 _cid, address _sender, address _starNFT, uint256[] _nftIDs);
    event EventForgeWithStake(uint256 _cid, address _sender, address _starNFT, uint256[] _nftIDs, uint256 _stakeAmount, address _erc20);

    /* ============ Modifiers ============ */
    /**
     * Throws if the address is not a validated starNFT contract
     */
    modifier onlyStarNFT(IStarNFT _starNFTAddress)  {
        require(_starNFTs[_starNFTAddress], "Invalid Star NFT contract address");
        _;
    }
    /**
     * Throws if the sender is not the manager
     */
    modifier onlyManager() {
        _validateOnlyManager();
        _;
    }
    /**
     * Throws if the sender is not the Treasury's manager
     */
    modifier onlyTreasuryManager() {
        _validateOnlyTreasuryManager();
        _;
    }
    /**
     * Throws if the contract paused
     */
    modifier onlyNoPaused() {
        _validateOnlyNotPaused();
        _;
    }

    /* ============ Enums ================ */

    // Operation a user could interact with Galaxy per campaign of DAO
    enum Operation {
        Default,
        Claim,
        StakeIn,
        StakeOut,
        Forge
    }

    /* ============ Structs ============ */

    struct CampaignStakeConfig {
        address erc20;                  // Address of token being staked
        uint256 minStakeAmount;         // Minimum amount of token to stake required, included
        uint256 maxStakeAmount;         // Maximum amount of token to stake required, included
        uint256 lockBlockNum;           // To indicate when token lock-up period is met
        bool burnRequired;              // Require NFT burnt if staked out
        bool isEarlyStakeOutAllowed;    // Whether early stake out is allowed or not
        uint256 earlyStakeOutFine;      // If early stake out is allowed, the applied penalty
    }

    struct CampaignFeeConfig {
        address erc20;                 // Address of token asset if required
        uint256 erc20Fee;              // Amount of token if required
        uint256 platformFee;           // Amount of fee for using the service if applicable
        bool isActive;                 // Indicate whether this campaign exists and is active
    }

    /* ============ State Variables ============ */

    // The manager which has privilege to add, remove starNFT address.
    address public manager;
    // Treasury manager which receives platform fee.
    address public treasury_manager;

    // Mapping that stores all stake requirement for a given activated campaign.
    mapping(uint256 => CampaignStakeConfig) public campaignStakeConfigs;

    // Mapping that stores all fee requirements per Operation for a given activated campaign.
    // If no fee is required at all, Operation(DEFAULT) should set to all zero values.
    // Operation(DEFAULT) should always exist.
    mapping(uint256 => mapping(Operation => CampaignFeeConfig)) public campaignFeeConfigs;

    // Set that contains all validated starNFT contract addresses
    mapping(IStarNFT => bool) private _starNFTs;

    // Mapping that records fees totals owned by galaxy-treasury,
    // Separate from escrow backed-asset from users.
    uint256 public galaxyTreasuryNetwork;
    mapping(address => uint256) public galaxyTreasuryERC20;
    // contract is initialized
    bool public initialized;
    // contract is paused
    bool public paused;

    // hasMinted(signature => bool) that records if the user account has already used the signature.
    mapping(uint256 => bool) public hasMinted;

    /* ============ Constructor ============ */

    constructor() {}

    function initialize(
        address _manager,
        address _treasury_manager
    ) external {
        require(!initialized, "Contract already initialized");
        if (_manager != address(0)) {
            manager = _manager;
        } else {
            // `manager` defaults to msg.sender on construction if no valid manager address passed in.
            manager = msg.sender;
        }
        if (_treasury_manager != address(0)) {
            treasury_manager = _treasury_manager;
        } else {
            // `treasury_manager` defaults to msg.sender on construction if no valid treasury_manager address passed in.
            treasury_manager = msg.sender;
        }

        initialized = true;
    }

    function initEIP712() public {
        super.initialize();
    }

    /* ============ External Functions ============ */

    function activateCampaign(
        uint256 _cid,
        Operation[] calldata _op,
        uint256[] calldata _platformFee,
        uint256[] calldata _erc20Fee,
        address[] calldata _erc20
    ) external onlyManager {
        _setFees(_cid, _op, _platformFee, _erc20Fee, _erc20);
        emit EventActivateCampaign(_cid);
    }

    /**
     * Expire a non-stake campaign. Those with asset-backed quasar_nft campaigns won't get touched.
     * NOTE: should only reset non-stake campaigns.
     */
    function expireCampaign(uint256 _cid, Operation[] calldata _op) external onlyManager {
        require(_op.length > 0, "Array(_op) should not be empty.");
        for (uint256 i = 0; i < _op.length; i++) {
            delete campaignFeeConfigs[_cid][_op[i]];
        }
        emit EventExpireCampaign(_cid);
    }


    //    /**
    //     * Activate a stake campaign.
    //     * @param _params bytes1: Bitwise params for stake requirements
    //     * {
    //     *   burnRequired,         // First bit, Require NFT burnt if staked out
    //     *   earlyStakeOutFine     // Second bit, Whether early stake out is allowed or not
    //     * }
    //     * 0b00000000 0x00  => false, false
    //     * 0b01000000 0x40  => false, true
    //     * 0b10000000 0x80  => true, false
    //     * 0b11000000 0xc0  => true, true
    //     */
    //    function activateStakeCampaign(
    //        uint256 _cid,
    //        address _stakeErc20,
    //        uint256 _minStakeAmount,
    //        uint256 _maxStakeAmount,
    //        uint256 _lockBlockNum,
    //        bytes1 _params,
    //        uint256 _earlyStakeOutFine,
    //        Operation[] calldata _op,
    //        uint256[] calldata _platformFee,
    //        uint256[] calldata _erc20Fee,
    //        address[] calldata _erc20
    //    ) external onlyManager {
    //        require(_stakeErc20 != address(0), "Stake Token must not be null address");
    //        require(_minStakeAmount > 0, "Min stake amount should be greater than 0 for stake campaign");
    //        require(_minStakeAmount <= _maxStakeAmount, "StakeAmount min should less than or equal to max");
    //
    //        _setFees(_cid, _op, _platformFee, _erc20Fee, _erc20);
    //
    //        _setStake(_cid, _stakeErc20, _minStakeAmount, _maxStakeAmount, _lockBlockNum, _params, _earlyStakeOutFine);
    //
    //        emit EventActivateStakeCampaign(_cid);
    //    }

    // TODO: add merkle proof and direct `Operation` support.

    function claim(uint256 _cid, IStarNFT _starNFT, uint256 _dummyId, uint256 _powah, bytes calldata _signature) external payable onlyNoPaused {
        require(!hasMinted[_dummyId], "Already minted");
        require(_verify(_hash(_starNFT, _dummyId, _powah, msg.sender), _signature), "Invalid signature");
        hasMinted[_dummyId] = true;
        _payFees(_cid, Operation.Claim);
        uint256 nftID = _starNFT.mint(msg.sender, _powah);
        emit EventClaim(_cid, _dummyId, nftID, msg.sender);
    }

    function claimBatch(uint256 _cid, IStarNFT _starNFT, uint256[] calldata _dummyIdArr, uint256[] calldata _powahArr, bytes calldata _signature) external payable onlyNoPaused {
        require(_dummyIdArr.length > 0, "Array(_dummyIdArr) should not be empty.");
        require(_powahArr.length == _dummyIdArr.length, "Array(_powahArr) length mismatch");

        for (uint i = 0; i < _dummyIdArr.length; i++) {
            require(!hasMinted[_dummyIdArr[i]], "Already minted");
            hasMinted[_dummyIdArr[i]] = true;
        }

        // { // scope to avoid stack too deep errors
        _payFees(_cid, Operation.Claim);
        require(_verify(_hashBatch(_starNFT, _dummyIdArr, _powahArr, msg.sender), _signature), "Invalid signature");
        uint256[] memory nftIdArr = _starNFT.mintBatch(msg.sender, _powahArr.length, _powahArr);
        emit EventClaimBatch(_cid, _dummyIdArr, nftIdArr, msg.sender);
        // }
    }

    //    function stakeIn(uint256 _cid, uint256 stakeAmount) external payable nonReentrant onlyNoPaused {
    //        _payFees(_cid, Operation.StakeIn);
    //        _stakeIn(_cid, stakeAmount);
    //        emit EventStakeIn(_cid, msg.sender, stakeAmount, campaignStakeConfigs[_cid].erc20);
    //    }
    //
    //    // CALL STAR_NFT*
    //    function stakeOutQuasar(IStarNFT _starNFT, uint256 _nftID) external payable onlyStarNFT(_starNFT) nonReentrant {
    //        require(_starNFT.isOwnerOf(msg.sender, _nftID), "Must be owner of this Quasar NFT");
    //        // 1.1 get info, make sure nft has backing-asset
    //        (uint256 _mintBlock, IERC20 _stakeToken, uint256 _amount, uint256 _cid) = _starNFT.quasarInfo(_nftID);
    //        require(address(_stakeToken) != address(0), "Backing-asset token must not be null address");
    //        require(_amount > 0, "Backing-asset amount must be greater than 0");
    //        // 2. check early stake out fine if applies
    //        _payFine(_cid, _mintBlock);
    //        // 3. pay fee
    //        _payFees(_cid, Operation.StakeOut);
    //        // 4. transfer back (backed asset)
    //        require(_stakeToken.transfer(msg.sender, _amount), "Stake out transfer assert back failed");
    //        // 5. postStakeOut (quasar->star nft; burn quasar)
    //        if (campaignStakeConfigs[_cid].burnRequired) {
    //            _starNFT.burn(msg.sender, _nftID);
    //        } else {
    //            _starNFT.burnQuasar(msg.sender, _nftID);
    //        }
    //        emit EventStakeOut(address(_starNFT), _nftID);
    //    }
    //
    //    function stakeOutSuper(IStarNFT _starNFT, uint256 _nftID) external payable onlyStarNFT(_starNFT) nonReentrant {
    //        require(_starNFT.isOwnerOf(msg.sender, _nftID), "Must be owner of this Super NFT");
    //        // 1.1 get info, make sure nft has backing-asset
    //        (uint256 _mintBlock, IERC20[] memory _stakeToken, uint256[] memory _amount, uint256 _cid) = IStarNFT(_starNFT).superInfo(_nftID);
    //        require(_stakeToken.length > 0, "Array(_stakeToken) should not be empty.");
    //        require(_stakeToken.length == _amount.length, "Array(_amount) length mismatch");
    //        // 2. check early stake out fine if applies
    //        _payFine(_cid, _mintBlock);
    //        // 3. pay fee
    //        _payFees(_cid, Operation.StakeOut);
    //        // 4. transfer back (backed asset)
    //        for (uint256 i = 0; i < _stakeToken.length; i++) {
    //            require(address(_stakeToken[i]) != address(0), "Backing-asset token must not be null address");
    //            require(_amount[i] > 0, "Backing-asset amount must be greater than 0");
    //            require(_stakeToken[i].transfer(msg.sender, _amount[i]), "Stake out transfer assert back failed");
    //        }
    //        // 5. postStakeOut (super->star nft; burn super)
    //        if (campaignStakeConfigs[_cid].burnRequired) {
    //            _starNFT.burn(msg.sender, _nftID);
    //        } else {
    //            _starNFT.burnSuper(msg.sender, _nftID);
    //        }
    //        emit EventStakeOut(address(_starNFT), _nftID);
    //    }

    //    function forgeNoStake(uint256 _cid, IStarNFT _starNFT, uint256[] calldata _nftIDs) external payable onlyStarNFT(_starNFT) nonReentrant onlyNoPaused {
    //        for (uint i = 0; i < _nftIDs.length; i++) {
    //            require(_starNFT.isOwnerOf(msg.sender, _nftIDs[i]), "Not the owner");
    //        }
    //        _payFees(_cid, Operation.Forge);
    //        _starNFT.burnBatch(msg.sender, _nftIDs);
    //        emit EventForgeNoStake(_cid, msg.sender, address(_starNFT), _nftIDs);
    //    }

    //    function forgeStake(uint256 _cid, IStarNFT _starNFT, uint256[] calldata _nftIDs, uint256 stakeAmount) external payable onlyStarNFT(_starNFT) nonReentrant onlyNoPaused {
    //        for (uint i = 0; i < _nftIDs.length; i++) {
    //            require(_starNFT.isOwnerOf(msg.sender, _nftIDs[i]), "Not the owner");
    //        }
    //        _payFees(_cid, Operation.Forge);
    //        _stakeIn(_cid, stakeAmount);
    //        _starNFT.burnBatch(msg.sender, _nftIDs);
    //        emit EventForgeWithStake(_cid, msg.sender, address(_starNFT), _nftIDs, stakeAmount, campaignStakeConfigs[_cid].erc20);
    //    }

    receive() external payable {}

    fallback() external payable {}

    function setPause(bool _paused) external onlyManager {
        paused = _paused;
    }

    /**
     * PRIVILEGED MODULE FUNCTION. Function that update manager address.
     */
    function updateManager(address newAddress) external onlyManager {
        require(newAddress != address(0), "Manager address must not be null address");
        manager = newAddress;
    }

    /**
     * PRIVILEGED MODULE FUNCTION. Function that update treasure manager address.
     */
    function updateTreasureManager(address payable newAddress) external onlyTreasuryManager {
        require(newAddress != address(0), "Treasure manager must not be null address");
        treasury_manager = newAddress;
    }

    /**
     * PRIVILEGED MODULE FUNCTION. Function that adds a validated starNFT address.
     */
    function addValidatedStarNFTAddress(IStarNFT _starNFT) external onlyManager {
        require(address(_starNFT) != address(0), "Validate StarNFT contract must not be null address");
        _starNFTs[_starNFT] = true;
    }
    /**
     * PRIVILEGED MODULE FUNCTION. Function that removes a validated starNFT address.
     */
    function removeValidatedStarNFTAddress(IStarNFT _starNFT) external onlyManager {
        require(address(_starNFT) != address(0), "Invalidate StarNFT contract must not be null address");
        _starNFTs[_starNFT] = false;
    }

    /**
     * PRIVILEGED MODULE FUNCTION. Function that withdraw fees[network] total owned by galaxy-treasury to manager.
     * TODO: delete me after withdraw all network fee
     */
    function networkWithdraw() external onlyTreasuryManager {
        // get the amount of Ether/BNB fees stored in this contract owned by galaxy-treasury
        uint256 amount = galaxyTreasuryNetwork;
        require(amount > 0, "Treasury of network should be greater than 0");

        // modify state first
        galaxyTreasuryNetwork = 0;
        // send Ether/BNB fees to manager
        // Manager can receive Ether/BNB since the address of manager is payable
        (bool success,) = manager.call{value : amount}("");
        require(success, "Failed to send Ether/BNB fees to treasury manager");
    }

    //    /**
    //     * PRIVILEGED MODULE FUNCTION. Function that withdraw fees[erc20] total owned by galaxy-treasury to manager.
    //     * TODO: delete me after withdraw all erc20 fee
    //     */
    //    function erc20Withdraw(address erc20) external onlyTreasuryManager nonReentrant {
    //        // get the amount of erc20 fees stored in this contract owned by galaxy-treasury
    //        uint256 amount = galaxyTreasuryERC20[erc20];
    //        require(amount > 0, "Treasury of ERC20 should be greater than 0");
    //
    //        // modify state first
    //        galaxyTreasuryERC20[erc20] = 0;
    //        // send erc20 fees to manager
    //        require(IERC20(erc20).transfer(manager, amount), "Failed to send Erc20 fees to treasury manager");
    //    }

    /**
      * @dev stake out quasar in emergency mode
      */
    //    function emergencyWithdrawQuasar(IStarNFT _starNFT, uint256 _nftID) external onlyStarNFT(_starNFT) nonReentrant {
    //        require(paused, "Not paused");
    //        require(_starNFT.isOwnerOf(msg.sender, _nftID), "Must be owner of this Quasar NFT");
    //        // 1.1 get info, make sure nft has backing-asset
    //        (uint256 _mintBlock, IERC20 _stakeToken, uint256 _amount, uint256 _cid) = _starNFT.quasarInfo(_nftID);
    //        require(address(_stakeToken) != address(0), "Backing-asset token must not be null address");
    //        require(_amount > 0, "Backing-asset amount must be greater than 0");
    //        // 4. transfer back (backed asset)
    //        require(_stakeToken.transfer(msg.sender, _amount), "Stake out transfer assert back failed");
    //        // 5. postStakeOut (quasar->star nft; burn quasar)
    //        if (campaignStakeConfigs[_cid].burnRequired) {
    //            _starNFT.burn(msg.sender, _nftID);
    //        } else {
    //            _starNFT.burnQuasar(msg.sender, _nftID);
    //        }
    //        emit EventStakeOut(address(_starNFT), _nftID);
    //    }

    /**
      * @dev stake out super in emergency mode
      */
    //    function emergencyWithdrawSuper(IStarNFT _starNFT, uint256 _nftID) external onlyStarNFT(_starNFT) nonReentrant {
    //        require(paused, "Not paused");
    //        require(_starNFT.isOwnerOf(msg.sender, _nftID), "Must be owner of this Super NFT");
    //        // 1.1 get info, make sure nft has backing-asset
    //        (uint256 _mintBlock, IERC20[] memory _stakeToken, uint256[] memory _amount, uint256 _cid) = IStarNFT(_starNFT).superInfo(_nftID);
    //        require(_stakeToken.length > 0, "Array(_stakeToken) should not be empty.");
    //        require(_stakeToken.length == _amount.length, "Array(_amount) length mismatch");
    //        // 4. transfer back (backed asset)
    //        for (uint256 i = 0; i < _stakeToken.length; i++) {
    //            require(address(_stakeToken[i]) != address(0), "Backing-asset token must not be null address");
    //            require(_amount[i] > 0, "Backing-asset amount must be greater than 0");
    //            require(_stakeToken[i].transfer(msg.sender, _amount[i]), "Stake out transfer assert back failed");
    //        }
    //        // 5. postStakeOut (super->star nft; burn super)
    //        if (campaignStakeConfigs[_cid].burnRequired) {
    //            _starNFT.burn(msg.sender, _nftID);
    //        } else {
    //            _starNFT.burnSuper(msg.sender, _nftID);
    //        }
    //        emit EventStakeOut(address(_starNFT), _nftID);
    //    }

    /* ============ External Getter Functions ============ */

    //    function stakeOutInfo(IStarNFT _starNFTAddress, uint256 _nft_id) external onlyStarNFT(_starNFTAddress) view returns (
    //        bool _allowStakeOut,
    //        uint256 _allowBlock,
    //        bool _requireBurn,
    //        uint256 _earlyStakeOutFine,
    //        uint256 _noFineBlock
    //    ) {
    //        (uint256 _createBlock, IERC20 _stakeToken, uint256 _amount, uint256 _cid) = _starNFTAddress.quasarInfo(_nft_id);
    //        if (address(_stakeToken) == address(0)) {
    //            // no asset
    //            return (false, 0, false, 0, 0);
    //        }
    //        _requireBurn = campaignStakeConfigs[_cid].burnRequired;
    //        //        uint256 lockBlockNum = campaignStakeConfigs[_cid].lockBlockNum;
    //        if (block.number >= campaignStakeConfigs[_cid].lockBlockNum.add(_createBlock)) {
    //            return (true, 0, _requireBurn, 0, 0);
    //        }
    //        _allowBlock = campaignStakeConfigs[_cid].lockBlockNum + _createBlock;
    //        if (!campaignStakeConfigs[_cid].isEarlyStakeOutAllowed) {
    //            // not allow early stakeout
    //            return (false, _allowBlock, _requireBurn, 0, 0);
    //        }
    //        _allowStakeOut = true;
    //        _allowBlock = _createBlock;
    //        _noFineBlock = _createBlock + campaignStakeConfigs[_cid].lockBlockNum;
    //        _earlyStakeOutFine = _noFineBlock
    //        .sub(block.number)
    //        .mul(10000)
    //        .mul(campaignStakeConfigs[_cid].earlyStakeOutFine)
    //        .div(campaignStakeConfigs[_cid].lockBlockNum)
    //        .div(10000);
    //    }
    //
    //    function superStakeOutInfo(IStarNFT _starNFTAddress, uint256 _nft_id) external onlyStarNFT(_starNFTAddress) view returns (
    //        bool _allowStakeOut,
    //        uint256 _allowBlock,
    //        bool _requireBurn,
    //        uint256 _earlyStakeOutFine,
    //        uint256 _noFineBlock
    //    ) {
    //        (uint256 _createBlock, IERC20[] memory _stakeToken, , uint256 _cid) = _starNFTAddress.superInfo(_nft_id);
    //        if (_stakeToken.length == 0) {
    //            // no asset
    //            return (false, 0, false, 0, 0);
    //        }
    //        _requireBurn = campaignStakeConfigs[_cid].burnRequired;
    //        //        uint256 lockBlockNum = campaignStakeConfigs[_cid].lockBlockNum;
    //        if (block.number >= campaignStakeConfigs[_cid].lockBlockNum.add(_createBlock)) {
    //            return (true, 0, _requireBurn, 0, 0);
    //        }
    //        _allowBlock = campaignStakeConfigs[_cid].lockBlockNum + _createBlock;
    //        if (!campaignStakeConfigs[_cid].isEarlyStakeOutAllowed) {
    //            // not allow early stakeout
    //            return (false, _allowBlock, _requireBurn, 0, 0);
    //        }
    //        _allowStakeOut = true;
    //        _allowBlock = _createBlock;
    //        _noFineBlock = _createBlock + campaignStakeConfigs[_cid].lockBlockNum;
    //        _earlyStakeOutFine = _noFineBlock
    //        .sub(block.number)
    //        .mul(10000)
    //        .mul(campaignStakeConfigs[_cid].earlyStakeOutFine)
    //        .div(campaignStakeConfigs[_cid].lockBlockNum)
    //        .div(10000);
    //    }

    function isValidatedStarNFTAddress(IStarNFT _starNFT) external returns (bool) {
        return _starNFTs[_starNFT];
    }

    /* ============ Internal Functions ============ */
    function _hash(IStarNFT _starNFT, uint256 _dummyId, uint256 _powah, address _account) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("NFT(address starNFT,uint256 dummyId,uint256 powah,address account)"),
                _starNFT, _dummyId, _powah, _account
            )));
    }

    function _hashBatch(IStarNFT _starNFT, uint256[] calldata _dummyIdArr, uint256[] calldata _powahArr, address _account) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("NFT(address starNFT,uint256[] dummyIdArr,uint256[] powahArr,address account)"),
                _starNFT, _dummyIdArr, _powahArr, _account
            )));
    }

    function _verify(bytes32 digest, bytes calldata signature) internal view returns (bool) {
        return ECDSA.recover(digest, signature) == manager;
    }

    //    // TODO: delete me, Only for sig testing purpose.
    //    function _verifyGetSigner(bytes32 digest, bytes calldata signature) public view returns (address, bool) {
    //        return (ECDSA.recover(digest, signature), ECDSA.recover(digest, signature) == manager);
    //    }
    //    function _setManagerForSigTest(address tmp) external {
    //        manager = tmp;
    //    }

    function _setFees(
        uint256 _cid,
        Operation[] calldata _op,
        uint256[] calldata _platformFee,
        uint256[] calldata _erc20Fee,
        address[] calldata _erc20
    ) private {
        require(_op.length > 0, "Array(_op) should not be empty.");
        // Don't use validate arrays because empty arrays are valid
        require(_op.length == _platformFee.length, "Array(_platformFee) length mismatch");
        require(_op.length == _erc20Fee.length, "Array(_erc20Fee) length mismatch");
        require(_op.length == _erc20.length, "Array(_erc20) length mismatch");

        for (uint256 i = 0; i < _op.length; i++) {
            require((_erc20[i] == address(0) && _erc20Fee[i] == 0) || (_erc20[i] != address(0) && _erc20Fee[i] != 0), "Invalid erc20 fee requirement arguments");
            campaignFeeConfigs[_cid][_op[i]] = CampaignFeeConfig(_erc20[i], _erc20Fee[i], _platformFee[i], true);
        }
    }

    //    function _setStake(
    //        uint256 _cid,
    //        address _erc20,
    //        uint256 _minStakeAmount,
    //        uint256 _maxStakeAmount,
    //        uint256 _lockBlockNum,
    //        bytes1 _params,
    //        uint256 _earlyStakeOutFine
    //    ) private {
    //        campaignStakeConfigs[_cid] = CampaignStakeConfig(
    //            _erc20,
    //            _minStakeAmount,
    //            _maxStakeAmount,
    //            _lockBlockNum,
    //            _params & bytes1(0x80) != 0,
    //            _params & bytes1(0x40) != 0,
    //            _earlyStakeOutFine
    //        );
    //    }

    function _payFees(uint256 _cid, Operation _op) private {
        require(campaignFeeConfigs[_cid][Operation.Default].isActive, "Operation(DEFAULT) should be activated");

        // 0. which fee record to use
        Operation op_key = campaignFeeConfigs[_cid][_op].isActive ? _op : Operation.Default;
        CampaignFeeConfig memory feeConf = campaignFeeConfigs[_cid][op_key];
        // 1. pay platformFee if needed
        if (feeConf.platformFee > 0) {
            (bool success,) = treasury_manager.call{value : feeConf.platformFee}(new bytes(0));
            require(success, 'Platform fee transfer failed');
        }
        // 2. pay erc20_fee if needed
        if (feeConf.erc20Fee > 0) {
            // user wallet transfer <erc20> of <feeConf.erc20Fee> to <this contract>.
            require(IERC20(feeConf.erc20).transferFrom(msg.sender, treasury_manager, feeConf.erc20Fee), "Transfer erc20_fee failed");
        }
    }

    //    function _payFine(uint256 _cid, uint256 _mintBlock) private {
    //        uint256 lockBlockNum = campaignStakeConfigs[_cid].lockBlockNum;
    //        // 1.2 only need to check early-stake-out config if lock up time has not been met yet
    //        if (block.number < _mintBlock + lockBlockNum) {
    //            require(campaignStakeConfigs[_cid].isEarlyStakeOutAllowed, "Early stake out not allowed");
    //            // calc fine if allow early stake out
    //            uint256 _fine = (_mintBlock + lockBlockNum)
    //            .sub(block.number)
    //            .mul(10000)
    //            .mul(campaignStakeConfigs[_cid].earlyStakeOutFine)
    //            .div(lockBlockNum)
    //            .div(10000);
    //            // Fine will be adding to treasury with platformFee in _payFees() if applies.
    //            // require(msg.value >= campaignFeeConfigs[_cid][Operation.StakeOut].platformFee.add(_fine), "Insufficient fine");
    //            // stakeOutQuasar and stakeOutSuper doesn't need pay network fee
    //            uint256 total = _fine.add(campaignFeeConfigs[_cid][Operation.StakeOut].platformFee);
    //            require(msg.value >= total, "Insufficient fine");
    //            // transfer fine and platform fee
    //            if (total > 0) {
    //                (bool success,) = treasury_manager.call{value : total}(new bytes(0));
    //                require(success, 'Platform fee and fine transfer failed');
    //            }
    //        }
    //    }

    //    function _stakeIn(uint256 _cid, uint256 stakeAmount) private {
    //        // Stake in if needed
    //        require(campaignStakeConfigs[_cid].erc20 != address(0), "Stake campaign should be activated");
    //        require(stakeAmount >= campaignStakeConfigs[_cid].minStakeAmount, "StakeAmount should >= minStakeAmount");
    //        require(stakeAmount <= campaignStakeConfigs[_cid].maxStakeAmount, "StakeAmount should <= maxStakeAmount");
    //        // transfer <erc20> of <stakeAmount> to <this contract> from user wallet.
    //        require(IERC20(campaignStakeConfigs[_cid].erc20).transferFrom(msg.sender, address(this), stakeAmount), "Stake in erc20 failed");
    //    }

    /**
     * Due to reason error bloat, internal functions are used to reduce bytecode size
     */
    function _validateOnlyManager() internal view {
        require(msg.sender == manager, "Only manager can call");
    }

    function _validateOnlyTreasuryManager() internal view {
        require(msg.sender == treasury_manager, "Only treasury manager can call");
    }

    function _validateOnlyNotPaused() internal view {
        require(!paused, "Contract paused");
    }
}