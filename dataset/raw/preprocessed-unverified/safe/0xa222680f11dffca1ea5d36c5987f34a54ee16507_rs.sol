/**
 *Submitted for verification at Etherscan.io on 2019-09-20
*/

pragma solidity 0.5.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract Exchange is Ownable {
    using SafeMath for uint;
    
    // string => per 10000 (% * 100)
    mapping (string => uint) public promoCodes;
    
    uint public fee = 300;
    uint public cxcUnitsPerEth = 100 * 1e18;
    address public cxcTokenAddress = 0xE5E00C5F68bd9922e4Be522b8f18bBD0CaeD0C94;
    
    function setCxcTokenAddress(address _addr) public onlyOwner {
        cxcTokenAddress = _addr;
    }
    
    function setPromoCode(string memory code, uint discountPercentInto100) public onlyOwner {
        promoCodes[code] = discountPercentInto100;
    }
    
    function setFee(uint _fee) public onlyOwner {
        require(_fee < 10000);
        fee = _fee;
    }
    
    function setCxcUnitsPerEth(uint _cxcUnitsPerEth) public onlyOwner {
        cxcUnitsPerEth = _cxcUnitsPerEth;
    }
    
    function getCxcUnitsPerEth_eth_to_cxc() public view returns (uint) {
        return cxcUnitsPerEth.sub(cxcUnitsPerEth.mul(fee).div(1e4));
    }
    
    function getCxcUnitsPerEth_cxc_to_eth() public view returns (uint) {
        return cxcUnitsPerEth.add(cxcUnitsPerEth.mul(fee).div(1e4));
    } 
    
    function () external payable {
        // accept ETH
    }
    
    function withdrawAllEth() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
    
    function exchangeCxcToEth(string memory promo) public {
        token tokenReward = token(cxcTokenAddress);
        uint allowance = tokenReward.allowance(msg.sender, address(this));
        require(allowance > 0 && tokenReward.transferFrom(msg.sender, owner, allowance));
        
        uint _cxcUnitsPerEth = getCxcUnitsPerEth_cxc_to_eth();
        uint weiToSend = allowance.mul(1e18).div(_cxcUnitsPerEth);
        if (promoCodes[promo] > 0) {
            weiToSend = weiToSend.add(weiToSend.mul(promoCodes[promo]).div(1e4));
        }
        msg.sender.transfer(weiToSend);
    }
}