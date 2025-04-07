/**
 *Submitted for verification at Etherscan.io on 2021-02-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract ContractGuard {
    mapping(uint256 => mapping(address => bool)) private _status;

    function checkSameOriginReentranted() internal view returns (bool) {
        return _status[block.number][tx.origin];
    }

    function checkSameSenderReentranted() internal view returns (bool) {
        return _status[block.number][msg.sender];
    }

    modifier onlyOneBlock() {
        require(!checkSameOriginReentranted(), "ContractGuard: one block, one function");
        require(!checkSameSenderReentranted(), "ContractGuard: one block, one function");

        _;

        _status[block.number][tx.origin] = true;
        _status[block.number][msg.sender] = true;
    }
}





interface ITreasury is IEpochController {
    function dollarPriceOne() external view returns (uint256);

    function dollarPriceCeiling() external view returns (uint256);
}





contract BondMarket is ContractGuard, IBondMarket {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    /* ========== STATE VARIABLES ========== */

    // governance
    address public operator;

    // flags
    bool public initialized = false;

    // core components
    address public dollar = address(0x3479B0ACF875405D7853f44142FE06470a40f6CC);
    address public treasury = address(0x71535ad4C7C5925382CdEadC806371cc89A5085D);

    // oracle
    address public dollarOracle = address(0xa2D385185Bbd96f4794AE3504aeaa7825827A297);
    uint256 public constant dollarPriceOne = 1e18;
    address public sideToken = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // WETH

    // coupon info
    uint256 public couponSupply;
    uint256 public couponIssued;
    uint256 public couponClaimed;

    // coupon purchase & redeem
    uint256 public discountPercent; // when purchasing coupon
    uint256 public maxDiscountRate;
    uint256 public premiumPercent; // when redeeming coupon
    uint256 public maxPremiumRate;
    uint256 public maxRedeemableCouponPercentPerEpoch;
    mapping(address => mapping(uint256 => uint256)) public purchasedCoupons; // user -> epoch -> purchased coupons
    mapping(address => uint256[]) public purchasedEpochs; // user -> array of purchasing epochs
    mapping(uint256 => uint256) public redemptedCoupons; // epoch -> redempted coupons

    /* =================== Added variables (need to keep orders for proxy to work) =================== */
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    uint256 public lpPoolIncentiveRate;
    uint256 public expiredCouponEpochs;

    /* =================== Events =================== */

    event Initialized(address indexed executor, uint256 at);
    event IssueNewCoupon(uint256 timestamp, uint256 amount);
    event BoughtCoupons(address indexed from, uint256 epoch, uint256 dollarAmount, uint256 bondAmount);
    event RedeemedCoupons(address indexed from, uint256 epoch, uint256 redeemedEpoch, uint256 dollarAmount, uint256 bondAmount);

    /* =================== Modifier =================== */

    modifier onlyOperator() {
        require(operator == msg.sender, "CouponMarket: caller is not the operator");
        _;
    }

    modifier onlyTreasury() {
        require(treasury == msg.sender || operator == msg.sender, "CouponMarket: caller is not a treasury nor operator");
        _;
    }

    modifier notInitialized {
        require(!initialized, "CouponMarket: already initialized");
        _;
    }

    /* ========== VIEW FUNCTIONS ========== */

    // flags
    function isInitialized() public view returns (bool) {
        return initialized;
    }

    // epoch
    function epoch() public view override returns (uint256) {
        return ITreasury(treasury).epoch();
    }

    function nextEpochPoint() public view override returns (uint256) {
        return ITreasury(treasury).nextEpochPoint();
    }

    function nextEpochLength() public view override returns (uint256) {
        return ITreasury(treasury).nextEpochLength();
    }

    // oracle
    function getDollarPrice() public view returns (uint256 _dollarPrice) {
        try IOracle(dollarOracle).consultDollarPrice(sideToken, 1e18) returns (uint256 price) {
            return price;
        } catch {
            revert("CouponMarket: failed to consult dollar price from the oracle");
        }
    }

    function getDollarUpdatedPrice() public view returns (uint256 _dollarPrice) {
        try IOracle(dollarOracle).twapDollarPrice(sideToken, 1e18) returns (uint256 price) {
            return price;
        } catch {
            revert("CouponMarket: failed to get TWAP dollar price from the oracle");
        }
    }

    function isDebtPhase() public view override returns (bool) {
        return getDollarUpdatedPrice() < dollarPriceOne;
    }

    function bondSupply() public view override returns (uint256) {
        return couponSupply;
    }

    function getCouponDiscountRate() public view returns (uint256 _rate) {
        uint256 _dollarPrice = getDollarUpdatedPrice();
        if (_dollarPrice < dollarPriceOne) {
            if (discountPercent == 0) {
                // no discount
                _rate = dollarPriceOne;
            } else {
                uint256 _couponAmount = dollarPriceOne.mul(1e18).div(_dollarPrice); // to burn 1 dollar
                uint256 _discountAmount = _couponAmount.sub(dollarPriceOne).mul(discountPercent).div(10000);
                _rate = dollarPriceOne.add(_discountAmount);
                uint256 _maxDiscountRate = maxDiscountRate;
                if (_maxDiscountRate > 0 && _rate > _maxDiscountRate) {
                    _rate = _maxDiscountRate;
                }
            }
        }
    }

    function getCouponPremiumRate() public view returns (uint256 _rate) {
        uint256 _dollarPrice = getDollarUpdatedPrice();
        if (_dollarPrice >= dollarPriceOne) {
            if (premiumPercent == 0) {
                // no premium bonus
                _rate = dollarPriceOne;
            } else {
                uint256 _premiumAmount = _dollarPrice.sub(dollarPriceOne).mul(premiumPercent).div(10000);
                _rate = dollarPriceOne.add(_premiumAmount);
                uint256 _maxPremiumRate = maxPremiumRate;
                if (_maxPremiumRate > 0 && _rate > _maxPremiumRate) {
                    _rate = _maxPremiumRate;
                }
            }
        }
    }

    function getBurnableDollarLeft() public view returns (uint256 _burnableDollarLeft) {
        uint256 _dollarPrice = getDollarPrice();
        if (_dollarPrice < dollarPriceOne) {
            _burnableDollarLeft = couponSupply.mul(1e18).div(getCouponDiscountRate());
        }
    }

    function getRedeemableCoupons() public view returns (uint256 _redeemableCoupons) {
        uint256 _dollarPrice = getDollarPrice();
        if (_dollarPrice >= dollarPriceOne) {
            uint256 _epoch = epoch();
            uint256 _maxRedeemableCoupons = IERC20(dollar).totalSupply().mul(maxRedeemableCouponPercentPerEpoch).div(10000);
            uint256 _redemptedCoupons = redemptedCoupons[_epoch];
            _redeemableCoupons = (_maxRedeemableCoupons <= _redemptedCoupons) ? 0 : _maxRedeemableCoupons.sub(_redemptedCoupons);
        }
    }

    function getPurchasedCouponHistory(address _account)
        external
        view
        returns (
            uint256 _length,
            uint256[] memory _epochs,
            uint256[] memory _amounts
        )
    {
        uint256 _purchasedEpochLength = purchasedEpochs[_account].length;
        _epochs = new uint256[](_purchasedEpochLength);
        _amounts = new uint256[](_purchasedEpochLength);
        for (uint256 _index = 0; _index < _purchasedEpochLength; _index++) {
            uint256 _ep = purchasedEpochs[_account][_index];
            uint256 _amt = purchasedCoupons[_account][_ep];
            if (_amt > 0) {
                _epochs[_length] = _ep;
                _amounts[_length] = _amt;
                ++_length;
            }
        }
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _account) external view returns (uint256) {
        return _balances[_account];
    }

    /* ========== GOVERNANCE ========== */

    function initialize(
        address _dollar,
        address _treasury,
        address _dollarOracle
    ) public notInitialized {
        dollar = _dollar;
        treasury = _treasury;
        dollarOracle = _dollarOracle;

        sideToken = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

        couponSupply = 0;
        couponIssued = 0;
        couponClaimed = 0;

        maxDiscountRate = 130e16; // upto 130%
        maxPremiumRate = 130e16; // upto 130%

        discountPercent = 3000; // 30%
        premiumPercent = 3000; // 30%

        maxRedeemableCouponPercentPerEpoch = 300; // 3% redeemable each epoch

        initialized = true;
        operator = msg.sender;

        emit Initialized(msg.sender, block.number);
    }

    function setOperator(address _operator) external onlyOperator {
        operator = _operator;
    }

    function setDollarOracle(address _dollarOracle) external onlyOperator {
        dollarOracle = _dollarOracle;
    }

    function setSideToken(address _sideToken) external onlyOperator {
        sideToken = _sideToken;
    }

    function setMaxDiscountRate(uint256 _maxDiscountRate) external onlyOperator {
        maxDiscountRate = _maxDiscountRate;
    }

    function setMaxPremiumRate(uint256 _maxPremiumRate) external onlyOperator {
        maxPremiumRate = _maxPremiumRate;
    }

    function setDiscountPercent(uint256 _discountPercent) external onlyOperator {
        require(_discountPercent <= 20000, "over 200%");
        discountPercent = _discountPercent;
    }

    function setPremiumPercent(uint256 _premiumPercent) external onlyOperator {
        require(_premiumPercent <= 20000, "over 200%");
        premiumPercent = _premiumPercent;
    }

    function setMaxRedeemableCouponPercentPerEpoch(uint256 _maxRedeemableCouponPercentPerEpoch) external onlyOperator {
        require(_maxRedeemableCouponPercentPerEpoch <= 10000, "over 100%");
        maxRedeemableCouponPercentPerEpoch = _maxRedeemableCouponPercentPerEpoch;
    }

    function setLpPoolIncentiveRate(uint256 _lpPoolIncentiveRate) external onlyOperator {
        require(_lpPoolIncentiveRate <= 2000, "over 20%");
        lpPoolIncentiveRate = _lpPoolIncentiveRate;
    }

    function setExpiredCouponEpochs(uint256 _expiredCouponEpochs) external onlyOperator {
        require(_expiredCouponEpochs >= 180, "too short"); // >= 180 epochs
        expiredCouponEpochs = _expiredCouponEpochs;
    }

    // Manual add balances for display only
    function manuallyBalanceAdd(address _account, uint256 _amount) external onlyOperator {
        _balances[_account] = _balances[_account].add(_amount);
        _totalSupply = _totalSupply.add(_amount);
    }

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        _token.safeTransfer(_to, _amount);
    }

    /* ========== MUTABLE FUNCTIONS ========== */

    function _updateDollarPrice() internal {
        try IOracle(dollarOracle).update() {} catch {}
    }

    function _updateDollarPriceCumulative() internal {
        try IOracle(dollarOracle).updateCumulative() {} catch {}
    }

    function issueNewBond(uint256 _issuedBond) external override onlyTreasury {
        couponSupply = couponSupply.add(_issuedBond);
    }

    function buyCoupons(uint256 _dollarAmount, uint256 _targetPrice) external override onlyOneBlock {
        require(_dollarAmount > 0, "BondMarket: cannot purchase coupons with zero amount");

        uint256 _dollarPrice = getDollarUpdatedPrice();
        require(_dollarPrice == _targetPrice, "BondMarket: dollar price moved");
        require(
            _dollarPrice < dollarPriceOne, // price < $1
            "BondMarket: dollarPrice not eligible for coupon purchase"
        );

        uint256 _burnableDollarLeft = getBurnableDollarLeft();
        require(_dollarAmount <= _burnableDollarLeft, "BondMarket: not enough coupon left to purchase");

        uint256 _rate = getCouponDiscountRate();
        require(_rate > 0, "BondMarket: invalid coupon rate");

        uint256 _couponAmount = _dollarAmount.mul(_rate).div(1e18);
        couponSupply = couponSupply.sub(_couponAmount);
        couponIssued = couponIssued.add(_couponAmount);

        uint256 _epoch = epoch();
        address _dollar = dollar;
        IDollar(_dollar).burnFrom(msg.sender, _dollarAmount);
        purchasedCoupons[msg.sender][_epoch] = purchasedCoupons[msg.sender][_epoch].add(_couponAmount);
        _balances[msg.sender] = _balances[msg.sender].add(_couponAmount);
        _totalSupply = _totalSupply.add(_couponAmount);

        if (lpPoolIncentiveRate > 0) {
            uint256 _lpPoolIncentive = (_dollarAmount * lpPoolIncentiveRate) / 10000;
            IDollar(_dollar).mint(treasury, _lpPoolIncentive);
        }

        uint256 _purchasedEpochLength = purchasedEpochs[msg.sender].length;
        if (_purchasedEpochLength == 0 || purchasedEpochs[msg.sender][_purchasedEpochLength - 1] < _epoch) {
            purchasedEpochs[msg.sender].push(_epoch);
        }

        _updateDollarPriceCumulative();

        emit BoughtCoupons(msg.sender, _epoch, _dollarAmount, purchasedCoupons[msg.sender][_epoch]);
    }

    function redeemCoupons(
        uint256 _epoch,
        uint256 _couponAmount,
        uint256 _targetPrice
    ) external override onlyOneBlock {
        require(_couponAmount > 0, "BondMarket: cannot redeem coupons with zero amount");

        uint256 _currentEpoch = epoch();
        uint256 _expiredCouponEpochs = expiredCouponEpochs;
        if (_expiredCouponEpochs > 0) {
            require(_epoch.add(_expiredCouponEpochs) >= _currentEpoch, "BondMarket: coupons expired");
        }

        uint256 _dollarPrice = getDollarUpdatedPrice();
        require(_dollarPrice == _targetPrice, "BondMarket: dollar price moved");
        require(
            _dollarPrice >= dollarPriceOne, // price >= $1
            "BondMarket: dollarPrice not eligible for coupon purchase"
        );

        uint256 _redeemableCoupons = getRedeemableCoupons();
        require(_couponAmount <= _redeemableCoupons, "BondMarket: not enough coupon available to redeem");

        uint256 _rate = getCouponPremiumRate();
        require(_rate > 0, "BondMarket: invalid coupon rate");

        uint256 _dollarAmount = _couponAmount.mul(_rate).div(1e18);
        IDollar(dollar).mint(msg.sender, _dollarAmount);
        purchasedCoupons[msg.sender][_epoch] = purchasedCoupons[msg.sender][_epoch].sub(_couponAmount, "over redeem");
        _balances[msg.sender] = _balances[msg.sender].sub(_couponAmount);
        _totalSupply = _totalSupply.sub(_couponAmount);
        couponClaimed = couponClaimed.add(_couponAmount);

        redemptedCoupons[_currentEpoch] = redemptedCoupons[_currentEpoch].add(_couponAmount);

        _updateDollarPriceCumulative();

        emit RedeemedCoupons(msg.sender, _currentEpoch, _epoch, _dollarAmount, _couponAmount);
    }
}