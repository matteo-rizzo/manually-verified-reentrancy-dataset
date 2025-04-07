/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;


// 
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// 
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


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


// 
contract ManagerRole is Context {
    using Roles for Roles.Role;

    event ManagerAdded(address indexed account);
    event ManagerRemoved(address indexed account);

    Roles.Role private _managers;

    constructor () internal {
        _addManager(_msgSender());
    }

    modifier onlyManager() {
        require(isManager(_msgSender()), "ManagerRole: caller does not have the Manager role");
        _;
    }

    function isManager(address account) public view returns (bool) {
        return _managers.has(account);
    }

    function addManager(address account) public onlyManager {
        _addManager(account);
    }

    function renounceManager() public {
        _removeManager(_msgSender());
    }

    function _addManager(address account) internal {
        _managers.add(account);
        emit ManagerAdded(account);
    }

    function _removeManager(address account) internal {
        _managers.remove(account);
        emit ManagerRemoved(account);
    }
}

// 


// 
/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


// 
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

// 
/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);

    function tokensOfOwner(address owner) external view returns (uint256[] memory);
}

// 
contract BooBankerProtocolAdapter is IProtocolAdapter, ManagerRole, Ownable {
    using SafeMath for uint256;

    // nft id => burn
    mapping(uint256 => uint256) public burnDivisor;
    // nft id => multiplier
    mapping(uint256 => uint256) public rewardsMultiplier;

    // NFT contract address
    IERC721Enumerable public nftAddress;

    // Token contract address - holding X of token grants a reduction of Y
    IERC20 public tokenAddress;

    // Must own minTokenHold quantity to receive minTokenHoldBurnDivisor or minTokenHoldRewardsMultiplierDivisor
    uint256 public minTokenHold;

    // Burn reduction for holding minTokenHold of tokenAddress
    uint256 public minTokenHoldBurnDivisor;

    // Farming rewards increase for holding minTokenHold of tokenAddress
    uint256 public minTokenHoldRewardsMultiplier;

    // Users can opt out
    mapping(address => bool) public userOptOut;

    constructor() public {}

    // Gets adapted burn divisor
    function getBurnDivisor(address _user, uint256 _currentBurnDivisor) external view override returns (uint256) {
        if (userOptOut[_user] || address(nftAddress) == address(0))
            return _currentBurnDivisor;

        uint256[] memory _tokenIds = nftAddress.tokensOfOwner(_user);
        if (_tokenIds.length != 0) {
            // pick last purchased nft
            _currentBurnDivisor = _currentBurnDivisor.add(burnDivisor[_tokenIds[_tokenIds.length - 1]]);
        }

        if (address(tokenAddress) != address(0) && tokenAddress.balanceOf(_user) >= minTokenHold) {
            // calculate burn reduction for holding token X
            _currentBurnDivisor = _currentBurnDivisor.add(minTokenHoldBurnDivisor);
        }

        return _currentBurnDivisor;
    }

    // Gets adapted farm rewards multiplier
    function getRewardsMultiplier(address _user, uint256 _currentRewardsMultiplier) external view override returns (uint256) {
        if (userOptOut[_user] || address(nftAddress) == address(0))
            return _currentRewardsMultiplier;

        uint256[] memory _tokenIds = nftAddress.tokensOfOwner(_user);
        if (_tokenIds.length != 0) {
            // pick last purchased nft
            _currentRewardsMultiplier = _currentRewardsMultiplier.add(rewardsMultiplier[_tokenIds[_tokenIds.length - 1]]);
        }

        if (address(tokenAddress) != address(0) && tokenAddress.balanceOf(_user) >= minTokenHold) {
            // calculate burn reduction for holding token X
            _currentRewardsMultiplier = _currentRewardsMultiplier.add(minTokenHoldRewardsMultiplier);
        }

        return _currentRewardsMultiplier;
    }

    // User can opt out of using nft adapters to save gas if they can't afford nfts
    function setUserOptOut(bool _opt) public {
        // set to true to Opt Out
        userOptOut[msg.sender] = _opt;
    }

    function setNft(IERC721Enumerable _nft) public onlyManager {
        // setting NFT address to 0x0 disables checks
        nftAddress = _nft;
    }

    function setBurnDivisor(uint256 _tokenId, uint256 _burnDivisor) public onlyManager {
        burnDivisor[_tokenId] = _burnDivisor;
    }

    function setRewardsMultiplier(uint256 _tokenId, uint256 _rewardsMultiplier) public onlyManager {
        rewardsMultiplier[_tokenId] = _rewardsMultiplier;
    }

    function setNftParams(uint256 _tokenId, uint256 _burnDivisor, uint256 _rewardsMultiplier) public onlyManager {
        burnDivisor[_tokenId] = _burnDivisor;
        rewardsMultiplier[_tokenId] = _rewardsMultiplier;
    }

    function setNftParamsRange(uint256 _startTokenId, uint256 _endTokenId, uint256 _burnDivisor, uint256 _rewardsMultiplier) public onlyManager {
        require(
            _endTokenId > _startTokenId,
            "endTokenId must be greater than startTokenId"
        );

        for(uint256 i = _startTokenId; i <= _endTokenId; i++) {
            burnDivisor[i] = _burnDivisor;
            rewardsMultiplier[i] = _rewardsMultiplier;
        }
    }

    function setTokenAdapterAddress(IERC20 _token) public onlyManager {
        // setting _token to address(0) disables the modifiers
        tokenAddress = _token;
    }

    function setTokenAdapter(IERC20 _token, uint256 _minHold, uint256 _burnDivisor, uint256 _rewardsMultiplier) public onlyManager {
        setTokenAdapterAddress(_token);
        setTokenMinHold(_minHold);
        setTokenBurnDivisor(_burnDivisor);
        setTokenRewardsMultiplier(_rewardsMultiplier);
    }

    function setTokenMinHold(uint256 _minHold) public onlyManager {
        minTokenHold = _minHold;
    }

    function setTokenBurnDivisor(uint256 _burnDivisor) public onlyManager {
        minTokenHoldBurnDivisor = _burnDivisor;
    }

    function setTokenRewardsMultiplier(uint256 _rewardsMultiplier) public onlyManager {
        minTokenHoldRewardsMultiplier = _rewardsMultiplier;
    }
}