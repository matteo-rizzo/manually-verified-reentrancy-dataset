/**
 *Submitted for verification at Etherscan.io on 2021-07-10
*/

pragma solidity 0.5.17;

/**
 * @dev Collection of functions related to the address type
 */


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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/**
 * @title The interface for the Kyber Network smart contract
 * @author Zefram Lou (Zebang Liu)
 */



/**
 * @title The smart contract for useful utility functions and constants.
 * @author Zefram Lou (Zebang Liu)
 */
contract Utils {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Detailed;

    /**
     * @notice Checks if `_token` is a valid token.
     * @param _token the token's address
     */
    modifier isValidToken(address _token) {
        require(_token != address(0));
        if (_token != address(ETH_TOKEN_ADDRESS)) {
            require(isContract(_token));
        }
        _;
    }

    address public USDC_ADDR;
    address payable public KYBER_ADDR;
    address payable public ONEINCH_ADDR;

    bytes public constant PERM_HINT = "PERM";

    // The address Kyber Network uses to represent Ether
    ERC20Detailed internal constant ETH_TOKEN_ADDRESS =
        ERC20Detailed(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    ERC20Detailed internal usdc;
    IKyberNetwork internal kyber;

    uint256 internal constant PRECISION = (10**18);
    uint256 internal constant MAX_QTY = (10**28); // 10B tokens
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 internal constant MAX_DECIMALS = 18;

    constructor(
        address _usdcAddr,
        address payable _kyberAddr,
        address payable _oneInchAddr
    ) public {
        USDC_ADDR = _usdcAddr;
        KYBER_ADDR = _kyberAddr;
        ONEINCH_ADDR = _oneInchAddr;

        usdc = ERC20Detailed(_usdcAddr);
        kyber = IKyberNetwork(_kyberAddr);
    }

    /**
     * @notice Get the number of decimals of a token
     * @param _token the token to be queried
     * @return number of decimals
     */
    function getDecimals(ERC20Detailed _token) internal view returns (uint256) {
        if (address(_token) == address(ETH_TOKEN_ADDRESS)) {
            return uint256(ETH_DECIMALS);
        }
        return uint256(_token.decimals());
    }

    /**
     * @notice Get the token balance of an account
     * @param _token the token to be queried
     * @param _addr the account whose balance will be returned
     * @return token balance of the account
     */
    function getBalance(ERC20Detailed _token, address _addr)
        internal
        view
        returns (uint256)
    {
        if (address(_token) == address(ETH_TOKEN_ADDRESS)) {
            return uint256(_addr.balance);
        }
        return uint256(_token.balanceOf(_addr));
    }

    /**
     * @notice Calculates the rate of a trade. The rate is the price of the source token in the dest token, in 18 decimals.
     *         Note: the rate is on the token level, not the wei level, so for example if 1 Atoken = 10 Btoken, then the rate
     *         from A to B is 10 * 10**18, regardless of how many decimals each token uses.
     * @param srcAmount amount of source token
     * @param destAmount amount of dest token
     * @param srcDecimals decimals used by source token
     * @param dstDecimals decimals used by dest token
     */
    function calcRateFromQty(
        uint256 srcAmount,
        uint256 destAmount,
        uint256 srcDecimals,
        uint256 dstDecimals
    ) internal pure returns (uint256) {
        require(srcAmount <= MAX_QTY);
        require(destAmount <= MAX_QTY);

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return ((destAmount * PRECISION) /
                ((10**(dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return ((destAmount *
                PRECISION *
                (10**(srcDecimals - dstDecimals))) / srcAmount);
        }
    }

    /**
     * @notice Wrapper function for doing token conversion on Kyber Network
     * @param _srcToken the token to convert from
     * @param _srcAmount the amount of tokens to be converted
     * @param _destToken the destination token
     * @return _destPriceInSrc the price of the dest token, in terms of source tokens
     *         _srcPriceInDest the price of the source token, in terms of dest tokens
     *         _actualDestAmount actual amount of dest token traded
     *         _actualSrcAmount actual amount of src token traded
     */
    function __kyberTrade(
        ERC20Detailed _srcToken,
        uint256 _srcAmount,
        ERC20Detailed _destToken
    )
        internal
        returns (
            uint256 _destPriceInSrc,
            uint256 _srcPriceInDest,
            uint256 _actualDestAmount,
            uint256 _actualSrcAmount
        )
    {
        require(_srcToken != _destToken);

        uint256 beforeSrcBalance = getBalance(_srcToken, address(this));
        uint256 msgValue;
        if (_srcToken != ETH_TOKEN_ADDRESS) {
            msgValue = 0;
            _srcToken.safeApprove(KYBER_ADDR, 0);
            _srcToken.safeApprove(KYBER_ADDR, _srcAmount);
        } else {
            msgValue = _srcAmount;
        }
        _actualDestAmount = kyber.tradeWithHint.value(msgValue)(
            _srcToken,
            _srcAmount,
            _destToken,
            toPayableAddr(address(this)),
            MAX_QTY,
            1,
            address(0),
            PERM_HINT
        );
        _actualSrcAmount = beforeSrcBalance.sub(
            getBalance(_srcToken, address(this))
        );
        require(_actualDestAmount > 0 && _actualSrcAmount > 0);
        _destPriceInSrc = calcRateFromQty(
            _actualDestAmount,
            _actualSrcAmount,
            getDecimals(_destToken),
            getDecimals(_srcToken)
        );
        _srcPriceInDest = calcRateFromQty(
            _actualSrcAmount,
            _actualDestAmount,
            getDecimals(_srcToken),
            getDecimals(_destToken)
        );
    }

    /**
     * @notice Wrapper function for doing token conversion on 1inch
     * @param _srcToken the token to convert from
     * @param _srcAmount the amount of tokens to be converted
     * @param _destToken the destination token
     * @return _destPriceInSrc the price of the dest token, in terms of source tokens
     *         _srcPriceInDest the price of the source token, in terms of dest tokens
     *         _actualDestAmount actual amount of dest token traded
     *         _actualSrcAmount actual amount of src token traded
     */
    function __oneInchTrade(
        ERC20Detailed _srcToken,
        uint256 _srcAmount,
        ERC20Detailed _destToken,
        bytes memory _calldata
    )
        public  
        returns (
            uint256 _destPriceInSrc,
            uint256 _srcPriceInDest,
            uint256 _actualDestAmount,
            uint256 _actualSrcAmount
        )
    {
        require(_srcToken != _destToken);

        uint256 beforeSrcBalance = getBalance(_srcToken, address(this));
        uint256 beforeDestBalance = getBalance(_destToken, address(this));
        // Note: _actualSrcAmount is being used as msgValue here, because otherwise we'd run into the stack too deep error
        if (_srcToken != ETH_TOKEN_ADDRESS) {
            _actualSrcAmount = 0;
            _srcToken.safeApprove(ONEINCH_ADDR, 0);
            _srcToken.safeApprove(ONEINCH_ADDR, _srcAmount);
        } else {
            _actualSrcAmount = _srcAmount;
        }

        // trade through 1inch proxy
        (bool success, ) = ONEINCH_ADDR.call.value(_actualSrcAmount)(_calldata);
        require(success);

        // calculate trade amounts and price
        _actualDestAmount = getBalance(_destToken, address(this)).sub(
            beforeDestBalance
        );
        _actualSrcAmount = beforeSrcBalance.sub(
            getBalance(_srcToken, address(this))
        );
        require(_actualDestAmount > 0 && _actualSrcAmount > 0);
        _destPriceInSrc = calcRateFromQty(
            _actualDestAmount,
            _actualSrcAmount,
            getDecimals(_destToken),
            getDecimals(_srcToken)
        );
        _srcPriceInDest = calcRateFromQty(
            _actualSrcAmount,
            _actualDestAmount,
            getDecimals(_srcToken),
            getDecimals(_destToken)
        );
    }

    /**
     * @notice Checks if an Ethereum account is a smart contract
     * @param _addr the account to be checked
     * @return True if the account is a smart contract, false otherwise
     */
    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        if (_addr == address(0)) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function toPayableAddr(address _addr)
        internal
        pure
        returns (address payable)
    {
        return address(uint160(_addr));
    }
}