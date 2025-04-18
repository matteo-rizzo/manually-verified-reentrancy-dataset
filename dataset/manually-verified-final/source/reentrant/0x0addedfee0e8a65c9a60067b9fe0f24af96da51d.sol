library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "addition overflow");
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a, "subtraction overflow");
        c = a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b, "multiplication overflow");
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0, "division by zero");
        c = a / b;
    }
}

interface ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256 remaining);
    function transfer(address to, uint256 tokens)
        external
        returns (bool success);
    function approve(address spender, uint256 tokens)
        external
        returns (bool success);
    function transferFrom(address from, address to, uint256 tokens)
        external
        returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 tokens
    );
}

interface ApproveAndCallFallBack {
    function receiveApproval(
        address from,
        uint256 tokens,
        address token,
        bytes calldata data
    ) external;
}

interface MedianiserInterface {
    function peek() external view returns (bytes32, bool);
}

contract PEG is ERC20Interface, Owned {
    using SafeMath for uint256;
    uint256 private constant MAX_UINT256 = 2**256 - 1;

    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 _totalSupply;
    uint256 lastPriceAdjustment;
    uint256 timeBetweenPriceAdjustments;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    MedianiserInterface medianiser;

    event Burn(address indexed owner, uint256 tokens);
    event gotPEG(
        address indexed caller,
        uint256 amountGivenEther,
        uint256 amountReceivedPEG
    );
    event gotEther(
        address indexed caller,
        uint256 amountGivenPEG,
        uint256 amountReceivedEther
    );
    event Inflate(uint256 previousPoolSize, uint256 amountMinted);
    event Deflate(uint256 previousPoolSize, uint256 amountBurned);
    event NoAdjustment();
    event FailedAdjustment();

    constructor(
        address medianiserAddress,
        uint256 setTimeBetweenPriceAdjustments
    ) public payable {
        symbol = "PEG";
        name = "PEG Stablecoin";
        decimals = 18;
        lastPriceAdjustment = now;
        timeBetweenPriceAdjustments = setTimeBetweenPriceAdjustments;

        medianiser = MedianiserInterface(medianiserAddress);

        uint256 feedPrice;
        bool priceIsValid;
        (feedPrice, priceIsValid) = getOraclePriceETH_USD();
        require(priceIsValid, "oracle failure");

        _totalSupply = feedPrice.mul(address(this).balance).div(
            10**uint256(decimals)
        );
        balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[owner];
    }

    function transfer(address to, uint256 tokens)
        public
        canTriggerPriceAdjustment
        override
        returns (bool success)
    {
        require(to != address(0), "can't send to 0 address, use burn");
        if (to == address(this)) getEther(tokens);
        else {
            balances[msg.sender] = balances[msg.sender].sub(tokens);
            balances[to] = balances[to].add(tokens);
            emit Transfer(msg.sender, to, tokens);
        }
        return true;
    }

    function burn(uint256 tokens) public canTriggerPriceAdjustment returns (bool success) {
        _totalSupply = _totalSupply.sub(tokens);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        emit Burn(msg.sender, tokens);
        emit Transfer(msg.sender, address(0), tokens);
        return true;
    }

    function approve(address spender, uint256 tokens)
        public
        canTriggerPriceAdjustment
        override
        returns (bool success)
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint256 tokens)
        public
        canTriggerPriceAdjustment
        override
        returns (bool success)
    {
        require(to != address(0), "can't send to 0 address, use burn");
        require(to != address(this), "can't transfer to self");
        balances[from] = balances[from].sub(tokens);
        if (allowed[from][msg.sender] < MAX_UINT256) {
            allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        }
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256 allowancePEG)
    {
        return allowed[owner][spender];
    }

    function approveAndCall(address spender, uint256 tokens, bytes memory data)
        public
        canTriggerPriceAdjustment
        returns (bool success)
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(
            msg.sender,
            tokens,
            address(this),
            data
        );
        return true;
    }

    receive () external payable {
        getPEG();
    }

    modifier canTriggerPriceAdjustment {
        _;
        if (now >= lastPriceAdjustment + timeBetweenPriceAdjustments)
            priceFeedAdjustment();
    }

    function getNextPriceAdjustmentTime()
        public
        view
        returns (uint256 nextPriceAdjustmentTime)
    {
        if (now >= lastPriceAdjustment + timeBetweenPriceAdjustments) return 0;
        else return lastPriceAdjustment + timeBetweenPriceAdjustments - now;
    }

    function getPEG()
        public
        payable
        canTriggerPriceAdjustment
        returns (bool success, uint256 amountReceivedPEG)
    {
        amountReceivedPEG = balances[address(this)]
            .mul(msg.value.mul(10**8).div(address(this).balance))
            .div(10**8);
        balances[address(this)] = balances[address(this)].sub(
            amountReceivedPEG
        );
        balances[msg.sender] = balances[msg.sender].add(amountReceivedPEG);
        emit gotPEG(msg.sender, msg.value, amountReceivedPEG);
        emit Transfer(address(this), msg.sender, amountReceivedPEG);
        return (true, amountReceivedPEG);
    }

    function getEther(uint256 amountGivenPEG)
        public
        canTriggerPriceAdjustment
        returns (bool success, uint256 amountReceivedEther)
    {
        amountReceivedEther = address(this)
            .balance
            .mul(
            amountGivenPEG.mul(10**8).div(
                balances[address(this)].add(amountGivenPEG)
            )
        )
            .div(10**8);
        balances[address(this)] = balances[address(this)].add(amountGivenPEG);
        msg.sender.call.value(1)("");	
balances[msg.sender] = balances[msg.sender].sub(amountGivenPEG);
        emit gotEther(msg.sender, amountGivenPEG, amountReceivedEther);
        emit Transfer(msg.sender, address(this), amountGivenPEG);
        msg.sender.transfer(amountReceivedEther);
        return (true, amountReceivedEther);
    }

    function getPoolBalances()
        public
        view
        returns (uint256 balanceETH, uint256 balancePEG)
    {
        return (address(this).balance, balanceOf(address(this)));
    }

    function inflateEtherPool() public payable returns (bool success) {
        return true;
    }

    function getOraclePriceETH_USD()
        public
        view
        returns (uint256 priceETH_USD, bool priceIsValid)
    {
        bytes32 price;
        (price, priceIsValid) = medianiser.peek();
        return (uint256(price), priceIsValid);
    }

    function priceFeedAdjustment() private returns (uint256 newPoolPEG) {
        uint256 feedPrice;
        bool priceIsValid;
        (feedPrice, priceIsValid) = getOraclePriceETH_USD();

        if (!priceIsValid) {
            newPoolPEG = balances[address(this)];
            lastPriceAdjustment = now;
            emit FailedAdjustment();
            return (newPoolPEG);
        }

        feedPrice = feedPrice.mul(address(this).balance).div(
            10**uint256(decimals)
        );
        if (feedPrice > (balances[address(this)] / 100) * 101) {
            uint256 posDelta = feedPrice.sub(balances[address(this)]).div(10);
            newPoolPEG = balances[address(this)].add(posDelta);
            emit Inflate(balances[address(this)], posDelta);
            emit Transfer(address(0), address(this), posDelta);
            balances[address(this)] = newPoolPEG;
            _totalSupply = _totalSupply.add(posDelta);
        } else if (feedPrice < (balances[address(this)] / 100) * 99) {
            uint256 negDelta = balances[address(this)].sub(feedPrice).div(10);
            newPoolPEG = balances[address(this)].sub(negDelta);
            emit Deflate(balances[address(this)], negDelta);
            emit Transfer(address(this), address(0), negDelta);
            balances[address(this)] = newPoolPEG;
            _totalSupply = _totalSupply.sub(negDelta);
        } else {
            newPoolPEG = balances[address(this)];
            emit NoAdjustment();
        }
        lastPriceAdjustment = now;
    }

    function transferAnyERC20Token(address tokenAddress, uint256 tokens)
        public
        onlyOwner
        returns (bool success)
    {
        require(tokenAddress != address(this), "can't withdraw PEG");
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}
