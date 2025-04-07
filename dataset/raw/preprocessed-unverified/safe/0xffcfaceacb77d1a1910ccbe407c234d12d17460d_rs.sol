/**
 *Submitted for verification at Etherscan.io on 2021-02-01
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

// Global Enums and Structs



struct StrategyParams {
    uint256 performanceFee;
    uint256 activation;
    uint256 debtRatio;
    uint256 rateLimit;
    uint256 lastReport;
    uint256 totalDebt;
    uint256 totalGain;
    uint256 totalLoss;
}

// Part: BankConfig



// Part: IBaseStrategy



// Part: IGenericLender



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: Bank

interface Bank is IERC20 {
    function deposit() external payable;

    function glbDebtVal() external view returns (uint256);

    function glbDebtShare() external view returns (uint256);

    function reservePool() external view returns (uint256);

    function totalETH() external view returns (uint256);

    function config() external view returns (address);

    function withdraw(uint256 share) external;

    function pendingInterest(uint256 msgValue) external view returns (uint256);

    function debtShareToVal(uint256 debtShare) external view returns (uint256);

    function debtValToShare(uint256 debtVal) external view returns (uint256);
}

// Part: IWETH

interface IWETH is IERC20 {
    function deposit() external payable;

    function decimals() external view returns (uint256);

    function withdraw(uint256) external;
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


// Part: iearn-finance/[email protected]/VaultAPI

interface VaultAPI is IERC20 {
    function apiVersion() external pure returns (string memory);

    function withdraw(uint256 shares, address recipient) external returns (uint256);

    function token() external view returns (address);

    function strategies(address _strategy) external view returns (StrategyParams memory);

    /**
     * View how much the Vault would increase this Strategy's borrow limit,
     * based on its present performance (since its last report). Can be used to
     * determine expectedReturn in your Strategy.
     */
    function creditAvailable() external view returns (uint256);

    /**
     * View how much the Vault would like to pull back from the Strategy,
     * based on its present performance (since its last report). Can be used to
     * determine expectedReturn in your Strategy.
     */
    function debtOutstanding() external view returns (uint256);

    /**
     * View how much the Vault expect this Strategy to return at the current
     * block, based on its present performance (since its last report). Can be
     * used to determine expectedReturn in your Strategy.
     */
    function expectedReturn() external view returns (uint256);

    /**
     * This is the main contact point where the Strategy interacts with the
     * Vault. It is critical that this call is handled as intended by the
     * Strategy. Therefore, this function will be called by BaseStrategy to
     * make sure the integration is correct.
     */
    function report(
        uint256 _gain,
        uint256 _loss,
        uint256 _debtPayment
    ) external returns (uint256);

    /**
     * This function should only be used in the scenario where the Strategy is
     * being retired but no migration of the positions are possible, or in the
     * extreme scenario that the Strategy needs to be put into "Emergency Exit"
     * mode in order for it to exit as quickly as possible. The latter scenario
     * could be for any reason that is considered "critical" that the Strategy
     * exits its position as fast as possible, such as a sudden change in
     * market conditions leading to losses, or an imminent failure in an
     * external dependency.
     */
    function revokeStrategy() external;

    /**
     * View the governance address of the Vault to assert privileged functions
     * can only be called by governance. The Strategy serves the Vault, so it
     * is subject to governance defined by the Vault.
     */
    function governance() external view returns (address);
}

// Part: GenericLenderBase

abstract contract GenericLenderBase is IGenericLender {
    VaultAPI public vault;
    address public override strategy;
    IERC20 public want;
    string public override lenderName;

    uint256 public dust;

    constructor(address _strategy, string memory name) public {
        strategy = _strategy;
        vault = VaultAPI(IBaseStrategy(strategy).vault());
        want = IERC20(vault.token());
        lenderName = name;
        dust = 10000;

        want.approve(_strategy, uint256(-1));
    }

    function setDust(uint256 _dust) external virtual override management {
        dust = _dust;
    }

    function sweep(address _token) external virtual override management {
        address[] memory _protectedTokens = protectedTokens();
        for (uint256 i; i < _protectedTokens.length; i++) require(_token != _protectedTokens[i], "!protected");

        IERC20(_token).transfer(vault.governance(), IERC20(_token).balanceOf(address(this)));
    }

    function protectedTokens() internal view virtual returns (address[] memory);

    //make sure to use
    modifier management() {
        require(
            msg.sender == address(strategy) || msg.sender == vault.governance() || msg.sender == IBaseStrategy(strategy).strategist(),
            "!management"
        );
        _;
    }
}

// File: AlphaHomoLender.sol

/********************
 *   A lender plugin for LenderYieldOptimiser for any erc20 asset on Cream (not eth)
 *   Made by SamPriestley.com
 *   https://github.com/Grandthrax/yearnv2/blob/master/contracts/GenericLender/GenericCream.sol
 *
 ********************* */

contract AlphaHomo is GenericLenderBase {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 private constant secondsPerYear = 31556952;
    address public constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant bank = address(0x67B66C99D3Eb37Fa76Aa3Ed1ff33E8e39F0b9c7A);

    constructor(address _strategy, string memory name) public GenericLenderBase(_strategy, name) {
        require(address(want) == weth, "NOT WETH");
        dust = 1e12;
        //want.approve(_cToken, uint256(-1));
    }

    receive() external payable {}

    function nav() external view override returns (uint256) {
        return _nav();
    }

    function _nav() internal view returns (uint256) {
        return want.balanceOf(address(this)).add(underlyingBalanceStored());
    }

    function withdrawUnderlying(uint256 amount) internal returns (uint256) {
        Bank b = Bank(bank);

        uint256 shares = amount.mul(b.totalSupply()).div(_bankTotalEth());
        //uint256 shares = amount.mul(b.glbDebtVal().add(b.pendingInterest(0))).div(b.glbDebtShare());
        // uint256 shares = b.debtValToShare(amount);
        uint256 balance = b.balanceOf(address(this));
        if (shares > balance) {
            b.withdraw(balance);
        } else {
            b.withdraw(shares);
        }

        uint256 withdrawn = address(this).balance;
        IWETH(weth).deposit{value: withdrawn}();

        return withdrawn;
    }

    function underlyingBalanceStored() public view returns (uint256 balance) {
        Bank b = Bank(bank);
        return b.balanceOf(address(this)).mul(_bankTotalEth()).div(b.totalSupply());
        //return b.balanceOf(address(this)).mul(b.glbDebtVal().add(b.pendingInterest(0))).div(b.glbDebtShare());
    }

    function _bankTotalEth() internal view returns (uint256 _totalEth) {
        Bank b = Bank(bank);

        uint256 interest = b.pendingInterest(0);
        BankConfig config = BankConfig(b.config());
        uint256 toReserve = interest.mul(config.getReservePoolBps()).div(10000);

        uint256 glbDebtVal = b.glbDebtVal().add(interest);
        uint256 reservePool = b.reservePool().add(toReserve);

        _totalEth = bank.balance.add(glbDebtVal).sub(reservePool);
    }

    function apr() external view override returns (uint256) {
        return _apr(0);
    }

    function aprAfterDeposit(uint256 amount) external view override returns (uint256) {
        return _apr(amount);
    }

    function _apr(uint256 amount) internal view returns (uint256) {
        Bank b = Bank(bank);
        BankConfig config = BankConfig(b.config());
        uint256 balance = bank.balance.add(amount);
        uint256 ratePerSec = config.getInterestRate(b.glbDebtVal(), balance);

        uint256 utilisation = uint256(1e18).mul(b.glbDebtVal()).div(b.totalETH());
        //10% is kept as reserves. So remove. Then multiply by utilisation to share per lender
        uint256 rate = ratePerSec.mul(9).div(10).mul(utilisation).div(1e18);

        return rate.mul(secondsPerYear);
    }

    function weightedApr() external view override returns (uint256) {
        uint256 a = _apr(0);
        return a.mul(_nav());
    }

    function withdraw(uint256 amount) external override management returns (uint256) {
        return _withdraw(amount);
    }

    //emergency withdraw. sends balance plus amount to governance
    function emergencyWithdraw(uint256 amount) external override management {
        withdrawUnderlying(amount);

        want.safeTransfer(vault.governance(), want.balanceOf(address(this)));
    }

    //withdraw an amount including any want balance
    function _withdraw(uint256 amount) internal returns (uint256) {
        uint256 balanceUnderlying = underlyingBalanceStored();
        uint256 looseBalance = want.balanceOf(address(this));
        uint256 total = balanceUnderlying.add(looseBalance);

        if (amount > total) {
            //cant withdraw more than we own
            amount = total;
        }
        if (looseBalance >= amount) {
            want.safeTransfer(address(strategy), amount);
            return amount;
        }

        //not state changing but OK because of previous call
        uint256 liquidity = bank.balance;

        if (liquidity > 1) {
            uint256 toWithdraw = amount.sub(looseBalance);

            if (toWithdraw <= liquidity) {
                //we can take all
                withdrawUnderlying(toWithdraw);
            } else {
                //take all we can
                withdrawUnderlying(liquidity);
            }
        }
        looseBalance = want.balanceOf(address(this));
        want.safeTransfer(address(strategy), looseBalance);
        return looseBalance;
    }

    function deposit() external override management {
        uint256 balance = want.balanceOf(address(this));

        IWETH(weth).withdraw(balance);
        Bank(bank).deposit{value: balance}();
    }

    function withdrawAll() external override management returns (bool) {
        uint256 invested = _nav();
        Bank b = Bank(bank);

        uint256 balance = b.balanceOf(address(this));

        b.withdraw(balance);

        uint256 withdrawn = address(this).balance;
        IWETH(weth).deposit{value: withdrawn}();
        uint256 returned = want.balanceOf(address(this));
        want.safeTransfer(address(strategy), returned);

        return returned.add(dust) >= invested;
    }

    //think about this
    function enabled() external view override returns (bool) {
        return true;
    }

    function hasAssets() external view override returns (bool) {
        uint256 bankBal = Bank(bank).balanceOf(address(this));
        uint256 wantBal = want.balanceOf(address(this));

        //adding apples to oranges but doesnt matter as we are just looking for rounding errors
        return bankBal.add(wantBal) > dust;
    }

    function protectedTokens() internal view override returns (address[] memory) {
        address[] memory protected = new address[](2);
        protected[0] = address(want);
        protected[1] = bank;
        return protected;
    }
}