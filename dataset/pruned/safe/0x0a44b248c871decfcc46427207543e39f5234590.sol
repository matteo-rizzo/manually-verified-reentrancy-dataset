/**
 *Submitted for verification at Etherscan.io on 2020-01-10
*/

// File: openzeppelin-solidity/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

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
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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


// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


// File: contracts/Interfaces/StakingInterface.sol

pragma solidity ^0.5.15;



// File: contracts/Types.sol

pragma solidity ^0.5.15;



// File: contracts/Compound/ErrorReporter.sol

pragma solidity ^0.5.8;

contract ComptrollerErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        COMPTROLLER_MISMATCH,
        INSUFFICIENT_SHORTFALL,
        INSUFFICIENT_LIQUIDITY,
        INVALID_CLOSE_FACTOR,
        INVALID_COLLATERAL_FACTOR,
        INVALID_LIQUIDATION_INCENTIVE,
        MARKET_NOT_ENTERED,
        MARKET_NOT_LISTED,
        MARKET_ALREADY_LISTED,
        MATH_ERROR,
        NONZERO_BORROW_BALANCE,
        PRICE_ERROR,
        REJECTION,
        SNAPSHOT_ERROR,
        TOO_MANY_ASSETS,
        TOO_MUCH_REPAY
    }

    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
        EXIT_MARKET_BALANCE_OWED,
        EXIT_MARKET_REJECTION,
        SET_CLOSE_FACTOR_OWNER_CHECK,
        SET_CLOSE_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_NO_EXISTS,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_WITHOUT_PRICE,
        SET_IMPLEMENTATION_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_VALIDATION,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_PENDING_IMPLEMENTATION_OWNER_CHECK,
        SET_PRICE_ORACLE_OWNER_CHECK,
        SUPPORT_MARKET_EXISTS,
        SUPPORT_MARKET_OWNER_CHECK,
        ZUNUSED
    }

    /**
      * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
      * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
      **/
    event Failure(uint256 error, uint256 info, uint256 detail);

    /**
      * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
      */
    function fail(Error err, FailureInfo info) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), 0);

        return uint256(err);
    }

    /**
      * @dev use this when reporting an opaque error from an upgradeable collaborator contract
      */
    function failOpaque(Error err, FailureInfo info, uint256 opaqueError) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), opaqueError);

        return uint256(err);
    }
}

contract TokenErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        BAD_INPUT,
        COMPTROLLER_REJECTION,
        COMPTROLLER_CALCULATION_ERROR,
        INTEREST_RATE_MODEL_ERROR,
        INVALID_ACCOUNT_PAIR,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        INVALID_COLLATERAL_FACTOR,
        MATH_ERROR,
        MARKET_NOT_FRESH,
        MARKET_NOT_LISTED,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_IN_FAILED,
        TOKEN_TRANSFER_OUT_FAILED
    }

    /*
     * Note: FailureInfo (but not Error) is kept in alphabetical order
     *       This is because FailureInfo grows significantly faster, and
     *       the order of Error has some meaning, while the order of FailureInfo
     *       is entirely arbitrary.
     */
    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED,
        ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED,
        ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_ACCRUE_INTEREST_FAILED,
        BORROW_CASH_NOT_AVAILABLE,
        BORROW_FRESHNESS_CHECK,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        BORROW_MARKET_NOT_LISTED,
        BORROW_COMPTROLLER_REJECTION,
        LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED,
        LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED,
        LIQUIDATE_COLLATERAL_FRESHNESS_CHECK,
        LIQUIDATE_COMPTROLLER_REJECTION,
        LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED,
        LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX,
        LIQUIDATE_CLOSE_AMOUNT_IS_ZERO,
        LIQUIDATE_FRESHNESS_CHECK,
        LIQUIDATE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_REPAY_BORROW_FRESH_FAILED,
        LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED,
        LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED,
        LIQUIDATE_SEIZE_COMPTROLLER_REJECTION,
        LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_SEIZE_TOO_MUCH,
        MINT_ACCRUE_INTEREST_FAILED,
        MINT_COMPTROLLER_REJECTION,
        MINT_EXCHANGE_CALCULATION_FAILED,
        MINT_EXCHANGE_RATE_READ_FAILED,
        MINT_FRESHNESS_CHECK,
        MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        MINT_TRANSFER_IN_FAILED,
        MINT_TRANSFER_IN_NOT_POSSIBLE,
        REDEEM_ACCRUE_INTEREST_FAILED,
        REDEEM_COMPTROLLER_REJECTION,
        REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED,
        REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED,
        REDEEM_EXCHANGE_RATE_READ_FAILED,
        REDEEM_FRESHNESS_CHECK,
        REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        REDEEM_TRANSFER_OUT_NOT_POSSIBLE,
        REDUCE_RESERVES_ACCRUE_INTEREST_FAILED,
        REDUCE_RESERVES_ADMIN_CHECK,
        REDUCE_RESERVES_CASH_NOT_AVAILABLE,
        REDUCE_RESERVES_FRESH_CHECK,
        REDUCE_RESERVES_VALIDATION,
        REPAY_BEHALF_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_COMPTROLLER_REJECTION,
        REPAY_BORROW_FRESHNESS_CHECK,
        REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COMPTROLLER_OWNER_CHECK,
        SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED,
        SET_INTEREST_RATE_MODEL_FRESH_CHECK,
        SET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_ORACLE_MARKET_NOT_LISTED,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED,
        SET_RESERVE_FACTOR_ADMIN_CHECK,
        SET_RESERVE_FACTOR_FRESH_CHECK,
        SET_RESERVE_FACTOR_BOUNDS_CHECK,
        TRANSFER_COMPTROLLER_REJECTION,
        TRANSFER_NOT_ALLOWED,
        TRANSFER_NOT_ENOUGH,
        TRANSFER_TOO_MUCH
    }

    /**
      * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
      * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
      **/
    event Failure(uint256 error, uint256 info, uint256 detail);

    /**
      * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
      */
    function fail(Error err, FailureInfo info) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), 0);

        return uint256(err);
    }

    /**
      * @dev use this when reporting an opaque error from an upgradeable collaborator contract
      */
    function failOpaque(Error err, FailureInfo info, uint256 opaqueError) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), opaqueError);

        return uint256(err);
    }
}

// File: contracts/Stake.sol

pragma solidity ^0.5.15;








contract Stake is StakingInterface, Ownable, TokenErrorReporter {
    using SafeMath for uint256;
    using Roles for Roles.Role;

    Roles.Role operators;

    event WhitelistToken(address indexed tokenAddress);
    event DiscardToken(address indexed tokenAddress);

    event StakeEvent(
        address indexed staker,
        address indexed tokenAddress,
        uint256 tokenBalance
    );
    event Redeem(
        address indexed staker,
        address indexed tokenAddress,
        uint256 tokenWithdrawal
    );

    event TakeEarnings(address indexed tokenAddress, uint256 indexed amount);

    address[] public TokenList;
    mapping(address => Types.Token) public TokenStructs;
    mapping(address => mapping(address => Types.Stake)) public stakes;

    string private constant ERROR_AMOUNT_ZERO = "STAKING_AMOUNT_ZERO";
    string private constant ERROR_AMOUNT_NEGATIVE = "STAKING_AMOUNT_NEGATIVE";
    string private constant ERROR_TOKEN_TRANSFER = "STAKING_TOKEN_TRANSFER_FAILED";
    string private constant ERROR_NOT_ENOUGH_BALANCE = "STAKING_NOT_ENOUGH_BALANCE";
    string private constant ERROR_NOT_ENOUGH_ALLOWANCE = "STAKING_NOT_ENOUGH_ALLOWANCE";
    string private constant ERROR_TOKEN_NOT_WHITELISTED = "STAKING_TOKEN_NOT_WHITELISTED";
    string private constant ERROR_NOT_OWNER = "SEND_IS_NOT_OWNER";
    string private constant ERROR_NO_STAKE = "STAKING_NOT_FOUND";
    string private constant ERROR_TOKEN_EXISTS = "TOKEN_EXISTS";
    string private constant ERROR_TOKEN_NOT_FOUND = "TOKEN_NOT_FOUND";
    string private constant ERROR_TRANSFER_FAILED = "TOKEN_TRANSFER_FAILED";

    constructor(address[] memory TokenAddress) public {
        uint256 length = TokenAddress.length;
        if (length > 0) {
            for (uint256 i = 0; i < length; i = i.add(1)) {
                whitelistToken(TokenAddress[i]);
            }
        }
    }

    modifier onlyOperatorOrOwner() {
        require(operators.has(msg.sender) || owner() == msg.sender, ERROR_NOT_OWNER);
        _;
    }

    modifier onlyStakerOrOwner(address staker) {
        require(msg.sender == staker || operators.has(msg.sender)  || owner() == msg.sender, ERROR_NOT_OWNER);
        _;
    }

    modifier stakeExists(address staker, address tokenAddress) {
        require(stakes[staker][tokenAddress].TokenAddress == tokenAddress, ERROR_NO_STAKE);
        _;
    }

    function addOperator(address _operator) public onlyOwner
    {
        operators.add(_operator);
    }

    function removeOperator(address _operator) public onlyOwner
    {
        operators.remove(_operator);
    }

    function balanceOf(address staker, address tokenAddress) public view returns (uint256) {
        if(isStake(staker, tokenAddress)) {
            return stakes[staker][tokenAddress].TokenBalance;
        }
        return 0;
    }

    function isToken(address tokenAddress) public view returns (bool) {
        if (TokenList.length == uint256(Error.NO_ERROR)) return false;
        return (TokenList[TokenStructs[tokenAddress].listPointer] == tokenAddress);
    }

    function isStake(address staker, address tokenAddress) public view returns (bool) {
        return stakes[staker][tokenAddress].TokenAddress == tokenAddress;
    }

    function whitelistToken(address TokenAddress) public onlyOwner {
        require(!isToken(TokenAddress), ERROR_TOKEN_EXISTS);
        TokenStructs[TokenAddress].listPointer = TokenList.push(TokenAddress).sub(1);
        emit WhitelistToken(TokenAddress);
    }

    function discardToken(address TokenAddress) public onlyOwner {
        require(isToken(TokenAddress), ERROR_TOKEN_NOT_FOUND);
        uint256 rowToDelete = TokenStructs[TokenAddress].listPointer;
        address keyToMove = TokenList[TokenList.length.sub(1)];
        TokenList[rowToDelete] = keyToMove;
        TokenStructs[keyToMove].listPointer = rowToDelete;
        TokenList.length = TokenList.length.sub(1);
        delete TokenStructs[TokenAddress];
        emit DiscardToken(TokenAddress);
    }

    function stake(address tokenAddress, uint256 amount) public {
        addStakeForToken(msg.sender, tokenAddress, amount);
    }

    function stakeFor(address staker, address tokenAddress, uint256 amount) public onlyOperatorOrOwner {
        addStakeForToken(staker, tokenAddress, amount);
    }

    function redeem(address staker, address tokenAddress, uint256 amount) public onlyOperatorOrOwner {
        require(isToken(tokenAddress), ERROR_TOKEN_NOT_FOUND);
        require(isStake(staker, tokenAddress), ERROR_NO_STAKE);
        require(amount > 0, ERROR_AMOUNT_ZERO);

        // Get Stake
        Types.Stake memory memStake = stakes[staker][tokenAddress];
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, ERROR_NOT_ENOUGH_BALANCE);

        uint256 tBalance = memStake.TokenBalance;
        require(tBalance >= amount, ERROR_NOT_ENOUGH_BALANCE);
        require(tBalance > 0, ERROR_NOT_ENOUGH_BALANCE);

        // Calculate Remaining Balance
        uint256 remainingAmount = tBalance.sub(amount);
        require(remainingAmount >= 0, ERROR_NOT_ENOUGH_BALANCE);
        _updateStakeForToken(staker, tokenAddress, remainingAmount);

        // Transfer Amount
        require(token.transfer(staker, amount), ERROR_TOKEN_TRANSFER);
        emit Redeem(staker, tokenAddress, amount);
    }

    function takeEarnings(address tokenAddress, uint256 amount) public onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > amount, ERROR_NOT_ENOUGH_BALANCE);

        require(IERC20(tokenAddress).transfer(msg.sender, amount));
        emit TakeEarnings(tokenAddress, amount);
    }

    function takeAllEarnings(address tokenAddress) public onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, ERROR_NOT_ENOUGH_BALANCE);

        require(token.transfer(msg.sender, balance));
        emit TakeEarnings(tokenAddress, balance);
    }

    function addStakeForToken(address staker, address TokenAddress, uint256 amount) internal {
        require(isToken(TokenAddress), ERROR_TOKEN_NOT_FOUND);
        require(amount > 0, ERROR_AMOUNT_ZERO);
        IERC20 token = IERC20(TokenAddress);
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, ERROR_NOT_ENOUGH_ALLOWANCE);
        uint256 funds = amount;
        if (isStake(staker, TokenAddress)) {
            Types.Stake memory memStake = stakes[staker][TokenAddress];
            funds = memStake.TokenBalance.add(amount);
        } else {
            funds = amount;
        }
        _updateStakeForToken(staker, TokenAddress, amount);
        require(token.transferFrom(msg.sender, address(this), amount), ERROR_TOKEN_TRANSFER);
        emit StakeEvent(staker, TokenAddress, amount);
    }

    function _updateStakeForToken(address staker, address TokenAddress, uint256 amount) internal {
        require(amount >= 0, ERROR_AMOUNT_NEGATIVE);
        stakes[staker][TokenAddress] = Types.Stake({
            TokenAddress : TokenAddress,
            TokenBalance : amount
            });
    }
}