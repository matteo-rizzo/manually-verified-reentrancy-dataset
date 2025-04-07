/**
 *Submitted for verification at Etherscan.io on 2021-03-21
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;



interface IUniswapV2Pair is IUniswapV2ERC20 {
    // event Approval(address indexed owner, address indexed spender, uint value);
    // event Transfer(address indexed from, address indexed to, uint value);

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );

    // function name() external pure returns (string memory);
    // function symbol() external pure returns (string memory);
    // function decimals() external pure returns (uint8);
    // function totalSupply() external view returns (uint);
    // function balanceOf(address owner) external view returns (uint);
    // function allowance(address owner, address spender) external view returns (uint);

    // function approve(address spender, uint value) external returns (bool);
    // function transfer(address to, uint value) external returns (bool);
    // function transferFrom(address from, address to, uint value) external returns (bool);

    // function DOMAIN_SEPARATOR() external view returns (bytes32);
    // function PERMIT_TYPEHASH() external pure returns (bytes32);
    // function nonces(address owner) external view returns (uint);

    // function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}















contract OlympusBondingCalculator is IBondingCalculator {

  using FixedPoint for *;
  using SafeMath for uint;
  using SafeMath for uint112;

  event BondPremium( uint debtRatio_, uint bondScalingValue_, uint premium_ );
  event PrincipleValuation( uint k_, uint amountDeposited_, uint totalSupplyOfTokenDeposited_, uint principleValuation_  );
  event BondInterest( uint k_, uint amountDeposited_, uint totalSupplyOfTokenDeposited_, uint pendingDebtDue_, uint managedTokenTotalSupply_, uint bondScalingValue_, uint interestDue_ );

  function _calcDebtRatio( uint pendingDebtDue_, uint managedTokenTotalSupply_ ) internal pure returns ( uint debtRatio_ ) {    
    debtRatio_ = FixedPoint.fraction( 
      // Must move the decimal to the right by 9 places to avoid math underflow error
      pendingDebtDue_.mul( 1e9 ), 
      managedTokenTotalSupply_
    ).decode112with18()
    // Must move the decimal tot he left 18 places to account for the 9 places added above and the 19 signnificant digits added by FixedPoint.
    .div(1e18);

  }

  function calcDebtRatio( uint pendingDebtDue_, uint managedTokenTotalSupply_ ) external pure override returns ( uint debtRatio_ ) {
    debtRatio_ = _calcDebtRatio( pendingDebtDue_, managedTokenTotalSupply_ );
  }

  // Premium is 2 extra deciamls i.e. 250 = 2.5 premium
  function _calcBondPremium( uint debtRatio_, uint bondScalingValue_ ) internal pure returns ( uint premium_ ) {
    // premium_ = uint( uint(1).mul( 1e9 ).add( debtRatio_ ) ** bondScalingValue_);
    premium_ = bondScalingValue_.mul( (debtRatio_) ).add( uint(1010000000) ).div( 1e7 );
  }

  function calcBondPremium( uint debtRatio_, uint bondScalingValue_ ) external pure override returns ( uint premium_ ) {
    premium_ = _calcBondPremium( debtRatio_, bondScalingValue_ );
  }

  function _principleValuation( uint k_, uint amountDeposited_, uint totalSupplyOfTokenDeposited_ ) internal pure returns ( uint principleValuation_ ) {
    // *** When deposit amount is small does not pick up principle valuation *** \\
    principleValuation_ = k_.sqrrt().mul(2).mul( FixedPoint.fraction( amountDeposited_, totalSupplyOfTokenDeposited_ ).decode112with18().div( 1e10 ).mul( 10 ) );
  }

  function calcPrincipleValuation( uint k_, uint amountDeposited_, uint totalSupplyOfTokenDeposited_ ) external pure override returns ( uint principleValuation_ ) {
    principleValuation_ = _principleValuation( k_, amountDeposited_, totalSupplyOfTokenDeposited_ );
  }

  function principleValuation( address principleTokenAddress_, uint amountDeposited_ ) external view override returns ( uint principleValuation_ ) {
    uint k_ = _getKValue(principleTokenAddress_);

    uint principleTokenTotalSupply_ = IUniswapV2Pair( principleTokenAddress_ ).totalSupply();
    principleValuation_ = _principleValuation( k_, amountDeposited_, principleTokenTotalSupply_ );
  }

  function _calculateBondInterest( uint k_, uint amountDeposited_, uint totalSupplyOfTokenDeposited_, uint pendingDebtDue_, uint managedTokenTotalSupply_, uint bondScalingValue_ ) internal returns ( uint interestDue_ ) {
    uint principleValuation_ = _principleValuation( k_, amountDeposited_, totalSupplyOfTokenDeposited_ );

    uint debtRatio_ = _calcDebtRatio( pendingDebtDue_, managedTokenTotalSupply_ );

    uint premium_ = _calcBondPremium( debtRatio_, bondScalingValue_ );

    interestDue_ = FixedPoint.fraction(
      principleValuation_,
     premium_
    ).decode().div( 100 );
    emit BondInterest( k_, amountDeposited_, totalSupplyOfTokenDeposited_, pendingDebtDue_, managedTokenTotalSupply_, bondScalingValue_, interestDue_ );
  }


  function calculateBondInterest( address treasury_, address principleTokenAddress_, uint amountDeposited_, uint bondScalingValue_ ) external override returns ( uint interestDue_ ) {
    //uint k_ = IUniswapV2Pair( principleTokenAddress_ ).kLast();

    uint k_ = _getKValue(principleTokenAddress_);

    uint principleTokenTotalSuply_ = IUniswapV2Pair( principleTokenAddress_ ).totalSupply();

    address managedToken_ = ITreasury( treasury_ ).getManagedToken();

    uint managedTokenTotalSuply_ = IUniswapV2Pair( managedToken_ ).totalSupply();

    uint outstandingDebtAmount_ = ITreasury( treasury_ ).getDebtAmountDue();

    interestDue_ = _calculateBondInterest( k_, amountDeposited_, principleTokenTotalSuply_, outstandingDebtAmount_, managedTokenTotalSuply_, bondScalingValue_ );
  }
  
  function _getKValue( address principleTokenAddress_ ) internal view returns( uint k_ )  {
    (uint reserve0, uint reserve1, ) = IUniswapV2Pair( principleTokenAddress_ ).getReserves();
     k_ = reserve0.mul(reserve1).div(1e9);
  }
}