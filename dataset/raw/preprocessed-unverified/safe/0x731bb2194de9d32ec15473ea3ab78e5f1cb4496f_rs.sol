/**
 *Submitted for verification at Etherscan.io on 2020-03-06
*/

/**
 *TILWIKI Global Ecosystem project by Anaida Schneider. All rights reserved.
*/

pragma solidity ^0.6.0;

contract Context {
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}







 




contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
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


    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _burnFrom(address account, uint256 amount) internal virtual {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


contract Ownable is Context {
    address private _owner;
    address private candidate;

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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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
        _transferOwnership(newOwner);
    }


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal virtual {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        candidate = newOwner;
    }

    function confirmOwnership() public {
        require(candidate == msg.sender, "Ownable: only for candidates");
        emit OwnershipTransferred(_owner, candidate);
        _owner = candidate;
        delete candidate;
    }

    
}


contract TLWToken is ERC20 {
    string public constant name = "TILWIKI - Faces of Art";
    string public constant symbol = "TLW";
    uint8 public constant decimals = 8;
    uint256 public INITIAL_SUPPLY = 0;
    address public CrowdsaleAddress;
    bool public lockMint = false;
    uint256 public MaxSupply = 79797979 * 10**8 ; //max supply

    constructor(address _CrowdsaleAddress) public {
        CrowdsaleAddress = _CrowdsaleAddress;
    }

    modifier onlyOwner() {
        // only Crowdsale contract
        require(_msgSender() == CrowdsaleAddress, "Only from Crowdsale contract");
        _;
    }

    function lockMintForever() public onlyOwner {
        lockMint = true;
    }

    /** 
     * Override
     */
    function mint(address _to, uint256 _value) public onlyOwner returns (bool){
        require(!lockMint, "Mint is locked forever.");
        uint256 result = totalSupply() + _value;
        require(result <= MaxSupply,"Result Above Limit");
        _mint(_to, _value);
        return true;
    }
    
        /** 
     * Override
     */
    function burn(uint256 _value) public returns (bool){
        _burn(_msgSender(), _value);
        return true;
    }

    fallback() external payable {
        revert("The token contract don`t receive ether");
    }  
    receive() external payable {
        revert("The token contract don`t receive ether");
    }
}

contract Crowdsale is Ownable {
    using SafeMath for uint; 
    address myAddress = address(this);
    
    event Received(address, uint256);
    event Withdraw(address, uint256);

    TLWToken public token = new TLWToken(myAddress);
    
    function mint(address _to, uint256 _value) public onlyOwner returns (bool){
        token.mint(_to, _value);
        return true;
    }   
    
    function lockMint(uint256 _pass) public onlyOwner returns (bool){
        require(_pass == 128, "Incorrect test value");
        token.lockMintForever();
        return true;
    }  
    
    function withdrawFunds (uint256 _value) public onlyOwner {
        require (myAddress.balance >= _value,"Value is more than balance");
        _msgSender().transfer(_value);
        emit Withdraw(_msgSender(), _value);
    }
    
    receive() external payable {
      emit Received(_msgSender(), msg.value);
    }

    fallback () external payable {
        emit Received(_msgSender(), msg.value);
    }

}