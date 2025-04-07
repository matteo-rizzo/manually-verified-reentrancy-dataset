pragma solidity ^0.4.18;



contract InterfaceContentCreatorUniverse {
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function priceOf(uint256 _tokenId) public view returns (uint256 price);
  function getNextPrice(uint price, uint _tokenId) public pure returns (uint);
  function lastSubTokenBuyerOf(uint tokenId) public view returns(address);
  function lastSubTokenCreatorOf(uint tokenId) public view returns(address);

  //
  function createCollectible(uint256 tokenId, uint256 _price, address creator, address owner) external ;
}

contract InterfaceYCC {
  function payForUpgrade(address user, uint price) external  returns (bool success);
  function mintCoinsForOldCollectibles(address to, uint256 amount, address universeOwner) external  returns (bool success);
  function tradePreToken(uint price, address buyer, address seller, uint burnPercent, address universeOwner) external;
  function payoutForMining(address user, uint amount) external;
  uint256 public totalSupply;
}

contract InterfaceMining {
  function createMineForToken(uint tokenId, uint level, uint xp, uint nextLevelBreak, uint blocknumber) external;
  function payoutMining(uint tokenId, address owner, address newOwner) external;
  function levelUpMining(uint tokenId) external;
}





contract TransferInterfaceERC721YC {
  function transferToken(address to, uint256 tokenId) public returns (bool success);
}
contract TransferInterfaceERC20 {
  function transfer(address to, uint tokens) public returns (bool success);
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ConsenSys/Tokens/blob/master/contracts/eip20/EIP20.sol
// ----------------------------------------------------------------------------
contract YouCollectBase is Owned {
  using SafeMath for uint256;

  event RedButton(uint value, uint totalSupply);

  // Payout
  function payout(address _to) public onlyCLevel {
    _payout(_to, this.balance);
  }
  function payout(address _to, uint amount) public onlyCLevel {
    if (amount>this.balance)
      amount = this.balance;
    _payout(_to, amount);
  }
  function _payout(address _to, uint amount) private {
    if (_to == address(0)) {
      ceoAddress.transfer(amount);
    } else {
      _to.transfer(amount);
    }
  }

  // ------------------------------------------------------------------------
  // Owner can transfer out any accidentally sent ERC20 tokens
  // ------------------------------------------------------------------------
  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyCEO returns (bool success) {
      return TransferInterfaceERC20(tokenAddress).transfer(ceoAddress, tokens);
  }
}


contract Donate is YouCollectBase {
  mapping (uint256 => address) public tokenIndexToOwner;
  mapping (uint256 => uint256) public tokenIndexToPrice;
  mapping (uint256 => address) public donateAddress;
  mapping (uint256 => address) public tokenWinner;
  uint256 donateTokenCount;
  uint256 highestPrice = 0.001 ether;
  address public nextRoundWinner;

  uint256 lastBuyBlock;
  uint256 roundDelay = 1999;
  bool started = false;
    
  event TokenSold(uint256 indexed tokenId, uint256 price, address prevOwner, address winner);

  /*** CONSTRUCTOR ***/
  function Donate() public {
  }

  /// For creating Collectibles
  function addDonateTokenAddress(address adr) external onlyCEO {
    donateTokenCount = donateTokenCount.add(1);
    donateAddress[donateTokenCount] = adr;
  }
  function updateDonateTokenAddress(address adr, uint256 tokenId) external onlyCEO {
    donateAddress[tokenId] = adr;
  }
  function changeRoundDelay(uint256 delay) external onlyCEO {
    roundDelay = delay;
  }

  function getBlocksUntilNextRound() public view returns(uint) {
    if (lastBuyBlock+roundDelay<block.number)
      return 0;
    return lastBuyBlock + roundDelay - block.number + 1;
  }
  function start() public onlyCEO {
    started = true;
    startNextRound();
  }
  
  function startNextRound() public {
    require(started);
    require(lastBuyBlock+roundDelay<block.number);
    tokenIndexToPrice[0] = highestPrice;
    tokenIndexToOwner[0] = nextRoundWinner;
    tokenWinner[0] = tokenIndexToOwner[0];
    
    for (uint index = 1; index <= donateTokenCount; index++) {
      tokenIndexToPrice[index] = 0.001 ether;
      tokenWinner[index] = tokenIndexToOwner[index];
    }
    highestPrice = 0.001 ether;
    lastBuyBlock = block.number;
  }

  function getNextPrice(uint price) public pure returns (uint) {
    if (price < 1 ether)
      return price.mul(200).div(87);
    return price.mul(120).div(87);
  }

  function buyToken(uint _tokenId) public payable {
    address oldOwner = tokenIndexToOwner[_tokenId];
    uint256 sellingPrice = tokenIndexToPrice[_tokenId];
    require(oldOwner!=msg.sender);
    require(msg.value >= sellingPrice);
    require(sellingPrice > 0);

    uint256 purchaseExcess = msg.value.sub(sellingPrice);
    uint256 payment = sellingPrice.mul(87).div(100);
    uint256 feeOnce = sellingPrice.sub(payment).div(13);
    uint256 feeThree = feeOnce.mul(3);
    uint256 nextPrice = getNextPrice(sellingPrice);
    // Update prices
    tokenIndexToPrice[_tokenId] = nextPrice;
    // Transfers the Token
    tokenIndexToOwner[_tokenId] = msg.sender;
    lastBuyBlock = block.number;
    if (_tokenId > 0) {
      // Taxes for last round winner or new owner of the All-Donate-Token
      if (tokenIndexToOwner[0]!=address(0))
        tokenIndexToOwner[0].transfer(feeThree);
      // Check for new winner of this round
      if (nextPrice > highestPrice) {
        highestPrice = nextPrice;
        nextRoundWinner = msg.sender;
      }
    }
    // Donation
    donateAddress[_tokenId].transfer(feeThree);
    // Taxes for last round token winner 
    if (tokenWinner[_tokenId]!=address(0))
      tokenWinner[_tokenId].transfer(feeThree);
    // Taxes for universe
    yct.ownerOf(0).transfer(feeOnce);
    // Payment for old owner
    if (oldOwner != address(0)) {
      oldOwner.transfer(payment);
    }

    TokenSold(_tokenId, sellingPrice, oldOwner, msg.sender);

    // refund when paid too much
    if (purchaseExcess>0)
      msg.sender.transfer(purchaseExcess);
  }


  function getCollectibleWithMeta(uint256 tokenId) public view returns (uint256 _tokenId, uint256 sellingPrice, address owner, uint256 nextSellingPrice, address _tokenWinner, address _donateAddress) {
    _tokenId = tokenId;
    sellingPrice = tokenIndexToPrice[tokenId];
    owner = tokenIndexToOwner[tokenId];
    nextSellingPrice = getNextPrice(sellingPrice);
    
    _tokenWinner = tokenWinner[tokenId];
    _donateAddress = donateAddress[tokenId];
  }

}