/**
 *Submitted for verification at Etherscan.io on 2021-09-09
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.6;


abstract contract OwnableStatic {
    // address private _owner;
    mapping( address => bool ) private _isOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(msg.sender, true);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    // function owner() public view virtual returns (address) {
    //     return _owner;
    // }
    function isOwner( address ownerQuery ) external  view returns ( bool isQueryOwner ) {
    isQueryOwner = _isOwner[ownerQuery];
  }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    // modifier onlyOwner() virtual {
    //     require(owner() == msg.sender, "Ownable: caller is not the owner");
    //     _;
    // }
    modifier onlyOwner() {
    require( _isOwner[msg.sender] );
    _;
  }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    // function renounceOwnership() public virtual onlyOwner {
    //     _setOwner(address(0));
    // }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    // function transferOwnership(address newOwner) public virtual onlyOwner {
    //     require(newOwner != address(0), "Ownable: new owner is the zero address");
    //     _setOwner(newOwner);
    // }

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







contract LPLeverageLaunch is OwnableStatic {

  using SafeERC20 for IERC20;

  mapping( address => bool ) public isTokenApprovedForLending;

  mapping( address => mapping( address => uint256 ) ) public amountLoanedForLoanedTokenForLender;
  
  mapping( address => uint256 ) public totalLoanedForToken;

  mapping( address => uint256 ) public launchTokenDueForHolder;

  mapping( address => uint256 ) public priceForLentToken;

  address public _weth9;

  address public fundManager;

  bool public isActive;

  modifier onlyActive() {
    require( isActive == true );
    _;
  }

  constructor() {}

  function changeActive( bool makeActive ) external onlyOwner() returns ( bool success ) {
    isActive = makeActive;
    success = true;
  }

  function setFundManager( address newFundManager ) external onlyOwner() returns ( bool success ) {
    fundManager = newFundManager;
    success = true;
  }

  function setWETH9( address weth9 ) external onlyOwner() returns ( bool success ) {
    _weth9 = weth9;
    success = true;
  }

  function dispenseToFundManager( address token ) external onlyOwner() returns ( bool success ) {
    _dispenseToFundManager( token );
    success = true;
  }

  function _dispenseToFundManager( address token ) internal {
    require( fundManager != address(0) );
    IERC20(token).safeTransfer( fundManager, IERC20(token).balanceOf( address(this) ) );
  }

  function changeTokenLendingApproval( address newToken, bool isApproved ) external onlyOwner() returns ( bool success ) {
    isTokenApprovedForLending[newToken] = isApproved;
    success = true;
  }

  function getTotalLoaned(address token ) external view returns (uint256 totalLoaned) {
    totalLoaned = totalLoanedForToken[token];
  }

  function setPrice( address lentToken, uint256 price ) external onlyOwner() returns ( bool success ) {
    priceForLentToken[lentToken] = price;
    success = true;
  }

  /**
   * @param loanedToken The address fo the token being paid. Ethereum is indicated with address(0).
   */
  function lendLiquidity( address loanedToken, uint amount ) external onlyActive() returns ( bool success ) {
    require( fundManager != address(0) );
    require( isTokenApprovedForLending[loanedToken] );

    IERC20(loanedToken).safeTransferFrom( msg.sender, fundManager, amount );
    amountLoanedForLoanedTokenForLender[msg.sender][loanedToken] += amount;
    totalLoanedForToken[loanedToken] += amount;

    // uint256 lentTokenPrice = twapForToken[loanedToken];

    launchTokenDueForHolder[msg.sender] += (amount / priceForLentToken[loanedToken]);

    success == true;
  }

  function getAmountDueToLender( address lender ) external view returns ( uint256 amountDue ) {
    amountDue = launchTokenDueForHolder[lender];
  }

  receive() external payable onlyActive() {
    _lendLiquidity();
  }

  function lendETHLiquidity() external payable onlyActive() returns ( bool success ) {
    _lendLiquidity();

    success == true;
  }

  function _lendLiquidity() internal returns ( bool success ) {
    require( fundManager != address(0) );
    amountLoanedForLoanedTokenForLender[msg.sender][address(_weth9)] = amountLoanedForLoanedTokenForLender[msg.sender][address(_weth9)] + msg.value;
    totalLoanedForToken[address(_weth9)] += msg.value;

    payable(fundManager).transfer( address(this).balance );

    launchTokenDueForHolder[msg.sender] += msg.value;

    success == true;
  }

  function dispenseToFundManager() external onlyOwner() returns ( bool success ) {
    payable(fundManager).transfer( address(this).balance );
    success = true;
  }

  function getAmountLoaned( address lender, address lentToken ) external view returns ( uint256 amountLoaned ) {
    amountLoaned = amountLoanedForLoanedTokenForLender[lender][lentToken];
  }

  function emergencyWithdraw( address token ) external onlyOwner() returns ( bool success ) {
    IERC20(token).safeTransfer( msg.sender, IERC20(token).balanceOf( address(this) ) );
    totalLoanedForToken[token] = 0;
    success = true;
  }

  function emergencyWithdraw() external onlyOwner() returns ( bool success ) {
    payable(msg.sender).transfer( address(this).balance );
    success = true;
  }

}