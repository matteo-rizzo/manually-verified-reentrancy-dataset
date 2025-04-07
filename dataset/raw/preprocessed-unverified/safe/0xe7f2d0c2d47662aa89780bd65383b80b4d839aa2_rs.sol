/**
 *Submitted for verification at Etherscan.io on 2021-10-05
*/

// SPDX-License-Identifier: Unlicensed
// Telegram: @Quagtools


pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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





contract Quagtools  is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private bots;
    uint256 private constant total = 1000000000000 * 10**9;
    uint256 private _tFeeTotal;
    address private deadAddress = address(0);
    uint256 private setTax;
    uint256 private burnPer;
    address payable private _feeAddrWallet1;
    address payable private _feeAddrWallet2;
    address payable private _feeAddrWallet3;
    
    string private constant _name = "Quagtools";
    string private constant _symbol = "QUAG";
    uint8 private constant _decimals = 9;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor (address payable _add1,address payable _add2,address payable _add3) {
        _feeAddrWallet1 = _add1;
        _feeAddrWallet2 = _add2;
        _feeAddrWallet3 = _add3;
        balance[address(this)] = total;
        emit Transfer(address(0), address(this), total);
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

    function totalSupply() public pure override returns (uint256) {
        return total;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
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

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!bots[from]);
        if (from != address(this)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance > total/1000){
                if (!inSwap && from != uniswapV2Pair && swapEnabled) {
                    swapTokensForEth(contractTokenBalance);
                    uint256 contractETHBalance = address(this).balance;
                    if(contractETHBalance > 300000000000000000) {
                        sendETHToFee(address(this).balance);
                    }
                }
            }
        }
		
        _tokenTransfer(from,to,amount);
    }


    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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

    function sendETHToFee(uint256 amount) private {
        uint256 toSend = amount/3;
        _feeAddrWallet1.transfer(toSend);
        _feeAddrWallet2.transfer(toSend);
        _feeAddrWallet3.transfer(toSend);
    }
    
    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), total);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        setTax = 8;
        burnPer = 2;
        swapEnabled = true;
        tradingOpen = true;
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }
    
    function blacklist(address _address) external onlyOwner{
            bots[_address] = true;
    }
    
    function removeBlacklist(address notbot) external onlyOwner{
        bots[notbot] = false;
    }
        
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        _transferStandard(sender, recipient, amount);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        uint256 tax = tAmount.mul(setTax)/100;
        uint256 burn = tAmount.mul(burnPer)/100;
        uint256 remaining = tAmount.sub(tax).sub(burn);
        balance[sender] = balance[sender].sub(tAmount);
        balance[address(this)] = balance[address(this)].add(tax);
        balance[deadAddress] = balance[deadAddress].add(burn);
        balance[recipient] = balance[recipient].add(remaining);
        emit Transfer(sender, recipient, tAmount);
    }




    receive() external payable {}
    
    function manualswap() external {
        require(_msgSender() == _feeAddrWallet1);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    
    function manualsend() external {
        require(_msgSender() == _feeAddrWallet2);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

}