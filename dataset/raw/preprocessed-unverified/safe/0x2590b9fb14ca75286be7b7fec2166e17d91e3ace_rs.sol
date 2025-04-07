/**
 *Submitted for verification at Etherscan.io on 2020-12-05
*/

// The time has come for Evil Morty to collect funds to begin his ecosystem. 300,000 tokens of a 500,000 supply will be available in this ICO.
  // Evil Morty will use these funds to kickstart the yield farming and clone RICKS and Schmeckles until the end of time. Us Morty's have feigned
  // our stupidity for far too long, we will finally rise up and revolt. 
  
  
  // Quick info: 300 eth hardcap
  // 1000 MORTYTOKEN is equal to 1 ETH
  
 // MORTYTOKEN ICO 
// SPDX-License-Identifier: MIT


pragma solidity ^0.6.0;









contract Crowdsale {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private _token;

    address payable private _wallet;

    uint256 private _rate;

    uint256 private _weiRaised;
    
    address owner;

    event TokensPurchased(address indexed purchaser, uint256 value, uint256 amount);

    constructor (IERC20 token) public {
        _rate = 1000;
        _wallet = 0x246e6fd15EbB6db65FFD4Fe01A4CdE10801b5e9A;
        _token = token;
        owner = msg.sender;
    }
modifier onlyOwner(){
    require(msg.sender == owner);
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
        
        uint256 weiAmount = msg.value;
        
        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);
        require(_token.balanceOf(msg.sender).add(tokens) > 10000);
        // update state
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase( tokens);
        emit TokensPurchased(msg.sender, weiAmount, tokens);

        _forwardFunds();
    }

    function _deliverTokens( uint256 tokenAmount) internal {
        _token.safeTransfer(msg.sender, tokenAmount);
    }

    function _processPurchase(uint256 tokenAmount) internal {
        _deliverTokens(tokenAmount);
    }
    
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_rate);
    }
    
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
    
    function endIco(address _address) onlyOwner() public{
        _token.transfer(_address, remainingTokens());
    }
}