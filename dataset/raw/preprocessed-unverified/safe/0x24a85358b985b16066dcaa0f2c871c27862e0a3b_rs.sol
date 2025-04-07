/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

// Dependency file: contracts/libraries/SafeMath.sol

// SPDX-License-Identifier: MIT

// pragma solidity >=0.6.0;

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


// Dependency file: contracts/modules/ConfigNames.sol

// pragma solidity >=0.5.16;



// Root file: contracts/AAAAQuery.sol

pragma solidity >=0.6.6;
pragma experimental ABIEncoderV2;

// import "contracts/libraries/SafeMath.sol";
// import 'contracts/modules/ConfigNames.sol';

















contract AAAAQuery {
    address public owner;
    address public config;
    using SafeMath for uint;

    struct PoolInfoStruct {
        address pair;
        uint totalBorrow;
        uint totalPledge;
        uint totalPledgeValue;
        uint remainSupply;
        uint totalSupplyValue;
        uint borrowInterests;
        uint supplyInterests;
        address supplyToken;
        address collateralToken;
        uint8 supplyTokenDecimals;
        uint8 collateralTokenDecimals;
        string lpToken0Symbol;
        string lpToken1Symbol;
        string supplyTokenSymbol;
        string collateralTokenSymbol;
    }

    struct TokenStruct {
        string name;
        string symbol;
        uint8 decimals;
        uint balance;
        uint totalSupply;
        uint allowance;
    }

    struct MintTokenStruct {
        uint mintCumulation;
        uint maxSupply;
        uint takeBorrow;
        uint takeLend;
    }

     struct SupplyInfo {
        uint amountSupply;
        uint interestSettled;
        uint liquidationSettled;

        uint interests;
        uint liquidation;
    }

    struct BorrowInfo {
        address user;
        uint amountCollateral;
        uint interestSettled;
        uint amountBorrow;
        uint interests;
    }

    struct LiquidationStruct {
        address pool;
        address user;
        uint amountCollateral;
        uint expectedRepay;
        uint liquidationRate;
    }

    struct PoolConfigInfo {
        uint baseInterests;
        uint marketFrenzy;
        uint pledgeRate;
        uint pledgePrice;
        uint liquidationRate;   
    }

    struct UserLiquidationStruct {
        uint amountCollateral;
        uint liquidationAmount;
        uint timestamp;
    }

    struct BallotStruct {
        address ballot;
        bytes32 name;
        address pool; // pool address or address(0)
        address creator;
        uint currentValue;
        uint    value;
        uint    createdBlock;
        uint    createdTime;
        uint    total;
        uint    reward;
        uint YES;
        uint NO;
        uint weight;
        bool voted;
        uint voteIndex;
        bool claimed;
        uint myReward;
        bool end;
        bool pass;
        bool expire;
        string  subject;
        string  content;
    }

    constructor() public {
        owner = msg.sender;
    }
    
    function setupConfig (address _config) external {
        require(msg.sender == owner, "FORBIDDEN");
        config = _config;
    }
        
    function getPoolInterests(address pair) public view returns (uint, uint) {
        uint borrowInterests = IAAAAPool(pair).getInterests();
        uint supplyInterests = 0;
        uint borrow = IAAAAPool(pair).totalBorrow();
        uint total = borrow + IAAAAPool(pair).remainSupply();
        if(total > 0) {
            supplyInterests = borrowInterests * borrow / total;
        }
        return (supplyInterests, borrowInterests);
    }

    function getPoolInfoByIndex(uint index) public view returns (PoolInfoStruct memory info) {
        uint count = IAAAAFactory(IConfig(config).factory()).countPools();
        if (index >= count || count == 0) {
            return info;
        }
        address pair = IAAAAFactory(IConfig(config).factory()).allPools(index);
        return getPoolInfo(pair);
    }

    function getPoolInfoByTokens(address lend, address collateral) public view returns (PoolInfoStruct memory info) {
        address pair = IAAAAFactory(IConfig(config).factory()).getPool(lend, collateral);
        return getPoolInfo(pair);
    }
    
    function getPoolInfo(address pair) public view returns (PoolInfoStruct memory info) {
        if(!IAAAAFactory(IConfig(config).factory()).isPool(pair)) {
            return info;
        }
        info.pair = pair;
        info.totalBorrow = IAAAAPool(pair).totalBorrow();
        info.totalPledge = IAAAAPool(pair).totalPledge();
        info.remainSupply = IAAAAPool(pair).remainSupply();
        info.borrowInterests = IAAAAPool(pair).getInterests();
        info.supplyToken = IAAAAPool(pair).supplyToken();
        info.collateralToken = IAAAAPool(pair).collateralToken();
        info.supplyTokenDecimals = IERC20(info.supplyToken).decimals();
        info.collateralTokenDecimals = IERC20(info.collateralToken).decimals();
        info.supplyTokenSymbol = IERC20(info.supplyToken).symbol();
        info.collateralTokenSymbol = IERC20(info.collateralToken).symbol();
        address lpToken0 = ISwapPair(info.collateralToken).token0();
        address lpToken1 = ISwapPair(info.collateralToken).token1();
        info.lpToken0Symbol = IERC20(lpToken0).symbol();
        info.lpToken1Symbol = IERC20(lpToken1).symbol();

        info.totalSupplyValue = IConfig(config).convertTokenAmount(info.supplyToken, IConfig(config).base(), info.remainSupply.add(info.totalBorrow));
        info.totalPledgeValue = IConfig(config).convertTokenAmount(info.collateralToken, IConfig(config).base(), info.totalPledge);

        if(info.totalBorrow + info.remainSupply > 0) {
            info.supplyInterests = info.borrowInterests * info.totalBorrow / (info.totalBorrow + info.remainSupply);
        }
    }

    function queryPoolList() public view returns (PoolInfoStruct[] memory list) {
        uint count = IAAAAFactory(IConfig(config).factory()).countPools();
        if(count > 0) {
            list = new PoolInfoStruct[](count);
            for(uint i = 0;i < count;i++) {
                list[i] = getPoolInfoByIndex(i);
            }
        }
    }

    function queryPoolListByToken(address token) public view returns (PoolInfoStruct[] memory list) {
        uint count = IAAAAFactory(IConfig(config).factory()).countPools();
        uint outCount = 0;
        if(count > 0) {
            for(uint i = 0;i < count;i++) {
                PoolInfoStruct memory info = getPoolInfoByIndex(i);
                if(info.supplyToken == token) {
                    outCount++;
                }
            }
            if(outCount == 0) return list;
            list = new PoolInfoStruct[](outCount);
            uint index = 0;
            for(uint i = 0;i < count;i++) {
                PoolInfoStruct memory info = getPoolInfoByIndex(i);
                if(info.supplyToken == token) {
                    list[index] = info;
                    index++;
                }
            }
        }
        return list;
    }

    function queryToken(address user, address spender, address token) public view returns (TokenStruct memory info) {
        info.name = IERC20(token).name();
        info.symbol = IERC20(token).symbol();
        info.decimals = IERC20(token).decimals();
        info.balance = IERC20(token).balanceOf(user);
        info.totalSupply = IERC20(token).totalSupply();
        if(spender != user) {
            info.allowance = IERC20(token).allowance(user, spender);
        }
    }

    function queryTokenList(address user, address spender, address[] memory tokens) public view returns (TokenStruct[] memory token_list) {
        uint count = tokens.length;
        if(count > 0) {
            token_list = new TokenStruct[](count);
            for(uint i = 0;i < count;i++) {
                token_list[i] = queryToken(user, spender, tokens[i]);
            }
        }
    }

    function queryMintToken(address user) public view returns (MintTokenStruct memory info) {
        address token = IConfig(config).mint();
        info.mintCumulation = IAAAAMint(token).mintCumulation();
        info.maxSupply = IAAAAMint(token).maxSupply();
        info.takeBorrow = IAAAAMint(token).takeBorrowWithAddress(user);
        info.takeLend = IAAAAMint(token).takeLendWithAddress(user);
    }

    function getBorrowInfo(address _pair, address _user) public view returns (BorrowInfo memory info){
        (, uint amountCollateral, uint interestSettled, uint amountBorrow, uint interests) = IAAAAPool(_pair).borrows(_user);
        info = BorrowInfo(_user, amountCollateral, interestSettled, amountBorrow, interests);
    }

    function iterateBorrowInfo(address _pair, uint _start, uint _end) public view returns (BorrowInfo[] memory list){
        require(_start <= _end && _start >= 0 && _end >= 0, "INVAID_PARAMTERS");
        uint count = IAAAAPool(_pair).numberBorrowers();
        if (_end > count) _end = count;
        count = _end - _start;
        list = new BorrowInfo[](count);
        uint index = 0;
        for(uint i = _start; i < _end; i++) {
            address user = IAAAAPool(_pair).borrowerList(i);
            list[index] = getBorrowInfo(_pair, user);
            index++;
        }
    }

    function iteratePairLiquidationInfo(address _pair, uint _start, uint _end) public view returns (
        LiquidationStruct[] memory list)
    {
        require(_start <= _end && _start >= 0 && _end >= 0, "INVAID_PARAMTERS");
        address supplyToken = IAAAAPool(_pair).supplyToken();
        address collateralToken = IAAAAPool(_pair).collateralToken();

        uint count = IAAAAPool(_pair).numberBorrowers();
        if (_end > count) _end = count;
        count = _end - _start;
        uint index = 0;
        uint liquidationRate = IConfig(config).getPoolValue(_pair, ConfigNames.POOL_LIQUIDATION_RATE);
        uint pledgeRate = IConfig(config).getPoolValue(_pair, ConfigNames.POOL_PLEDGE_RATE);
        
        for(uint i = _start; i < _end; i++) {
            address user = IAAAAPool(_pair).borrowerList(i);
            (, uint amountCollateral, , , ) = IAAAAPool(_pair).borrows(user);
            uint pledgeAmount = IConfig(config).convertTokenAmount(collateralToken, supplyToken, amountCollateral);
            uint repayAmount = IAAAAPlatform(IConfig(config).platform()).getRepayAmount(supplyToken, collateralToken, amountCollateral, user);
            if(repayAmount > pledgeAmount.mul(pledgeRate).div(1e18).mul(liquidationRate).div(1e18))
            {
                index++;
            }
        }
        list = new LiquidationStruct[](index);
        index = 0;
        for(uint i = _start; i < _end; i++) {
            address user = IAAAAPool(_pair).borrowerList(i);
            (, uint amountCollateral, , , ) = IAAAAPool(_pair).borrows(user);
            uint pledgeAmount = IConfig(config).convertTokenAmount(collateralToken, supplyToken, amountCollateral);
            uint repayAmount = IAAAAPlatform(IConfig(config).platform()).getRepayAmount(supplyToken, collateralToken, amountCollateral, user);
            if(repayAmount > pledgeAmount.mul(pledgeRate).div(1e18).mul(liquidationRate).div(1e18))
            {
                list[index].user             = user;
                list[index].pool             = _pair;
                list[index].amountCollateral = amountCollateral;
                list[index].expectedRepay    = repayAmount;
                list[index].liquidationRate  = liquidationRate;
                index++;
            }
        }
    }

    function getPoolConf(address _pair) public view returns (PoolConfigInfo memory info) {
        info.baseInterests = IConfig(config).getPoolValue(_pair, ConfigNames.POOL_BASE_INTERESTS);
        info.marketFrenzy = IConfig(config).getPoolValue(_pair, ConfigNames.POOL_MARKET_FRENZY);
        info.pledgeRate = IConfig(config).getPoolValue(_pair, ConfigNames.POOL_PLEDGE_RATE);
        info.pledgePrice = IConfig(config).getPoolValue(_pair, ConfigNames.POOL_PRICE);
        info.liquidationRate = IConfig(config).getPoolValue(_pair, ConfigNames.POOL_LIQUIDATION_RATE);
    }

    function queryUserLiquidationList(address _pair, address _user) public view returns (UserLiquidationStruct[] memory list) {
        uint count = IAAAAPool(_pair).liquidationHistoryLength(_user);
        if(count > 0) {
            list = new UserLiquidationStruct[](count);
            for(uint i = 0;i < count; i++) {
                (uint amountCollateral, uint liquidationAmount, uint timestamp) = IAAAAPool(_pair).liquidationHistory(_user, i);
                list[i] = UserLiquidationStruct(amountCollateral, liquidationAmount, timestamp);
            }
        }
    }

    function getSwapPairReserve(address _pair) public view returns (address token0, address token1, uint8 decimals0, uint8 decimals1, uint reserve0, uint reserve1) {
        token0 = ISwapPair(_pair).token0();
        token1 = ISwapPair(_pair).token1();
        decimals0 = IERC20(token0).decimals();
        decimals1 = IERC20(token1).decimals();
        (reserve0, reserve1, ) = ISwapPair(_pair).getReserves();
    }

    function getCanMaxBorrowAmount(address _pair, address _user, uint _blocks) public view returns(uint) {
        (, uint amountCollateral, uint interestSettled, uint amountBorrow, uint interests) = IAAAAPool(_pair).borrows(_user);
        uint maxBorrow = IAAAAPlatform(IConfig(config).platform()).getMaximumBorrowAmount(IAAAAPool(_pair).supplyToken(), IAAAAPool(_pair).collateralToken(), amountCollateral);
        uint poolBalance = IERC20(IAAAAPool(_pair).supplyToken()).balanceOf(_pair);

        uint _interestPerBorrow = IAAAAPool(_pair).interestPerBorrow().add(IAAAAPool(_pair).getInterests().mul(block.number+_blocks - IAAAAPool(_pair).lastInterestUpdate()));
        uint _totalInterest = interests.add(_interestPerBorrow.mul(amountBorrow).div(1e18).sub(interestSettled));

        uint repayInterest = amountCollateral == 0 ? 0 : _totalInterest.mul(amountCollateral).div(amountCollateral);
        uint repayAmount = amountCollateral == 0 ? 0 : amountBorrow.mul(amountCollateral).div(amountCollateral).add(repayInterest);

        uint result = maxBorrow.sub(repayAmount);
        if(poolBalance < result) {
            result = poolBalance;
        }
        return result;
    }

    function canReinvest(address _pair, address _user) public view returns(bool) {
        uint interestPerSupply = IAAAAPool(_pair).interestPerSupply();
        (uint amountSupply, uint interestSettled, , uint interests, ) = IAAAAPool(_pair).supplys(_user);
        uint remainSupply = IAAAAPool(_pair).remainSupply();
        uint platformShare = IConfig(config).params(ConfigNames.INTEREST_PLATFORM_SHARE);

        uint curInterests = interestPerSupply.mul(amountSupply).div(1e18).sub(interestSettled);
        interests = interests.add(curInterests);
        uint reinvestAmount = interests.mul(platformShare).div(1e18);
  
        if(reinvestAmount < remainSupply) {
            return true;
        } else {
            return false;
        }
    }

    function getBallotInfo(address _ballot, address _user) public view returns (BallotStruct memory proposal){
        proposal.ballot = _ballot;
        proposal.name = IAAAABallot(_ballot).name();
        proposal.creator = IAAAABallot(_ballot).creator();
        proposal.subject = IAAAABallot(_ballot).subject();
        proposal.content = IAAAABallot(_ballot).content();
        proposal.createdTime = IAAAABallot(_ballot).createdTime();
        proposal.createdBlock = IAAAABallot(_ballot).createdBlock();
        proposal.end = IAAAABallot(_ballot).end();
        proposal.pass = IAAAABallot(_ballot).pass();
        proposal.expire = IAAAABallot(_ballot).expire();
        proposal.YES = IAAAABallot(_ballot).proposals(0);
        proposal.NO = IAAAABallot(_ballot).proposals(1);
        proposal.reward = IAAAABallot(_ballot).reward();
        proposal.voted = IAAAABallot(_ballot).voters(_user).voted;
        proposal.voteIndex = IAAAABallot(_ballot).voters(_user).vote;
        proposal.weight = IAAAABallot(_ballot).voters(_user).weight;
        proposal.claimed = IAAAABallot(_ballot).voters(_user).claimed;
        proposal.value = IAAAABallot(_ballot).value();
        proposal.total = IAAAABallot(_ballot).total();
        proposal.pool = IAAAABallot(_ballot).pool();
        if(proposal.pool != address(0)) {
            proposal.currentValue = IConfig(config).getPoolValue(proposal.pool, proposal.name);
        } else {
            proposal.currentValue = IConfig(config).getValue(proposal.name);
        }

        if(proposal.total > 0) {
           proposal.myReward = proposal.reward * proposal.weight / proposal.total;
        }
    }


    function iterateBallotList(uint _start, uint _end) public view returns (BallotStruct[] memory ballots){
        require(_start <= _end && _start >= 0 && _end >= 0, "INVAID_PARAMTERS");
        uint count = IAAAAFactory(IConfig(config).factory()).countBallots();
        if (_end > count) _end = count;
        count = _end - _start;
        ballots = new BallotStruct[](count);
        if (count == 0) return ballots;
        uint index = 0;
        for(uint i = _start;i < _end;i++) {
            address ballot = IAAAAFactory(IConfig(config).factory()).allBallots(i);
            ballots[index] = getBallotInfo(ballot, msg.sender);
            index++;
        }
        return ballots;
    }

    function iterateReverseBallotList(uint _start, uint _end) public view returns (BallotStruct[] memory ballots){
        require(_end <= _start && _end >= 0 && _start >= 0, "INVAID_PARAMTERS");
        uint count = IAAAAFactory(IConfig(config).factory()).countBallots();
        if (_start > count) _start = count;
        count = _start - _end;
        ballots = new BallotStruct[](count);
        if (count == 0) return ballots;
        uint index = 0;
        for(uint i = _end;i < _start; i++) {
            uint j = _start - i -1;
            address ballot = IAAAAFactory(IConfig(config).factory()).allBallots(j);
            ballots[index] = getBallotInfo(ballot, msg.sender);
            index++;
        }
        return ballots;
    }

}