/**
 *Submitted for verification at Etherscan.io on 2021-06-02
*/

/*
 * Crypto stamp Bridge Data
 * Holding all data that is used across the bridge and connected contracts
 *
 * Developed by Capacity Blockchain Solutions GmbH <capacity.at>
 * for Ã–sterreichische Post AG <post.at>
 *
 * Any usage of or interaction with this set of contracts is subject to the
 * Terms & Conditions available at https://crypto.post.at/
 */

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

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

// File: contracts/ENSReverseRegistrarI.sol

/*
 * Interfaces for ENS Reverse Registrar
 * See https://github.com/ensdomains/ens/blob/master/contracts/ReverseRegistrar.sol for full impl
 * Also see https://github.com/wealdtech/wealdtech-solidity/blob/master/contracts/ens/ENSReverseRegister.sol
 *
 * Use this as follows (registryAddress is the address of the ENS registry to use):
 * -----
 * // This hex value is caclulated by namehash('addr.reverse')
 * bytes32 public constant ENS_ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;
 * function registerReverseENS(address registryAddress, string memory calldata) external {
 *     require(registryAddress != address(0), "need a valid registry");
 *     address reverseRegistrarAddress = ENSRegistryOwnerI(registryAddress).owner(ENS_ADDR_REVERSE_NODE)
 *     require(reverseRegistrarAddress != address(0), "need a valid reverse registrar");
 *     ENSReverseRegistrarI(reverseRegistrarAddress).setName(name);
 * }
 * -----
 * or
 * -----
 * function registerReverseENS(address reverseRegistrarAddress, string memory calldata) external {
 *    require(reverseRegistrarAddress != address(0), "need a valid reverse registrar");
 *     ENSReverseRegistrarI(reverseRegistrarAddress).setName(name);
 * }
 * -----
 * ENS deployments can be found at https://docs.ens.domains/ens-deployments
 * E.g. Etherscan can be used to look up that owner on those contracts.
 * namehash.hash("addr.reverse") == "0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2"
 * Ropsten: ens.owner(namehash.hash("addr.reverse")) == "0x6F628b68b30Dc3c17f345c9dbBb1E483c2b7aE5c"
 * Mainnet: ens.owner(namehash.hash("addr.reverse")) == "0x084b1c3C81545d370f3634392De611CaaBFf8148"
 */





// File: contracts/BridgeDataI.sol

/*
 * Interface for data storage of the bridge.
 */



// File: contracts/BridgeData.sol

/*
 * Implements a data storage for the bridge.
 * Mostly used to storage addresses for various contracts in a common place
 * that all contracts can access, but also some other data commonly shared
 * between bridge-related contracts.
 * Liberally based on Optimistic Ethereum Lib_AddressManager.sol
 */





contract BridgeData is BridgeDataI {
    // Chain names
    string public override connectedChainName;
    string public override ownChainName;
    // Base for token URIs
    string public override tokenURIBase;

    // Token sunset
    uint256 public override tokenSunsetTimestamp;
    uint256 public immutable sunsetDelay;

    // Various addresses, accessed via a name hash.
    mapping (bytes32 => address) private addresses;

    constructor(string memory _connectedChainName, string memory _ownChainName, string memory _tokenURIBase, uint256 _sunsetDelay, address _tokenAssignmentControl)
    {
        // During the deployment phase, set bridgeControl to deployer,
        // at the end of deployment, switch to actual bridgeControl address.
        _setAddress("bridgeControl", msg.sender);
        _setAddress("tokenAssignmentControl", _tokenAssignmentControl);
        sunsetDelay = _sunsetDelay;
        connectedChainName = _connectedChainName;
        ownChainName = _ownChainName;
        tokenURIBase = _tokenURIBase;
    }

    modifier onlyBridgeControl()
    {
        require(msg.sender == getAddress("bridgeControl"), "bridgeControl key required for this function.");
        _;
    }

    modifier onlyBridge()
    {
        require(msg.sender == getAddress("bridgeControl") || msg.sender == getAddress("bridgeHead"), "bridgeControl key or bridge head required for this function.");
        _;
    }

    modifier onlyTokenAssignmentControl() {
        require(msg.sender == getAddress("tokenAssignmentControl"), "tokenAssignmentControl key required for this function.");
        _;
    }

    /*** Enable adjusting variables after deployment ***/

    function setConnectedChain(string memory _newConnectedChainName)
    external
    onlyBridgeControl
    {
        require(bytes(_newConnectedChainName).length > 0, "You need to provide an actual chain name string.");
        emit ConnectedChainChanged(connectedChainName, _newConnectedChainName);
        connectedChainName = _newConnectedChainName;
    }

    function setTokenURIBase(string memory _newTokenURIBase)
    external
    onlyBridgeControl
    {
        require(bytes(_newTokenURIBase).length > 0, "You need to provide an actual token URI base string.");
        emit TokenURIBaseChanged(tokenURIBase, _newTokenURIBase);
        tokenURIBase = _newTokenURIBase;
    }

    // Set a sunset timestamp for bridged tokens. All transfers will be disabled after that.
    // The timestamp has to be at least a delay duration in the future when not yet set.
    // Once set, it can be pushed to the further future at any rate with no addittive delay.
    // It also can be set to 0 at any point in time, which disables the sunset.
    function setTokenSunsetTimestamp(uint256 _timestamp)
    public override
    onlyBridge
    {
        require(_timestamp == 0 || _timestamp >= block.timestamp + sunsetDelay ||
                (tokenSunsetTimestamp > 0 && _timestamp >= tokenSunsetTimestamp && _timestamp >= block.timestamp),
                "Sunset needs to be 0 or (enough) in the future.");
        tokenSunsetTimestamp = _timestamp;
        emit TokenSunsetAnnounced(_timestamp);
    }

    function setAddress(string memory _name, address _newAddress)
    public override
    onlyBridge
    {
        _setAddress(_name, _newAddress);
    }

    function _setAddress(string memory _name, address _newAddress)
    internal
    {
        bytes32 nameHash = _getNameHash(_name);
        require(_newAddress != address(0) || nameHash != _getNameHash("bridgeControl"), "bridgeControl cannot be the zero address.");
        emit AddressChanged(_name, addresses[nameHash], _newAddress);
        addresses[nameHash] = _newAddress;
    }

    function getAddress(string memory _name)
    public view override
    returns (address)
    {
        return addresses[_getNameHash(_name)];
    }

    function _getNameHash(string memory _name)
    internal pure
    returns (bytes32 _hash)
    {
        return keccak256(abi.encodePacked(_name));
    }

    /*** Enable reverse ENS registration ***/

    // Call this with the address of the reverse registrar for the respective network and the ENS name to register.
    // The reverse registrar can be found as the owner of 'addr.reverse' in the ENS system.
    // For Mainnet, the address needed is 0x9062c0a6dbd6108336bcbe4593a3d1ce05512069
    function registerReverseENS(address _reverseRegistrarAddress, string calldata _name)
    external
    onlyTokenAssignmentControl
    {
        require(_reverseRegistrarAddress != address(0), "need a valid reverse registrar");
        ENSReverseRegistrarI(_reverseRegistrarAddress).setName(_name);
    }

    /*** Make sure currency or NFT doesn't get stranded in this contract ***/

    // If this contract gets a balance in some ERC20 contract after it's finished, then we can rescue it.
    function rescueToken(address _foreignToken, address _to)
    external
    onlyTokenAssignmentControl
    {
        IERC20 erc20Token = IERC20(_foreignToken);
        erc20Token.transfer(_to, erc20Token.balanceOf(address(this)));
    }

    // If this contract gets a balance in some ERC721 contract after it's finished, then we can rescue it.
    function approveNFTrescue(IERC721 _foreignNFT, address _to)
    external
    onlyTokenAssignmentControl
    {
        _foreignNFT.setApprovalForAll(_to, true);
    }

}