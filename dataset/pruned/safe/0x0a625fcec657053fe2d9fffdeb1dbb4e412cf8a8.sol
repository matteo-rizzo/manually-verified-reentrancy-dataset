/**
 *Submitted for verification at Etherscan.io on 2020-10-30
*/

/**
 * Copyright 2017-2020, bZeroX, LLC <https://bzx.network/>. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;




contract IERC20 {
    string public name;
    uint8 public decimals;
    string public symbol;
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function approve(address _spender, uint256 _value) public returns (bool);
    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract IWethERC20 is IWeth, IERC20 {}

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
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */


/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2дл.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

    /// @dev Constant for unlocked guard state - non-zero to prevent extra gas costs.
    /// See: https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1056
    uint256 internal constant REENTRANCY_GUARD_FREE = 1;

    /// @dev Constant for locked guard state
    uint256 internal constant REENTRANCY_GUARD_LOCKED = 2;

    /**
    * @dev We use a single lock for the whole contract.
    */
    uint256 internal reentrancyLock = REENTRANCY_GUARD_FREE;

    /**
    * @dev Prevents a contract from calling itself, directly or indirectly.
    * If you mark a function `nonReentrant`, you should also
    * mark it `external`. Calling one `nonReentrant` function from
    * another is not supported. Instead, you can implement a
    * `private` function doing the actual work, and an `external`
    * wrapper marked as `nonReentrant`.
    */
    modifier nonReentrant() {
        require(reentrancyLock == REENTRANCY_GUARD_FREE, "nonReentrant");
        reentrancyLock = REENTRANCY_GUARD_LOCKED;
        _;
        reentrancyLock = REENTRANCY_GUARD_FREE;
    }
}

/**
 * @dev Collection of functions related to the address type
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
        require(isOwner(), "unauthorized");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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

contract Pausable {

    // keccak256("Pausable_FunctionPause")
    bytes32 internal constant Pausable_FunctionPause = 0xa7143c84d793a15503da6f19bf9119a2dac94448ca45d77c8bf08f57b2e91047;

    modifier pausable(bytes4 sig) {
        require(!_isPaused(sig), "unauthorized");
        _;
    }

    function _isPaused(
        bytes4 sig)
        internal
        view
        returns (bool isPaused)
    {
        bytes32 slot = keccak256(abi.encodePacked(sig, Pausable_FunctionPause));
        assembly {
            isPaused := sload(slot)
        }
    }
}

contract LoanTokenBase is ReentrancyGuard, Ownable, Pausable {

    uint256 internal constant WEI_PRECISION = 10**18;
    uint256 internal constant WEI_PERCENT_PRECISION = 10**20;

    int256 internal constant sWEI_PRECISION = 10**18;

    string public name;
    string public symbol;
    uint8 public decimals;

    // uint88 for tight packing -> 8 + 88 + 160 = 256
    uint88 internal lastSettleTime_;

    address public loanTokenAddress;

    uint256 public baseRate;
    uint256 public rateMultiplier;
    uint256 public lowUtilBaseRate;
    uint256 public lowUtilRateMultiplier;

    uint256 public targetLevel;
    uint256 public kinkLevel;
    uint256 public maxScaleRate;

    uint256 internal _flTotalAssetSupply;
    uint256 public checkpointSupply;
    uint256 public initialPrice;

    mapping (uint256 => bytes32) public loanParamsIds; // mapping of keccak256(collateralToken, isTorqueLoan) to loanParamsId
    mapping (address => uint256) internal checkpointPrices_; // price of token at last user checkpoint
}

contract AdvancedTokenStorage is LoanTokenBase {
    using SafeMath for uint256;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Mint(
        address indexed minter,
        uint256 tokenAmount,
        uint256 assetAmount,
        uint256 price
    );

    event Burn(
        address indexed burner,
        uint256 tokenAmount,
        uint256 assetAmount,
        uint256 price
    );

    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    uint256 internal totalSupply_;

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return totalSupply_;
    }

    function balanceOf(
        address _owner)
        public
        view
        returns (uint256)
    {
        return balances[_owner];
    }

    function allowance(
        address _owner,
        address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }
}

contract LoanToken is AdvancedTokenStorage {

    address internal target_;

    constructor(
        address _newOwner,
        address _newTarget)
        public
    {
        transferOwnership(_newOwner);
        _setTarget(_newTarget);
    }

    function()
        external
        payable
    {
        if (gasleft() <= 2300) {
            return;
        }

        address target = target_;
        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(gas, target, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function setTarget(
        address _newTarget)
        public
        onlyOwner
    {
        _setTarget(_newTarget);
    }

    function _setTarget(
        address _newTarget)
        internal
    {
        require(Address.isContract(_newTarget), "target not a contract");
        target_ = _newTarget;
    }
}