/**
 *Submitted for verification at Etherscan.io on 2021-02-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;









contract hETHVaultV1_2 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    uint256 public totalDeposit;

    address payable public feeAddress;
    address payable public adminAddress;
    string public vaultName;
    uint32 public depositFeePermill = 69;
    uint32 public withdrawFeePermill = 69;
    address public gov;
    
    event Deposited(address indexed user, uint256 amount, string htrAddress, uint256 entryFeeAmount);
    event Withdrawn(address indexed user, uint256 amount, string htrAddress, uint256 estimatedFeeAmount, uint256 exitFeeAmount);
    
    constructor (address payable _adminAddress, address payable _feeAddress, string memory _vaultName) {
        adminAddress = _adminAddress;
        feeAddress = _feeAddress;
        vaultName = _vaultName;
        gov = msg.sender;
    }
    
    modifier onlyGov() {
        require(msg.sender==gov, "!governance");
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender==adminAddress, "!admin");
        _;
    }
    
    function setGovernance(address _gov)
        external
        onlyGov
    {
        gov = _gov;
    }
    
    function setFeeAddress(address payable _feeAddress)
        external
        onlyGov
    {
        feeAddress = _feeAddress;
    }
    
    function setAdminAddress(address payable _adminAddress)
        external
        onlyGov
    {
        adminAddress = _adminAddress;
    }
    
    function setVaultName(string memory _vaultName)
        external
        onlyGov
    {
        vaultName = _vaultName;
    }
    
    function setDepositFeePermill(uint32 _feePermill)
        external
        onlyGov
    {
        depositFeePermill = _feePermill;    
    }
    
    function setWithdrawFeePermill(uint32 _feePermill)
        external
        onlyGov
    {
        withdrawFeePermill = _feePermill;    
    }
    
    function deposit(string memory _htrAddress) external payable {
        require(msg.value > 0, "can't deposit 0");
        uint256 _amount = msg.value;
        
        uint256 _feeAmount = _amount.mul(depositFeePermill).div(10000);
        uint256 _returnAmount = _amount.sub(_feeAmount) % (10 ** 16);
        uint256 _realAmount = _amount.sub(_feeAmount).sub(_returnAmount);
        
        require(_realAmount > 0, "can't deposit less than 0.01");
        
        if (!feeAddress.send(_feeAmount)) {
            feeAddress.transfer(_feeAmount);
        }
        if (!msg.sender.send(_returnAmount)) {
            msg.sender.transfer(_returnAmount);
        }
        
        totalDeposit = totalDeposit.add(_realAmount);
        emit Deposited(msg.sender, _realAmount, _htrAddress, _feeAmount);
    }
    
    function withdraw(uint256 _amount, uint256 _estimatedGasFeeAmount, address payable _receiverAddress, string memory _htrAddress)
        external
        onlyAdmin
    {
        require(_amount > 0, "can't withdraw 0");

        require(_amount >= address(this).balance, "!balance");
        require(_amount > _estimatedGasFeeAmount, "!gasfee");
        
        uint256 _tmpAmount = _amount.sub(_estimatedGasFeeAmount);
        uint256 _feeAmount = _tmpAmount.mul(withdrawFeePermill).div(10000);
        uint256 _realAmount = _tmpAmount.sub(_feeAmount);
        
        if (!feeAddress.send(_feeAmount)) {
            feeAddress.transfer(_feeAmount);
        }
        if (!_receiverAddress.send(_realAmount)) {
            _receiverAddress.transfer(_realAmount);
        }
        if (!adminAddress.send(_estimatedGasFeeAmount)) {
            adminAddress.transfer(_estimatedGasFeeAmount);
        }
        
        totalDeposit = totalDeposit.sub(_amount);
        emit Withdrawn(_receiverAddress, _realAmount, _htrAddress, _estimatedGasFeeAmount, _feeAmount);
    }
}