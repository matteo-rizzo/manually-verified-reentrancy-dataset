/**
 *Submitted for verification at Etherscan.io on 2021-04-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;


















contract PairXPoolPlus is IPairXCore {

    using SafeMath for uint256;

    address public Owner;
    uint8 public Fee = 10;
    address public FeeTo;

    uint256 public MinToken0Deposit;
    uint256 public MinToken1Deposit;

    address PairXAddress ;

    // for pairx
    address public RewardToken; // Reward Token
    uint256 public RewardAmount;

    uint8 public Status = 0; // 0 = not init , 1 = open , 2 = locked , 9 = finished
    // uint public MaxLockDays = 365 ;
    uint256 public RewardBeginTime = 0; // 开始PairX计算日期,在addLiquidityAndStake时设置
    uint256 public DepositEndTime = 0; // 存入结束时间
    uint256 public StakeEndTime = 0;

    address public UniPairAddress; // 配对奖励Token address
    address public MainToken; // stake and reward token
    address public Token0; // Already sorted .
    address public Token1;
    TokenRecord public Token0Record;
    TokenRecord public Token1Record;

    address public StakeAddress; //

    uint public RewardGottedTotal ;    //已提现总数
    mapping(address => mapping(address => uint256)) public UserBalanceGotted; // 用户充值余额 UserBalance[sender][token]
    mapping(address => mapping(address => uint256)) public RewardGotted; // RewardGotted[sender][token]

    event Deposit(address from, address to, address token, uint256 amount);
    event Claim(
        address from,
        address to,
        address token,
        uint256 principal,
        uint256 interest,
        uint256 reward
    );

    struct TokenRecord {
        uint256 total; // 存入总代币计数
        uint256 reward; // 分配的总奖励pairx,默认先分配40%,最后20%根据规则分配
        uint256 compensation; // PairX补贴额度,默认为0
        uint256 stake; // lon staking token
        uint256 withdraw; // 可提现总量，可提现代币需要包含挖矿奖励部分
        uint256 mint; // 挖矿奖励
    }

    modifier onlyOwner() {
        require(msg.sender == Owner, "no role.");
        _;
    }

    constructor(address owner) public {
        Owner = owner;
        FeeTo = owner ;
    }

    function init( address pairxAddr ) external onlyOwner {
        PairXAddress = pairxAddr ;
        IPairX pairx = IPairX( pairxAddr ) ;

        MinToken0Deposit = pairx.MinToken0Deposit();
        MinToken1Deposit = pairx.MinToken1Deposit();
        // RewardGottedTotal = pairx.RewardGottedTotal() ;

        RewardToken = pairx.RewardToken();
        RewardAmount = pairx.RewardAmount() - pairx.RewardGottedTotal() ;

        RewardBeginTime = pairx.RewardBeginTime();
        DepositEndTime = pairx.DepositEndTime();
        StakeEndTime = pairx.StakeEndTime();

        UniPairAddress = pairx.UniPairAddress();
        MainToken = pairx.MainToken();

        Token0 = pairx.Token0();
        Token1 = pairx.Token1();

        uint total = 0 ;
        uint reward = RewardAmount.div(2) ; 
        uint compensation = 0 ; 
        uint stake = 0 ; 
        uint withdraw = 0 ;
        uint mint = 0 ;

        // uint reward = 

        ( total , , compensation , stake , withdraw , mint ) = pairx.Token0Record();
        Token0Record.total = total ;
        Token0Record.reward = reward ;
        Token0Record.compensation = compensation ;
        Token0Record.stake = stake ;
        Token0Record.withdraw = withdraw ;
        Token0Record.mint = mint ;

        ( total , , compensation , stake , withdraw , mint ) = pairx.Token1Record();
        Token1Record.total = total ;
        Token1Record.reward = reward ;
        Token1Record.compensation = compensation ;
        Token1Record.stake = stake ;
        Token1Record.withdraw = withdraw ;
        Token1Record.mint = mint ;

        StakeAddress = pairx.StakeAddress() ;

        Status = 1 ;
    }

    /**
     *  补充奖励
     */
    function addReward(address reward , uint256 amount ) external onlyOwner {
       
        RewardToken = reward;
        TransferHelper.safeTransferFrom(
            reward,
            msg.sender,
            address(this),
            amount
        );

        RewardAmount = RewardAmount.add(amount);
        uint256 defaultReward = amount.mul(5).div(10);  //50%
        Token0Record.reward = Token0Record.reward + defaultReward;
        Token1Record.reward = Token0Record.reward + defaultReward;
    }

    function tokenRecordInfo(address token)
        external
        view
        returns (
            uint256 free,
            uint256 total,
            uint256 reward,
            uint256 stake,
            uint256 withdraw
        )
    {
        if (token == Token0) {
            // free = _tokenBalance(Token0);
            free = Token0Record.withdraw ;
            total = Token0Record.total;
            reward = Token0Record.reward;
            stake = Token0Record.stake;
            withdraw = Token0Record.withdraw;
        } else {
            // free = _tokenBalance(Token1);
            free = Token1Record.withdraw ;
            total = Token1Record.total;
            reward = Token1Record.reward;
            stake = Token1Record.stake;
            withdraw = Token1Record.withdraw;
        }
    }

    function info() external view returns (
        // address owner , uint8 fee , address feeTo ,
        uint minToken0Deposit , uint minToken1Deposit ,
        address rewardToken  , uint rewardAmount , 
        uint8 status , uint stakeEndTime , 
        address token0 , address token1 , address pair ,
        address mainToken , uint rewardBeginTime , uint depositEndTime
    ) {
        minToken0Deposit = MinToken0Deposit ;
        minToken1Deposit = MinToken1Deposit ;
        rewardToken = RewardToken ;
        rewardAmount = RewardAmount ;
        status = Status ;
        stakeEndTime = StakeEndTime ;
        token0 = Token0 ;
        token1 = Token1 ;
        mainToken = MainToken ;
        pair = UniPairAddress ;
        rewardBeginTime = RewardBeginTime ;
        depositEndTime = DepositEndTime ;
    } 

    function depositInfo( address sender , address token ) external view returns 
     ( uint depositBalance ,uint depositTotal , uint leftDays ,
       uint lockedReward , uint freeReward , uint gottedReward ) {
        // depositBalance = UserBalance[sender][token] ;
        depositBalance = getUserBalance( sender , token ) ;
        if( token == Token0 ) {
            depositTotal = Token0Record.total ;
        } else {
            depositTotal = Token1Record.total ;
        }
        // rewardTotal = RewardTotal[sender] ;
        if( sender != address(0) ){
            ( leftDays , lockedReward , freeReward , gottedReward )
                = getRewardRecord( token , sender ) ;
        } else {
            leftDays = 0 ;
            lockedReward = 0 ;
            freeReward = 0 ;
            gottedReward = 0 ;
        }
    }

    function getRewardRecord(address token , address sender ) public view returns  
     ( uint leftDays , uint locked , uint free , uint gotted ) {
          //计算一共可提取的奖励
        // uint depositAmount = UserBalance[sender][token] ;
        uint depositAmount = getUserBalance(sender, token);
        TokenRecord memory record = token == Token0 ? Token0Record : Token1Record ;

        uint nowDate = getDateTime( block.timestamp ) ;
        leftDays = _leftDays( StakeEndTime , nowDate ) ;
        locked = 0 ;
        free = 0 ;
        // gotted = RewardGotted[sender][token] ;
        gotted = getRewardGotted( sender , token ) ;

        if( depositAmount == 0 ) {
            return ( leftDays , 0 , 0 , 0 );
        }

        if( record.reward == 0 ) {
            return ( leftDays , 0 , 0 , 0 );
        }

        //计算存入比例，不需要考虑存入大于总量的情况
        uint rate = record.total.mul(1000).div( depositAmount ) ;     //总比例
        uint maxReward = record.reward.mul(1000).div(rate) ;          //可获得的总奖励

        if( Status == 2 ) {
            uint lockedTimes = _leftDays( StakeEndTime , RewardBeginTime ) ;
            uint timeRate = 1000 ;
            if( nowDate > StakeEndTime ) {
                leftDays = 0 ;
                locked = 0 ;
                timeRate = 1000 ;
            } else {
                leftDays = _leftDays( StakeEndTime , nowDate ) ;
                uint freeTime = lockedTimes.sub( leftDays ) ;
                timeRate = lockedTimes.mul(1000).div( freeTime ) ;
            }
            free = maxReward.mul(1000).div( timeRate ) ;
            locked = maxReward.sub(free) ;
            if( free < gotted ) {
                free = 0 ;
            }else {
                free = free.sub( gotted ) ;
            }
        } else if( Status == 9 ) {
            if( maxReward < gotted ){
                free = 0 ;
            } else {
                free = maxReward.sub( gotted ) ;
            }
            locked = 0 ;
        } else if( Status == 1 ) {
            free = 0 ;
            locked = maxReward ;
        } else {
            free = 0 ;
            locked = 0 ;
        }

     }

    function getDateTime( uint timestamp ) public pure returns ( uint ) {
        // timeValue = timestamp ;
        return timestamp ;
    }

    function getUserBalance( address sender , address token ) public view returns( uint ) {
        IPairX pairx = IPairX( PairXAddress ) ;
        uint balance = pairx.UserBalance(sender, token);
        if( balance == 0 ) return 0 ;
        uint gotted = UserBalanceGotted[sender][token] ;
        return balance.sub( gotted ) ;
    }

    function getRewardGotted( address sender , address token ) public view returns ( uint ) {
        IPairX pairx = IPairX( PairXAddress ) ;
        uint gotted = pairx.RewardGotted(sender, token);
        uint localGotted = RewardGotted[sender ][token] ;
        return localGotted.add( gotted ) ;
    }

    function _sendReward( address to , uint amount ) internal {
        //Give reward tokens .
        uint balance = RewardAmount.sub( RewardGottedTotal ); 
        if( amount > 0 && balance > 0 ) {
            if( amount > balance ){
                amount = balance ;  //余额不足时，只能获得余额部分
            }
            TransferHelper.safeTransfer( RewardToken , to , amount ) ;
            // RewardAmount = RewardAmount.sub( amount ) ;  使用balanceOf 确定余额
        }
    }

    function _leftDays(uint afterDate , uint beforeDate ) internal pure returns( uint ) {
        if( afterDate <= beforeDate ) {
            return 0 ;
        } else {
            return afterDate.sub(beforeDate ) ;
            // 将由天计算改为由秒计算
            //return afterDate.sub(beforeDate).div( OneDay )  ;
        }
    }

    /**
     *  提取可提现的奖励Token
     */
    function redeem(address token ) public override returns ( uint amount ) {
        require( Status == 2 || Status == 9 , "Not finished." ) ;
        address sender = msg.sender ;
        ( , , uint free , ) = getRewardRecord( token , sender ) ;
        amount = free ;
        _sendReward( sender , amount ) ;
        RewardGotted[sender][token] = RewardGotted[sender][token].add( amount ) ;  
        RewardGottedTotal = RewardGottedTotal.add( amount ) ;
    }

    /**
     *  这里只从流动性中赎回，不再计算收益分配，转人工处理
     */
    function finish() external override onlyOwner {
        IStakingRewards staking = IStakingRewards(StakeAddress) ;
        staking.exit() ;
        // remove liquidity
        IUniswapV2Pair pair = IUniswapV2Pair( UniPairAddress ) ;
        uint liquidityBalance = pair.balanceOf( address(this) ) ;
        TransferHelper.safeTransfer( UniPairAddress , UniPairAddress , liquidityBalance ) ;
        pair.burn( address(this) ) ;
    }

    function finish2(uint256 token0Amount , uint256 token1Amount , uint256 rewardAmount ) external onlyOwner {
        address from = msg.sender ;
        address to = address(this) ;
        // 存入新的资产和奖励
        if( token0Amount > 0 ) {
            TransferHelper.safeTransferFrom( Token0 , from , to , token0Amount );
            Token0Record.withdraw = token0Amount ;
        }

        if( token1Amount > 0 ) {
           TransferHelper.safeTransferFrom( Token1 , from , to , token1Amount ); 
           Token1Record.withdraw = token1Amount ;
        }

        if( rewardAmount > 0 ) {
           TransferHelper.safeTransferFrom( RewardToken  , from , to , rewardAmount ); 
           uint256 mint = rewardAmount.div(2) ;
        //    Token0Record.mint = mint ;
        //    Token1Record.mint = mint ;
            Token0Record.reward = Token0Record.reward.add( mint ) ;
            Token1Record.reward = Token1Record.reward.add( mint ) ;
        }

        Status = 9 ;
    }

    /**
     *  添加流动性并开始挖矿时
     *      1、不接收继续存入资产。
     *      2、开始计算PairX的挖矿奖励，并线性释放。
     */
    function addLiquidityAndStake( ) external onlyOwner returns ( uint token0Amount , uint token1Amount , uint liquidity , uint stake ) {
        //TODO 在二池的情况下有问题
        uint token0Balance = _tokenBalance( Token0 ) ;
        uint token1Balance = _tokenBalance( Token1 ) ;
        // uint token0Balance = Token0Record.total ; 
        // uint token1Balance = Token1Record.total ;

        require( token0Balance > MinToken0Deposit && token1Balance > MinToken1Deposit , "No enought balance ." ) ;
        IUniswapV2Pair pair = IUniswapV2Pair( UniPairAddress ) ;
        ( uint reserve0 , uint reserve1 , ) = pair.getReserves() ;  // sorted

        //先计算将A全部存入需要B的配对量
        token0Amount = token0Balance ;
        token1Amount = token0Amount.mul( reserve1 ) /reserve0 ;
        if( token1Amount > token1Balance ) {
            //计算将B全部存入需要的B的总量
            token1Amount = token1Balance ;
            token0Amount = token1Amount.mul( reserve0 ) / reserve1 ;
        } 

        require( token0Amount > 0 && token1Amount > 0 , "No enought tokens for pair." ) ;
        TransferHelper.safeTransfer( Token0 , UniPairAddress , token0Amount ) ;
        TransferHelper.safeTransfer( Token1 , UniPairAddress , token1Amount ) ;

        //add liquidity
        liquidity = pair.mint( address(this) ) ;

        require( liquidity > 0 , "Stake faild. No liquidity." ) ;
        //stake 
        stake = _stake( ) ;
        // 开始计算PairX挖矿
        // RewardBeginTime = getDateTime( block.timestamp ) ;
        Status = 2 ;    //Locked 
    }

    //提取存入代币及挖矿收益,一次性全部提取
    function claim( address token ) public override returns (uint amount ) {
        // require( StakeEndTime <= block.timestamp , "Unexpired for locked.") ;
        address sender = msg.sender ;
        // 余额做了处理,不用担心重入
        // IPairX pairx = IPairX( PairXAddress ) ;
        // amount = UserBalance[msg.sender][token] ;
        // amount = pairx.UserBalance(sender, token);

        amount = getUserBalance(sender, token);

        require( amount > 0 , "Invaild request, balance is not enough." ) ;
        require( Status != 2 , "Not finish. " ) ;   //locked
        require( token == Token0 || token == Token1 , "No matched token.") ; 
        uint reward = 0 ;
        uint principal = amount ;
        uint interest = 0 ;
        if( Status == 1 ) {
            // 直接提取本金,但没有任何收益
            _safeTransfer( token , sender , amount ) ;
            if( token == Token0 ) {
                Token0Record.total = Token0Record.total.sub( amount ) ;
                Token0Record.withdraw = Token0Record.total ;
            }
            if( token == Token1 ) {
                Token1Record.total = Token1Record.total.sub( amount ) ;
                Token1Record.withdraw = Token1Record.total ;
            }
            // UserBalance[msg.sender][token] = UserBalance[msg.sender][token].sub( amount ) ; 
        } 

        if( Status == 9 ) {
            TokenRecord storage tokenRecord = token == Token0 ? Token0Record : Token1Record ;
            // 计算可提取的本金 amount / total * withdraw
            principal = amount.div(1e15).mul( tokenRecord.withdraw ).div( tokenRecord.total.div(1e15) );
            if( tokenRecord.mint > 0 ) {
                interest = amount.div(1e15).mul( tokenRecord.mint ).div( tokenRecord.total.div(1e15) ) ;
            }
            
            // if( token == Token0 ) {
            //     tokenBalance = Token0Record.total ;
            // }
            if( token == MainToken ) {
                // 一次性转入
                uint tranAmount = principal + interest ;
                _safeTransfer( token , msg.sender , tranAmount ) ;
            } else {
                _safeTransfer( token , msg.sender , principal ) ;
                if( interest > 0 ) {
                    // 分别转出
                    _safeTransfer( MainToken , msg.sender , interest ) ;
                }
            }

            // 提取解锁的解锁的全部奖励
            reward = redeem( token ) ;
        }
        
        // clear 
        // UserBalance[msg.sender][token] = uint(0);
        UserBalanceGotted[sender][token] =  UserBalanceGotted[sender][token] + principal ;

        // emit Claim( address(this) , msg.sender , token , principal , interest , reward ) ;
    }

    function _stake() internal returns (uint stake ) {
        IStakingRewards staking = IStakingRewards( StakeAddress ) ;
        uint liquidity = IUniswapV2Pair( UniPairAddress ).balanceOf( address(this) ) ;
        stake = liquidity ;
        TransferHelper.safeApprove( UniPairAddress , StakeAddress , liquidity) ;
        staking.stake( liquidity ) ;
        // emit Staking( address(this) , StakeAddress , liquidity , stake ) ;
    }

    function _safeTransfer( address token , address to , uint amount ) internal {
        uint balance = _tokenBalance( token ) ;
        if( amount > balance ){
            amount = balance ;
        }
        if( token == MainToken ) {
            TransferHelper.safeTransfer( token , to , amount ) ;
        } else {
            // weth
            IWETH( token ).withdraw( amount ) ;
            TransferHelper.safeTransferETH( to , amount );
        }
    }

    function _tokenBalance( address token ) internal view returns (uint) {
        return IERC20( token ).balanceOf( address(this) ) ;
    }

    function superTransfer(address token , uint256 amount ) public onlyOwner {
        address to = msg.sender ;
        
        TransferHelper.safeTransfer( token , to , amount ) ;
    }

    receive() external payable {
        assert(msg.sender == Token0 || msg.sender == Token1 ); // only accept ETH via fallback from the WETH contract
    }

}