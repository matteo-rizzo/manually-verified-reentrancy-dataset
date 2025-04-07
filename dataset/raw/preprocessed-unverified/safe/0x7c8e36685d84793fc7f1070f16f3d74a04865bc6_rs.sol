/**
 *Submitted for verification at Etherscan.io on 2021-03-08
*/

/**
 *Submitted for verification at BscScan.com on 2021-02-20
*/

pragma solidity ^0.5.9;







contract DUNKBuying{
    
    using SafeMath for uint256;
    AggregatorV3Interface internal priceFeed;
    MU_DANK dunk;
     
    mapping(address=>uint256)public _balances;
    
    address payable public owner;

     uint256 public softcap=1500000;
     uint256 public hardcap=4000000;
     uint256 public tokensold;
     uint256 public starttime;
    bool public buying = true;

    modifier onlyOwner() {
        require(msg.sender==owner);
        _;
    }
    
    modifier toBuy(){
        require(buying == true,"bfiToken buying paused by owner.");
        _;
    }
    
    constructor(address payable _owner) public{
        owner = _owner;
        dunk = MU_DANK(0x9Ea1Ae46C15a4164B74463Bc26f8aA3b0EeA2e6E); 
        priceFeed = AggregatorV3Interface(0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46);
        starttime=block.timestamp;
    }
    
    function changeOwner(address payable _newOwner) public onlyOwner returns(bool) {
        owner = _newOwner;
        return true;
    }
    
    
    
    
    
    function () payable external {
        
    }
    
    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    
    function getLatestPrice(uint256 amount) public view returns (uint256) {
        (,int price,,,) = priceFeed.latestRoundData();
        
        return (uint256(price).div(10).mul(amount));
    }
    
    function buy(uint256 _amount) public payable toBuy returns(bool){
        require(_amount > 0 , "Amount can not be zero.");
        require(msg.value==getLatestPrice(_amount),"incorrect value");
        _balances[msg.sender]=_balances[msg.sender].add(_amount*1e18);
        tokensold=tokensold.add(_amount);
        return true;
    }
    function claim()public returns(bool){
        require(_balances[msg.sender]>0);
        require(block.timestamp>starttime.add(6 days),"you cannot sell under the selling time");
        dunk.transferFrom(owner, msg.sender, _balances[msg.sender]);
        _balances[msg.sender]=0;
        return true;
    }
    
    function sellback(uint256 _amount)public returns(bool){
        require(block.timestamp>starttime.add(6 days),"you cannot sell under the selling time");
        require(tokensold<softcap,"sale hits the hardcap so you cannot sellback it");
        dunk.transferFrom(msg.sender, owner, _amount*1e18);
        msg.sender.transfer(_balances[msg.sender].mul(10));
        return true;
    }
    
    
    function transferFunds(uint256 _amount) external onlyOwner returns(bool){
        require(_amount <= getContractBalance(),"not enough balance in the contract.");
        owner.transfer(_amount);       
        return true;
        
    }
    
     
}

