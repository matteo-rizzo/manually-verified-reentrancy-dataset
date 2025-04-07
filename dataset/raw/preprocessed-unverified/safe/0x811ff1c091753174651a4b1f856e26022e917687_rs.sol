/**
 *Submitted for verification at Etherscan.io on 2021-05-11
*/

pragma solidity 0.8.4;

// SPDX-License-Identifier: MIT

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal virtual view returns (address) {
        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract Cryptovator is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private _name = "Cryptovator";
    string private _symbol = "CVR20";
    uint8 private _decimals = 18;

    mapping(address => uint256) internal _reflectionBalance;
    mapping(address => uint256) internal _tokenBalance;
    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 private constant MAX = ~uint256(0);
    uint256 internal _tokenTotal = 100000000000000000 *10**18;
    uint256 internal _reflectionTotal = (MAX - (MAX % _tokenTotal));

    mapping(address => bool) isExcludedFromFee;
    mapping(address => bool) internal _isExcluded;
    address[] internal _excluded;
    
    //@dev The tax fee contains two decimal places so 250 = 2.5%
    uint256 public _feeDecimal = 2;
    uint256 public _taxFee = 500;
    uint256 public _burnFee = 30;
    uint256 public _AFee = 50;
    uint256 public _BFee = 20;
    
    uint256 public _taxFeeTotal;
    uint256 public _burnFeeTotal;
    uint256 public _AFeeTotal;
    uint256 public _BFeeTotal;
    
    address public _AWallet = 0x8E0f61A65cF4827A9920E51012e263F51b1279Be;
    address public _BWallet = 0xa4D28533007893Cf72332aF596544Ce744575c6A;
    address public _vtalikWallet = 0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B;
    
    event RewardsDistributed(uint256 amount);
    
    constructor() {
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[_vtalikWallet] = true;
        isExcludedFromFee[address(this)] = true;
        
        _reflectionBalance[_msgSender()] = _reflectionTotal.div(2);
        _reflectionBalance[_vtalikWallet] = _reflectionTotal.div(2);
        emit Transfer(address(0), _msgSender(), _tokenTotal.div(2));
        emit Transfer(address(0), _vtalikWallet, _tokenTotal.div(2));
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

    function totalSupply() public override view returns (uint256) {
        return _tokenTotal;
    }

    function balanceOf(address account) public override view returns (uint256) {
        if (_isExcluded[account]) return _tokenBalance[account];
        return tokenFromReflection(_reflectionBalance[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        virtual
        returns (bool)
    {
       _transfer(_msgSender(),recipient,amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override virtual returns (bool) {
        _transfer(sender,recipient,amount);
               
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub( amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tokenAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tokenAmount <= _tokenTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            return tokenAmount.mul(_getReflectionRate());
        } else {
            return
                tokenAmount.sub(tokenAmount.mul(_taxFee).div(10** _feeDecimal + 2)).mul(
                    _getReflectionRate()
                );
        }
    }

    function tokenFromReflection(uint256 reflectionAmount)
        public
        view
        returns (uint256)
    {
        require(
            reflectionAmount <= _reflectionTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getReflectionRate();
        return reflectionAmount.div(currentRate);
    }

    function excludeAccount(address account) external onlyOwner() {
        require(
            account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D,
            "CVR20: Uniswap router cannot be excluded."
        );
        require(account != address(this), 'CVR20: The contract it self cannot be excluded');
        require(!_isExcluded[account], "CVR20: Account is already excluded");
        if (_reflectionBalance[account] > 0) {
            _tokenBalance[account] = tokenFromReflection(
                _reflectionBalance[account]
            );
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "CVR20: Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tokenBalance[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        uint256 transferAmount = amount;
        uint256 rate = _getReflectionRate();

        if(!isExcludedFromFee[sender] && !isExcludedFromFee[recipient]){
            transferAmount = collectFee(sender,amount,rate);
        }

        //@dev Transfer reflection
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(amount.mul(rate));
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount.mul(rate));

        //@dev If any account belongs to the excludedAccount transfer token
        if (_isExcluded[sender]) {
            _tokenBalance[sender] = _tokenBalance[sender].sub(amount);
        }
        if (_isExcluded[recipient]) {
            _tokenBalance[recipient] = _tokenBalance[recipient].add(transferAmount);
        }

        emit Transfer(sender, recipient, transferAmount);
    }
    
    function collectFee(address account, uint256 amount, uint256 rate) private returns (uint256) {
        uint256 transferAmount = amount;
        
        //@dev Tax fee
        if(_taxFee != 0){
            uint256 taxFee = amount.mul(_taxFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(taxFee);
            _reflectionTotal = _reflectionTotal.sub(taxFee.mul(rate));
            _taxFeeTotal = _taxFeeTotal.add(taxFee);
            emit RewardsDistributed(taxFee);
        }
        
        //@dev Take burn fee
        if(_burnFee != 0){
            uint256 burnFee = amount.mul(_burnFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(burnFee);
            _tokenTotal = _tokenTotal.sub(burnFee);
            _reflectionTotal = _reflectionTotal.sub(burnFee);
            _burnFeeTotal = _burnFeeTotal.add(burnFee);
            emit Transfer(account,address(0),burnFee);
        }
        
        //@dev Take A fee
        if(_AFee != 0){
            uint256 AFee = amount.mul(_AFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(AFee);
            _reflectionBalance[_AWallet] = _reflectionBalance[_AWallet].add(AFee.mul(rate));
            _AFeeTotal = _AFeeTotal.add(AFee);
            emit Transfer(account,_AWallet,AFee);
        }
        
        //@dev Take B fee
        if(_BFee != 0){
            uint256 BFee = amount.mul(_BFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(BFee);
            _reflectionBalance[_BWallet] = _reflectionBalance[_BWallet].add(BFee.mul(rate));
            _BFeeTotal = _BFeeTotal.add(BFee);
            emit Transfer(account,_BWallet,BFee);
        }
        
        return transferAmount;
    }

    function _getReflectionRate() private view returns (uint256) {
        uint256 reflectionSupply = _reflectionTotal;
        uint256 tokenSupply = _tokenTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _reflectionBalance[_excluded[i]] > reflectionSupply ||
                _tokenBalance[_excluded[i]] > tokenSupply
            ) return _reflectionTotal.div(_tokenTotal);
            reflectionSupply = reflectionSupply.sub(
                _reflectionBalance[_excluded[i]]
            );
            tokenSupply = tokenSupply.sub(_tokenBalance[_excluded[i]]);
        }
        if (reflectionSupply < _reflectionTotal.div(_tokenTotal))
            return _reflectionTotal.div(_tokenTotal);
        return reflectionSupply.div(tokenSupply);
    }
    
    function excludedFromFee(address account, bool) public onlyOwner {
        isExcludedFromFee[account] = true;
    }
    
    function includedForFee(address account, bool) public onlyOwner {
        isExcludedFromFee[account] = false;
    }
    
    function setTaxFee(uint256 fee) public onlyOwner {
        _taxFee = fee;
    }
    
    function setburnFee(uint256 fee) public onlyOwner {
        _burnFee = fee;
    }
    
    function setAFee(uint256 fee) public onlyOwner {
        _AFee = fee;
    }
    
    function setBFee(uint256 fee) public onlyOwner {
        _BFee = fee;
    }
    
    function setAWallet(address _address) public onlyOwner {
        _AWallet = _address;
    }
    
    function setBWallet(address _address) public onlyOwner {
        _BWallet = _address;
    }
    
    // function to allow owner to transfer any BEP20 from this address.
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "BEP20: amount must be greater than 0");
        require(recipient != address(0), "BEP20: recipient is the zero address");
        Token(tokenAddress).transfer(recipient, amount);
    }
}