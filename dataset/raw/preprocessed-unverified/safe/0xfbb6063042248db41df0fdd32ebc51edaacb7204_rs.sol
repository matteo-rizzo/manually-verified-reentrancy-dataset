/**
 *Submitted for verification at Etherscan.io on 2021-03-10
*/

// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// 


// 


// 
interface ISTABLEX is IERC20 {
  function mint(address account, uint256 amount) external;

  function burn(address account, uint256 amount) external;

  function a() external view returns (IAddressProvider);
}

// 


// 


// 


// 


// 


// 


// 


// 


// 


// 


// 


// 


// 


// 


// 
interface IMIMO is IERC20 {

  function burn(address account, uint256 amount) external;
  
  function mint(address account, uint256 amount) external;

}

// 


// 


// 


// 


// 


// 


// 
contract RepayVault {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  uint256 public constant REPAY_PER_VAULT = 10 ether;

  IAddressProvider public a;

  constructor(IAddressProvider _addresses) public {
    require(address(_addresses) != address(0));

    a = _addresses;
  }

  modifier onlyManager() {
    require(a.controller().hasRole(a.controller().MANAGER_ROLE(), msg.sender), "Caller is not Manager");
    _;
  }

  function repay() public onlyManager {
    IVaultsCore core = a.core();
    IVaultsDataProvider vaultsData = a.vaultsData();
    uint256 vaultCount = a.vaultsData().vaultCount();

    for (uint256 vaultId = 1; vaultId <= vaultCount; vaultId++) {
      uint256 baseDebt = vaultsData.vaultBaseDebt(vaultId);

      //if (vaultId==28 || vaultId==29 || vaultId==30 || vaultId==31 || vaultId==32 || vaultId==33 || vaultId==35){
      //  continue;
      //}

      if (baseDebt == 0) {
        continue;
      }

      core.repay(vaultId, REPAY_PER_VAULT);
    }

    IERC20 par = IERC20(a.stablex());
    par.safeTransfer(msg.sender, par.balanceOf(address(this)));
  }
}