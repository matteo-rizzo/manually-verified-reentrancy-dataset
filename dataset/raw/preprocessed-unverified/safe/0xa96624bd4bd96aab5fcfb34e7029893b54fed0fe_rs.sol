/**
 *Submitted for verification at Etherscan.io on 2019-08-05
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
 * @title interface for unsafe ERC20
 * @dev Unsafe ERC20 does not return when transfer, approve, transferFrom
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
        bool safe;
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
     * @param _setter who set USDT
     * @param _usdt address of USDT
     */
    event USDTSet(
        address indexed _setter,
        address indexed _usdt
    );

    /**
     * @param _setter who set fund collector
     * @param _fundCollector address of fund collector
     */
    event FundCollectorSet(
        address indexed _setter,
        address indexed _fundCollector
    );

    /**
     * @param _setter who set sale token
     * @param _saleToken address of sale token
     */
    event SaleTokenSet(
        address indexed _setter,
        address indexed _saleToken
    );

    /**
     * @param _setter who set token wallet
     * @param _tokenWallet address of token wallet
     */
    event TokenWalletSet(
        address indexed _setter,
        address indexed _tokenWallet
    );

    /**
     * @param _setter who set bonus threshold
     * @param _bonusThreshold exceed the threshold will get bonus
     * @param _tierOneBonusTime tier one bonus timestamp
     * @param _tierOneBonusRate tier one bonus rate
     * @param _tierTwoBonusTime tier two bonus timestamp
     * @param _tierTwoBonusRate tier two bonus rate
     */
    event BonusConditionsSet(
        address indexed _setter,
        uint256 _bonusThreshold,
        uint256 _tierOneBonusTime,
        uint256 _tierOneBonusRate,
        uint256 _tierTwoBonusTime,
        uint256 _tierTwoBonusRate
    );

    /**
     * @param _setter who set the whitelist
     * @param _user address of the user
     * @param _allowed whether the user allowed to buy
     */
    event WhitelistSet(
        address indexed _setter,
        address indexed _user,
        bool _allowed
    );

    /**
     * event for logging exchangeable token updates
     * @param _setter who set the exchangeable token
     * @param _exToken the exchangeable token
     * @param _safe whether the exchangeable token is a safe ERC20
     * @param _accepted whether the exchangeable token was accepted
     * @param _rate exchange rate of the exchangeable token
     */
    event ExTokenSet(
        address indexed _setter,
        address indexed _exToken,
        bool _safe,
        bool _accepted,
        uint256 _rate
    );

    /**
     * event for token purchase logging
     * @param _buyer address of token buyer
     * @param _exToken address of the exchangeable token
     * @param _exTokenAmount amount of the exchangeable tokens
     * @param _amount amount of tokens purchased
     */
    event TokensPurchased(
        address indexed _buyer,
        address indexed _exToken,
        uint256 _exTokenAmount,
        uint256 _amount
    );

    constructor (
        address _fundCollector,
        address _saleToken,
        address _tokenWallet,
        uint256 _bonusThreshold,
        uint256 _tierOneBonusTime,
        uint256 _tierOneBonusRate,
        uint256 _tierTwoBonusTime,
        uint256 _tierTwoBonusRate
    )
        public
    {
        _setFundCollector(_fundCollector);
        _setSaleToken(_saleToken);
        _setTokenWallet(_tokenWallet);
        _setBonusConditions(
            _bonusThreshold,
            _tierOneBonusTime,
            _tierOneBonusRate,
            _tierTwoBonusTime,
            _tierTwoBonusRate
        );

    }

    /**
     * @param _fundCollector address of the fund collector
     */
    function setFundCollector(address _fundCollector) external onlyOwner {
        _setFundCollector(_fundCollector);
    }

    /**
     * @param _fundCollector address of the fund collector
     */
    function _setFundCollector(address _fundCollector) private {
        require(_fundCollector != address(0), "fund collector cannot be 0x0");
        fundCollector = _fundCollector;
        emit FundCollectorSet(msg.sender, _fundCollector);
    }

    /**
     * @param _saleToken address of the sale token
     */
    function setSaleToken(address _saleToken) external onlyOwner {
        _setSaleToken(_saleToken);
    }

    /**
     * @param _saleToken address of the sale token
     */
    function _setSaleToken(address _saleToken) private {
        require(_saleToken != address(0), "sale token cannot be 0x0");
        saleToken = IERC20(_saleToken);
        emit SaleTokenSet(msg.sender, _saleToken);
    }

    /**
     * @param _tokenWallet address of the token wallet
     */
    function setTokenWallet(address _tokenWallet) external onlyOwner {
        _setTokenWallet(_tokenWallet);
    }

    /**
     * @param _tokenWallet address of the token wallet
     */
    function _setTokenWallet(address _tokenWallet) private {
        require(_tokenWallet != address(0), "token wallet cannot be 0x0");
        tokenWallet = _tokenWallet;
        emit TokenWalletSet(msg.sender, _tokenWallet);
    }

    /**
     * @param _bonusThreshold exceed the threshold will get bonus
     * @param _tierOneBonusTime before t1 bonus timestamp will use t1 bonus rate
     * @param _tierOneBonusRate tier-1 bonus rate
     * @param _tierTwoBonusTime before t2 bonus timestamp will use t2 bonus rate
     * @param _tierTwoBonusRate tier-2 bonus rate
     */
    function setBonusConditions(
        uint256 _bonusThreshold,
        uint256 _tierOneBonusTime,
        uint256 _tierOneBonusRate,
        uint256 _tierTwoBonusTime,
        uint256 _tierTwoBonusRate
    )
        external
        onlyOwner
    {
        _setBonusConditions(
            _bonusThreshold,
            _tierOneBonusTime,
            _tierOneBonusRate,
            _tierTwoBonusTime,
            _tierTwoBonusRate
        );
    }

    function _setBonusConditions(
        uint256 _bonusThreshold,
        uint256 _tierOneBonusTime,
        uint256 _tierOneBonusRate,
        uint256 _tierTwoBonusTime,
        uint256 _tierTwoBonusRate
    )
        private
        onlyOwner
    {
        require(_bonusThreshold > 0," threshold cannot be zero.");
        require(_tierOneBonusTime < _tierTwoBonusTime, "invalid bonus time");
        require(_tierOneBonusRate >= _tierTwoBonusRate, "invalid bonus rate");

        bonusThreshold = _bonusThreshold;
        tierOneBonusTime = _tierOneBonusTime;
        tierOneBonusRate = _tierOneBonusRate;
        tierTwoBonusTime = _tierTwoBonusTime;
        tierTwoBonusRate = _tierTwoBonusRate;

        emit BonusConditionsSet(
            msg.sender,
            _bonusThreshold,
            _tierOneBonusTime,
            _tierOneBonusRate,
            _tierTwoBonusTime,
            _tierTwoBonusRate
        );
    }

    /**
     * @notice set allowed to ture to add the user into the whitelist
     * @notice set allowed to false to remove the user from the whitelist
     * @param _user address of user
     * @param _allowed whether allow the user to deposit/withdraw or not
     */
    function setWhitelist(address _user, bool _allowed) external onlyOwner {
        whitelist[_user] = _allowed;
        emit WhitelistSet(msg.sender, _user, _allowed);
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
     * @param _exToken address of the exchangeable token
     * @param _safe whether it is a safe ERC20
     * @param _accepted true: accepted; false: rejected
     * @param _rate exchange rate
     */
    function setExToken(
        address _exToken,
        bool _safe,
        bool _accepted,
        uint256 _rate
    )
        external
        onlyOwner
    {
        _exTokens[_exToken].safe = _safe;
        _exTokens[_exToken].accepted = _accepted;
        _exTokens[_exToken].rate = _rate;
        emit ExTokenSet(msg.sender, _exToken, _safe, _accepted, _rate);
    }

    /**
     * @param _exToken address of the exchangeable token
     * @return whether the exchangeable token is a safe ERC20
     */
    function safe(address _exToken) public view returns (bool) {
        return _exTokens[_exToken].safe;
    }

    /**
     * @param _exToken address of the exchangeable token
     * @return whether the exchangeable token is accepted or not
     */
    function accepted(address _exToken) public view returns (bool) {
        return _exTokens[_exToken].accepted;
    }

    /**
     * @param _exToken address of the exchangeale token
     * @return amount of sale token a buyer gets per exchangeable token
     */
    function rate(address _exToken) external view returns (uint256) {
        return _exTokens[_exToken].rate;
    }

    /**
     * @dev get exchangeable sale token amount
     * @param _exToken address of the exchangeable token
     * @param _amount amount of the exchangeable token (how much to pay)
     * @return purchased sale token amount
     */
    function exchangeableAmounts(
        address _exToken,
        uint256 _amount
    )
        external
        view
        returns (uint256)
    {
        return _getTokenAmount(_exToken, _amount);
    }

    /**
     * @dev buy tokens
     * @dev buyer must be in whitelist
     * @param _exToken address of the exchangeable token
     * @param _amount amount of the exchangeable token
     */
    function buyTokens(
        address _exToken,
        uint256 _amount
    )
        external
    {
        require(_exTokens[_exToken].accepted, "token was not accepted");
        require(_amount != 0, "amount cannot 0");
        require(whitelist[msg.sender], "buyer must be in whitelist");
        // calculate token amount to sell
        uint256 _tokens = _getTokenAmount(_exToken, _amount);
        require(_tokens >= 10**18, "at least buy 1 tokens per purchase");
        _forwardFunds(_exToken, _amount);
        _processPurchase(msg.sender, _tokens);
        emit TokensPurchased(msg.sender, _exToken, _amount, _tokens);
    }

    /**
     * @dev buyer transfers amount of the exchangeable token to fund collector
     * @param _exToken address of the exchangeable token
     * @param _amount amount of the exchangeable token will send to fund collector
     */
    function _forwardFunds(address _exToken, uint256 _amount) private {
        if (_exTokens[_exToken].safe) {
            IERC20(_exToken).safeTransferFrom(msg.sender, fundCollector, _amount);
        } else {
            IUnsafeERC20(_exToken).transferFrom(msg.sender, fundCollector, _amount);
        }
    }

    /**
     * @dev calculated purchased sale token amount
     * @param _exToken address of the exchangeable token
     * @param _amount amount of the exchangeable token (how much to pay)
     * @return amount of purchased sale token
     */
    function _getTokenAmount(
        address _exToken,
        uint256 _amount
    )
        private
        view
        returns (uint256)
    {
        // round down value (v) by multiple (m) = (v / m) * m
        uint256 _value = _amount
            .mul(_exTokens[_exToken].rate)
            .div(1000000000000000000)
            .mul(1000000000000000000);
        return _applyBonus(_value);
    }

    function _applyBonus(
        uint256 _amount
    )
        private
        view
        returns (uint256)
    {
        if (_amount < bonusThreshold) {
            return _amount;
        }

        if (block.timestamp <= tierOneBonusTime) {
            return _amount.mul(tierOneBonusRate).div(100);
        } else if (block.timestamp <= tierTwoBonusTime) {
            return _amount.mul(tierTwoBonusRate).div(100);
        } else {
            return _amount;
        }
    }

    /**
     * @dev transfer sale token amounts from token wallet to beneficiary
     * @param _beneficiary purchased tokens will transfer to this address
     * @param _tokenAmount purchased token amount
     */
    function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount
    )
        private
    {
        saleToken.safeTransferFrom(tokenWallet, _beneficiary, _tokenAmount);
    }
}