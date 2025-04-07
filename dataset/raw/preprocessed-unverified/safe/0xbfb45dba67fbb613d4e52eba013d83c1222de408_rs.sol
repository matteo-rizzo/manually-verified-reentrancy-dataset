/**
 *Submitted for verification at Etherscan.io on 2021-02-06
*/

// File: ../triton/crypto/presaleContract.sol

//                      ▄▄                            
// ███▀▀██▀▀███         ██   ██                       
// █▀   ██   ▀█              ██                       
//      ██    ▀███▄███▀███ ██████  ▄██▀██▄▀████████▄  
//      ██      ██▀ ▀▀  ██   ██   ██▀   ▀██ ██    ██  
//      ██      ██      ██   ██   ██     ██ ██    ██  
//      ██      ██      ██   ██   ██▄   ▄██ ██    ██  
//    ▄████▄  ▄████▄  ▄████▄ ▀████ ▀█████▀▄████  ████▄
                                                   
                                                   

pragma solidity ^0.6.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
*/



// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------



contract TritonPresale is Owned {
    using SafeMath for uint256;
    
    bool public isPresaleOpen;
    address public tokenAddress;
    uint256 public tokenDecimals = 9;
    uint256 public tokenRatePerEth = 10_00;
    uint256 public rateDecimals = 2;
    uint256 public minEthLimit = 100 finney;
    uint256 public maxEthLimit = 1 ether;
    
    mapping(address => uint256) public usersInvestments;
    
    constructor() public {
        owner = msg.sender;
    }
    
    
    receive() external payable{
        require(isPresaleOpen, "Presale is not open.");
        require(
                usersInvestments[msg.sender].add(msg.value) <= maxEthLimit
                && usersInvestments[msg.sender].add(msg.value) >= minEthLimit,
                "Installment Invalid."
            );
        uint256 tokenAmount = getTokensPerEth(msg.value);
        require(IToken(tokenAddress).transfer(msg.sender, tokenAmount), "Insufficient balance of presale contract!");
        usersInvestments[msg.sender] = usersInvestments[msg.sender].add(msg.value);        
        owner.transfer(msg.value);
    }
    
    function getTokensPerEth(uint256 amount) internal view returns(uint256) {
        return amount.mul(tokenRatePerEth).div(
            10**(uint256(18).sub(tokenDecimals).add(rateDecimals))
            );
    }
    
    function burnRemaining() external onlyOwner {
        require(!isPresaleOpen, "You cannot burn tokens untitl the presale is closed.");
        IToken(tokenAddress).burnTokens(IToken(tokenAddress).balanceOf(address(this)));   
    }

        function start() external onlyOwner{
        require(!isPresaleOpen, "Presale is open");
        
        isPresaleOpen = true;
    }
    
    function close() external onlyOwner{
        require(isPresaleOpen, "Presale is not open yet.");
        
        isPresaleOpen = false;
    }
    
    function setToken(address token) external onlyOwner {
        require(tokenAddress == address(0), "Token address is already set.");
        require(token != address(0), "Token address zero not allowed.");
        
        tokenAddress = token;
    }
    
    function setTokenDecimals(uint256 decimals) external onlyOwner {
       tokenDecimals = decimals;
    }
    
    function setMinEthLimit(uint256 amount) external onlyOwner {
        minEthLimit = amount;    
    }
    
    function setMaxEthLimit(uint256 amount) external onlyOwner {
        maxEthLimit = amount;    
    }
    
    function setTokenRatePerEth(uint256 rate) external onlyOwner {
        tokenRatePerEth = rate;
    }
    
    function setRateDecimals(uint256 decimals) external onlyOwner {
        rateDecimals = decimals;
    }
}