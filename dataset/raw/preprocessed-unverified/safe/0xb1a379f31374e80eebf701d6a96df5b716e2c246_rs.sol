/**
 *Submitted for verification at Etherscan.io on 2021-05-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;  

abstract contract IDFSRegistry {
 
    function getAddr(bytes32 _id) public view virtual returns (address);

    function addNewContract(
        bytes32 _id,
        address _contractAddr,
        uint256 _waitPeriod
    ) public virtual;

    function startContractChange(bytes32 _id, address _newContractAddr) public virtual;

    function approveContractChange(bytes32 _id) public virtual;

    function cancelContractChange(bytes32 _id) public virtual;

    function changeWaitPeriod(bytes32 _id, uint256 _newWaitPeriod) public virtual;
}  

  

  



  

contract AdminVault {
    address public owner;
    address public admin;

    constructor() {
        owner = msg.sender;
        admin = 0xac04A6f65491Df9634f6c5d640Bcc7EfFdbea326;
    }

    /// @notice Admin is able to change owner
    /// @param _owner Address of new owner
    function changeOwner(address _owner) public {
        require(admin == msg.sender, "msg.sender not admin");
        owner = _owner;
    }

    /// @notice Admin is able to set new admin
    /// @param _admin Address of multisig that becomes new admin
    function changeAdmin(address _admin) public {
        require(admin == msg.sender, "msg.sender not admin");
        admin = _admin;
    }
} 


/// @title AdminAuth Handles owner/admin priviligies over smart contracts
contract AdminAuth {
    using SafeERC20 for IERC20;

    AdminVault public adminVault = AdminVault(0x808231F6799ac3DF84DE0ddF792B71714d5b1F77);

    modifier onlyOwner() {
        require(adminVault.owner() == msg.sender, "msg.sender not owner");
        _;
    }

    modifier onlyAdmin() {
        require(adminVault.admin() == msg.sender, "msg.sender not admin");
        _;
    }

    /// @notice  withdraw stuck funds
    function withdrawStuckFunds(address _token, address _receiver, uint256 _amount) public onlyOwner {
        if (_token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(_receiver).transfer(_amount);
        } else {
            IERC20(_token).safeTransfer(_receiver, _amount);
        }
    }

    /// @notice Destroy the contract
    function kill() public onlyAdmin {
        selfdestruct(payable(msg.sender));
    }

    /// @notice Changes the admin vault that is currently used
    /// @param _newAdminVault Address of the new Admin Vault contract
    function changeAdminVault(address _newAdminVault) public onlyAdmin {
        adminVault = AdminVault(_newAdminVault);
    }
}


/// @title Stores the fee recipient address and allows the owner to change it
contract FeeRecipient is AdminAuth {

    address public wallet;

    constructor(address _newWallet) public {
        wallet = _newWallet;
    }

    function getFeeAddr() public view returns (address) {
        return wallet;
    }

    function changeWalletAddr(address _newWallet) public onlyOwner {
        wallet = _newWallet;
    }
}