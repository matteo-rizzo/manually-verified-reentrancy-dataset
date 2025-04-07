/**
 *Submitted for verification at Etherscan.io on 2020-09-06
*/

pragma solidity 0.7.0;




contract LOCKPreSale  {
    using SafeMath for uint256;

    uint256 constant MIN_BUY = 1 * 10**18;
    uint256 constant MAX_BUY = 100 * 10**18;
    uint256 constant  PRICE = 116 * 10**13;
    uint256 public  HARD_CAP = 700 * 10**18 ;

    address payable  receiver ;
 
    uint256 public totalSold   = 0;
    uint256 public totalRaised = 0;

    event onBuy(address buyer , uint256 amount);

    mapping(address => uint256) public boughtOf;

    constructor() public {
      receiver = msg.sender;
    }

    function buyToken() public payable {
        require(msg.value >= MIN_BUY , "MINIMUM IS 1 ETH");
        require(msg.value <= MAX_BUY , "MAXIMUM IS 15 ETH");
        require(totalRaised + msg.value <= HARD_CAP , "HARD CAP REACHED");

        uint256 amount = (msg.value.div(PRICE)) * 10 ** 18;

        boughtOf[msg.sender] += amount;
        totalSold += amount;
        totalRaised += msg.value;
        
        receiver.transfer(msg.value);

        emit onBuy(msg.sender , amount);
    }

}