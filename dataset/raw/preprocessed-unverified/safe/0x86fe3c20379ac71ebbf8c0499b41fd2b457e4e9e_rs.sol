pragma solidity ^0.4.18;

/**
 * TradeToken Crowdsale Contract
 *
 * This is the crowdsale contract for the TradeToken. It utilizes Majoolr&#39;s
 * CrowdsaleLib library to reduce custom source code surface area and increase
 * overall security.Majoolr provides smart contract services and security reviews
 * for contract deployments in addition to working on open source projects in the
 * Ethereum community.
 * For further information: trade.io, majoolr.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

contract TIOCrowdsale {
  using DirectCrowdsaleLib for DirectCrowdsaleLib.DirectCrowdsaleStorage;

  DirectCrowdsaleLib.DirectCrowdsaleStorage sale;
  bool public greenshoeActive;
  function TIOCrowdsale(
                address owner,
                uint256[] saleData,           // [1512633600, 50, 0, 1513238400, 56, 0, 1513843200, 64, 0, 1514448000, 75, 0]
                uint256 fallbackExchangeRate, // 45000
                uint256 capAmountInCents,     // 24750000000
                uint256 endTime,              // 1515052740
                uint8 percentBurn,            // 100
                CrowdsaleToken token)         // 0x80bc5512561c7f85a3a9508c7df7901b370fa1df
  {
  	sale.init(owner, saleData, fallbackExchangeRate, capAmountInCents, endTime, percentBurn, token);
  }

  // fallback function can be used to buy tokens
  function () payable {
    sendPurchase();
  }

  function sendPurchase() payable returns (bool) {
    uint256 _tokensSold = getTokensSold();
    if(_tokensSold > 270000000000000000000000000 && (!greenshoeActive)){
      bool success = activateGreenshoe();
      assert(success);
    }
  	return sale.receivePurchase(msg.value);
  }

  function activateGreenshoe() private returns (bool) {
    uint256 _currentPrice = sale.base.saleData[sale.base.milestoneTimes[sale.base.currentMilestone]][0];
    while(sale.base.milestoneTimes.length > sale.base.currentMilestone + 1)
    {
      sale.base.currentMilestone += 1;
      sale.base.saleData[sale.base.milestoneTimes[sale.base.currentMilestone]][0] = _currentPrice;
    }
    greenshoeActive = true;
    return true;
  }

  function withdrawTokens() returns (bool) {
  	return sale.withdrawTokens();
  }

  function withdrawLeftoverWei() returns (bool) {
    return sale.withdrawLeftoverWei();
  }

  function withdrawOwnerEth() returns (bool) {
    return sale.withdrawOwnerEth();
  }

  function crowdsaleActive() constant returns (bool) {
    return sale.crowdsaleActive();
  }

  function crowdsaleEnded() constant returns (bool) {
    return sale.crowdsaleEnded();
  }

  function setTokenExchangeRate(uint256 _exchangeRate) returns (bool) {
    return sale.setTokenExchangeRate(_exchangeRate);
  }

  function setTokens() returns (bool) {
    return sale.setTokens();
  }

  function getOwner() constant returns (address) {
    return sale.base.owner;
  }

  function getTokensPerEth() constant returns (uint256) {
    return sale.base.tokensPerEth;
  }

  function getExchangeRate() constant returns (uint256) {
    return sale.base.exchangeRate;
  }

  function getCapAmount() constant returns (uint256) {
    if(!greenshoeActive) {
      return sale.base.capAmount - 160000000000000000000000;
    } else {
      return sale.base.capAmount;
    }
  }

  function getStartTime() constant returns (uint256) {
    return sale.base.startTime;
  }

  function getEndTime() constant returns (uint256) {
    return sale.base.endTime;
  }

  function getEthRaised() constant returns (uint256) {
    return sale.base.ownerBalance;
  }

  function getContribution(address _buyer) constant returns (uint256) {
  	return sale.base.hasContributed[_buyer];
  }

  function getTokenPurchase(address _buyer) constant returns (uint256) {
  	return sale.base.withdrawTokensMap[_buyer];
  }

  function getLeftoverWei(address _buyer) constant returns (uint256) {
    return sale.base.leftoverWei[_buyer];
  }

  function getSaleData(uint256 timestamp) constant returns (uint256[3]) {
    return sale.getSaleData(timestamp);
  }

  function getTokensSold() constant returns (uint256) {
    return sale.base.startingTokenBalance - sale.base.withdrawTokensMap[sale.base.owner];
  }

  function getPercentBurn() constant returns (uint256) {
    return sale.base.percentBurn;
  }
}









contract CrowdsaleToken {
  using TokenLib for TokenLib.TokenStorage;

  TokenLib.TokenStorage public token;

  function CrowdsaleToken(address owner,
                                   string name,
                                   string symbol,
                                   uint8 decimals,
                                   uint256 initialSupply,
                                   bool allowMinting)
                                   public
  {
    token.init(owner, name, symbol, decimals, initialSupply, allowMinting);
  }

  function name() public view returns (string) {
    return token.name;
  }

  function symbol() public view returns (string) {
    return token.symbol;
  }

  function decimals() public view returns (uint8) {
    return token.decimals;
  }

  function totalSupply() public view returns (uint256) {
    return token.totalSupply;
  }

  function initialSupply() public view returns (uint256) {
    return token.initialSupply;
  }

  function balanceOf(address who) public view returns (uint256) {
    return token.balanceOf(who);
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return token.allowance(owner, spender);
  }

  function transfer(address to, uint256 value) public returns (bool ok) {
    return token.transfer(to, value);
  }

  function transferFrom(address from, address to, uint value) public returns (bool ok) {
    return token.transferFrom(from, to, value);
  }

  function approve(address spender, uint256 value) public returns (bool ok) {
    return token.approve(spender, value);
  }

  function approveChange(address spender, uint256 valueChange, bool increase)
                         public
                         returns (bool)
  {
    return token.approveChange(spender, valueChange, increase);
  }

  function changeOwner(address newOwner) public returns (bool ok) {
    return token.changeOwner(newOwner);
  }

  function burnToken(uint256 amount) public returns (bool ok) {
    return token.burnToken(amount);
  }
}