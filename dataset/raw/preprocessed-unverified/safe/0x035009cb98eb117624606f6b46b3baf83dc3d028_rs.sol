/**
 *Submitted for verification at Etherscan.io on 2020-10-03
*/

//
//  _   _ ______ ______ _  __    __ _   
// | \ | |  ____|  ____| |/ /   / _(_)                           
// |  \| | |__  | |__  | ' /   | |_ _ _ __   __ _ _ __   ___ ___ 
// | . ` |  __| |  __| |  <    |  _| | '_ \ / _` | '_ \ / __/ _ \
// | |\  | |____| |____| . \  _| | | | | | | (_| | | | | (_|  __/
// |_| \_|______|______|_|\_\(_)_| |_|_| |_|\__,_|_| |_|\___\___|
//                                
//
// Site:     https://neek.finance/
// Telegram: https://t.me/neekfinance/    < Join Us
// Twitter:  https://twitter.com/NeekFinance/    < Follow Us
//
//

pragma solidity 0.5.17;
contract ReentrancyGuard {
    bool private _notEntered;
    constructor () internal {
        _notEntered = true;
    }
    modifier nonReentrant() {
        require(_notEntered, "ReentrancyGuard: reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }
}




contract Context {
    constructor () internal { }
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}
contract Crowdsale is Context, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 private _token;
    address payable private _wallet;
    uint256 private _rate;
    uint256 private _weiRaised;
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    constructor (uint256 rate, address payable wallet, IERC20 token) public {
        require(rate > 0, "Crowdsale: rate is 0");
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");
        _rate = rate;
        _wallet = wallet;
        _token = token;
    }
    function () external payable {
        buyTokens(_msgSender());
    }
    function token() public view returns (IERC20) {
        return _token;
    }
    function wallet() public view returns (address payable) {
        return _wallet;
    }
    function rate() public view returns (uint256) {
        return _rate;
    }
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);
        uint256 tokens = _getTokenAmount(weiAmount);
        _weiRaised = _weiRaised.add(weiAmount);
        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);
        _updatePurchasingState(beneficiary, weiAmount);
        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this;
    }
    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
    }
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.safeTransfer(beneficiary, tokenAmount);
    }
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
    }
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_rate);
    }
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}
contract NeekPresale1 is Crowdsale {
    constructor (
        uint256 rate,
        address payable wallet,
        IERC20 token
    )
        public
        Crowdsale(rate, wallet, token)
        // Rate set 0.000100 ETH Per NEEK
        //          10,000 NEEK Per ETH
    {
    }
}