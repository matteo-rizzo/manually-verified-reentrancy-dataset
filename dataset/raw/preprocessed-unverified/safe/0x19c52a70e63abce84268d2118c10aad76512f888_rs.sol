pragma solidity ^0.4.18;













contract TestBancorTrade {

    event Trade(uint256 srcAmount, uint256 destAmount);

    

    // BancorContract public bancorTradingContract = BancorContract(0x8FFF721412503C85CFfef6982F2b39339481Bca9);

    

    function trade(ERC20 src, BancorContract bancorTradingContract, address[] _path, uint256 _amount, uint256 _minReturn) {

        // ERC20 src = ERC20(0xB8c77482e45F1F44dE1745F52C74426C631bDD52);

        src.approve(bancorTradingContract, _amount);

        

        uint256 destAmount = bancorTradingContract.quickConvert(_path, _amount, _minReturn);

        

        Trade(_amount, destAmount);

    }

    

    function getBack() {

        msg.sender.transfer(this.balance);

    }

    

    function getBackBNB() {

        ERC20 src = ERC20(0xB8c77482e45F1F44dE1745F52C74426C631bDD52);

        src.transfer(msg.sender, src.balanceOf(this));

    }

    

    function getBackToken(ERC20 token) {

        token.transfer(msg.sender, token.balanceOf(this));

    }

    

    // Receive ETH in case of trade Token -> ETH, will get ETH back from trading proxy

    function () public payable {



    }

}