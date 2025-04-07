/**

 *Submitted for verification at Etherscan.io on 2019-03-07

*/



pragma solidity 0.5.5;







contract IERC20 {

    function transfer(address to, uint256 value) public returns (bool) {}

}



contract CurrentKing {

  using SafeMath for uint256;



  // initialize

  uint256 public REWARD_PER_WIN = 10000000;

  uint256 public CREATOR_REWARD = 100000;

  address public CREATOR_ADDRESS;

  address public GTT_ADDRESS;



  // game state params

  uint256 public lastPaidBlock;

  address public currentKing;



  constructor() public {

    CREATOR_ADDRESS = msg.sender;

    lastPaidBlock = block.number;

    currentKing = address(this);

  }



  // can only be called once

  function setTokenAddress(address _gttAddress) public {

    if (GTT_ADDRESS == address(0)) {

      GTT_ADDRESS = _gttAddress;

    }

  }



  function play() public {

    uint256 currentBlock = block.number;



    // pay old king

    if (currentBlock != lastPaidBlock) {

      payOut(currentBlock);



      // reinitialize

      lastPaidBlock = currentBlock;

    }



    // set new king

    currentKing = msg.sender;

  }



  function payOut(uint256 _currentBlock) internal {

    // calculate multiplier (# of unclaimed blocks)

    uint256 numBlocksToPayout = _currentBlock.sub(lastPaidBlock);



    IERC20(GTT_ADDRESS).transfer(currentKing, REWARD_PER_WIN.mul(numBlocksToPayout));

    IERC20(GTT_ADDRESS).transfer(CREATOR_ADDRESS, CREATOR_REWARD.mul(numBlocksToPayout));

  }

}