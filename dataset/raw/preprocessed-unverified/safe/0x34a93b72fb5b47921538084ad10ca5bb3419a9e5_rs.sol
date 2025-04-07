/**
 *Submitted for verification at Etherscan.io on 2021-04-05
*/

/**
 *Submitted for verification at BscScan.com on 2021-03-28
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.6.12;









contract Crowdsale {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    address payable private _wallet = 0x5cDC8AC3e5aEA29cDf7fa62ac8Dd5dE475F7384a;
    address payable private ceo = 0x5cDC8AC3e5aEA29cDf7fa62ac8Dd5dE475F7384a;
    address payable private fas = 0x2F7dCf9414A1D1f2E83f36a828a00DE48F962a1c;
    address payable private tresor = 0x122611B0AffBaFAB0fa9c68c790194517633d2eB;
    address payable private dev = 0x80D45fC9fA18213b9d4f6A70641012Bc1c7CFaB1;
    address payable private staking = 0x81E690Ab07a12EF57C17979E90eb34446754a751;

    uint256 public totalBNBCollected;
    mapping(address => uint256) public investments;
    mapping(address => bool) public exist;
    address payable [] public investors;
    uint256 public target = 500000000000000000000000;

    IERC20 private _token;

    uint256 private _rate;

    uint256 private _weiRaised;
    
    address owner;
    

    event TokensPurchased(address indexed purchaser, uint256 value);

    constructor () public {
        _rate = 1667;
        _wallet = msg.sender;
        _token = IERC20(0x578ADce0eB5A6E5Df371E5089214e0880Ae62b82);
        owner = msg.sender;
    }
modifier onlyOwner(){
    require(msg.sender == owner, 'only Owner can run this function');
    _;
}
    receive() external payable {
        buyTokens();
    }

    function token() public view returns (IERC20) {
        return _token;
    }

    function wallet() public view returns (address) {
        return _wallet;
    }

    function rate() public view returns (uint256) {
        return _rate;
    }
    function remainingTokens() public view returns (uint256) {
        return _token.balanceOf(address(this));
    }

    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }
    function changeRate(uint256 price) public onlyOwner() returns(bool success) {
        _rate = price;
        return success;
    }
    

    function buyTokens() public payable {
       // require(msg.value >= 0.5 ether && msg.value <= 10 ether);
        address payable sender = msg.sender;
        uint256 weiAmount = (msg.value);
        if(!exist[sender]){
            investors.push(sender);
            exist[sender] = true;
        }
        totalBNBCollected = totalBNBCollected + msg.value;
        investments[sender] = investments[sender] + msg.value;

        // calculate token amount to be created
        // update state
        _weiRaised = _weiRaised.add(weiAmount);

        emit TokensPurchased(msg.sender, weiAmount);

    }

    function _deliverTokens(address sender, uint256 tokenAmount) internal {
        _token.safeTransfer(sender, tokenAmount);
    }

    
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_rate);
    }
    
    function endIco() public onlyOwner{
        if(totalBNBCollected >= target){
            for(uint256 i = 0; i < investors.length; i++){
                address investor = investors[i];
                uint256 investment = investments[investor];
                uint256 numberOfTokens = _getTokenAmount(investment);
                delete investors[i];
                investments[investor] = 0;
                exist[investor] = false;
                totalBNBCollected = 0;
                _token.transfer(investor, numberOfTokens);
            }
            uint256 balance = address(this).balance;
            ceo.transfer((balance.div(100)).mul(10));
            fas.transfer((balance.div(100)).mul(10));
            dev.transfer((balance.div(100)).mul(40));
            tresor.transfer((balance.div(100)).mul(30));
            staking.transfer((balance.div(100)).mul(10));
            //.transfer(_address, remainingTokens());
            return;
            
        }
        for(uint256 j =0; j < investors.length; j++){
             address payable investor = investors[j];
            uint256 investment = investments[investor];
            investor.transfer(investment);
            delete investors[j];
            investments[investor] = 0;
            exist[investor] = false;
            totalBNBCollected = 0;
        }
        
    }
    
    function changeTarget(uint256 _target) external onlyOwner{
        target = _target;
    }
    function getTokens() external onlyOwner returns(bool){
        _token.transfer(_wallet, remainingTokens());
        return true;
    }
}