/**
 *Submitted for verification at Etherscan.io on 2020-10-24
*/

// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: @openzeppelin/contracts/introspection/IERC165.sol


// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */



// Dependency file: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/introspection/IERC165.sol";

/**
 * _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {

    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}


// Dependency file: @openzeppelin/contracts/introspection/ERC165.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/introspection/IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


// Dependency file: @openzeppelin/contracts/token/ERC1155/ERC1155Receiver.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
// import "@openzeppelin/contracts/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() public {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}


// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


// pragma solidity ^0.6.0;

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



// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: @openzeppelin/contracts/utils/EnumerableSet.sol


// pragma solidity ^0.6.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */



// Dependency file: @openzeppelin/contracts/GSN/Context.sol


// pragma solidity ^0.6.0;

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


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/GSN/Context.sol";
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


// Dependency file: contracts/interfaces/IAlpaToken.sol


// pragma solidity 0.6.12;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IAlpaToken is IERC20 {
    function mint(address _to, uint256 _amount) external;
}


// Dependency file: @openzeppelin/contracts/token/ERC1155/IERC1155.sol


// pragma solidity ^0.6.2;

// import "@openzeppelin/contracts/introspection/IERC165.sol";

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


// Dependency file: contracts/interfaces/ICryptoAlpaca.sol


// pragma solidity =0.6.12;

// import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface ICryptoAlpaca is IERC1155 {
    function getAlpaca(uint256 _id)
        external
        view
        returns (
            uint256 id,
            bool isReady,
            uint256 cooldownEndBlock,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 hatchingCost,
            uint256 hatchingCostMultiplier,
            uint256 hatchCostMultiplierEndBlock,
            uint256 generation,
            uint256 gene,
            uint256 energy,
            uint256 state
        );

    function hasPermissionToBreedAsSire(address _addr, uint256 _id)
        external
        view
        returns (bool);

    function grandPermissionToBreed(address _addr, uint256 _sireId) external;

    function clearPermissionToBreed(uint256 _alpacaId) external;

    function hatch(uint256 _matronId, uint256 _sireId)
        external
        payable
        returns (uint256);

    function crack(uint256 _id) external;
}


// Root file: contracts/MasterChef/MasterChef.sol


pragma solidity 0.6.12;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC1155/ERC1155Receiver.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/utils/EnumerableSet.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "contracts/interfaces/IAlpaToken.sol";
// import "contracts/interfaces/ICryptoAlpaca.sol";

// MasterChef is the master of ALPA.
contract MasterChef is Ownable, ERC1155Receiver {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== EVENTS ========== */

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);

    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    /* ========== STRUCT ========== */

    // Info of each user.
    struct UserInfo {
        // How many LP tokens the user has provided.
        uint256 amount;
        // Reward debt. What have been paid so far
        uint256 rewardDebt;
    }

    struct UserGlobalInfo {
        // alpaca associated
        uint256 alpacaID;
        // alpaca energy
        uint256 alpacaEnergy;
    }

    // Info of each pool.
    struct PoolInfo {
        // Address of LP token contract.
        IERC20 lpToken;
        // How many allocation points assigned to this pool. ALPAs to distribute per block.
        uint256 allocPoint;
        // Last block number that ALPAs distribution occurs.
        uint256 lastRewardBlock;
        // Accumulated ALPAs per share per energy, times SAFE_MULTIPLIER. See below.
        uint256 accAlpaPerShare;
        // Accumulated Share
        uint256 accShare;
    }

    /* ========== STATES ========== */

    // The ALPA ERC20 token
    IAlpaToken public alpa;

    // Crypto alpaca contract
    ICryptoAlpaca public cryptoAlpaca;

    // dev address.
    address public devaddr;

    // number of ALPA tokens created per block.
    uint256 public alpaPerBlock;

    // Energy if user does not have any alpaca that boost the LP pool
    uint256 public constant EMPTY_ALPACA_ENERGY = 1;

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    // Info of each user that stakes LP tokens.
    mapping(address => UserGlobalInfo) public userGlobalInfo;

    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;

    // The block number when ALPA mining starts.
    uint256 public startBlock;

    uint256 private constant SAFE_MULTIPLIER = 1e16;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        IAlpaToken _alpa,
        ICryptoAlpaca _cryptoAlpaca,
        address _devaddr,
        uint256 _alpaPerBlock,
        uint256 _startBlock
    ) public {
        alpa = _alpa;
        cryptoAlpaca = _cryptoAlpaca;
        devaddr = _devaddr;
        alpaPerBlock = _alpaPerBlock;
        startBlock = _startBlock;
    }

    /* ========== PUBLIC ========== */

    /**
     * @dev get number of LP pools
     */
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    /**
     * @dev Add a new lp to the pool. Can only be called by the owner.
     * DO NOT add the same LP token more than once. Rewards will be messed up if you do.
     */
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accAlpaPerShare: 0,
                accShare: 0
            })
        );
    }

    /**
     * @dev Update the given pool's ALPA allocation point. Can only be called by the owner.
     */
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    /**
     * @dev View `_user` pending ALPAs for a given `_pid` LP pool.
     */
    function pendingAlpa(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        UserGlobalInfo storage userGlobal = userGlobalInfo[msg.sender];

        uint256 accAlpaPerShare = pool.accAlpaPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = _getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 alpaReward = multiplier
                .mul(alpaPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint);

            accAlpaPerShare = accAlpaPerShare.add(
                alpaReward.mul(SAFE_MULTIPLIER).div(pool.accShare)
            );
        }
        return
            user
                .amount
                .mul(_safeUserAlpacaEnergy(userGlobal))
                .mul(accAlpaPerShare)
                .div(SAFE_MULTIPLIER)
                .sub(user.rewardDebt);
    }

    /**
     * @dev Update reward variables for all pools. Be careful of gas spending!
     */
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    /**
     * @dev Update reward variables of the given pool to be up-to-date.
     */
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(pool.lastRewardBlock, block.number);
        uint256 alpaReward = multiplier
            .mul(alpaPerBlock)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);

        alpa.mint(devaddr, alpaReward.div(10));
        alpa.mint(address(this), alpaReward);

        pool.accAlpaPerShare = pool.accAlpaPerShare.add(
            alpaReward.mul(SAFE_MULTIPLIER).div(pool.accShare)
        );
        pool.lastRewardBlock = block.number;
    }

    /**
     * @dev Retrieve caller's Alpaca.
     */
    function retrieve() public {
        UserGlobalInfo storage userGlobal = userGlobalInfo[msg.sender];
        require(
            userGlobal.alpacaID != 0,
            "MasterChef: you do not have any alpaca"
        );

        for (uint256 pid = 0; pid < poolInfo.length; pid++) {
            UserInfo storage user = userInfo[pid][msg.sender];

            if (user.amount > 0) {
                PoolInfo storage pool = poolInfo[pid];
                updatePool(pid);
                uint256 pending = user
                    .amount
                    .mul(userGlobal.alpacaEnergy)
                    .mul(pool.accAlpaPerShare)
                    .div(SAFE_MULTIPLIER)
                    .sub(user.rewardDebt);
                if (pending > 0) {
                    _safeAlpaTransfer(msg.sender, pending);
                }

                user.rewardDebt = user
                    .amount
                    .mul(EMPTY_ALPACA_ENERGY)
                    .mul(pool.accAlpaPerShare)
                    .div(SAFE_MULTIPLIER);

                pool.accShare = pool.accShare.sub(
                    (userGlobal.alpacaEnergy.sub(1)).mul(user.amount)
                );
            }
        }
        uint256 prevAlpacaID = userGlobal.alpacaID;
        userGlobal.alpacaID = 0;
        userGlobal.alpacaEnergy = 0;

        cryptoAlpaca.safeTransferFrom(
            address(this),
            msg.sender,
            prevAlpacaID,
            1,
            ""
        );
    }

    /**
     * @dev Deposit LP tokens to MasterChef for ALPA allocation.
     */
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        UserGlobalInfo storage userGlobal = userGlobalInfo[msg.sender];
        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(_safeUserAlpacaEnergy(userGlobal))
                .mul(pool.accAlpaPerShare)
                .div(SAFE_MULTIPLIER)
                .sub(user.rewardDebt);
            if (pending > 0) {
                _safeAlpaTransfer(msg.sender, pending);
            }
        }

        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
            pool.accShare = pool.accShare.add(
                _safeUserAlpacaEnergy(userGlobal).mul(_amount)
            );
        }

        user.rewardDebt = user
            .amount
            .mul(_safeUserAlpacaEnergy(userGlobal))
            .mul(pool.accAlpaPerShare)
            .div(SAFE_MULTIPLIER);
        emit Deposit(msg.sender, _pid, _amount);
    }

    /**
     * @dev Withdraw LP tokens from MasterChef.
     */
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "MasterChef: invalid amount");

        UserGlobalInfo storage userGlobal = userGlobalInfo[msg.sender];

        updatePool(_pid);
        uint256 pending = user
            .amount
            .mul(_safeUserAlpacaEnergy(userGlobal))
            .mul(pool.accAlpaPerShare)
            .div(SAFE_MULTIPLIER)
            .sub(user.rewardDebt);
        if (pending > 0) {
            _safeAlpaTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            pool.accShare = pool.accShare.sub(
                _safeUserAlpacaEnergy(userGlobal).mul(_amount)
            );
        }

        user.rewardDebt = user
            .amount
            .mul(_safeUserAlpacaEnergy(userGlobal))
            .mul(pool.accAlpaPerShare)
            .div(SAFE_MULTIPLIER);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    /* ========== PRIVATE ========== */

    function _safeUserAlpacaEnergy(UserGlobalInfo storage userGlobal)
        private
        view
        returns (uint256)
    {
        if (userGlobal.alpacaEnergy == 0) {
            return EMPTY_ALPACA_ENERGY;
        }
        return userGlobal.alpacaEnergy;
    }

    // Safe alpa transfer function, just in case if rounding error causes pool to not have enough ALPAs.
    function _safeAlpaTransfer(address _to, uint256 _amount) private {
        uint256 alpaBal = alpa.balanceOf(address(this));
        if (_amount > alpaBal) {
            alpa.transfer(_to, alpaBal);
        } else {
            alpa.transfer(_to, _amount);
        }
    }

    // Return reward multiplier over the given _from to _to block.
    function _getMultiplier(uint256 _from, uint256 _to)
        private
        pure
        returns (uint256)
    {
        return _to.sub(_from);
    }

    /* ========== EXTERNAL DEV MUTATION ========== */

    // Update dev address by the previous dev.
    function setDev(address _devaddr) external onlyDev {
        devaddr = _devaddr;
    }

    /* ========== EXTERNAL OWNER MUTATION ========== */

    // Update number of ALPA to mint per block
    function setAlpaPerBlock(uint256 _alpaPerBlock) external onlyOwner {
        alpaPerBlock = _alpaPerBlock;
    }

    /* ========== ERC1155Receiver ========== */

    /**
     * @dev onERC1155Received implementation per IERC1155Receiver spec
     */
    function onERC1155Received(
        address,
        address _from,
        uint256 _id,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        require(
            msg.sender == address(cryptoAlpaca),
            "MasterChef: received alpaca from unauthenticated contract"
        );

        require(_id != 0, "MasterChef: invalid alpaca");

        UserGlobalInfo storage userGlobal = userGlobalInfo[_from];

        // Fetch alpaca energy
        (, , , , , , , , , , , uint256 energy, ) = cryptoAlpaca.getAlpaca(_id);
        require(energy > 0, "MasterChef: invalid alpaca energy");

        for (uint256 i = 0; i < poolInfo.length; i++) {
            UserInfo storage user = userInfo[i][_from];

            if (user.amount > 0) {
                PoolInfo storage pool = poolInfo[i];
                updatePool(i);

                uint256 pending = user
                    .amount
                    .mul(_safeUserAlpacaEnergy(userGlobal))
                    .mul(pool.accAlpaPerShare)
                    .div(SAFE_MULTIPLIER)
                    .sub(user.rewardDebt);
                if (pending > 0) {
                    _safeAlpaTransfer(_from, pending);
                }
                // Update user reward debt with new energy
                user.rewardDebt = user
                    .amount
                    .mul(energy)
                    .mul(pool.accAlpaPerShare)
                    .div(SAFE_MULTIPLIER);

                pool.accShare = pool.accShare.add(energy.mul(user.amount)).sub(
                    _safeUserAlpacaEnergy(userGlobal).mul(user.amount)
                );
            }
        }

        // update user global
        uint256 prevAlpacaID = userGlobal.alpacaID;
        userGlobal.alpacaID = _id;
        userGlobal.alpacaEnergy = energy;

        // Give original owner the right to breed
        cryptoAlpaca.grandPermissionToBreed(_from, _id);

        if (prevAlpacaID != 0) {
            // Transfer alpaca back to owner
            cryptoAlpaca.safeTransferFrom(
                address(this),
                _from,
                prevAlpacaID,
                1,
                ""
            );
        }

        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    /**
     * @dev onERC1155BatchReceived implementation per IERC1155Receiver spec
     * User should not send using batch.
     */
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) external override returns (bytes4) {
        return "";
    }

    /* ========== MODIFIER ========== */

    modifier onlyDev() {
        require(devaddr == _msgSender(), "Masterchef: caller is not the dev");
        _;
    }
}