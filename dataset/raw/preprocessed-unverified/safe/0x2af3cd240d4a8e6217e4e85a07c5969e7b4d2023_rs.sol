/**

 *Submitted for verification at Etherscan.io on 2019-02-04

*/



pragma solidity ^0.5.2;



// File: @daostack/arc/contracts/schemes/PriceOracleInterface.sol







// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File:@daostack/arc/contracts/test/PriceOracleMock.sol



contract PriceOracleMock is PriceOracleInterface, Ownable {



    struct Price {

        uint256 numerator;

        uint256 denominator;

    }



    // user => amount

    mapping (address => Price) public tokenPrices;



    function getPrice(address token) public view returns (uint, uint) {

        Price memory price = tokenPrices[token];

        return (price.numerator, price.denominator);

    }



    function setTokenPrice(address token, uint256 numerator, uint256 denominator) public onlyOwner {

        tokenPrices[token] = Price(numerator, denominator);

    }

}