/**
 *Submitted for verification at Etherscan.io on 2020-10-21
*/

pragma solidity ^0.5.0;








// https://docs.synthetix.io/contracts/SafeDecimalMath


contract IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);

    function mint(address account, uint256 amount) public returns (bool);

    function burn(uint256 amount) public returns (bool);
}


contract YFC_Presale is Ownable {
    address private yfcCoinddress;
    uint256 private price;
    address private messenger;

    using SafeMath for uint256;
using SafeDecimalMath for uint;
    constructor(address _yfcCoinddress, uint256 _initialPrice) public {
        yfcCoinddress = _yfcCoinddress;
        price = _initialPrice;
    }

    event bought(address _buyer, uint256 _paid, uint256 _given);
    event priceChanged(address initiator, uint256 _from, uint256 _to);
    event messengerChanged(address _from, address _to);
    modifier onlyMessenger() {
        require(msg.sender == messenger, "caller is not a messenger");
        _;
    }

    function updatePrice(uint256 _price) public onlyMessenger {
        uint256 currentprice = price;
        price = _price;
        emit priceChanged(msg.sender, currentprice, _price);
    }

    function setMessenger(address _messenger) public onlyOwner {
        address currentMessenger = messenger;
        messenger = _messenger;
        emit messengerChanged(currentMessenger, _messenger);
    }

    function setYFCCoin(address _yfcCoinddress) public onlyOwner {
        yfcCoinddress = _yfcCoinddress;
    }

    function getPrice() public view returns (uint256 _price) {
        return price;
    }

    function buyer() public payable {
        require(msg.value > 0, "Invalid amount");
        uint256 amount = msg.value; //.mul(10**18);
        IERC20 YFCCoin = IERC20(yfcCoinddress);
        uint256 amountToSend = amount.divideDecimal(price).multiplyDecimal(10**18);
        require(
            YFCCoin.transfer(msg.sender, amountToSend),
            "Fail to send fund"
        );
        emit bought(msg.sender, msg.value, amountToSend);
    }

    function withdrawAllEtherByOwner() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function getContractEtherBalance() public view returns (uint256) {
        return address(this).balance;
    }
}