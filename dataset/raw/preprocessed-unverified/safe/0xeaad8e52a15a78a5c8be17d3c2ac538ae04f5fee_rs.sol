/**
 *Submitted for verification at Etherscan.io on 2021-03-01
*/

// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;


// 


// 


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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


// 
contract DebtNotifier is IDebtNotifier {
  IGovernanceAddressProvider public override a;
  mapping(address => ISupplyMiner) public override collateralSupplyMinerMapping;

  constructor(IGovernanceAddressProvider _addresses) public {
    require(address(_addresses) != address(0));
    a = _addresses;
  }

  modifier onlyVaultsCore() {
    require(msg.sender == address(a.parallel().core()), "Caller is not VaultsCore");
    _;
  }

  modifier onlyManager() {
    require(a.controller().hasRole(a.controller().MANAGER_ROLE(), msg.sender));
    _;
  }

  /**
    Notifies the correct supplyMiner of a change in debt.
    @dev Only the vaultsCore can call this.
    `debtChanged` will silently return if collateralType is not known to prevent any problems in vaultscore.
    @param _vaultId the ID of the vault of which the debt has changed.
  **/
  function debtChanged(uint256 _vaultId) public override onlyVaultsCore {
    IVaultsDataProvider.Vault memory v = a.parallel().vaultsData().vaults(_vaultId);

    ISupplyMiner supplyMiner = collateralSupplyMinerMapping[v.collateralType];
    if (address(supplyMiner) == address(0)) {
      // not throwing error so VaultsCore keeps working
      return;
    }
    supplyMiner.baseDebtChanged(v.owner, v.baseDebt);
  }

  /**
    Updates the collateral to supplyMiner mapping.
    @dev Manager role in the AccessController is required to call this.
    @param collateral the address of the collateralType.
    @param supplyMiner the address of the supplyMiner which will be notified on debt changes for this collateralType.
  **/
  function setCollateralSupplyMiner(address collateral, ISupplyMiner supplyMiner) public override onlyManager {
    collateralSupplyMinerMapping[collateral] = supplyMiner;
  }
}