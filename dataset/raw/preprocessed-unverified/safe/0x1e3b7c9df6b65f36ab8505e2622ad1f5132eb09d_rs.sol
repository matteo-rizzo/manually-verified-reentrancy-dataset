/**
 *Submitted for verification at Etherscan.io on 2021-07-12
*/

pragma solidity 0.5.12;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


/**
 * @title SetterRole
 */
contract SetterRole is Ownable {
    using Roles for Roles.Role;

    event SetterAdded(address indexed account);
    event SetterRemoved(address indexed account);

    Roles.Role private _setters;

    modifier onlySetter() {
        require(isSetter(msg.sender), "Caller has no permission");
        _;
    }

    function isSetter(address account) public view returns (bool) {
        return(_setters.has(account) || account == _owner);
    }

    function addSetter(address account) public onlyOwner {
        _setters.add(account);
        emit SetterAdded(account);
    }

    function removeSetter(address account) public onlyOwner {
        _setters.remove(account);
        emit SetterRemoved(account);
    }
}

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
 

 

/**
 * @title MF TokenSale contract
 * @author https://grox.solutions
 */
contract TokenSale is SetterRole {
    using SafeMath for uint256;

    IUSDT public USDT;
    IERC20 public TOKEN;

    uint256 public FEE_PERCENT = 500;
    uint256 public REF_PERCENT = 2000;
    uint256 public FUND_PERCENT = 7500;
    uint256 public PERCENT_DIV = 10000;

    uint256 internal rateMul;
    uint256 internal rateDiv;
    bool public rateChangeable;
    bool public withdrawable;

    struct User {
        uint256 purchased;

        address referrer;
        address[] referrals;
        uint256 refPercent;
        uint256 totalBonuses;
    }

    mapping (address => User) public users;

    address public fundWallet;
    address public feeWallet;

    address public defaultRef;

    uint256 internal _tokensSold;

    event Purchased(address indexed account, uint256 usdt, uint256 tokens);
    event RefBonus(address indexed account, address indexed referral, uint256 refPercent, uint256 amount);
    event RateChanged(uint256 oldRateMul, uint256 oldRateDiv, uint256 newRateMul, uint256 newRateDiv);
    event FeeWalletChanged(address oldFeeWallet, address newFeeWallet);
    event FundWalletChanged(address oldFundWallet, address newFundWallet);

    constructor(address USDTAddr, address TOKENAddr, address initialOwner, address initialFeeWallet, address initialFundWallet, address defaultReferrer, uint256 _rateMul, uint256 _rateDiv, bool _rateChangeable, bool _withdrawable) public Ownable(initialOwner) {
        require(USDTAddr != address(0) && TOKENAddr != address(0) && initialFeeWallet != address(0) && initialFundWallet != address(0) && defaultReferrer != address(0));

        USDT = IUSDT(USDTAddr);
        TOKEN = IERC20(TOKENAddr);

        feeWallet = initialFeeWallet;
        fundWallet = initialFundWallet;
        defaultRef = defaultReferrer;

        rateMul = _rateMul;
        rateDiv = _rateDiv;

        rateChangeable = _rateChangeable;
        withdrawable = _withdrawable;

        emit RateChanged(0, 0, rateMul, rateDiv);
    }

    function buyToken(uint256 usdtAmount, address referrer) public {
        require(usdtAmount >= 10e6, "Minimum purchase is 10$");
        require(USDT.allowance(msg.sender, address(this)) >= usdtAmount, "Approve USDT to this contract first");

        if (users[msg.sender].referrer == address(0)) {
            if (referrer == address(0)) {
                referrer = defaultRef;
            }
            users[msg.sender].referrer = referrer;
            users[referrer].referrals.push(msg.sender);
        }

        USDT.transferFrom(msg.sender, address(this), usdtAmount);

        uint256 refBonus;
        if (users[msg.sender].referrer != address(0)) {
            uint256 refPercent = users[users[msg.sender].referrer].refPercent > 0 ? users[users[msg.sender].referrer].refPercent : REF_PERCENT;
            refBonus = usdtAmount * refPercent / PERCENT_DIV;
            USDT.transfer(users[msg.sender].referrer, refBonus);
            users[msg.sender].totalBonuses = users[msg.sender].totalBonuses.add(refBonus);
            emit RefBonus(users[msg.sender].referrer, msg.sender, refPercent, refBonus);
        }

        uint256 fee = usdtAmount.mul(FEE_PERCENT + REF_PERCENT).div(PERCENT_DIV);
        if (fee.sub(refBonus) > 0) {
            USDT.transfer(feeWallet, fee.sub(refBonus));
        }

        USDT.transfer(fundWallet, usdtAmount.mul(FUND_PERCENT).div(PERCENT_DIV));

        uint256 tokens = getEstimation(usdtAmount);

        TOKEN.transfer(msg.sender, tokens);

        _tokensSold = _tokensSold.add(tokens);
        users[msg.sender].purchased = users[msg.sender].purchased.add(tokens);

        emit Purchased(msg.sender, usdtAmount, tokens);
    }

    function withdrawERC20(address ERC20Token, address recipient) external onlyOwner {
        if (ERC20Token == address(TOKEN)) {
            require(withdrawable);
        }

        uint256 amount = IERC20(ERC20Token).balanceOf(address(this));
        IERC20(ERC20Token).transfer(recipient, amount);

    }

    function usdtBalanceOf(address account) public view returns(uint256 usdt) {
        return USDT.balanceOf(account);
    }

    function tokenBalanceOf(address account) public view returns(uint256 tokens) {
        return TOKEN.balanceOf(account);
    }

    function getPurchasedOf(address account) public view returns(uint256 tokens) {
        return users[account].purchased;
    }

    function getEstimation(uint256 usdt) public view returns(uint256 tokens) {
        require(usdt >= 10e6, "Minimum purchase is 10$");
        return usdt.mul(rateMul).div(rateDiv);
    }

    function getAvailableTokens() public view returns(uint256 tokens) {
        return TOKEN.balanceOf(address(this));
    }

    function getSoldTokens() public view returns(uint256 tokens) {
        return _tokensSold;
    }

    function getReferrerInfo(address account) public view returns(address referrer, uint256 refPercent, uint256 amountOfReferrals, uint256 totalBonuses) {
        referrer = users[account].referrer;
        refPercent = users[account].refPercent > 0 ? users[account].refPercent : REF_PERCENT;
        amountOfReferrals = users[account].referrals.length;
        totalBonuses = users[account].totalBonuses;
    }

    function getReferralInfo(address account, uint256 from, uint256 to) public view returns(address[] memory referrals, uint256[] memory bonuses) {
        uint256 amountOfReferrals = users[account].referrals.length;

        if (to > amountOfReferrals) {
            to = amountOfReferrals;
        }

        require(to >= from);

        uint256 length = to - from;

        referrals = new address[](length);
        bonuses = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            referrals[i] = users[account].referrals[from + i];
            bonuses[i] = users[referrals[i]].totalBonuses;
        }
    }

    function setParameters(bool _withdrawable, bool _rateChangeable) public onlyOwner {
        if (withdrawable && !_withdrawable) {
            withdrawable = false;
        }
        if (rateChangeable && !_rateChangeable) {
            rateChangeable = false;
        }
    }

    function setReferrer(address ref, uint256 refPercent) public onlySetter {
        require(ref != address(0) && refPercent <= FEE_PERCENT + REF_PERCENT);
        users[ref].refPercent = refPercent;
    }

    function setRate(uint256 newRateMul, uint256 newRateDiv) public onlySetter {
        require(rateChangeable && newRateMul >= 1 && newRateDiv >= 1);

        emit RateChanged(rateMul, rateDiv, newRateMul, newRateDiv);

        rateMul = newRateMul;
        rateDiv = newRateDiv;
    }

    function _bytesToAddress(bytes memory source) internal pure returns(address parsedreferrer) {
        assembly {
            parsedreferrer := mload(add(source,0x14))
        }
    }

}