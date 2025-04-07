/**
 *Submitted for verification at Etherscan.io on 2021-07-20
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;


// 
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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
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
}

// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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


// 




// 


// 
/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */


// 
abstract contract GShibaRNG is Ownable {
    /**
    * Tiers
    * 0 - Platinum
    * 1 - Gold
    * 2 - Silver
    * 3 - Bronze
     */
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    address payable public platinumWinner;
    address payable public goldWinner;
    address payable public silverWinner;
    address payable public bronzeWinner;
    
    EnumerableSet.AddressSet platinumSet;
    EnumerableSet.AddressSet goldSet;
    EnumerableSet.AddressSet silverSet;
    EnumerableSet.AddressSet bronzeSet;

    EnumerableSet.AddressSet[] gamblingWallets;

    uint256 public platinumMinWeight = 2 * 10 ** 5;
    uint256 public goldMinWeight = 10 ** 5;
    uint256 public silverMinWeight = 5 * 10 ** 4;

    mapping(address => uint256) public gamblingWeights;
    mapping(address => uint256) public ethAmounts;
    mapping(address => bool) public excludedFromGambling;
    mapping(address => bool) public isEthAmountNegative;

    IUniswapV2Router02 public uniswapV2Router;

    uint256 public feeMin = 0.1 * 10 ** 18;
    uint256 public feeMax = 0.3 * 10 ** 18;
    uint256 internal lastTotalFee;

    uint256 public ethWeight = 10 ** 10;

    mapping(address => bool) isGoverner;
    address[] governers;

    event newWinnersSelected(uint256 timestamp, address platinumWinner, address goldWinner, address silverWinner, address bronzeWinner, 
        uint256 platinumEthAmount, uint256 goldEthAmount, uint256 silverEthAmount, uint256 bronzeEthAmount,
        uint256 platinumGShibaAmount, uint256 goldGShibaAmount, uint256 silverGShibaAmount, uint256 bronzeGShibaAmount,
        uint256 lastTotalFee);

    modifier onlyGoverner() {
        require(isGoverner[_msgSender()], "Not governer");
        _;
    }

    constructor(address payable _initialWinner) public
    {
        platinumWinner = _initialWinner;
        goldWinner = _initialWinner;
        silverWinner = _initialWinner;
        bronzeWinner = _initialWinner;
        
        platinumSet.add(_initialWinner);
        goldSet.add(_initialWinner);
        silverSet.add(_initialWinner);
        bronzeSet.add(_initialWinner);

        gamblingWallets.push(platinumSet);
        gamblingWallets.push(goldSet);
        gamblingWallets.push(silverSet);
        gamblingWallets.push(bronzeSet);

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // UniswapV2 for Ethereum network

        isGoverner[owner()] = true;
        governers.push(owner());
    }

    function checkTierFromWeight(uint256 weight)
        public
        view
        returns(uint256)
    {
        if (weight > platinumMinWeight) {
            return 0;
        }
        if (weight > goldMinWeight) {
            return 1;
        }
        if (weight > silverMinWeight) {
            return 2;
        }
        return 3;
    }

    function calcWeight(uint256 ethAmount, uint256 gShibaAmount) public view returns(uint256) {
        return ethAmount.div(10 ** 13) + gShibaAmount.div(10 ** 13).div(ethWeight);
    }

    function addNewWallet(address _account, uint256 tier) internal {
        gamblingWallets[tier].add(_account);
    }

    function removeWallet(address _account, uint256 tier) internal {
        gamblingWallets[tier].remove(_account);
    }

    function addWalletToGamblingList(address _account, uint256 _amount) internal {
        if (!excludedFromGambling[_account]) {
            address[] memory path = new address[](2);
            path[0] = uniswapV2Router.WETH();
            path[1] = address(this);
            
            uint256 ethAmount = uniswapV2Router.getAmountsIn(_amount, path)[0];
            
            uint256 oldWeight = gamblingWeights[_account];

            if (isEthAmountNegative[_account]) {
                if (ethAmount > ethAmounts[_account]) {
                    ethAmounts[_account] = ethAmount - ethAmounts[_account];
                    isEthAmountNegative[_account] = false;

                    gamblingWeights[_account] = calcWeight(ethAmounts[_account], IERC20(address(this)).balanceOf(_account) + _amount);
                } else {
                    ethAmounts[_account] = ethAmounts[_account] - ethAmount;
                    gamblingWeights[_account] = 0;
                }
            } else {
                ethAmounts[_account] += ethAmount;

                gamblingWeights[_account] = calcWeight(ethAmounts[_account], IERC20(address(this)).balanceOf(_account) + _amount);
            }

            if (!isEthAmountNegative[_account]) {
                uint256 oldTier = checkTierFromWeight(oldWeight);
                uint256 newTier = checkTierFromWeight(gamblingWeights[_account]);

                if (oldTier != newTier) {
                    removeWallet(_account, oldTier);
                }

                addNewWallet(_account, newTier);
            }
        }
    }

    function removeWalletFromGamblingList(address _account, uint256 _amount) internal {
        if (!excludedFromGambling[_account]) {
            address[] memory path = new address[](2);
            path[0] = uniswapV2Router.WETH();
            path[1] = address(this);
            
            uint256 ethAmount = uniswapV2Router.getAmountsIn(_amount, path)[0];

            uint256 oldWeight = gamblingWeights[_account];

            if (isEthAmountNegative[_account]) {
                ethAmounts[_account] += ethAmount;
                gamblingWeights[_account] = 0;
            } else if (ethAmounts[_account] >= ethAmount) {
                ethAmounts[_account] -= ethAmount;
                gamblingWeights[_account] = calcWeight(ethAmounts[_account], IERC20(address(this)).balanceOf(_account));
            } else {
                ethAmounts[_account] = ethAmount - ethAmounts[_account];
                isEthAmountNegative[_account] = true;
                gamblingWeights[_account] = 0;
            }

            uint256 oldTier = checkTierFromWeight(oldWeight);
            removeWallet(_account, oldTier);
        }
    }

    function rand(uint256 max)
        private
        view
        returns(uint256)
    {
        if (max == 1) {
            return 0;
        }

        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
            block.gaslimit +
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
            block.number
        )));

        return (seed - ((seed / (max - 1)) * (max - 1))) + 1;
    }

    function checkAndChangeGamblingWinner() internal {
        uint256 randFee = rand(feeMax - feeMin) + feeMin;

        if (lastTotalFee >= randFee) {
            uint256 platinumWinnerIndex = rand(gamblingWallets[0].length());
            uint256 goldWinnerIndex = rand(gamblingWallets[1].length());
            uint256 silverWinnerIndex = rand(gamblingWallets[2].length());
            uint256 bronzeWinnerIndex = rand(gamblingWallets[3].length());

            platinumWinner = payable(gamblingWallets[0].at(platinumWinnerIndex));
            goldWinner = payable(gamblingWallets[1].at(goldWinnerIndex));
            silverWinner = payable(gamblingWallets[2].at(silverWinnerIndex));
            bronzeWinner = payable(gamblingWallets[3].at(bronzeWinnerIndex));

            emit newWinnersSelected(
                block.timestamp, platinumWinner, goldWinner, silverWinner, bronzeWinner, 
                ethAmounts[platinumWinner], ethAmounts[goldWinner], ethAmounts[silverWinner], ethAmounts[bronzeWinner],
                IERC20(address(this)).balanceOf(platinumWinner), IERC20(address(this)).balanceOf(goldWinner), IERC20(address(this)).balanceOf(silverWinner), IERC20(address(this)).balanceOf(bronzeWinner),
                lastTotalFee
            );
        }
    }

    /**
    * Mutations
     */

    function setEthWeight(uint256 _ethWeight) external onlyGoverner {
        ethWeight = _ethWeight;
    }

    function setTierWeights(uint256 _platinumMin, uint256 _goldMin, uint256 _silverMin) external onlyGoverner {
        require(_platinumMin > _goldMin && _goldMin > _silverMin, "Weights should be descending order");

        platinumMinWeight = _platinumMin;
        goldMinWeight = _goldMin;
        silverMinWeight = _silverMin;
    }

    function setFeeMinMax(uint256 _feeMin, uint256 _feeMax) external onlyGoverner {
        require(_feeMin < _feeMax, "feeMin should be smaller than feeMax");

        feeMin = _feeMin;
        feeMax = _feeMax;
    }

    function addGoverner(address _governer) public onlyGoverner {
        if (!isGoverner[_governer]) {
            isGoverner[_governer] = true;
            governers.push(_governer);
        }
    }

    function removeGoverner(address _governer) external onlyGoverner {
        if (isGoverner[_governer]) {
            isGoverner[_governer] = false;

            for (uint i = 0; i < governers.length; i ++) {
                if (governers[i] == _governer) {
                    governers[i] = governers[governers.length - 1];
                    governers.pop();
                    break;
                }
            }
        }
    }

    function migrate(address _user, uint256 _gShibaAmount) external onlyGoverner returns(bool) {
        uint256 ethAmount = _gShibaAmount.div(10 ** 10);
        uint256 weight = calcWeight(ethAmount, _gShibaAmount);
        uint256 tier = checkTierFromWeight(weight);

        gamblingWallets[tier].add(_user);
        ethAmounts[_user] = ethAmount;
        gamblingWeights[_user] = weight;

        return true;
    }
}

/*                                                                                                                                                                                       
Gambler Shiba
https://t.me/gshiba_official

More info:

    * Instead of giving equal weights to all users, we give weights based on their purchase token amount and contributed ETH amount
    * If you sell or transfer tokens to other wallets, you lose your ticket, but as soon as you buy again you regain your ticket
    * There's no min eligible amount. Even if you buy 1 token, you have the very little chance to get rewarded.
*/
// 
// Contract implementation
contract GamblerShiba is IERC20, Ownable, GShibaRNG {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) public timestamp;

    uint256 private eligibleRNG = block.timestamp;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isBlackListedBot;

    uint256 private _tTotal = 1000000000000 * 10 ** 18;  //1,000,000,000,000

    uint256 public _coolDown = 30 seconds;

    string private _name = 'Gambler Shiba';
    string private _symbol = 'GSHIBA';
    uint8 private _decimals = 18;
    
    uint256 public _devFee = 12;
    uint256 private _previousdevFee = _devFee;

    address payable private _feeWalletAddress;
    
    address public uniswapV2Pair;

    bool inSwap = false;
    bool public swapEnabled = true;
    bool public feeEnabled = true;
    
    bool public tradingEnabled = false;
    bool public cooldownEnabled = true;

    uint256 public _maxTxAmount = _tTotal / 400;
    uint256 private _numOfTokensToExchangeFordev = 5000000000000000;

    address public migrator;

    event SwapEnabledUpdated(bool enabled);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address payable feeWalletAddress)
        GShibaRNG(feeWalletAddress)
        public
    {
        _feeWalletAddress = feeWalletAddress;
        _tOwned[_msgSender()] = _tTotal;

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());

        // Exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        // Excluded gshiba, pair, owner from gambling list
        excludedFromGambling[address(this)] = true;
        excludedFromGambling[uniswapV2Pair] = true;
        excludedFromGambling[owner()] = true;

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
        return _tOwned[account];
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
    
    function isBlackListed(address account) public view returns (bool) {
        return _isBlackListedBot[account];
    }

    function setExcludeFromFee(address account, bool excluded) external onlyGoverner {
        _isExcludedFromFee[account] = excluded;
    }

    function addBotToBlackList(address account) external onlyOwner() {
        require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not blacklist Uniswap router.');
        require(!_isBlackListedBot[account], "Account is already blacklisted");
        _isBlackListedBot[account] = true;
    }
    
    function addBotsToBlackList(address[] memory bots) external onlyOwner() {
        for (uint i = 0; i < bots.length; i++) {
            _isBlackListedBot[bots[i]] = true;
        }
    }

    function removeBotFromBlackList(address account) external onlyOwner() {
        require(_isBlackListedBot[account], "Account is not blacklisted");
        _isBlackListedBot[account] = false;
    }

    function removeAllFee() private {
        if(_devFee == 0) return;
        _previousdevFee = _devFee;
        _devFee = 0;
    }

    function restoreAllFee() private {
        _devFee = _previousdevFee;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**2
        );
    }
    
    function setMaxTxAmount(uint256 maxTx) external onlyOwner() {
        _maxTxAmount = maxTx;
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
        require(!_isBlackListedBot[recipient], "Go away");
        require(!_isBlackListedBot[sender], "Go away");

        if(sender != owner() && recipient != owner() && sender != migrator && recipient != migrator) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the max amount.");

            // You can't trade this yet until trading enabled, be patient 
            if (sender == uniswapV2Pair || recipient == uniswapV2Pair) {
                require(tradingEnabled, "Trading is not enabled");
            }
        }

        // Cooldown
        if(cooldownEnabled) {
            if (sender == uniswapV2Pair ) {
                // They just bought so add cooldown
                timestamp[recipient] = block.timestamp.add(_coolDown);
            }

            // exclude owner and uniswap
            if(sender != owner() && sender != uniswapV2Pair) {
                require(block.timestamp >= timestamp[sender], "Cooldown");
            }
        }

        if (sender == uniswapV2Pair) {
            if (recipient != owner() && feeEnabled) {
                addWalletToGamblingList(recipient, amount);
            }
        }

        // rest of the standard shit below

        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >= _numOfTokensToExchangeFordev;
        if (!inSwap && swapEnabled && overMinTokenBalance && sender != uniswapV2Pair) {
            // We need to swap the current tokens to ETH and send to the dev wallet
            swapTokensForEth(contractTokenBalance);

            uint256 contractETHBalance = address(this).balance;
            if(contractETHBalance > 0) {
                sendETHTodev(address(this).balance);
            }
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            takeFee = false;
        }

        // transfer amount, it will take tax and dev fee
        _tokenTransfer(sender, recipient, amount, takeFee);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    
    function sendETHTodev(uint256 amount) private {
        if (block.timestamp >= eligibleRNG) {
            checkAndChangeGamblingWinner();
        }

        uint256 winnerReward = amount.div(30);

        lastTotalFee += winnerReward;

        platinumWinner.transfer(winnerReward.mul(4));
        goldWinner.transfer(winnerReward.mul(3));
        silverWinner.transfer(winnerReward.mul(2));
        bronzeWinner.transfer(winnerReward.mul(1));

        _feeWalletAddress.transfer(amount.mul(2).div(3));
    }
    
    // We are exposing these functions to be able to manual swap and send
    // in case the token is highly valued and 5M becomes too much
    function manualSwap() external onlyGoverner {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    
    function manualSend() external onlyGoverner {
        uint256 contractETHBalance = address(this).balance;
        sendETHTodev(contractETHBalance);
    }

    function setSwapEnabled(bool enabled) external onlyOwner(){
        swapEnabled = enabled;
        emit SwapEnabledUpdated(enabled);
    }    
    
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            removeAllFee();

        _transferStandard(sender, recipient, amount);

        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        uint256 tdev = tAmount.mul(_devFee).div(100);
        uint256 transferAmount = tAmount.sub(tdev);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(transferAmount);
        
        // Stop wallets from trying to stay in gambling by transferring to other wallets
        removeWalletFromGamblingList(sender, tAmount);
        
        _takedev(tdev); 
        emit Transfer(sender, recipient, transferAmount);
    }

    function _takedev(uint256 tdev) private {
        _tOwned[address(this)] = _tOwned[address(this)].add(tdev);
    }

        //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getMaxTxAmount() private view returns(uint256) {
        return _maxTxAmount;
    }

    function _getETHBalance() public view returns(uint256 balance) {
        return address(this).balance;
    }
    
    function allowDex(bool _tradingEnabled) external onlyOwner() {
        tradingEnabled = _tradingEnabled;
        eligibleRNG = block.timestamp + 25 minutes;
    }
    
    function toggleCoolDown(bool _cooldownEnabled) external onlyOwner() {
        cooldownEnabled = _cooldownEnabled;
    }
    
    function toggleFeeEnabled(bool _feeEnabled) external onlyOwner() {
        // this is a failsafe if something breaks with mappings we can turn off so no-one gets rekt and can still trade
        feeEnabled = _feeEnabled;
    }

    function setMigrationContract(address _migrator) external onlyGoverner {
        excludedFromGambling[_migrator] = true;
        _isExcludedFromFee[_migrator] = true;
        addGoverner(_migrator);
        migrator = _migrator;
    }
}