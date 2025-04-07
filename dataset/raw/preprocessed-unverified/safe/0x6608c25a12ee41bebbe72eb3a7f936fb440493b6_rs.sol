pragma solidity ^0.4.21;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

contract IQUASaleMint {
    function mintProxyWithoutCap(address _to, uint256 _amount) public;
    function mintProxy(address _to, uint256 _amount) public;
}



/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */
contract QuasaCoinExchanger is Ownable {
    using SafeMath for uint256;

    // Address where funds are collected
    address public wallet;

    // How many token units a buyer gets per wei
    uint256 public rate;

    // Quasa token sale minter
    IQUASaleMint public icoSmartcontract;

    function QuasaCoinExchanger() public {

        owner = msg.sender;

        // 1 ETH = 3000 QUA
        rate = 3000;
        wallet = 0x373ae730d8c4250b3d022a65ef998b8b7ab1aa53;
        icoSmartcontract = IQUASaleMint(0x48299b98d25c700e8f8c4393b4ee49d525162513);
    }


    function setRate(uint256 _rate) onlyOwner public  {
        rate = _rate;
    }


    // -----------------------------------------
    // Crowdsale external interface
    // -----------------------------------------

    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     */
    function () external payable {
        buyTokens(msg.sender);
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * @param _beneficiary Address performing the token purchase
     */
    function buyTokens(address _beneficiary) public payable {

        uint256 _weiAmount = msg.value;

        require(_beneficiary != address(0));
        require(_weiAmount != 0);

        // calculate token amount to be created
        uint256 _tokenAmount = _weiAmount.mul(rate);

        icoSmartcontract.mintProxyWithoutCap(_beneficiary, _tokenAmount);

        wallet.transfer(_weiAmount);
    }

}