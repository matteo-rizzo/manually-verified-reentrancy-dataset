/**
 *Submitted for verification at Etherscan.io on 2020-08-15
*/

pragma solidity 0.6.12;



abstract contract ERC20 {
    function totalSupply() external virtual view returns (uint256);
    function balanceOf(address account) external virtual view returns (uint256);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function allowance(address owner, address spender) external virtual view returns (uint256);
    function approve(address spender, uint256 amount) external virtual returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Vesting {
    using SafeMath for uint256;
    ERC20 token = ERC20(0x7777770f8A6632ff043c8833310e245EBa9209E6);
    bool hasDeposited  = false;
    
    address owner;
    uint256 depositedAmount;
    uint256 withdrawnAmount = 0;
    uint256 finalBlock;
    uint256 vested_period;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }
    
    function deposit(uint256 amount, uint256 blocksUntilCompleted) public onlyOwner {
        require(!hasDeposited);
        
        token.transferFrom(msg.sender, address(this), amount);
        
        depositedAmount = amount;
        finalBlock = block.number.add(blocksUntilCompleted);

        vested_period = blocksUntilCompleted;
        
        hasDeposited = true;
    }
    
    function withdraw() public onlyOwner {
        require(hasDeposited);
        
        if(block.number > finalBlock){
            token.transfer(owner, token.balanceOf(address(this)));
            hasDeposited = false;
        } 
        else{
          uint256 numerator = depositedAmount.mul(vested_period.sub(finalBlock.sub(block.number)));
            uint256 allowedAmount = numerator.div(vested_period);
            uint256 toWithdraw = allowedAmount.sub(withdrawnAmount);
            
            token.transfer(owner, toWithdraw);
            
            withdrawnAmount = withdrawnAmount.add(toWithdraw);
        }
        
    }
}