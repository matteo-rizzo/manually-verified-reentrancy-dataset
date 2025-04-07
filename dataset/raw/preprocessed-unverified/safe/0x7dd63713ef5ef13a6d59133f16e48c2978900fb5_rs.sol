/**
 *Submitted for verification at Etherscan.io on 2020-08-28
*/

pragma solidity =0.6.6;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false






contract DonutBurn {
   using SafeMath for uint256;
   
   bool isSeeded;
   
   address constant public BURN_ADDRESS = 0x0000000000000000000000000000000000000001;
   address constant public COFFEE_ADDRESS = 0xCcFf20dC60f1b34D9e8bE09591d00F0f775596FD;
   address constant public DONUT_ADDRESS = 0xC0F9bD5Fa5698B6505F643900FFA515Ea5dF54A9;
   uint256 constant public COFFEE_MAG = 1e9;
   uint256 constant public DONUT_MAG = 1e18;
   uint256 constant public INITIAL_COFFEE_SUPPLY = 5 * 1e6 * COFFEE_MAG;
   uint256 constant public RATE = 4;
 
   constructor() public {
   }
 
   function seed() external {
       require(!isSeeded);
       TransferHelper.safeTransferFrom(COFFEE_ADDRESS, msg.sender, address(this), INITIAL_COFFEE_SUPPLY);
       isSeeded = true;
   }
 
   function burn(uint256 _amount) external {
       uint256 coffeeBalance_ = IERC20(COFFEE_ADDRESS).balanceOf(address(this));
       uint256 coffeeAmount_ = (_amount.mul(RATE)).div(COFFEE_MAG);
       require(coffeeBalance_ >= coffeeAmount_);
       TransferHelper.safeTransferFrom(DONUT_ADDRESS, msg.sender, BURN_ADDRESS, _amount);
       TransferHelper.safeTransfer(COFFEE_ADDRESS, msg.sender, coffeeAmount_);
   }
    
    
}