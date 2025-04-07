/**
 *Submitted for verification at Etherscan.io on 2021-09-10
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.4;


abstract contract OwnableStatic {

    mapping( address => bool ) public _isOwner;

    constructor() {
        _setOwner(msg.sender, true);
    }

    modifier onlyOwner() {
    require( _isOwner[msg.sender] );
    _;
  }

    function _setOwner(address newOwner, bool makeOwner) private {
        _isOwner[newOwner] = makeOwner;
        // _owner = newOwner;
        // emit OwnershipTransferred(oldOwner, newOwner);
    }

    function setOwnerShip( address newOwner, bool makeOOwner ) external onlyOwner() returns ( bool success ) {
    _isOwner[newOwner] = makeOOwner;
    success = true;
  }
}









contract LPLeverageLaunch is OwnableStatic, ILPLeverageLaunch {

  using AddressUtils for address;
  using SafeERC20 for IERC20;

  mapping( address => bool ) public override isTokenApprovedForLending;

  mapping( address => mapping( address => uint256 ) ) private _amountLoanedForLoanedTokenForLender;
  
  mapping( address => uint256 ) private _totalLoanedForToken;

  mapping( address => uint256 ) private _launchTokenDueForHolder;

  mapping( address => uint256 ) public override priceForLentToken;

  address public override _weth9;

  address public override fundManager;

  bool public override isActive;

  address public previousDepoistSource;

  modifier onlyActive() {
    require( isActive == true, "Launch: Lending is not active." );
    _;
  }

  constructor() {}


  function amountLoanedForLoanedTokenForLender( address holder, address lentToken ) external override view returns ( uint256 ) {
    return _amountLoanedForLoanedTokenForLender[holder][lentToken] + ILPLeverageLaunch(previousDepoistSource).amountLoanedForLoanedTokenForLender( holder, lentToken );
  }

  function totalLoanedForToken( address lentToken ) external override view returns ( uint256 ) {
    return _totalLoanedForToken[lentToken] + ILPLeverageLaunch(previousDepoistSource).totalLoanedForToken(lentToken);
  }

  function launchTokenDueForHolder( address holder ) external override view returns ( uint256 ) {
    return _launchTokenDueForHolder[holder] + ILPLeverageLaunch(previousDepoistSource).launchTokenDueForHolder(holder);
  }

  function setPreviousDepositSource( address newPreviousDepositSource ) external override onlyOwner() returns ( bool success ) {
    previousDepoistSource = newPreviousDepositSource;
    success = true;
  }

  function changeActive( bool makeActive ) external override onlyOwner() returns ( bool success ) {
    isActive = makeActive;
    success = true;
  }

  function setFundManager( address newFundManager ) external override onlyOwner() returns ( bool success ) {
    fundManager = newFundManager;
    success = true;
  }

  function setWETH9( address weth9 ) external override onlyOwner() returns ( bool success ) {
    _weth9 = weth9;
    success = true;
  }

  function setPrice( address lentToken, uint256 price ) external override onlyOwner() returns ( bool success ) {
    priceForLentToken[lentToken] = price;
    success = true;
  }

  function dispenseToFundManager( address token ) external override onlyOwner() returns ( bool success ) {
    _dispenseToFundManager( token );
    success = true;
  }

  function _dispenseToFundManager( address token ) internal {
    require( fundManager != address(0) );
    IERC20(token).safeTransfer( fundManager, IERC20(token).balanceOf( address(this) ) );
  }

  function changeTokenLendingApproval( address newToken, bool isApproved ) external override onlyOwner() returns ( bool success ) {
    isTokenApprovedForLending[newToken] = isApproved;
    success = true;
  }

  function getTotalLoaned(address token ) external override view returns (uint256 totalLoaned) {
    totalLoaned = _totalLoanedForToken[token];
  }

  /**
   * @param loanedToken The address fo the token being paid. Ethereum is indicated with _weth9.
   */
  function lendLiquidity( address loanedToken, uint amount ) external override onlyActive() returns ( bool success ) {
    require( fundManager != address(0) );
    require( isTokenApprovedForLending[loanedToken] );

    IERC20(loanedToken).safeTransferFrom( msg.sender, fundManager, amount );
    _amountLoanedForLoanedTokenForLender[msg.sender][loanedToken] += amount;
    _totalLoanedForToken[loanedToken] += amount;

    _launchTokenDueForHolder[msg.sender] += (amount / priceForLentToken[loanedToken]);

    success = true;
  }

  function getAmountDueToLender( address lender ) external override view returns ( uint256 amountDue ) {
    amountDue = _launchTokenDueForHolder[lender];
  }

  function lendETHLiquidity() external override payable onlyActive() returns ( bool success ) {
    _lendETHLiquidity();

    success = true;
  }

  function _lendETHLiquidity() internal {
    require( fundManager != address(0), "Launch: fundManager is address(0)." );
    _amountLoanedForLoanedTokenForLender[msg.sender][_weth9] += msg.value;
    _totalLoanedForToken[_weth9] += msg.value;
    _launchTokenDueForHolder[msg.sender] += msg.value;
  }

  function dispenseToFundManager() external override onlyOwner() returns ( bool success ) {
    payable(fundManager).transfer( _totalLoanedForToken[address(_weth9)] );
    delete _totalLoanedForToken[address(_weth9)];
    success = true;
  }

  function setTotalEthLent( uint256 newValidEthBalance ) external override onlyOwner() returns ( bool success ) {
    _totalLoanedForToken[address(_weth9)] = newValidEthBalance;
    success = true;
  }

  function getAmountLoaned( address lender, address lentToken ) external override view returns ( uint256 amountLoaned ) {
    amountLoaned = _amountLoanedForLoanedTokenForLender[lender][lentToken];
  }

}