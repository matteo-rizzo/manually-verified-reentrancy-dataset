/**
 *Submitted for verification at Etherscan.io on 2021-03-19
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */





abstract contract IdleYield {
    function mintIdleToken(uint256 amount, bool skipRebalance, address referral) external virtual returns(uint256);
    function redeemIdleToken(uint256 amount) external virtual returns(uint256);
    function balanceOf(address user) external virtual returns(uint256);
    function tokenPrice() external virtual view returns(uint256);
    function userAvgPrices(address user) external virtual view returns(uint256);
    function fee() external virtual view returns(uint256);
}

contract PLUGIDLEV1 is IPLUGV1, Ownable, Pausable {
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    uint256 private constant ONE_18 = 10**18;
    uint256 private constant FULL_ALLOC = 100000;
    
    address public constant override tokenWant = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC
    address public constant override tokenStrategy = address(0x5274891bEC421B39D23760c04A6755eCB444797C); // IDLEUSDC
    address public override tokenReward = address(0x20a68F9e34076b2dc15ce726d7eEbB83b694702d); // ISLA
    IdleYield strategy = IdleYield(tokenStrategy);
    IERC20 iTokenWant = IERC20(tokenWant);
    
    // addresses to send interests generated
    address public rewardOutOne;
    address public rewardOutTwo;
    // it should be used only when plug balance has to move to another plug
    address public plugHelper;
    
    // Plug parameter
    uint256 public currentLevelCap = uint256(150000).mul(ONE_18); // 150K token want
    uint256 public plugLimit = uint256(50000).mul(ONE_18); // 50K plug limit
    uint256 public plugLevel;
    mapping (address => uint256) public tokenStrategyAmounts;
    mapping (address => uint256) public tokenWantAmounts;
    mapping (address => uint256) public tokenWantDonated;
    uint256 public usersTokenWant;
    uint256 public lastRebalanceTs;
    uint256 twInStrategyLastRebalance;
    uint256 public rebalancePeriod = 3 days;
    uint256 public rewardRate = ONE_18;

    event PlugCharged(address user, uint256 amount, uint256 amountMinted);
    event PlugDischarged(address user, uint256 userAmount, uint256 rewardForUSer, uint256 rewardForPlug);
    event SentRewardToOutOne(address token, uint256 amount);
    event SentRewardToOutTwo(address token, uint256 amount);
    event Rebalance(uint256 amountEarned);

    constructor() {
        iTokenWant.approve(tokenStrategy, uint256(-1));
    }

    /**
     * Charge plug staking token want into idle.
     */
    function chargePlug(uint256 _amount) external override whenNotPaused() {
        usersTokenWant = usersTokenWant.add(_amount);
        require(usersTokenWant < plugLimit);
        iTokenWant.safeTransferFrom(msg.sender, address(this), _amount);
        require(_getPlugBalance(tokenWant) >= _amount);
        uint256 amountMinted = strategy.mintIdleToken(_amount, true, address(0));
        
        tokenStrategyAmounts[msg.sender] = tokenStrategyAmounts[msg.sender].add(amountMinted);
        tokenWantAmounts[msg.sender] = tokenWantAmounts[msg.sender].add(_amount);
        emit PlugCharged(msg.sender, _amount, amountMinted);
    }
    
    /**
     * Discharge plug withdrawing all token staked into idle
     * Choose the percentage to donate into the plug (0, 50, 100)
     * If there is any reward active it will be send respecting the actual reward rate
     */
    function dischargePlug(uint256 _plugPercentage) external override whenNotPaused() {
        _dischargePlug(_plugPercentage);
    }
    
    /**
     * Internal function to discharge plug
     */
    function _dischargePlug(uint256 _plugPercentage) internal {
        require(_plugPercentage == 0 || _plugPercentage == 50 || _plugPercentage == 100);
        uint256 userAmount = tokenWantAmounts[msg.sender];
        require(userAmount > 0);

        // transfer token want from IDLE to plug
        uint256 amountRedeemed = strategy.redeemIdleToken(tokenStrategyAmounts[msg.sender]);
        usersTokenWant = usersTokenWant.sub(userAmount); 

        // token want earned
        uint256 tokenEarned;
        uint256 rewardForUser;
        uint256 rewardForPlug;
        uint256 amountToDischarge;

        // it should be always greater, added for safe
        if (amountRedeemed <= userAmount) {
            tokenEarned = 0;
            userAmount = amountRedeemed;
        } else {
            tokenEarned = amountRedeemed.sub(userAmount);
            rewardForUser = tokenEarned; 
        }
        
        // calculate token earned percentage to donate into plug 
        if (_plugPercentage > 0 && tokenEarned > 0) {
            rewardForPlug = tokenEarned;
            rewardForUser = 0;
            if (_plugPercentage == 50) {
                rewardForPlug = rewardForPlug.div(2);
                rewardForUser = tokenEarned.sub(rewardForPlug);
            }
            uint256 rewardLeft = _getPlugBalance(tokenReward);
            if (rewardLeft > 0) {
                uint256 rewardWithRate = rewardForPlug.mul(rewardRate).div(ONE_18);
                _sendReward(rewardLeft, rewardWithRate); 
            }
            tokenWantDonated[msg.sender] = tokenWantDonated[msg.sender].add(rewardForPlug);
        }

        // transfer tokenWant userAmount to user
        amountToDischarge = userAmount.add(rewardForUser);
        _dischargeUser(amountToDischarge);
        emit PlugDischarged(msg.sender, userAmount, rewardForUser, rewardForPlug);
    }

    /**
     * Sending all token want owned by an user.
     */
    function _dischargeUser(uint256 _amount) internal {
        _sendTokenWant(_amount);
        tokenWantAmounts[msg.sender] = 0;
        tokenStrategyAmounts[msg.sender] = 0;
    }

    /**
     * Send token want to msg.sender.
     */
    function _sendTokenWant(uint256 _amount) internal {
        iTokenWant.safeTransfer(msg.sender, _amount); 
    }

    /**
     * Send token reward to users,
     */
    function _sendReward(uint256 _rewardLeft, uint256 _rewardWithRate) internal {
        if (_rewardLeft >= _rewardWithRate) {
            IERC20(tokenReward).safeTransfer(msg.sender, _rewardWithRate); 
        } else {
            IERC20(tokenReward).safeTransfer(msg.sender, _rewardLeft); 
        } 
    }
    
    /**
     * Rebalance plug every rebalance period.
     */
    function rebalancePlug() external override whenNotPaused() {
        _rebalancePlug();
    }
    
    /**
     * Internsal function for rebalance.
     */
    function _rebalancePlug() internal {
        require(lastRebalanceTs.add(rebalancePeriod) < block.timestamp);
        lastRebalanceTs = block.timestamp;
        
        uint256 twPlug = iTokenWant.balanceOf(address(this));
        
        uint256 twInStrategy;
        uint256 teInStrategy;
        uint256 teByPlug;
        
        // reinvest token want to strategy
        if (plugLevel == 0) {
            _rebalanceAtLevel0(twPlug);
        } else {
            twInStrategy = _getTokenWantInS();
            teInStrategy = twInStrategy.sub(twInStrategyLastRebalance);
            teByPlug = twPlug.add(teInStrategy);
            if (plugLevel == 1) {
                _rebalanceAtLevel1Plus(teByPlug.div(2));
            } else {
                _rebalanceAtLevel1Plus(teByPlug.div(3));
            }
        }
        twInStrategyLastRebalance = _getTokenWantInS();
    }
    
    /**
     * Rebalance plug at level 0
     * Mint all tokens want owned by plug to idle pool 
     */
    function _rebalanceAtLevel0(uint256 _amount) internal {
        uint256 mintedTokens = strategy.mintIdleToken(_amount, true, address(0));
        tokenStrategyAmounts[address(this)] = tokenStrategyAmounts[address(this)].add(mintedTokens); 
    }
    
    /**
     * Rebalance plug at level1+.
     * level1 -> 50% remain into plug and 50% send to reward1
     * level2+ -> 33.3% to plug 33.3% to reward1 and 33.3% to reward2
     */
    function _rebalanceAtLevel1Plus(uint256 _amount) internal {
        uint256 plugAmount = _getPlugBalance(tokenWant);
        uint256 amountToSend = _amount;
        
        if (plugLevel > 1) {
            amountToSend = amountToSend.mul(2);
        }
        
        if (plugAmount < amountToSend) {
            uint256 amountToRetrieveFromS = amountToSend.sub(plugAmount);
            uint256 amountToRedeem = amountToRetrieveFromS.div(_getRedeemPrice()).mul(ONE_18);
            strategy.redeemIdleToken(amountToRedeem);
            tokenStrategyAmounts[address(this)] = tokenStrategyAmounts[address(this)].sub(amountToRedeem);
        }
        
        // send to reward out 1
        _transferToOutside(tokenWant, rewardOutOne, _amount);
        
        if (plugLevel > 1) {
            _transferToOutside(tokenWant, rewardOutTwo, _amount);
        }
        
        //send all remain token want from plug to idle strategy
        uint256 balanceLeft = plugAmount.sub(amountToSend);
        if (balanceLeft > 0) {
            _rebalanceAtLevel0(balanceLeft);
        }
    }

    /**
     * Upgrade plug to the next level.
     */
    function upgradePlug(uint256 _nextLevelCap) external override onlyOwner {
        require(_nextLevelCap > currentLevelCap && plugTotalAmount() > currentLevelCap);
        require(rewardOutOne != address(0));
        if (plugLevel >= 1) {
            require(rewardOutTwo != address(0));
            require(plugHelper != address(0));
        }
        plugLevel = plugLevel + 1;
        currentLevelCap = _nextLevelCap;
    }
    
    /**
     * Redeem all token owned by plug from idle strategy.
     */
    function safePlugExitStrategy(uint256 _amount) external onlyOwner {
        strategy.redeemIdleToken(_amount);
        tokenStrategyAmounts[address(this)] = tokenStrategyAmounts[address(this)].sub(_amount);
        twInStrategyLastRebalance = _getTokenWantInS();
    }
    
    /**
     * Transfer token want to factory.
     */
    function transferToHelper() external onlyOwner {
        require(plugHelper != address(0));
        uint256 amount = iTokenWant.balanceOf(address(this));
        _transferToOutside(tokenWant, plugHelper, amount);
    }
    
    /**
     * Transfer token different than token strategy to external allowed address (ex IDLE, COMP, ecc).
     */
    function transferToRewardOut(address _token, address _rewardOut) external onlyOwner {
        require(_token != address(0) && _rewardOut != address(0));
        require(_rewardOut == rewardOutOne || _rewardOut == rewardOutTwo);
        // it prevents to tranfer idle tokens outside
        require(_token != tokenStrategy);
        uint256 amount = IERC20(_token).balanceOf(address(this));
        _transferToOutside(_token, _rewardOut, amount);
    }
    
    /**
     * Transfer any token to external address.
     */
    function _transferToOutside(address _token, address _outside, uint256 _amount) internal {
      IERC20(_token).safeTransfer(_outside, _amount);  
    }

    /**
     * Approve token to spender.
     */
    function safeTokenApprore(address _token, address _spender, uint256 _amount) external onlyOwner {
        IERC20(_token).approve(_spender, _amount);
    }
    
    /**
     * Set the current level cap.
     */
    function setCurrentLevelCap(uint256 _newCap) external onlyOwner {
        require(_newCap > plugTotalAmount());
        currentLevelCap = _newCap;
    }
    
    /**
     * Set a new token reward.
     */
    function setTokenReward(address _tokenReward) external onlyOwner {
        tokenReward = _tokenReward;
    }

    /**
     * Set the new reward rate in decimals (18).
     */
    function setRewardRate(uint256 _rate) external onlyOwner {
        rewardRate = _rate;
    }
    
    /**
     * Set the first reward pool address.
     */
    function setRewardOutOne(address _reward) external onlyOwner {
        rewardOutOne = _reward;
    }
    
    /**
     * Set the second reward pool address.
     */
    function setRewardOutTwo(address _reward) external onlyOwner {
        rewardOutTwo = _reward;
    }
    
    /**
     * Set the plug helper address.
     */
    function setPlugHelper(address _plugHelper) external onlyOwner {
        plugHelper = _plugHelper;
    }
    
    /**
     * Set the new rebalance period duration.
     */ 
    function setRebalancePeriod(uint256 _newPeriod) external onlyOwner {
        // at least 12 hours (60 * 60 * 12)
        require(_newPeriod >= 43200);
        rebalancePeriod = _newPeriod;
    }

    /**
     * Set the new plug cap for token want to store in it.
     */ 
    function setPlugUsersLimit(uint256 _newLimit) external onlyOwner {
        require(_newLimit > plugLimit);
        plugLimit = _newLimit;
    }

    /**
     * Get the current reedem price.
     * @notice function helper for retrieving the idle token price counting fees, developed by @emilianobonassi
     * https://github.com/emilianobonassi/idle-token-helper
     */
    function _getRedeemPrice() view internal returns (uint256 redeemPrice) {
        uint256 userAvgPrice = strategy.userAvgPrices(address(this));
        uint256 currentPrice = strategy.tokenPrice();

        // When no deposits userAvgPrice is 0 equiv currentPrice
        // and in the case of issues
        if (userAvgPrice == 0 || currentPrice < userAvgPrice) {
            redeemPrice = currentPrice;
        } else {
            uint256 fee = strategy.fee();

            redeemPrice = ((currentPrice.mul(FULL_ALLOC))
                .sub(
                    fee.mul(
                         currentPrice.sub(userAvgPrice)
                    )
                )).div(FULL_ALLOC);
        }

        return redeemPrice;
    }

    /**
     * Get the plug balance of a token.
     */
    function _getPlugBalance(address _token) internal view returns(uint256) {
        return IERC20(_token).balanceOf(address(this));
    }

    /**
     * Get the plug balance of token want into idle strategy.
     */
    function _getTokenWantInS() internal view returns (uint256) {
        uint256 tokenPrice = _getRedeemPrice();
        return tokenStrategyAmounts[address(this)].mul(tokenPrice).div(ONE_18);
    }

    /**
     * Get the plug total amount between the ineer and the amount store into idle.
     */
    function plugTotalAmount() public view returns(uint256) {
        uint256 tokenWantInStrategy = _getTokenWantInS();
        return iTokenWant.balanceOf(address(this)).add(tokenWantInStrategy);
    }
}