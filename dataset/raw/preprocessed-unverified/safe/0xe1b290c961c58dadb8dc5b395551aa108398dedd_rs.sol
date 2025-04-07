/**
 *Submitted for verification at Etherscan.io on 2021-06-29
*/

pragma solidity 0.8.6;

// "SPDX-License-Identifier: MIT"






/// Ethereum
contract Bridge is Owned{
    address constant public TBCC_TOKEN_CONTRACT = 0x2Ecb95eB932DfBBb71545f4D23CA303700aC855F;
    uint256 constant public  MAX_GAS_FOR_CALLING_ERC20 = 70000;
  
    uint256 public relayFee;
    
    event transferOutSuccess(address senderAddr, uint256 amount);

    constructor() {
        owner = msg.sender;
        relayFee = 4500000000000000;
    }


    function transferOut(uint256 amount) external payable returns (bool) {
        require(msg.value > relayFee);
        require(IERC20(TBCC_TOKEN_CONTRACT).transferFrom(msg.sender, address(this), amount));  
        emit transferOutSuccess(msg.sender, amount);
        return true;
    }

    function withdrawTokens(address payable to, uint256 amount) external onlyOwner returns(uint256) {
        uint256 actualBalance = IERC20(TBCC_TOKEN_CONTRACT).balanceOf{gas: MAX_GAS_FOR_CALLING_ERC20}(address(this));
        uint256 actualAmount = amount < actualBalance ? amount : actualBalance;
        require(IERC20(TBCC_TOKEN_CONTRACT).transfer{gas: MAX_GAS_FOR_CALLING_ERC20}(to, actualAmount));
        return actualAmount;
    }

    function withdrawCoins(address to, uint256 amount) external onlyOwner returns(uint256) {
        (bool succ, ) = payable(to).call{value: amount }("");
        require(succ, "TRANSFER FAILED");
        return amount;
    }

    function updateRelayFee(uint256 amount) external onlyOwner returns(uint256) {
        relayFee = amount;
        return relayFee;
    }
}