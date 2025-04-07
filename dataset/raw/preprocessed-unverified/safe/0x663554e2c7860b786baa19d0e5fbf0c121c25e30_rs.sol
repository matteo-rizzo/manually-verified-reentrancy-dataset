/**
 *Submitted for verification at Etherscan.io on 2020-10-04
*/

pragma solidity ^0.6.12;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



















/*

 A strategy must implement the following calls;

 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()

 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller

*/

contract StrategyStableUSD {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    enum TokenIndex {DAI, USDC, USDT}

    address public governance;
    address public controller;

    address public yVault;
    address public curve = address(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
    address public ycrv = address(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);
    address public ycrvVault;

    address public want;
    address constant public crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);

    TokenIndex public tokenIndex;
    IConvertor public zap = IConvertor(0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3);

    constructor(address _controller, TokenIndex _tokenIndex, address _ycrvVault) public {
        governance = msg.sender;
        controller = _controller;

        tokenIndex = _tokenIndex;
        ycrvVault = _ycrvVault;

        if (tokenIndex == TokenIndex.DAI) {
            want = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
            yVault = 0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01;
        } else if (tokenIndex == TokenIndex.USDC) {
            want = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
            yVault = 0xd6aD7a6750A7593E092a9B218d66C0A814a3436e;
        } else if (tokenIndex == TokenIndex.USDT) {
            want = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
            yVault = 0x83f798e925BcD4017Eb265844FDDAbb448f1707D;
        } else {
            revert('!tokenIndex');
        }
    }

    function getName() external pure returns (string memory) {
        return "StrategyStableUSD";
    }

    function deposit() public {
        uint256 _balance = IERC20(want).balanceOf(address(this));
        if (_balance > 0) {
            IERC20(want).safeApprove(yVault, 0);
            IERC20(want).safeApprove(yVault, _balance);
            yERC20(yVault).deposit(_balance);
        }

        uint256 yBalance = IERC20(yVault).balanceOf(address(this));
        if (yBalance > 0) {
            IERC20(yVault).safeApprove(curve, 0);
            IERC20(yVault).safeApprove(curve, yBalance);

            uint256[4] memory amounts = [uint256(0), uint256(0), uint256(0), uint256(0)];
            amounts[uint256(tokenIndex)] = yBalance;

            ICurveFi(curve).add_liquidity(
                amounts, 0
            );
        }

        uint256 ycrvBalance = IERC20(ycrv).balanceOf(address(this));
        if (ycrvBalance > 0) {
            IERC20(ycrv).safeApprove(ycrvVault, 0);
            IERC20(ycrv).safeApprove(ycrvVault, ycrvBalance);
            // deposits the entire balance and also asks the vault to invest it (public function)
            Vault(ycrvVault).deposit(ycrvBalance);
        }
    }

    function balanceOf() external view returns (uint) {
        uint256 shares = IERC20(ycrvVault).balanceOf(address(this));
        if (shares == 0) {
            return 0;
        }

        uint256 price = Vault(ycrvVault).getPricePerFullShare();
        // the price is in yCRV units, because this is a yCRV vault
        // the multiplication doubles the number of decimals for shares, so we need to divide
        // the precision is always 10 ** 18 as the yCRV vault has 18 decimals
        uint256 precision = 1e18;
        uint256 ycrvBalance = shares.mul(price).div(precision);
        // now we can convert the balance to the token amount
        uint256 ycrvValue = underlyingValueFromYCrv(ycrvBalance);
        return ycrvValue.add(IERC20(want).balanceOf(address(this)));
    }

    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        require(crv != address(_asset), "crv");
        require(ycrv != address(_asset), "ycrv");

        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    function withdraw(uint _amount) external {
        require(msg.sender == controller, "!controller");
        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _withdrawSome(_amount.sub(_balance));
            _amount = Math.min(_amount, IERC20(want).balanceOf(address(this)));
        }

        address _vault = Controller(controller).vaults(address(this));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds

        IERC20(want).safeTransfer(_vault, _amount);
    }

    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        uint256 shares = IERC20(ycrvVault).balanceOf(address(this));
        Vault(ycrvVault).withdraw(shares);

        yCurveToUnderlying(uint256(~0));
        balance = IERC20(want).balanceOf(address(this));
        if (balance > 0) {
            address vault = Controller(controller).vaults(address(this));
            require(vault != address(0), "!vault"); // additional protection so we don't burn the funds
            IERC20(want).safeTransfer(vault, balance);
        }
    }

    /**
    * Returns the value of yCRV in y-token (e.g., yCRV -> yDai) accounting for slippage and fees.
    */
    function underlyingValueFromYCrv(uint256 ycrvBalance) public view returns (uint256) {
        return zap.calc_withdraw_one_coin(ycrvBalance, int128(tokenIndex));
    }

    function _withdrawSome(uint256 _amount) internal returns (uint) {
        uint shares = IERC20(ycrvVault).balanceOf(address(this));
        Vault(ycrvVault).withdraw(shares);
        yCurveToUnderlying(_amount);

        uint remains = IERC20(ycrv).balanceOf(address(this));
        if (remains > 0) {
            IERC20(ycrv).safeApprove(ycrvVault, 0);
            IERC20(ycrv).safeApprove(ycrvVault, remains);
            Vault(ycrvVault).deposit(remains);
        }
        return _amount;
    }

    /**
    * Uses the Curve protocol to convert the yCRV back into the underlying asset. If it cannot acquire
    * the limit amount, it will acquire the maximum it can.
    */
    function yCurveToUnderlying(uint256 underlyingLimit) internal {
        uint256 ycrvBalance = IERC20(ycrv).balanceOf(address(this));

        // this is the maximum number of y-tokens we can get for our yCRV
        uint256 yTokenMaximumAmount = yTokenValueFromYCrv(ycrvBalance);
        if (yTokenMaximumAmount == 0) {
            return;
        }

        // ensure that we will not overflow in the conversion
        uint256 yTokenDesiredAmount = underlyingLimit == uint256(~0) ?
        yTokenMaximumAmount : yTokenValueFromUnderlying(underlyingLimit);

        uint256[4] memory yTokenAmounts = wrapCoinAmount(
            Math.min(yTokenMaximumAmount, yTokenDesiredAmount));
        uint256 yUnderlyingBalanceBefore = IERC20(yVault).balanceOf(address(this));
        IERC20(ycrv).safeApprove(curve, 0);
        IERC20(ycrv).safeApprove(curve, ycrvBalance);
        ICurveFi(curve).remove_liquidity_imbalance(
            yTokenAmounts, ycrvBalance
        );
        // now we have yUnderlying asset
        uint256 yUnderlyingBalanceAfter = IERC20(yVault).balanceOf(address(this));
        if (yUnderlyingBalanceAfter > yUnderlyingBalanceBefore) {
            // we received new yUnderlying tokens for yCRV
            yERC20(yVault).withdraw(yUnderlyingBalanceAfter.sub(yUnderlyingBalanceBefore));
        }
    }

    /**
    * Returns the value of yCRV in underlying token accounting for slippage and fees.
    */
    function yTokenValueFromYCrv(uint256 ycrvBalance) public view returns (uint256) {
        return underlyingValueFromYCrv(ycrvBalance) // this is in DAI, we will convert to yDAI
        .mul(10 ** 18)
        .div(Vault(yVault).getPricePerFullShare()); // function getPricePerFullShare() has 18 decimals for all tokens
    }

    /**
    * Returns the value of the underlying token in yToken
    */
    function yTokenValueFromUnderlying(uint256 amountUnderlying) public view returns (uint256) {
        // 1 yToken = this much underlying, 10 ** 18 precision for all tokens
        return amountUnderlying
        .mul(1e18)
        .div(Vault(yVault).getPricePerFullShare());
    }

    /**
    * Wraps the coin amount in the array for interacting with the Curve protocol
    */
    function wrapCoinAmount(uint256 amount) internal view returns (uint256[4] memory) {
        uint256[4] memory amounts = [uint256(0), uint256(0), uint256(0), uint256(0)];
        amounts[uint56(tokenIndex)] = amount;
        return amounts;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
}