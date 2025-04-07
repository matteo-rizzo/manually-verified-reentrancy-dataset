pragma solidity ^0.4.16;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {

  bool public paused = false;
  bool public finished = false;
  
  modifier whenSaleNotFinish() {
    require(!finished);
    _;
  }

  modifier whenSaleFinish() {
    require(finished);
    _;
  }

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {
    paused = true;
  }

  function unpause() onlyOwner whenPaused public {
    paused = false;
  }
}

contract CCCRSale is Pausable {
    using SafeMath for uint256;

    address public investWallet = 0xbb2efFab932a4c2f77Fc1617C1a563738D71B0a7;
    CCCRCoin public tokenReward; 
    uint256 public tokenPrice = 723; // 1ETH / 1$
    uint256 zeroAmount = 10000000000; // 10 zero
    uint256 startline = 1510736400; // 15.11.17 12:00
    uint256 public minCap = 300000000000000;
    uint256 public totalRaised = 207038943697300;
    uint256 public etherOne = 1000000000000000000;
    uint256 public minimumTokens = 10;

    function CCCRSale(address _tokenReward) {
        tokenReward = CCCRCoin(_tokenReward);
    }

    function bytesToAddress(bytes source) internal pure returns(address) {
        uint result;
        uint mul = 1;
        for(uint i = 20; i > 0; i--) {
            result += uint8(source[i-1])*mul;
            mul = mul*256;
        }
        return address(result);
    }

    function () whenNotPaused whenSaleNotFinish payable {

      require(msg.value >= etherOne.div(tokenPrice).mul(minimumTokens));
        
      uint256 amountWei = msg.value;        
      uint256 amount = amountWei.div(zeroAmount);
      uint256 tokens = amount.mul(getRate());
      
      if(msg.data.length == 20) {
          address referer = bytesToAddress(bytes(msg.data));
          require(referer != msg.sender);
          referer.transfer(amountWei.div(100).mul(20));
      }
      
      tokenReward.transfer(msg.sender, tokens);
      investWallet.transfer(this.balance);
      totalRaised = totalRaised.add(tokens);

      if (totalRaised >= minCap) {
          finished = true;
      }
    }

    function getRate() constant internal returns (uint256) {
        if      (block.timestamp < startline + 19 days) return tokenPrice.mul(138).div(100);
        else if (block.timestamp <= startline + 46 days) return tokenPrice.mul(123).div(100);
        else if (block.timestamp <= startline + 60 days) return tokenPrice.mul(115).div(100);
        else if (block.timestamp <= startline + 74 days) return tokenPrice.mul(109).div(100);
        return tokenPrice;
    }

    function updatePrice(uint256 _tokenPrice) external onlyManager {
        tokenPrice = _tokenPrice;
    }

    function transferTokens(uint256 _tokens) external onlyManager {
        tokenReward.transfer(msg.sender, _tokens); 
    }

    function newMinimumTokens(uint256 _minimumTokens) external onlyManager {
        minimumTokens = _minimumTokens; 
    }

    function getWei(uint256 _etherAmount) external onlyManager {
        uint256 etherAmount = _etherAmount.mul(etherOne);
        investWallet.transfer(etherAmount); 
    }

    function airdrop(address[] _array1, uint256[] _array2) external whenSaleNotFinish onlyManager {
       address[] memory arrayAddress = _array1;
       uint256[] memory arrayAmount = _array2;
       uint256 arrayLength = arrayAddress.length.sub(1);
       uint256 i = 0;
       
      while (i <= arrayLength) {
           tokenReward.transfer(arrayAddress[i], arrayAmount[i]);
           i = i.add(1);
      }  
    }

}