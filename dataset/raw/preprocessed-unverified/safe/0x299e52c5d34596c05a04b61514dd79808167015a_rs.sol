/**

 *Submitted for verification at Etherscan.io on 2019-06-15

*/



pragma solidity ^0.5.0;



/**

 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include

 * the optional functions; to access them see `ERC20Detailed`.

 */





contract TreasureHunt {

  bool public isActive;

  bytes32 hashedSecret;

  address DGX_TOKEN_ADDRESS;



  // this function runs when the contract is deployed

  // it initializes the contract storage

  constructor(bytes32 _hashedSecret, address _dgx_token_address) public {

    // set the hashed secret

    hashedSecret = _hashedSecret;



    // set the DGX contract address

    DGX_TOKEN_ADDRESS = _dgx_token_address;



    // set the treasure hunt as active

    isActive = true;

  }



  function unlockTreasure(bytes32 _secret) public {

    // only if this treasure hunt is active

    require(isActive, "treasure inactive");



    // make sure the keccak256 hash of the _secret

    // matches the hashedSecret

    require(keccak256(abi.encodePacked(_secret)) == hashedSecret, "incorrect secret");



    // transfer the DGX to the address

    // that called this function

    uint256 _dgxBalance = IERC20(DGX_TOKEN_ADDRESS).balanceOf(address(this));

    require(IERC20(DGX_TOKEN_ADDRESS).transfer(msg.sender, _dgxBalance), "could not transfer DGX");



    // set the treasure hunt to be inactive

    isActive = false;

  }

}