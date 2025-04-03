// Dependency file: contracts/libraries/TransferHelper.sol

// SPDX-License-Identifier: GPL-3.0-or-later

// pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false



// Root file: contracts/DemaxConvert.sol

pragma solidity >=0.5.16;

// import 'contracts/libraries/TransferHelper.sol';



contract DemaxConvert {
    event ConvertETHForBNB(address indexed user, uint amount);
    event ConvertTokenForBNB(address indexed user, address token, uint amount);
    event CollectETH(uint amount);
    event CollectToken(address token, uint amount);
    
    address public owner;
    address public wallet;
    
    address[] public allTokens;
    
    mapping (address => bool) public users;
    
    mapping (address => uint) public tokenLimits;
    
    constructor (address _wallet) public {
        owner = msg.sender;
        wallet = _wallet;
    }
    
    function changeWallet(address _wallet) external {
        require(msg.sender == owner, "FORBIDDEN");
        wallet = _wallet;
    }
    
    function enableToken(address _token, uint _limit) external{
        require(msg.sender == owner, "FORBIDDEN");    
        tokenLimits[_token] = _limit;
        
        bool isAdd = false;
        for(uint i = 0;i < allTokens.length;i++) {
            if(allTokens[i] == _token) {
                isAdd = true;
                break;
            }
        }
        
        if(!isAdd) {
            allTokens.push(_token);
        }
    }
    
    function validTokens() external view returns (address[] memory) {
        uint count;
        for (uint i; i < allTokens.length; i++) {
            if (tokenLimits[allTokens[i]] > 0) {
                count++;
            }
        }
        address[] memory res = new address[](count);
        uint index = 0;
        for (uint i; i < allTokens.length; i++) {
            if (tokenLimits[allTokens[i]] > 0) {
                res[index] = allTokens[i];
                index++;
            }
        }
        return res;
    }
    
    function convertETHForBNB() payable external {
        require(msg.value > 0 && msg.value <= tokenLimits[address(0)], "INVALID_AMOUNT");
        require(users[msg.sender] == false, "ALREADY_CONVERT");
        users[msg.sender] = true;
        emit ConvertETHForBNB(msg.sender, msg.value);
    }
    
    function convertTokenForBNB(address _token, uint _amount) external {
        require(_amount > 0 && _amount <= tokenLimits[_token], "INVALID_AMOUNT");
        require(users[msg.sender] == false, "ALREADY_CONVERT");
        users[msg.sender] = true;
        TransferHelper.safeTransferFrom(_token, msg.sender, address(this), _amount);
        emit ConvertTokenForBNB(msg.sender, _token, _amount);
    }
    
    function collect() external {
        require(msg.sender == owner, "FORBIDDEN");
        for(uint i = 0;i < allTokens.length;i++) {
            uint balance = IERC20(allTokens[i]).balanceOf(address(this));
            if(balance > 0) {
                TransferHelper.safeTransfer(allTokens[i], wallet, balance);
                emit CollectToken(allTokens[i], balance);
            }
        }
        
        if(address(this).balance > 0) {
            emit CollectETH(address(this).balance);
            TransferHelper.safeTransferETH(wallet, address(this).balance);
        }
    }
}