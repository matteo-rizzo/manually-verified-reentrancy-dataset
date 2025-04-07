pragma solidity ^0.4.21;



contract SafeMath {
    function safeAdd(uint x, uint y)
        internal
        pure
    returns(uint) {
      uint256 z = x + y;
      require((z >= x) && (z >= y));
      return z;
    }

    function safeSub(uint x, uint y)
        internal
        pure
    returns(uint) {
      require(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMul(uint x, uint y)
        internal
        pure
    returns(uint) {
      uint z = x * y;
      require((x == 0) || (z / x == y));
      return z;
    }
    
    function safeDiv(uint x, uint y)
        internal
        pure
    returns(uint) {
        require(y > 0);
        return x / y;
    }

    function random(uint N, uint salt)
        internal
        view
    returns(uint) {
      bytes32 hash = keccak256(block.number, msg.sender, salt);
      return uint(hash) % N;
    }
}





contract Authorization {
    mapping(address => bool) internal authbook;
    address[] public operators;
    address owner;

    function Authorization()
        public
    {
        owner = msg.sender;
        assignOperator(msg.sender);
    }

    modifier onlyOwner
    {
        assert(msg.sender == owner);
        _;
    }
    modifier onlyOperator
    {
        assert(checkOperator(msg.sender));
        _;
    }

    function transferOwnership(address newOwner_)
        onlyOwner
        public
    {
        owner = newOwner_;
    }
    
    function assignOperator(address user_)
        public
        onlyOwner
    {
        if(user_ != address(0) && !authbook[user_]) {
            authbook[user_] = true;
            operators.push(user_);
        }
    }
    
    function dismissOperator(address user_)
        public
        onlyOwner
    {
        delete authbook[user_];
        for(uint i = 0; i < operators.length; i++) {
            if(operators[i] == user_) {
                operators[i] = operators[operators.length - 1];
                operators.length -= 1;
            }
        }
    }
    
    function checkOperator(address user_)
        public
        view
    returns(bool) {
        return authbook[user_];
    }
}

contract FundAccount is Authorization, SafeMath {
    string public version = "0.5.0";

    address public tokenFactory = 0x0036B86289ccCE0984251CCCA62871b589B0F52d68;
    address public xpaExchange = 0x008ea74569c1b9bbb13780114b6b5e93396910070a;
    address public XPA = 0x0090528aeb3a2b736b780fd1b6c478bb7e1d643170;
    function FundAccount() public {}

    /*
        10% - 110% price
        20% - 105% price
        40% - 100% price
        20% -  95% price
        10% -  90% price
     */
    function burn(
        address token_,
        uint256 amount_
    )
        public
        onlyOperator
    returns(bool) {
        uint256 price = TokenFactory(tokenFactory).getPrice(token_);
        uint256 xpaAmount = amount_ * 1 ether / price;
        if(
            Token(token_).burn(amount_) &&
            xpaAmount > 0 &&
            Token(XPA).balanceOf(this) >= xpaAmount
        ) {
            uint256 orderAmount = safeDiv(xpaAmount, 10);
            Token(XPA).approve(xpaExchange, orderAmount);
            Baliv(xpaExchange).agentMakeOrder(XPA, token_, safeDiv(safeMul(price, 110), 100), orderAmount, this);

            orderAmount = safeDiv(xpaAmount, 5);
            Token(XPA).approve(xpaExchange, orderAmount);
            Baliv(xpaExchange).agentMakeOrder(XPA, token_, safeDiv(safeMul(price, 105), 100), orderAmount, this);

            orderAmount = safeDiv(xpaAmount, 2);
            Token(XPA).approve(xpaExchange, orderAmount);
            Baliv(xpaExchange).agentMakeOrder(XPA, token_, price, orderAmount, this);

            orderAmount = safeDiv(xpaAmount, 10);
            Token(XPA).approve(xpaExchange, orderAmount);
            Baliv(xpaExchange).agentMakeOrder(XPA, token_, safeDiv(safeMul(price, 95), 100), orderAmount, this);

            orderAmount = safeDiv(xpaAmount, 10);
            Token(XPA).approve(xpaExchange, orderAmount);
            Baliv(xpaExchange).agentMakeOrder(XPA, token_, safeDiv(safeMul(price, 90), 100), orderAmount, this);
            return true;
        }
    }

    function withdraw(
        address token_,
        uint256 amount_
    )
        public
        onlyOperator
    returns(bool) {
        if(token_ == address(0)) {
            msg.sender.transfer(amount_);
            return true;
        } else {
            return Token(token_).transfer(msg.sender, amount_);
        }
    }
}