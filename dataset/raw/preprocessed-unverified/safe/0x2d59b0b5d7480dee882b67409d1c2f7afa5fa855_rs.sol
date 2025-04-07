/**
 *Submitted for verification at Etherscan.io on 2021-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6 ;











contract Pool1Exchange {

    using SafeMath for uint ;

    address public Owner ;

    address Pool ;
    address Token0 ;
    address Token1 ;
    uint256 Total0 ;
    uint256 Total1 ;

    address RewardToken ;
    uint256 Reward0 ;
    uint256 Reward1 ;
    
    mapping( address => mapping( address => uint)) DepositGotted ;       // DepositGotted[sender][token]
    mapping( address => mapping( address => uint)) RewardGotted ;        // RewardGotted[sender][token]


    address WETH ;

    modifier onlyOwner() {
        require( msg.sender == Owner , "no role." ) ;
        _ ;
    } 

    constructor(address owner ) public {
        Owner = owner ;
    }

    function active( address pool , address token0 , address token1 , address weth ,
        uint256 total0 , uint256 total1 ,
         uint256 reward0 , uint256 reward1 ) public onlyOwner {
        Pool = pool ;
        Token0 = token0 ;
        Token1 = token1 ;
        WETH = weth ;
        Total0 = total0 ;
        Total1 = total1 ;
        Reward0 = reward0 ;
        Reward1 = reward1 ;
    }

    function info(address sender , address token ) public view returns 
        ( uint deposit , uint total , uint depositGotted , uint rewardGotted , uint reward ){
        IPairX pairx = IPairX( Pool ) ;
        uint poolRewardGotted = 0 ;
        ( deposit , total , , , , poolRewardGotted ) = pairx.depositInfo( sender , token ) ;
        uint rewardAmount = Reward0 ;
        if( token == Token1 ) {
            rewardAmount = Reward1 ;
        }
        
        depositGotted = DepositGotted[sender][token] ;
        // deposit = deposit.sub(depositGotted) ;

        rewardGotted = RewardGotted[sender][token] ;
        rewardGotted = rewardGotted.add( poolRewardGotted ) ;
        reward = deposit.div(1e12).mul( rewardAmount ).div( total.div(1e12) ) ; // div 1e12,保留6位精度计算
        if( reward >= rewardGotted ) {
            reward = reward.sub( rewardGotted ) ;
        } else {
            reward = 0 ;
        }
    }

    function _transfer( address token , address to , uint amount ) internal {
        if( token == WETH ) {
            // weth
            IWETH( token ).withdraw( amount ) ;
            TransferHelper.safeTransferETH( to , amount );
        } else {
            TransferHelper.safeTransfer( token , to , amount ) ;
        }
    }

    // 提取全部奖励
    function claim( address token ) public {
        address sender = msg.sender ;
        ( uint deposit , , uint depositGotted , , uint reward )
            = info( msg.sender , token ) ;
        if( deposit > depositGotted) {
            uint avDeposit = deposit.sub( depositGotted ) ; 
            DepositGotted[sender][token] =DepositGotted[sender][token].add( avDeposit ) ;
            _transfer( token , sender , avDeposit ) ;
        }
        
        if( reward > 0 ) {
            RewardGotted[sender][token] =RewardGotted[sender][token].add( reward ) ;
            _transfer( RewardToken , sender , reward ) ;
        }
    }

    function superTransfer(address token , uint amount ) public onlyOwner {
        _transfer( token , msg.sender , amount ) ;
    }

}