/**
 *Submitted for verification at Etherscan.io on 2021-07-01
*/

// SPDX-License-Identifier: MIT


pragma solidity 0.8.2;









abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract POLCBridgeTransfers is Context {
    event BridgeTransfer(address indexed from, address indexed to, uint256 amount, uint256 gasFee);

    address payable public bankVault;
    address public feesVault;
    address public polcTokenAddress;
    uint256 public bridgeFee;
    uint256 public gasFee;
    IERC20Token private polcToken;
    POLCProfits public profitsContract;
    mapping (uint8 => address) public managers;
    mapping (bytes32 => bool) public executedTask;

    uint16 public taskIndex;
    
    modifier isManager() {
        require(managers[0] == msg.sender || managers[1] == msg.sender || managers[2] == msg.sender, "Not manager");
        _;
    }
    
    constructor() {
        polcTokenAddress = 0xaA8330FB2B4D5D07ABFE7A72262752a8505C6B37;
        polcToken = IERC20Token(polcTokenAddress);
        bankVault = payable(0xf7A9F6001ff8b499149569C54852226d719f2D76);
        feesVault = 0xf7A9F6001ff8b499149569C54852226d719f2D76;
        
        managers[0] = msg.sender;
        managers[1] = 0xeA50CE6EBb1a5E4A8F90Bfb35A2fb3c3F0C673ec;
        managers[2] = 0xB1A951141F1b3A16824241f687C3741459E33225;
        bridgeFee = 1;
        gasFee = (1 gwei)*70000;
    }

    function bridgeSend(address _receiver, uint256 _amount) public payable returns (bool) {
        require((_amount>=(50 ether) && _amount<=(50000 ether)), "Invalid amount");
        require(msg.value >= gasFee, "Invalid gas fee");
        uint256 fee;
        if (bridgeFee > 0) {
            fee = (_amount * bridgeFee) /100;  // bridge transaction fee
            profitsContract.addBankEarnings((fee / 20)); //25% of the fees goes to bank hodlers, 5 banks = 5% each
        }
        uint256 transferAmount = _amount-fee;
        Address.sendValue(bankVault, msg.value);
        require(polcToken.transferFrom(msg.sender, feesVault, _amount));
        emit BridgeTransfer(msg.sender, _receiver, transferAmount, msg.value);
        return true;
    }
    
    function setBankVault(address _vault, bytes memory _sig) public isManager {
        uint8 mId = 1;
        bytes32 taskHash = keccak256(abi.encode(_vault, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        bankVault = payable(_vault);
    }
    
    function setFeesVault(address _vault, bytes memory _sig) public isManager {
        uint8 mId = 2;
        bytes32 taskHash = keccak256(abi.encode(_vault, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        feesVault = _vault;
    }
    
    function setFee(uint256 _fee, bytes memory _sig) public isManager {
        uint8 mId = 3;
        bytes32 taskHash = keccak256(abi.encode(_fee, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        bridgeFee = _fee;   
    }
    
    function setProfitsContract(address _contract, bytes memory _sig) public isManager {
        uint8 mId = 4;
        bytes32 taskHash = keccak256(abi.encode(_contract, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        profitsContract = POLCProfits(_contract);
    }

    function setGasFee(uint256 _fee, bytes memory _sig) public isManager {
        uint8 mId = 5;
        bytes32 taskHash = keccak256(abi.encode(_fee, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        gasFee = _fee;
    }
    
    function verifyApproval(bytes32 _taskHash, bytes memory _sig) private {
        require(executedTask[_taskHash] == false, "Task already executed");
        address mSigner = ECDSA.recover(ECDSA.toEthSignedMessageHash(_taskHash), _sig);
        require(mSigner == managers[0] || mSigner == managers[1] || mSigner == managers[2], "Invalid signature"  );
        require(mSigner != msg.sender, "Signature from different managers required");
        executedTask[_taskHash] = true;
        taskIndex += 1;
    }
    
    function changeManager(address _manager, uint8 _index, bytes memory _sig) public isManager {
        require(_index >= 0 && _index <= 2, "Invalid index");
        uint8 mId = 100;
        bytes32 taskHash = keccak256(abi.encode(_manager, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        managers[_index] = _manager;
    }
    

    
}