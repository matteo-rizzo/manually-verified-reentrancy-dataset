/**
 *Submitted for verification at Etherscan.io on 2021-05-20
*/

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;








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

////////////////////////////////////////////////////////////////////////////////////////////
/// @title WarpVaultI
/// @author Christopher Dixon
////////////////////////////////////////////////////////////////////////////////////////////
/**
The WarpControlI contract is an abstract contract used by individual WarpVault contracts to call the
  maxWithdrawAllowed function on the WarpControl contract
**/
abstract contract WarpControlI {
    function getMaxWithdrawAllowed(address account, address lpToken)
        public
        virtual
        returns (uint256);

    function viewMaxWithdrawAllowed(address account, address lpToken)
        public
        virtual
        view
        returns (uint256);

    function getPriceOfCollateral(address lpToken)
        public
        virtual
        view
        returns (uint256);

    function addMemberToGroup(address _refferalCode, address _member)
        public
        virtual;

    function checkIfGroupMember(address _account)
        public
        virtual
        view
        returns (bool);

    function getTotalAvailableCollateralValue(address _account)
        public
        virtual
        returns (uint256);

    function getTotalBorrowedValue(address _account)
        public
        virtual
        returns (uint256);

    function calcBorrowLimit(uint256 _collateralValue)
        public
        virtual
        pure
        returns (uint256);

    function calcCollateralRequired(uint256 _borrowAmount)
        public
        virtual
        view
        returns (uint256);

    function getBorrowLimit(address _account) public virtual returns (uint256);

    function liquidateAccount(address _borrower) public virtual;
}

// SPDX-License-Identifier: agpl-3.0


abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  ILendingPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
  ILendingPool public immutable LENDING_POOL;

  constructor(ILendingPoolAddressesProvider provider) public {
    ADDRESSES_PROVIDER = provider;
    LENDING_POOL = ILendingPool(provider.getLendingPool());
  }
}





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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @title LendingPoolAddressesProvider contract
 * @dev Main registry of addresses part of or connected to the protocol, including permissioned roles
 * - Acting also as factory of proxies and admin of those, so with right to change its implementations
 * - Owned by the Aave Governance
 * @author Aave
 **/




/**
    !!!
    Never keep funds permanently on your FlashLoanReceiverBase contract as they could be
    exposed to a 'griefing' attack, where the stored funds are used by an attacker.
    !!!
 */
contract MyV2FlashLoan is FlashLoanReceiverBase {
    using SafeMath for uint256;

    address public uniRouterAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public uniFactoryAddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public sushiRouterAddress = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address public sushiFactoryAddress = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
    address public warpControlAddress = 0x8E0Fa7c5C7Fa86A059e865A90b50a90351df716a;

    address public daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public usdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public usdtAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public wbtcAddress = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IERC20 usdcToken = IERC20(usdcAddress);

    constructor(ILendingPoolAddressesProvider _addressProvider) FlashLoanReceiverBase(_addressProvider) public
    {

    }

    event log(string s);
    event log(string s, uint v);
    event log(string s, address v);

    struct opVars
    {
        address borrower;
        address warpControlAddress;
        address warpTeam;
        WarpControlI warpControl;
        IUniswapV2Router02 router;
        IUniswapV2Factory factory;
        IUniswapV2Pair pair;
        uint256 amount;
        address token0;
        address token1;
        uint256 usdcNeededForLoan;
        uint256[3] remainingAmounts;
        uint256 balance;
    }

    /**
        This function is called after your contract has received the flash loaned amount.
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    )
        external
        override
        returns (bool)
    {

        //
        // This contract now has the funds requested.
        // Your logic goes here.
        //

        opVars memory vars;

        // 1. liquidate account

        // approve warp control to pull funds from this
        for (uint i = 0; i < assets.length; i++) {

            // approve asset withdraw by flash loan provider
            IERC20(assets[i]).safeApprove(vars.warpControlAddress, 1e64);
        }

        // liquidate account
        (vars.borrower, vars.warpControlAddress, vars.warpTeam) = abi.decode(params, (address, address, address));
        vars.warpControl = WarpControlI(vars.warpControlAddress);
        vars.warpControl.liquidateAccount(vars.borrower);

        // for testing purposes, we just burn the borrowed assets, so we can check that the monetized LP tokens can be used to pay back flash loan
        // for (uint i = 0; i < assets.length; i++) {
        //   uint256 amountToBurn = amounts[i] * 90 / 100;
        //    IERC20(assets[i]).safeTransfer(0x931D387731bBbC988B312206c74F77D004D6B84b, amountToBurn); // simulate burning of flash loaned assets (liquidating)
        // }

        // 2. prepare uni router and factory
        vars.router = IUniswapV2Router02(uniRouterAddress);
        vars.factory = IUniswapV2Factory(uniFactoryAddress);

        // 2. convert Uniswap WETH-DAI to USDC
        vars.token0 = wethAddress;
        vars.token1 = daiAddress;
        convertToUSDC(vars);

        // 2. convert Uniswap WETH-USDC to usdc
        vars.token0 = wethAddress;
        vars.token1 = usdcAddress;
        convertToUSDC(vars);

        // 2. convert Uniswap WETH-USDT to usdc
        vars.token0 = wethAddress;
        vars.token1 = usdtAddress;
        convertToUSDC(vars);

        // 2. convert Uniswap WBTC-WETH to usdc
        vars.token0 = wethAddress;
        vars.token1 = wbtcAddress;
        convertToUSDC(vars);

        // 2. prepare uni router and factory
        vars.router = IUniswapV2Router02(sushiRouterAddress);
        vars.factory = IUniswapV2Factory(sushiFactoryAddress);

        // 2. convert Uniswap WETH-DAI to USDC
        vars.token0 = wethAddress;
        vars.token1 = daiAddress;
        convertToUSDC(vars);

        // 2. convert Uniswap WETH-USDC to usdc
        vars.token0 = wethAddress;
        vars.token1 = usdcAddress;
        convertToUSDC(vars);

        // 2. convert Uniswap WETH-USDT to usdc
        vars.token0 = wethAddress;
        vars.token1 = usdtAddress;
        convertToUSDC(vars);

        // 2. convert Uniswap WBTC-WETH to usdc
        vars.token0 = wethAddress;
        vars.token1 = wbtcAddress;
        convertToUSDC(vars);

        // 3. use uni router again
        vars.router = IUniswapV2Router02(uniRouterAddress);
        vars.factory = IUniswapV2Factory(uniFactoryAddress);

        // 3. we have a bunch of USDC now
        for (uint i = 0; i < assets.length; i++) {

            // approve asset withdraw by flash loan provider
            vars.amount = amounts[i].add(premiums[i]);
            IERC20(assets[i]).safeApprove(address(LENDING_POOL), vars.amount);

            if(assets[i] != usdcAddress)
            {
              // convert from USDC to fullfill assets[i] (payback loan)
              vars.token0 = assets[i];
              convertUSDCToToken(vars);

              vars.balance = IERC20(assets[i]).balanceOf(address(this));
              if(vars.balance > vars.amount)
                vars.remainingAmounts[i] = vars.balance - vars.amount;
            }
            else // is usdc
            {
              // remember how much usdc we need to leave in the contract to pay back loan (the rest we transfer to caller)
              vars.balance = IERC20(assets[i]).balanceOf(address(this));
              if(vars.balance > vars.amount)
                vars.remainingAmounts[i] = vars.balance - vars.amount;
            }
        }

        // transfer balance of remaining assets to caller, minus any needed for the loan
        for (uint i = 0; i < assets.length; i++) {
          if(vars.remainingAmounts[i] > 0)
             IERC20(assets[i]).safeTransfer(vars.warpTeam, vars.remainingAmounts[i]);
        }

        return true;
    }

    function liquidateWarpAccount(
        address[] memory assets,
        uint256[] memory amounts,
        uint256[] memory modes,
        address borrower,
        address warpControl,
        address warpTeam
        ) public {
        address receiverAddress = address(this);


        address onBehalfOf = address(this);
        bytes memory params = abi.encode(borrower, warpControl, warpTeam);
        uint16 referralCode = 0;

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    function getPath(address token0, address token1) private returns(address[] memory)
    {
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;

        return path;
    }

    // convert some USDC to exactly amountOwing of asset (DAI for example)
    function convertUSDCToToken(opVars memory vars) private
    {
        // approve router to transfer USDC on behalf of contract
        IERC20 usdcToken = IERC20(usdcAddress);
        usdcToken.approve(address(vars.router), 1e64);

        // swap USDC for token0
        vars.router.swapTokensForExactTokens(vars.amount, 1e64, getPath(usdcAddress, vars.token0), address(this), 1e18);
    }

    // convert some LP tokens to USDC
    function convertToUSDC(opVars memory vars) private
    {
        // get LP amount
        vars.pair = IUniswapV2Pair(vars.factory.getPair(vars.token0, vars.token1));
        vars.amount = vars.pair.balanceOf(address(this));

        if(vars.amount == 0)
          return;

        // remove liquidity => get ETH + DAI
        vars.pair.approve(address(vars.router), vars.amount);
        (uint amountToken, uint amountETH) = vars.router.removeLiquidityETH(vars.token1, vars.amount, 0, 0, address(this), 1e18);

        // convert eth to USDC
        vars.router.swapExactETHForTokens.value(amountETH)(0, getPath(vars.router.WETH(), usdcAddress), address(this), 1e18);

        // convert DAI to USDC (no need for usdc=>usdc swap)
        if(vars.token1 != usdcAddress)
        {
          IERC20 daiToken = IERC20(vars.token1);
          daiToken.approve(address(vars.router), amountToken);
          vars.router.swapExactTokensForTokens(amountToken, 0, getPath(vars.token1, usdcAddress), address(this), 1e18);
        }
    }

    fallback () external payable { }
}