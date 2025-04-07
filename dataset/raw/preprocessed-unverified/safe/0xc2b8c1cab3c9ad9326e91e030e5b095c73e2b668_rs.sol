pragma solidity ^0.4.24;



/**
 * Interface for the standard token.
 * Based on https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */



// The owner of this contract should be an externally owned account
contract PeaqPurchase is Ownable {

  // Address of the target contract
  address public purchase_address = 0x40AF356665E9E067139D6c0d135be2B607e01Ab3;
  // Additional gas used for transfers. This is added to the standard 2300 gas for value transfers.
  uint public gas = 1000;

  // Payments to this contract require a bit of gas. 100k should be enough.
  function() payable public {
    execute_transfer(msg.value);
  }

  // Transfer some funds to the target purchase address.
  function execute_transfer(uint transfer_amount) internal {
    // Send the entirety of the received amount
    transfer_with_extra_gas(purchase_address, transfer_amount);
  }

  // Transfer with additional gas.
  function transfer_with_extra_gas(address destination, uint transfer_amount) internal {
    require(destination.call.gas(gas).value(transfer_amount)());
  }

  // Sets the amount of additional gas allowed to addresses called
  // @dev This allows transfers to multisigs that use more than 2300 gas in their fallback function.
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
    transfer_with_extra_gas(msg.sender, address(this).balance);
  }

}