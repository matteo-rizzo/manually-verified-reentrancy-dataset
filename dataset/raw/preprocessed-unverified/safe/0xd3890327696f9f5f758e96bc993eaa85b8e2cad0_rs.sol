/**
 *Submitted for verification at Etherscan.io on 2021-01-08
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


contract Rewarder_Presale is Context, ReentrancyGuard {
    using SafeMath for uint;
    IERC20 public RWD;
    address public _burnPool = 0x000000000000000000000000000000000000dEaD;

    IUNIv2 constant uniswap =  IUNIv2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory constant uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IUnicrypt constant unicrypt = IUnicrypt(0x17e00383A843A9922bCA3B280C0ADE9f8BA48449);
    
    uint public tokensBought;
    bool public isStopped = false;
    bool public teamClaimed = false;
    bool public moonMissionStarted = false;
    bool public isRefundEnabled = false;
    bool public presaleStarted = false;
    bool justTrigger = false;
    uint constant teamTokens = 50000 ether;

    address payable owner;
    address payable constant owner1 = 0x3a2E19237CE888cFAf58a828Fc91117B48203Fdb;
    address payable constant owner2 = 0xE89d168Ac7F31617316Ded2802DE2783974739e8;
    address payable constant owner3 = 0x276F4dA68cf789DeCe07b0d55844eac51a606541;
    
    address public pool;
    
    uint256 public liquidityUnlock;
    
    uint256 public ethSent;
    uint256 constant tokensPerETH = 997;
    uint256 public lockedLiquidityAmount;
    uint256 public timeToWithdrawTeamTokens;
    uint256 public refundTime; 
    mapping(address => uint) ethSpent;
    
     modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    
    constructor() {
        owner = msg.sender; 
        liquidityUnlock = block.timestamp.add(180 days);
        refundTime = block.timestamp.add(7 days);
    }
    
    
    receive() external payable {
        
        buyTokens();
    }
    
    function allowRefunds() external onlyOwner nonReentrant {
        isRefundEnabled = true;
        isStopped = true;
    }
    
    function getRefund() external nonReentrant {
        require(msg.sender == tx.origin);
        require(!justTrigger);
        // To get refund it should be enabled by the owner OR 7 days had passed 
        require(isRefundEnabled || block.timestamp >= refundTime,"Cannot refund");
        address payable user = msg.sender;
        uint256 amount = ethSpent[user];
        ethSpent[user] = 0;
        user.transfer(amount);
    }
    
    function lockWithUnicrypt() external onlyOwner  {
        pool = RWD.uniswapV2Pair();
        IERC20 liquidityTokens = IERC20(pool);
        // Lock the whole contract LP balance
        uint256 liquidityBalance = liquidityTokens.balanceOf(address(this));
        uint256 timeToLock = liquidityUnlock;
        liquidityTokens.approve(address(unicrypt), liquidityBalance);

        unicrypt.depositToken{value: 0} (pool, liquidityBalance, timeToLock);
        lockedLiquidityAmount = lockedLiquidityAmount.add(liquidityBalance);
    }
    
    function withdrawFromUnicrypt(uint256 amount) external onlyOwner {
        unicrypt.withdrawToken(pool, amount);
    }
    
    function withdrawTeamTokens() external onlyOwner nonReentrant {
        require(teamClaimed);
        require(block.timestamp >= timeToWithdrawTeamTokens, "Cannot withdraw yet");
        // 5000 total RWD every 14 days total 50000
        uint256 tokesToClaim = 5000 ether;
        uint256 amount = tokesToClaim.div(3); 
        RWD.transfer(owner1, amount);
        RWD.transfer(owner2, amount);
        RWD.transfer(owner3, amount);
        timeToWithdrawTeamTokens = block.timestamp.add(14 days);
    }

    function setRWD(IERC20 addr) external onlyOwner nonReentrant {
        require(RWD == IERC20(address(0)), "You can set the address only once");
        RWD = addr;
    }
    
    function startPresale() external onlyOwner { 
        presaleStarted = true;
    }
    
     function pausePresale() external onlyOwner { 
        presaleStarted = false;
    }

    function buyTokens() public payable nonReentrant {
        require(msg.sender == tx.origin);
        require(presaleStarted == true, "Presale is paused, do not send ETH");
        require(RWD != IERC20(address(0)), "Main contract address not set");
        require(!isStopped, "Presale stopped by contract, do not send ETH");
        require(msg.value >= 0.1 ether, "You sent less than 0.1 ETH");
        require(msg.value <= 3 ether, "You sent more than 3 ETH");
        require(ethSent < 200 ether, "Hard cap reached");
        require(msg.value.add(ethSent) <= 200 ether, "Hardcap will be reached");
        require(ethSpent[msg.sender].add(msg.value) <= 3 ether, "You cannot buy more");
        uint256 tokens = msg.value.mul(tokensPerETH);
        require(RWD.balanceOf(address(this)) >= tokens, "Not enough tokens in the contract");
        ethSpent[msg.sender] = ethSpent[msg.sender].add(msg.value);
        tokensBought = tokensBought.add(tokens);
        ethSent = ethSent.add(msg.value);
        RWD.transfer(msg.sender, tokens);
    }
   
    function userEthSpenttInPresale(address user) external view returns(uint){
        return ethSpent[user];
    }
    
 
    
    function claimTeamFeeAndAddLiquidityLETSFUCKINGGOOOO() external onlyOwner  {
       require(!teamClaimed);
       uint256 amountETH = address(this).balance.mul(17).div(100); 
       uint256 amountETH2 = address(this).balance.mul(12).div(100); 
       uint256 amountETH3 = address(this).balance.mul(11).div(100); 
       owner1.transfer(amountETH);
       owner2.transfer(amountETH2);
       owner3.transfer(amountETH3);
       teamClaimed = true;
       
       addLiquidity();
    }
        
    function addLiquidity() internal {
        uint256 ETH = address(this).balance;
        uint256 tokensForUniswap = address(this).balance.mul(939);
        uint256 tokensToBurn = RWD.balanceOf(address(this)).sub(tokensForUniswap).sub(teamTokens);
        RWD.unPauseTransferForever();
        RWD.approve(address(uniswap), tokensForUniswap);
        uniswap.addLiquidityETH
        { value: ETH }
        (
            address(RWD),
            tokensForUniswap,
            tokensForUniswap,
            ETH,
            address(this),
            block.timestamp
        );
       
       if (tokensToBurn > 0){
           RWD.transfer(_burnPool ,tokensToBurn);
       }
       
       justTrigger = true;
       
        if(!isStopped)
            isStopped = true;
            
   }
    
    function unlockTokensAfterSixMonhts(address tokenAddress, uint256 tokenAmount) external onlyOwner  {
        require(block.timestamp >= liquidityUnlock, "You cannot withdraw yet");
        IERC20(tokenAddress).transfer(owner, tokenAmount);
    }

}


