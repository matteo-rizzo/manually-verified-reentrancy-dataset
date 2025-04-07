/**
 *Submitted for verification at Etherscan.io on 2021-02-24
*/

//"SPDX-License-Identifier: UNLICENSED"

pragma solidity ^0.6.6;

















/* 
 * @dev PoolStakes contract for locking up liquidity to earn bonus rewards.
 */
contract PoolStake is Owned {
    //instantiate SafeMath library
    using SafeMath for uint;
    
    IERC20 internal weth;                       //represents weth.
    IERC20 internal token;                      //represents the project's token which should have a weth pair on uniswap
    IERC20 internal lpToken;                    //lpToken for liquidity provisioning
    
    address internal uToken;                    //utility token
    address internal wallet;                    //company wallet
    uint internal scalar = 10**36;              //unit for scaling
    uint internal cap;                          //ETH limit that can be provided
    
    Multiplier internal multiplier;                         //Interface of Multiplier contract
    UniswapV2Router internal uniswapRouter;                 //Interface of Uniswap V2 router
    IUniswapV2Factory internal iUniswapV2Factory;           //Interface of uniswap V2 factore
    
    //user struct
    struct User {
        uint start;                 //starting period
        uint release;               //release period
        uint tokenBonus;            //user token bonus
        uint wethBonus;             //user weth bonus
        uint tokenWithdrawn;        //amount of token bonus withdrawn
        uint wethWithdrawn;         //amount of weth bonus withdrawn
        uint liquidity;             //user liquidity gotten from uniswap
        bool migrated;              //if migrated to uniswap V3
    }
    
    //address to User mapping
    mapping(address => User) internal _users;
    
    uint32 internal constant _012_HOURS_IN_SECONDS = 43200;
    
    //term periods
    uint32 internal period1;
    uint32 internal period2;
    uint32 internal period3;
    uint32 internal period4;
    
    //return percentages for ETH and token                          1000 = 1% 
    uint internal period1RPWeth; 
    uint internal period2RPWeth;
    uint internal period3RPWeth;
    uint internal period4RPWeth;
    uint internal period1RPToken; 
    uint internal period2RPToken;
    uint internal period3RPToken;
    uint internal period4RPToken;
    
    //available bonuses rto be claimed
    uint internal _pendingBonusesWeth;
    uint internal _pendingBonusesToken;
    
    //migration contract for Uniswap V3
    address public migrationContract;
    
    //events
    event BonusAdded(address indexed sender, uint ethAmount, uint tokenAmount);
    event BonusRemoved(address indexed sender, uint amount);
    event CapUpdated(address indexed sender, uint amount);
    event LPWithdrawn(address indexed sender, uint amount);
    event LiquidityAdded(address indexed sender, uint liquidity, uint amountETH, uint amountToken);
    event LiquidityWithdrawn(address indexed sender, uint liquidity, uint amountETH, uint amountToken);
    event UserTokenBonusWithdrawn(address indexed sender, uint amount, uint fee);
    event UserETHBonusWithdrawn(address indexed sender, uint amount, uint fee);
    event VersionMigrated(address indexed sender, uint256 time, address to);
    event LiquidityMigrated(address indexed sender, uint amount, address to);
    
    /* 
     * @dev initiates a new PoolStake.
     * ------------------------------------------------------
     * @param _token    --> token offered for staking liquidity.
     * @param _Owner    --> address for the initial contract owner.
     */ 
    constructor(address _token, address _Owner) public Owned(_Owner) {
            
        require(_token != address(0), "can not deploy a zero address");
        token = IERC20(_token);
        weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); 
        
        iUniswapV2Factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
        address _lpToken = iUniswapV2Factory.getPair(address(token), address(weth));
        require(_lpToken != address(0), "Pair must be created on uniswap first");
        lpToken = IERC20(_lpToken);
        
        uToken = 0x9Ed8e7C9604790F7Ec589F99b94361d8AAB64E5E;
        wallet = 0xa7A4d919202DFA2f4E44FFAc422d21095bF9770a;
        multiplier = Multiplier(0xbc962d7be33d8AfB4a547936D8CE6b9a1034E9EE);
        uniswapRouter = UniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);        
    }
    
    /* 
     * @dev change the return percentage for locking up liquidity for ETH and Token (only Owner).
     * ------------------------------------------------------------------------------------
     * @param _period1RPETH - _period4RPToken --> the new return percentages.
     * ----------------------------------------------
     * returns whether successfully changed or not.
     */ 
    function changeReturnPercentages(
        uint _period1RPETH, uint _period2RPETH, uint _period3RPETH, uint _period4RPETH, 
        uint _period1RPToken, uint _period2RPToken, uint _period3RPToken, uint _period4RPToken
    ) external onlyOwner returns(bool) {
        
        period1RPWeth = _period1RPETH;
        period2RPWeth = _period2RPETH;
        period3RPWeth = _period3RPETH;
        period4RPWeth = _period4RPETH;
        
        period1RPToken = _period1RPToken;
        period2RPToken = _period2RPToken;
        period3RPToken = _period3RPToken;
        period4RPToken = _period4RPToken;
        
        return true;
    }
    
    /* 
     * @dev change the lockup periods (only Owner).
     * ------------------------------------------------------------------------------------
     * @param _firstTerm - _fourthTerm --> the new term periods.
     * ----------------------------------------------
     * returns whether successfully changed or not.
     */ 
    function changeTermPeriods(
        uint32 _firstTerm, uint32 _secondTerm, 
        uint32 _thirdTerm, uint32 _fourthTerm
    ) external onlyOwner returns(bool) {
        
        period1 = _firstTerm;
        period2 = _secondTerm;
        period3 = _thirdTerm;
        period4 = _fourthTerm;
        
        return true;
    }
    
    /* 
     * @dev change the maximum ETH that a user can enter with (only Owner).
     * ------------------------------------------------------------------------------------
     * @param _cap      --> the new cap value.
     * ----------------------------------------------
     * returns whether successfully changed or not.
     */ 
    function changeCap(uint _cap) external onlyOwner returns(bool) {
        
        cap = _cap;
        
        emit CapUpdated(msg.sender, _cap);
        return true;
    }
    
    /* 
     * @dev makes migration possible for uniswap V3 (only Owner).
     * ----------------------------------------------------------
     * @param _unistakeMigrationContract      --> the migration contract address.
     * -------------------------------------------------------------------------
     * returns whether successfully migrated or not.
     */ 
    function allowMigration(address _unistakeMigrationContract) external onlyOwner returns (bool) {
        
        require(_unistakeMigrationContract != address(0x0), "cannot migrate to a null address");
        migrationContract = _unistakeMigrationContract;
        
        emit VersionMigrated(msg.sender, now, migrationContract);
        return true;
    }
    
    /* 
     * @dev initiates migration for a user (only when migration is allowed).
     * -------------------------------------------------------------------
     * @param _unistakeMigrationContract      --> the migration contract address.
     * -------------------------------------------------------------------------
     * returns whether successfully migrated or not.
     */ 
    function startMigration(address _unistakeMigrationContract) external returns (bool) {
        
        require(_unistakeMigrationContract != address(0x0), "cannot migrate to a null address");
        require(migrationContract == _unistakeMigrationContract, "must confirm endpoint");
        require(!getUserMigration(msg.sender), "must not be migrated already");
        
        _users[msg.sender].migrated = true;
        
        uint256 liquidity = _users[msg.sender].liquidity;
        lpToken.transfer(migrationContract, liquidity);
        
        emit LiquidityMigrated(msg.sender, liquidity, migrationContract);
        return true;
    }
    
    /* 
     * @dev add more staking bonuses to the pool.
     * ----------------------------------------
     * @param              --> input value along with call to add ETH
     * @param _tokenAmount --> the amount of token to be added.
     * --------------------------------------------------------
     * returns whether successfully added or not.
     */ 
    function addBonus(uint _tokenAmount) external payable returns(bool) {
        
        if (_tokenAmount > 0)
        require(token.transferFrom(msg.sender, address(this), _tokenAmount), "must approve smart contract");
        
        BonusAdded(msg.sender, msg.value, _tokenAmount);
        return true;
    }
    
    /* 
     * @dev remove staking bonuses to the pool. (only owner)
     * must have enough asset to be removed
     * ----------------------------------------
     * @param _amountETH   --> eth amount to be removed
     * @param _amountToken --> token amount to be removed.
     * --------------------------------------------------------
     * returns whether successfully added or not.
     */ 
    function removeETHAndTokenBouses(uint _amountETH, uint _amountToken) external onlyOwner returns (bool success) {
       
        require(_amountETH > 0 || _amountToken > 0, "amount must be larger than zero");
    
        if (_amountETH > 0) {
            require(_checkForSufficientStakingBonusesForETH(_amountETH), 'cannot withdraw above current ETH bonus balance');
            msg.sender.transfer(_amountETH);
            emit BonusRemoved(msg.sender, _amountETH);
        }
        
        if (_amountToken > 0) {
            require(_checkForSufficientStakingBonusesForToken(_amountToken), 'cannot withdraw above current token bonus balance');
            require(token.transfer(msg.sender, _amountToken), "error: token transfer failed");
            emit BonusRemoved(msg.sender, _amountToken);
        }
        
        return true;
    }
    
    /* 
     * @dev add unwrapped liquidity to staking pool.
     * --------------------------------------------
     * @param             --> must input ETH value along with call
     * @param _term       --> the lockup term.
     * @param _multiplier --> whether multiplier should be used or not
     *                        1 means you want to use the multiplier. !1 means no multiplier
     * --------------------------------------------------------------
     * returns whether successfully added or not.
     */
    function addLiquidity(uint _term, uint _multiplier) external payable returns(bool) {
        
        require(!getUserMigration(msg.sender), "must not be migrated already");
        require(now >= _users[msg.sender].release, "cannot override current term");
        require(_isValidTerm(_term), "must select a valid term");
        require(msg.value > 0, "must send ETH along with transaction");
        if (cap != 0) require(msg.value <= cap, "cannot provide more than the cap");
        
        uint rate = _proportion(msg.value, address(weth), address(token));
        require(token.transferFrom(msg.sender, address(this), rate), "must approve smart contract");
        
        (uint ETH_bonus, uint token_bonus) = getUserBonusPending(msg.sender);
        require(ETH_bonus == 0 && token_bonus == 0, "must first withdraw available bonus");
        
        uint oneTenthOfRate = (rate.mul(10)).div(100);
        token.approve(address(uniswapRouter), rate);

        (uint amountToken, uint amountETH, uint liquidity) = 
        uniswapRouter.addLiquidityETH{value: msg.value}(
            address(token), 
            rate.add(oneTenthOfRate), 
            0, 
            0, 
            address(this), 
            now.add(_012_HOURS_IN_SECONDS));
        
        _users[msg.sender].start = now;
        _users[msg.sender].release = now.add(_term);
        
        uint previousLiquidity = _users[msg.sender].liquidity; 
        _users[msg.sender].liquidity = previousLiquidity.add(liquidity);  
        
        uint wethRP = _calculateReturnPercentage(weth, _term);
        uint tokenRP = _calculateReturnPercentage(token, _term);
               
        (uint provided_ETH, uint provided_token) = getUserLiquidity(msg.sender);
        
        if (_multiplier == 1) {
            
            _withMultiplier(
                _term, provided_ETH, provided_token, wethRP,  tokenRP);
            
        } else {
            
            _withoutMultiplier(provided_ETH, provided_token, wethRP, tokenRP);
        }
        
        emit LiquidityAdded(msg.sender, liquidity, amountETH, amountToken);
        return true;
    }
    
    /* 
     * @dev uses the Multiplier contract for double rewarding
     * ------------------------------------------------------
     * @param _term       --> the lockup term.
     * @param amountETH   --> ETH amount provided in liquidity
     * @param amountToken --> token amount provided in liquidity
     * @param wethRP      --> return percentge for ETH based on term period
     * @param tokenRP     --> return percentge for token based on term period
     * --------------------------------------------------------------------
     */
    function _withMultiplier(
        uint _term, uint amountETH, uint amountToken, uint wethRP, uint tokenRP
    ) internal {
        
        require(multiplier.balance(msg.sender) > 0, "No Multiplier balance to use");
        if (_term > multiplier.lockupPeriod(msg.sender)) multiplier.updateLockupPeriod(msg.sender, _term);
        
        uint multipliedETH = _proportion(multiplier.balance(msg.sender), uToken, address(weth));
        uint multipliedToken = _proportion(multipliedETH, address(weth), address(token));
        uint addedBonusWeth;
        uint addedBonusToken;
        
        if (_offersBonus(weth) && _offersBonus(token)) {
                    
            if (multipliedETH > amountETH) {
                multipliedETH = (_calculateBonus((amountETH.mul(multiplier.getMultiplierCeiling())), wethRP));
                addedBonusWeth = multipliedETH;
            } else {
                addedBonusWeth = (_calculateBonus((amountETH.add(multipliedETH)), wethRP));
            }
                    
            if (multipliedToken > amountToken) {
                multipliedToken = (_calculateBonus((amountToken.mul(multiplier.getMultiplierCeiling())), tokenRP));
                addedBonusToken = multipliedToken;
            } else {
                addedBonusToken = (_calculateBonus((amountToken.add(multipliedToken)), tokenRP));
            }
                
            require(_checkForSufficientStakingBonusesForETH(addedBonusWeth)
            && _checkForSufficientStakingBonusesForToken(addedBonusToken),
            "must be sufficient staking bonuses available in pool");
                            
            _users[msg.sender].wethBonus = _users[msg.sender].wethBonus.add(addedBonusWeth);
            _users[msg.sender].tokenBonus = _users[msg.sender].tokenBonus.add(addedBonusToken);
            _pendingBonusesWeth = _pendingBonusesWeth.add(addedBonusWeth);
            _pendingBonusesToken = _pendingBonusesToken.add(addedBonusToken);
                    
        } else if (_offersBonus(weth) && !_offersBonus(token)) {
                    
            if (multipliedETH > amountETH) {
                multipliedETH = (_calculateBonus((amountETH.mul(multiplier.getMultiplierCeiling())), wethRP));
                addedBonusWeth = multipliedETH;
            } else {
                addedBonusWeth = (_calculateBonus((amountETH.add(multipliedETH)), wethRP));
            }
                    
            require(_checkForSufficientStakingBonusesForETH(addedBonusWeth), 
            "must be sufficient staking bonuses available in pool");
                    
            _users[msg.sender].wethBonus = _users[msg.sender].wethBonus.add(addedBonusWeth);
            _pendingBonusesWeth = _pendingBonusesWeth.add(addedBonusWeth);
                    
        } else if (!_offersBonus(weth) && _offersBonus(token)) {
        
            if (multipliedToken > amountToken) {
                multipliedToken = (_calculateBonus((amountToken.mul(multiplier.getMultiplierCeiling())), tokenRP));
                addedBonusToken = multipliedToken;
            } else {
                addedBonusToken = (_calculateBonus((amountToken.add(multipliedToken)), tokenRP));
            }
                    
            require(_checkForSufficientStakingBonusesForToken(addedBonusToken),
            "must be sufficient staking bonuses available in pool");
                    
            _users[msg.sender].tokenBonus = _users[msg.sender].tokenBonus.add(addedBonusToken);
            _pendingBonusesToken = _pendingBonusesToken.add(addedBonusToken);
        }
    }
    
    /* 
     * @dev distributes bonus without considering Multiplier
     * ------------------------------------------------------
     * @param amountETH   --> ETH amount provided in liquidity
     * @param amountToken --> token amount provided in liquidity
     * @param wethRP      --> return percentge for ETH based on term period
     * @param tokenRP     --> return percentge for token based on term period
     * --------------------------------------------------------------------
     */
    function _withoutMultiplier(
        uint amountETH, uint amountToken, uint wethRP, uint tokenRP
    ) internal {
            
        uint addedBonusWeth;
        uint addedBonusToken;
        
        if (_offersBonus(weth) && _offersBonus(token)) {
            
            addedBonusWeth = _calculateBonus(amountETH, wethRP);
            addedBonusToken = _calculateBonus(amountToken, tokenRP);
                
            require(_checkForSufficientStakingBonusesForETH(addedBonusWeth)
            && _checkForSufficientStakingBonusesForToken(addedBonusToken),
            "must be sufficient staking bonuses available in pool");
                        
            _users[msg.sender].wethBonus = _users[msg.sender].wethBonus.add(addedBonusWeth);
            _users[msg.sender].tokenBonus = _users[msg.sender].tokenBonus.add(addedBonusToken);
            _pendingBonusesWeth = _pendingBonusesWeth.add(addedBonusWeth);
            _pendingBonusesToken = _pendingBonusesToken.add(addedBonusToken);
                
        } else if (_offersBonus(weth) && !_offersBonus(token)) {
                
            addedBonusWeth = _calculateBonus(amountETH, wethRP);
                
            require(_checkForSufficientStakingBonusesForETH(addedBonusWeth), 
            "must be sufficient staking bonuses available in pool");
                
            _users[msg.sender].wethBonus = _users[msg.sender].wethBonus.add(addedBonusWeth);
            _pendingBonusesWeth = _pendingBonusesWeth.add(addedBonusWeth);
                
        } else if (!_offersBonus(weth) && _offersBonus(token)) {
                
            addedBonusToken = _calculateBonus(amountToken, tokenRP);
                
            require(_checkForSufficientStakingBonusesForToken(addedBonusToken),
            "must be sufficient staking bonuses available in pool");
                
            _users[msg.sender].tokenBonus = _users[msg.sender].tokenBonus.add(addedBonusToken);
            _pendingBonusesToken = _pendingBonusesToken.add(addedBonusToken);
        }
        
    }
    
    /* 
     * @dev relocks liquidity already provided
     * --------------------------------------------
     * @param _term       --> the lockup term.
     * @param _multiplier --> whether multiplier should be used or not
     *                        1 means you want to use the multiplier. !1 means no multiplier
     * --------------------------------------------------------------
     * returns whether successfully relocked or not.
     */
    function relockLiquidity(uint _term, uint _multiplier) external returns(bool) {
        
        require(!getUserMigration(msg.sender), "must not be migrated already");
        require(_users[msg.sender].liquidity > 0, "do not have any liquidity to lock");
        require(now >= _users[msg.sender].release, "cannot override current term");
        require(_isValidTerm(_term), "must select a valid term");
        
        (uint ETH_bonus, uint token_bonus) = getUserBonusPending(msg.sender);
        require (ETH_bonus == 0 && token_bonus == 0, 'must withdraw available bonuses first');
        
        (uint provided_ETH, uint provided_token) = getUserLiquidity(msg.sender);
        if (cap != 0) require(provided_ETH <= cap, "cannot provide more than the cap");
        
        uint wethRP = _calculateReturnPercentage(weth, _term);
        uint tokenRP = _calculateReturnPercentage(token, _term);
        
        _users[msg.sender].start = now;
        _users[msg.sender].release = now.add(_term);
        
        if (_multiplier == 1) _withMultiplier(_term, provided_ETH, provided_token, wethRP,  tokenRP);
        else _withoutMultiplier(provided_ETH, provided_token, wethRP, tokenRP); 
        
        return true;
    }
    
    /* 
     * @dev withdraw unwrapped liquidity by user if released.
     * -------------------------------------------------------
     * @param _lpAmount --> takes the amount of user's lp token to be withdrawn.
     * -------------------------------------------------------------------------
     * returns whether successfully withdrawn or not.
     */
    function withdrawLiquidity(uint _lpAmount) external returns(bool) {
        require(!getUserMigration(msg.sender), "must not be migrated already");
        
        uint liquidity = _users[msg.sender].liquidity;
        require(_lpAmount > 0 && _lpAmount <= liquidity, "do not have any liquidity");
        require(now >= _users[msg.sender].release, "cannot override current term");
        
        _users[msg.sender].liquidity = liquidity.sub(_lpAmount); 
        
        lpToken.approve(address(uniswapRouter), _lpAmount);                                         
        
        (uint amountToken, uint amountETH) = 
            uniswapRouter.removeLiquidityETH(
                address(token),
                _lpAmount,
                1,
                1,
                msg.sender,
                now.add(_012_HOURS_IN_SECONDS));
        
        emit LiquidityWithdrawn(msg.sender, _lpAmount, amountETH, amountToken);
        return true;
    }
    
    /* 
     * @dev withdraw LP token by user if released.
     * -------------------------------------------------------
     * returns whether successfully withdrawn or not.
     */
    function withdrawUserLP() external returns(bool) {
        
        uint liquidity = _users[msg.sender].liquidity;
        require(liquidity > 0, "do not have any liquidity");
        require(now >= _users[msg.sender].release, "cannot override current term");
        
        _users[msg.sender].liquidity = 0; 
        
        lpToken.transfer(msg.sender, liquidity);                                         
        
        emit LPWithdrawn(msg.sender, liquidity);
        return true;
    }
    
    /* 
     * @dev withdraw staking bonuses earned from locking up liquidity. 
     * --------------------------------------------------------------
     * returns whether successfully withdrawn or not.
     */  
    function withdrawUserBonus() public returns(bool) {
        
        (uint ETH_bonus, uint token_bonus) = getUserBonusAvailable(msg.sender);
        require(ETH_bonus > 0 || token_bonus > 0, "you do not have any bonus available");
        
        uint releasedToken = _calculateTokenReleasedAmount(msg.sender);
        uint releasedETH = _calculateETHReleasedAmount(msg.sender);
        
        if (releasedToken > 0 && releasedETH > 0) {
            
            _withdrawUserTokenBonus(msg.sender, releasedToken);
            _withdrawUserETHBonus(msg.sender, releasedETH);
            
        } else if (releasedETH > 0 && releasedToken == 0) 
            _withdrawUserETHBonus(msg.sender, releasedETH);
        
        else if (releasedETH == 0 && releasedToken > 0)
            _withdrawUserTokenBonus(msg.sender, releasedToken);
        
        if (_users[msg.sender].release <= now) {
            
            _users[msg.sender].wethWithdrawn = 0;
            _users[msg.sender].tokenWithdrawn = 0;
            _users[msg.sender].wethBonus = 0;
            _users[msg.sender].tokenBonus = 0;
        }
        return true;
    }
    
    /* 
     * @dev withdraw ETH bonus earned from locking up liquidity
     * --------------------------------------------------------------
     * @param _user          --> address of the user making withdrawal
     * @param releasedAmount --> released ETH to be withdrawn
     * ------------------------------------------------------------------
     * returns whether successfully withdrawn or not.
     */
    function _withdrawUserETHBonus(address payable _user, uint releasedAmount) internal returns(bool) {
     
        _users[_user].wethWithdrawn = _users[_user].wethWithdrawn.add(releasedAmount);
        _pendingBonusesWeth = _pendingBonusesWeth.sub(releasedAmount);
        
        (uint fee, uint feeInETH) = _calculateETHFee(releasedAmount);
        
        require(IERC20(uToken).transferFrom(_user, wallet, fee), "must approve fee");
        _user.transfer(releasedAmount);
    
        emit UserETHBonusWithdrawn(_user, releasedAmount, feeInETH);
        return true;
    }
    
    /* 
     * @dev withdraw token bonus earned from locking up liquidity
     * --------------------------------------------------------------
     * @param _user          --> address of the user making withdrawal
     * @param releasedAmount --> released token to be withdrawn
     * ------------------------------------------------------------------
     * returns whether successfully withdrawn or not.
     */
    function _withdrawUserTokenBonus(address _user, uint releasedAmount) internal returns(bool) {
        
        _users[_user].tokenWithdrawn = _users[_user].tokenWithdrawn.add(releasedAmount);
        _pendingBonusesToken = _pendingBonusesToken.sub(releasedAmount);
        
        (uint fee, uint feeInToken) = _calculateTokenFee(releasedAmount);
        
        require(IERC20(uToken).transferFrom(_user, wallet, fee), "must approve fee");
        token.transfer(_user, releasedAmount);
    
        emit UserTokenBonusWithdrawn(_user, releasedAmount, feeInToken);
        return true;
    }
    
    /* 
     * @dev gets an asset's amount in proportion of a pair asset
     * ---------------------------------------------------------
     * param _amount --> the amount of first asset
     * param _tokenA --> the address of the first asset
     * param _tokenB --> the address of the second asset
     * -------------------------------------------------
     * returns the propotion of the _tokenB
     */ 
    function _proportion(uint _amount, address _tokenA, address _tokenB) internal view returns(uint tokenBAmount) {
        
        (uint reserveA, uint reserveB) = UniswapV2Library.getReserves(address(iUniswapV2Factory), _tokenA, _tokenB);
        
        return UniswapV2Library.quote(_amount, reserveA, reserveB);
    }
    
    /* 
     * @dev gets the released Token value
     * --------------------------------
     * param _user --> the address of the user
     * ------------------------------------------------------
     * returns the released amount in Token
     */ 
    function _calculateTokenReleasedAmount(address _user) internal view returns(uint) {

        uint release = _users[_user].release;
        uint start = _users[_user].start;
        uint taken = _users[_user].tokenWithdrawn;
        uint tokenBonus = _users[_user].tokenBonus;
        uint releasedPct;
        
        if (now >= release) releasedPct = 100;
        else releasedPct = ((now.sub(start)).mul(100000)).div((release.sub(start)).mul(1000));
        
        uint released = (((tokenBonus).mul(releasedPct)).div(100));
        return released.sub(taken);
    }
    
    /* 
     * @dev gets the released ETH value
     * --------------------------------
     * param _user --> the address of the user
     * ------------------------------------------------------
     * returns the released amount in ETH
     */ 
    function _calculateETHReleasedAmount(address _user) internal view returns(uint) {
        
        uint release = _users[_user].release;
        uint start = _users[_user].start;
        uint taken = _users[_user].wethWithdrawn;
        uint wethBonus = _users[_user].wethBonus;
        uint releasedPct;
        
        if (now >= release) releasedPct = 100;
        else releasedPct = ((now.sub(start)).mul(10000)).div((release.sub(start)).mul(100));
        
        uint released = (((wethBonus).mul(releasedPct)).div(100));
        return released.sub(taken);
    }
    
    /* 
     * @dev get the required fee for the released token bonus in the utility token
     * -------------------------------------------------------------------------------
     * param _user --> the address of the user
     * ----------------------------------------------------------
     * returns the fee amount in the utility token and Token
     */ 
    function _calculateTokenFee(uint _amount) internal view returns(uint uTokenFee, uint tokenFee) {
        
        uint fee = (_amount.mul(10)).div(100);
        uint feeInETH = _proportion(fee, address(token), address(weth));
        uint feeInUtoken = _proportion(feeInETH, address(weth), address(uToken));  
        
        return (feeInUtoken, fee);
    
    }
    
    /* 
     * @dev get the required fee for the released ETH bonus in the utility token
     * -------------------------------------------------------------------------------
     * param _user --> the address of the user
     * ----------------------------------------------------------
     * returns the fee amount in the utility token and ETH
     */ 
    function _calculateETHFee(uint _amount) internal view returns(uint uTokenFee, uint ethFee) {
        
        uint fee = (_amount.mul(10)).div(100);
        uint feeInUtoken = _proportion(fee, address(weth), address(uToken));  
        
        return (feeInUtoken, fee);
    }
    
    /* 
     * @dev get the required fee for the released ETH bonus   
     * -------------------------------------------------------------------------------
     * param _user --> the address of the user
     * ----------------------------------------------------------
     * returns the fee amount.
     */ 
    function calculateETHBonusFee(address _user) external view returns(uint ETH_Fee) {
        
        uint wethReleased = _calculateETHReleasedAmount(_user);
        
        if (wethReleased > 0) {
            
            (uint feeForWethInUtoken,) = _calculateETHFee(wethReleased);

            return feeForWethInUtoken;
            
        } else {
            
            return 0;
        }
            
    }
    
    /* 
     * @dev get the required fee for the released token bonus   
     * -------------------------------------------------------------------------------
     * param _user --> the address of the user
     * ----------------------------------------------------------
     * returns the fee amount.
     */ 
    function calculateTokenBonusFee(address _user) external view returns(uint token_Fee) {
        
        uint tokenReleased = _calculateTokenReleasedAmount(_user);
        
        if (tokenReleased > 0) {
            
            (uint feeForTokenInUtoken,) = _calculateTokenFee(tokenReleased);
            
            return feeForTokenInUtoken;
            
        } else {
            
            return 0;
        }
    }
    
    /* 
     * @dev get the bonus based on the return percentage for a particular locking term.   
     * -------------------------------------------------------------------------------
     * param _amount           --> the amount to calculate bonus from.
     * param _returnPercentage --> the returnPercentage of the term.
     * ----------------------------------------------------------
     * returns the bonus amount.
     */ 
    function _calculateBonus(uint _amount, uint _returnPercentage) internal pure returns(uint) {
        
        return ((_amount.mul(_returnPercentage)).div(100000)) / 2;                                  //  1% = 1000
    }
    
    /* 
     * @dev get the correct return percentage based on locked term.   
     * -----------------------------------------------------------
     * @param _token --> associated asset.
     * @param _term --> the locking term.
     * ----------------------------------------------------------
     * returns the return percentage.
     */   
    function _calculateReturnPercentage(IERC20 _token, uint _term) internal view returns(uint) {
        
        if (_token == weth) {
            if (_term == period1) { 
                return period1RPWeth;
            } else if (_term == period2) { 
                return period2RPWeth;
            } else if (_term == period3) { 
                return period3RPWeth;
            } else if (_term == period4) { 
                return period4RPWeth;
            } else {
                return 0;
            }
        } else if (_token == token) {
            if (_term == period1) { 
                return period1RPToken;
            } else if (_term == period2) { 
                return period2RPToken;
            } else if (_term == period3) { 
                return period3RPToken;
            } else if (_term == period4) { 
                return period4RPToken;
            } else {
                return 0;
            }
        }
            
    }
    
    /* 
     * @dev check whether the input locking term is one of the supported terms.  
     * ----------------------------------------------------------------------
     * @param _term --> the locking term.
     * -------------------------------
     * returns whether true or not.
     */   
    function _isValidTerm(uint _term) internal view returns(bool) {
        
        if (_term == period1
            || _term == period2
            || _term == period3
            || _term == period4) 
        {
            return true;
        } else {
            return false;
        }
    }
    
    /* 
     * @dev get the amount ETH and Token liquidity provided by the user.   
     * ------------------------------------------------------------------
     * @param _user --> the address of the user.
     * ---------------------------------------
     * returns the amount of ETH and Token liquidity provided.
     */   
    function getUserLiquidity(address _user) public view returns(uint provided_ETH, uint provided_token) {
        
        uint total = lpToken.totalSupply();
        uint ratio = ((_users[_user].liquidity).mul(scalar)).div(total);
        uint tokenHeld = token.balanceOf(address(lpToken));
        uint wethHeld = weth.balanceOf(address(lpToken));
        
        return ((ratio.mul(wethHeld)).div(scalar), (ratio.mul(tokenHeld)).div(scalar));
    }
    
    /* 
     * @dev check whether the inputted user address has been migrated.  
     * ----------------------------------------------------------------------
     * @param _user --> ddress of the user
     * ---------------------------------------
     * returns whether true or not.
     */  
    function getUserMigration(address _user) public view returns (bool) {
        return _users[_user].migrated;
    }
    
    /* 
     * @dev check whether the inputted user token has currently offers bonus  
     * ----------------------------------------------------------------------
     * @param _token --> associated token
     * ---------------------------------------
     * returns whether true or not.
     */  
    function _offersBonus(IERC20 _token) internal view returns (bool) {
        
        uint wethRPTotal = period1RPWeth.add(period2RPWeth).add(period3RPWeth).add(period4RPWeth);
        uint tokenRPTotal = period1RPToken.add(period2RPToken).add(period3RPToken).add(period4RPToken);
        
        if (_token == weth) {
            if (wethRPTotal > 0) {
                return true;
            } else {
                return false;
            }
            
        } else if (_token == token) {
            if (tokenRPTotal > 0) {
                return true;
            } else {
                return false;
            }
            
        }
    }
    
    /* 
     * @dev check whether the pool has sufficient amount of bonuses available for new deposits/stakes.   
     * ----------------------------------------------------------------------------------------------
     * @param amount --> the _amount to be evaluated against.
     * ---------------------------------------------------
     * returns whether true or not.
     */ 
    function _checkForSufficientStakingBonusesForETH(uint _amount) internal view returns(bool) {
        
        if ((address(this).balance).sub(_pendingBonusesWeth) >= _amount) {
            return true;
        } else {
            return false;
        }
    }
    
    /* 
     * @dev check whether the pool has sufficient amount of bonuses available for new deposits/stakes.   
     * ----------------------------------------------------------------------------------------------
     * @param amount --> the _amount to be evaluated against.
     * ---------------------------------------------------
     * returns whether true or not.
     */ 
    function _checkForSufficientStakingBonusesForToken(uint _amount) internal view returns(bool) {
       
        if ((token.balanceOf(address(this)).sub(_pendingBonusesToken)) >= _amount) {
            
            return true;
            
        } else {
            
            return false;
        }
    }
    
    /* 
     * @dev get the timestamp of when the user balance will be released from locked term. 
     * ---------------------------------------------------------------------------------
     * @param _user --> the address of the user.
     * ---------------------------------------
     * returns the timestamp for the release.
     */     
    function getUserRelease(address _user) external view returns(uint release_time) {
        
        uint release = _users[_user].release;
        if (release > now) {
            
            return (release.sub(now));
       
        } else {
            
            return 0;
        }
        
    }
    
    /* 
     * @dev get the amount of bonuses rewarded from staking to a user.   
     * --------------------------------------------------------------
     * @param _user --> the address of the user.
     * ---------------------------------------
     * returns the amount of staking bonuses.
     */  
    function getUserBonusPending(address _user) public view returns(uint ETH_bonus, uint token_bonus) {
        
        uint takenWeth = _users[_user].wethWithdrawn;
        uint takenToken = _users[_user].tokenWithdrawn;
        
        return (_users[_user].wethBonus.sub(takenWeth), _users[_user].tokenBonus.sub(takenToken));
    }
    
    /* 
     * @dev get the amount of released bonuses rewarded from staking to a user.   
     * --------------------------------------------------------------
     * @param _user --> the address of the user.
     * ---------------------------------------
     * returns the amount of released staking bonuses.
     */  
    function getUserBonusAvailable(address _user) public view returns(uint ETH_Released, uint token_Released) {
        
        uint ETHValue = _calculateETHReleasedAmount(_user);
        uint tokenValue = _calculateTokenReleasedAmount(_user);
        
        return (ETHValue, tokenValue);
    }   
    
    /* 
     * @dev get the amount of liquidity pool tokens staked/locked by user.   
     * ------------------------------------------------------------------
     * @param _user --> the address of the user.
     * ---------------------------------------
     * returns the amount of locked liquidity.
     */   
    function getUserLPTokens(address _user) external view returns(uint user_LP) {

        return _users[_user].liquidity;
    }
    
    /* 
     * @dev get the lp token address for the pair.  
     * -----------------------------------------------------------
     * returns the lp address for eth/token pair.
     */ 
    function getLPAddress() external view returns(address) {
        return address(lpToken);
    }
    
    /* 
     * @dev get the amount of staking bonuses available in the pool.  
     * -----------------------------------------------------------
     * returns the amount of staking bounses available for ETH and Token.
     */ 
    function getAvailableBonus() external view returns(uint available_ETH, uint available_token) {
        
        available_ETH = (address(this).balance).sub(_pendingBonusesWeth);
        available_token = (token.balanceOf(address(this))).sub(_pendingBonusesToken);
        
        return (available_ETH, available_token);
    }
    
    /* 
     * @dev get the maximum amount of ETH allowed for provisioning.  
     * -----------------------------------------------------------
     * returns the amaximum ETH allowed
     */ 
    function getCap() external view returns(uint maxETH) {
        
        return cap;
    }
    
    /* 
     * @dev checks the term period and return percentages 
     * --------------------------------------------------
     * returns term period and return percentages 
     */
    function getTermPeriodAndReturnPercentages() external view returns(
        uint Term_Period_1, uint Term_Period_2, uint Term_Period_3, uint Term_Period_4,
        uint Period_1_Return_Percentage_Token, uint Period_2_Return_Percentage_Token,
        uint Period_3_Return_Percentage_Token, uint Period_4_Return_Percentage_Token,
        uint Period_1_Return_Percentage_ETH, uint Period_2_Return_Percentage_ETH,
        uint Period_3_Return_Percentage_ETH, uint Period_4_Return_Percentage_ETH
    ) {
        
        return (
            period1, period2, period3, period4, period1RPToken, period2RPToken, period3RPToken, 
            period4RPToken,period1RPWeth, period2RPWeth, period3RPWeth, period4RPWeth);
    }
    
}

contract PoolStakeFactory {
    
    //array of PoolStake contracts
    address[] private _poolStakes;
    
    //event on contract creation
    event Created(address indexed Creator, address Contract, address indexed Token);
    
    /* 
     * @dev get the length of all contracts created 
     * -----------------------------------------------------------
     * returns number of contracts created
     */ 
    function totalContracts() external view returns(uint256) {
        
        return _poolStakes.length;
    }
    
    /* 
     * @dev get an array of all contracts created 
     * -----------------------------------------------------------
     * returns all contracts created 
     */ 
    function getContracts() external view returns(address[] memory) {
        
        return _poolStakes;
    }
    
    /* 
     * @dev create a new contract prototype.
     * -------------------------------------
     * @param _token      --> the ETH-pair token address
     * -------------------------------------------------
     * returns whether successfully changed or not.
     */ 
    function createContract(address _token) external returns(bool) {
            
        PoolStake poolStake = new PoolStake(_token, msg.sender);
        _poolStakes.push(address(poolStake));
        
        emit Created(msg.sender, address(poolStake), _token);
        return true;
    }

}