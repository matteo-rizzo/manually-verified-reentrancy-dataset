/**
 *Submitted for verification at Etherscan.io on 2021-10-02
*/

pragma solidity ^0.8.6;

//SPDX-License-Identifier: MIT Licensed
//HJAELPCOIN - Pre-sale  DApp





contract preSaleHJAELP {
    using SafeMath for uint256;

    IERC20 public token;
    AggregatorV3Interface public priceFeedeth;

    address payable public owner;

    uint256 public tokensPerEth;
    uint256 public minAmount;
    uint256 public maxAmount;
    uint256 public preSaleStartTime;
    uint256 public preSaleEndTime;
    uint256 public soldToken;
    uint256 public amountRaisedEth;
    uint256 public totalusers;

    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not an owner");
        _;
    }

    mapping(address => uint256) public coinBalance;

    event BuyToken(address indexed _user, uint256 indexed _amount);

    constructor(address payable _owner, IERC20 _token) {
        owner = _owner;
        token = _token;
        priceFeedeth = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        tokensPerEth = 333333;
        minAmount = 0.02 ether;
        maxAmount = 8 ether;
        preSaleStartTime = block.timestamp;
        preSaleEndTime = preSaleStartTime + 30 days;
    }

    receive() external payable {}

    // to get real time price of eth
    function getLatestPriceEth() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedeth.latestRoundData();
        return uint256(price);
    }

    // to buy token during preSale time => for web3 use

    function buyToken() public payable {
        require(
            block.timestamp >= preSaleStartTime &&
                block.timestamp < preSaleEndTime,
            "PRESALE: PreSale time not met"
        );
        require(
            coinBalance[msg.sender].add(msg.value) <= maxAmount,
            "PRESALE: Amount exceeds max limit"
        );
        require(
            msg.value >= minAmount && msg.value <= maxAmount,
            "PRESALE: Amount not correct"
        );
        if (token.balanceOf(msg.sender) == 0) {
            totalusers++;
        }

        uint256 numberOfTokens = ethToToken(msg.value);
        token.transferFrom(owner, msg.sender, numberOfTokens);
        soldToken = soldToken.add(numberOfTokens);
        amountRaisedEth = amountRaisedEth.add(msg.value);
        coinBalance[msg.sender] = coinBalance[msg.sender].add(msg.value);

        emit BuyToken(msg.sender, numberOfTokens);
    }

    // to check number of token for given eth
    function ethToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = _amount.mul(tokensPerEth);
        return numberOfTokens;
    }

    // to change Price of the token
    function changePrice(uint256 _price) external onlyOwner {
        tokensPerEth = _price;
    }

    // to change preSale amount limits
    function setPreSaletLimits(uint256 _minAmount, uint256 _maxAmount)
        external
        onlyOwner
    {
        minAmount = _minAmount;
        maxAmount = _maxAmount;
    }

    // to change preSale time duration
    function setPreSaleTime(uint256 _startTime, uint256 _endTime)
        external
        onlyOwner
    {
        preSaleStartTime = _startTime;
        preSaleEndTime = _endTime;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function changePriceFeed(address  _newPriceFeed) external onlyOwner {
        priceFeedeth = AggregatorV3Interface(_newPriceFeed);
    }

    function changeToken(address  _newToken) external onlyOwner {
        token = IERC20(_newToken);
    }

    // to draw funds for liquidity
    function transferFunds(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    // to draw out tokens
    function transferTokens(uint256 _value) external onlyOwner {
        token.transfer(owner, _value);
    }

    // to get current UTC time
    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    function contractBalanceEth() external view returns (uint256) {
        return address(this).balance;
    }

    function getContractTokenApproval() external view returns (uint256) {
        return token.allowance(owner, address(this));
    }
}

