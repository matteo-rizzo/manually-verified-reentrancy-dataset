/**
 *Submitted for verification at Etherscan.io on 2020-08-27
*/

pragma solidity =0.6.6;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false






contract Vote_Presale_1 {
   using SafeMath for uint256;
   
   bool seeded;
   
   address public admin;
   
   address constant public VOTE_ADDRESS = 0xdFb3051e710118BAfc4b3Bb2034728f73C1E62aB;
   address constant public WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
   uint256 constant public VOTE_MAG = 1e9;
   uint256 constant public ETH_MAG = 1e18;
   uint256 constant public SEED_AMOUNT = 3800000 * VOTE_MAG;
   uint256 constant public RATE = 8000;

   modifier onlyAdmin() {
       require(admin == msg.sender);
       _;
   }
 
   modifier isSeeded() {
       require(seeded == true);
       _;
   }
 
   constructor() public {
       admin = msg.sender;
   }
 
   function seed() external onlyAdmin {
       TransferHelper.safeTransferFrom(VOTE_ADDRESS, msg.sender, address(this), SEED_AMOUNT);
       seeded = true;
   }
 
   function exchangeEthForTokens(uint256 _amount) external {
       uint256 ethAmount_ = _amount;
       uint256 voteBalance_ = IERC20(VOTE_ADDRESS).balanceOf(address(this));
       uint256 voteAmount_ = (ethAmount_.mul(RATE)).div(VOTE_MAG);
       require(voteBalance_ >= voteAmount_, "PRESALE_1 ENDED");
       TransferHelper.safeTransferFrom(WETH_ADDRESS, msg.sender, address(this), _amount);
       TransferHelper.safeTransfer(VOTE_ADDRESS, msg.sender, voteAmount_);
   }
   
   function withdraw() external isSeeded onlyAdmin {
       uint256 ethBalance_ = IERC20(WETH_ADDRESS).balanceOf(address(this));
       TransferHelper.safeTransfer(WETH_ADDRESS, msg.sender, ethBalance_);
   }
  
    
}