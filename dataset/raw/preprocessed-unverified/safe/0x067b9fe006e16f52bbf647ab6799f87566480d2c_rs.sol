/**
 *Submitted for verification at Etherscan.io on 2021-04-13
*/

// SPDX-License-Identifier: MIT
/*
This is a Stacker.vc FarmTreasury version 1 contract. It deploys a rebase token where it rebases to be equivalent to it's underlying token. 1 stackUSDT = 1 USDT.
The underlying assets are used to farm on different smart contract and produce yield via the ever-expanding DeFi ecosystem.

THANKS! To Lido DAO for the inspiration in more ways than one, but especially for a lot of the code here. 
If you haven't already, stake your ETH for ETH2.0 with Lido.fi!

Also thanks for Aragon for hosting our Stacker Ventures DAO, and for more inspiration!
*/

pragma solidity ^0.6.11;

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

/**
 * @dev Collection of functions related to the address type
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

    constructor () internal {
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
 * @dev Interface of the ERC20 standard as defined in the EIP.
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


abstract contract FarmTokenV1 is IERC20 {
    using SafeMath for uint256;
    using Address for address;

    // shares are how a users balance is generated. For rebase tokens, balances are always generated at runtime, while shares stay constant.
    // shares is your proportion of the total pool of invested UnderlyingToken
    // shares are like a Compound.finance cToken, while our token balances are like an Aave aToken.
    mapping(address => uint256) private shares;
    mapping(address => mapping (address => uint256)) private allowances;

    uint256 public totalShares;

    string public name;
    string public symbol;
    string public underlying;
    address public underlyingContract;

    uint8 public decimals;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, uint8 _decimals, address _underlyingContract) public {
        name = string(abi.encodePacked(abi.encodePacked("Stacker Ventures ", _name), " v1"));
        symbol = string(abi.encodePacked("stack", _name));
        underlying = _name;

        decimals = _decimals;

        underlyingContract = _underlyingContract;
    }

    // 1 stackToken = 1 underlying token
    function totalSupply() external override view returns (uint256){
        return _getTotalUnderlying();
    }

    function totalUnderlying() external view returns (uint256){
        return _getTotalUnderlying();
    }

    function balanceOf(address _account) public override view returns (uint256){
        return getUnderlyingForShares(_sharesOf(_account));
    }

    // transfer tokens, not shares
    function transfer(address _recipient, uint256 _amount) external override returns (bool){
        _verify(msg.sender, _amount);
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) external override returns (bool){
        _verify(_sender, _amount);
        uint256 _currentAllowance = allowances[_sender][msg.sender];
        require(_currentAllowance >= _amount, "FARMTOKENV1: not enough allowance");

        _transfer(_sender, _recipient, _amount);
        _approve(_sender, msg.sender, _currentAllowance.sub(_amount));
        return true;
    }

    // this checks if a transfer/transferFrom/withdraw is allowed. There are some conditions on withdraws/transfers from new deposits
    // function stub, this needs to be implemented in a contract which inherits this for a valid deployment
    // IMPLEMENT THIS
    function _verify(address _account, uint256 _amountUnderlyingToSend) internal virtual;

    // allow tokens, not shares
    function allowance(address _owner, address _spender) external override view returns (uint256){
        return allowances[_owner][_spender];
    }

    // approve tokens, not shares
    function approve(address _spender, uint256 _amount) external override returns (bool){
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    // shares of _account
    function sharesOf(address _account) external view returns (uint256) {
        return _sharesOf(_account);
    }

    // how many shares for _amount of underlying?
    // if there are no shares, or no underlying yet, we are initing the contract or suffered a total loss
    // either way, init this state at 1:1 shares:underlying
    function getSharesForUnderlying(uint256 _amountUnderlying) public view returns (uint256){
        uint256 _totalUnderlying = _getTotalUnderlying();
        if (_totalUnderlying == 0){
            return _amountUnderlying; // this will init at 1:1 _underlying:_shares
        }
        uint256 _totalShares = totalShares;
        if (_totalShares == 0){
            return _amountUnderlying; // this will init the first shares, expected contract underlying balance == 0, or there will be a bonus (doesn't belong to anyone so ok)
        }

        return _amountUnderlying.mul(_totalShares).div(_totalUnderlying);
    }

    // how many underlying for _amount of shares?
    // if there are no shares, or no underlying yet, we are initing the contract or suffered a total loss
    // either way, init this state at 1:1 shares:underlying
    function getUnderlyingForShares(uint256 _amountShares) public view returns (uint256){
        uint256 _totalShares = totalShares;
        if (_totalShares == 0){
            return _amountShares; // this will init at 1:1 _shares:_underlying
        }
        uint256 _totalUnderlying = _getTotalUnderlying();
        if (_totalUnderlying == 0){
            return _amountShares; // this will init at 1:1 
        }

        return _amountShares.mul(_totalUnderlying).div(_totalShares);

    }

    function _sharesOf(address _account) internal view returns (uint256){
        return shares[_account];
    }

    // function stub, this needs to be implemented in a contract which inherits this for a valid deployment
    // sum the contract balance + working balance withdrawn from the contract and actively farming
    // IMPLEMENT THIS
    function _getTotalUnderlying() internal virtual view returns (uint256);

    // in underlying
    function _transfer(address _sender, address _recipient, uint256 _amount) internal {
        uint256 _sharesToTransfer = getSharesForUnderlying(_amount);
        _transferShares(_sender, _recipient, _sharesToTransfer);
        emit Transfer(_sender, _recipient, _amount);
    }

    // in underlying
    function _approve(address _owner, address _spender, uint256 _amount) internal {
        require(_owner != address(0), "FARMTOKENV1: from == 0x0");
        require(_spender != address(0), "FARMTOKENV1: to == 0x00");

        allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function _transferShares(address _sender, address _recipient,  uint256 _amountShares) internal {
        require(_sender != address(0), "FARMTOKENV1: from == 0x00");
        require(_recipient != address(0), "FARMTOKENV1: to == 0x00");

        uint256 _currentSenderShares = shares[_sender];
        require(_amountShares <= _currentSenderShares, "FARMTOKENV1: transfer amount exceeds balance");

        shares[_sender] = _currentSenderShares.sub(_amountShares);
        shares[_recipient] = shares[_recipient].add(_amountShares);
    }

    function _mintShares(address _recipient, uint256 _amountShares) internal {
        require(_recipient != address(0), "FARMTOKENV1: to == 0x00");

        totalShares = totalShares.add(_amountShares);
        shares[_recipient] = shares[_recipient].add(_amountShares);

        // NOTE: we're not emitting a Transfer event from the zero address here
        // If we mint shares with no underlying, we basically just diluted everyone

        // It's not possible to send events from _everyone_ to reflect each balance dilution (ie: balance going down)

        // Not compliant to ERC20 standard...
    }

    function _burnShares(address _account, uint256 _amountShares) internal {
        require(_account != address(0), "FARMTOKENV1: burn from == 0x00");

        uint256 _accountShares = shares[_account];
        require(_amountShares <= _accountShares, "FARMTOKENV1: burn amount exceeds balance");
        totalShares = totalShares.sub(_amountShares);

        shares[_account] = _accountShares.sub(_amountShares);

        // NOTE: we're not emitting a Transfer event to the zero address here 
        // If we burn shares without burning/withdrawing the underlying
        // then it looks like a system wide credit to everyones balance

        // It's not possible to send events to _everyone_ to reflect each balance credit (ie: balance going up)

        // Not compliant to ERC20 standard...
    }
}

contract FarmTreasuryV1 is ReentrancyGuard, FarmTokenV1 {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    mapping(address => DepositInfo) public userDeposits;
    mapping(address => bool) public noLockWhitelist;

    struct DepositInfo {
        uint256 amountUnderlyingLocked;
        uint256 timestampDeposit;
        uint256 timestampUnlocked;
    }

    uint256 internal constant LOOP_LIMIT = 200;

    address payable public governance;
    address payable public farmBoss;

    bool public paused = false;
    bool public pausedDeposits = false;

    // fee schedule, can be changed by governance, in bips
    // performance fee is on any gains, base fee is on AUM/yearly
    uint256 public constant max = 10000;
    uint256 public performanceToTreasury = 1000;
    uint256 public performanceToFarmer = 1000;
    uint256 public baseToTreasury = 100;
    uint256 public baseToFarmer = 100;

    // limits on rebalancing from the farmer, trying to negate errant rebalances
    uint256 public rebalanceUpLimit = 100; // maximum of a 1% gain per rebalance
    uint256 public rebalanceUpWaitTime = 23 hours;
    uint256 public lastRebalanceUpTime;

    // waiting period on withdraws from time of deposit
    // locked amount linearly decreases until the time is up, so at waitPeriod/2 after deposit, you can withdraw depositAmt/2 funds.
    uint256 public waitPeriod = 1 weeks;

    // hot wallet holdings for instant withdraw, in bips
    // if the hot wallet balance expires, the users will need to wait for the next rebalance period in order to withdraw
    uint256 public hotWalletHoldings = 1000; // 10% initially

    uint256 public ACTIVELY_FARMED;

    event RebalanceHot(uint256 amountIn, uint256 amountToFarmer, uint256 timestamp);
    event ProfitDeclared(bool profit, uint256 amount, uint256 timestamp, uint256 totalAmountInPool, uint256 totalSharesInPool, uint256 performanceFeeTotal, uint256 baseFeeTotal);
    event Deposit(address depositor, uint256 amount, address referral);
    event Withdraw(address withdrawer, uint256 amount);

    constructor(string memory _nameUnderlying, uint8 _decimalsUnderlying, address _underlying) public FarmTokenV1(_nameUnderlying, _decimalsUnderlying, _underlying) {
        governance = msg.sender;
        lastRebalanceUpTime = block.timestamp;
    }

    function setGovernance(address payable _new) external {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        governance = _new;
    }

    // the "farmBoss" is a trusted smart contract that functions kind of like an EOA.
    // HOWEVER specific contract addresses need to be whitelisted in order for this contract to be allowed to interact w/ them
    // the governance has full control over the farmBoss, and other addresses can have partial control for strategy rotation/rebalancing
    function setFarmBoss(address payable _new) external {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        farmBoss = _new;
    }

    function setNoLockWhitelist(address[] calldata _accounts, bool[] calldata _noLock) external {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        require(_accounts.length == _noLock.length && _accounts.length <= LOOP_LIMIT, "FARMTREASURYV1: check array lengths");

        for (uint256 i = 0; i < _accounts.length; i++){
            noLockWhitelist[_accounts[i]] = _noLock[i];
        }
    }

    function pause() external {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        paused = true;
    }

    function unpause() external {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        paused = false;
    }

    function pauseDeposits() external {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        pausedDeposits = true;
    }

    function unpauseDeposits() external {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        pausedDeposits = false;
    }

    function setFeeDistribution(uint256 _performanceToTreasury, uint256 _performanceToFarmer, uint256 _baseToTreasury, uint256 _baseToFarmer) external {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        require(_performanceToTreasury.add(_performanceToFarmer) < max, "FARMTREASURYV1: too high performance");
        require(_baseToTreasury.add(_baseToFarmer) <= 500, "FARMTREASURYV1: too high base");
        
        performanceToTreasury = _performanceToTreasury;
        performanceToFarmer = _performanceToFarmer;
        baseToTreasury = _baseToTreasury;
        baseToFarmer = _baseToFarmer;
    }

    function setWaitPeriod(uint256 _new) external {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        require(_new <= 10 weeks, "FARMTREASURYV1: too long wait");

        waitPeriod = _new;
    }

    function setHotWalletHoldings(uint256 _new) external {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        require(_new <= max && _new >= 100, "FARMTREASURYV1: hot wallet values bad");

        hotWalletHoldings = _new;
    }

    function setRebalanceUpLimit(uint256 _new) external {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        require(_new < max, "FARMTREASURYV1: >= max");

        rebalanceUpLimit = _new;
    }

    function setRebalanceUpWaitTime(uint256 _new) external {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        require(_new <= 1 weeks, "FARMTREASURYV1: > 1 week");

        rebalanceUpWaitTime = _new;
    }

    function deposit(uint256 _amountUnderlying, address _referral) external nonReentrant {
        require(_amountUnderlying > 0, "FARMTREASURYV1: amount == 0");
        require(!paused && !pausedDeposits, "FARMTREASURYV1: paused");

        _deposit(_amountUnderlying, _referral);

        IERC20 _underlying = IERC20(underlyingContract);
        uint256 _before = _underlying.balanceOf(address(this));
        _underlying.safeTransferFrom(msg.sender, address(this), _amountUnderlying);
        uint256 _after = _underlying.balanceOf(address(this));
        uint256 _total = _after.sub(_before);
        require(_total >= _amountUnderlying, "FARMTREASURYV1: bad transfer");
    }

    function _deposit(uint256 _amountUnderlying, address _referral) internal {
        // determine how many shares this will be
        uint256 _sharesToMint = getSharesForUnderlying(_amountUnderlying);

        _mintShares(msg.sender, _sharesToMint);
        // store some important info for this deposit, that will be checked on withdraw/transfer of tokens
        _storeDepositInfo(msg.sender, _amountUnderlying);

        // emit deposit w/ referral event... can't refer yourself
        if (_referral != msg.sender){
            emit Deposit(msg.sender, _amountUnderlying, _referral);
        }
        else {
            emit Deposit(msg.sender, _amountUnderlying, address(0));
        }

        emit Transfer(address(0), msg.sender, _amountUnderlying);
    }

    function _storeDepositInfo(address _account, uint256 _amountUnderlying) internal {

        DepositInfo memory _existingInfo = userDeposits[_account];

        // first deposit, make a new entry in the mapping, lock all funds for "waitPeriod"
        if (_existingInfo.timestampDeposit == 0){
            DepositInfo memory _info = DepositInfo(
                {
                    amountUnderlyingLocked: _amountUnderlying, 
                    timestampDeposit: block.timestamp, 
                    timestampUnlocked: block.timestamp.add(waitPeriod)
                }
            );
            userDeposits[_account] = _info;
        }
        // not the first deposit, if there are still funds locked, then average out the waits (ie: 1 BTC locked 10 days = 2 BTC locked 5 days)
        else {
            uint256 _lockedAmt = _getLockedAmount(_account, _existingInfo.amountUnderlyingLocked, _existingInfo.timestampDeposit, _existingInfo.timestampUnlocked);
            // if there's no lock, disregard old info and make a new lock

            if (_lockedAmt == 0){
                DepositInfo memory _info = DepositInfo(
                    {
                        amountUnderlyingLocked: _amountUnderlying, 
                        timestampDeposit: block.timestamp, 
                        timestampUnlocked: block.timestamp.add(waitPeriod)
                    }
                );
                userDeposits[_account] = _info;
            }
            // funds are still locked from a past deposit, average out the waittime remaining with the waittime for this new deposit
            /*
                solve this equation:

                newDepositAmt * waitPeriod + remainingAmt * existingWaitPeriod = (newDepositAmt + remainingAmt) * X waitPeriod

                therefore:

                                (newDepositAmt * waitPeriod + remainingAmt * existingWaitPeriod)
                X waitPeriod =  ----------------------------------------------------------------
                                                (newDepositAmt + remainingAmt)

                Example: 7 BTC new deposit, with wait period of 2 weeks
                         1 BTC remaining, with remaining wait period of 1 week
                         ...
                         (7 BTC * 2 weeks + 1 BTC * 1 week) / 8 BTC = 1.875 weeks
            */
            else {
                uint256 _lockedAmtTime = _lockedAmt.mul(_existingInfo.timestampUnlocked.sub(block.timestamp));
                uint256 _newAmtTime = _amountUnderlying.mul(waitPeriod);
                uint256 _total = _amountUnderlying.add(_lockedAmt);

                uint256 _newLockedTime = (_lockedAmtTime.add(_newAmtTime)).div(_total);

                DepositInfo memory _info = DepositInfo(
                    {
                        amountUnderlyingLocked: _total, 
                        timestampDeposit: block.timestamp, 
                        timestampUnlocked: block.timestamp.add(_newLockedTime)
                    }
                );
                userDeposits[_account] = _info;
            }
        }
    }

    function getLockedAmount(address _account) public view returns (uint256) {
        DepositInfo memory _existingInfo = userDeposits[_account];
        return _getLockedAmount(_account, _existingInfo.amountUnderlyingLocked, _existingInfo.timestampDeposit, _existingInfo.timestampUnlocked);
    }

    // the locked amount linearly decreases until the timestampUnlocked time, then it's zero
    // Example: if 5 BTC contributed (2 week lock), then after 1 week there will be 2.5 BTC locked, the rest is free to transfer/withdraw
    function _getLockedAmount(address _account, uint256 _amountLocked, uint256 _timestampDeposit, uint256 _timestampUnlocked) internal view returns (uint256) {
        if (_timestampUnlocked <= block.timestamp || noLockWhitelist[_account]){
            return 0;
        }
        else {
            uint256 _remainingTime = _timestampUnlocked.sub(block.timestamp);
            uint256 _totalTime = _timestampUnlocked.sub(_timestampDeposit);

            return _amountLocked.mul(_remainingTime).div(_totalTime);
        }
    }

    function withdraw(uint256 _amountUnderlying) external nonReentrant {
        require(_amountUnderlying > 0, "FARMTREASURYV1: amount == 0");
        require(!paused, "FARMTREASURYV1: paused");

        _withdraw(_amountUnderlying);

        IERC20(underlyingContract).safeTransfer(msg.sender, _amountUnderlying);
    }

    function _withdraw(uint256 _amountUnderlying) internal {
        _verify(msg.sender, _amountUnderlying);
        // try and catch the more obvious error of hot wallet being depleted, otherwise proceed
        if (IERC20(underlyingContract).balanceOf(address(this)) < _amountUnderlying){
            revert("FARMTREASURYV1: Hot wallet balance depleted. Please try smaller withdraw or wait for rebalancing.");
        }

        uint256 _sharesToBurn = getSharesForUnderlying(_amountUnderlying);
        _burnShares(msg.sender, _sharesToBurn); // they must have >= _sharesToBurn, checked here

        emit Transfer(msg.sender, address(0), _amountUnderlying);
        emit Withdraw(msg.sender, _amountUnderlying);
    }

    // wait time verification
    function _verify(address _account, uint256 _amountUnderlyingToSend) internal override {
        DepositInfo memory _existingInfo = userDeposits[_account];

        uint256 _lockedAmt = _getLockedAmount(_account, _existingInfo.amountUnderlyingLocked, _existingInfo.timestampDeposit, _existingInfo.timestampUnlocked);
        uint256 _balance = balanceOf(_account);

        // require that any funds locked are not leaving the account in question.
        require(_balance.sub(_amountUnderlyingToSend) >= _lockedAmt, "FARMTREASURYV1: requested funds are temporarily locked");
    }

    // this means that we made a GAIN, due to standard farming gains
    // operaratable by farmBoss, this is standard operating procedure, farmers can only report gains
    function rebalanceUp(uint256 _amount, address _farmerRewards) external nonReentrant returns (bool, uint256) {
        require(msg.sender == farmBoss, "FARMTREASURYV1: !farmBoss");
        require(!paused, "FARMTREASURYV1: paused");

        // fee logic & profit recording
        // check farmer limits on rebalance wait time for earning reportings. if there is no _amount reported, we don't take any fees and skip these checks
        // we should always allow pure hot wallet rebalances, however earnings needs some checks and restrictions
        if (_amount > 0){
            require(block.timestamp.sub(lastRebalanceUpTime) >= rebalanceUpWaitTime, "FARMTREASURYV1: <rebalanceUpWaitTime");
            require(ACTIVELY_FARMED.mul(rebalanceUpLimit).div(max) >= _amount, "FARMTREASURYV1 _amount > rebalanceUpLimit");
            // farmer incurred a gain of _amount, add this to the amount being farmed
            ACTIVELY_FARMED = ACTIVELY_FARMED.add(_amount);
            uint256 _totalPerformance = _performanceFee(_amount, _farmerRewards);
            uint256 _totalAnnual = _annualFee(_farmerRewards);

            // for farmer controls, and also for the annual fee time
            // only update this if there is a reported gain, otherwise this is just a hot wallet rebalance, and we should always allow these
            lastRebalanceUpTime = block.timestamp; 

            // for off-chain APY calculations, fees assessed
            emit ProfitDeclared(true, _amount, block.timestamp, _getTotalUnderlying(), totalShares, _totalPerformance, _totalAnnual);
        }
        else {
            // for off-chain APY calculations, no fees assessed
            emit ProfitDeclared(true, _amount, block.timestamp, _getTotalUnderlying(), totalShares, 0, 0);
        }
        // end fee logic & profit recording

        // funds are in the contract and gains are accounted for, now determine if we need to further rebalance the hot wallet up, or can take funds in order to farm
        // start hot wallet and farmBoss rebalance logic
        (bool _fundsNeeded, uint256 _amountChange) = _calcHotWallet();
        _rebalanceHot(_fundsNeeded, _amountChange); // if the hot wallet rebalance fails, revert() the entire function
        // end logic

        return (_fundsNeeded, _amountChange); // in case we need them, FE simulations and such
    }

    // this means that the system took a loss, and it needs to be reflected in the next rebalance
    // only operatable by governance, (large) losses should be extremely rare by good farming practices
    // this would look like a farmed smart contract getting exploited/hacked, and us not having the necessary insurance for it
    // possible that some more aggressive IL strategies could also need this function called
    function rebalanceDown(uint256 _amount, bool _rebalanceHotWallet) external nonReentrant returns (bool, uint256) {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");
        // require(!paused, "FARMTREASURYV1: paused"); <-- governance can only call this anyways, leave this commented out

        ACTIVELY_FARMED = ACTIVELY_FARMED.sub(_amount);

        if (_rebalanceHotWallet){
            (bool _fundsNeeded, uint256 _amountChange) = _calcHotWallet();
            _rebalanceHot(_fundsNeeded, _amountChange); // if the hot wallet rebalance fails, revert() the entire function

            return (_fundsNeeded, _amountChange); // in case we need them, FE simulations and such
        }

        // for off-chain APY calculations, no fees assessed
        emit ProfitDeclared(false, _amount, block.timestamp, _getTotalUnderlying(), totalShares, 0, 0);

        return (false, 0);
    }

    function _performanceFee(uint256 _amount, address _farmerRewards) internal returns (uint256){

        uint256 _existingShares = totalShares;
        uint256 _balance = _getTotalUnderlying();

        uint256 _performanceToFarmerUnderlying = _amount.mul(performanceToFarmer).div(max);
        uint256 _performanceToTreasuryUnderlying = _amount.mul(performanceToTreasury).div(max);
        uint256 _performanceTotalUnderlying = _performanceToFarmerUnderlying.add(_performanceToTreasuryUnderlying);

        if (_performanceTotalUnderlying == 0){
            return 0;
        }

        uint256 _sharesToMint = _underlyingFeeToShares(_performanceTotalUnderlying, _balance, _existingShares);

        uint256 _sharesToFarmer = _sharesToMint.mul(_performanceToFarmerUnderlying).div(_performanceTotalUnderlying); // by the same ratio
        uint256 _sharesToTreasury = _sharesToMint.sub(_sharesToFarmer);

        _mintShares(_farmerRewards, _sharesToFarmer);
        _mintShares(governance, _sharesToTreasury);

        uint256 _underlyingFarmer = getUnderlyingForShares(_sharesToFarmer);
        uint256 _underlyingTreasury = getUnderlyingForShares(_sharesToTreasury);

        // do two mint events, in underlying, not shares
        emit Transfer(address(0), _farmerRewards, _underlyingFarmer);
        emit Transfer(address(0), governance, _underlyingTreasury);

        return _underlyingFarmer.add(_underlyingTreasury);
    }

    // we are taking baseToTreasury + baseToFarmer each year, every time this is called, look when we took fee last, and linearize the fee to now();
    function _annualFee(address _farmerRewards) internal returns (uint256) {
        uint256 _lastAnnualFeeTime = lastRebalanceUpTime;
        if (_lastAnnualFeeTime >= block.timestamp){
            return 0;
        }

        uint256 _elapsedTime = block.timestamp.sub(_lastAnnualFeeTime);
        uint256 _existingShares = totalShares;
        uint256 _balance = _getTotalUnderlying();

        uint256 _annualPossibleUnderlying = _balance.mul(_elapsedTime).div(365 days);
        uint256 _annualToFarmerUnderlying = _annualPossibleUnderlying.mul(baseToFarmer).div(max);
        uint256 _annualToTreasuryUnderlying = _annualPossibleUnderlying.mul(baseToFarmer).div(max);
        uint256 _annualTotalUnderlying = _annualToFarmerUnderlying.add(_annualToTreasuryUnderlying);

        if (_annualTotalUnderlying == 0){
            return 0;
        }

        uint256 _sharesToMint = _underlyingFeeToShares(_annualTotalUnderlying, _balance, _existingShares);

        uint256 _sharesToFarmer = _sharesToMint.mul(_annualToFarmerUnderlying).div(_annualTotalUnderlying); // by the same ratio
        uint256 _sharesToTreasury = _sharesToMint.sub(_sharesToFarmer);

        _mintShares(_farmerRewards, _sharesToFarmer);
        _mintShares(governance, _sharesToTreasury);

        uint256 _underlyingFarmer = getUnderlyingForShares(_sharesToFarmer);
        uint256 _underlyingTreasury = getUnderlyingForShares(_sharesToTreasury);

        // do two mint events, in underlying, not shares
        emit Transfer(address(0), _farmerRewards, _underlyingFarmer);
        emit Transfer(address(0), governance, _underlyingTreasury);

        return _underlyingFarmer.add(_underlyingTreasury);
    }

    function _underlyingFeeToShares(uint256 _totalFeeUnderlying, uint256 _balance, uint256 _existingShares) pure internal returns (uint256 _sharesToMint){
        // to mint the required amount of fee shares, solve:
        /* 
            ratio:

                    currentShares             newShares     
            -------------------------- : --------------------, where newShares = (currentShares + mintShares)
            (totalUnderlying - feeAmt)      totalUnderlying

            solved:
            ---> (currentShares / (totalUnderlying - feeAmt) * totalUnderlying) - currentShares = mintShares, where newBalanceLessFee = (totalUnderlying - feeAmt)
        */
        return _existingShares
                .mul(_balance)
                .div(_balance.sub(_totalFeeUnderlying))
                .sub(_existingShares);
    }

    function _calcHotWallet() internal view returns (bool _fundsNeeded, uint256 _amountChange) {
        uint256 _balanceHere = IERC20(underlyingContract).balanceOf(address(this));
        uint256 _balanceFarmed = ACTIVELY_FARMED;

        uint256 _totalAmount = _balanceHere.add(_balanceFarmed);
        uint256 _hotAmount = _totalAmount.mul(hotWalletHoldings).div(max);

        // we have too much in hot wallet, send to farmBoss
        if (_balanceHere >= _hotAmount){
            return (false, _balanceHere.sub(_hotAmount));
        }
        // we have too little in hot wallet, pull from farmBoss
        if (_balanceHere < _hotAmount){
            return (true, _hotAmount.sub(_balanceHere));
        }
    }

    // usually paired with _calcHotWallet()
    function _rebalanceHot(bool _fundsNeeded, uint256 _amountChange) internal {
        if (_fundsNeeded){
            uint256 _before = IERC20(underlyingContract).balanceOf(address(this));
            IERC20(underlyingContract).safeTransferFrom(farmBoss, address(this), _amountChange);
            uint256 _after = IERC20(underlyingContract).balanceOf(address(this));
            uint256 _total = _after.sub(_before);

            require(_total >= _amountChange, "FARMTREASURYV1: bad rebalance, hot wallet needs funds!");

            // we took funds from the farmBoss to refill the hot wallet, reflect this in ACTIVELY_FARMED
            ACTIVELY_FARMED = ACTIVELY_FARMED.sub(_amountChange);

            emit RebalanceHot(_amountChange, 0, block.timestamp);
        }
        else {
            require(farmBoss != address(0), "FARMTREASURYV1: !FarmBoss"); // don't burn funds

            IERC20(underlyingContract).safeTransfer(farmBoss, _amountChange); // _calcHotWallet() guarantees we have funds here to send

            // we sent more funds for the farmer to farm, reflect this
            ACTIVELY_FARMED = ACTIVELY_FARMED.add(_amountChange);

            emit RebalanceHot(0, _amountChange, block.timestamp);
        }
    }

    function _getTotalUnderlying() internal override view returns (uint256) {
        uint256 _balanceHere = IERC20(underlyingContract).balanceOf(address(this));
        uint256 _balanceFarmed = ACTIVELY_FARMED;

        return _balanceHere.add(_balanceFarmed);
    }

    function rescue(address _token, uint256 _amount) external nonReentrant {
        require(msg.sender == governance, "FARMTREASURYV1: !governance");

        if (_token != address(0)){
            IERC20(_token).safeTransfer(governance, _amount);
        }
        else { // if _tokenContract is 0x0, then escape ETH
            governance.transfer(_amount);
        }
    }
}