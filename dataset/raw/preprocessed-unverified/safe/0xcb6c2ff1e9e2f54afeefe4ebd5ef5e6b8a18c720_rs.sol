/**
 *Submitted for verification at Etherscan.io on 2021-08-19
*/

pragma solidity 0.8.6;

// SPDX-License-Identifier: Apache-2.0

                                       
//                                  ###### 
//                          ,,,((((((((((# 
//                       ,.     (((((((((# 
//                   ,....      .((((((#  
//                  *.....#####......((#   
//               *,,,....######......*    
//       ##((((**,,,,,,,...##.....,**     
//     #####(((*,,,,####,,,,,,,,,,**       
//           (*,,,,,####,,,,,,,,*          
//           *,,,,,,,,,,,,,**             
//         #(((*,,,,,,,,**/##              
//      *,,##(((((#  ##((((##              
//   ..//(((#(##      ##((#               
//   .**///*/          ##                 
//   ,..**.           
//
// $ISS - https://t.me/issethofficial

// Fair stealth launch. 40% Burn, 50% LP, 10% vested for development
// LP lock immediately on launch.
// Ownership will be renounced after launch.
// Slippage recommended: 17%+





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
 


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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

contract ISS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    uint256 private _totalSupply = 20111998 * 10**9;

    string private _name = "International Space Station";
    string private _symbol = "ISS";
    uint8 private _decimals = 9;

    uint256 public _buybackDevFee = 15;
    uint256 private _previousBuybackDevFee = _buybackDevFee;

    address payable private _feeWallet = payable(0xbBD0CdeA2EE8fF5288D3A34c3DE6ae235334c18c);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool currentlySwapping;
    bool public swapAndRedirectEthFeesEnabled = true;

    uint256 private tokensSoldThresholdForEthSwap = 1000 * 10**9;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndRedirectEthFeesUpdated(bool enabled);
    event OnSwapAndRedirectEthFees(
        uint256 tokensSwapped,
        uint256 ethToFeeWallet
    );

    modifier lockTheSwap() {
        currentlySwapping = true;
        _;
        currentlySwapping = false;
    }

    constructor() {
        _balances[_msgSender()] = _totalSupply;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        // exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _balances[account];
    }

    function feeWallet() public view returns (address paybable) {
        return _feeWallet;
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // start swap to ETH
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >=
            tokensSoldThresholdForEthSwap;
        if (overMinTokenBalance &&
            !currentlySwapping &&
            from != uniswapV2Pair &&
            swapAndRedirectEthFeesEnabled
        ) {
            // add fees
            swapAndRedirectEthFees(contractTokenBalance);
        }

        // transfer amount
        _tokenTransfer(from, to, amount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            removeAllFee();
        }

        (uint256 tTransferAmount, uint256 tFee) = _getValues(amount);
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(tTransferAmount);
        _takeFee(tFee);

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            restoreAllFee();
        }

        emit Transfer(sender, recipient, tTransferAmount);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tFee = calculateFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _takeFee(uint256 fee) private {
        _balances[address(this)] = _balances[address(this)].add(fee);
    }

    function calculateFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_buybackDevFee).div(100);
    }

    function removeAllFee() private {
        if (_buybackDevFee == 0) return;

        _previousBuybackDevFee = _buybackDevFee;

        _buybackDevFee = 0;
    }

    function restoreAllFee() private {
        _buybackDevFee = _previousBuybackDevFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function swapAndRedirectEthFees(uint256 contractTokenBalance) private lockTheSwap {
        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the fee events include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(contractTokenBalance);

        uint256 newBalance = address(this).balance.sub(initialBalance);

        if (newBalance > 0) {
            //
            // for shills/buybacks/dev
            // send to the buyback wallet
            //

            sendEthToFeeWallet(newBalance);

            emit OnSwapAndRedirectEthFees(contractTokenBalance, newBalance);
        }
    }

    function sendEthToFeeWallet(uint256 amount) private {
        _feeWallet.transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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

    function manualSwap() external onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualSend() external onlyOwner {
        uint256 contractEthBalance = address(this).balance;
        sendEthToFeeWallet(contractEthBalance);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setBuybackDevFee(uint256 fee) external onlyOwner {
        require(fee <= 20, "Amount exceeds maximum allowed fee");
        _buybackDevFee = fee;
    }

    function _setFeeWallet(address payable newFeeWallet) external onlyOwner {
        _feeWallet = newFeeWallet;
    }

    function setRouterAddress(address payable newRouter) external onlyOwner {
        IUniswapV2Router02 _newUniswapRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newUniswapRouter.factory())
            .createPair(address(this), _newUniswapRouter.WETH());
        uniswapV2Router = _newUniswapRouter;
    }

    function setSwapAndRedirectEthFeesEnabled(bool _enabled) public onlyOwner {
        swapAndRedirectEthFeesEnabled = _enabled;
        emit SwapAndRedirectEthFeesUpdated(_enabled);
    }
}