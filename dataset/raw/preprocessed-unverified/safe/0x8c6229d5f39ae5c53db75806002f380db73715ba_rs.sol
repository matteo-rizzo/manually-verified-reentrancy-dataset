/**
 *Submitted for verification at Etherscan.io on 2021-02-20
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



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



contract PreOlympusSales is Ownable {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  event SaleStarted( address indexed activator, uint256 timestamp );
  event SaleEnded( address indexed activator, uint256 timestamp );
  event SellerApproval( address indexed approver, address indexed seller, string indexed message );

  IERC20 public dai;

  IERC20 public pOly;

  address private _saleProceedsAddress;

  uint256 public pOlyPrice;

  bool public initialized;

  mapping( address => bool ) public approvedBuyers;

  constructor() {}
    
  function initialize( 
    address pOly_, 
    address dai_,
    uint256 pOlyPrice_,
    address saleProceedsAddress_
  ) external onlyOwner {
    require( !initialized );
    pOly = IERC20( pOly_ );
    dai = IERC20( dai_ );
    pOlyPrice = pOlyPrice_;
    _saleProceedsAddress = saleProceedsAddress_;
    initialized = true;
  }

  function setPOlyPrice( uint256 newPOlyPrice_ ) external onlyOwner() returns ( uint256 ) {
    pOlyPrice = newPOlyPrice_;
    return pOlyPrice;
  }

  function _approveBuyer( address newBuyer_ ) internal onlyOwner() returns ( bool ) {
    approvedBuyers[newBuyer_] = true;
    return approvedBuyers[newBuyer_];
  }

  function approveBuyer( address newBuyer_ ) external onlyOwner() returns ( bool ) {
    return _approveBuyer( newBuyer_ );
  }

  function approveBuyers( address[] calldata newBuyers_ ) external onlyOwner() returns ( uint256 ) {
    for( uint256 iteration_ = 0; newBuyers_.length > iteration_; iteration_++ ) {
      _approveBuyer( newBuyers_[iteration_] );
    }
    return newBuyers_.length;
  }

  function _calculateAmountPurchased( uint256 amountPaid_ ) internal returns ( uint256 ) {
    return amountPaid_.mul( pOlyPrice );
  }

  function buyPOly( uint256 amountPaid_ ) external returns ( bool ) {
    require( approvedBuyers[msg.sender], "Buyer not approved." );
    uint256 pOlyAmountPurchased_ = _calculateAmountPurchased( amountPaid_ );
    dai.safeTransferFrom( msg.sender, _saleProceedsAddress, amountPaid_ );
    pOly.safeTransfer( msg.sender, pOlyAmountPurchased_ );
    return true;
  }

  function withdrawTokens( address tokenToWithdraw_ ) external onlyOwner() returns ( bool ) {
    IERC20( tokenToWithdraw_ ).safeTransfer( msg.sender, IERC20( tokenToWithdraw_ ).balanceOf( address( this ) ) );
    return true;
  }
}