/**
 *Submitted for verification at Etherscan.io on 2021-07-04
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


// File: openzeppelin-solidity\contracts\utils\Address.sol


/**
 * @dev Collection of functions related to the address type
 */




contract fKISHU is IERC20, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    enum TxType { FromExcluded, ToExcluded, BothExcluded, Standard }

    mapping (address => uint256) private rTokenBalance;
    mapping (address => uint256) private tTokenBalance;
    mapping (address => mapping (address => uint256)) private _allowances;

    EnumerableSet.AddressSet excluded;

    uint256 private tTokenSupply;
    uint256 private rTokenSupply;
    uint256 private feesAccrued;
 
    string private _name = 'FEG Wrapped KISHU Token'; 
    string private _symbol = 'fKISHU';
    uint8  private _decimals = 9;
    
    address private op;
    address private op2;
    address public tContract = 0xA2b4C0Af19cC16a6CfAcCe81F192B024d625817D;
    
    event  Deposit(address indexed dst, uint amount);
    event  Withdrawal(address indexed src, uint amount);

    constructor () {
        op = address(0x4c9BC793716e8dC05d1F48D8cA8f84318Ec3043C);
        op2 = op;
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
        return tTokenSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (EnumerableSet.contains(excluded, account)) return tTokenBalance[account];
        (uint256 r, uint256 t) = currentSupply();
        return (rTokenBalance[account] * t)  / r;
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
    
    function ClaimOPfee() public {
        require (msg.sender == op);
        uint256 transferToAmount = (IERC20(tContract).balanceOf(address(this))) - (tTokenSupply);
        _pushUnderlying(tContract, op, transferToAmount);
        tTokenSupply -= transferToAmount;
      
        
    }
    
    function deposit(uint256 _amount) public  {
        require(_amount > 0, "can't deposit nothing");
        _pullUnderlying(tContract, msg.sender, _amount);
        (uint256 r, uint256 t) = currentSupply();
        uint256 fee = _amount / 100; 
        uint256 df = fee / 10;
        uint256 net = fee != 0 ? (_amount - (fee)) : _amount;
        tTokenSupply += _amount;
        if(isExcluded(msg.sender)){
            tTokenBalance[msg.sender] += (_amount- fee);
        } 
        feesAccrued += df;
        rTokenBalance[op] += ((df * r) / t);
        rTokenSupply += (((net + df) * r) / t);
        rTokenBalance[msg.sender] += ((net * r) / t);
        emit Deposit(msg.sender, _amount);
    }

    function _pullUnderlying(address erc20, address from, uint amount)
        internal
        nonReentrant
    {
        bool xfer = IERC20(erc20).transferFrom(from, address(this), amount);
        require(xfer, "ERR_ERC20_FALSE");
    }
    
    
    function withdraw(uint256 _amount) public  {
        require(balanceOf(msg.sender) >= _amount && _amount <= totalSupply(), "invalid _amount");
        (uint256 r, uint256 t) = currentSupply();
        uint256 fee = _amount / 100;
        uint256 wf = fee / 10;
        uint256 net = _amount - fee;
        if(isExcluded(msg.sender)) {
            tTokenBalance[msg.sender] -= _amount;
            rTokenBalance[msg.sender] -= ((_amount * r) / t);
        } else {
            rTokenBalance[msg.sender] -= ((_amount * r) / t);
        }
        tTokenSupply -= (net + wf);
        rTokenSupply -= (((net + wf) * r ) / t);
        rTokenBalance[op] += ((wf * r) / t);
        feesAccrued += wf;
        _pushUnderlying(tContract, msg.sender, net);
        emit Withdrawal(msg.sender, net);
    }
    
    function _pushUnderlying(address erc20, address to, uint amount)
        internal
        nonReentrant
    {
        bool xfer = IERC20(erc20).transfer(to, amount);
        require(xfer, "ERR_ERC20_FALSE");
    }
    
    function rTokenToEveryone(uint256 amt) public {
        require(!isExcluded(msg.sender), "not allowed");
        (uint256 r, uint256 t) = currentSupply();
        rTokenBalance[msg.sender] -= ((amt * r) / t);
        rTokenSupply -= ((amt * r) / t);
        feesAccrued += amt;
    }

    function excludeFromFees(address account) external {
        require(msg.sender == op2, "op only");
        require(!EnumerableSet.contains(excluded, account), "address excluded");
        if(rTokenBalance[account] > 0) {
            (uint256 r, uint256 t) = currentSupply();
            tTokenBalance[account] = (rTokenBalance[account] * (t)) / (r);
        }
        EnumerableSet.add(excluded, account);
    }

    function includeInFees(address account) external {
        require(msg.sender == op2, "op only");
        require(EnumerableSet.contains(excluded, account), "address excluded");
        tTokenBalance[account] = 0;
        EnumerableSet.remove(excluded, account);
    }
    
    function tTokenFromrToken(uint256 rTokenAmount) external view returns (uint256) {
        (uint256 r, uint256 t) = currentSupply();
        return (rTokenAmount * t) / r;
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
            rTokenBalance[sender] -= ((amt * r) / t);
            tTokenBalance[recipient] += (amt - fee);
            rTokenBalance[recipient] += (((amt - fee) * r) / t);
        } else if (tt == TxType.FromExcluded) {
            tTokenBalance[sender] -= (amt);
            rTokenBalance[sender] -= ((amt * r) / t);
            rTokenBalance[recipient] += (((amt - fee) * r) / t);
        } else if (tt == TxType.BothExcluded) {
            tTokenBalance[sender] -= (amt);
            rTokenBalance[sender] -= ((amt * r) / t);
            tTokenBalance[recipient] += (amt - fee);
            rTokenBalance[recipient] += (((amt - fee) * r) / t);
        } else {
            rTokenBalance[sender] -= ((amt * r) / t);
            rTokenBalance[recipient] += (((amt - fee) * r) / t);
        }
        rTokenSupply  -= ((fee * r) / t);
        feesAccrued += fee;
        emit Transfer(sender, recipient, amt - fee);
    }

    function currentSupply() public view returns(uint256, uint256) {
        if(rTokenSupply == 0 || tTokenSupply == 0) return (1000000000, 1);
        uint256 rSupply = rTokenSupply;
        uint256 tSupply = tTokenSupply;
        for (uint256 i = 0; i < EnumerableSet.length(excluded); i++) {
            if (rTokenBalance[EnumerableSet.at(excluded, i)] > rSupply || tTokenBalance[EnumerableSet.at(excluded, i)] > tSupply) return (rTokenSupply, tTokenSupply);
            rSupply -= (rTokenBalance[EnumerableSet.at(excluded, i)]);
            tSupply -= (tTokenBalance[EnumerableSet.at(excluded, i)]);
        }
        if (rSupply < rTokenSupply / tTokenSupply) return (rTokenSupply, tTokenSupply);
        return (rSupply, tSupply);
    }
    
    function setOp(address opper, address opper2) external {
        require(msg.sender == op, "only op can call");
        op = opper;
        op2 = opper2;
    }
}