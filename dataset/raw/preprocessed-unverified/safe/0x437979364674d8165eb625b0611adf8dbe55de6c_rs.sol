/**
 *Submitted for verification at Etherscan.io on 2020-07-16
*/

/**
 *Submitted for verification at Etherscan.io on 2020-07-15
*/

pragma experimental ABIEncoderV2;
pragma solidity ^0.6.0;




enum BondStage {
        //无意义状态
        DefaultStage,
        //评级
        RiskRating,
        RiskRatingFail,
        //募资
        CrowdFunding,
        CrowdFundingSuccess,
        CrowdFundingFail,
        UnRepay,//待还款
        RepaySuccess,
        Overdue,
        //由清算导致的债务结清
        DebtClosed
    }

//状态标签
enum IssuerStage {
        DefaultStage,
		UnWithdrawCrowd,
        WithdrawCrowdSuccess,
		UnWithdrawPawn,
        WithdrawPawnSuccess       
    }

/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/
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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}









/**
 * @dev Optional functions from the ERC20 standard.
 */
abstract contract ERC20Detailed is IERC20 {
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
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
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

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

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
     * - the caller must have allowance for `sender`'s tokens of at least
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
    // function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    //     _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    //     return true;
    // }

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
    // function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    //     _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    //     return true;
    // }

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

        // _beforeTokenTransfer(sender, recipient, amount);

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

        // _beforeTokenTransfer(address(0), account, amount);

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

        // _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    // function _burnFrom(address account, uint256 amount) internal virtual {
    //     _burn(account, amount);
    //     _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    // }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of `from`'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of `from`'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:using-hooks.adoc[Using Hooks].
     */
    // function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// File: ../../../../tmp/openzeppelin-contracts/contracts/token/ERC20/ERC20Burnable.sol
// pragma solidity ^0.6.0;
/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    // function burnFrom(address account, uint256 amount) public virtual {
    //     _burnFrom(account, amount);
    // }
}



/*
 * Copyright (c) The Force Protocol Development Team
 */


/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */








contract Core {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public ACL;
    address public router;
    address public config;
    address public oracle;
    ICoreUtils public coreUtils;
    address public nameGen;

    modifier auth {
        IACL _ACL = IACL(ACL);
        require(_ACL.accessible(msg.sender, address(this), msg.sig), "core: access unauthorized");
        _;
    }

    constructor(
        address _ACL,
        address _router,
        address _config,
        address _coreUtils,
        address _oracle,
	    address _nameGen
    ) public {
        ACL = _ACL;
        router = _router;
        config = _config;
        coreUtils = ICoreUtils(_coreUtils);
        oracle = _oracle;
	    nameGen = _nameGen;
    }

    function setCoreParamAddress(bytes32 k, address v) external auth {
        if (k == bytes32("router")) {
            router = v;
            return;
        }
        if (k == bytes32("config")) {
            config = v;
            return;
        }
        if (k == bytes32("coreUtils")) {
            coreUtils = ICoreUtils(v);
            return;
        }
        if (k == bytes32("oracle")) {
            oracle = v;
            return;
        }
        revert("setCoreParamAddress: invalid k");
    }

    function setACL(
        address _ACL) external {
        require(msg.sender == ACL, "require ACL");
        ACL = _ACL;
    }

    function d(uint256 id) public view returns (address) {
        return IRouter(router).defaultDataContract(id);
    }

    function bondData(uint256 id) public view returns (IBondData) {
        return IBondData(d(id));
    }

    event MonitorEvent(address indexed who, address indexed bond, bytes32 indexed funcName, bytes);

    function MonitorEventCallback(address who, address bond, bytes32 funcName, bytes calldata payload) external auth {
        emit MonitorEvent(who, bond, funcName, payload);
    }

    function initialDepositCb(uint256 id, uint256 amount) external auth {
        IBondData b = bondData(id);
        b.setBondParam("depositMultiple", IConfig(config).depositMultiple(b.collateralToken()));

        require(amount >= ICoreUtils(coreUtils).calcMinCollateralTokenAmount(id), "invalid deposit amount");
        
        // 支持评级
        if (b.supportRedeem()) {
            b.setBondParam("bondStage", uint256(BondStage.RiskRating));
            b.setBondParamAddress("gov", IConfig(config).gov());

            uint256 voteDuration = IConfig(config).voteDuration(); //s
            b.setBondParam("voteExpired", now + voteDuration);
        } else {
            b.setBondParam("bondStage", uint256(BondStage.CrowdFunding));
            b.setBondParam("voteExpired", now);//不支持评级的债券发债后，投票立即到期
            b.setBondParam("investExpired", now + IConfig(config).investDuration());
            b.setBondParam("bondExpired", now + IConfig(config).investDuration() + b.maturity());
        }

        b.setBondParam("gracePeriod", IConfig(config).gracePeriod());

        b.setBondParam("discount", IConfig(config).discount(b.collateralToken()));
        b.setBondParam("liquidateLine", IConfig(config).liquidateLine(b.collateralToken()));
        b.setBondParam("partialLiquidateAmount", IConfig(config).partialLiquidateAmount(b.crowdToken()));


        b.setBondParam("borrowAmountGive", b.getBorrowAmountGive().add(amount));
               

    }

    //发债方追加资金, amount为需要转入的token数
    function depositCb(address who, uint256 id, uint256 amount)
        external
        auth
        returns (bool)
    {
        require(d(id) != address(0) && bondData(id).issuer() == who, "invalid address or issuer");

        IBondData b = bondData(id);
        // //充值amount token到合约中，充值之前需要approve
        // safeTransferFrom(b.collateralToken(), msg.sender, address(this), address(this), amount);

        b.setBondParam("borrowAmountGive",b.getBorrowAmountGive().add(amount));

        return true;
    }

    //投资债券接口
    //id: 发行的债券id，唯一标志债券
    //amount： 投资的数量
    function investCb(address who, uint256 id, uint256 amount)
        external
        auth
        returns (bool)
    {
        IBondData b = bondData(id);
        require(d(id) != address(0) 
            && who != b.issuer() 
            && now <= b.investExpired()
            && b.bondStage() == uint(BondStage.CrowdFunding), "forbidden self invest, or invest is expired");
        uint256 bondAmount = coreUtils.convert2BondAmount(address(b), b.crowdToken(), amount);
        //投资不能超过剩余可投份数
        require(
            bondAmount > 0 && bondAmount <= coreUtils.remainInvestAmount(id),
            "invalid bondAmount"
        );
        b.mintBond(who, bondAmount);

        // //充值amount token到合约中，充值之前需要approve
        // safeTransferFrom(give, msg.sender, address(this), address(this), amount);

        require(coreUtils.remainInvestAmount(id) >= 0, "bond overflow");


        return true;
    }

    //停止融资, 开始计息
    function interestBearingPeriod(uint256 id) external {
        IBondData b = bondData(id);

        //设置众筹状态, 调用的前置条件必须满足债券投票完成并且通过.
        //@auth 仅允许 @Core 合约调用.
        require(d(id) != address(0)
            && b.bondStage() == uint256(BondStage.CrowdFunding)
            && (now > b.investExpired() || coreUtils.remainInvestAmount(id) == 0), "already closed invest");
        //计算融资进度.
        if (coreUtils.isMinIssuanceCheckOK(id)) {
            uint sysDebt = coreUtils.debtPlusTotalInterest(id);
            b.setBondParam("liability", sysDebt);
            b.setBondParam("originLiability", sysDebt);

            uint256 _1 = 1 ether;
            uint256 crowdUsdxLeverage = coreUtils.crowdBalanceInUsd(id)
                .mul(b.depositMultiple())
                .mul(b.liquidateLine())
                .div(1e36);

            //CCR < 0.7 * 4
            //pawnUsd/crowdUsd < 0.7*4
            bool unsafe = coreUtils.pawnBalanceInUsd(id) < crowdUsdxLeverage;
            if (unsafe) {
                b.setBondParam("bondStage", uint256(BondStage.CrowdFundingFail));
                b.setBondParam("issuerStage", uint256(IssuerStage.UnWithdrawPawn));
            } else {
                b.setBondParam("bondExpired", now + b.maturity());

                b.setBondParam("bondStage", uint256(BondStage.CrowdFundingSuccess));
                b.setBondParam("issuerStage", uint256(IssuerStage.UnWithdrawCrowd));

                //根据当前融资额度获取投票手续费.
                uint256 totalFee = b.totalFee();
                uint256 voteFee = totalFee.mul(IConfig(config).ratingFeeRatio()).div(_1);

                //支持评级
                if (b.supportRedeem()) {
                    b.setBondParam("fee", voteFee);
                    b.setBondParam("sysProfit", totalFee.sub(voteFee));
                } else {
                    b.setBondParam("fee", 0);//无投票手续费
                    b.setBondParam("sysProfit", totalFee);//发债手续费全部归ForTube平台
                }
            }
        } else {
            b.setBondParam("bondStage", uint256(BondStage.CrowdFundingFail));
            b.setBondParam("issuerStage", uint256(IssuerStage.UnWithdrawPawn));
        }

        emit MonitorEvent(msg.sender, address(b), "interestBearingPeriod", abi.encodePacked());
    }

    //转出募集到的资金,只有债券发行者可以转出资金
    function txOutCrowdCb(address who, uint256 id) external auth returns (uint) {
        IBondData b = IBondData(bondData(id));
        require(d(id) != address(0) && b.issuerStage() == uint(IssuerStage.UnWithdrawCrowd) && b.issuer() == who, "only txout crowd once or require issuer");


        uint256 balance = coreUtils.transferableAmount(id);
        // safeTransferFrom(crowd, address(this), address(this), msg.sender, balance);

        b.setBondParam("issuerStage", uint256(IssuerStage.WithdrawCrowdSuccess));
        b.setBondParam("bondStage", uint256(BondStage.UnRepay));

        return balance;
    }

    function overdueCb(uint256 id) external auth {
        IBondData b = IBondData(bondData(id));
        require(now >= b.bondExpired().add(b.gracePeriod()) 
            && (b.bondStage() == uint(BondStage.UnRepay) || b.bondStage() == uint(BondStage.CrowdFundingSuccess) ), "invalid overdue call state");
        b.setBondParam("bondStage", uint256(BondStage.Overdue));
        emit MonitorEvent(msg.sender, address(b), "overdue", abi.encodePacked());
    }

    //发债方还款
    //id: 发行的债券id，唯一标志债券
    //get: 募集的token地址
    //amount: 还款数量
    function repayCb(address who, uint256 id) external auth returns (uint) {
        require(d(id) != address(0) && bondData(id).issuer() == who, "invalid address or issuer");
        IBondData b = bondData(id);
        //募资成功，起息后即可还款,只有未还款或者逾期中可以还款，债务被关闭或者抵押物被清算完，不用还款
        require(
            b.bondStage() == uint(BondStage.UnRepay) || b.bondStage() == uint(BondStage.Overdue),
            "invalid state"
        );

        //充值repayAmount token到合约中，充值之前需要approve
        //使用amountGet进行计算
        uint256 repayAmount = b.liability();
        b.setBondParam("liability", 0);

        //safeTransferFrom(crowd, msg.sender, address(this), address(this), repayAmount);

        b.setBondParam("bondStage", uint256(BondStage.RepaySuccess));
        b.setBondParam("issuerStage", uint256(IssuerStage.UnWithdrawPawn));

        //清算一部分后,正常还款，需要设置清算中为false
        if (b.liquidating()) {
            b.setLiquidating(false);
        }

        return repayAmount;
    }

    //发债方取回质押token,在发债方已还清贷款的情况下，可以取回质押品
    //id: 发行的债券id，唯一标志债券
    //pawn: 抵押的token地址
    //amount: 取回数量
    function withdrawPawnCb(address who, uint256 id) external auth returns (uint) {
        IBondData b = bondData(id);
        require(d(id) != address(0) 
            && b.issuer() == who
            && b.issuerStage() == uint256(IssuerStage.UnWithdrawPawn), "invalid issuer, txout state or address");

        b.setBondParam("issuerStage", uint256(IssuerStage.WithdrawPawnSuccess));
        uint256 borrowGive = b.getBorrowAmountGive();
        //刚好结清债务和抵押物均为0（b.issuerStage() == uint256(IssuerStage.DebtClosed)）时，不能取回抵押物
        require(borrowGive > 0, "invalid give amount");
        b.setBondParam("borrowAmountGive", 0);//更新抵押品数量为0

        return borrowGive;
    }

    //募资失败，投资人凭借"债券"取回本金
    function withdrawPrincipalCb(address who, uint256 id)
        external
        auth
        returns (uint256)
    {
        IBondData b = bondData(id);

        //募资完成, 但是未募资成功.
        require(d(id) != address(0) && 
            b.bondStage() == uint(BondStage.CrowdFundingFail),
            "must crowdfunding failure"
        );

        (uint256 supplyGive) = b.getSupplyAmount(who);
        //safeTransferFrom(give, address(this), address(this), msg.sender, supplyGive);

        uint256 bondAmount = coreUtils.convert2BondAmount(
            address(b),
            b.crowdToken(),
            supplyGive
        );
        b.burnBond(who, bondAmount);


        return supplyGive;
    }

    //债券到期, 投资人取回本金和收益
    function withdrawPrincipalAndInterestCb(address who, uint256 id)
        external
        auth
        returns (uint256)
    {
        IBondData b = bondData(id);
        //募资成功，并且债券到期
        require(d(id) != address(0) && (
            b.bondStage() == uint(BondStage.RepaySuccess)
            || b.bondStage() == uint(BondStage.DebtClosed)),
            "unrepay or unliquidate"
        );


        (uint256 supplyGive) = b.getSupplyAmount(who);
        uint256 bondAmount = coreUtils.convert2BondAmount(
            address(b),
            b.crowdToken(),
            supplyGive
        );

        uint256 actualRepay = coreUtils.investPrincipalWithInterest(id, who);

        //safeTransferFrom(give, address(this), address(this), msg.sender, actualRepay);

        b.burnBond(who, bondAmount);


        return actualRepay;
    }

    function abs(uint256 a, uint256 b) internal pure returns (uint c) {
        c = a >= b ? a.sub(b) : b.sub(a);
    }

    function liquidateInternal(address who, uint256 id, uint y1, uint x1) internal returns (uint256, uint256, uint256, uint256) {
        IBondData b = bondData(id);
        require(b.issuer() != who, "can't self-liquidate");

        //当前已经处于清算中状态
        if (b.liquidating()) {
            bool depositMultipleUnsafe = coreUtils.isDepositMultipleUnsafe(id);
            require(depositMultipleUnsafe, "in depositMultiple safe state");
        } else {
            require(coreUtils.isUnsafe(id), "in safe state");

            //设置为清算中状态
            b.setLiquidating(true);
        }

        uint256 balance = IERC20(b.crowdToken()).balanceOf(who);
        uint256 y = coreUtils.Y(id);
        uint256 x = coreUtils.X(id);

        require(balance >= y1 && y1 <= y, "insufficient y1 or balance");

        if (y1 == b.liability() || abs(y1, b.liability()) <= uint256(1) 
        || x1 == b.getBorrowAmountGive() 
        || abs(x1, b.getBorrowAmountGive()) <= coreUtils.precision(id)) {
            b.setBondParam("bondStage", uint(BondStage.DebtClosed));
            b.setLiquidating(false);
        }

        if (y1 == b.liability() || abs(y1, b.liability()) <= uint256(1)) {
            if (!(x1 == b.getBorrowAmountGive() || abs(x1, b.getBorrowAmountGive()) <= coreUtils.precision(id))) {
                b.setBondParam("issuerStage", uint(IssuerStage.UnWithdrawPawn));
            }
        }

        //对债务误差为1的处理
        if (abs(y1, b.liability()) <= uint256(1)) {
            b.setBondParam("liability", 0);
        } else {
            b.setBondParam("liability", b.liability().sub(y1));
        }

        if (abs(x1, b.getBorrowAmountGive()) <= coreUtils.precision(id)) {
            b.setBondParam("borrowAmountGive", 0);
        } else {
            b.setBondParam("borrowAmountGive", b.getBorrowAmountGive().sub(x1));
        }


        if (!coreUtils.isDepositMultipleUnsafe(id)) {
            b.setLiquidating(false);
        }

        if (coreUtils.isDebtOpen(id)) {
            b.setBondParam("sysProfit", b.sysProfit().add(b.fee()));
            b.setBondParam("fee", 0);
        }

        return (y1, x1, y, x);
    }

    //分批清算债券接口
    //id: 债券发行id，同上
    function liquidateCb(address who, uint256 id, uint256 y1)
        external
        auth
        returns (uint256, uint256, uint256, uint256)
    {
        (uint y, uint x) = coreUtils.getLiquidateAmount(id, y1);

        return liquidateInternal(who, id, y, x);
    }

    //取回系统盈利
    function withdrawSysProfitCb(address who, uint256 id) external auth returns (uint256) {
        IBondData b = bondData(id);
        uint256 _sysProfit = b.sysProfit();
        require(_sysProfit > 0, "no withdrawable sysProfit");
        b.setBondParam("sysProfit", 0);
        return _sysProfit;
    }
}