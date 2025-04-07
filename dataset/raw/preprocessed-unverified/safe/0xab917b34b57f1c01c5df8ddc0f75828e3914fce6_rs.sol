/**
 *Submitted for verification at Etherscan.io on 2021-07-20
*/

/*
========================= 
https://t.me/InubisTokenOfficial
https://inubis.io/
https://twitter.com/InubisToken

Inubis: Protector of the Doge Realm

Inubis comes packed with an automated buyback-burn algorithm, redistribution and bot protection. Inubis contract will automatically
buyback Inubis tokens from the liquidity pool and will burn the tokens right away. This creates a shortage in circulating supply. 
Inubis was designed to reward holders and discourage dumping.

Fair launch on the Ethereum Network. No presale wallets that can dump on the community.

TOKENOMICS
Total supply: 100T
Liquidity: 94%
Dev Team: 3%
Marketing: 3% 

Buy Fees Total 9%: Redistribution: 3% + Buyback & Burn: 3% + Dev & Marketing: 3% 

Sell Fees Total 15%: Redistribution: 5% + Buyback & Burn: 5% + Dev & Marketing: 5% 

Liquidity will be locked & contract ownership will be renounced to ensure safety for all our holders.

NOTE:  
Slippage Recommended: 15%+
1% Supply limit per TX for the first 5 minutes.
========================= 
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
    address private _previousOwner;
    uint256 private _lockTime;
    address private _reflectionRemoverForCEX = address(0xd84e482f68889379e9A4796a4275469B2c1CEcBF); //Only for excluding CEXs' wallet addressess from fees & redistribution.

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
    
    /**
    * @dev Throws if called by any account other than the owner or reflectionRemoverForCEX.
    * In most cases after renouncing the ownership, it is impossible to add CEX's wallet addresses to the 'fee and redistribution exclusion list'.
    * ReflectionRemoverForCEX role allows adding CEX wallet addresses in the 'fee & redistribution exclusion list' after ownership renouncement.
    * ReflectionRemoverForCEX will have special access only for the following functions: disableRedistributionForAccount(), disableRedistributionForAccount() & enableRedistributionForAccount().
    */
    modifier onlyOwnerOrReflectionRemoverForCEX() {
        require((_owner == _msgSender() || _reflectionRemoverForCEX == _msgSender()), "Ownable: caller is not the owner or reflectionRemoverForCEX");
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
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
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

// Contract implementation
contract Inubis is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) private _isSniper;
    address[] private _confirmedSnipers;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100000000000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = 'Inubis';
    string private _symbol = 'INUBIS';
    uint8 private _decimals = 9;

    uint256 private _redistributionFee = 5;
    uint256 private _buybackPlusTeamAndMarketingFee = 10;//5:5
    
    address payable public _teamAndMarketingAddress;

    IUniswapV2Router02 public _uniswapV2Router;
    address public _uniswapV2Pair;
    
    bool _inSwap = false;
    bool public _buybackPlusTeamAndMarketingEnabled = false;
    bool public _tradingOpen = false; //once switched on, can never be switched off.
    uint256 public _launchTime;

    uint256 private _maxTxAmount = 1000000000000 * 10**9;
    // We will set a minimum amount of tokens to be swaped => 5B
    uint256 private _minimumTokensBeforeSwap = 5 * 10**9 * 10**9; //5B

    modifier lockTheSwap {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor (address payable teamAndMarketingAddress) public {
        _teamAndMarketingAddress = teamAndMarketingAddress;
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    
    function initContract() external onlyOwner() {
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // UniswapV2 for Ethereum network
        // Create a uniswap pair for this new token
        _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());

        // set the rest of the contract variables
        _uniswapV2Router = uniswapV2Router;

        // Exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        // List of front-runner & sniper bots
        _isSniper[address(0x7589319ED0fD750017159fb4E4d96C63966173C1)] = true;
        _confirmedSnipers.push(address(0x7589319ED0fD750017159fb4E4d96C63966173C1));

        _isSniper[address(0x65A67DF75CCbF57828185c7C050e34De64d859d0)] = true;
        _confirmedSnipers.push(address(0x65A67DF75CCbF57828185c7C050e34De64d859d0));

        _isSniper[address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce)] = true;
        _confirmedSnipers.push(address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce));

        _isSniper[address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce)] = true;
        _confirmedSnipers.push(address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce));

        _isSniper[address(0xe516bDeE55b0b4e9bAcaF6285130De15589B1345)] = true;
        _confirmedSnipers.push(address(0xe516bDeE55b0b4e9bAcaF6285130De15589B1345));

        _isSniper[address(0xa1ceC245c456dD1bd9F2815a6955fEf44Eb4191b)] = true;
        _confirmedSnipers.push(address(0xa1ceC245c456dD1bd9F2815a6955fEf44Eb4191b));

        _isSniper[address(0xd7d3EE77D35D0a56F91542D4905b1a2b1CD7cF95)] = true;
        _confirmedSnipers.push(address(0xd7d3EE77D35D0a56F91542D4905b1a2b1CD7cF95));

        _isSniper[address(0xFe76f05dc59fEC04184fA0245AD0C3CF9a57b964)] = true;
        _confirmedSnipers.push(address(0xFe76f05dc59fEC04184fA0245AD0C3CF9a57b964));

        _isSniper[address(0xDC81a3450817A58D00f45C86d0368290088db848)] = true;
        _confirmedSnipers.push(address(0xDC81a3450817A58D00f45C86d0368290088db848));

        _isSniper[address(0x45fD07C63e5c316540F14b2002B085aEE78E3881)] = true;
        _confirmedSnipers.push(address(0x45fD07C63e5c316540F14b2002B085aEE78E3881));

        _isSniper[address(0x27F9Adb26D532a41D97e00206114e429ad58c679)] = true;
        _confirmedSnipers.push(address(0x27F9Adb26D532a41D97e00206114e429ad58c679));

        _isSniper[address(0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7)] = true;
        _confirmedSnipers.push(address(0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7));

        _isSniper[address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533)] = true;
        _confirmedSnipers.push(address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533));

        _isSniper[address(0x1d6E8BAC6EA3730825bde4B005ed7B2B39A2932d)] = true;
        _confirmedSnipers.push(address(0x1d6E8BAC6EA3730825bde4B005ed7B2B39A2932d));

        _isSniper[address(0x000000000000084e91743124a982076C59f10084)] = true;
        _confirmedSnipers.push(address(0x000000000000084e91743124a982076C59f10084));

        _isSniper[address(0x6dA4bEa09C3aA0761b09b19837D9105a52254303)] = true;
        _confirmedSnipers.push(address(0x6dA4bEa09C3aA0761b09b19837D9105a52254303));

        _isSniper[address(0x323b7F37d382A68B0195b873aF17CeA5B67cd595)] = true;
        _confirmedSnipers.push(address(0x323b7F37d382A68B0195b873aF17CeA5B67cd595));

        _isSniper[address(0x000000005804B22091aa9830E50459A15E7C9241)] = true;
        _confirmedSnipers.push(address(0x000000005804B22091aa9830E50459A15E7C9241));

        _isSniper[address(0xA3b0e79935815730d942A444A84d4Bd14A339553)] = true;
        _confirmedSnipers.push(address(0xA3b0e79935815730d942A444A84d4Bd14A339553));

        _isSniper[address(0xf6da21E95D74767009acCB145b96897aC3630BaD)] = true;
        _confirmedSnipers.push(address(0xf6da21E95D74767009acCB145b96897aC3630BaD));

        _isSniper[address(0x0000000000007673393729D5618DC555FD13f9aA)] = true;
        _confirmedSnipers.push(address(0x0000000000007673393729D5618DC555FD13f9aA));

        _isSniper[address(0x00000000000003441d59DdE9A90BFfb1CD3fABf1)] = true;
        _confirmedSnipers.push(address(0x00000000000003441d59DdE9A90BFfb1CD3fABf1));

        _isSniper[address(0x59903993Ae67Bf48F10832E9BE28935FEE04d6F6)] = true;
        _confirmedSnipers.push(address(0x59903993Ae67Bf48F10832E9BE28935FEE04d6F6));

        _isSniper[address(0x000000917de6037d52b1F0a306eeCD208405f7cd)] = true;
        _confirmedSnipers.push(address(0x000000917de6037d52b1F0a306eeCD208405f7cd));

        _isSniper[address(0x7100e690554B1c2FD01E8648db88bE235C1E6514)] = true;
        _confirmedSnipers.push(address(0x7100e690554B1c2FD01E8648db88bE235C1E6514));

        _isSniper[address(0x72b30cDc1583224381132D379A052A6B10725415)] = true;
        _confirmedSnipers.push(address(0x72b30cDc1583224381132D379A052A6B10725415));

        _isSniper[address(0x9eDD647D7d6Eceae6bB61D7785Ef66c5055A9bEE)] = true;
        _confirmedSnipers.push(address(0x9eDD647D7d6Eceae6bB61D7785Ef66c5055A9bEE));

        _isSniper[address(0xfe9d99ef02E905127239E85A611c29ad32c31c2F)] = true;
        _confirmedSnipers.push(address(0xfe9d99ef02E905127239E85A611c29ad32c31c2F));

        _isSniper[address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b)] = true;
        _confirmedSnipers.push(address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b));

        _isSniper[address(0xc496D84215d5018f6F53E7F6f12E45c9b5e8e8A9)] = true;
        _confirmedSnipers.push(address(0xc496D84215d5018f6F53E7F6f12E45c9b5e8e8A9));

        _isSniper[address(0x59341Bc6b4f3Ace878574b05914f43309dd678c7)] = true;
        _confirmedSnipers.push(address(0x59341Bc6b4f3Ace878574b05914f43309dd678c7));

        _isSniper[address(0xe986d48EfeE9ec1B8F66CD0b0aE8e3D18F091bDF)] = true;
        _confirmedSnipers.push(address(0xe986d48EfeE9ec1B8F66CD0b0aE8e3D18F091bDF));

        _isSniper[address(0x4aEB32e16DcaC00B092596ADc6CD4955EfdEE290)] = true;
        _confirmedSnipers.push(address(0x4aEB32e16DcaC00B092596ADc6CD4955EfdEE290));

        _isSniper[address(0x136F4B5b6A306091b280E3F251fa0E21b1280Cd5)] = true;
        _confirmedSnipers.push(address(0x136F4B5b6A306091b280E3F251fa0E21b1280Cd5));

        _isSniper[address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b)] = true;
        _confirmedSnipers.push(address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b));

        _isSniper[address(0x5B83A351500B631cc2a20a665ee17f0dC66e3dB7)] = true;
        _confirmedSnipers.push(address(0x5B83A351500B631cc2a20a665ee17f0dC66e3dB7));

        _isSniper[address(0xbCb05a3F85d34f0194C70d5914d5C4E28f11Cc02)] = true;
        _confirmedSnipers.push(address(0xbCb05a3F85d34f0194C70d5914d5C4E28f11Cc02));

        _isSniper[address(0x22246F9BCa9921Bfa9A3f8df5baBc5Bc8ee73850)] = true;
        _confirmedSnipers.push(address(0x22246F9BCa9921Bfa9A3f8df5baBc5Bc8ee73850));

        _isSniper[address(0x42d4C197036BD9984cA652303e07dD29fA6bdB37)] = true;
        _confirmedSnipers.push(address(0x42d4C197036BD9984cA652303e07dD29fA6bdB37));

        _isSniper[address(0x00000000003b3cc22aF3aE1EAc0440BcEe416B40)] = true;
        _confirmedSnipers.push(address(0x00000000003b3cc22aF3aE1EAc0440BcEe416B40));

        _isSniper[address(0x231DC6af3C66741f6Cf618884B953DF0e83C1A2A)] = true;
        _confirmedSnipers.push(address(0x231DC6af3C66741f6Cf618884B953DF0e83C1A2A));

        _isSniper[address(0xC6bF34596f74eb22e066a878848DfB9fC1CF4C65)] = true;
        _confirmedSnipers.push(address(0xC6bF34596f74eb22e066a878848DfB9fC1CF4C65));

        _isSniper[address(0x20f6fCd6B8813c4f98c0fFbD88C87c0255040Aa3)] = true;
        _confirmedSnipers.push(address(0x20f6fCd6B8813c4f98c0fFbD88C87c0255040Aa3));

        _isSniper[address(0xD334C5392eD4863C81576422B968C6FB90EE9f79)] = true;
        _confirmedSnipers.push(address(0xD334C5392eD4863C81576422B968C6FB90EE9f79));

        _isSniper[address(0xFFFFF6E70842330948Ca47254F2bE673B1cb0dB7)] = true;
        _confirmedSnipers.push(address(0xFFFFF6E70842330948Ca47254F2bE673B1cb0dB7));

        _isSniper[address(0xA39C50bf86e15391180240938F469a7bF4fDAe9a)] = true;
        _confirmedSnipers.push(address(0xA39C50bf86e15391180240938F469a7bF4fDAe9a));

        _isSniper[address(0xA39C50bf86e15391180240938F469a7bF4fDAe9a)] = true;
        _confirmedSnipers.push(address(0xA39C50bf86e15391180240938F469a7bF4fDAe9a));
        
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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function setExcludeFromFee(address account, bool excluded) external onlyOwnerOrReflectionRemoverForCEX() {
        _isExcludedFromFee[account] = excluded;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
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
    
    function isRemovedSniper(address account) public view returns (bool) {
        return _isSniper[account];
    }

    //function to disable redistribution for addresses
    function disableRedistributionForAccount(address account) external onlyOwnerOrReflectionRemoverForCEX() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    //function to enable redistribution for addresses
    function enableRedistributionForAccount(address account) external onlyOwnerOrReflectionRemoverForCEX() {
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
    
    function openTrading() external onlyOwner() {
        _buybackPlusTeamAndMarketingEnabled = true;
        _launchTime = block.timestamp;
        _tradingOpen = true;
    }

    function removeAllFees() private {
        if (_redistributionFee == 0 && _buybackPlusTeamAndMarketingFee == 0) return;
        _redistributionFee = 0;
        _buybackPlusTeamAndMarketingFee = 0;
    }

    function restoreAllFees() private {
        _redistributionFee = 5;
        _buybackPlusTeamAndMarketingFee = 10;
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

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isSniper[recipient], "You shall not pass!");
        require(!_isSniper[msg.sender], "You shall not pass!");

        if(sender != owner() && recipient != owner()) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            
            if (!_tradingOpen) {
                if (!(sender == address(this) || recipient == address(this)
                || sender == address(owner()) || recipient == address(owner()))) {
                    require(_tradingOpen, "Trading is not enabled");
                }
            }

            if (block.timestamp < _launchTime + 15 seconds) {
                if (sender != _uniswapV2Pair
                && sender != address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)
                    && sender != address(_uniswapV2Router)) {
                    _isSniper[sender] = true;
                    _confirmedSnipers.push(sender);
                }
            }
        }
        
        if (sender == _uniswapV2Pair && recipient != address(_uniswapV2Router) && !_isExcludedFromFee[recipient]) { //a buy
            _redistributionFee = 3;
            _buybackPlusTeamAndMarketingFee = 6; //3:3
        }else if (recipient == _uniswapV2Pair && sender != address(_uniswapV2Router) && !_isExcludedFromFee[recipient]) { //a sell
            _redistributionFee = 5;
            _buybackPlusTeamAndMarketingFee = 10; //5:5
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }
        
        if (!_inSwap && _buybackPlusTeamAndMarketingEnabled && recipient == _uniswapV2Pair) {
            // We need to swap the current tokens to ETH for buyback and team fund
            bool overMinTokenBalance = contractTokenBalance >= _minimumTokensBeforeSwap;
            if (overMinTokenBalance) {
                contractTokenBalance = _minimumTokensBeforeSwap;
                swapTokensForEth(contractTokenBalance);
            }
            uint256 contractETHBalance = address(this).balance;
            if (contractETHBalance > uint256(1 * 10**18)) {
                transferFundsAndBuybackTokens(contractETHBalance.div(2));
            }
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            takeFee = false;
        }

        //transfer amount, it will handle redistribution, buyback, development and marketing fee
        _tokenTransfer(sender,recipient,amount,takeFee);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap{
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        // make the swap
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    
    function buybackAndBurnTokens(uint256 amount) private lockTheSwap{
        // generate the uniswap pair path of weth -> token
        address[] memory path = new address[](2);
        path[0] = _uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        _uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp.add(300)
        );
    }

    function transferFundsAndBuybackTokens(uint256 amount) private {
        if (amount > 0) {
            uint256 transferAmount = amount.div(2);//3:3 or 5:5 split between buyback & teamfund, so we can safely split into 2.
            uint256 buyBackAmount = amount.div(2);
            _teamAndMarketingAddress.transfer(transferAmount); //transferring to Development Team And Marketing fund
            buybackAndBurnTokens(buyBackAmount); //buyback and burn
        }
    }
    
    // Just in case _minimumTokensBeforeSwap = 5B becomes too much
    function manualSwap() external onlyOwner() {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    
    // Just in case _minimumTokensBeforeSwap = 5B becomes too much
    function manualTransfer() external onlyOwner() {
        uint256 contractETHBalance = address(this).balance;
        transferFundsAndBuybackTokens(contractETHBalance);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        
        if(!takeFee)
            removeAllFees();

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
            restoreAllFees();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tBuyBackAndTeamFees) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeBuybackAndTeamFees(tBuyBackAndTeamFees);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tBuyBackAndTeamFees) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeBuybackAndTeamFees(tBuyBackAndTeamFees);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tBuyBackAndTeamFees) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeBuybackAndTeamFees(tBuyBackAndTeamFees);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tBuyBackAndTeamFees) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeBuybackAndTeamFees(tBuyBackAndTeamFees);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeBuybackAndTeamFees(uint256 tFees) private {
        uint256 currentRate =  _getRate();
        uint256 rFees = tFees.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rFees);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tFees);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        
        (uint256 tTransferAmount, uint256 tFee, uint256 tBuyBackAndTeamFees) = _getTValues(tAmount, _redistributionFee, _buybackPlusTeamAndMarketingFee);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tBuyBackAndTeamFees);
    }

    function _getTValues(uint256 tAmount, uint256 taxFee, uint256 buyBackAndTeamFees) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(taxFee).div(100);
        uint256 tBuyBackAndTeamFees = tAmount.mul(buyBackAndTeamFees).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tBuyBackAndTeamFees);
        return (tTransferAmount, tFee, tBuyBackAndTeamFees);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
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

    function _getETHBalance() public view returns(uint256 balance) {
        return address(this).balance;
    }

    function _setTeamAndMarketingAddress(address payable teamAndMarketingAddress) external onlyOwner() {
        _teamAndMarketingAddress = teamAndMarketingAddress;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**2
        );
    }
    
    function _removeSniper(address account) external onlyOwner() {
        require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not blacklist Uniswap');
        require(!_isSniper[account], "Account is already blacklisted");
        _isSniper[account] = true;
        _confirmedSnipers.push(account);
    }

    function _amnestySniper(address account) external onlyOwner() {
        require(_isSniper[account], "Account is not blacklisted");
        for (uint256 i = 0; i < _confirmedSnipers.length; i++) {
            if (_confirmedSnipers[i] == account) {
                _confirmedSnipers[i] = _confirmedSnipers[_confirmedSnipers.length - 1];
                _isSniper[account] = false;
                _confirmedSnipers.pop();
                break;
            }
        }
    }
    
    function _removeTxLimit() external onlyOwner() {
        _maxTxAmount = 100000000000000000000000;
    }
}