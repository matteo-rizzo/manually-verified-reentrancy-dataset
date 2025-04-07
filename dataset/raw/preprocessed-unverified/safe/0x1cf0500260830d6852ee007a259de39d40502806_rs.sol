/**
 *Submitted for verification at Etherscan.io on 2021-10-03
*/

// Frogger Token

// Arcade Games are the New Meta.  Frogger will join Tetris as another timeless classic

// Telegram: https://t.me/Froggertoken

// Tokenomics:
// 1% reflection
// 3% Marketing
// 1% App Development
// 7% Competitions Rewards

// SPDX-License-Identifier: Unlicensed

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
    contract FroggerToken is Context, IERC20, Ownable {
        using SafeMath for uint256;
        using Address for address;

        mapping (address => uint256) private _rOwned;
        mapping (address => uint256) private _tOwned;
        mapping (address => mapping (address => uint256)) private _allowances;

        mapping (address => bool) private _isExcludedFromFee;

        mapping (address => bool) private _isExcluded;
        address[] private _excluded;
    
        uint256 private constant MAX = ~uint256(0);
        uint256 private _tTotal = 1000000000000 * 10**18;
        uint256 private _rTotal = (MAX - (MAX % _tTotal));
        uint256 private _tFeeTotal;

        string private _name = 'Frogger Token';
        string private _symbol = 'FROGGER';
        uint8 private _decimals = 18;
        
        // Tax and development fees will start at 0 so we don't have a big impact when deploying to Uniswap
        // development wallet address is null but the method to set the address is exposed
        uint256 private _taxFee = 1; 
        uint256 private _developmentFee = 11;
        uint256 private _previousTaxFee = _taxFee;
        uint256 private _previousDevelopmentFee = _developmentFee;

        address payable public _developmentWalletAddress;
        address payable public _marketingWalletAddress;
        address payable public _competitionsWalletAddress;
        
        IUniswapV2Router02 public immutable uniswapV2Router;
        address public immutable uniswapV2Pair;

        bool inSwap = false;
        bool public swapEnabled = true;

        uint256 private _maxTxAmount = 10000000000 * 10**18;
        // We will set a minimum amount of tokens to be swaped => 5M
        uint256 private _numOfTokensToExchangeForDevelopment = 2500000 * 10**18;
        uint256 private _maxWalletSize = 20000000000 * 10**18;
        

        event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
        event SwapEnabledUpdated(bool enabled);

        modifier lockTheSwap {
            inSwap = true;
            _;
            inSwap = false;
        }

        constructor (address payable developmentWalletAddress, address payable marketingWalletAddress, address payable competitionsWalletAddress) public {
            _developmentWalletAddress = developmentWalletAddress;
            _marketingWalletAddress = marketingWalletAddress;
            _competitionsWalletAddress = competitionsWalletAddress;
            _rOwned[_msgSender()] = _rTotal;

            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // 
            //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // 
            // Create a uniswap pair for this new token
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());

            // set the rest of the contract variables
            uniswapV2Router = _uniswapV2Router;

            // Exclude owner and this contract from fee
            _isExcludedFromFee[owner()] = true;
            _isExcludedFromFee[address(this)] = true;
            _isExcludedFromFee[_developmentWalletAddress] = true;
            _isExcludedFromFee[_marketingWalletAddress] = true;
            _isExcludedFromFee[_competitionsWalletAddress] = true;

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

        function setExcludeFromFee(address account, bool excluded) external onlyOwner() {
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

        function excludeAccount(address account) external onlyOwner() {
            require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
            require(!_isExcluded[account], "Account is already excluded");
            if(_rOwned[account] > 0) {
                _tOwned[account] = tokenFromReflection(_rOwned[account]);
            }
            _isExcluded[account] = true;
            _excluded.push(account);
        }

        function includeAccount(address account) external onlyOwner() {
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

        function removeAllFee() private {
            if(_taxFee == 0 && _developmentFee == 0) return;
            
            _previousTaxFee = _taxFee;
            _previousDevelopmentFee = _developmentFee;
            
            _taxFee = 0;
            _developmentFee = 0;
        }
    
        function restoreAllFee() private {
            _taxFee = _previousTaxFee;
            _developmentFee = _previousDevelopmentFee;
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
            
             if(sender != owner() && recipient != owner()) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            }
            if(sender != owner() && recipient != owner() && recipient != uniswapV2Pair && recipient != address(0xdead)) {
                uint256 tokenBalanceRecipient = balanceOf(recipient);
                require(tokenBalanceRecipient + amount <= _maxWalletSize, "Recipient exceeds max wallet size.");
            }

            // is the token balance of this contract address over the min number of
            // tokens that we need to initiate a swap?
            // also, don't get caught in a circular development event.
            // also, don't swap if sender is uniswap pair.
            uint256 contractTokenBalance = balanceOf(address(this));
            
            if(contractTokenBalance >= _maxTxAmount)
            {
                contractTokenBalance = _maxTxAmount;
            }
            
            bool overMinTokenBalance = contractTokenBalance >= _numOfTokensToExchangeForDevelopment;
            if (!inSwap && swapEnabled && overMinTokenBalance && sender != uniswapV2Pair) {
                // We need to swap the current tokens to ETH and send to the development wallet
                swapTokensForEth(contractTokenBalance);
                
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToDevelopment(address(this).balance);
                }
            }
            
            //indicates if fee should be deducted from transfer
            bool takeFee = true;
            
            //if any account belongs to _isExcludedFromFee account then remove the fee
            if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
                takeFee = false;
            }
            
            //transfer amount, it will take tax and development fee
            _tokenTransfer(sender,recipient,amount,takeFee);
        }

        function swapTokensForEth(uint256 tokenAmount) private lockTheSwap{
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
        
        function sendETHToDevelopment(uint256 amount) private {
            _developmentWalletAddress.transfer(amount.div(11).mul(1));
            _marketingWalletAddress.transfer(amount.div(11).mul(3));
            _competitionsWalletAddress.transfer(amount.div(11).mul(7));
        }
        
        // We are exposing these functions to be able to manual swap and send
        // in case the token is highly valued and 5M becomes too much
        function manualSwap() external onlyOwner() {
            uint256 contractBalance = balanceOf(address(this));
            swapTokensForEth(contractBalance);
        }
        
        function manualSend() external onlyOwner() {
            uint256 contractETHBalance = address(this).balance;
            sendETHToDevelopment(contractETHBalance);
        }

        function setSwapEnabled(bool enabled) external onlyOwner(){
            swapEnabled = enabled;
        }
        
        function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
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
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tDevelopment) = _getValues(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 
            _takeDevelopment(tDevelopment); 
            _reflectFee(rFee, tFee);
            emit Transfer(sender, recipient, tTransferAmount);
        }

        function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tDevelopment) = _getValues(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);    
            _takeDevelopment(tDevelopment);           
            _reflectFee(rFee, tFee);
            emit Transfer(sender, recipient, tTransferAmount);
        }

        function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tDevelopment) = _getValues(tAmount);
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 
            _takeDevelopment(tDevelopment);   
            _reflectFee(rFee, tFee);
            emit Transfer(sender, recipient, tTransferAmount);
        }

        function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tDevelopment) = _getValues(tAmount);
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
            _takeDevelopment(tDevelopment);         
            _reflectFee(rFee, tFee);
            emit Transfer(sender, recipient, tTransferAmount);
        }

        function _takeDevelopment(uint256 tDevelopment) private {
            uint256 currentRate =  _getRate();
            uint256 rDevelopment = tDevelopment.mul(currentRate);
            _rOwned[address(this)] = _rOwned[address(this)].add(rDevelopment);
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)].add(tDevelopment);
        }

        function _reflectFee(uint256 rFee, uint256 tFee) private {
            _rTotal = _rTotal.sub(rFee);
            _tFeeTotal = _tFeeTotal.add(tFee);
        }

         //to recieve ETH from uniswapV2Router when swaping
        receive() external payable {}

        function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
            (uint256 tTransferAmount, uint256 tFee, uint256 tDevelopment) = _getTValues(tAmount, _taxFee, _developmentFee);
            uint256 currentRate =  _getRate();
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
            return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tDevelopment);
        }

        function _getTValues(uint256 tAmount, uint256 taxFee, uint256 developmentFee) private pure returns (uint256, uint256, uint256) {
            uint256 tFee = tAmount.mul(taxFee).div(100);
            uint256 tDevelopment = tAmount.mul(developmentFee).div(100);
            uint256 tTransferAmount = tAmount.sub(tFee).sub(tDevelopment);
            return (tTransferAmount, tFee, tDevelopment);
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
        
        function _getTaxFee() private view returns(uint256) {
            return _taxFee;
        }

        function _getMaxTxAmount() private view returns(uint256) {
            return _maxTxAmount;
        }

        function _getETHBalance() public view returns(uint256 balance) {
            return address(this).balance;
        }
        
        function _setTaxFee(uint256 taxFee) external onlyOwner() {
            require(taxFee >= 0 && taxFee <= 25, 'taxFee should be in 0 - 25');
            _taxFee = taxFee;
        }

        function _setDevelopmentFee(uint256 developmentFee) external onlyOwner() {
            require(developmentFee >= 1 && developmentFee <= 25, 'developmentFee should be in 1 - 25');
            _developmentFee = developmentFee;
        }
        
        function _setDevelopmentWallet(address payable developmentWalletAddress) external onlyOwner() {
            _developmentWalletAddress = developmentWalletAddress;
        }
        
         function _setcompetitionsWallet(address payable competitionsWalletAddress) external onlyOwner() {
            _competitionsWalletAddress = competitionsWalletAddress;
        }
                
        function _setMarketingWallet(address payable marketingWalletAddress) external onlyOwner() {
            _marketingWalletAddress = marketingWalletAddress;
        }
        
        function _setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
            _maxTxAmount = maxTxAmount;
        }
        
         function _setMaxWalletSize (uint256 maxWalletSize) external onlyOwner() {
          _maxWalletSize = maxWalletSize;
        }
    }