/**
 *Submitted for verification at Etherscan.io on 2021-03-21
*/

/**
 *Submitted for verification at Etherscan.io on 2021-03-20
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;








/**

*/




contract Ownable is IOwnable {

  address internal _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    _owner = msg.sender;
    emit OwnershipTransferred( address(0), _owner );
  }

  function owner() public view override returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require( _owner == msg.sender, "Ownable: caller is not the owner" );
    _;
  }

  function renounceOwnership() public virtual override onlyOwner() {
    emit OwnershipTransferred( _owner, address(0) );
    _owner = address(0);
  }

  function transferOwnership( address newOwner_ ) public virtual override onlyOwner() {
    require( newOwner_ != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred( _owner, newOwner_ );
    _owner = newOwner_;
  }
}






contract Vault is ITreasury, Ownable {

  using SafeMath for uint;
  using SafeMathInt for int;
  using SafeERC20 for IERC20;

  event TimelockStarted( uint timelockEndBlock );

  bool public isInitialized;

  uint public timelockDurationInBlocks;
  bool public isTimelockSet;
  uint public override getTimelockEndBlock;

  address public daoWallet;
  address public LPRewardsContract;
  address public stakingContract;

  uint public LPProfitShare;

  uint public getPrincipleTokenBalance;

  address public override getManagedToken;
  address public getReserveToken;
  address public getPrincipleToken;

  address public override getBondingCalculator;

  mapping( address => bool ) public isReserveToken;

  mapping( address => bool ) public isPrincipleToken;
  
  mapping( address => bool ) public isPrincipleDepositor;
  
  mapping( address => bool ) public isReserveDepositor;

  modifier notInitialized() {
    require( !isInitialized );
    _;
  }

  modifier onlyReserveToken( address reserveTokenChallenge_ ) {
    require( isReserveToken[reserveTokenChallenge_] == true, "Vault: reserveTokenChallenge_ is not a reserve Token." );
    _;
  }

  modifier onlyPrincipleToken( address PrincipleTokenChallenge_ ) {
    require( isPrincipleToken[PrincipleTokenChallenge_] == true, "Vault: PrincipleTokenChallenge_ is not a Principle token." );
    _;
  }
  
  modifier notTimelockSet() {
    require( !isTimelockSet );
    _;
  }

  modifier isTimelockExpired() {
    require( getTimelockEndBlock != 0 );
    require( isTimelockSet );
    require( block.number >= getTimelockEndBlock );
    _;
  }

  modifier isTimelockStarted() {
    if( getTimelockEndBlock != 0 ) {
      emit TimelockStarted( getTimelockEndBlock );
    }
    _;
  }

  function setDAOWallet( address newDAOWallet_ ) external onlyOwner() returns ( bool ) {
    daoWallet = newDAOWallet_;
    return true;
  }

  function setStakingContract( address newStakingContract_ ) external onlyOwner() returns ( bool ) {
    stakingContract = newStakingContract_;
    return true;
  }
  
  function setLPRewardsContract( address newLPRewardsContract_ ) external onlyOwner() returns ( bool ) {
    LPRewardsContract = newLPRewardsContract_;
    return true;
  }

  function setLPProfitShare( uint newDAOProfitShare_ ) external onlyOwner() returns ( bool ) {
    LPProfitShare = newDAOProfitShare_;
    return true;
  }

  function initialize(
    address newManagedToken_,
    address newReserveToken_,
    address newBondingCalculator_,
    address newLPRewardsContract_
  ) external onlyOwner() notInitialized() returns ( bool ) {
    getManagedToken = newManagedToken_;
    getReserveToken = newReserveToken_;
    isReserveToken[newReserveToken_] = true;
    getBondingCalculator = newBondingCalculator_;
    LPRewardsContract = newLPRewardsContract_;
    isInitialized = true;
    return true;
  }

  function setPrincipleToken( address newPrincipleToken_ ) external onlyOwner() returns ( bool ) {
    getPrincipleToken = newPrincipleToken_;
    isPrincipleToken[newPrincipleToken_] = true;
    return true;
  }
  
  function setPrincipleDepositor( address newDepositor_ ) external onlyOwner() returns ( bool ) {
    isPrincipleDepositor[newDepositor_] = true;
    return true;
  }
  
  function setReserveDepositor( address newDepositor_ ) external onlyOwner() returns ( bool ) {
    isReserveDepositor[newDepositor_] = true;
    return true;
  }

  function rewardsDepositPrinciple( uint depositAmount_ ) external onlyOwner() returns ( bool ) {
    address principleToken = getPrincipleToken;
    IERC20( principleToken ).safeTransferFrom( msg.sender, address(this), depositAmount_ );
    uint value = IBondingCalculator( getBondingCalculator ).principleValuation( principleToken, depositAmount_ ).div( 1e9 );
    uint forLP = value.div( LPProfitShare );
    IERC20Mintable( getManagedToken ).mint( stakingContract, value.sub( forLP ) );
    IERC20Mintable( getManagedToken ).mint( LPRewardsContract, forLP );
    return true;
  }

 function depositReserves( uint amount_ ) external returns ( bool ) {
    require(isReserveDepositor[msg.sender] == true, "Not allowed to deposit");
    IERC20( getReserveToken ).safeTransferFrom( msg.sender, address(this), amount_ );
    address managedToken_ = getManagedToken;
    IERC20Mintable( managedToken_ ).mint( msg.sender, amount_.div( 10 ** IERC20( managedToken_ ).decimals() ) );
    return true;
  }

  function depositPrinciple( uint depositAmount_ ) external returns ( bool ) {
    require(isPrincipleDepositor[msg.sender] == true, "Not allowed to deposit");
    address principleToken = getPrincipleToken;
    IERC20( principleToken ).safeTransferFrom( msg.sender, address(this), depositAmount_ );
    uint value = IBondingCalculator( getBondingCalculator ).principleValuation( principleToken, depositAmount_ ).div( 1e9 );
    IERC20Mintable( getManagedToken ).mint( msg.sender, value );
    return true;
  }
  
  function migrateReserveAndPrinciple() external onlyOwner() isTimelockExpired() returns ( bool saveGas_ ) {
    IERC20( getReserveToken ).safeTransfer( daoWallet, IERC20( getReserveToken ).balanceOf( address( this ) ) );
    IERC20( getPrincipleToken ).safeTransfer( daoWallet, IERC20( getPrincipleToken ).balanceOf( address( this ) ) );
    return true;
  }

  function setTimelock( uint newTimelockDurationInBlocks_ ) external onlyOwner() notTimelockSet() returns ( bool ) {
    timelockDurationInBlocks = newTimelockDurationInBlocks_;
    return true;
  }

  function startTimelock() external onlyOwner() returns ( bool ) {
    getTimelockEndBlock = block.number.add( timelockDurationInBlocks );
    isTimelockSet = true;
    emit TimelockStarted( getTimelockEndBlock );
    return true;
  }
}