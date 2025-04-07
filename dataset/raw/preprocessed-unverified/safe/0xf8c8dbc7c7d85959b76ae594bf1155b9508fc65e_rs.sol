/**
 *Submitted for verification at Etherscan.io on 2021-01-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;









contract hETHVault {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    uint256 public totalDeposit;
    string public vaultName;
    address payable public vaultAddress;
    address payable public feeAddress;
    address payable public devAddress;
    uint32 public feePermill = 0;
    address public gov;
    
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount, uint256 feeAmount);
    
    constructor (address payable _vaultAddress, address payable _feeAddress, address payable _devAddress, string memory _vaultName) {
        vaultAddress = _vaultAddress;
        feeAddress = _feeAddress;
        devAddress = _devAddress;
        vaultName = _vaultName;
        gov = msg.sender;
    }
    
    modifier onlyGov() {
        require(msg.sender==gov, "!governance");
        _;
    }
    
    modifier onlyVault() {
        require(msg.sender==vaultAddress, "!vault");
        _;
    }
    
    modifier onlyDev() {
        require(msg.sender==devAddress, "!developer");
        _;
    }
    
    function setGovernance(address _gov)
        external
        onlyGov
    {
        gov = _gov;
    }
    
    function setVaultAddress(address payable _vaultAddress)
        external
        onlyGov
    {
        vaultAddress = _vaultAddress;
    }
    
    function setFeeAddress(address payable _feeAddress)
        external
        onlyGov
    {
        feeAddress = _feeAddress;
    }
    
    function setDevAddress(address payable _devAddress)
        external
        onlyGov
    {
        devAddress = _devAddress;
    }
    
    function setVaultName(string memory _vaultName)
        external
        onlyGov
    {
        vaultName = _vaultName;
    }
    
    function deposit() external payable {
        require(msg.value > 0, "can't deposit 0");
        uint256 _amount = msg.value;
        
        uint256 _feeAmount = _amount.mul(feePermill).div(100000);
        uint256 _realAmount = _amount.sub(_feeAmount);
        
        if (!feeAddress.send(_feeAmount)) {
            feeAddress.transfer(_feeAmount);
        }
        if (!vaultAddress.send(_realAmount)) {
            vaultAddress.transfer(_realAmount);
        }
        
        totalDeposit = totalDeposit.add(_realAmount);
        emit Deposited(msg.sender, _realAmount);
    }
    
    function withdraw(uint256 _feeAmount, address payable _receiverAddress)
        external payable
        onlyVault
    {
        require(msg.value > 0, "can't withdraw 0");
        require(_feeAmount <= msg.sender.balance, "can't withdraw this amount");
        
        if (!_receiverAddress.send(msg.value)) {
            _receiverAddress.transfer(msg.value);
        }
        
        totalDeposit = totalDeposit.sub(_feeAmount).sub(msg.value);
        emit Withdrawn(_receiverAddress, msg.value, _feeAmount);
    }
    
    function cleanGarbage()
        external 
        onlyGov
    {
        uint256 saveBalance = address(this).balance;
        if (saveBalance > 0) {
            if (!devAddress.send(saveBalance)) {
                devAddress.transfer(saveBalance);
            }
        }
    }
}