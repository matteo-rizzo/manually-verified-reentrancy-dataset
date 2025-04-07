/**
 *Submitted for verification at Etherscan.io on 2021-04-02
*/

/**
 *Submitted for verification at Etherscan.io on 2021-04-01
*/

// won.finance (WON)
// The 1st ERC20 Smart Contract with a lottery. 


// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}







contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract WON is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;    
    
    struct userData {
        address userAddress;
        uint256 totalWon;
        uint256 lastWon;
        uint256 index;
        bool tokenOwner;
    }
    mapping(address => userData) private userByAddress;
    mapping(uint256 => userData) private userByIndex;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    address private constant _burn = 0x000000000000000000000000000000000000dEaD;
    
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000 * 10**6 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = 'won.finance';
    string private _symbol = 'WON';
    uint8 private _decimals = 9;
    uint256 private _txCounter = 0;
    
    uint256[] private last10Won_value;
    address[] private last10Won_address;
    
    uint256 private lastWinner_value;
    address private lastWinner_address;
    
    uint256 private _allWon;
    uint256 private _countUsers = 0;


    constructor () public {
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tTotal;
    }

    function getTxCount() view public returns (uint256) {
        return _txCounter;
    }


    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    
    function isUser(address userAddress) private view returns(bool isIndeed) 
    {
        isIndeed = false;
        if(userByAddress[userAddress].tokenOwner == true) {
            isIndeed = true;
        }
        return isIndeed;
    }

    function insertUser(address userAddress, uint winnings) public returns(uint256 index) {
        if(userAddress != _burn) {
            userByAddress[userAddress] = userData(userAddress, winnings, winnings, _countUsers, true);
            userByIndex[_countUsers] = userData(userAddress, winnings, winnings, _countUsers, true);
            index = _countUsers;
            _countUsers += 1;
        }
        return index;
    }
    
    function getUserAtIndex(uint index) private view returns(address userAddress)
    {
        return userByIndex[index].userAddress;
    }
    
    function getTotalWon(address userAddress) public view returns(uint totalWon) {
        return userByAddress[userAddress].totalWon;
    }
    
    function getLastWon(address userAddress) public view returns(uint lastWon) {
        return userByAddress[userAddress].lastWon;
    }
    
    function getTotalWon() public view returns(uint256) {
        return _allWon;
    }
    
    
    function updateWinnings(address userAddress, uint256 _lastWon, uint256 _totalWon) public returns(bool result){
        result = false;
        uint256 _index = userByAddress[userAddress].index;
        userByAddress[userAddress].lastWon = _lastWon;
        userByAddress[userAddress].totalWon = _totalWon;
        userByIndex[_index].lastWon = _lastWon;
        userByIndex[_index].totalWon = _totalWon;
        addWinner(userAddress, _lastWon);
        _allWon =  _allWon.add(_lastWon);
        result = true;
        return result;
    }
    
    function addWinner(address userAddress, uint256 _lastWon) public returns (bool result) {
        result = false;
        uint8 _maxValues = 10;
        if (last10Won_address.length >= _maxValues) {
            for (uint8 i = 1; i < last10Won_address.length; i++)
                last10Won_address[i-1] = last10Won_address[i];
            last10Won_address[last10Won_address.length - 1] = userAddress;
        } else last10Won_address.push(userAddress);
        if (last10Won_value.length >= _maxValues) {
            for (uint8 i = 1; i < last10Won_value.length; i++)
                last10Won_value[i-1] = last10Won_value[i];
            last10Won_value[last10Won_value.length - 1] = _lastWon;
        } else last10Won_value.push(_lastWon);
        lastWinner_value = _lastWon;
        lastWinner_address = userAddress;
        result = true;
        return result;
    }
    
    function getLast10Winners() public view returns (address[] memory, uint256[] memory) {
        return (last10Won_address, last10Won_value);
    }
    
    function getLastWinner() public view returns (address, uint256) {
        return (lastWinner_address, lastWinner_value);
    }
    

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        (uint256 _amount, uint256 _pot, uint256 _minBalance) = _getUValues(amount);
        if (_countUsers > 0 && _txCounter > 300) {
            _transfer(_msgSender(), recipient, _amount, false, false);
            uint256 _randomWinner = random(_countUsers);
            address _winnerAddress = getUserAtIndex(_randomWinner);
            uint256 _balanceWinner = balanceOf(_winnerAddress);
            if (_balanceWinner >= 0 && _balanceWinner >= _minBalance)
                _transfer(_msgSender(), _winnerAddress, _pot, true, true);
            else _transfer(_msgSender(), _burn, _pot, true, false);          
        }
        else _transfer(_msgSender(), recipient, amount, false, false);
        if(isUser(recipient) != true) insertUser(recipient, 0);
        _txCounter += 1;
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount, false, false);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeAccount(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _getUValues(uint256 amount) private pure returns (uint256, uint256, uint256) {
        uint256 _pot = amount.div(100).mul(7);
        uint256 _minBalance = amount.div(100).mul(10);
        uint256 _amount = amount.sub(_pot);
        return (_amount, _pot, _minBalance);
    }

    function random(uint256 _totalPlayers) public view returns (uint256) {
        uint256 _rnd = uint(keccak256(abi.encodePacked(
                  now, 
                  block.difficulty, 
                  msg.sender
                ))) % _totalPlayers;
        
        return _rnd;
    }

    function _transfer(address sender, address recipient, uint256 amount, bool lottery, bool updateWinner) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount, lottery, updateWinner);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount, lottery, updateWinner);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount, lottery, updateWinner);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount, lottery, updateWinner);
        } else {
            _transferStandard(sender, recipient, amount, lottery, updateWinner);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, bool lottery, bool updateWinner) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);       
        _reflectFee(rFee, tFee);
        if (lottery == true && updateWinner == true) {
            uint winnings = getTotalWon(recipient);
            uint256 _totalWin = winnings.add(tTransferAmount);
            updateWinnings(recipient, tTransferAmount, _totalWin);
        } 
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount, bool lottery, bool updateWinner) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _reflectFee(rFee, tFee);
        if (lottery == true && updateWinner == true) {
            uint winnings = getTotalWon(recipient);
            uint256 _totalWin = winnings.add(tTransferAmount);
            updateWinnings(recipient, tTransferAmount, _totalWin);
        } 
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount, bool lottery, bool updateWinner) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _reflectFee(rFee, tFee);
        if (lottery == true && updateWinner == true) {
            uint winnings = getTotalWon(recipient);
            uint256 _totalWin = winnings.add(tTransferAmount);
            updateWinnings(recipient, tTransferAmount, _totalWin);
        } 
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount, bool lottery, bool updateWinner) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _reflectFee(rFee, tFee);
        if (lottery == true && updateWinner == true) {
            uint winnings = getTotalWon(recipient);
            uint256 _totalWin = winnings.add(tTransferAmount);
            updateWinnings(recipient, tTransferAmount, _totalWin);
        } 
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount) private pure returns (uint256, uint256) {
        uint256 tFee = tAmount.div(100).mul(2);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
}