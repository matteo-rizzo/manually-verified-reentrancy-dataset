/**
 *Submitted for verification at Etherscan.io on 2021-04-19
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.1;



// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/BondToken_and_GDOTC/bondToken/BondTokenInterface.sol






interface BondTokenInterface is IERC20 {
    event LogExpire(uint128 rateNumerator, uint128 rateDenominator, bool firstTime);

    function mint(address account, uint256 amount) external returns (bool success);

    function expire(uint128 rateNumerator, uint128 rateDenominator)
        external
        returns (bool firstTime);

    function simpleBurn(address account, uint256 amount) external returns (bool success);

    function burn(uint256 amount) external returns (bool success);

    function burnAll() external returns (uint256 amount);

    function getRate() external view returns (uint128 rateNumerator, uint128 rateDenominator);
}

// File: contracts/BondToken_and_GDOTC/oracle/LatestPriceOracleInterface.sol




/**
 * @dev Interface of the price oracle.
 */


// File: contracts/BondToken_and_GDOTC/oracle/PriceOracleInterface.sol





/**
 * @dev Interface of the price oracle.
 */
interface PriceOracleInterface is LatestPriceOracleInterface {
    /**
     * @dev Returns the latest id. The id start from 1 and increments by 1.
     */
    function latestId() external returns (uint256);

    /**
     * @dev Returns the historical price specified by `id`. Decimals is 8.
     */
    function getPrice(uint256 id) external returns (uint256);

    /**
     * @dev Returns the timestamp of historical price specified by `id`.
     */
    function getTimestamp(uint256 id) external returns (uint256);
}

// File: contracts/BondToken_and_GDOTC/bondMaker/BondMakerInterface.sol








// File: contracts/contracts/Interfaces/StrategyInterface.sol







// File: contracts/contracts/Interfaces/VolatilityOracleInterface.sol






// File: contracts/BondToken_and_GDOTC/bondPricer/Enums.sol




/**
    Pure SBT:
        ___________
       /
      /
     /
    /

    LBT Shape:
              /
             /
            /
           /
    ______/

    SBT Shape:
              ______
             /
            /
    _______/

    Triangle:
              /\
             /  \
            /    \
    _______/      \________
 */
enum BondType {NONE, PURE_SBT, SBT_SHAPE, LBT_SHAPE, TRIANGLE}

// File: contracts/BondToken_and_GDOTC/bondPricer/BondPricerInterface.sol







// File: @openzeppelin/contracts/GSN/Context.sol





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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol





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


// File: @openzeppelin/contracts/utils/Address.sol





/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/ERC20.sol









/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
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
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// File: contracts/contracts/Interfaces/ExchangeInterface.sol










// File: contracts/contracts/Interfaces/SimpleAggragatorInterface.sol


pragma experimental ABIEncoderV2;




// File: contracts/BondToken_and_GDOTC/util/Polyline.sol




contract Polyline {
    struct Point {
        uint64 x; // Value of the x-axis of the x-y plane
        uint64 y; // Value of the y-axis of the x-y plane
    }

    struct LineSegment {
        Point left; // The left end of the line definition range
        Point right; // The right end of the line definition range
    }

    /**
     * @notice Return the value of y corresponding to x on the given line. line in the form of
     * a rational number (numerator / denominator).
     * If you treat a line as a line segment instead of a line, you should run
     * includesDomain(line, x) to check whether x is included in the line's domain or not.
     * @dev To guarantee accuracy, the bit length of the denominator must be greater than or equal
     * to the bit length of x, and the bit length of the numerator must be greater than or equal
     * to the sum of the bit lengths of x and y.
     */
    function _mapXtoY(LineSegment memory line, uint64 x)
        internal
        pure
        returns (uint128 numerator, uint64 denominator)
    {
        int256 x1 = int256(line.left.x);
        int256 y1 = int256(line.left.y);
        int256 x2 = int256(line.right.x);
        int256 y2 = int256(line.right.y);

        require(x2 > x1, "must be left.x < right.x");

        denominator = uint64(x2 - x1);

        // Calculate y = ((x2 - x) * y1 + (x - x1) * y2) / (x2 - x1)
        // in the form of a fraction (numerator / denominator).
        int256 n = (x - x1) * y2 + (x2 - x) * y1;

        require(n >= 0, "underflow n");
        require(n < 2**128, "system error: overflow n");
        numerator = uint128(n);
    }

    /**
     * @notice Checking that a line segment is a valid format.
     */
    function assertLineSegment(LineSegment memory segment) internal pure {
        uint64 x1 = segment.left.x;
        uint64 x2 = segment.right.x;
        require(x1 < x2, "must be left.x < right.x");
    }

    /**
     * @notice Checking that a polyline is a valid format.
     */
    function assertPolyline(LineSegment[] memory polyline) internal pure {
        uint256 numOfSegment = polyline.length;
        require(numOfSegment != 0, "polyline must not be empty array");

        LineSegment memory leftSegment = polyline[0]; // mutable
        int256 gradientNumerator = int256(leftSegment.right.y) - int256(leftSegment.left.y); // mutable
        int256 gradientDenominator = int256(leftSegment.right.x) - int256(leftSegment.left.x); // mutable

        // The beginning of the first line segment's domain is 0.
        require(
            leftSegment.left.x == uint64(0),
            "the x coordinate of left end of the first segment must be 0"
        );
        // The value of y when x is 0 is 0.
        require(
            leftSegment.left.y == uint64(0),
            "the y coordinate of left end of the first segment must be 0"
        );

        // Making sure that the first line segment is a correct format.
        assertLineSegment(leftSegment);

        // The end of the domain of a segment and the beginning of the domain of the adjacent
        // segment must coincide.
        LineSegment memory rightSegment; // mutable
        for (uint256 i = 1; i < numOfSegment; i++) {
            rightSegment = polyline[i];

            // Make sure that the i-th line segment is a correct format.
            assertLineSegment(rightSegment);

            // Checking that the x-coordinates are same.
            require(
                leftSegment.right.x == rightSegment.left.x,
                "given polyline has an undefined domain."
            );

            // Checking that the y-coordinates are same.
            require(
                leftSegment.right.y == rightSegment.left.y,
                "given polyline is not a continuous function"
            );

            int256 nextGradientNumerator = int256(rightSegment.right.y) -
                int256(rightSegment.left.y);
            int256 nextGradientDenominator = int256(rightSegment.right.x) -
                int256(rightSegment.left.x);
            require(
                nextGradientNumerator * gradientDenominator !=
                    nextGradientDenominator * gradientNumerator,
                "the sequential segments must not have the same gradient"
            );

            leftSegment = rightSegment;
            gradientNumerator = nextGradientNumerator;
            gradientDenominator = nextGradientDenominator;
        }

        // rightSegment is lastSegment

        // About the last line segment.
        require(
            gradientNumerator >= 0 && gradientNumerator <= gradientDenominator,
            "the gradient of last line segment must be non-negative, and equal to or less than 1"
        );
    }

    /**
     * @notice zip a LineSegment structure to uint256
     * @return zip uint256( 0 ... 0 | x1 | y1 | x2 | y2 )
     */
    function zipLineSegment(LineSegment memory segment) internal pure returns (uint256 zip) {
        uint256 x1U256 = uint256(segment.left.x) << (64 + 64 + 64); // uint64
        uint256 y1U256 = uint256(segment.left.y) << (64 + 64); // uint64
        uint256 x2U256 = uint256(segment.right.x) << 64; // uint64
        uint256 y2U256 = uint256(segment.right.y); // uint64
        zip = x1U256 | y1U256 | x2U256 | y2U256;
    }

    /**
     * @notice unzip uint256 to a LineSegment structure
     */
    function unzipLineSegment(uint256 zip) internal pure returns (LineSegment memory) {
        uint64 x1 = uint64(zip >> (64 + 64 + 64));
        uint64 y1 = uint64(zip >> (64 + 64));
        uint64 x2 = uint64(zip >> 64);
        uint64 y2 = uint64(zip);
        return LineSegment({left: Point({x: x1, y: y1}), right: Point({x: x2, y: y2})});
    }

    /**
     * @notice unzip the fnMap to uint256[].
     */
    function decodePolyline(bytes memory fnMap) internal pure returns (uint256[] memory) {
        return abi.decode(fnMap, (uint256[]));
    }
}

// File: @openzeppelin/contracts/utils/SafeCast.sol






/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */


// File: contracts/contracts/Strategy/StrategyForSimpleAggregator.sol











contract StrategyForSimpleAggregator is SimpleStrategyInterface, Polyline {
    using SafeMath for uint256;
    using SafeCast for uint256;
    struct FeeInfo {
        int16 currentFeeBase;
        int32 upwardDifference;
        int32 downwardDifference;
    }
    uint256 constant WEEK_LENGTH = 3;
    mapping(bytes32 => address[]) public aggregators;
    mapping(bytes32 => FeeInfo) public feeBases;
    uint256 internal immutable TERM_INTERVAL;
    uint256 internal immutable TERM_CORRECTION_FACTOR;
    int16 constant INITIAL_FEEBASE = 250;

    constructor(uint256 termInterval, uint256 termCF) {
        TERM_INTERVAL = termInterval;
        TERM_CORRECTION_FACTOR = termCF;
    }

    /**
     * @notice Return next maturity.(Default: Friday 3 p.m UTC within 3 weeks )
     */
    function calcNextMaturity() public view override returns (uint256 nextTimeStamp) {
        uint256 week = (block.timestamp - TERM_CORRECTION_FACTOR).div(TERM_INTERVAL);
        nextTimeStamp = ((week + WEEK_LENGTH) * TERM_INTERVAL) + (TERM_CORRECTION_FACTOR);
    }

    /**
     * @notice Determine the bond token amount to be issued/burned.
     * @param issueBondGroupId Bond group ID to be issued
     * @param bondGroupList Determine bond group ID to be burned from this list.
     */
    function getTrancheBonds(
        BondMakerInterface bondMaker,
        address aggregatorAddress,
        uint256 issueBondGroupId,
        uint256 price,
        uint256[] calldata bondGroupList,
        uint64 priceUnit,
        bool isReversedOracle
    )
        public
        view
        virtual
        override
        returns (
            uint256 issueAmount,
            uint256,
            uint256[2] memory IDAndAmountOfBurn
        )
    {
        price = calcRoundPrice(price, priceUnit, 1);
        uint256 baseAmount = _getBaseAmount(SimpleAggregatorInterface(aggregatorAddress));
        for (uint64 i = 0; i < bondGroupList.length; i++) {
            (issueAmount, ) = _getLBTStrikePrice(bondMaker, bondGroupList[i], isReversedOracle);
            // If Call option strike price is different from current price by priceUnit * 5,
            // this bond group becomes target of burn.
            if ((issueAmount > price + priceUnit * 5 || issueAmount < price.sub(priceUnit * 5))) {
                uint256 balance = _getMinBondAmount(bondMaker, bondGroupList[i], aggregatorAddress);
                // If `balance` is larger than that of current target bond group,
                // change the target bond group
                if (balance > baseAmount / 2 && balance > IDAndAmountOfBurn[1]) {
                    IDAndAmountOfBurn[0] = bondGroupList[i];
                    IDAndAmountOfBurn[1] = balance;
                }
            }
        }
        {
            uint256 balance = _getMinBondAmount(bondMaker, issueBondGroupId, aggregatorAddress);
            baseAmount = baseAmount + (IDAndAmountOfBurn[1] / 5);
            if (balance < baseAmount && issueBondGroupId != 0) {
                issueAmount = baseAmount - balance;
            } else {
                issueAmount = 0;
            }
        }
    }

    /**
     * @notice Register feebase for each type of aggregator.
     * Fee base is shared among the same type of aggregators.
     */
    function registerCurrentFeeBase(
        int16 currentFeeBase,
        uint256 currentCollateralPerToken,
        uint256 nextCollateralPerToken,
        address owner,
        address oracleAddress,
        bool isReversedOracle
    ) public override {
        bytes32 aggregatorID = generateAggregatorID(owner, oracleAddress, isReversedOracle);
        int16 feeBase = _calcFeeBase(
            currentFeeBase,
            currentCollateralPerToken,
            nextCollateralPerToken,
            feeBases[aggregatorID].upwardDifference,
            feeBases[aggregatorID].downwardDifference
        );
        address[] memory aggregatorAddresses = aggregators[aggregatorID];
        require(_isValidAggregator(aggregatorAddresses), "sender is invalid aggregator");
        if (feeBase < INITIAL_FEEBASE) {
            feeBases[aggregatorID].currentFeeBase = INITIAL_FEEBASE;
        } else if (feeBase >= 1000) {
            feeBases[aggregatorID].currentFeeBase = 999;
        } else {
            feeBases[aggregatorID].currentFeeBase = feeBase;
        }
    }

    /**
     * @notice If CollateralPerToken amount increases by 5% or more, reduce currentFeeBase by downwardDifference.
     * If CollateralPerToken amount decreases by 5% or more, increase currentFeeBase by upwardDifference.
     */
    function _calcFeeBase(
        int16 currentFeeBase,
        uint256 currentCollateralPerToken,
        uint256 nextCollateralPerToken,
        int32 upwardDifference,
        int32 downwardDifference
    ) internal pure returns (int16) {
        if (
            nextCollateralPerToken.mul(100).div(105) > currentCollateralPerToken &&
            currentFeeBase > downwardDifference
        ) {
            return int16(currentFeeBase - downwardDifference);
        } else if (nextCollateralPerToken.mul(105).div(100) < currentCollateralPerToken) {
            return int16(currentFeeBase + upwardDifference);
        }
        return currentFeeBase;
    }

    function _isValidAggregator(address[] memory aggregatorAddresses) internal view returns (bool) {
        for (uint256 i = 0; i < aggregatorAddresses.length; i++) {
            if (aggregatorAddresses[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Register addresses of aggregators for each type of price feed
     * @notice Aggregator owner should register aggregators for fee base registration
     */
    function registerAggregators(
        address oracleAddress,
        bool isReversedOracle,
        address[] calldata aggregatorAddresses,
        int32 upwardDifference,
        int32 downwardDifference
    ) external {
        bytes32 aggregatorID = generateAggregatorID(msg.sender, oracleAddress, isReversedOracle);
        require(aggregators[aggregatorID].length == 0, "This aggregator ID is already registered");
        aggregators[aggregatorID] = aggregatorAddresses;
        feeBases[aggregatorID] = FeeInfo(INITIAL_FEEBASE, upwardDifference, downwardDifference);
    }

    function generateAggregatorID(
        address owner,
        address oracleAddress,
        bool isReversedOracle
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(owner, oracleAddress, isReversedOracle));
    }

    /**
     * @notice Calculate call option price for the current price
     * If reversed oracle is set to aggregator, return reversed strike price
     */
    function calcCallStrikePrice(
        uint256 currentPriceE8,
        uint64 priceUnit,
        bool isReversedOracle
    ) external pure override returns (uint256 callStrikePrice) {
        if (isReversedOracle) {
            callStrikePrice = _getReversedValue(
                calcRoundPrice(currentPriceE8, priceUnit, 1),
                isReversedOracle
            );
        } else {
            callStrikePrice = calcRoundPrice(currentPriceE8, priceUnit, 1);
        }
    }

    /**
     * @notice Determine the valid strike price for the new period.
     * @dev SBT strike price is the half of current price.
     * If reversed oracle is set to aggregator, reversed value is returned.
     */
    function getCurrentStrikePrice(
        uint256 currentPriceE8,
        uint64 priceUnit,
        bool isReversedOracle
    ) external pure override returns (uint256 strikePrice) {
        if (isReversedOracle) {
            strikePrice = _getReversedValue(
                calcRoundPrice(currentPriceE8 * 2, priceUnit, 1),
                isReversedOracle
            );
        } else {
            strikePrice = calcRoundPrice(currentPriceE8, priceUnit, 2);
        }
        return strikePrice;
    }

    function getCurrentSpread(
        address owner,
        address oracleAddress,
        bool isReversedOracle
    ) public view override returns (int16) {
        bytes32 aggregatorID = generateAggregatorID(owner, oracleAddress, isReversedOracle);
        if (feeBases[aggregatorID].currentFeeBase == 0) {
            return INITIAL_FEEBASE;
        }
        return feeBases[aggregatorID].currentFeeBase;
    }

    function _getReversedValue(uint256 value, bool isReversedOracle)
        internal
        pure
        returns (uint256)
    {
        if (!isReversedOracle) {
            return value;
        } else {
            return 10**16 / value;
        }
    }

    /**
     * @dev Calculate base bond amount of issue/burn
     */
    function _getBaseAmount(SimpleAggregatorInterface aggregator) internal view returns (uint256) {
        uint256 collateralAmount = aggregator.getCollateralAmount();
        int16 decimalGap = int16(aggregator.getCollateralDecimal()) - 8;
        return _applyDecimalGap(collateralAmount.div(5), decimalGap);
    }

    function _applyDecimalGap(uint256 amount, int16 decimalGap) internal pure returns (uint256) {
        if (decimalGap < 0) {
            return amount.mul(10**uint256(decimalGap * -1));
        } else {
            return amount / (10**uint256(decimalGap));
        }
    }

    function calcRoundPrice(
        uint256 price,
        uint64 priceUnit,
        uint8 divisor
    ) public pure override returns (uint256 roundedPrice) {
        roundedPrice = price.div(priceUnit * divisor).mul(priceUnit);
    }

    function getFeeInfo(
        address owner,
        address oracleAddress,
        bool isReversedOracle
    )
        public
        view
        returns (
            int16 currentFeeBase,
            int32 upwardDifference,
            int32 downwardDifference
        )
    {
        bytes32 aggregatorID = generateAggregatorID(owner, oracleAddress, isReversedOracle);
        return (
            feeBases[aggregatorID].currentFeeBase,
            feeBases[aggregatorID].upwardDifference,
            feeBases[aggregatorID].downwardDifference
        );
    }

    /**
     * @dev Get LBT strike price in Collateral / USD
     */
    function _getLBTStrikePrice(
        BondMakerInterface bondMaker,
        uint256 bondGroupID,
        bool isReversedOracle
    ) public view returns (uint128, address) {
        (bytes32[] memory bondIDs, ) = bondMaker.getBondGroup(bondGroupID);
        (address bondAddress, , , bytes32 fnMapID) = bondMaker.getBond(bondIDs[1]);
        bytes memory fnMap = bondMaker.getFnMap(fnMapID);
        uint256[] memory zippedLines = decodePolyline(fnMap);
        LineSegment memory secondLine = unzipLineSegment(zippedLines[1]);
        return (
            _getReversedValue(uint256(secondLine.left.x), isReversedOracle).toUint128(),
            bondAddress
        );
    }

    /**
     * @dev Get minimum bond amount in the bond group
     */
    function _getMinBondAmount(
        BondMakerInterface bondMaker,
        uint256 bondGroupID,
        address aggregatorAddress
    ) internal view returns (uint256 balance) {
        (bytes32[] memory bondIDs, ) = bondMaker.getBondGroup(bondGroupID);
        for (uint256 i = 0; i < bondIDs.length; i++) {
            (address bondAddress, , , ) = bondMaker.getBond(bondIDs[i]);
            uint256 bondBalance = IERC20(bondAddress).balanceOf(aggregatorAddress);
            if (i == 0) {
                balance = bondBalance;
            } else if (balance > bondBalance) {
                balance = bondBalance;
            }
        }
    }
}

// File: contracts/contracts/Strategy/StrategyForSimpleAggregatorETH.sol





contract StrategyForSimpleAggregatorETH is StrategyForSimpleAggregator {
    using SafeMath for uint256;
    ExchangeInterface internal immutable exchange;

    constructor(
        ExchangeInterface _exchange,
        uint256 termInterval,
        uint256 termCF
    ) StrategyForSimpleAggregator(termInterval, termCF) {
        exchange = _exchange;
        require(address(_exchange) != address(0), "_exchange cannot be zero");
    }

    /**
     * @notice Determine the bond token amount to be issued/burned.
     * @param issueBondGroupId Bond group ID to be issued
     * @param bondGroupList Determine bond group ID to be burned from this list.
     * @param ethAmount ETH amount to be depositted to GDOTC (if aggregator is ETH aggregator)
     */
    function getTrancheBonds(
        BondMakerInterface bondMaker,
        address aggregatorAddress,
        uint256 issueBondGroupId,
        uint256 price,
        uint256[] calldata bondGroupList,
        uint64 priceUnit,
        bool isReversedOracle
    )
        public
        view
        override
        returns (
            uint256 issueAmount,
            uint256 ethAmount,
            uint256[2] memory IDAndAmountOfBurn
        )
    {
        if (SimpleAggregatorInterface(aggregatorAddress).getCollateralAddress() == address(0)) {
            uint256 currentDepositAmount = exchange.ethAllowance(aggregatorAddress);
            uint256 baseETHAmount = aggregatorAddress.balance.div(10);
            if (currentDepositAmount < baseETHAmount) {
                ethAmount = baseETHAmount.sub(currentDepositAmount);
            }
        }

        (issueAmount, , IDAndAmountOfBurn) = super.getTrancheBonds(
            bondMaker,
            aggregatorAddress,
            issueBondGroupId,
            price,
            bondGroupList,
            priceUnit,
            isReversedOracle
        );
    }
}