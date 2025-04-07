/**

 *Submitted for verification at Etherscan.io on 2019-04-17

*/



//Copyright (c) 2016-2019 zOS Global Limited, licensed under the MIT license.

//https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/LICENSE



pragma solidity ^0.5.2;



















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



contract Crowdsale is ReentrancyGuard {

    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    IERC20 private _token;

    address payable private _wallet;



    uint256 private _rate;

    uint256 private _weiRaised;



    uint256 private _openingTime;

    uint256 private _closingTime;



    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);



    constructor () public {

        _rate = 10000000000;

        _wallet = 0x4b09b4aeA5f9C616ebB6Ee0097B62998Cb332275;

        _token = IERC20(0x1a9ECb05376Bf8BB32F7F038A845DbAfb22041cd);

        

        _openingTime = block.timestamp;

        _closingTime = 1567296000;

    }

    

    function isOpen() public view returns (bool) {

        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;

    }



    modifier onlyWhileOpen {

        require(isOpen());

        _;

    }

    

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen view {

        require(beneficiary != address(0));

        require(weiAmount != 0);

    }



    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

        return weiAmount.div(_rate);

    }

    

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {

        _token.safeTransfer(beneficiary, tokenAmount);

    }

    

    function _forwardFunds() internal {

        _wallet.transfer(msg.value);

    }

    

    function buyTokens(address beneficiary) public nonReentrant payable {

        uint256 weiAmount = msg.value;

        _preValidatePurchase(beneficiary, weiAmount);



        uint256 tokens = _getTokenAmount(weiAmount);



        _weiRaised = _weiRaised.add(weiAmount);



        _deliverTokens(beneficiary, tokens);

        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);



        _forwardFunds();

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



    function openingTime() public view returns (uint256) {

        return _openingTime;

    }

    function closingTime() public view returns (uint256) {

        return _closingTime;

    }

}