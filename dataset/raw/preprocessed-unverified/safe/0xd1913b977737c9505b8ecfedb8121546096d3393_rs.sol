/**
 *Submitted for verification at Etherscan.io on 2021-07-02
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;











abstract contract IWETH {
    function allowance(address, address) public virtual view returns (uint256);

    function balanceOf(address) public virtual view returns (uint256);

    function approve(address, uint256) public virtual;

    function transfer(address, uint256) public virtual returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) public virtual returns (bool);

    function deposit() public payable virtual;

    function withdraw(uint256) public virtual;
}























































































contract LiquityHelper {
    using TokenUtils for address;

    uint constant public LUSD_GAS_COMPENSATION = 200e18;
    address constant public LUSDTokenAddr = 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0;
    address constant public LQTYTokenAddr = 0x6DEA81C8171D0bA574754EF6F8b412F2Ed88c54D;
    address constant public PriceFeedAddr = 0x4c517D4e2C851CA76d7eC94B805269Df0f2201De;
    address constant public BorrowerOperationsAddr = 0x24179CD81c9e782A4096035f7eC97fB8B783e007;
    address constant public TroveManagerAddr = 0xA39739EF8b0231DbFA0DcdA07d7e29faAbCf4bb2;
    address constant public SortedTrovesAddr = 0x8FdD3fbFEb32b28fb73555518f8b361bCeA741A6;
    address constant public HintHelpersAddr = 0xE84251b93D9524E0d2e621Ba7dc7cb3579F997C0;
    address constant public CollSurplusPoolAddr = 0x3D32e8b97Ed5881324241Cf03b2DA5E2EBcE5521;
    address constant public StabilityPoolAddr = 0x66017D22b0f8556afDd19FC67041899Eb65a21bb;
    address constant public LQTYStakingAddr = 0x4f9Fbb3f1E99B56e0Fe2892e623Ed36A76Fc605d;
    address constant public LQTYFrontEndAddr = 0x76720aC2574631530eC8163e4085d6F98513fb27;

    IPriceFeed constant public PriceFeed = IPriceFeed(PriceFeedAddr);
    IBorrowerOperations constant public BorrowerOperations = IBorrowerOperations(BorrowerOperationsAddr);
    ITroveManager constant public TroveManager = ITroveManager(TroveManagerAddr);
    ISortedTroves constant public SortedTroves = ISortedTroves(SortedTrovesAddr);
    IHintHelpers constant public HintHelpers = IHintHelpers(HintHelpersAddr);
    ICollSurplusPool constant public CollSurplusPool = ICollSurplusPool(CollSurplusPoolAddr);
    IStabilityPool constant public StabilityPool = IStabilityPool(StabilityPoolAddr);
    ILQTYStaking constant public LQTYStaking = ILQTYStaking(LQTYStakingAddr);

    function withdrawStaking(uint256 _ethGain, uint256 _lusdGain, address _wethTo, address _lusdTo) internal {
        if (_ethGain > 0) {
            TokenUtils.depositWeth(_ethGain);
            TokenUtils.WETH_ADDR.withdrawTokens(_wethTo, _ethGain);
        }
        if (_lusdGain > 0) {
            LUSDTokenAddr.withdrawTokens(_lusdTo, _lusdGain);
        }
    }
    
    function withdrawStabilityGains(uint256 _ethGain, uint256 _lqtyGain, address _wethTo, address _lqtyTo) internal {
        if (_ethGain > 0) {
            TokenUtils.depositWeth(_ethGain);
            TokenUtils.WETH_ADDR.withdrawTokens(_wethTo, _ethGain);
        }      
        if (_lqtyGain > 0) {
            LQTYTokenAddr.withdrawTokens(_lqtyTo, _lqtyGain);
        }
    }
}







contract LiquityView is LiquityHelper {
    using TokenUtils for address;
    using SafeMath for uint256;

    enum LiquityActionId {Open, Borrow, Payback, Supply, Withdraw}

    function isRecoveryMode() public view returns (bool) {
        uint256 price = PriceFeed.lastGoodPrice();
        return TroveManager.checkRecoveryMode(price);
    }

    function computeNICR(uint256 _coll, uint256 _debt) public pure returns (uint256) {
        if (_debt > 0) {
            return _coll.mul(1e20).div(_debt);
        }
        // Return the maximal value for uint256 if the Trove has a debt of 0. Represents "infinite" CR.
        else {
            // if (_debt == 0)
            return 2**256 - 1;
        }
    }

    /// @notice Predict the resulting nominal collateral ratio after a trove modifying action
    /// @param _troveOwner Address of the trove owner, if the action specified is LiquityOpen this argument is ignored
    /// @param _action LiquityActionIds
    function predictNICR(
        address _troveOwner,
        LiquityActionId _action,
        address _from,
        uint256 _collAmount,
        uint256 _lusdAmount
    ) external view returns (uint256 NICR) {
        //  LiquityOpen
        if (_action == LiquityActionId.Open) {
            if (!isRecoveryMode())
                _lusdAmount = _lusdAmount.add(TroveManager.getBorrowingFeeWithDecay(_lusdAmount));
            _lusdAmount = BorrowerOperations.getCompositeDebt(_lusdAmount);

            if (_collAmount == type(uint256).max)
                _collAmount = TokenUtils.WETH_ADDR.getBalance(_from);

            return computeNICR(_collAmount, _lusdAmount);
        }

        (uint256 debt, uint256 coll, , ) = TroveManager.getEntireDebtAndColl(_troveOwner);

        //  LiquityBorrow
        if (_action == LiquityActionId.Borrow) {
            if (!isRecoveryMode())
                _lusdAmount = _lusdAmount.add(TroveManager.getBorrowingFeeWithDecay(_lusdAmount));
            return computeNICR(coll, debt.add(_lusdAmount));
        }

        //  LiquityPayback
        if (_action == LiquityActionId.Payback) {
            return computeNICR(coll, debt.sub(_lusdAmount));
        }

        //  LiquitySupply
        if (_action == LiquityActionId.Supply) {
            if (_collAmount == type(uint256).max)
                _collAmount = TokenUtils.WETH_ADDR.getBalance(_from);

            return computeNICR(coll.add(_collAmount), debt);
        }

        //  LiquityWithdraw
        if (_action == LiquityActionId.Withdraw) {
            return computeNICR(coll.sub(_collAmount), debt);
        }
    }

    function getApproxHint(
        uint256 _CR,
        uint256 _numTrials,
        uint256 _inputRandomSeed
    )
        external
        view
        returns (
            address hintAddress,
            uint256 diff,
            uint256 latestRandomSeed
        )
    {
        return HintHelpers.getApproxHint(_CR, _numTrials, _inputRandomSeed);
    }

    function findInsertPosition(
        uint256 _ICR,
        address _prevId,
        address _nextId
    ) external view returns (address upperHint, address lowerHint) {
        return SortedTroves.findInsertPosition(_ICR, _prevId, _nextId);
    }

    function getTroveInfo(address _troveOwner)
        external
        view
        returns (
            uint256 troveStatus,
            uint256 collAmount,
            uint256 debtAmount,
            uint256 collPrice,
            uint256 TCRatio,
            bool recoveryMode
        )
    {
        troveStatus = TroveManager.getTroveStatus(_troveOwner);
        collAmount = TroveManager.getTroveColl(_troveOwner);
        debtAmount = TroveManager.getTroveDebt(_troveOwner);
        collPrice = PriceFeed.lastGoodPrice();
        TCRatio = TroveManager.getTCR(collPrice);
        recoveryMode = TroveManager.checkRecoveryMode(collPrice);
    }

    function getInsertPosition(
        uint256 _collAmount,
        uint256 _debtAmount,
        uint256 _numTrials,
        uint256 _inputRandomSeed
    ) external view returns (address upperHint, address lowerHint) {
        uint256 NICR = _collAmount.mul(1e20).div(_debtAmount);
        (address hintAddress, , ) = HintHelpers.getApproxHint(NICR, _numTrials, _inputRandomSeed);
        (upperHint, lowerHint) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
    }

    function getRedemptionHints(
        uint _LUSDamount, 
        uint _price,
        uint _maxIterations
    )
        external
        view
        returns (
        address firstRedemptionHint,
        uint partialRedemptionHintNICR,
        uint truncatedLUSDamount
    ) {
        return HintHelpers.getRedemptionHints(_LUSDamount, _price, _maxIterations);
    }
    
    function getStakeInfo(address _user) external view returns (uint256 stake, uint256 ethGain, uint256 lusdGain) {
        stake = LQTYStaking.stakes(_user);
        ethGain = LQTYStaking.getPendingETHGain(_user);
        lusdGain = LQTYStaking.getPendingLUSDGain(_user);
    }
    
    function getDepositorInfo(address _depositor) external view returns(uint256 compoundedLUSD, uint256 ethGain, uint256 lqtyGain) {
        compoundedLUSD = StabilityPool.getCompoundedLUSDDeposit(_depositor);
        ethGain = StabilityPool.getDepositorETHGain(_depositor);
        lqtyGain = StabilityPool.getDepositorLQTYGain(_depositor);
    }

    /// @notice Returns the debt in front of the users trove in the sorted list
    /// @param _of Address of the trove owner
    /// @param _acc Accumulated sum used in subsequent calls, 0 for first call
    /// @param _iterations Maximum number of troves to traverse
    /// @return next Trove owner address to be used in the subsequent call, address(0) at the end of list
    /// @return debt Accumulated debt to be used in the subsequent call
    function getDebtInFront(address _of, uint256 _acc, uint256 _iterations) external view returns (address next, uint256 debt) {
        next = _of;
        debt = _acc;
        for (uint256 i = 0; i < _iterations && next != address(0); i++) {
            next = SortedTroves.getNext(next);
            debt = debt.add(TroveManager.getTroveDebt(next));
        }
    }
}