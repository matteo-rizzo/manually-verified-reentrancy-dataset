/**
 *Submitted for verification at Etherscan.io on 2019-07-05
*/

pragma solidity ^0.5.8;

/*
    IdeaFeX Token crowdsale contract

    Deployed to     : 0xa0f9783497969a160d640bc8a0f5d53838a39416
    IFX token       : 0x2CF588136b15E47b555331d2f5258063AE6D01ed
    Funds wallet    : 0x1bD99BA31f1056F962e017410c9514dD4d6da4c6
    Supply for sale : 400,000,000.000000000000000000
    Rate            : 2000 IFX = 1 ETH
    Bonus           : 40% before 20% sold
                      30% between 20% and 40% sold
                      20% between 40% and 60% sold
                      10% between 60% and 80% sold
*/


/* Safe maths */




/* ERC20 standard interface */




/* Safe ERC20 */




/* No nested calls */

contract ReentrancyGuard {
    uint private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}


/* IFX crowdsale */

contract IFXCrowdsale is ReentrancyGuard {
    using SafeMath for uint;
    using SafeERC20 for ERC20Interface;

    // Addresses!!!
    ERC20Interface private _IFX = ERC20Interface(0x2CF588136b15E47b555331d2f5258063AE6D01ed);
    address payable private _fundingWallet = 0x1bD99BA31f1056F962e017410c9514dD4d6da4c6;
    address payable private _tokenSaleWallet = 0x6924E015c192C0f1839a432B49e1e96e06571227;

    uint private _rate = 2000;
    uint private _weiRaised;
    uint private _ifxSold;
    uint private _bonus = 40;
    uint private _rateCurrent = 2800;

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint ethValue, uint ifxAmount);


    // Basics

    function () external payable {
        buyTokens(msg.sender);
    }

    function token() public view returns (ERC20Interface) {
        return _IFX;
    }

    function fundingWallet() public view returns (address payable) {
        return _fundingWallet;
    }

    function rate() public view returns (uint) {
        return _rate;
    }

    function rateWithBonus() public view returns (uint){
        return _rateCurrent;
    }

    function bonus() public view returns (uint) {
        return _bonus;
    }

    function weiRaised() public view returns (uint) {
        return _weiRaised;
    }

    function ifxSold() public view returns (uint) {
        return _ifxSold;
    }


    // Default when people send ETH to contract address

    function buyTokens(address beneficiary) public nonReentrant payable {

        // Ensures that the call is valid
        require(beneficiary != address(0), "Beneficiary is zero address");
        require(msg.value != 0, "Value is 0");

        // Obtain token amount
        uint tokenAmount = msg.value.mul(_rateCurrent);

        // Ensures that the hard cap is not breached
        require(_ifxSold + tokenAmount < 400000000 * 10**18, "Hard cap reached");

        // Records the purchase internally
        _weiRaised = _weiRaised.add(msg.value);
        _ifxSold = _ifxSold.add(tokenAmount);

        // Update the bonus after each purchase
        _currentBonus();

        // Process the purchase
        _IFX.safeTransferFrom(_tokenSaleWallet, beneficiary, tokenAmount);
        _fundingWallet.transfer(msg.value);

        // Announce the purchase event
        emit TokensPurchased(msg.sender, beneficiary, msg.value, tokenAmount);
    }


    // Bonus

    function _currentBonus() internal {
        if(_ifxSold < 80000000 * 10**18){
            _bonus = 40;
        } else if(_ifxSold >= 80000000 * 10**18 && _ifxSold < 160000000 * 10**18){
            _bonus = 30;
        } else if(_ifxSold >= 160000000 * 10**18 && _ifxSold < 240000000 * 10**18){
            _bonus = 20;
        } else if(_ifxSold >= 240000000 * 10**18 && _ifxSold < 320000000 * 10**18){
            _bonus = 10;
        } else if(_ifxSold >= 320000000 * 10**18){
            _bonus = 0;
        }

        // _rate === 2000
        // _rate / 100 === 20
        // (_bonus + 100) * _rate / 100 === _bonus * 20 + _rate
        _rateCurrent = _bonus * 20 + 2000;
    }
}