/**

 *Submitted for verification at Etherscan.io on 2018-09-07

*/



pragma solidity ^0.4.24;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title Currency exchange rate contract

 */

contract CurrencyExchangeRate is Ownable {



    struct Currency {

        uint256 exRateToEther; // Exchange rate: currency to Ether

        uint8 exRateDecimals;  // Exchange rate decimals

    }



    Currency[] public currencies;



    event CurrencyExchangeRateAdded(

        address indexed setter, uint256 index, uint256 rate, uint256 decimals

    );



    event CurrencyExchangeRateSet(

        address indexed setter, uint256 index, uint256 rate, uint256 decimals

    );



    constructor() public {

        // Add Ether to index 0

        currencies.push(

            Currency ({

                exRateToEther: 1,

                exRateDecimals: 0

            })

        );

        // Add USD to index 1

        currencies.push(

            Currency ({

                exRateToEther: 30000,

                exRateDecimals: 2

            })

        );

    }



    function addCurrencyExchangeRate(

        uint256 _exRateToEther, 

        uint8 _exRateDecimals

    ) external onlyOwner {

        emit CurrencyExchangeRateAdded(

            msg.sender, currencies.length, _exRateToEther, _exRateDecimals);

        currencies.push(

            Currency ({

                exRateToEther: _exRateToEther,

                exRateDecimals: _exRateDecimals

            })

        );

    }



    function setCurrencyExchangeRate(

        uint256 _currencyIndex,

        uint256 _exRateToEther, 

        uint8 _exRateDecimals

    ) external onlyOwner {

        emit CurrencyExchangeRateSet(

            msg.sender, _currencyIndex, _exRateToEther, _exRateDecimals);

        currencies[_currencyIndex].exRateToEther = _exRateToEther;

        currencies[_currencyIndex].exRateDecimals = _exRateDecimals;

    }

}