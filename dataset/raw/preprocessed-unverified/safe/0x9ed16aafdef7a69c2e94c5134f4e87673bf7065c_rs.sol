/**
 *Submitted for verification at Etherscan.io on 2021-07-16
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.3;



// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    
    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}







interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// contract implementation
contract ZardInu is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    uint8 private _decimals = 9;

    string private _name = "Zard Inu"; // name
    string private _symbol = "ZARD"; // symbol
    uint256 private _tTotal = 1000000000000 * 10**9; // 1T

    // % to holders
    uint256 public defaultTaxFee = 3;
    uint256 public _taxFee = defaultTaxFee;
    uint256 private _previousTaxFee = _taxFee;

    // % to swap & send to marketing wallet
    uint256 public defaultMarketingFee = 4;
    uint256 public _marketingFee = defaultMarketingFee;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public _marketingFee4Sellers = 4; //applies to sells only

    bool public feesOnSellersAndBuyers = true;

    uint256 public _maxTxAmount = 50000000 * 10**2 * 10**9; // max transaction amount
    uint256 public numTokensToExchangeForMarketing = _tTotal.div(100).div(100); // contract balance to trigger swap & send

    address payable private _teamWalletAddress;
    address payable private _marketingWalletAddress;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    
    mapping (address => bool) private _isBlackListedBot;
    address[] private _blackListedBots;

    address[] private _excluded;
    uint256 private constant MAX = ~uint256(0);

    uint256 private _tFeeTotal;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndSend;
    bool public SwapAndSendEnabled = true;        
    bool public tradingEnabled = false;

    event SwapAndSendEnabledUpdated(bool enabled);
//------

    bool private cooldownEnabled = false;
    uint256 private _numOfTokensToExchangeForTeam = 5 * 10**6; // 5M

    bool private isCooldownEnabled = true;
    mapping(address => uint256) private buycooldown;
    mapping(address => uint256) private sellcooldown;
    mapping(address => uint256) private firstsell;
    mapping(address => uint256) private sellnumber;

    mapping (address => bool) private bots;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    mapping (address => bool) private _isBlacklisted;

//------
    modifier lockTheSwap {
        inSwapAndSend = true;
        _;
        inSwapAndSend = false;
    }

    constructor (address payable teamWalletAddress, address payable marketingWalletAddress) {
        
        _teamWalletAddress = teamWalletAddress;
        _marketingWalletAddress = marketingWalletAddress;
        
        _rOwned[_msgSender()] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        _isBlackListedBot[address(0x7589319ED0fD750017159fb4E4d96C63966173C1)] = true;
        _blackListedBots.push(address(0x7589319ED0fD750017159fb4E4d96C63966173C1));
        
        _isBlackListedBot[address(0x65A67DF75CCbF57828185c7C050e34De64d859d0)] = true;
        _blackListedBots.push(address(0x65A67DF75CCbF57828185c7C050e34De64d859d0));
        
        _isBlackListedBot[address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce)] = true;
        _blackListedBots.push(address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce));
        
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
        
        _isBlackListedBot[address(0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7)] = true;
        _blackListedBots.push(address(0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7));
        
        _isBlackListedBot[address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533)] = true;
        _blackListedBots.push(address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533));
        
        _isBlackListedBot[address(0x1d6E8BAC6EA3730825bde4B005ed7B2B39A2932d)] = true;
        _blackListedBots.push(address(0x1d6E8BAC6EA3730825bde4B005ed7B2B39A2932d));
        
        _isBlackListedBot[address(0x000000000000084e91743124a982076C59f10084)] = true;
        _blackListedBots.push(address(0x000000000000084e91743124a982076C59f10084));

        _isBlackListedBot[address(0x6dA4bEa09C3aA0761b09b19837D9105a52254303)] = true;
        _blackListedBots.push(address(0x6dA4bEa09C3aA0761b09b19837D9105a52254303));
        
        _isBlackListedBot[address(0x323b7F37d382A68B0195b873aF17CeA5B67cd595)] = true;
        _blackListedBots.push(address(0x323b7F37d382A68B0195b873aF17CeA5B67cd595));
        
        _isBlackListedBot[address(0x000000005804B22091aa9830E50459A15E7C9241)] = true;
        _blackListedBots.push(address(0x000000005804B22091aa9830E50459A15E7C9241));
        
        _isBlackListedBot[address(0xA3b0e79935815730d942A444A84d4Bd14A339553)] = true;
        _blackListedBots.push(address(0xA3b0e79935815730d942A444A84d4Bd14A339553));
        
        _isBlackListedBot[address(0xf6da21E95D74767009acCB145b96897aC3630BaD)] = true;
        _blackListedBots.push(address(0xf6da21E95D74767009acCB145b96897aC3630BaD));
        
        _isBlackListedBot[address(0x0000000000007673393729D5618DC555FD13f9aA)] = true;
        _blackListedBots.push(address(0x0000000000007673393729D5618DC555FD13f9aA));
        
        _isBlackListedBot[address(0x00000000000003441d59DdE9A90BFfb1CD3fABf1)] = true;
        _blackListedBots.push(address(0x00000000000003441d59DdE9A90BFfb1CD3fABf1));
        
        _isBlackListedBot[address(0x59903993Ae67Bf48F10832E9BE28935FEE04d6F6)] = true;
        _blackListedBots.push(address(0x59903993Ae67Bf48F10832E9BE28935FEE04d6F6));
        
        _isBlackListedBot[address(0x000000917de6037d52b1F0a306eeCD208405f7cd)] = true;
        _blackListedBots.push(address(0x000000917de6037d52b1F0a306eeCD208405f7cd));
        
        _isBlackListedBot[address(0x7100e690554B1c2FD01E8648db88bE235C1E6514)] = true;
        _blackListedBots.push(address(0x7100e690554B1c2FD01E8648db88bE235C1E6514));
        
        _isBlackListedBot[address(0x72b30cDc1583224381132D379A052A6B10725415)] = true;
        _blackListedBots.push(address(0x72b30cDc1583224381132D379A052A6B10725415));
        
        _isBlackListedBot[address(0x9eDD647D7d6Eceae6bB61D7785Ef66c5055A9bEE)] = true;
        _blackListedBots.push(address(0x9eDD647D7d6Eceae6bB61D7785Ef66c5055A9bEE));

        _isBlackListedBot[address(0xfe9d99ef02E905127239E85A611c29ad32c31c2F)] = true;
        _blackListedBots.push(address(0xfe9d99ef02E905127239E85A611c29ad32c31c2F));
        
        _isBlackListedBot[address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b)] = true;
        _blackListedBots.push(address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b));
        
        _isBlackListedBot[address(0xc496D84215d5018f6F53E7F6f12E45c9b5e8e8A9)] = true;
        _blackListedBots.push(address(0xc496D84215d5018f6F53E7F6f12E45c9b5e8e8A9));

        _isBlackListedBot[address(0x59341Bc6b4f3Ace878574b05914f43309dd678c7)] = true;
        _blackListedBots.push(address(0x59341Bc6b4f3Ace878574b05914f43309dd678c7));

        _isBlackListedBot[address(0xe986d48EfeE9ec1B8F66CD0b0aE8e3D18F091bDF)] = true;
        _blackListedBots.push(address(0xe986d48EfeE9ec1B8F66CD0b0aE8e3D18F091bDF));

        _isBlackListedBot[address(0x4aEB32e16DcaC00B092596ADc6CD4955EfdEE290)] = true;
        _blackListedBots.push(address(0x4aEB32e16DcaC00B092596ADc6CD4955EfdEE290));
        
        _isBlackListedBot[address(0x136F4B5b6A306091b280E3F251fa0E21b1280Cd5)] = true;
        _blackListedBots.push(address(0x136F4B5b6A306091b280E3F251fa0E21b1280Cd5));
        
        _isBlackListedBot[address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b)] = true;
        _blackListedBots.push(address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b));
        
        _isBlackListedBot[address(0x5B83A351500B631cc2a20a665ee17f0dC66e3dB7)] = true;
        _blackListedBots.push(address(0x5B83A351500B631cc2a20a665ee17f0dC66e3dB7));
  
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
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

    function addBotToBlackList(address account) external onlyOwner() {
        require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not blacklist Uniswap router.');
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

    function isBlackListed(address account) public view returns (bool) {
        return _isBlackListedBot[account];
    }

    function setCooldownEnabled(bool onoff) external onlyOwner() {
        cooldownEnabled = onoff;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        require(maxTxPercent > 0, "Amount must be greater than 0");
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);
        emit MaxTxAmountUpdated(_maxTxAmount);
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = false;
    }

    function removeAllFee() private {
        if(_taxFee == 0 && _marketingFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousMarketingFee = _marketingFee;

        _taxFee = 0;
        _marketingFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _marketingFee = _previousMarketingFee;
    }

    //to recieve ETH when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tMarketing) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tMarketing, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tMarketing);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tMarketing = calculateMarketingFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tMarketing);
        return (tTransferAmount, tFee, tMarketing);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tMarketing, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rMarketing);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeMarketing(uint256 tMarketing) private {
        uint256 currentRate =  _getRate();
        uint256 rMarketing = tMarketing.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarketing);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tMarketing);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**2
        );
    }

    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketingFee).div(
            10**2
        );
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isBlackListedBot[to], "You have no power here!");
        require(!_isBlackListedBot[from], "You have no power here!");
        require(_isBlacklisted[from] == false || to == address(0), "You are banned");
        require(_isBlacklisted[to] == false, "The recipient is banned");

        if(from != owner() && to != owner()) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            if (from == uniswapV2Pair || to == uniswapV2Pair) {
                require(tradingEnabled, "Trading is not enabled yet");
            }
            require(!bots[from] && !bots[to]);
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to] && cooldownEnabled) {
                require(tradingEnabled);
                require(amount <= _maxTxAmount);
                require(buycooldown[to] < block.timestamp);
                buycooldown[to] = block.timestamp + (2 minutes);
                defaultMarketingFee = 8;
                _marketingFee4Sellers = 8;
            }
        }

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + send lock?
        // also, don't get caught in a circular sending event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensToExchangeForMarketing;

        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }

        if (
            overMinTokenBalance &&
            !inSwapAndSend &&
            from != uniswapV2Pair &&
            SwapAndSendEnabled
        ) {
            SwapAndSend(contractTokenBalance);
        }

        if(feesOnSellersAndBuyers) {
            setFees(to);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        _tokenTransfer(from,to,amount,takeFee);
    }

    function setFees(address recipient) private {
        _taxFee = defaultTaxFee;
        _marketingFee = defaultMarketingFee;
        if (recipient == uniswapV2Pair) { // sell
            _marketingFee = _marketingFee4Sellers;
        }
    }

    function SwapAndSend(uint256 contractTokenBalance) private lockTheSwap {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), contractTokenBalance);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        uint256 contractETHBalance = address(this).balance;
        if(contractETHBalance > 0) {
             _teamWalletAddress.transfer(contractETHBalance.div(2));
            _marketingWalletAddress.transfer(contractETHBalance.div(2));
        }
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeMarketing(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeMarketing(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeMarketing(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeMarketing(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function setDefaultMarketingFee(uint256 marketingFee) external onlyOwner() {
        defaultMarketingFee = marketingFee;
    }

    function setMarketingFee4Sellers(uint256 marketingFee4Sellers) external onlyOwner() {
        _marketingFee4Sellers = marketingFee4Sellers;
    }

    function setFeesOnSellersAndBuyers(bool _enabled) public onlyOwner() {
        feesOnSellersAndBuyers = _enabled;
    }

    function setSwapAndSendEnabled(bool _enabled) public onlyOwner() {
        SwapAndSendEnabled = _enabled;
        emit SwapAndSendEnabledUpdated(_enabled);
    }
    
    function LetTradingBegin(bool _tradingEnabled) external onlyOwner() {
         tradingEnabled = _tradingEnabled;
    }

    function blacklistSingleWallet(address addresses) public onlyOwner(){
        if(_isBlacklisted[addresses] == true) return;
        _isBlacklisted[addresses] = true;
    }

    function blacklistMultipleWallets(address[] calldata addresses) public onlyOwner(){
        for (uint256 i; i < addresses.length; ++i) {
            _isBlacklisted[addresses[i]] = true;
        }
    }
    
    function isBlacklisted(address addresses) public view returns (bool){
        if(_isBlacklisted[addresses] == true) return true;
        else return false;
    }
    
    
    function unBlacklistSingleWallet(address addresses) external onlyOwner(){
         if(_isBlacklisted[addresses] == false) return;
        _isBlacklisted[addresses] = false;
    }

    function unBlacklistMultipleWallets(address[] calldata addresses) public onlyOwner(){
        for (uint256 i; i < addresses.length; ++i) {
            _isBlacklisted[addresses[i]] = false;
        }
    }

    function setnumTokensToExchangeForMarketing(uint256 _numTokensToExchangeForMarketing) public onlyOwner() {
        numTokensToExchangeForMarketing = _numTokensToExchangeForMarketing;
    }

    function _setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
    }
}