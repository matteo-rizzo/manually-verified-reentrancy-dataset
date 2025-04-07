/**

 *Submitted for verification at Etherscan.io on 2019-02-04

*/



pragma solidity 0.4.25;















contract Trade is Ownable {

    using SafeMath for uint;

    uint public cursETHtoUSD = 15000;

    uint public costClientBuyETH = 1 ether / 10000;

    uint public costClientSellETH = 1 ether / 100000;

    uint public costClientBuyUSD = costClientBuyETH * cursETHtoUSD / 100;

    uint public costClientSellUSD = costClientSellETH * cursETHtoUSD / 100;

    uint private DEC = 10 ** 18;

    bool public clientBuyOpen = true;

    bool public clientSellOpen = true;

    uint public clientBuyTimeWorkFrom = 1545264000;

    uint public clientBuyTimeWork = 24 hours;

    uint public clientSellTimeWorkFrom = 1545264000;

    uint public clientSellTimeWork = 24 hours;

    address public tokenAddress;



    event clientBuy(address user, uint valueETH, uint amount);

    event clientSell(address user, uint valueETH, uint amount);

    event Deposit(address user, uint value);

    event DepositToken(address user, uint value);

    event WithdrawEth(address user, uint value);

    event WithdrawTokens(address user, uint value);



    modifier buyIsOpen() {

        require(clientBuyOpen == true, "Buying are closed");

        require((now - clientBuyTimeWorkFrom) % 24 hours <= clientBuyTimeWork, "Now buying are closed");

        _;

    }



    modifier sellIsOpen() {

        require(clientSellOpen == true, "Selling are closed");

        require((now - clientSellTimeWorkFrom) % 24 hours <= clientSellTimeWork, "Now selling are closed");

        _;

    }



    function updateCursETHtoUSD(uint _value) onlyOwner public {

        cursETHtoUSD = _value;

        costClientBuyUSD = costClientBuyETH.mul(cursETHtoUSD).div(100);

        costClientSellUSD = costClientSellETH.mul(cursETHtoUSD).div(100);

    }



    function contractSalesAtUsd(uint _value) onlyOwner public {

        costClientBuyUSD = _value;

        costClientBuyETH = costClientBuyUSD.div(cursETHtoUSD).mul(100);

    }



    function contractBuysAtUsd(uint _value) onlyOwner public {

        costClientSellUSD = _value;

        costClientSellETH = costClientSellUSD.div(cursETHtoUSD).mul(100);

    }



    function contractSalesAtEth(uint _value) onlyOwner public {

        costClientBuyETH = _value;

        costClientBuyUSD = costClientBuyETH.mul(cursETHtoUSD).div(100);

    }



    function contractBuysAtEth(uint _value) onlyOwner public {

        costClientSellETH = _value;

        costClientSellUSD = costClientSellETH.mul(cursETHtoUSD).div(100);

    }



    function closeClientBuy() onlyOwner public {

        clientBuyOpen = false;

    }



    function openClientBuy() onlyOwner public {

        clientBuyOpen = true;

    }



    function closeClientSell() onlyOwner public {

        clientSellOpen = false;

    }



    function openClientSell() onlyOwner public {

        clientSellOpen = true;

    }



    function setClientBuyingTime(uint _from, uint _time) onlyOwner public {

        clientBuyTimeWorkFrom = _from;

        clientBuyTimeWork = _time;

    }



    function setClientSellingTime(uint _from, uint _time) onlyOwner public {

        clientSellTimeWorkFrom = _from;

        clientSellTimeWork = _time;

    }



    function contractSellTokens() buyIsOpen payable public {

        require(msg.value > 0, "ETH amount must be greater than 0");



        uint amount = msg.value.mul(DEC).div(costClientBuyETH);



        require(IERC20(tokenAddress).balanceOf(this) >= amount, "Not enough tokens");



        IERC20(tokenAddress).transfer(msg.sender, amount);



        emit clientBuy(msg.sender, msg.value, amount);

    }



    function() external payable {

        contractSellTokens();

    }



    function contractBuyTokens(uint amount) sellIsOpen public {

        require(amount > 0, "Tokens amount must be greater than 0");

        require(IERC20(tokenAddress).balanceOf(msg.sender) >= amount, "Not enough tokens on balance");



        uint valueETH = amount.mul(costClientSellETH).div(DEC);

        require(valueETH <= address(this).balance, "Not enough balance on the contract");



        IERC20(tokenAddress).transferTrade(msg.sender, this, amount);

        msg.sender.transfer(valueETH);



        emit clientSell(msg.sender, valueETH, amount);

    }



    function contractBuyTokensFrom(address from, uint amount) sellIsOpen public {

        require(keccak256(msg.sender) == keccak256(tokenAddress), "Only for token");

        require(amount > 0, "Tokens amount must be greater than 0");

        require(IERC20(tokenAddress).balanceOf(from) >= amount, "Not enough tokens on balance");



        uint valueETH = amount.mul(costClientSellETH).div(DEC);

        require(valueETH <= address(this).balance, "Not enough balance on the contract");



        IERC20(tokenAddress).transferTrade(from, this, amount);

        from.transfer(valueETH);



        emit clientSell(from, valueETH, amount);

    }



    function withdrawEth(address to, uint256 value) onlyOwner public {

        require(address(this).balance >= value, "Not enough balance on the contract");

        to.transfer(value);



        emit WithdrawEth(to, value);

    }



    function withdrawTokens(address to, uint256 value) onlyOwner public {

        require(IERC20(tokenAddress).balanceOf(this) >= value, "Not enough token balance on the contract");



        IERC20(tokenAddress).transferTrade(this, to, value);



        emit WithdrawTokens(to, value);

    }



    function depositEther() onlyOwner payable public {

        emit Deposit(msg.sender, msg.value);

    }



    function depositToken(uint _value) onlyOwner public {

        IERC20(tokenAddress).transferTrade(msg.sender, this, _value);

    }



    function changeTokenAddress(address newTokenAddress) onlyOwner public {

        tokenAddress = newTokenAddress;

    }

}