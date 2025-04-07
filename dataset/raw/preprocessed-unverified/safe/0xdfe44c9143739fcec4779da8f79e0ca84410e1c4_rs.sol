/**

 *Submitted for verification at Etherscan.io on 2019-02-20

*/



pragma solidity ^0.5.4;



    



    



    



    contract ReentrancyGuard {

        

    uint256 private _guardCounter;



    constructor () internal {

        _guardCounter = 1;

    }



    modifier nonReentrant() {

        _guardCounter += 1;

        uint256 localCounter = _guardCounter;

        _;

        require(localCounter == _guardCounter);

    }

}



    contract ETHPlaySale is ReentrancyGuard {

    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    IERC20 private _token;



    address payable private _wallet;



    uint256 private _rate;



    uint256 private _weiRaised;



    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);



    constructor (uint256 rate, address payable wallet, IERC20 token) public {

        require(rate > 0);

        require(wallet != address(0));

        require(address(token) != address(0));



        _rate = rate;

        _wallet = wallet;

        _token = token;

    }



    function () external payable {

        buyTokens(msg.sender);

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

        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);



        _updatePurchasingState(beneficiary, weiAmount);



        _forwardFunds();

        _postValidatePurchase(beneficiary, weiAmount);

    }



    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        require(beneficiary != address(0));

        require(weiAmount != 0);

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