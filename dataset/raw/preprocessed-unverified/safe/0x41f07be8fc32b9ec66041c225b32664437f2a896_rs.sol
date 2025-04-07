/**
 *Submitted for verification at Etherscan.io on 2020-04-24
*/

pragma solidity ^0.5.0;








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


contract EgorasTokenSale is Ownable {
    address private egorasCoinddress;
    uint256 private price;
    address private messenger;

    using SafeMath for uint256;

    constructor(address _egorasCoinddress, uint256 _initialPrice) public {
        egorasCoinddress = _egorasCoinddress;
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

    function setEgorasCoin(address _egorasCoinddress) public onlyOwner {
        egorasCoinddress = _egorasCoinddress;
    }

    function getPrice() public view returns (uint256 _price) {
        return price;
    }

    function buyer() public payable {
        require(msg.value > 0, "Invalid amount");
        uint256 amount = msg.value.mul(10**18);
        IERC20 egorasCoin = IERC20(egorasCoinddress);
        uint256 amountToSend = amount.div(price).mul(10**18);
        require(
            egorasCoin.transfer(msg.sender, amountToSend),
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