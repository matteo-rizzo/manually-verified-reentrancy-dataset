// SPDX-License-Identifier: MIT

/* 

    _    __  __ ____  _     ____       _     _       _       
   / \  |  \/  |  _ \| |   / ___| ___ | | __| |     (_) ___  
  / _ \ | |\/| | |_) | |  | |  _ / _ \| |/ _` |     | |/ _ \ 
 / ___ \| |  | |  __/| |__| |_| | (_) | | (_| |  _  | | (_) |
/_/   \_\_|  |_|_|   |_____\____|\___/|_|\__,_| (_) |_|\___/ 
                                

    Ample Gold $AMPLG is a goldpegged defi protocol that is based on Ampleforths elastic tokensupply model. 
    AMPLG is designed to maintain its base price target of 0.01g of Gold with a progammed inflation adjustment (rebase).
    
    Forked from Ampleforth: https://github.com/ampleforth/uFragments (Credits to Ampleforth team for implementation of rebasing on the ethereum network)
    
    GPL 3.0 license
    
    AMPLG_GoldOracle.sol - AMPLG $AMPLG Oracle
  
*/

pragma solidity ^0.6.12;



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



contract AMPLGGoldOracle is IGoldOracle, Ownable {
  
    uint256 goldPrice;
    uint256 marketPrice;

    function setGoldPrice(uint256 _goldprice) external onlyOwner {
        goldPrice = _goldprice;
    }

    function setMarketPrice(uint256 _marketprice) external onlyOwner {
        marketPrice = _marketprice;
    }
    
    function getGoldPrice() external override view returns (uint256, bool) {
        return (goldPrice, true);
    }

    function getMarketPrice() external override view returns (uint256, bool) {
        return (marketPrice, true);
    }
}