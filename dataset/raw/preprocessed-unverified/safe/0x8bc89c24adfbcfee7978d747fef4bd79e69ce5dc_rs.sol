/**
 *Submitted for verification at Etherscan.io on 2021-02-09
*/

pragma solidity >=0.5.0;


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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context, PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

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
 *
 * _Since v2.5.0:_ this module is now much more gas efficient, given net gas
 * metering changes introduced in the Istanbul hardfork.
 */
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
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
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract LORTokenWrapper {
	using SafeMath for uint256;
	using SafeERC20 for IERC20;

	IERC20 public lorToken;

	uint256 private _totalSupply;
	// Objects balances [id][address] => balance
	mapping(uint256 => mapping(address => uint256)) internal _balances;
	mapping(uint256 => uint256) private _totalDeposits;

	function totalSupply() public view returns (uint256) {
		return _totalSupply;
	}

	function totalDeposits(uint256 id) public view returns (uint256) {
		return _totalDeposits[id];
	}

	function balanceOf(address account, uint256 id) public view returns (uint256) {
		return _balances[id][account];
	}

	function deposit(uint256 id, uint256 amount) public {
		_totalSupply = _totalSupply.add(amount);
		_totalDeposits[id] = _totalDeposits[id].add(amount);
		_balances[id][msg.sender] = _balances[id][msg.sender].add(amount);
		lorToken.transferFrom(msg.sender, address(this), amount);
	}

	function withdraw(uint256 id, uint256 amount) public {
		_totalSupply = _totalSupply.sub(amount);
		_totalDeposits[id] = _totalDeposits[id].sub(amount);
		_balances[id][msg.sender] = _balances[id][msg.sender].sub(amount);
		lorToken.transfer(msg.sender, amount);
	}

	function claim(uint256 id, address account) internal {
		uint256 amount = balanceOf(account, id);
		_totalSupply = _totalSupply.sub(amount);
		_totalDeposits[id] = _totalDeposits[id].sub(amount);
		_balances[id][account] = _balances[id][account].sub(amount);
	}
}

contract LCPSignaling is LORTokenWrapper, ReentrancyGuard, Pausable, Ownable {
	address public lotAddress;
	uint256 public lcpEndEpoch;
	bool private allowWithdraw;

	mapping(address => bool) public protectedTokens;
	mapping(uint256 => bool) private _generated;
	mapping(uint256 => bool) private _winner;

	event Deposited(address indexed user, uint256 id, uint256 amount);
	event Withdrawn(address indexed user, uint256 id, uint256 amount);
	event Claimed(address indexed user, uint256 id, uint256 amount);
	event Generated(address indexed user, uint256 id);

	constructor(address _lotAddress, address _lorAddress) public {
		lotAddress = _lotAddress;
		lorToken = IERC20(_lorAddress);
		protectedTokens[_lorAddress] = true;

		lorToken.safeApprove(_lotAddress, (2**256 - 1));
	}

	modifier onlyLOT() {
		require(msg.sender == lotAddress, "only LOT allowed");
		_;
	}

	function resetLcp(uint256 endEpoch) public onlyOwner {
		lcpEndEpoch = endEpoch;
		allowWithdraw = false;
	}

	function addWinners(uint256[] memory ids) public onlyOwner {
		for (uint256 i = 0; i < ids.length; i++) _winner[ids[i]] = true;
		allowWithdraw = true;
	}

	function deposit(uint256 id, uint256 amount) public nonReentrant whenNotPaused() {
		require(block.timestamp <= lcpEndEpoch, "LCP is over. Check den.social for the lastest.");
		require(amount % 1 ether == 0, "Deposit only increments of 1");
		require(!_generated[id] || !_winner[id], "Lair previously won; no new deposits");
		super.deposit(id, amount);
		emit Deposited(msg.sender, id, amount);
	}

	function withdraw(uint256 id, uint256 amount) public nonReentrant {
		require(amount > 0, "Cannot withdraw 0");
		require(allowWithdraw || block.timestamp <= lcpEndEpoch, "Winners being tabulated. Withdraws open soon.");
		require(!_winner[id] && !_generated[id], "Lair won LCP but not generated; claim to open soon");
		require(!_generated[id], "LOT generated; did you intend to claim?");
		require(amount % 1 ether == 0, "Withdraw only increments of 1");

		super.withdraw(id, amount);
		emit Withdrawn(msg.sender, id, amount);
	}

	function claim(uint256 id) public nonReentrant {
		require(_generated[id], "LOT not generated; did you intend to withdraw?");
		require(super.balanceOf(msg.sender, id) > 0, "Nothing to claim");

		uint256 amount = super.balanceOf(msg.sender, id);
		super.claim(id, msg.sender);
		IERC1155(lotAddress).lcpMint(id, msg.sender, _toEther(amount), "");
		emit Claimed(msg.sender, id, _toEther(amount));
	}

	function claimable(address account, uint256 id) public view returns (uint256) {
		if (!_generated[id]) {
			return 0;
		}
		return _toEther(super.balanceOf(account, id));
	}

	function generate(uint256 id) public onlyLOT returns (uint256) {
		_generated[id] = true;
		emit Generated(msg.sender, id);
		return totalDeposits(id);
	}

	function sweep(address token) external onlyOwner {
		require(!protectedTokens[token], "token is protected");
		IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
	}

	// Internal functions
	function _toEther(uint256 _amount) internal pure returns (uint256) {
		return _amount / (1 ether);
	}
}