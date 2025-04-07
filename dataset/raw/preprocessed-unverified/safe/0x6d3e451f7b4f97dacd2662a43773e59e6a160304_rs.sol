/**
 *Submitted for verification at Etherscan.io on 2021-07-12
*/

//SPDX-License-Identifier: MIT


/*

FairShare

I was testing some ideas on a fair lottery token on ropsten then i saw the EverShare contract. We have some similar ideas so i tweaked my token a bit.

This token save fees in the contract & send to a random single holder wallet in the community every 120-180 mins.

More info:

    - Stealth / fair launch with small liquidity.
    - There is a max tx (buy / sell) & 1 block cooldown to stop bots.
    - A wallet can not hold more than 1.5% total supply.
    - Fees of transactions will stay in the contract as lottery pool, the prize is sent out every 120-180 mins (appro.) to a random single holder wallet.
    - 2% burn fee
    - 8% dev fee (50% lottery pool, 50% shared wallet)

For traders:

    - Total supply: 1 000 000 000 000
    - Max tx (buy/sell): 3 000 000 000
    - Max wallet amount: 15 000 000 000
    - Slippage: 12-15%

Lottery rules:

    - Minimum amount of tokens to be eligible for lottery: 2 000 000 000
    - If you bought and have not sold, you are eligible.
    - Sellers are a part of the token so to be fair, i don't exclude them completely from the lottery prize but there are some punishments:
        - If you sell any amount and your final balance has less than 500 000 000 tokens, you are blacklisted from lottery
        - If you sell any amount and your final balance has more than 500 000 000 tokens, your wallet will be flagged, you can only win 5% of the prize if you are selected by the contract (next draw will have bigger prize, i like EuroMillions style)
        - A seller can only win once, then the wallet is blacklisted from lottery

This is a community token, I will lock LP & renounce ownership.

    - 100% tokens & 1.5-2 ETH will be put in liquidity, 0 dev tokens, 0 burnt. (why burn tokens if you can lower the initial supply on creation ...)
    - I will initially lock all LP in the contract for 7 days.
    - If this token takes off, i will extend the lock / burn liquidity.
    - If this token fails, i will remove the locked liquidity after it unlocks.

Little advertisement:

    - My friend created a new TG group for discussion about new ideas / tokenomics for meme coins: t.me/new_idea_meme, feel free to join & discuss.

Good luck & have fun
*/

pragma solidity ^0.6.12;




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





/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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


/**
 * @dev Collection of functions related to the address type
 */


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

contract Contract is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    struct PlayerInfo {
        bool included;
        bool reduced;
        uint256 index;
    }

    struct Payout {
        address addr;
        uint256 amount;
        uint256 time;
    }

    // uniswap & trading
    address internal constant ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    bool public tradingOpen = false;
    bool private _inSwap = false;
    mapping (address => uint256) private _timestamp;
    uint256 private _coolDown = 15 seconds;

    // token
    mapping(address => bool) public isExcludedFromFee;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;
    uint256 public constant maxTxAmount = 3000 * 10 ** 6 * 10 ** 9;
    uint256 public constant maxWalletAmount = 15000 * 10 ** 6 * 10 ** 9;
    uint256 public constant minHoldForLottery = 2000 * 10 ** 6 * 10 ** 9;
    uint256 public constant minHoldSellerForLottery = 500 * 10 ** 6 * 10 ** 9;
    uint256 private constant _totalSupply = 1000000 * 10 ** 6 * 10 ** 9;
    string private constant _name = 'Fair Share';
    string private constant _symbol = 'FairShare';
    uint8 private constant _decimals = 9;
    uint256 public burnFee = 2; // 2% burn
    uint256 public devFee = 8; // 8% dev (50% lottery pool, 50% shared wallet)
    uint256 private _previousBurnFee = burnFee;
    uint256 private _previousDevFee = devFee;
    address payable private _sharedWallet;
    address private constant _burnAddress = 0x000000000000000000000000000000000000dEaD;

    // for liquidity lock
    uint256 public releaseTime = block.timestamp;

    // lottery
    address[] private _lotteryPlayers;
    Payout[] public lotteryPayout;
    Payout public lastLotteryPayout;
    mapping(address => bool) public isBlacklistedFromLottery;
    mapping(address => PlayerInfo) private _lotteryPlayersInfo;
    uint256 public lotteryBalance = 0;
    uint256 public timeBetweenLotteryDraw = 180;
    uint256 public lastLotteryDraw = block.timestamp;

    modifier lockTheSwap {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor() public {
        _sharedWallet = _msgSender();
        _balances[address(this)] = _totalSupply;
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[address(this)] = true;

        // blacklist contract & burn addr from lottery
        isBlacklistedFromLottery[address(this)] = true;
        isBlacklistedFromLottery[_burnAddress] = true;

        emit Transfer(address(0), address(this), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance.sub(subtractedValue));
        return true; 
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

    function isReducedLotteryPrize(address account) public view returns(bool) {
        return _lotteryPlayersInfo[account].reduced;
    }

    function isLotteryPlayer(address account) public view returns(bool) {
        return _lotteryPlayersInfo[account].included;
    }

    function nbLotteryPlayer() external view returns(uint256) {
        return _lotteryPlayers.length;
    }

    function nbLotteryPayout() external view returns(uint256) {
        return lotteryPayout.length;
    }

    /**
     * @dev Return next lottery draw time
     */
    function nextLotteryDraw() external view returns (uint256) {
        return lastLotteryDraw + timeBetweenLotteryDraw * 1 minutes;
    }

    /**
     * @dev Extends the lock of LP in contract
     */
    function lockLp(uint256 newReleaseTime) external {
        require(_msgSender() == _sharedWallet || _msgSender() == owner(), "You are not allowed to call this function");
        require(newReleaseTime > releaseTime, "You can only extend LP lock time");

        releaseTime = newReleaseTime;
    }

    /**
     * @dev Release LP when its unlock
     */
    function releaseLp() external {
        require(_msgSender() == _sharedWallet || _msgSender() == owner(), "You are not allowed to call this function");
        require(releaseTime < now, "LP still locked");

        IERC20(uniswapV2Pair).transfer(_sharedWallet, IERC20(uniswapV2Pair).balanceOf(address(this)));
    }

    /**
     * @dev Burn LP when its unlock (send all LP to burn address)
     */
    function burnLp() external {
        require(_msgSender() == _sharedWallet || _msgSender() == owner(), "You are not allowed to call this function");

        IERC20(uniswapV2Pair).transfer(_burnAddress, IERC20(uniswapV2Pair).balanceOf(address(this)));
    }

    /**
     * @dev Create uniswap pair, add liquidity & open trading
     */
    function openTrading() external onlyOwner() {
        require(!tradingOpen, "Trading is already enabled / opened");

        uniswapV2Router = IUniswapV2Router02(ROUTER_ADDRESS);

        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        // blacklist uniswap addr from lottery
        isBlacklistedFromLottery[ROUTER_ADDRESS] = true;
        isBlacklistedFromLottery[uniswapV2Pair]  = true;

        // add liquidity
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this), balanceOf(address(this)), 0, 0, address(this), now + 600);

        // open trading
        tradingOpen = true;

        // lock liquidity
        releaseTime = now + 7 days;

        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
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

        if (! isExcludedFromFee[sender] && ! isExcludedFromFee[recipient]) {
            require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

            if (recipient != uniswapV2Pair) {
                require(amount.add(balanceOf(recipient)) <= maxWalletAmount, "Wallet amount exceeds the maxWalletAmount");
            }
        }

        if (sender == uniswapV2Pair) {
            //they just bought so add 1 block cooldown - fuck you frontrunners
            _timestamp[recipient] = block.timestamp.add(_coolDown);
        }

        if (! isExcludedFromFee[sender] && sender != uniswapV2Pair) {
            require(block.timestamp >= _timestamp[sender], "Cooldown");
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 minOfTokensToExchangeForDev = _getMinOfTokensToExchangeForDev();

        if (minOfTokensToExchangeForDev > maxTxAmount) {
            minOfTokensToExchangeForDev = maxTxAmount;
        }

        if (!_inSwap && tradingOpen && sender!= uniswapV2Pair && contractTokenBalance >= minOfTokensToExchangeForDev) {
            _swapTokensForEth(minOfTokensToExchangeForDev);

            _sendETHToFee(address(this).balance);
        }

        bool takeFee = true;

        if(isExcludedFromFee[sender] || isExcludedFromFee[recipient]){
            takeFee = false;
        }

        _tokenTransfer(sender,recipient,amount,takeFee);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            _removeAllFee();

        _transferStandard(sender, recipient, amount);

        if(!takeFee)
            _restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tDev, uint256 tBurn) = _getValues(tAmount);

        _balances[sender]    = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(tTransferAmount);

        _takeAllFee(tDev);
        _sendBurnFee(sender, tBurn);

        // buyer has more than `minHoldForLottery` tokens
        if (_balances[recipient] >= minHoldForLottery) {
            // add new addr to lottery pool
            if (! isLotteryPlayer(recipient) && ! isBlacklistedFromLottery[recipient]) {
                _lotteryPlayers.push(recipient);
                _lotteryPlayersInfo[recipient] = PlayerInfo(true, false, _lotteryPlayers.length - 1);
            }
        }

        // seller has more than `minHoldSellerForLottery` tokens
        if (_balances[sender] >= minHoldSellerForLottery && ! isBlacklistedFromLottery[sender]) {
            if (! isLotteryPlayer(sender)) {
                _lotteryPlayers.push(sender);
                _lotteryPlayersInfo[sender] = PlayerInfo(true, true, _lotteryPlayers.length - 1);
            } else {
                _lotteryPlayersInfo[sender].reduced = true;
            }
        }

        // seller has lass than `minHoldSellerForLottery` tokens
        if (_balances[sender] < minHoldSellerForLottery && ! isBlacklistedFromLottery[sender]) {
            _blacklistFromLottery(sender);
        }

        // draw
        if (block.timestamp >= lastLotteryDraw + timeBetweenLotteryDraw * 1 minutes) {
            _sendLotteryPrize();
        }

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _removeAllFee() private {
        if(burnFee == 0 && devFee == 0) return;

        _previousBurnFee = burnFee;
        _previousDevFee = devFee;
        burnFee = 0;
        devFee = 0;
    }

    function _restoreAllFee() private {
        burnFee = _previousBurnFee;
        devFee = _previousDevFee;
    }

    function _swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount > 0) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();
            _approve(address(this), address(uniswapV2Router), tokenAmount);

            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function _sendETHToFee(uint256 amount) private lockTheSwap {
        if (amount > lotteryBalance) {
            uint256 change = amount.sub(lotteryBalance);

            _sharedWallet.transfer(change.div(2));
            lotteryBalance = lotteryBalance.add(change.div(2));
        }
    }

    function _sendLotteryPrize() private {
        if (_lotteryPlayers.length > 0 && lotteryBalance > 0) {
            uint256 prize = lotteryBalance;
            uint256 index = _semiRandom() % _lotteryPlayers.length;
            address winner = _lotteryPlayers[index];
            address payable target = payable(winner);

            if (isReducedLotteryPrize(winner)) {
                prize = lotteryBalance.div(20);
            }

            target.transfer(prize);

            lastLotteryPayout = Payout(winner, prize, block.timestamp);
            lotteryPayout.push(lastLotteryPayout);

            // reset lastdraw
            lastLotteryDraw = block.timestamp;

            // reset random time between draw
            timeBetweenLotteryDraw = _randtimeBetweenLotteryDraw();

            // seller can only win once
            if (isReducedLotteryPrize(winner)) {
                _blacklistFromLottery(winner);
            }

            // update lottery balance
            lotteryBalance = lotteryBalance.sub(prize);
        }
    }

    function _takeAllFee(uint256 tFee) private {
        if (tFee > 0) {
            _balances[address(this)] = _balances[address(this)].add(tFee);
        }
    }

    function _sendBurnFee(address sender, uint256 tFee) private {
        if (tFee > 0) {
            _balances[_burnAddress] = _balances[_burnAddress].add(tFee);

            emit Transfer(sender, _burnAddress, tFee);
        }
    }

    function _getMinOfTokensToExchangeForDev() private view returns (uint256) {
        (uint256 tokens, , ) = IUniswapV2Pair(uniswapV2Pair).getReserves();

        return tokens.div(100);
    }

    function _blacklistFromLottery(address addr) private {
        isBlacklistedFromLottery[addr] = true;

        if (_lotteryPlayers.length == 1) {
            _lotteryPlayers.pop();

            if (isLotteryPlayer(addr)) {
                _lotteryPlayersInfo[addr].included = false;
            }
        }

        if (_lotteryPlayers.length > 1 && isLotteryPlayer(addr)) {
            uint256 index   = _lotteryPlayersInfo[addr].index;
            address newAddr = _lotteryPlayers[_lotteryPlayers.length - 1];

            if (index < _lotteryPlayers.length) {
                _lotteryPlayers[index] = newAddr;
                
                if (isLotteryPlayer(newAddr)) {
                    _lotteryPlayersInfo[newAddr].index = index;
                }
            }

            _lotteryPlayers.pop();
        }
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tDev = tAmount.mul(devFee).div(100);
        uint256 tBurn = tAmount.mul(burnFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tDev).sub(tBurn);

        return (tTransferAmount, tDev, tBurn);
    }

    function _semiRandom() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
                block.timestamp + block.difficulty +
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
                block.gaslimit +
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
                block.number,
                _lotteryPlayers
            )));
    }

    /**
     * @dev return 120-180 randomly
     */
    function _randtimeBetweenLotteryDraw() private view returns(uint256) {
        uint256 seed = _semiRandom();

        return 120 + seed % 61;
    }

    receive() external payable {}
}