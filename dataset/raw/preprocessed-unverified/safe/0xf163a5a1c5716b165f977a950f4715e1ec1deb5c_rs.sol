/**
 *Submitted for verification at Etherscan.io on 2021-04-15
*/

pragma solidity 0.6.12;


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

// File: contracts/GSN/Context.sol
// SPDX-License-Identifier: MIT
// File: contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/utils/Address.sol
/**
 * @dev Collection of functions related to the address type
 */


// File: contracts/token/ERC20/ERC20.sol
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


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */






















// Strategy Contract Basics
abstract contract StrategyBase {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    // Perfomance fee 30% to buyback
    uint256 public performanceFee = 30000;
    uint256 public constant performanceMax = 100000;

    // Withdrawal fee 0.2% to buyback
    // - 0.14% to treasury
    // - 0.06% to dev fund
    uint256 public treasuryFee = 140;
    uint256 public constant treasuryMax = 100000;

    uint256 public devFundFee = 60;
    uint256 public constant devFundMax = 100000;

    // delay yield profit realization
    uint256 public delayBlockRequired = 1000;
    uint256 public lastHarvestBlock;
    uint256 public lastHarvestInWant;

    // buyback ready
    bool public buybackEnabled = true;
    address public mmToken = 0xa283aA7CfBB27EF0cfBcb2493dD9F4330E0fd304;
    address public masterChef = 0xf8873a6080e8dbF41ADa900498DE0951074af577;

    //curve rewards
    address public crv = 0xD533a949740bb3306d119CC777fa900bA034cd52;

    // Tokens
    address public want;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // buyback coins
    address public constant usdcBuyback = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant zrxBuyback = 0xE41d2489571d322189246DaFA5ebDe1F4699F498;

    // User accounts
    address public governance;
    address public controller;
    address public strategist;
    address public timelock;

    // Dex
    address public univ2Router2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    //Sushi
    address constant public sushiRouter = address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    constructor(
        address _want,
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    ) public {
        require(_want != address(0));
        require(_governance != address(0));
        require(_strategist != address(0));
        require(_controller != address(0));
        require(_timelock != address(0));

        want = _want;
        governance = _governance;
        strategist = _strategist;
        controller = _controller;
        timelock = _timelock;
    }

    // **** Modifiers **** //

    modifier onlyBenevolent {
        require(
            msg.sender == tx.origin ||
                msg.sender == governance ||
                msg.sender == strategist
        );
        _;
    }

    // **** Views **** //

    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfPool() public virtual view returns (uint256);

    function balanceOf() public view returns (uint256) {
        uint256 delayReduction;
        uint256 currentBlock = block.number;
        if (delayBlockRequired > 0 && lastHarvestInWant > 0 && currentBlock.sub(lastHarvestBlock) < delayBlockRequired){
            uint256 diffBlock = lastHarvestBlock.add(delayBlockRequired).sub(currentBlock);
            delayReduction = lastHarvestInWant.mul(diffBlock).mul(1e18).div(delayBlockRequired).div(1e18);
        }
        return balanceOfWant().add(balanceOfPool()).sub(delayReduction);
    }

    function getName() external virtual pure returns (string memory);

    // **** Setters **** //

    function setDelayBlockRequired(uint256 _delayBlockRequired) external {
        require(msg.sender == governance, "!governance");
        delayBlockRequired = _delayBlockRequired;
    }

    function setDevFundFee(uint256 _devFundFee) external {
        require(msg.sender == timelock, "!timelock");
        devFundFee = _devFundFee;
    }

    function setTreasuryFee(uint256 _treasuryFee) external {
        require(msg.sender == timelock, "!timelock");
        treasuryFee = _treasuryFee;
    }

    function setPerformanceFee(uint256 _performanceFee) external {
        require(msg.sender == timelock, "!timelock");
        performanceFee = _performanceFee;
    }

    function setStrategist(address _strategist) external {
        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setTimelock(address _timelock) external {
        require(msg.sender == timelock, "!timelock");
        timelock = _timelock;
    }

    function setController(address _controller) external {
        require(msg.sender == timelock, "!timelock");
        controller = _controller;
    }

    function setMmToken(address _mmToken) external {
        require(msg.sender == governance, "!governance");
        mmToken = _mmToken;
    }

    function setBuybackEnabled(bool _buybackEnabled) external {
        require(msg.sender == governance, "!governance");
        buybackEnabled = _buybackEnabled;
    }

    function setMasterChef(address _masterChef) external {
        require(msg.sender == governance, "!governance");
        masterChef = _masterChef;
    }

    // **** State mutations **** //
    function deposit() public virtual;

    function withdraw(IERC20 _asset) external virtual returns (uint256 balance);

    // Controller only function for creating additional rewards from dust
    function _withdrawNonWantAsset(IERC20 _asset) internal returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint256 _amount) external {
        require(msg.sender == controller, "!controller");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
				
        uint256 _feeDev = _amount.mul(devFundFee).div(devFundMax);
        uint256 _feeTreasury = _amount.mul(treasuryFee).div(treasuryMax);

        if (buybackEnabled == true) {
            // we want buyback mm using LP token
            (address _buybackPrinciple, uint256 _buybackAmount) = _convertWantToBuyback(_feeDev.add(_feeTreasury));
            buybackAndNotify(_buybackPrinciple, _buybackAmount);
        } else {
            IERC20(want).safeTransfer(IController(controller).devfund(), _feeDev);
            IERC20(want).safeTransfer(IController(controller).treasury(), _feeTreasury);
        }

        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds

        IERC20(want).safeTransfer(_vault, _amount.sub(_feeDev).sub(_feeTreasury));
    }
	
    // buyback MM and notify MasterChef
    function buybackAndNotify(address _buybackPrinciple, uint256 _buybackAmount) internal {
        if (buybackEnabled == true) {
            _swapUniswap(_buybackPrinciple, mmToken, _buybackAmount);
            uint256 _mmBought = IERC20(mmToken).balanceOf(address(this));
            IERC20(mmToken).safeTransfer(masterChef, _mmBought);
            IMasterchef(masterChef).notifyBuybackReward(_mmBought);
        }
    }

    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();

        balance = IERC20(want).balanceOf(address(this));

        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }

    function _withdrawAll() internal {
        _withdrawSome(balanceOfPool());
    }

    function _withdrawSome(uint256 _amount) internal virtual returns (uint256);	
	
    // convert LP to buyback principle token
    function _convertWantToBuyback(uint256 _lpAmount) internal virtual returns (address, uint256);

    // each harvest need to update `lastHarvestBlock=block.number` and `lastHarvestInWant=yield profit converted to want for re-invest`
    function harvest() public virtual;

    // **** Emergency functions ****

    function execute(address _target, bytes memory _data)
        public
        payable
        returns (bytes memory response)
    {
        require(msg.sender == timelock, "!timelock");
        require(_target != address(0), "!target");

        // call contract in current context
        assembly {
            let succeeded := delegatecall(
                sub(gas(), 5000),
                _target,
                add(_data, 0x20),
                mload(_data),
                0,
                0
            )
            let size := returndatasize()

            response := mload(0x40)
            mstore(
                0x40,
                add(response, and(add(add(size, 0x20), 0x1f), not(0x1f)))
            )
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
                case 1 {
                    // throw if delegatecall failed
                    revert(add(response, 0x20), size)
                }
        }
    }

    // **** Internal functions ****
    function _swapUniswap(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        require(_to != address(0));

        if (_amount > 0){

            address[] memory path = (_to == usdcBuyback)? new address[](3) : new address[](2);
            path[0] = _from;
            if (_to == usdcBuyback){
                path[1] = weth;
                path[2] = _to;
            }else{
                path[1] = _to;
            }

            UniswapRouterV2(univ2Router2).swapExactTokensForTokens(
                _amount,
                0,
                path,
                address(this),
                now
            );
        }
    }

}





abstract contract StrategyUnitBase is StrategyBase {
    // Unit Protocol module: https://github.com/unitprotocol/core/blob/master/CONTRACTS.md	
    address public constant cdpMgr01 = 0x0e13ab042eC5AB9Fc6F43979406088B9028F66fA;
    address public constant unitVault = 0xb1cFF81b9305166ff1EFc49A129ad2AfCd7BCf19;		
    address public constant unitVaultParameters = 0xB46F8CF42e504Efe8BEf895f848741daA55e9f1D;	
    address public constant debtToken = 0x1456688345527bE1f37E9e627DA0837D6f08C925;
    address public constant eth_usd = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    // sub-strategy related constants
    address public collateral;
    uint256 public collateralDecimal = 1e18;
    address public unitOracle;
    uint256 public collateralPriceDecimal = 1;
    bool public collateralPriceEth = false;
	
    // configurable minimum collateralization percent this strategy would hold for CDP
    uint256 public minRatio = 200;
    // collateralization percent buffer in CDP debt actions
    uint256 public ratioBuff = 200;
    uint256 public constant ratioBuffMax = 10000;

    // Keeper bots, maintain ratio above minimum requirement
    mapping(address => bool) public keepers;

    constructor(
        address _collateral,
        uint256 _collateralDecimal,
        address _collateralOracle,
        uint256 _collateralPriceDecimal,
        bool _collateralPriceEth,
        address _want,
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        StrategyBase(_want, _governance, _strategist, _controller, _timelock)
    {
        require(_want == _collateral, '!mismatchWant');
		    
        collateral = _collateral;   
        collateralDecimal = _collateralDecimal;
        unitOracle = _collateralOracle;
        collateralPriceDecimal = _collateralPriceDecimal;
        collateralPriceEth = _collateralPriceEth;		
		
        IERC20(collateral).safeApprove(unitVault, uint256(-1));
        IERC20(debtToken).safeApprove(unitVault, uint256(-1));
    }

    // **** Modifiers **** //

    modifier onlyKeepers {
        require(keepers[msg.sender] || msg.sender == address(this) || msg.sender == strategist || msg.sender == governance, "!keepers");
        _;
    }
	
    modifier onlyGovernanceAndStrategist {
        require(msg.sender == governance || msg.sender == strategist, "!governance");
        _;
    }
	
    modifier onlyCDPInUse {
        uint256 collateralAmt = getCollateralBalance();
        require(collateralAmt > 0, '!zeroCollateral');
		
        uint256 debtAmt = getDebtBalance();
        require(debtAmt > 0, '!zeroDebt');		
        _;
    }
	
    function getCollateralBalance() public view returns (uint256) {
        return IUnitVault(unitVault).collaterals(collateral, address(this));
    }
	
    function getDebtBalance() public view returns (uint256) {
        return IUnitVault(unitVault).getTotalDebt(collateral, address(this));
    }	
	
    function getDebtWithoutFee() public view returns (uint256) {
        return IUnitVault(unitVault).debts(collateral, address(this));
    }	

    // **** Getters ****
	
    function debtLimit() public view returns (uint256){
        return IUnitVaultParameters(unitVaultParameters).tokenDebtLimit(collateral);
    }
	
    function debtUsed() public view returns (uint256){
        return IUnitVault(unitVault).tokenDebts(collateral);
    }
	
    function balanceOfPool() public override view returns (uint256){
        return getCollateralBalance();
    }

    function collateralValue(uint256 collateralAmt) public view returns (uint256){
        uint256 collateralPrice = getLatestCollateralPrice();
        return collateralAmt.mul(collateralPrice).mul(1e18).div(collateralDecimal).div(collateralPriceDecimal);// debtToken in 1e18 decimal
    }

    function currentRatio() public onlyCDPInUse view returns (uint256) {	    
        uint256 collateralAmt = collateralValue(getCollateralBalance()).mul(100);
        uint256 debtAmt = getDebtBalance();		
        return collateralAmt.div(debtAmt);
    } 
    
    // if borrow is true (for lockAndDraw): return (maxDebt - currentDebt) if positive value, otherwise return 0
    // if borrow is false (for redeemAndFree): return (currentDebt - maxDebt) if positive value, otherwise return 0
    function calculateDebtFor(uint256 collateralAmt, bool borrow) public view returns (uint256) {
        uint256 maxDebt = collateralValue(collateralAmt).mul(ratioBuffMax).div(_getBufferedMinRatio(ratioBuffMax));
		
        uint256 debtAmt = getDebtBalance();
		
        uint256 debt = 0;
        
        if (borrow && maxDebt >= debtAmt){
            debt = maxDebt.sub(debtAmt);
        } else if (!borrow && debtAmt >= maxDebt){
            debt = debtAmt.sub(maxDebt);
        }
        
        return (debt > 0)? debt : 0;
    }
	
    function _getBufferedMinRatio(uint256 _multiplier) internal view returns (uint256){
        return minRatio.mul(_multiplier).mul(ratioBuffMax.add(ratioBuff)).div(ratioBuffMax).div(100);
    }

    function borrowableDebt() public view returns (uint256) {
        uint256 collateralAmt = getCollateralBalance();
        return calculateDebtFor(collateralAmt, true);
    }

    function requiredPaidDebt(uint256 _redeemCollateralAmt) public view returns (uint256) {
        uint256 collateralAmt = getCollateralBalance().sub(_redeemCollateralAmt);
        return calculateDebtFor(collateralAmt, false);
    }

    // **** sub-strategy implementation ****
    function _convertWantToBuyback(uint256 _lpAmount) internal virtual override returns (address, uint256);
	
    function _depositUSDP(uint256 _usdpAmt) internal virtual;
	
    function _withdrawUSDP(uint256 _usdpAmt) internal virtual;
	
    // **** Oracle (using chainlink) ****
	
    function getLatestCollateralPrice() public view returns (uint256){
        require(unitOracle != address(0), '!_collateralOracle');	
		
        (,int price,,,) = AggregatorV3Interface(unitOracle).latestRoundData();
		
        if (price > 0){		
            int ethPrice = 1;
            if (collateralPriceEth){
               (,ethPrice,,,) = AggregatorV3Interface(eth_usd).latestRoundData();// eth price from chainlink in 1e8 decimal		
            }
            return uint256(price).mul(collateralPriceDecimal).mul(uint256(ethPrice)).div(1e8).div(collateralPriceEth? 1e18 : 1);
        } else{
            return 0;
        }
    }

    // **** Setters ****
	
    function setMinRatio(uint256 _minRatio) external onlyGovernanceAndStrategist {
        minRatio = _minRatio;
    }	
	
    function setRatioBuff(uint256 _ratioBuff) external onlyGovernanceAndStrategist {
        ratioBuff = _ratioBuff;
    }	

    function setKeeper(address _keeper, bool _enabled) external onlyGovernanceAndStrategist {
        keepers[_keeper] = _enabled;
    }
	
    // **** Unit Protocol CDP actions ****
	
    function addCollateralAndBorrow(uint256 _collateralAmt, uint256 _usdpAmt) internal {   
        require(_usdpAmt.add(debtUsed()) < debtLimit(), '!exceedLimit');
        IUnitCDPManager(cdpMgr01).join(collateral, _collateralAmt, _usdpAmt);		
    } 
	
    function repayAndRedeemCollateral(uint256 _collateralAmt, uint _usdpAmt) internal { 
        IUnitCDPManager(cdpMgr01).exit(collateral, _collateralAmt, _usdpAmt);     		
    } 

    // **** State Mutation functions ****
	
    function keepMinRatio() external onlyCDPInUse onlyKeepers {		
        uint256 requiredPaidback = requiredPaidDebt(0);
        if (requiredPaidback > 0){
            _withdrawUSDP(requiredPaidback);
			
            uint256 _actualPaidDebt = IERC20(debtToken).balanceOf(address(this));
            uint256 _fee = getDebtBalance().sub(getDebtWithoutFee());
			
            require(_actualPaidDebt > _fee, '!notEnoughForFee');	
            _actualPaidDebt = _actualPaidDebt.sub(_fee);// unit protocol will charge fee first
            _actualPaidDebt = _capMaxDebtPaid(_actualPaidDebt);			
			
            require(IERC20(debtToken).balanceOf(address(this)) >= _actualPaidDebt.add(_fee), '!notEnoughRepayment');
            repayAndRedeemCollateral(0, _actualPaidDebt);
        }
    }
	
    function deposit() public override {
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {	
            uint256 _newDebt = calculateDebtFor(_want.add(getCollateralBalance()), true);
            if (_newDebt > 0){
                addCollateralAndBorrow(_want, _newDebt);
                uint256 wad = IERC20(debtToken).balanceOf(address(this));
                _depositUSDP(_newDebt > wad? wad : _newDebt);
            }
        }
    }
	
    // to avoid repay all debt
    function _capMaxDebtPaid(uint256 _actualPaidDebt) internal view returns(uint256){
        uint256 _maxDebtToRepay = getDebtWithoutFee().sub(ratioBuffMax);
        return _actualPaidDebt >= _maxDebtToRepay? _maxDebtToRepay : _actualPaidDebt;
    }

    function _withdrawSome(uint256 _amount) internal override returns (uint256) {
        if (_amount == 0){
            return _amount;
        }
        
        uint256 requiredPaidback = requiredPaidDebt(_amount);		
        if (requiredPaidback > 0){
            _withdrawUSDP(requiredPaidback);
        }
		
        bool _fullWithdraw = _amount == balanceOfPool();
        uint256 _wantBefore = IERC20(want).balanceOf(address(this));
        if (!_fullWithdraw){
            uint256 _actualPaidDebt = IERC20(debtToken).balanceOf(address(this));
            uint256 _fee = getDebtBalance().sub(getDebtWithoutFee());
		
            require(_actualPaidDebt > _fee, '!notEnoughForFee');				
            _actualPaidDebt = _actualPaidDebt.sub(_fee); // unit protocol will charge fee first
            _actualPaidDebt = _capMaxDebtPaid(_actualPaidDebt);
			
            require(IERC20(debtToken).balanceOf(address(this)) >= _actualPaidDebt.add(_fee), '!notEnoughRepayment');
            repayAndRedeemCollateral(_amount, _actualPaidDebt);			
        }else{
            require(IERC20(debtToken).balanceOf(address(this)) >= getDebtBalance(), '!notEnoughFullRepayment');
            repayAndRedeemCollateral(_amount, getDebtBalance());
            require(getDebtBalance() == 0, '!leftDebt');
            require(getCollateralBalance() == 0, '!leftCollateral');
        }
		
        uint256 _wantAfter = IERC20(want).balanceOf(address(this));		
        return _wantAfter.sub(_wantBefore);
    }
    
}

contract StrategyUnitRenbtcV1 is StrategyUnitBase {
    // strategy specific
    address public constant renbtc_collateral = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
    uint256 public constant renbtc_collateral_decimal = 1e8;
    address public constant renbtc_oracle = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c;
    uint256 public constant renbtc_price_decimal = 1;
    bool public constant renbtc_price_eth = false;
	
    // farming in usdp3crv 
    address public constant usdp3crv = 0x7Eb40E450b9655f4B3cC4259BCC731c63ff55ae6;
    address public constant usdp = 0x1456688345527bE1f37E9e627DA0837D6f08C925;
    address public constant usdp_gauge = 0x055be5DDB7A925BfEF3417FC157f53CA77cA7222;
    address public constant curvePool = 0x42d7025938bEc20B69cBae5A77421082407f053A;
    address public constant mintr = 0xd061D61a4d941c39E5453435B6345Dc261C2fcE0;
    
    // slippage protection for one-sided ape in/out
    uint256 public slippageProtectionIn = 50; // max 0.5%
    uint256 public slippageProtectionOut = 50; // max 0.5%
    uint256 public constant DENOMINATOR = 10000;

    constructor(address _governance, address _strategist, address _controller, address _timelock) 
        public StrategyUnitBase(
            renbtc_collateral,
            renbtc_collateral_decimal,
            renbtc_oracle,
            renbtc_price_decimal,
            renbtc_price_eth,
            renbtc_collateral,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {
        // approve for Curve pool and DEX
        IERC20(usdp).safeApprove(curvePool, uint256(-1));
        IERC20(usdp3crv).safeApprove(curvePool, uint256(-1));
        
        IERC20(usdp3crv).safeApprove(usdp_gauge, uint256(-1));
        
        IERC20(crv).safeApprove(univ2Router2, uint256(-1));
        IERC20(weth).safeApprove(univ2Router2, uint256(-1));
        IERC20(renbtc_collateral).safeApprove(univ2Router2, uint256(-1));
        IERC20(usdcBuyback).safeApprove(univ2Router2, uint256(-1));
    }
	
    // **** Setters ****	
	
    function setSlippageProtectionIn(uint256 _slippage) external onlyGovernanceAndStrategist{
        slippageProtectionIn = _slippage;
    }
	
    function setSlippageProtectionOut(uint256 _slippage) external onlyGovernanceAndStrategist{
        slippageProtectionOut = _slippage;
    }
	
    // **** State Mutation functions ****	

    function getHarvestable() external returns (uint256) {
        return ICurveGauge(usdp_gauge).claimable_tokens(address(this));
    }

    function _convertWantToBuyback(uint256 _lpAmount) internal override returns (address, uint256){
        _swapUniswap(renbtc_collateral, usdcBuyback, _lpAmount);
        return (usdcBuyback, IERC20(usdcBuyback).balanceOf(address(this)));
    }	
	
    function harvest() public override onlyBenevolent {

        // Collects crv tokens
        ICurveMintr(mintr).mint(usdp_gauge);
        uint256 _crv = IERC20(crv).balanceOf(address(this));
        if (_crv > 0) {
            _swapUniswap(crv, weth, _crv);
        }

        // buyback $MM
        uint256 _to = IERC20(weth).balanceOf(address(this));
        uint256 _buybackAmount = _to.mul(performanceFee).div(performanceMax);		
        if (buybackEnabled == true && _buybackAmount > 0) {
            buybackAndNotify(weth, _buybackAmount);
        }
		
        // re-invest to compounding profit
        _swapUniswap(weth, want, IERC20(weth).balanceOf(address(this)));
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            lastHarvestBlock = block.number;
            lastHarvestInWant = _want;
            deposit();
        }
    }
	
    function _depositUSDP(uint256 _usdpAmt) internal override{	
        if (_usdpAmt > 0 && checkSlip(_usdpAmt)) {
            uint256[2] memory amounts = [_usdpAmt, 0]; 
            ICurveFi_2(curvePool).add_liquidity(amounts, 0);
        }
		
        uint256 _usdp3crv = IERC20(usdp3crv).balanceOf(address(this));
        if (_usdp3crv > 0){
            ICurveGauge(usdp_gauge).deposit(_usdp3crv);		
        }
    }
	
    function _withdrawUSDP(uint256 _usdpAmt) internal override {	
        uint256 _requiredUsdp3crv = estimateRequiredUsdp3crv(_usdpAmt);
        _requiredUsdp3crv = _requiredUsdp3crv.mul(DENOMINATOR.add(slippageProtectionOut)).div(DENOMINATOR);// try to remove bit more
		
        uint256 _usdp3crv = IERC20(usdp3crv).balanceOf(address(this));
        uint256 _withdrawFromGauge = _usdp3crv < _requiredUsdp3crv? _requiredUsdp3crv.sub(_usdp3crv) : 0;
			
        if (_withdrawFromGauge > 0){
            uint256 maxInGauge = ICurveGauge(usdp_gauge).balanceOf(address(this));
            ICurveGauge(usdp_gauge).withdraw(maxInGauge < _withdrawFromGauge? maxInGauge : _withdrawFromGauge);			
        }
		    	
        _usdp3crv = IERC20(usdp3crv).balanceOf(address(this));
        if (_usdp3crv > 0){
            _requiredUsdp3crv = _requiredUsdp3crv > _usdp3crv?  _usdp3crv : _requiredUsdp3crv;
            uint256 maxSlippage = _requiredUsdp3crv.mul(DENOMINATOR.sub(slippageProtectionOut)).div(DENOMINATOR);
            ICurveFi_2(curvePool).remove_liquidity_one_coin(_requiredUsdp3crv, 0, maxSlippage);			
        }
    }

    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external override returns (uint256 balance) {
        require(usdp3crv != address(_asset), "!usdp3crv");
        require(usdp != address(_asset), "!usdp");
        return _withdrawNonWantAsset(_asset);
    }

    // **** Views ****

    function virtualPriceToWant() public view returns (uint256) {
        return ICurveFi_2(curvePool).get_virtual_price();
    }
	
    function estimateRequiredUsdp3crv(uint256 _usdpAmt) public view returns (uint256) {
        uint256[2] memory amounts = [_usdpAmt, 0]; 
        return ICurveFi_2(curvePool).calc_token_amount(amounts, false);
    }
	
    function checkSlip(uint256 _usdpAmt) public view returns (bool){
        uint256 expectedOut = _usdpAmt.mul(1e18).div(virtualPriceToWant());
        uint256 maxSlip = expectedOut.mul(DENOMINATOR.sub(slippageProtectionIn)).div(DENOMINATOR);

        uint256[2] memory amounts = [_usdpAmt, 0]; 
        return ICurveFi_2(curvePool).calc_token_amount(amounts, true) >= maxSlip;
    }

    function getName() external override pure returns (string memory) {
        return "StrategyUnitRenbtcV1";
    }
}