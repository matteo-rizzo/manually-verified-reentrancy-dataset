/**
 *Submitted for verification at Etherscan.io on 2021-02-11
*/

// SPDX-FileCopyrightText: © 2020 Velox <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause

pragma solidity 0.8.0;



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract IERC20NONStandard {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */

    uint256 public totalSupply;
    function balanceOf(address owner) virtual public view returns (uint256 balance);

    /// !!! NOTICE !!! `transfer` does not return a value, in violation of the ERC20 specification
    /// will return Whether the transfer was successful or not
    function transfer(address to, uint256 value) virtual public;

    /// !!! NOTICE !!! `transferFrom` does not return a value, in violation of the ERC20 specification
    /// will return Whether the transfer was successful or not
    function transferFrom(address from, address to, uint256 value) virtual public;


    function approve(address spender, uint256 value) virtual public returns (bool success);
    function allowance(address owner, address spender) virtual public view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract BackingStore {
    address public MAIN_CONTRACT;
    address public UNISWAP_FACTORY_ADDRESS = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public ADMIN_ADDRESS;
}

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

contract SwapExceptions {

    event SwapException(uint exception, uint info, uint detail);

    enum Exception {
        NO_ERROR,
        GENERIC_ERROR,
        UNAUTHORIZED,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW,
        DIVISION_BY_ZERO,
        BAD_INPUT,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_TRANSFER_FAILED,
        MARKET_NOT_SUPPORTED,
        SUPPLY_RATE_CALCULATION_FAILED,
        BORROW_RATE_CALCULATION_FAILED,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_OUT_FAILED,
        INSUFFICIENT_LIQUIDITY,
        INSUFFICIENT_BALANCE,
        INVALID_COLLATERAL_RATIO,
        MISSING_ASSET_PRICE,
        EQUITY_INSUFFICIENT_BALANCE,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        ASSET_NOT_PRICED,
        INVALID_LIQUIDATION_DISCOUNT,
        INVALID_COMBINED_RISK_PARAMETERS,
        ZERO_ORACLE_ADDRESS,
        CONTRACT_PAUSED
    }

    /*
     * Note: Reason (but not Exception) is kept in alphabetical order
     *       This is because Reason grows significantly faster, and
     *       the order of Exception has some meaning, while the order of Reason
     *       is arbitrary.
     */
    enum Reason {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        BORROW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED,
        BORROW_ACCOUNT_SHORTFALL_PRESENT,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_AMOUNT_LIQUIDITY_SHORTFALL,
        BORROW_AMOUNT_VALUE_CALCULATION_FAILED,
        BORROW_CONTRACT_PAUSED,
        BORROW_MARKET_NOT_SUPPORTED,
        BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
        BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED,
        BORROW_ORIGINATION_FEE_CALCULATION_FAILED,
        BORROW_TRANSFER_OUT_FAILED,
        EQUITY_WITHDRAWAL_AMOUNT_VALIDATION,
        EQUITY_WITHDRAWAL_CALCULATE_EQUITY,
        EQUITY_WITHDRAWAL_MODEL_OWNER_CHECK,
        EQUITY_WITHDRAWAL_TRANSFER_OUT_FAILED,
        LIQUIDATE_ACCUMULATED_BORROW_BALANCE_CALCULATION_FAILED,
        LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET,
        LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET,
        LIQUIDATE_AMOUNT_SEIZE_CALCULATION_FAILED,
        LIQUIDATE_BORROW_DENOMINATED_COLLATERAL_CALCULATION_FAILED,
        LIQUIDATE_CLOSE_AMOUNT_TOO_HIGH,
        LIQUIDATE_CONTRACT_PAUSED,
        LIQUIDATE_DISCOUNTED_REPAY_TO_EVEN_AMOUNT_CALCULATION_FAILED,
        LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET,
        LIQUIDATE_NEW_BORROW_RATE_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET,
        LIQUIDATE_NEW_SUPPLY_RATE_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_BORROW_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_CASH_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET,
        LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET,
        LIQUIDATE_FETCH_ASSET_PRICE_FAILED,
        LIQUIDATE_TRANSFER_IN_FAILED,
        LIQUIDATE_TRANSFER_IN_NOT_POSSIBLE,
        REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_CONTRACT_PAUSED,
        REPAY_BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        REPAY_BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        REPAY_BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED,
        REPAY_BORROW_TRANSFER_IN_FAILED,
        REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
        SET_ASSET_PRICE_CHECK_ORACLE,
        SET_MARKET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_ORACLE_OWNER_CHECK,
        SET_ORIGINATION_FEE_OWNER_CHECK,
        SET_PAUSED_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_RISK_PARAMETERS_OWNER_CHECK,
        SET_RISK_PARAMETERS_VALIDATION,
        SUPPLY_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        SUPPLY_CONTRACT_PAUSED,
        SUPPLY_MARKET_NOT_SUPPORTED,
        SUPPLY_NEW_BORROW_INDEX_CALCULATION_FAILED,
        SUPPLY_NEW_BORROW_RATE_CALCULATION_FAILED,
        SUPPLY_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        SUPPLY_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_CASH_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        SUPPLY_TRANSFER_IN_FAILED,
        SUPPLY_TRANSFER_IN_NOT_POSSIBLE,
        SUPPORT_MARKET_FETCH_PRICE_FAILED,
        SUPPORT_MARKET_OWNER_CHECK,
        SUPPORT_MARKET_PRICE_CHECK,
        SUSPEND_MARKET_OWNER_CHECK,
        WITHDRAW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED,
        WITHDRAW_ACCOUNT_SHORTFALL_PRESENT,
        WITHDRAW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        WITHDRAW_AMOUNT_LIQUIDITY_SHORTFALL,
        WITHDRAW_AMOUNT_VALUE_CALCULATION_FAILED,
        WITHDRAW_CAPACITY_CALCULATION_FAILED,
        WITHDRAW_CONTRACT_PAUSED,
        WITHDRAW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        WITHDRAW_NEW_BORROW_RATE_CALCULATION_FAILED,
        WITHDRAW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        WITHDRAW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        WITHDRAW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        WITHDRAW_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        WITHDRAW_TRANSFER_OUT_FAILED,
        WITHDRAW_TRANSFER_OUT_NOT_POSSIBLE
    }

    /**
      * @dev report a known exception
      */
    function raiseException(Exception exception, Reason reason) internal returns (uint) {
        emit SwapException(uint(exception), uint(reason), 0);
        return uint(exception);
    }

    /**
      * @dev report an opaque error from an upgradeable collaborator contract
      */
    function raiseGenericException(Reason reason, uint genericException) internal returns (uint) {
        emit SwapException(uint(Exception.GENERIC_ERROR), uint(reason), genericException);
        return uint(Exception.GENERIC_ERROR);
    }

}

contract Swappable is SwapExceptions {
    /**
      * @dev Checks whether or not there is sufficient allowance for this contract to move amount from `from` and
      *      whether or not `from` has a balance of at least `amount`. Does NOT do a transfer.
      */
    function checkTransferIn(address asset, address from, uint amount) internal view returns (Exception) {

        IERC20 token = IERC20(asset);

        if (token.allowance(from, address(this)) < amount) {
            return Exception.TOKEN_INSUFFICIENT_ALLOWANCE;
        }

        if (token.balanceOf(from) < amount) {
            return Exception.TOKEN_INSUFFICIENT_BALANCE;
        }

        return Exception.NO_ERROR;
    }

    /**
      *  @dev This wrapper safely handles non-standard ERC-20 tokens that do not return a value.
      *  See here: https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
      */
    function doTransferIn(address asset, address from, uint amount) internal returns (Exception) {
        IERC20NONStandard token = IERC20NONStandard(asset);
        bool result;
        // Should we use Helper.safeTransferFrom?
        require(token.allowance(from, address(this)) >= amount, 'Not enough allowance from client');
        token.transferFrom(from, address(this), amount);

        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    result := not(0)          // set result to true
                }
                case 32 {                     // This is a complaint ERC-20
                    returndatacopy(0, 0, 32)
                    result := mload(0)        // Set `result = returndata` of external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }

        if (!result) {
            return Exception.TOKEN_TRANSFER_FAILED;
        }

        return Exception.NO_ERROR;
    }

    /**
      * @dev Checks balance of this contract in asset
      */
    function getCash(address asset) internal view returns (uint) {
        IERC20 token = IERC20(asset);
        return token.balanceOf(address(this));
    }

    /**
      * @dev Checks balance of `from` in `asset`
      */
    function getBalanceOf(address asset, address from) internal view returns (uint) {
        IERC20 token = IERC20(asset);
        return token.balanceOf(from);
    }

    /**
      * @dev Similar to EIP20 transfer, except it handles a False result from `transfer` and returns an explanatory
      *      error code rather than reverting. If caller has not called checked protocol's balance, this may revert due to
      *      insufficient cash held in this contract. If caller has checked protocol's balance prior to this call, and verified
      *      it is >= amount, this should not revert in normal conditions.
      *
      *      Note: This wrapper safely handles non-standard ERC-20 tokens that do not return a value.
      *            See here: https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
      */
    function doTransferOut(address asset, address to, uint amount) internal returns (Exception) {
        IERC20NONStandard token = IERC20NONStandard(asset);
        bool result;
        token.transfer(to, amount);

        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    result := not(0)          // set result to true
                }
                case 32 {                     // This is a complaint ERC-20
                    returndatacopy(0, 0, 32)
                    result := mload(0)        // Set `result = returndata` of external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }

        if (!result) {
            return Exception.TOKEN_TRANSFER_OUT_FAILED;
        }

        return Exception.NO_ERROR;
    }
}

/**
* @title VeloxSwap based on algorithmic conditional trading exeuctions
*/
contract VeloxSwap is BackingStore, Ownable, Swappable, IVeloxSwap {

    using SafeMath for uint256;
    IUniswapV2Router02 public immutable router;

    constructor() {
        router = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
    }

    /**
    *   @dev This function should ONLY be executed when algorithmic conditons are met
    *   function sellTokenForETH
    *   @param seller           address
    *   @param token            address
    *   @param tokenAmount      uint256
    *   @param minEthOut        uint256
    *   @param deadline         uint256 - UNIX timestamp
    */
    function sellTokenForETH(
        address seller,
        address token,
        uint256 tokenAmount,
        uint256 minEthOut,
        uint256 deadline
    ) override public {
        require(msg.sender == ADMIN_ADDRESS, "VELOXSWAP: NOT_ADMIN");

        // Wrapped Ether
        address tokenWETH = router.WETH();

        // Sanity check
        require (seller != address(0) &&
                token != address(0) &&
                tokenAmount > 0,
        'VELOXSWAP: ZERO_DETECTED');

        // Be 100% sure there's available allowance in this token contract
        Exception exception = doTransferIn(token, seller, tokenAmount);
        require (exception == Exception.NO_ERROR, 'VELOXSWAP: ALLOWANCE_TOO_LOW');

        // Safely Approve UNISWAP V2 Router for token amount
        VeloxTransferHelper.safeApprove(token, address(router), tokenAmount);

        // Path
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = tokenWETH;

        // Checking Token/WETH reserves
        (uint256 reserveToken, uint256 reserveWETH) = UniswapV2Library.getReserves(router.factory(), token, tokenWETH);
        require (reserveToken > 0 && reserveWETH > 0, 'VELOXSWAP: ZERO_RESERVE_DETECTED');

        router.swapExactTokensForETH(
            tokenAmount,
            minEthOut,
            path,
            seller,
            deadline
        );
    }
}

interface IVeloxSwapV2 is IVeloxSwap {

    function withdrawToken(address token, uint256 amount) external;
    
    function withdrawETH(uint256 amount) external;

    function sellExactTokensForTokens(
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 tokenInAmount,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline) external returns (uint256 amountOut);

    function fundGasCost(address seller, uint256 wethAmount) external;

}











interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}



/**
* @title VeloxSwap based on algorithmic conditional trading exeuctions
*/

contract VeloxSwapV2 is VeloxSwap(), IVeloxSwapV2 {

    uint constant FEE_SCALE = 10000;

    event ValueSwapped(address indexed seller, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    function withdrawToken(address token, uint256 amount) onlyOwner override external {
        // Should we convert to ETH?
        VeloxTransferHelper.safeTransfer(token, msg.sender, amount);
    }

    function withdrawETH(uint256 amount) onlyOwner override external {
        VeloxTransferHelper.safeTransferETH(msg.sender, amount);
    }

    function fundGasCost(address seller, uint256 wethAmount) override external {
        require(msg.sender == ADMIN_ADDRESS, 'VELOXSWAP: NOT_ADMIN');

        Exception exception = doTransferIn(router.WETH(), seller, wethAmount);
        require (exception == Exception.NO_ERROR, 'VELOXSWAP: WETH_TRANSFER_FAILED');
    }

    /**
    *   @dev This function should ONLY be executed when algorithmic conditons are met
    *   function sellExactTokensForTokens
    *   @param seller               address
    *   @param tokenInAddress       address
    *   @param tokenOutAddress      address
    *   @param tokenInAmount        uint256
    *   @param minTokenOutAmount    uint256
    *   @param feeFactor            uint - 1/10000 fraction of the amount, i.e. feeFactor of 1 means 0.01% fee
    *   @param takeFeeFromInput     bool
    *   @param deadline             uint256 - UNIX timestamp
    */
    function sellExactTokensForTokens(
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 tokenInAmount,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline
    ) override public returns (uint256 amountOut) {
        require(deadline >= block.timestamp, 'VELOXSWAP: EXPIRED');
        // Sanity checks
        validateInput(seller, tokenInAddress, tokenOutAddress, tokenInAmount, minTokenOutAmount, feeFactor);

        // Be 100% sure there's available allowance in this token contract
        Exception exception = doTransferIn(tokenInAddress, seller, tokenInAmount);
        require(exception == Exception.NO_ERROR, 'VELOXSWAP: ALLOWANCE_TOO_LOW');

        // Checking In/Out reserves
        checkLiquidity(tokenInAddress, tokenOutAddress, minTokenOutAmount);

        // Fee
        uint256 amountInForSwap = tokenInAmount;

        // Take fee from input
        if (takeFeeFromInput) {
            // Use less tokens for swap so we can keep the difference and make one less transfer
            amountInForSwap = deductFee(tokenInAmount, feeFactor);
            minTokenOutAmount = deductFee(minTokenOutAmount, feeFactor);
        }

        // If we took fee from the input, transfer the result directly to client,
        // otherwise, transfer to contract address so we can take fee from output
        address swapTargetAddress = takeFeeFromInput ? seller : address(this);

        // Execute the swap
        doSwap(tokenInAddress, tokenOutAddress, amountInForSwap, minTokenOutAmount, swapTargetAddress, deadline);

        amountOut = minTokenOutAmount;

        // Take the fee from the output if not taken from the input
        if (!takeFeeFromInput) {
            amountOut = takeOutputFee(amountOut, feeFactor, tokenOutAddress, seller);
        }

        emit ValueSwapped(seller, tokenInAddress, tokenOutAddress, tokenInAmount, amountOut);
    }

    function validateInput(address seller, address tokenInAddress, address tokenOutAddress, uint256 tokenInAmount, uint256 minTokenOutAmount, uint16 feeFactor) private view {

        require(msg.sender == ADMIN_ADDRESS, 'VELOXSWAP: NOT_ADMIN');
        require(feeFactor <= 30, 'VELOXSWAP: FEE_OVER_03_PERCENT');
        require(address(router) != address(0), 'VELOXSWAP: ROUTER_NOT_INSTANTIATED');

        address tokenWETH = router.WETH();
        require(tokenWETH != address(0), 'VELOXSWAP: WETH_ADDRESS_NOT_FOUND');

        require (seller != address(0) &&
                tokenInAddress != address(0) &&
                tokenOutAddress != address(0) &&
                tokenInAmount > 0 &&
                minTokenOutAmount > 0, // We should not allow minTokenOutAmount to be 0, so added this check
        'VELOXSWAP: ZERO_DETECTED');

        // For now we only work with WETH/TOKEN pairs
        require(tokenInAddress == tokenWETH || tokenOutAddress == tokenWETH, 'VELOXSWAP: INVALID_PATH');
    }

    function doSwap(address  tokenInAddress, address tokenOutAddress, uint256 tokenInAmount, uint256 minTokenOutAmount, address targetAddress, uint256 deadline) private {
        // Safely Approve UNISWAP V2 Router for token amount
        VeloxTransferHelper.safeApprove(tokenInAddress, address(router), tokenInAmount);

        // Path
        address[] memory path = new address[](2);
        path[0] = tokenInAddress;
        path[1] = tokenOutAddress;

        router.swapExactTokensForTokens(
            tokenInAmount,
            minTokenOutAmount,
            path,
            targetAddress,
            deadline
        );
    }

    function checkLiquidity(address  tokenInAddress, address tokenOutAddress, uint256 minTokenOutAmount) private view {
        (uint256 reserveIn, uint256 reserveOut) = UniswapV2Library.getReserves(UNISWAP_FACTORY_ADDRESS, tokenInAddress, tokenOutAddress);
        require(reserveIn > 0 && reserveOut > 0, 'VELOXSWAP: ZERO_RESERVE_DETECTED');
        require(reserveOut > minTokenOutAmount, 'VELOXSWAP: NOT_ENOUGH_LIQUIDITY');
    }

    function takeOutputFee(uint256 amountOut, uint16 feeFactor, address tokenOutAddress,
                           address from) private returns (uint256 transferredAmount) {

        // Transfer to client address the value of amountOut - fee and keep difference in contract address
        transferredAmount = deductFee(amountOut, feeFactor);
        Exception exception = doTransferOut(tokenOutAddress, from, transferredAmount);
        require (exception == Exception.NO_ERROR);
    }

    function deductFee(uint256 amount, uint16 feeFactor) private pure returns (uint256 deductedAmount) {
        deductedAmount = (amount * (FEE_SCALE - feeFactor)) / FEE_SCALE;
    }
}