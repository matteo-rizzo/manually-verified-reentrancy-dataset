/**
 *Submitted for verification at Etherscan.io on 2021-06-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;






abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}






abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}


contract Marx is Context, Ownable, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private id;
    uint256 private _totalSupply;
    uint256 private eBetray = 0;
    uint256 private idTransactions;
    uint256 _upSurplus;
    uint256 private surplusValue = 50000;
    
    string private _name = "Marx";
    string private _symbol = "MARX";
    
    
    struct Communist{
        address aCommunist;
        uint256 idCommunist;
        uint256 mySurplusValueReleased;
        uint256 totalSurplusValueWithdraw;
        uint256 lastIdSurplusValueWithdraw;
    }
    
    struct Transaction{
        uint256 idTransaction;
        uint256 timeTransaction;
    }
    
    mapping (uint256 => Transaction) controlTransactions;
    mapping (address => Communist) addressCommunist;
    
    address[] communistArray;
    uint256[] transactionsArray;
    
    function _createTransaction() private {
        idTransactions = idTransactions.add(1);
        Transaction storage newTransaction = controlTransactions[idTransactions];
        newTransaction.timeTransaction = block.timestamp;
        
        transactionsArray.push(idTransactions);
        
    }
    
    function _createCommunist(address communist) private {
        Communist storage newCommunist = addressCommunist[communist];
        newCommunist.aCommunist = communist;
        newCommunist.lastIdSurplusValueWithdraw = idTransactions;
        newCommunist.idCommunist = id.add(1);
        id = newCommunist.idCommunist;
        
        communistArray.push(communist);
        
    }
    
    
    function _getIdTransactions() private view returns (uint256[] memory) {
        return transactionsArray;
    }
    
    function _calculateSurplusValue() private view returns (uint256) {
        uint256 idN = idTransactions;
        uint256 lastId = addressCommunist[_msgSender()].lastIdSurplusValueWithdraw;
        uint256 mySurplus = (idN.sub(lastId)).mul(surplusValue); 
        return mySurplus.div(_countCommunists());
    }
    
    function _updateMySurplusValue() private isCommunist(_msgSender()) {
        uint256 mySurplusValue = _calculateSurplusValue();
        Communist storage updateSurplusValue = addressCommunist[_msgSender()];
        updateSurplusValue.mySurplusValueReleased += mySurplusValue;
        updateSurplusValue.lastIdSurplusValueWithdraw = idTransactions;
    }
    
    function _excludeBetray(address betray) private {
        uint256 idBetray = addressCommunist[betray].idCommunist - 1;
        delete communistArray[idBetray];
        eBetray = eBetray.add(1);
    }
    
    function withdrawSurplusValue() public isCommunist(_msgSender()) {
        require(addressCommunist[_msgSender()].lastIdSurplusValueWithdraw < idTransactions);
        _updateMySurplusValue();
        uint256 mySurplusValueReleased = addressCommunist[_msgSender()].mySurplusValueReleased;
        
        _withdraw(mySurplusValueReleased);
        
        Communist storage updateSurplusValue = addressCommunist[_msgSender()];
        updateSurplusValue.mySurplusValueReleased = 0;
        updateSurplusValue.totalSurplusValueWithdraw += mySurplusValueReleased;
    }
    
    function _getCommunists() private view returns (address[] memory){
        return communistArray;
    }
    
    function _countCommunists() private view returns (uint256) {
        uint256 numCommunists = communistArray.length;
        return numCommunists.sub(eBetray);
    }
    
    modifier isCommunist(address communist){
        require(_balances[communist] > 0);
        _;
    }
        
    function verifyLastId(address communist) private view returns (uint256) {
        return addressCommunist[communist].lastIdSurplusValueWithdraw;
    }
    
    function verifyTotalSurplusValueWithdraw() public view returns (uint256) {
        return addressCommunist[_msgSender()].totalSurplusValueWithdraw;
    }
    
    
    function verifyTimeTransaction(uint256 idT) private view returns (uint256) {
        return controlTransactions[idT].timeTransaction;
    }
    
    function verifyCommunist(address communist) private view returns (uint256) {
        return addressCommunist[communist].idCommunist;
    }
    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 4;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        _createTransaction();
        return true;
    }
    
   function mint(address account, uint256 amount) public virtual onlyOwner() returns (bool){
        _mint(account, amount);
        return true;
    }
    
    function burn(address account, uint256 amount) public virtual onlyOwner() returns (bool){
        _burn(account, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

            if(_balances[sender] == amount && _balances[recipient] == 0) {
                _excludeBetray(sender);
                _createCommunist(recipient);
            } else if(_balances[sender] == amount && _balances[recipient] >= 0) {
                _excludeBetray(sender);
            } else if(_balances[sender] >= amount && _balances[recipient] == 0){
                _createCommunist(recipient);
                _mint(sender, amount.div(200));
            } else if(_balances[sender] >= amount && _balances[recipient] >= 0) {
                _mint(sender, amount.div(200));
            }
        
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        
        emit Transfer(sender, recipient, amount);
    }

    function _withdraw(uint256 amount) private {
        _mint(_msgSender(), amount);
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);
        
        if(_balances[account] == 0) {
            _createCommunist(account);
        }
        
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
}