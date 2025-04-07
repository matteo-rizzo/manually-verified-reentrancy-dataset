/**
 *Submitted for verification at Etherscan.io on 2021-04-02
*/

pragma solidity ^0.8.2;

// SPDX-License-Identifier: MIT



contract OptionSellingContract {
    IERC20 buyingTokenContract;
    uint buyingAmount;
    
    IERC20 sellingtokenContract;
    uint sellingAmount;
    
    /**
    * @dev Returns the Buyers address
    */
    address public buyerAddress;
    
    /**
    * @dev Returns the sellers address
    */
    address public sellerAddress;
    
    /**
    * @dev Returns the state of the contract, if true tokens are deposited and 
    * trades can be excecuted
    */
    bool public isInitialised;
    
    /**
    * @dev Returns the amount of tokens that were sold through this contract
    */
    uint public soldAmount;
    
    /**
    * @dev Returns the amount of tokens that were bought through this contract
    */
    uint public boughtAmount;
    
    /**
    * @dev Initializes the contract setting the needed values for the trade.
    */
    constructor () {
        buyingTokenContract = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
        buyingAmount = 40e8;
        buyerAddress = 0x1574c679261C3715c789c02a496a443Fea7A1474;
        sellingtokenContract = IERC20(0x191557728e4d8CAa4Ac94f86af842148c0FA8F7E);
        sellingAmount = 120000000e8;
        sellerAddress = 0x7c50038b33DE3679cf2A5783AAfF5FE358709680;
    }
    
    /**
    * @dev This method thakes the predefined amount of selling tokens from the 
    * sellers account and initializes the contract which means that 
    * trading can start.
    * 
    * IMPORTANT: This method will not work if allowance on the selling token is 
    * not set to the appropriate ammount
    */
    function initializeContract() public {
        require(msg.sender == sellerAddress);
        require(!isInitialised, "Contract is already initialised!");
        sellingtokenContract.transferFrom(msg.sender, address(this), sellingAmount);
        isInitialised = true;
    }
    
    /**
    * @dev Creates the trade, it sends the amount of buying tokens that are ont the smart 
    * contract to the seller and withdraws the appropriate amount of selling tokens to the buyer
    * 
    * IMPORTANT: This method will only work if contract is initialised and if balance of buying token is at leats 0.1.
    */
    function executeSell() public {
        require(msg.sender == sellerAddress || msg.sender == buyerAddress);
        require(buyingTokenContract.balanceOf(address(this)) >= 1e7, "Selling ammount must me greater than 0.1 WBTC!");
        require(isInitialised, "Contract is not initialised!");
        
        uint buyingBalance = buyingTokenContract.balanceOf(address(this));
        if (buyingAmount - boughtAmount < buyingBalance){
            buyingTokenContract.transfer(buyerAddress, buyingBalance - (buyingAmount - boughtAmount));
            buyingBalance = buyingAmount - boughtAmount;
        }
        boughtAmount += buyingBalance;
        buyingTokenContract.transfer(sellerAddress, buyingBalance);
        
        
        uint activeSoldAmount = (buyingBalance * (sellingAmount/buyingAmount));
        soldAmount += activeSoldAmount;
        sellingtokenContract.transfer(buyerAddress, activeSoldAmount);
    }
    
    /**
    * @dev Returns the amount of selling tokens on the smart contract
    */
    function sellingTokenBalance() public view returns (uint){
        return sellingtokenContract.balanceOf(address(this));
    }
    
    /**
    * @dev Returns the amount of buying tokens on the smart contract
    */
    function buyingTokenBalance() public view returns (uint){
        return buyingTokenContract.balanceOf(address(this));
    }
    
    /**
    * @dev After the trading is complete and all the tokens are sent 
    * appropriatly the buyer gets the control of the smart contract 
    * so he can salvage wrongly sent tokens.
    */
    function salvageTokensFromContract(address tokenAddress, address to, uint amount) public {
        require(msg.sender == buyerAddress);
        require(boughtAmount == buyingAmount);
        IERC20(tokenAddress).transfer(to, amount);
    }
}