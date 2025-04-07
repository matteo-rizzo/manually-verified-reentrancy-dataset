pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





contract ERC20Interface{

    function transferFrom(address from, address to, uint256 value) public returns (bool);

}



/*

 * Ownable

 *

 * Base contract with an owner.

 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.

 */





contract Anaco_Airdrop is Ownable {

    

    // allows the use of the SafeMath library inside that contract, only for uint256 variables

    using SafeMath for uint256;

    

    // Token exchange rate (taking into account the 8 decimals from ANACO tokens)

    uint256 public tokensPerEth = 100000000 * 1e8;

    uint256 public closeTime = 1538351999; // September 30th, at 11PM 59:59 GMT is the end of the airdrop

    

    // ANAC Token interface

    ERC20Interface public anacoContract = ERC20Interface(0x356A50ECE1eD2782fE7031D81FD168f08e242a4E);

    address public fundsWallet;

    

    // modifiers

    modifier airdropOpen() {

       // if(now > closeTime) revert();

        _;

    }

    

    modifier airdropClosed() {

       // if(now < closeTime) revert(); 

        _;

    }

    

    constructor(address _fundsWallet) public {

        fundsWallet = _fundsWallet;

    }

    

    

    function () public {

        revert();           // do not accept fallback calls

    }

    

    

    function getTokens() payable public{

        require(msg.value >= 2 finney);             // needs to contribute at least 0.002 Ether

        

        uint256 amount = msg.value.mul(tokensPerEth).div(1 ether);

        

        if(msg.value >= 500 finney) {               // +50% bonus if you contribute more than 0.5 Ether

            amount = amount.add(amount.div(2));

        }

        

        anacoContract.transferFrom(fundsWallet, msg.sender, amount); // reverts by itself if fundsWallet doesn't allow enough funds to the contract

    }

    

    

    function withdraw() public onlyOwner {

        require(owner.send(address(this).balance));

    }

    

    

    function changeFundsWallet(address _newFundsWallet) public onlyOwner {

        fundsWallet = _newFundsWallet;

    }

    

}