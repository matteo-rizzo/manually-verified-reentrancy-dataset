/**
 *Submitted for verification at Etherscan.io on 2021-03-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
















contract FIXToken is IERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isFirstSale;

    uint256 public constant SECONDS_PER_WEEK = 604800;

    uint256 private constant PERCENTAGE_MULTIPLICATOR = 1e4;

    uint8 private constant DEFAULT_DECIMALS = 6;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _firstUpdate;
    uint256 private _lastUpdate;

    uint256 private _growthRate;
    uint256 private _growthRate_after;

    uint256 private _price;

    uint256 private _presaleStart;
    uint256 private _presaleEnd;

    bool private _isStarted;

    uint256 [] _zeros;

    event TokensPurchased(address indexed purchaser, uint256 value, uint256 amount, uint256 price);
    event TokensSold(address indexed seller, uint256 amount, uint256 USDT, uint256 price);
    event PriceUpdated(uint price);


    constructor (uint256 _ownerSupply) public {
        _decimals = 18;
        _totalSupply = 500000000 * uint(10) ** _decimals;
        require (_ownerSupply < _totalSupply, "Owner supply must be lower than total supply");
        _name = "ProFIXone Token";
        _symbol = "FIX";
        _price = 1000000;
        _growthRate = 100;
        _balances[address(this)] = _totalSupply.sub(_ownerSupply);
        _balances[owner()] = _ownerSupply;
        emit Transfer(address(0), address(this), _totalSupply.sub(_ownerSupply));
        emit Transfer(address(0), owner(), _ownerSupply);
    }


    function name() public view returns (string memory) {
        return _name;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }


    function decimals() public view override returns (uint8) {
        return _decimals;
    }


    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (msg.sender != owner()) {
            require(recipient == owner(), "Tokens can be sent only to owner address.");
        }
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function calculatePrice() public view returns (uint256) {
        if (_isStarted == false || _firstUpdate > now) {
            return _price;
        }
        uint256 i;
        uint256 newPrice = _price;
        if (now > _lastUpdate) {
            i = uint256((_lastUpdate.sub(_firstUpdate)).div(SECONDS_PER_WEEK).add(uint256(1)).sub(_zeros.length));
            for (uint256 x = 0; x < i; x++) {
                newPrice = newPrice.mul(PERCENTAGE_MULTIPLICATOR.add(_growthRate)).div(PERCENTAGE_MULTIPLICATOR);
            }
            if (_growthRate_after > 0) {
                i = uint256((now.sub(_lastUpdate)).div(SECONDS_PER_WEEK));
                for (uint256 x = 0; x < i; x++) {
                    newPrice = newPrice.mul(PERCENTAGE_MULTIPLICATOR.add(_growthRate_after)).div(PERCENTAGE_MULTIPLICATOR);
                }
            }
        } else {
            i = uint256((now.sub(_firstUpdate)).div(SECONDS_PER_WEEK)).add(uint256(1));
            for (uint8 x = 0; x < _zeros.length; x++) {
                if (_zeros[x] >= _firstUpdate && _zeros[x] <= now) {
                    i = i.sub(uint256(1));
                }
            }
            for (uint256 x = 0; x < i; x++) {
                newPrice = newPrice.mul(PERCENTAGE_MULTIPLICATOR.add(_growthRate)).div(PERCENTAGE_MULTIPLICATOR);
            }

        }

        return newPrice;
    }


    function currentPrice() public view returns (uint256) {
        return calculatePrice();
    }

    function growthRate() public view returns (uint256) {
        return _growthRate_after;
    }


    function isStarted() public view returns (bool) {
        return _isStarted;
    }

    function presaleStart() public view returns (uint256) {
        return _presaleStart;
    }

    function presaleEnd() public view returns (uint256) {
        return _presaleEnd;
    }


    function startContract(uint256 firstUpdate, uint256 lastUpdate, uint256 [] memory zeros) external onlyOwner {
        require (_isStarted == false, "Contract is already started.");
        require (firstUpdate >= now, "First price update time must be later than today");
        require (lastUpdate >= now, "Last price update time must be later than today");
        require (lastUpdate > firstUpdate, "Last price update time must be later than first update");
        _firstUpdate = firstUpdate;
        _lastUpdate = lastUpdate;
        _isStarted = true;
        for (uint8 x = 0; x < zeros.length; x++) {
            _zeros.push(zeros[x]);
        }

    }

    function setPresaleStart(uint256 new_date) external onlyOwner {
        require (_isStarted == true, "Contract is not started.");
        require(new_date >= now, "Start time must be later, than now");
        require(new_date > _presaleStart, "New start time must be higher then previous.");
        _presaleStart = new_date;
    }

    function setPresaleEnd(uint256 new_date) external onlyOwner {
        require (_isStarted == true, "Contract is not started.");
        require(new_date >= now, "End time must be later, than now");
        require(new_date > _presaleEnd, "New end time must be higher then previous.");
        require(new_date > _presaleStart, "New end time must be higher then start date.");
        _presaleEnd = new_date;
    }


    function setGrowthRate(uint256 _newGrowthRate) external onlyOwner {
        require (_isStarted == true, "Contract is not started.");
        require(now > _lastUpdate, "Growth rate cannot be changed within 60 months");
        _growthRate_after =_newGrowthRate;
    }


    function calculateTokens(uint256 amount, uint8 coin_decimals, uint256 updatedPrice) public view returns(uint256) {
        uint256 result;
        if (coin_decimals >= DEFAULT_DECIMALS) {
            result = amount.mul(10 ** uint256(_decimals)).div(updatedPrice.mul(10 ** uint256(coin_decimals-DEFAULT_DECIMALS)));
        } else {
            result = amount.mul(10 ** uint256(_decimals)).div(updatedPrice.div(10 ** uint256(DEFAULT_DECIMALS-coin_decimals)));

        }
        if (now >= _presaleStart && now <= _presaleEnd) {
            if (amount >= uint256(1000).mul(10 ** uint256(coin_decimals))) {
                result.add(100 * uint(10) ** _decimals);
            }
        }

        return result;
    }


    function sendTokens(address recepient, uint256 amount, uint8 coinDecimals) external onlyOwner {
        require (_isStarted == true, "Contract is not started.");
        require (_presaleStart > 0, "Presale start not set");
        require (_presaleEnd > 0, "Presale end not set");
        require (coinDecimals > 0, "Stablecoin decimals must be grater than 0");
        require (amount > 0, "Stablecoin value cannot be zero.");
        require(recepient != address(0), "ERC20: transfer to the zero address");
        uint256 lastPrice = calculatePrice();
        uint FIXAmount = calculateTokens(amount.mul(99).div(100), coinDecimals, lastPrice);
        require(_balances[address(this)] >= FIXAmount, "Insufficinet FIX amount left on contract");
        _balances[address(this)] = _balances[address(this)].sub(FIXAmount, "ERC20: transfer amount exceeds balance");
        _balances[recepient] = _balances[recepient].add(FIXAmount);
        emit TokensPurchased(recepient, amount, FIXAmount, lastPrice);
        emit Transfer(address(this), recepient, FIXAmount);

    }

    function sellTokens(address stablecoin, uint256 amount) external {
        require (_isStarted == true, "Contract is not started.");
        require (_presaleStart > 0, "Presale start not set");
        require (_presaleEnd > 0, "Presale end not set");
        require (amount > 0, "FIX value cannot be zero.");
        require(msg.sender != address(0), "ERC20: transfer to the zero address");
        require(stablecoin != address(0), "Stablecoin must not be zero address");
        require(stablecoin.isContract(), "Not a valid stablecoin contract address");
        uint256 coin_amount;
        uint256 new_amount = amount;
        IERC20 coin = IERC20(stablecoin);
        uint8 coin_decimals = coin.decimals();
        uint256 lastPrice = calculatePrice();
        if (!_isFirstSale[msg.sender]) {
            new_amount = amount.mul(98).div(100);
            _isFirstSale[msg.sender] = true;
        }
        require (_balances[msg.sender] >= amount, "Insufficient FIX token amount");
        if (coin_decimals >= 12) {
            coin_amount = new_amount.div(lastPrice).mul(10 ** uint256(coin_decimals-12));
        } else {
            coin_amount = new_amount.div(lastPrice).div(10 ** uint256(12 - coin_decimals));
        }

        _balances[address(this)] = _balances[address(this)].add(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        emit Transfer(msg.sender, address(this), amount);
        emit TokensSold(msg.sender, amount, coin_amount, lastPrice);
    }

}