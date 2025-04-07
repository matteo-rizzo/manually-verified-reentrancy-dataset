/**
 *Submitted for verification at Etherscan.io on 2019-06-21
*/

pragma solidity ^0.5.8;


/**
 * @title Math
 * @dev Assorted math operations
 */



/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



/**
 * @title TokenSale
 */
contract TokenSale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // token for sale
    IERC20 public saleToken;

    // address where funds are collected
    address public fundCollector;

    // address where has tokens to sell
    address public tokenWallet;

    // use whitelist[user] to get whether the user was allowed to buy
    mapping(address => bool) public whitelist;

    // exchangeable token
    struct ExToken {
        bool accepted;
        uint256 rate;
    }

    // exchangeable tokens
    mapping(address => ExToken) private _exTokens;

    // bonus threshold
    uint256 public bonusThreshold;

    // tier-1 bonus
    uint256 public tierOneBonusTime;
    uint256 public tierOneBonusRate;

    // tier-2 bonus
    uint256 public tierTwoBonusTime;
    uint256 public tierTwoBonusRate;

    /**
     * @param setter who set fund collector
     * @param fundCollector address of fund collector
     */
    event FundCollectorSet(
        address indexed setter,
        address indexed fundCollector
    );

    /**
     * @param setter who set sale token
     * @param saleToken address of sale token
     */
    event SaleTokenSet(
        address indexed setter,
        address indexed saleToken
    );

    /**
     * @param setter who set token wallet
     * @param tokenWallet address of token wallet
     */
    event TokenWalletSet(
        address indexed setter,
        address indexed tokenWallet
    );

    /**
     * @param setter who set bonus threshold
     * @param bonusThreshold exceed the threshold will get bonus
     * @param tierOneBonusTime tier one bonus timestamp
     * @param tierOneBonusRate tier one bonus rate
     * @param tierTwoBonusTime tier two bonus timestamp
     * @param tierTwoBonusRate tier two bonus rate
     */
    event BonusConditionsSet(
        address indexed setter,
        uint256 bonusThreshold,
        uint256 tierOneBonusTime,
        uint256 tierOneBonusRate,
        uint256 tierTwoBonusTime,
        uint256 tierTwoBonusRate
    );

    /**
     * @param setter who set the whitelist
     * @param user address of the user
     * @param allowed whether the user allowed to buy
     */
    event WhitelistSet(
        address indexed setter,
        address indexed user,
        bool allowed
    );

    /**
     * event for logging exchangeable token updates
     * @param setter who set the exchangeable token
     * @param exToken the exchangeable token
     * @param accepted whether the exchangeable token was accepted
     * @param rate exchange rate of the exchangeable token
     */
    event ExTokenSet(
        address indexed setter,
        address indexed exToken,
        bool accepted,
        uint256 rate
    );

    /**
     * event for token purchase logging
     * @param buyer address of token buyer
     * @param exToken address of the exchangeable token
     * @param exTokenAmount amount of the exchangeable tokens
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(
        address indexed buyer,
        address indexed exToken,
        uint256 exTokenAmount,
        uint256 amount
    );

    /**
     * @param fundCollector address where collected funds will be forwarded to
     * @param saleToken address of the token being sold
     * @param tokenWallet address of wallet has tokens to sell
     */
    constructor (
        address fundCollector,
        address saleToken,
        address tokenWallet,
        uint256 bonusThreshold,
        uint256 tierOneBonusTime,
        uint256 tierOneBonusRate,
        uint256 tierTwoBonusTime,
        uint256 tierTwoBonusRate
    )
        public
    {
        _setFundCollector(fundCollector);
        _setSaleToken(saleToken);
        _setTokenWallet(tokenWallet);
        _setBonusConditions(
            bonusThreshold,
            tierOneBonusTime,
            tierOneBonusRate,
            tierTwoBonusTime,
            tierTwoBonusRate
        );

    }

    /**
     * @param fundCollector address of the fund collector
     */
    function setFundCollector(address fundCollector) external onlyOwner {
        _setFundCollector(fundCollector);
    }

    /**
     * @param collector address of the fund collector
     */
    function _setFundCollector(address collector) private {
        require(collector != address(0), "fund collector cannot be 0x0");
        fundCollector = collector;
        emit FundCollectorSet(msg.sender, collector);
    }

    /**
     * @param saleToken address of the sale token
     */
    function setSaleToken(address saleToken) external onlyOwner {
        _setSaleToken(saleToken);
    }

    /**
     * @param token address of the sale token
     */
    function _setSaleToken(address token) private {
        require(token != address(0), "sale token cannot be 0x0");
        saleToken = IERC20(token);
        emit SaleTokenSet(msg.sender, token);
    }

    /**
     * @param tokenWallet address of the token wallet
     */
    function setTokenWallet(address tokenWallet) external onlyOwner {
        _setTokenWallet(tokenWallet);
    }

    /**
     * @param wallet address of the token wallet
     */
    function _setTokenWallet(address wallet) private {
        require(wallet != address(0), "token wallet cannot be 0x0");
        tokenWallet = wallet;
        emit TokenWalletSet(msg.sender, wallet);
    }

    /**
     * @param threshold exceed the threshold will get bonus
     * @param t1BonusTime before t1 bonus timestamp will use t1 bonus rate
     * @param t1BonusRate tier-1 bonus rate
     * @param t2BonusTime before t2 bonus timestamp will use t2 bonus rate
     * @param t2BonusRate tier-2 bonus rate
     */
    function setBonusConditions(
        uint256 threshold,
        uint256 t1BonusTime,
        uint256 t1BonusRate,
        uint256 t2BonusTime,
        uint256 t2BonusRate
    )
        external
        onlyOwner
    {
        _setBonusConditions(
            threshold,
            t1BonusTime,
            t1BonusRate,
            t2BonusTime,
            t2BonusRate
        );
    }

    /**
     * @param threshold exceed the threshold will get bonus
     */
    function _setBonusConditions(
        uint256 threshold,
        uint256 t1BonusTime,
        uint256 t1BonusRate,
        uint256 t2BonusTime,
        uint256 t2BonusRate
    )
        private
        onlyOwner
    {
        require(threshold > 0," threshold cannot be zero.");
        require(t1BonusTime < t2BonusTime, "invalid bonus time");
        require(t1BonusRate >= t2BonusRate, "invalid bonus rate");

        bonusThreshold = threshold;
        tierOneBonusTime = t1BonusTime;
        tierOneBonusRate = t1BonusRate;
        tierTwoBonusTime = t2BonusTime;
        tierTwoBonusRate = t2BonusRate;

        emit BonusConditionsSet(
            msg.sender,
            threshold,
            t1BonusTime,
            t1BonusRate,
            t2BonusTime,
            t2BonusRate
        );
    }

    /**
     * @notice set allowed to ture to add the user into the whitelist
     * @notice set allowed to false to remove the user from the whitelist
     * @param user address of user
     * @param allowed whether allow the user to deposit/withdraw or not
     */
    function setWhitelist(address user, bool allowed) external onlyOwner {
        whitelist[user] = allowed;
        emit WhitelistSet(msg.sender, user, allowed);
    }

    /**
     * @dev checks the amount of tokens left in the allowance.
     * @return amount of tokens left in the allowance
     */
    function remainingTokens() external view returns (uint256) {
        return Math.min(
            saleToken.balanceOf(tokenWallet),
            saleToken.allowance(tokenWallet, address(this))
        );
    }

    /**
     * @param exToken address of the exchangeable token
     * @param accepted true: accepted; false: rejected
     * @param rate exchange rate
     */
    function setExToken(
        address exToken,
        bool accepted,
        uint256 rate
    )
        external
        onlyOwner
    {
        _exTokens[exToken].accepted = accepted;
        _exTokens[exToken].rate = rate;
        emit ExTokenSet(msg.sender, exToken, accepted, rate);
    }

    /**
     * @param exToken address of the exchangeable token
     * @return whether the exchangeable token is accepted or not
     */
    function accepted(address exToken) public view returns (bool) {
        return _exTokens[exToken].accepted;
    }

    /**
     * @param exToken address of the exchangeale token
     * @return amount of sale token a buyer gets per exchangeable token
     */
    function rate(address exToken) external view returns (uint256) {
        return _exTokens[exToken].rate;
    }

    /**
     * @dev get exchangeable sale token amount
     * @param exToken address of the exchangeable token
     * @param amount amount of the exchangeable token (how much to pay)
     * @return purchased sale token amount
     */
    function exchangeableAmounts(
        address exToken,
        uint256 amount
    )
        external
        view
        returns (uint256)
    {
        return _getTokenAmount(exToken, amount);
    }

    /**
     * @dev buy tokens
     * @dev buyer must be in whitelist
     * @param exToken address of the exchangeable token
     * @param amount amount of the exchangeable token
     */
    function buyTokens(
        address exToken,
        uint256 amount
    )
        external
    {
        require(_exTokens[exToken].accepted, "token was not accepted");
        require(amount != 0, "amount cannot 0");
        require(whitelist[msg.sender], "buyer must be in whitelist");
        // calculate token amount to sell
        uint256 tokens = _getTokenAmount(exToken, amount);
        require(tokens >= 10**19, "at least buy 10 tokens per purchase");
        _forwardFunds(exToken, amount);
        _processPurchase(msg.sender, tokens);
        emit TokensPurchased(msg.sender, exToken, amount, tokens);
    }

    /**
     * @dev buyer transfers amount of the exchangeable token to fund collector
     * @param exToken address of the exchangeable token
     * @param amount amount of the exchangeable token will send to fund collector
     */
    function _forwardFunds(address exToken, uint256 amount) private {
        IERC20(exToken).safeTransferFrom(msg.sender, fundCollector, amount);
    }

    /**
     * @dev calculated purchased sale token amount
     * @param exToken address of the exchangeable token
     * @param amount amount of the exchangeable token (how much to pay)
     * @return amount of purchased sale token
     */
    function _getTokenAmount(
        address exToken,
        uint256 amount
    )
        private
        view
        returns (uint256)
    {
        // round down value (v) by multiple (m) = (v / m) * m
        uint256 value = amount
            .div(100000000000000000)
            .mul(100000000000000000)
            .mul(_exTokens[exToken].rate);
        return _applyBonus(value);
    }

    function _applyBonus(
        uint256 amount
    )
        private
        view
        returns (uint256)
    {
        if (amount < bonusThreshold) {
            return amount;
        }

        if (block.timestamp <= tierOneBonusTime) {
            return amount.mul(tierOneBonusRate).div(100);
        } else if (block.timestamp <= tierTwoBonusTime) {
            return amount.mul(tierTwoBonusRate).div(100);
        } else {
            return amount;
        }
    }

    /**
     * @dev transfer sale token amounts from token wallet to beneficiary
     * @param beneficiary purchased tokens will transfer to this address
     * @param tokenAmount purchased token amount
     */
    function _processPurchase(
        address beneficiary,
        uint256 tokenAmount
    )
        private
    {
        saleToken.safeTransferFrom(tokenWallet, beneficiary, tokenAmount);
    }
}