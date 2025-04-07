/**
 *Submitted for verification at Etherscan.io on 2021-04-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;





abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Owned is Context {
    address private _owner;
    address private _operator;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier ownerOnly {
        require(_owner == _msgSender() || _msgSender() == _operator, "not allowed");
        _;
    }


    modifier pendingOnly {
        require (_pendingOwner == msg.sender, "cannot claim");
        _;
    }

    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    function renounceOwnership() public virtual ownerOnly {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public ownerOnly {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _pendingOwner = newOwner;
    }

    function cancelTransfer() public ownerOnly {
        require(_pendingOwner != address(0), "no pending owner");
        _pendingOwner = address(0);
    }

    function claimOwnership() public pendingOnly {
        _pendingOwner = address(0);
        emit OwnershipTransferred(_owner, _msgSender());
        _owner = _msgSender();
    }


}





interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}









contract MUSKITO is IERC20, Owned {

    using Address for address;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    IStates.Balances balances;
    IStates.Divisors divisors;
    ITValues.TState lastTState;

    EnumerableSet.AddressSet excludedAccounts;
    EnumerableSet.AddressSet blackListedBots;


    address private _op;
    address private _donations;
    address private _router;
    address public  _pool;
    address private _pair;

    uint256 private _lastFee;
    uint256 public buys;
    uint256 public burns;


    bool private _paused;
    bool private _lpAdded;

    mapping(address => IStates.Account) accounts;
    mapping(address => mapping(address => uint256)) allowances;

    constructor() {

        _name = "MUSKITO Token";
        _symbol = "MUSKITO";
        _decimals = 18;

        balances.tokenSupply = 1_000_000_000 ether;
        balances.networkSupply = (~uint256(0) - (~uint256(0) % balances.tokenSupply));

        divisors.tx = 50;    // 2%
        divisors.sell = 100;  // 1%
        divisors.buy = 100;   // 1%
        divisors.burn = 100; // 1%
        divisors.donate = 100;   // 1%

        _router = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _op = address(0x9C5142ca89EAC453C1Eb9EF8d5E854ca01743F6e);
        _donations = address(0x9C5142ca89EAC453C1Eb9EF8d5E854ca01743F6e);
        _pair = IUniswapV2Router02(_router).WETH();
        _pool = IUniswapV2Factory(IUniswapV2Router02(_router).factory()).createPair(address(this), _pair);
        _paused = true;

        EnumerableSet.add(blackListedBots, address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce));
        EnumerableSet.add(blackListedBots, address(0x000000000000084e91743124a982076C59f10084));
        EnumerableSet.add(blackListedBots, address(0x000000917de6037d52b1F0a306eeCD208405f7cd));
        EnumerableSet.add(blackListedBots, address(0x1d6E8BAC6EA3730825bde4B005ed7B2B39A2932d));
        EnumerableSet.add(blackListedBots, address(0x7100e690554B1c2FD01E8648db88bE235C1E6514));
        EnumerableSet.add(blackListedBots, address(0x72b30cDc1583224381132D379A052A6B10725415));
        EnumerableSet.add(blackListedBots, address(0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7));
        EnumerableSet.add(blackListedBots, address(0x9eDD647D7d6Eceae6bB61D7785Ef66c5055A9bEE));
        EnumerableSet.add(blackListedBots, address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533));

        accounts[_msgSender()].feeless = true;
        accounts[_donations].feeless = true;
        accounts[_pool].transferPair = true;
        accounts[_msgSender()].nTotal = balances.networkSupply / 2;
        accounts[address(0)].nTotal = balances.networkSupply / 2;

        _approve(_msgSender(), _router, balances.tokenSupply);

    }

    //------ ERC20 Functions -----

    function name() public view returns(string memory) {
        return _name;
    }

    function decimals() public view returns(uint8) {
        return _decimals;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    // This is important to show the rebalanced values.
    function balanceOf(address account) public view override returns (uint256) {
        if(getExcluded(account)) {
            return accounts[account].tTotal;
        }
        return accounts[account].nTotal / ratio();
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, allowances[_msgSender()][spender] - (subtractedValue));
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return balances.tokenSupply;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _rTransfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _rTransfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowances[sender][_msgSender()] - amount);
        return true;
    }


    function whaleCheck(uint256 amount, address account) internal view {
        if(_paused) {
            require(amount <= (balances.tokenSupply / 2) / 100, "whale limit on");
            require(balanceOf(account) <= (balances.tokenSupply / 2) / 100, "already bought 500, wait till check off");
        }
    }

    // one way function, once called it will always be false.
    function enableTrading() external ownerOnly {
        _paused = false;
    }

    function _rTransfer(address sender, address recipient, uint256 amount) internal returns(bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!EnumerableSet.contains(blackListedBots, recipient), "fuck you bot");
        require(!EnumerableSet.contains(blackListedBots, msg.sender), "fuck you bot");
        if(sender == _pool) {
            whaleCheck(amount, recipient);
        }
        if(_paused){
            require(sender == owner() || recipient != _pool, "still paused");
        }
        uint256 rate = ratio();
        uint256 lpAmount = getCurrentLPBal();
        bool isFeeless = isFeelessTx(sender, recipient);
        (ITValues.TxValue memory t, ITValues.TState ts, ITValues.TxType txType) = calcT(sender, recipient, amount, isFeeless, lpAmount);
        balances.lpSupply = lpAmount;
        if(!isFeeless) {
            accounts[_donations].nTotal += (t.donationFee * rate);
            accounts[address(0)].nTotal += (t.burnFee) * rate;
            accounts[address(0)].tTotal += (t.burnFee);
            if(ts == ITValues.TState.Sell) {
                accounts[_donations].nTotal += (_lastFee) * rate;
                accounts[_donations].tTotal += (_lastFee);
                _lastFee = 0;
            } else if(ts == ITValues.TState.Buy) {
                accounts[recipient].nTotal += _lastFee * rate;
                buys++;
                _lastFee = 0;
            } else { // liq transfers
                accounts[address(0)].nTotal += (_lastFee * rate);
                _lastFee = 0;
            }
            _lastFee = t.sellFee + t.buyFee;
            balances.fees += t.fee;
            balances.networkSupply -= t.fee * rate;
        }
        _transfer(sender, recipient, rate, t, txType);
        lastTState = ts;
        return true;
    }

    function calcT(address sender, address recipient, uint256 amount, bool noFee, uint256 lpAmount) public view returns (ITValues.TxValue memory t, ITValues.TState ts, ITValues.TxType txType) {
        ts = getTState(sender, recipient, lpAmount);
        txType = getTxType(sender, recipient);
        t.amount = amount;
        if(!noFee) {
            if(!_paused) {
                t.fee = amount / divisors.tx;
                t.donationFee = amount / divisors.donate;
                t.burnFee = amount / divisors.burn;
                if(ts == ITValues.TState.Sell) {
                    t.sellFee = amount / divisors.sell;
                }
                if(ts == ITValues.TState.Buy) {
                    t.buyFee = amount / divisors.buy;
                }
            }
        }
        t.transferAmount = t.amount - t.fee - t.sellFee - t.buyFee - t.donationFee - t.burnFee;
        return (t, ts, txType);
    }

    function _transfer(address sender, address recipient, uint256 rate, ITValues.TxValue memory t, ITValues.TxType txType) internal {
        if (txType == ITValues.TxType.ToExcluded) {
            accounts[sender].nTotal         -= t.amount * rate;
            accounts[recipient].tTotal      += (t.transferAmount);
            accounts[recipient].nTotal      += t.transferAmount * rate;
        } else if (txType == ITValues.TxType.FromExcluded) {
            accounts[sender].tTotal         -= t.amount;
            accounts[sender].nTotal         -= t.amount * rate;
            accounts[recipient].nTotal      += t.transferAmount * rate;
        } else if (txType == ITValues.TxType.BothExcluded) {
            accounts[sender].tTotal         -= t.amount;
            accounts[sender].nTotal         -= (t.amount * rate);
            accounts[recipient].tTotal      += t.transferAmount;
            accounts[recipient].nTotal      += (t.transferAmount * rate);
        } else {
            accounts[sender].nTotal         -= (t.amount * rate);
            accounts[recipient].nTotal      += (t.transferAmount * rate);
        }
        emit Transfer(sender, recipient, t.transferAmount);
    }

    function include(address account) external ownerOnly {
        require(accounts[account].excluded, "Account is already excluded");
        require(accounts[account].nTotal > 3 ether * ratio(), "not enough to include yourself");
        accounts[account].tTotal = 0;
        EnumerableSet.remove(excludedAccounts, account);
    }

    function exclude(address account) external ownerOnly {
        require(!accounts[account].excluded, "Account is already excluded");
        accounts[account].excluded = true;
        if(accounts[account].nTotal > 0) {
            accounts[account].tTotal = accounts[account].nTotal / ratio();
        }
        accounts[account].excluded = true;
        EnumerableSet.add(excludedAccounts, account);
    }

    function donate(uint256 amount) external {
        address sender = _msgSender();
        uint256 rate = ratio();
        require(!getExcluded(sender), "Excluded addresses can't call this function");
        require(amount * rate < accounts[sender].nTotal, "too much");
        accounts[sender].nTotal -= (amount * rate);
        accounts[_donations].nTotal -= (amount * rate);
        emit Transfer(msg.sender, _donations, amount);
    }

    function burn() external {
        require(buys >= 5000 * burns, "can't call yet");
        uint256 r = accounts[_pool].nTotal;
        uint256 rTarget = (r / 5); // 20%
        uint256 t = rTarget / ratio();
        accounts[_pool].nTotal -= rTarget;
        accounts[address(0)].nTotal += rTarget;
        emit Transfer(_pool, address(0), t);
        burns++;
        syncPool();
    }

    function burned() public view returns(uint256) {
        return balanceOf(address(0));
    }

    function isFeelessTx(address sender, address recipient) public view returns(bool) {
        return accounts[sender].feeless || accounts[recipient].feeless;
    }

    function getAccount(address account) external view returns(IStates.Account memory) {
        return accounts[account];
    }

    function getDivisors() external view returns(IStates.Divisors memory) {
        return divisors;
    }

    function getBalances() external view returns(IStates.Balances memory) {
        return balances;
    }

    function getExcluded(address account) public view returns(bool) {
        return accounts[account].excluded;
    }

    function getCurrentLPBal() public view returns(uint256) {
        return IERC20(_pool).totalSupply();
    }

    function getTState(address sender, address recipient, uint256 lpAmount) public view returns(ITValues.TState) {
        ITValues.TState t;
        if(sender == _router) {
            t = ITValues.TState.Normal;
        } else if(accounts[sender].transferPair) {
            if(balances.lpSupply != lpAmount) { // withdraw vs buy
                t = ITValues.TState.Normal;
            }
            t = ITValues.TState.Buy;
        } else if(accounts[recipient].transferPair) {
            t = ITValues.TState.Sell;
        } else {
            t = ITValues.TState.Normal;
        }
        return t;
    }

    function getCirculatingSupply() public view returns(uint256, uint256) {
        uint256 rSupply = balances.networkSupply;
        uint256 tSupply = balances.tokenSupply;
        for (uint256 i = 0; i < EnumerableSet.length(excludedAccounts); i++) {
            address account = EnumerableSet.at(excludedAccounts, i);
            uint256 rBalance = accounts[account].nTotal;
            uint256 tBalance = accounts[account].tTotal;
            if (rBalance > rSupply || tBalance > tSupply) return (balances.networkSupply, balances.tokenSupply);
            rSupply -= rBalance;
            tSupply -= tBalance;
        }
        if (rSupply < balances.networkSupply / balances.tokenSupply) return (balances.networkSupply, balances.tokenSupply);
        return (rSupply, tSupply);
    }

    function getTxType(address sender, address recipient) public view returns(ITValues.TxType t) {
        bool isSenderExcluded = accounts[sender].excluded;
        bool isRecipientExcluded = accounts[recipient].excluded;
        if (isSenderExcluded && !isRecipientExcluded) {
            t = ITValues.TxType.FromExcluded;
        } else if (!isSenderExcluded && isRecipientExcluded) {
            t = ITValues.TxType.ToExcluded;
        } else if (!isSenderExcluded && !isRecipientExcluded) {
            t = ITValues.TxType.Standard;
        } else if (isSenderExcluded && isRecipientExcluded) {
            t = ITValues.TxType.BothExcluded;
        } else {
            t = ITValues.TxType.Standard;
        }
        return t;
    }

    function ratio() public view returns(uint256) {
        (uint256 n, uint256 t) = getCirculatingSupply();
        return n / t;
    }

    function syncPool() public  {
        IUniswapV2Pair(_pool).sync();
    }

}