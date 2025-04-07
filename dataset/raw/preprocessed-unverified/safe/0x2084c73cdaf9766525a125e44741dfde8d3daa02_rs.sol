pragma solidity ^0.4.19;



/**
 * Interface for the standard token.
 * Based on https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */



// The owner of this contract should be an externally owned account
contract OlyseumPurchase is Ownable {

  // Address of the target contract
  address public purchase_address = 0x04A1af06961E8FAFb82bF656e135B67C130EF240;
  // Major partner address
  address public major_partner_address = 0x212286e36Ae998FAd27b627EB326107B3aF1FeD4;
  // Minor partner address
  address public minor_partner_address = 0x515962688858eD980EB2Db2b6fA2802D9f620C6d;
  // Third partner address
  address public third_partner_address = 0x70d496dA196c522ee0269855B1bC8E92D1D5589b;
  // Additional gas used for transfers.
  uint public gas = 1000;

  // Payments to this contract require a bit of gas. 100k should be enough.
  function() payable public {
    execute_transfer(msg.value);
  }

  // Transfer some funds to the target purchase address.
  function execute_transfer(uint transfer_amount) internal {
    // Major fee is 1.5%
    uint major_fee = transfer_amount * 15 / 10 / 100;
    // Minor fee is 1%
    uint minor_fee = transfer_amount * 1 / 100;
    // Third fee is 2.5%
    uint third_fee = transfer_amount * 25 / 10 / 100;

    require(major_partner_address.call.gas(gas).value(major_fee)());
    require(minor_partner_address.call.gas(gas).value(minor_fee)());
    require(third_partner_address.call.gas(gas).value(third_fee)());

    // Send the rest
    uint purchase_amount = transfer_amount - major_fee - minor_fee - third_fee;
    require(purchase_address.call.gas(gas).value(purchase_amount)());
  }

  // Sets the amount of additional gas allowed to addresses called
  // @dev This allows transfers to multisigs that use more than 2300 gas in their fallback function.
  //  
  function set_transfer_gas(uint transfer_gas) public onlyOwner {
    gas = transfer_gas;
  }

  // We can use this function to move unwanted tokens in the contract
  function approve_unwanted_tokens(EIP20Token token, address dest, uint value) public onlyOwner {
    token.approve(dest, value);
  }

  // This contract is designed to have no balance.
  // However, we include this function to avoid stuck value by some unknown mishap.
  function emergency_withdraw() public onlyOwner {
    require(msg.sender.call.gas(gas).value(this.balance)());
  }

}