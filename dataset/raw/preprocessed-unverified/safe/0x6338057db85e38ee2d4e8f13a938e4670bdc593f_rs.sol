/**
 *Submitted for verification at Etherscan.io on 2021-02-06
*/

/*
    MIA Presale SmartContract
*/

pragma solidity ^0.7.0;
//SPDX-License-Identifier: UNLICENSED



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


contract MIAPresale is Context, ReentrancyGuard {
    using SafeMath for uint;
    IERC20 public ABS;
    
    uint public tokensBought;
    bool public isStopped = false;
    bool public presaleStarted = false;

    address payable owner;
    address public pool;
    
    uint256 public ethSent;
    uint256 constant tokensPerETH = 14000;
    mapping(address => uint) ethSpent;
    
     modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    
    constructor() {
        owner = msg.sender; 
    }
    
    
    receive() external payable {
        buyTokens();
    }

    function setABS(IERC20 addr) external onlyOwner nonReentrant {
        //require(ABS == IERC20(address(0)), "You can set the address only once");
        ABS = addr;
    }
    
    function startPresale() external onlyOwner { 
        presaleStarted = true;
    }
    
     function pausePresale() external onlyOwner { 
        presaleStarted = false;
    }
    
    function returnUnsoldTokensToOwner(uint256 amount) external onlyOwner {  
        ABS.transfer(msg.sender, amount); 
    }

    function buyTokens() public payable nonReentrant {
        require(msg.sender == tx.origin);
        require(presaleStarted == true, "Presale is paused, do not send ETH");
        require(ABS != IERC20(address(0)), "Main contract address not set");
        require(!isStopped, "Presale stopped by contract, do not send ETH");
        
        // You could add here a reentry guard that someone doesnt buy twice
        // like 
        //require (ethSpent[msg.sender] <= 1 ether);
        
        
        //MIA: 3 ETH limit
        //require(msg.value <= 3 ether, "You sent more than 3 ETH");
        require(msg.value <= 3 ether, "You sent more than 3 ETH");

        //MIA: presale cap
        require(ethSent < 30 ether, "Hard cap reached");
        require (msg.value.add(ethSent) <= 30 ether, "Hardcap reached");

        //MIA: 3 ETH limit
        require(ethSpent[msg.sender].add(msg.value) <= 3 ether, "You cannot buy more than 3 ETH");

        uint256 tokens = msg.value.mul(tokensPerETH)/1e9;
        require(ABS.balanceOf(address(this)) >= tokens, "Not enough tokens in the contract");
        ethSpent[msg.sender] = ethSpent[msg.sender].add(msg.value);
        tokensBought = tokensBought.add(tokens);
        ethSent = ethSent.add(msg.value);
        ABS.transfer(msg.sender, tokens);
    }
   
    function userEthSpenttInPresale(address user) external view returns(uint){
        return ethSpent[user];
    }
    
    function claimTeamETH() external onlyOwner  {
       uint256 amountETH = address(this).balance;
       owner.transfer(amountETH);
    }

}


