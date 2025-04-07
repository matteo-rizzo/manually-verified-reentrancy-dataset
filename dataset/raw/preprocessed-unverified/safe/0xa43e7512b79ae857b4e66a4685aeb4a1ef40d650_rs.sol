/**
 *Submitted for verification at Etherscan.io on 2021-04-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: IAlphaV2



// Part: ICErc20



// Part: IFund



// Part: IGovernable



// Part: IStrategy



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/Math

/**
 * @dev Standard math utilities missing in the Solidity language.
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


// Part: AlphaV2LendingStrategyBase

/**
 * This strategy takes an asset (DAI, USDC), lends to AlphaV2 Lending Box.
 */
contract AlphaV2LendingStrategyBase is IStrategy {
    enum TokenIndex {DAI, USDC}

    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public override underlying;
    address public override fund;
    address public override creator;

    // the matching enum record used to determine the index
    TokenIndex tokenIndex;

    // the alphasafebox corresponding to the underlying asset
    address public aBox;

    // these tokens cannot be claimed by the governance
    mapping(address => bool) public canNotSweep;

    bool public investActivated;

    constructor(
        address _fund,
        address _aBox,
        uint256 _tokenIndex
    ) public {
        require(_fund != address(0), "Fund cannot be empty");
        fund = _fund;
        underlying = IFund(fund).underlying();
        tokenIndex = TokenIndex(_tokenIndex);
        aBox = _aBox;
        creator = msg.sender;

        // restricted tokens, can not be swept
        canNotSweep[underlying] = true;
        canNotSweep[aBox] = true;

        investActivated = true;
    }

    function governance() internal view returns (address) {
        return IGovernable(fund).governance();
    }

    modifier onlyFundOrGovernance() {
        require(
            msg.sender == fund || msg.sender == governance(),
            "The sender has to be the governance or fund"
        );
        _;
    }

    /**
     *  TODO
     */
    function depositArbCheck() public view override returns (bool) {
        return true;
    }

    /**
     * Allows Governance to withdraw partial shares to reduce slippage incurred
     *  and facilitate migration / withdrawal / strategy switch
     */
    function withdrawPartialShares(uint256 shares)
        external
        onlyFundOrGovernance
    {
        IAlphaV2(aBox).withdraw(shares);
    }

    function setInvestActivated(bool _investActivated)
        external
        onlyFundOrGovernance
    {
        investActivated = _investActivated;
    }

    /**
     * Withdraws an underlying asset from the strategy to the fund in the specified amount.
     * It tries to withdraw from the strategy contract if this has enough balance.
     * Otherwise, we withdraw shares from the Alpha V2 Lending Box. Transfer the required underlying amount to fund,
     * and reinvest the rest. We can make it better by calculating the correct amount and withdrawing only that much.
     */
    function withdrawToFund(uint256 underlyingAmount)
        external
        override
        onlyFundOrGovernance
    {
        uint256 underlyingBalanceBefore =
            IERC20(underlying).balanceOf(address(this));

        if (underlyingBalanceBefore >= underlyingAmount) {
            IERC20(underlying).safeTransfer(fund, underlyingAmount);
            return;
        }

        uint256 shares =
            shareValueFromUnderlying(
                underlyingAmount.sub(underlyingBalanceBefore)
            );
        IAlphaV2(aBox).withdraw(shares);

        // we can transfer the asset to the fund
        uint256 underlyingBalance = IERC20(underlying).balanceOf(address(this));
        if (underlyingBalance > 0) {
            IERC20(underlying).safeTransfer(
                fund,
                Math.min(underlyingAmount, underlyingBalance)
            );
        }
    }

    /**
     * Withdraws all assets from the Alpha V2 Lending Box and transfers to Fund.
     */
    function withdrawAllToFund() external override onlyFundOrGovernance {
        uint256 shares = IAlphaV2(aBox).balanceOf(address(this));
        IAlphaV2(aBox).withdraw(shares);
        uint256 underlyingBalance = IERC20(underlying).balanceOf(address(this));
        if (underlyingBalance > 0) {
            IERC20(underlying).safeTransfer(fund, underlyingBalance);
        }
    }

    /**
     * Invests all underlying assets into our Alpha V2 Lending Box.
     */
    function investAllUnderlying() internal {
        if (!investActivated) {
            return;
        }

        uint256 underlyingBalance = IERC20(underlying).balanceOf(address(this));
        if (underlyingBalance > 0) {
            IERC20(underlying).safeApprove(aBox, 0);
            IERC20(underlying).safeApprove(aBox, underlyingBalance);
            // deposits the entire balance to Alpha V2 Lending Box
            IAlphaV2(aBox).deposit(underlyingBalance);
        }
    }

    /**
     * The hard work only invests all underlying assets
     */
    function doHardWork() public override onlyFundOrGovernance {
        investAllUnderlying();
    }

    // no tokens apart from underlying should be sent to this contract. Any tokens that are sent here by mistake are recoverable by governance
    function sweep(address _token, address _sweepTo) external {
        require(governance() == msg.sender, "Not governance");
        require(!canNotSweep[_token], "Token is restricted");
        IERC20(_token).safeTransfer(
            _sweepTo,
            IERC20(_token).balanceOf(address(this))
        );
    }

    /**
     * Keeping this here as I did not find how to get totalReward
     */
    function claim(uint256 totalReward, bytes32[] memory proof)
        external
        onlyFundOrGovernance
    {
        IAlphaV2(aBox).claim(totalReward, proof);
    }

    /**
     * Returns the underlying invested balance. This is the underlying amount based on yield bearing token balance,
     * plus the current balance of the underlying asset.
     */
    function investedUnderlyingBalance()
        external
        view
        override
        returns (uint256)
    {
        uint256 shares = IERC20(aBox).balanceOf(address(this));
        address cToken = IAlphaV2(aBox).cToken();
        uint256 exchangeRate = ICErc20(cToken).exchangeRateStored();
        uint256 precision = 10**18;
        uint256 underlyingBalanceinABox =
            shares.mul(exchangeRate).div(precision);
        return
            underlyingBalanceinABox.add(
                IERC20(underlying).balanceOf(address(this))
            );
    }

    /**
     * Returns the value of the underlying token in aBox ibToken
     */
    function shareValueFromUnderlying(uint256 underlyingAmount)
        internal
        view
        returns (uint256)
    {
        return
            underlyingAmount.mul(10**18).div(
                ICErc20(IAlphaV2(aBox).cToken()).exchangeRateStored()
            );
    }
}

// File: AlphaV2LendingStrategyMainnet.sol

/**
 * Adds the mainnet addresses to the AlphaV2LendingStrategyBase
 */
contract AlphaV2LendingStrategyMainnet is AlphaV2LendingStrategyBase {
    // token addresses
    address public constant dai =
        address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address public constant ibdaiv2 =
        address(0xee8389d235E092b2945fE363e97CDBeD121A0439);
    address public constant usdc =
        address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public constant ibusdcv2 =
        address(0x08bd64BFC832F1C2B3e07e634934453bA7Fa2db2);

    // pre-defined constant mapping: underlying -> aBox
    mapping(address => address) public aBoxes;

    constructor(address _fund)
        public
        AlphaV2LendingStrategyBase(_fund, address(0), 0)
    {
        aBoxes[dai] = ibdaiv2;
        aBoxes[usdc] = ibusdcv2;
        aBox = aBoxes[underlying];
        require(
            aBox != address(0),
            "underlying not supported: aBox is not defined"
        );
        if (underlying == dai) {
            tokenIndex = TokenIndex.DAI;
        } else if (underlying == usdc) {
            tokenIndex = TokenIndex.USDC;
        } else {
            revert("Asset not supported");
        }
    }
}