pragma solidity ^0.4.23;











contract Erc20Wrapper {

    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);

    function allowance(address _owner, address _spender) public view returns (uint256);



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract LemurTokenSale is Ownable {

    using SafeMath for uint256;



    Erc20Wrapper public token;



    address public wallet;



    uint256 public rate;

    uint256 public amountRaised;



    uint256 public openingTime;

    uint256 public closingTime;



    event TokenPurchase(address indexed _purchaser, address indexed _beneficiary, uint256 _value, uint256 _amount);



    constructor() public {

        // solium-disable-next-line security/no-block-members

        openingTime = block.timestamp;

        closingTime = openingTime.add(90 days);

    }



    function setToken(Erc20Wrapper _token) onlyOwner public {

        require(_token != address(0));

        token = _token;

    }



    function setWallet(address _wallet) onlyOwner public {

        require(_wallet != address(0));

        wallet = _wallet;

    }



    function setRate(uint256 _rate) onlyOwner public {

        require(_rate > 0);

        rate = _rate;

    }



    function setClosingTime(uint256 _days) onlyOwner public {

        require(_days >= 1);

        closingTime = openingTime.add(_days.mul(1 days));

    }



    function hasClosed() public view returns (bool) {

        // solium-disable-next-line security/no-block-members

        return block.timestamp > closingTime;

    }



    function () external payable {

        buyTokens(msg.sender);

    }



    function buyTokens(address _beneficiary) public payable {

        require(!hasClosed());

        require(token != address(0) && wallet != address(0) && rate > 0);

        require(_beneficiary != address(0));



        uint256 amount = msg.value;

        require(amount >= 0.01 ether);



        uint256 tokenAmount = amount.mul(rate);

        amountRaised = amountRaised.add(amount);

        require(token.transfer(_beneficiary, tokenAmount));



        emit TokenPurchase(msg.sender, _beneficiary, amount, tokenAmount);



        wallet.transfer(amount);

    }

}