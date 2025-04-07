/**
 *Submitted for verification at Etherscan.io on 2021-09-19
*/

// SPDX-License-Identifier: AGPL V3.0

pragma solidity 0.8.0;
pragma abicoder v2;



// Part: ILWXP



// Part: ILoot



// Part: ILootStats



// Part: IUpgradeCalculator



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/Context

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// Part: OpenZeppelin/[email protected]/IERC165

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/IERC721Receiver

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */


// Part: OpenZeppelin/[email protected]/ReentrancyGuard

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

    constructor () {
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

// Part: OpenZeppelin/[email protected]/ERC721Holder

/**
   * @dev Implementation of the {IERC721Receiver} interface.
   *
   * Accepts all token transfers.
   * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
   */
contract ERC721Holder is IERC721Receiver {

    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// Part: OpenZeppelin/[email protected]/IERC721

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

// Part: OpenZeppelin/[email protected]/Ownable

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: Smith.sol

/**
 * @title  Smith
 * @notice The Smith is open. Looters, prepare to fight, visit the smith and upgrade your loot with LWXP and Time.
 */
contract Smith is ReentrancyGuard, Ownable, ERC721Holder{
    using SafeERC20 for IERC20;
    // OG loot contract
    ILoot loot = ILoot(0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7);
    // Token used as the trade in for the LootSmith
    IERC20 public lwxp = IERC20(0xf18eC76f918A89a5d790E7150DD468D750a5c4e8);
    // whether the lootSmith is open
    bool smithOpen = true;
    address lootV1WeaponContract = 0x0ac0ECc6D249F1383c5C7c2Ff4941Bd56DEcDd14;
    address lootV2WeaponContract;
    IUpgradeCalculator public upgradeCalculator;
    mapping(address => mapping(uint256 => SmithsLog)) public smithsLogs;
    mapping(address => bool) public lootEcosystemContracts;
    uint256 public wait;
    uint256 public cap;

    struct SmithsLog{
        bool isUpgrading;
        uint256 startTimestamp;
        uint256 duration;
        uint256 endTimestamp;
        uint256 xpAmount;
    }

    event TokenUpdated(
        address oldToken,
        address newToken
    );
    event Upgrade(
        uint256 tokenId,
        uint256 upgradeAmount
    );
    event SmithOpened(
        bool open
    );
    event LootEcosystemContractSet(
        address lootContract
    );
    event SmithsLogsUpdated(
        uint256 tokenId,
        address lootContractAddress,
        uint256 startTimestamp,
        uint256 duration,
        uint256 endTimestamp,
        uint256 amount
    );
    event WaitChanged(
        uint256 wait
    );

    /**
     * @notice allow the owners to set the tokens used as pay-in for the weaponSmith
     * @param  _token address of the new token
     */
    function setToken(address _token) external onlyOwner {
        emit TokenUpdated(address(lwxp), _token);
        lwxp = IERC20(_token);
    }

    /**
     * @notice allow the owners to open the smith
     * @param  _smithOpen bool to open or close the smith
     */
    function setSmithOpen(bool _smithOpen) external onlyOwner {
        emit SmithOpened(_smithOpen);
        smithOpen = _smithOpen;
    }

    function setLootV2WeaponContract(address _lootWeaponContract) external onlyOwner {
        lootV2WeaponContract = _lootWeaponContract;
    }

    function setCap(uint256 _cap) external onlyOwner {
        cap = _cap;
    }

    function setLootEcosystemContract(address _lootContract) external onlyOwner {
        emit LootEcosystemContractSet(_lootContract);
        lootEcosystemContracts[_lootContract] = true;
    }

    /**
     * @notice allow the owners to change the wait time
     * @param  _wait number to change the wait to
     */
    function setWait(uint256 _wait) external onlyOwner {
        emit WaitChanged(_wait);
        wait = _wait;
    }

    function setUpgradeCalculator(address _upgradeCalculator) external onlyOwner {
        upgradeCalculator = IUpgradeCalculator(_upgradeCalculator);
    }

    /**
     * @notice allow the owners to sweep any erc20 tokens sent to the contract
     * @param  _token address of the token to be swept
     * @param  _amount amount to be swept
     */
    function sweep(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }

    function upgrade(
        uint256 tokenId,
        address lootContractAddress,
        uint256 amount
    )
    external
    nonReentrant
    {
        require(smithOpen, "!smithOpen");
        require(lootEcosystemContracts[lootContractAddress], "Not a recognised loot contract");
        require(IERC721(lootContractAddress).ownerOf(tokenId) == msg.sender, "!owner");
        require(amount > 0, "!amount");
        require(amount <= cap, "amount above cap");
        require(!smithsLogs[lootContractAddress][tokenId].isUpgrading, "Loot already upgrading");

        lwxp.safeTransferFrom(msg.sender, address(this), amount);
        if (lootContractAddress == lootV1WeaponContract) {
            IERC721(lootContractAddress).safeTransferFrom(msg.sender, address(this), tokenId);
            if (!ILWXP(address(lwxp)).claimedByTokenId(tokenId)){
                ILWXP(address(lwxp)).claimById(tokenId);
                lwxp.safeTransfer(msg.sender, 100000e18);
            }
            ILootStats(lootV2WeaponContract).mintFromSmith(tokenId, msg.sender);
            lootContractAddress = lootV2WeaponContract;
        }
        smithsLogs[lootContractAddress][tokenId] =
        SmithsLog(
            {
            isUpgrading: true,
            startTimestamp: block.timestamp,
            duration: wait,
            endTimestamp: block.timestamp + wait,
            xpAmount: amount
            }
        );
        emit SmithsLogsUpdated(tokenId, lootContractAddress, block.timestamp, wait, block.timestamp + wait, amount);
    }

    function collect(uint256 tokenId, address lootContractAddress) external nonReentrant {
        require(IERC721(lootContractAddress).ownerOf(tokenId) == msg.sender, "!owner");
        SmithsLog memory smithsLog = smithsLogs[lootContractAddress][tokenId];
        require(smithsLog.isUpgrading, "Loot not upgrading");
        require(smithsLog.endTimestamp < block.timestamp, "Loot not upgraded yet");
        uint256 boostAmount = upgradeCalculator.calculateUpgrade(
                    smithsLog.duration,
                    smithsLog.xpAmount,
                    ILootStats(lootV2WeaponContract).getTotalPower(tokenId)
        );
        smithsLogs[lootContractAddress][tokenId].isUpgrading = false;
        ILootStats(lootContractAddress).smithUpgrade(tokenId, boostAmount);
    }

    constructor(address _upgradeCalculator, address lootWeaponV2, address lootWeaponV1) Ownable() {
        wait = 7200;
        cap = 500000e18;
        upgradeCalculator = IUpgradeCalculator(_upgradeCalculator);
        lootV2WeaponContract = lootWeaponV2;
        lootEcosystemContracts[lootWeaponV2] = true;
        lootEcosystemContracts[lootWeaponV1] = true;
    }

}