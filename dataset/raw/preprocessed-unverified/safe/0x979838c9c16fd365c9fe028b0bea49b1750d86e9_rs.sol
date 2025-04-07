/**
 *Submitted for verification at Etherscan.io on 2021-04-27
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.4;


    
    abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


// File: openzeppelin-solidity\contracts\token\ERC20\IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */





/**
 * @dev Collection of functions related to the address type
 */






contract fUSDT is IERC20, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    enum TxType { FromExcluded, ToExcluded, BothExcluded, Standard }

    mapping (address => uint256) private rUsdtBalance;
    mapping (address => uint256) private tUsdtBalance;
    mapping (address => mapping (address => uint256)) private _allowances;

    EnumerableSet.AddressSet excluded;

    uint256 private tUsdtSupply;
    uint256 private rUsdtSupply;
    uint256 private feesAccrued;
 
    string private _name = 'FEG Wrapped USDT'; 
    string private _symbol = 'fUSDT';
    uint8  private _decimals = 6;
    
    address private op;
    address private op2;
    IERC20 public lpToken;
    
    event  Deposit(address indexed dst, uint amount);
    event  Withdrawal(address indexed src, uint amount);

    constructor (address _lpToken) {
        op = address(0x4c9BC793716e8dC05d1F48D8cA8f84318Ec3043C);
        op2 = op;
        lpToken = IERC20(_lpToken);
        EnumerableSet.add(excluded, address(0)); // stablity - zen.
        emit Transfer(address(0), msg.sender, 0);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return tUsdtSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (EnumerableSet.contains(excluded, account)) return tUsdtBalance[account];
        (uint256 r, uint256 t) = currentSupply();
        return (rUsdtBalance[account] * t)  / r;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function isExcluded(address account) public view returns (bool) {
        return EnumerableSet.contains(excluded, account);
    }

    function totalFees() public view returns (uint256) {
        return feesAccrued;
    }
    
    function deposit(uint256 _amount) public  {
        require(_amount > 0, "can't deposit nothing");
        lpToken.safeTransferFrom(msg.sender, address(this), _amount);
        (uint256 r, uint256 t) = currentSupply();
        uint256 fee = _amount / 100; 
        uint256 df = fee / 10;
        uint256 net = fee != 0 ? (_amount - (fee)) : _amount;
        tUsdtSupply += _amount;
        if(isExcluded(msg.sender)){
            tUsdtBalance[msg.sender] += (_amount- fee);
        } 
        feesAccrued += df;
        rUsdtBalance[op] += ((df * r) / t);
        rUsdtSupply += (((net + df) * r) / t);
        rUsdtBalance[msg.sender] += ((net * r) / t);
        emit Deposit(msg.sender, _amount);
    }
    
    function withdraw(uint256 _amount) public  {
        require(balanceOf(msg.sender) >= _amount && _amount <= totalSupply(), "invalid _amount");
        (uint256 r, uint256 t) = currentSupply();
        uint256 fee = _amount / 100;
        uint256 wf = fee / 10;
        uint256 net = _amount - fee;
        if(isExcluded(msg.sender)) {
            tUsdtBalance[msg.sender] -= _amount;
            rUsdtBalance[msg.sender] -= ((_amount * r) / t);
        } else {
            rUsdtBalance[msg.sender] -= ((_amount * r) / t);
        }
        tUsdtSupply -= (net + wf);
        rUsdtSupply -= (((net + wf) * r ) / t);
        rUsdtBalance[op] += ((wf * r) / t);
        feesAccrued += wf;
        lpToken.safeTransfer(msg.sender, net);
        emit Withdrawal(msg.sender, net);
    }
    
    function rUsdtToEveryone(uint256 amt) public {
        require(!isExcluded(msg.sender), "not allowed");
        (uint256 r, uint256 t) = currentSupply();
        rUsdtBalance[msg.sender] -= ((amt * r) / t);
        rUsdtSupply -= ((amt * r) / t);
        feesAccrued += amt;
    }

    function excludeFromFees(address account) external {
        require(msg.sender == op2, "op only");
        require(!EnumerableSet.contains(excluded, account), "address excluded");
        if(rUsdtBalance[account] > 0) {
            (uint256 r, uint256 t) = currentSupply();
            tUsdtBalance[account] = (rUsdtBalance[account] * (t)) / (r);
        }
        EnumerableSet.add(excluded, account);
    }

    function includeInFees(address account) external {
        require(msg.sender == op2, "op only");
        require(EnumerableSet.contains(excluded, account), "address excluded");
        tUsdtBalance[account] = 0;
        EnumerableSet.remove(excluded, account);
    }
    
    function tUsdtFromrUsdt(uint256 rUsdtAmount) external view returns (uint256) {
        (uint256 r, uint256 t) = currentSupply();
        return (rUsdtAmount * t) / r;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function getTtype(address sender, address recipient) internal view returns (TxType t) {
        bool isSenderExcluded = EnumerableSet.contains(excluded, sender);
        bool isRecipientExcluded = EnumerableSet.contains(excluded, recipient);
        if (isSenderExcluded && !isRecipientExcluded) {
            t = TxType.FromExcluded;
        } else if (!isSenderExcluded && isRecipientExcluded) {
            t = TxType.ToExcluded;
        } else if (!isSenderExcluded && !isRecipientExcluded) {
            t = TxType.Standard;
        } else if (isSenderExcluded && isRecipientExcluded) {
            t = TxType.BothExcluded;
        } else {
            t = TxType.Standard;
        }
        return t;
    }
    function _transfer(address sender, address recipient, uint256 amt) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amt > 0, "Transfer amt must be greater than zero");
        (uint256 r, uint256 t) = currentSupply();
        uint256 fee = amt / 100;
        TxType tt = getTtype(sender, recipient);
        if (tt == TxType.ToExcluded) {
            rUsdtBalance[sender] -= ((amt * r) / t);
            tUsdtBalance[recipient] += (amt - fee);
            rUsdtBalance[recipient] += (((amt - fee) * r) / t);
        } else if (tt == TxType.FromExcluded) {
            tUsdtBalance[sender] -= (amt);
            rUsdtBalance[sender] -= ((amt * r) / t);
            rUsdtBalance[recipient] += (((amt - fee) * r) / t);
        } else if (tt == TxType.BothExcluded) {
            tUsdtBalance[sender] -= (amt);
            rUsdtBalance[sender] -= ((amt * r) / t);
            tUsdtBalance[recipient] += (amt - fee);
            rUsdtBalance[recipient] += (((amt - fee) * r) / t);
        } else {
            rUsdtBalance[sender] -= ((amt * r) / t);
            rUsdtBalance[recipient] += (((amt - fee) * r) / t);
        }
        rUsdtSupply  -= ((fee * r) / t);
        feesAccrued += fee;
        emit Transfer(sender, recipient, amt - fee);
    }

    function currentSupply() public view returns(uint256, uint256) {
        if(rUsdtSupply == 0 || tUsdtSupply == 0) return (1000000000, 1);
        uint256 rSupply = rUsdtSupply;
        uint256 tSupply = tUsdtSupply;
        for (uint256 i = 0; i < EnumerableSet.length(excluded); i++) {
            if (rUsdtBalance[EnumerableSet.at(excluded, i)] > rSupply || tUsdtBalance[EnumerableSet.at(excluded, i)] > tSupply) return (rUsdtSupply, tUsdtSupply);
            rSupply -= (rUsdtBalance[EnumerableSet.at(excluded, i)]);
            tSupply -= (tUsdtBalance[EnumerableSet.at(excluded, i)]);
        }
        if (rSupply < rUsdtSupply / tUsdtSupply) return (rUsdtSupply, tUsdtSupply);
        return (rSupply, tSupply);
    }
    
    function setOp(address opper, address opper2) external {
        require(msg.sender == op, "only op can call");
        op = opper;
        op2 = opper2;
    }
}