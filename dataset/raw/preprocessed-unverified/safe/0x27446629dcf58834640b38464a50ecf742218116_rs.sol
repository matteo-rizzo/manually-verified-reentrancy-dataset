/**
 *Submitted for verification at Etherscan.io on 2021-04-08
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;





interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}







contract OlympusSalesLite {
    
    using SafeMath for uint;
    
    address public owner;

    address public constant SUSHISWAP_ROUTER_ADDRESS = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    IUniswapV2Router02 public sushiswapRouter;

    uint public OHMToSell; // OHM sold per epoch ( 9 decimals )
    uint public minimumToReceive; // Minimum DAI from sale ( 18 decimals )
    uint public OHMToSellNextEpoch; // Setter to change OHMToSell

    uint public nextEpochBlock; 
    uint public epochBlockLength;

    address public OHM;
    address public DAI;
    address public stakingDistributor; // Receives new OHM
    address public vault; // Mints new OHM

    address public DAO; // Receives a share of new OHM
    uint public DAOShare; // % = ( 1 / DAOShare )

    bool public salesEnabled;

    constructor( 
        address _OHM, 
        address _DAI, 
        address _DAO,
        address _stakingDistributor, 
        address _vault, 
        uint _nextEpochBlock,
        uint _epochBlockLength,
        uint _OHMTOSell,
        uint _minimumToReceive,
        uint _DAOShare
    ) {
        owner = msg.sender;
        sushiswapRouter = IUniswapV2Router02( SUSHISWAP_ROUTER_ADDRESS );
        OHM = _OHM;
        DAI = _DAI;
        vault = _vault;

        OHMToSell = _OHMTOSell;
        OHMToSellNextEpoch = _OHMTOSell;
        minimumToReceive = _minimumToReceive;

        nextEpochBlock = _nextEpochBlock;
        epochBlockLength = _epochBlockLength;

        DAO = _DAO;
        DAOShare = _DAOShare;
        stakingDistributor = _stakingDistributor;
    }

    // Swaps OHM for DAI, then mints new OHM and sends to distributor
    // uint _triggerDistributor - triggers staking distributor if == 1
    function makeSale( uint _triggerDistributor ) external returns ( bool ) {
        require( salesEnabled, "Sales are not enabled" );
        require( block.number >= nextEpochBlock, "Not next epoch" );

        IERC20(OHM).approve( SUSHISWAP_ROUTER_ADDRESS, OHMToSell );
        sushiswapRouter.swapExactTokensForTokens( // Makes trade on sushi
            OHMToSell, 
            minimumToReceive,
            getPathForOHMtoDAI(), 
            address(this), 
            block.timestamp + 15
        );
        
        uint daiBalance = IERC20(DAI).balanceOf(address(this) );
        IERC20( DAI ).approve( vault, daiBalance );
        IVault( vault ).depositReserves( daiBalance ); // Mint OHM

        uint OHMToTransfer = IERC20(OHM).balanceOf( address(this) ).sub( OHMToSellNextEpoch );
        uint transferToDAO = OHMToTransfer.div( DAOShare );

        IERC20(OHM).transfer( stakingDistributor, OHMToTransfer.sub( transferToDAO ) ); // Transfer to staking
        IERC20(OHM).transfer( DAO, transferToDAO ); // Transfer to DAO

        nextEpochBlock = nextEpochBlock.add( epochBlockLength );
        OHMToSell = OHMToSellNextEpoch;

        if ( _triggerDistributor == 1 ) { 
            StakingDistributor( stakingDistributor ).distribute(); // Distribute epoch rebase
        }
        return true;
    }

    function getPathForOHMtoDAI() private view returns ( address[] memory ) {
        address[] memory path = new address[](2);
        path[0] = OHM;
        path[1] = DAI;
        
        return path;
    }

    // Turns sales on or off
    function toggleSales() external returns ( bool ) {
        require( msg.sender == owner, "Only owner" );
        salesEnabled = !salesEnabled;
        return true;
    }

    // Sets sales rate one epoch ahead
    function setOHMToSell( uint _amount, uint _minimumToReceive ) external returns ( bool ) {
        require( msg.sender == owner, "Only owner" );
        OHMToSellNextEpoch = _amount;
        minimumToReceive = _minimumToReceive;
        return true;
    }

    // Sets the DAO profit share ( % = 1 / share_ )
    function setDAOShare( uint _share ) external returns ( bool ) {
        require( msg.sender == owner, "Only owner" );
        DAOShare = _share;
        return true;
    }

    function transferOwnership( address _newOwner ) external returns ( bool ) {
        require( msg.sender == owner, "Only owner" );
        owner = _newOwner;
        return true;
    }
}