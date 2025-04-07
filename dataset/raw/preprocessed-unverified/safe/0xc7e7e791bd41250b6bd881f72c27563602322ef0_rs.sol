/**
 *Submitted for verification at Etherscan.io on 2020-01-13
*/

pragma solidity >=0.4.26;








contract KyberTradeUSDC{

    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    KyberNetworkProxyInterface public proxy = KyberNetworkProxyInterface(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
    OrFeedInterface orfeed= OrFeedInterface(0x73f5022bec0e01c0859634b0c7186301c5464b46);
    address usdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    bytes  PERM_HINT = "PERM";
    address owner;

    constructor() public
    {
     owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert("Not Owner.");
        }
        _;
    }

    function xETHUSDC (KyberNetworkProxyInterface _kyberNetworkProxy, ERC20 token, address destAddress) internal{

        uint minRate;
        (, minRate) = _kyberNetworkProxy.getExpectedRate(ETH_TOKEN_ADDRESS, token, msg.value);
        uint destAmount = _kyberNetworkProxy.swapEtherToToken.value(msg.value)(token, minRate);
        require(token.transfer(destAddress, destAmount),"Error");
    }

    function () external payable  {

    }

    function withdrawETHAndTokens() private onlyOwner{
        msg.sender.transfer(address(this).balance);
        ERC20 usdcToken = ERC20(usdcAddress);
        uint256 currentTokenBalance = usdcToken.balanceOf(this);
        usdcToken.transfer(msg.sender, currentTokenBalance);
    }

    function getPrice() public view returns(uint256){
        uint256 currentPrice = orfeed.getExchangeRate("ETH", "USD", "", 100000000);
        return currentPrice;
    }

    function getKyberSellPrice() public view returns (uint256){
       uint256 currentPrice = orfeed.getExchangeRate("ETH", "USDC", "SELL-KYBER-EXCHANGE", 1000000000000000000);
        return currentPrice;
    }
}