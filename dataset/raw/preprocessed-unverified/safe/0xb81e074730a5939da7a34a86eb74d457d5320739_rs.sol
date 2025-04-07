/**
 *Submitted for verification at Etherscan.io on 2021-10-02
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier:MIT
//HJAELPCOIN



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return (msg.sender);
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = (address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(
            block.timestamp > _lockTime,
            "Contract is locked until defined days"
        );
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
        _previousOwner = address(0);
    }
}







interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}



// Protocol by team BloctechSolutions.com

contract HjaelpCoin is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    mapping(address => bool) private _isExcludedFromFee;

    uint256 public _taxFee;
    uint256 public _liquidityFee;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled; // should be true to turn on to add liquidty
    bool public buyBackEnabled; // should be true to turn on to buy back from pool
    bool public _tradingOpen; // should be true to turn on trading, one time process

    uint256 public _minTokensToAddToLiquidity;
    uint256 public buyBackLowerLimit = 0.1 ether;
    uint256 public buyBackUpperLimit = 1 ether;

    address private providerAddress;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event BuyBackEnabledUpdated(bool enabled);
    event BuyBack(address indexed receiver, uint256 indexed bnbAmount);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _name = "HjaelpCoin";
        _symbol = "HJAELP";
        _decimals = 18;
        _totalSupply = 1000000000 * (10**18); // total Supply: 1B

        // unit of 0.01%
        _taxFee = 400;
        _liquidityFee = 400;

        _minTokensToAddToLiquidity = 10000 * (10**18); // 0.1M

        _balances[owner()] = _balances[owner()].add(_totalSupply);

        // The service provider wallet that takes tax from transactions
        providerAddress = owner();

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // Set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        // Exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), owner(), _totalSupply);
    }

    receive() external payable {}

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

    function setMinTokensToAddToLiquidity(uint256 minTokensToAddToLiquidity)
        external
        onlyOwner
    {
        _minTokensToAddToLiquidity = minTokensToAddToLiquidity;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setBuyback(
        bool _state,
        uint256 _upperAmount,
        uint256 _lowerAmount
    ) public onlyOwner {
        buyBackEnabled = _state;
        buyBackUpperLimit = _upperAmount;
        buyBackLowerLimit = _lowerAmount;
    }

    function setProviderAddress(address newProviderAddress) external onlyOwner {
        // Remove the current provider from Tax Exclusion List.
        includeInFee(providerAddress);

        // Remove the current provider from Tax Exclusion List.
        excludeFromFee(newProviderAddress);

        providerAddress = newProviderAddress;
    }

    function startTrading() external onlyOwner {
        require(!_tradingOpen, "Tradiing already enabled");
        _tradingOpen = true;
        swapAndLiquifyEnabled = true;
        buyBackEnabled = true;

        emit SwapAndLiquifyEnabledUpdated(true);
        emit BuyBackEnabledUpdated(true);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balances[sender] >= amount, "Transfer amount exceeds balance");

        if (!_tradingOpen && sender != owner() && recipient != owner()) {
            require(
                sender != uniswapV2Pair && recipient != uniswapV2Pair,
                "Trading is not enabled"
            );
        }

        uint256 totalFee = 0;

        if (!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            // Take tax of transaction and transfer to the provider wallet.
            uint256 taxFeeAmount = amount.mul(_taxFee).div(10000);
            _balances[providerAddress] = _balances[providerAddress].add(
                taxFeeAmount
            );
            emit Transfer(sender, providerAddress, taxFeeAmount);

            // Take tax of transaction and add to liquidity.
            uint256 liquidityFeeAmount = amount.mul(_liquidityFee).div(10000);
            _balances[address(this)] = _balances[address(this)].add(
                liquidityFeeAmount
            );
            emit Transfer(sender, address(this), liquidityFeeAmount);

            // is the token balance of this contract address over the min number of
            // tokens that we need to initiate a swap + liquidity lock?
            // also, don't get caught in a circular liquidity event.
            // also, don't swap & liquify if sender is uniswap pair.
            uint256 contractTokenBalance = _balances[address(this)];

            bool overMinTokenBalance = contractTokenBalance >=
                _minTokensToAddToLiquidity;
            if (
                overMinTokenBalance &&
                !inSwapAndLiquify &&
                sender != uniswapV2Pair &&
                swapAndLiquifyEnabled
            ) {
                contractTokenBalance = _minTokensToAddToLiquidity;
                //add liquidity
                swapAndLiquify(contractTokenBalance);
            }

            totalFee = taxFeeAmount.add(liquidityFeeAmount);
        }

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount.sub(totalFee));
        emit Transfer(sender, recipient, amount.sub(totalFee));
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // now is to lock into liquidity pool
        Utils.swapTokensForEth(address(uniswapV2Router), half);

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        Utils.addLiquidity(
            address(uniswapV2Router),
            owner(),
            otherHalf,
            newBalance
        );

        // buy back if balance bnb is exceed lower limit
        if (buyBackEnabled && initialBalance > uint256(buyBackLowerLimit)) {
            if (initialBalance > buyBackUpperLimit)
                initialBalance = buyBackUpperLimit;
            Utils.swapETHForTokens(
                address(uniswapV2Router),
                address(this),
                initialBalance.div(10)
            );

            emit BuyBack(address(this), initialBalance.div(10));
        }

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
}

