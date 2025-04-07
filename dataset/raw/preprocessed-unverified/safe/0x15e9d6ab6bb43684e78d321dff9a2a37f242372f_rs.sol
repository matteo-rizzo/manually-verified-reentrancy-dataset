/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity ^0.4.25;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





contract CoooinsCoinAd {



  using SafeMath for uint256;



  uint256 public coinId;

  uint256 public purchaseTimestamp;

  uint256 public purchaseSeconds;

  uint256 public adPriceDay;

  uint256 public adPriceWeek;

  uint256 public adPriceMonth;

  uint256 public adPriceMultiple;

  address public contractOwner;



  event newAd(address indexed buyer, uint256 amount, uint256 indexed coinId, uint256 purchaseSeconds, uint256 purchaseTimestamp, uint256 adPriceMultiple);



  modifier onlyContractOwner {

    require(msg.sender == contractOwner);

    _;

  }



  constructor() public {

    adPriceDay = 10000000000000000;

    adPriceWeek = 50000000000000000;

    adPriceMonth = 150000000000000000;

    adPriceMultiple = 1;

    contractOwner = 0x2E26a4ac59094DA46a0D8d65D90A7F7B51E5E69A;

  }



  function withdraw() public onlyContractOwner {

    contractOwner.transfer(address(this).balance);

  }



  function setAdPriceMultiple(uint256 amount) public onlyContractOwner {

    adPriceMultiple = amount;

  }



  function updateAd(uint256 id) public payable {

    // set minimum amount and make sure ad hasnt expired

    require(msg.value >= adPriceMultiple.mul(adPriceDay));

    require(block.timestamp > purchaseTimestamp.add(purchaseSeconds));

    require(id > 0);



    // set ad time limit in seconds

    if (msg.value >= adPriceMultiple.mul(adPriceMonth)) {

      purchaseSeconds = 2592000; // 1 month

    } else if (msg.value >= adPriceMultiple.mul(adPriceWeek)) {

      purchaseSeconds = 604800; // 1 week

    } else {

      purchaseSeconds = 86400; // 1 day

    }



    coinId = id;

    purchaseTimestamp = block.timestamp;



    emit newAd(msg.sender, msg.value, coinId, purchaseSeconds, purchaseTimestamp, adPriceMultiple);

  }



  function getPurchaseTimestampEnds() public view returns (uint _getPurchaseTimestampAdEnds) {

    return purchaseTimestamp.add(purchaseSeconds);

  }



  function getBalance() public view returns(uint256){

    return address(this).balance;

  }



}