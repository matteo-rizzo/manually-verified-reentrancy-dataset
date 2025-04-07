/**
 *Submitted for verification at Etherscan.io on 2021-05-06
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.6.12;









contract Crowdsale {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private _token;
    uint256 public totalEthCollected;
    address payable private _wallet;

    uint256 private _rate;

    uint256 private _weiRaised;
    
    address owner;
    bool public _toggle = true;
    mapping (address => uint256) public tokensPerAddress;
    mapping (address => uint256) public tokensPaid;

    mapping (address => bool) public exist;
    uint8 public months = 0;
    address[] public investors;
    event TokensPurchased(address indexed purchaser, uint256 value, uint256 amount);

    constructor () public {
        _rate = 119000;
        _wallet = 0x3c4005Fe464A23fB63C4F1F8269d3b6E8BD1DA0d;
        _token = IERC20(0x97219702d8350FA7b2D49ACe60ce6DDca273FF2c);
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
    function toggle() external onlyOwner{
        if(_toggle){
            _toggle = false;
            return;
        }
        _toggle = true;
    }
 
    function buyTokens() public payable {
        require(_toggle == true);
        require(msg.value >= 0.5 ether, 'less than minimum limit');
        require(tokensPerAddress[msg.sender].add(msg.value) <= 3 ether, 'max limit reached');
        address sender = msg.sender;
        if(!exist[sender]){
            exist[sender] = true;
            investors.push(sender);
        }
        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);
        totalEthCollected = totalEthCollected + weiAmount;
        // update state
        _weiRaised = _weiRaised.add(weiAmount);
        tokensPerAddress[sender] += tokens;
        //_deliverTokens(sender ,tokens);
        emit TokensPurchased(msg.sender, weiAmount, tokens);

        _forwardFunds();
    }
    function distribute() external onlyOwner{
        require(months <=14);
        for(uint256 i =0; i < investors.length; i++){
            _deliverTokens(investors[i], tokensPerAddress[investors[i]].div(14));
            tokensPaid[investors[i]] += tokensPerAddress[investors[i]].div(14);
        }
        months +=1;
    }
    function resetMonths(uint8 _num) external onlyOwner{
        months = _num;
    } 
    function _deliverTokens(address sender, uint256 tokenAmount) internal {
        _token.safeTransfer(sender, tokenAmount);
    }

    
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_rate);
    }
    
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
    
    function endIco(address _address) public onlyOwner{
        _token.transfer(_address, remainingTokens());
    }
}