/**
 *Submitted for verification at Etherscan.io on 2021-07-02
*/

//website : polytopia.dog 

/*


.----.  .----. .-. .-.  .-..---.  .----. .----. .-.  .--.  
| {}  }/  {}  \| |  \ \/ /{_   _}/  {}  \| {}  }| | / {} \ 
| .--' \      /| `--.}  {   | |  \      /| .--' | |/  /\  \
`-'     `----' `----'`--'   `-'   `----' `-'    `-'`-'  `-'


One Lucky Holder will receive development fee every hour!! Hold and Earn!! 



More info:
    * This contract has a fee that will initially be set to 6% at launch and is to be shared, the community decides the final fee
    * After launch, _devWalletAddress will be randomely set to a single wallet who has bought this token and not sold as specified above
    * There is a 1 block cooldown that will stay as is to stop filthy front running bots
    * The _devWalletAddress will be chosen from hodlers randomely and will be set to last between 1 - 60 minutes at any one time, until another wallet is randomely chosen when that time is up
    * If you bought and have not sold, you are eligible
    * If you sell you lose your 'ticket', but as soon as you buy again you regain your 'ticket'
    * If you buy and transfer tokens to sell from another wallet, you lose your ticket, but as soon as you buy again you regain your ticket
    * TLDR -> Just HODL
    
    Tax fee (RFI) is set to 3%


*/

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
    contract PolytopiaInu is Context, IERC20, Ownable {
        using SafeMath for uint256;
        using Address for address;

        mapping (address => uint256) private _rOwned;
        mapping (address => uint256) private _tOwned;
        mapping (address => mapping (address => uint256)) private _allowances;
        mapping (address => uint256) public timestamp;
        
        
        mapping (address => bool) private _isInDevLottery;
        address[] private _DevLotteryWallets;
        
        uint256 private TimeBetweenShuffle = 25 minutes;
        uint256 private LastShuffle = block.timestamp;

        mapping (address => bool) private _isExcludedFromFee;
    
        mapping (address => bool) private _isExcluded;
        address[] private _excluded;
        
        mapping (address => bool) private _isBlackListedBot;
        address[] private _blackListedBots;
    
        uint256 private constant MAX = ~uint256(0);
        uint256 private _tTotal = 1000000000000000000000;  //1,000,000,000,000
        uint256 private _rTotal = (MAX - (MAX % _tTotal));
        uint256 private _tFeeTotal;
        uint256 private RandReturned;
        

        uint256 public _CoolDown = 15 seconds;
        uint256 public minEligibleAmount = 50000000000000000;
        uint256 public _maxHoldAmount = 50000000000000000;
        

        string private _name = 'Polytopia Inu';
        string private _symbol = 'POLYTOPIA';
        uint8 private _decimals = 9;
        
      
        uint256 private _taxFee = 0; 
        uint256 private _devFee = 0;
        uint256 private _previousTaxFee = _taxFee;
        uint256 private _previousdevFee = _devFee;

        address payable public _devWalletAddress;
        address payable private _sharedWalletAddress;
        
        IUniswapV2Router02 public immutable uniswapV2Router;
        address public immutable uniswapV2Pair;

        bool inSwap = false;
        bool public swapEnabled = true;
        bool public feeEnabled = true;
        bool public shuffleEnabled = false;
        
        bool public tradingEnabled = false;
        bool public cooldownEnabled = true;

        uint256 public _maxTxAmount = _tTotal; 
        uint256 private _numOfTokensToExchangeFordev = 5000000000000000;

        event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
        event SwapEnabledUpdated(bool enabled);

        modifier lockTheSwap {
            inSwap = true;
            _;
            inSwap = false;
        }

        constructor (address payable devWalletAddress, address payable sharedWalletAddress) public {
            _devWalletAddress = devWalletAddress;
            _sharedWalletAddress = sharedWalletAddress;
            _rOwned[_msgSender()] = _rTotal;

            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // UniswapV2 for Ethereum network
            // Create a uniswap pair for this new token
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());

            // set the rest of the contract variables
            uniswapV2Router = _uniswapV2Router;

            // Exclude owner and this contract from fee
            _isExcludedFromFee[owner()] = true;
            _isExcludedFromFee[address(this)] = true;
            
            _isBlackListedBot[address(0x7589319ED0fD750017159fb4E4d96C63966173C1)] = true;
            _blackListedBots.push(address(0x7589319ED0fD750017159fb4E4d96C63966173C1));
            
            
            
            _isInDevLottery[address(devWalletAddress)] = true;
            _DevLotteryWallets.push(address(devWalletAddress));
            _isInDevLottery[address(sharedWalletAddress)] = true;
            _DevLotteryWallets.push(address(sharedWalletAddress));

            
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
        
        function isBlackListed(address account) public view returns (bool) {
            return _isBlackListedBot[account];
        }
        
         function isEligible(address account) public view returns (bool) {
            return _isInDevLottery[account];
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
        
        
        
      function addWalletToDevList(address account) private {
            if (!_isInDevLottery[account]) {
            
            _isInDevLottery[account] = true;
            _DevLotteryWallets.push(account);
            
            }
        }
    
        function removeWalletFromDevList(address account) private {
           if (_isInDevLottery[account]) {
            
            for (uint256 i = 0; i < _DevLotteryWallets.length; i++) {
                if (_DevLotteryWallets[i] == account) {
                    _DevLotteryWallets[i] = _DevLotteryWallets[_DevLotteryWallets.length - 1];
                    _isInDevLottery[account] = false;
                    _DevLotteryWallets.pop();
                    break;
                }
            }
            
         }
        
        
        }

        function removeAllFee() private {
            if(_taxFee == 0 && _devFee == 0) return;
            
            _previousTaxFee = _taxFee;
            _previousdevFee = _devFee;
            
            _taxFee = 0;
            _devFee = 0;
        }
    
        function restoreAllFee() private {
            _taxFee = _previousTaxFee;
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
        
         function setMaxHoldAmount(uint256 maxHold) external onlyOwner() {
                _maxHoldAmount = maxHold;
        }
        
        
            function setminEligibleAmount(uint256 minEligible) external onlyOwner() {
                minEligibleAmount = minEligible;
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
            
            if(sender != owner() && recipient != owner()) {
                    
                    require(amount <= _maxTxAmount, "Transfer amount exceeds the max amount.");
                
                    //you can't trade this yet until trading enabled, be patient 
                    if (sender == uniswapV2Pair || recipient == uniswapV2Pair) { require(tradingEnabled, "Trading is not enabled");}
              
            }

             //cooldown logic  - add a single block cooldown to stop bots 
             
             if(cooldownEnabled) {
              
              //perform all cooldown checks 
              
                      if (sender == uniswapV2Pair ) {
                        
                         require(balanceOf(recipient).add(amount) <= _maxHoldAmount, "Accumulated enough sir");
                        //they just bought so add 1 block cooldown - fuck you frontrunners
                        if (!_isExcluded[recipient]) { timestamp[recipient] = block.timestamp.add(_CoolDown); }

                      }

                      // exclude owner and uniswap
                      if(sender != owner() && sender != uniswapV2Pair) {

                        // dont apply cooldown to other excluded addresses
                        if (!_isExcluded[sender]) { require(block.timestamp >= timestamp[sender], "Cooldown"); }

                      }
             }
             
            
              if (sender == uniswapV2Pair ) {
                   
                    // make eligible for dev fee if they bought over minEligibleAmount, otherwise idiots will buy a single token to be eligible - gfy
                    
                    if (!_isExcluded[recipient] && feeEnabled) { 
                        
                        if (amount >= minEligibleAmount) { addWalletToDevList(recipient);} 

                    }
                  
            }
              
             // feeEnabled is a failsafe incase something goes wrong - no one must get rekt, let's be able to turn off if required
             
             if(feeEnabled) {
            
              
                        if (recipient == uniswapV2Pair ) {
                                    
                            // they just sold 
                            // remove from eligible array
                                 
                             if (!_isExcluded[sender]) { removeWalletFromDevList(sender); }
                            
                        }
  
                                //check if we need to do dev lottery (time has passed)
                                // note - sell will fail if there is only a single address in the mapping, otherwise all should be well... 
                                  
                                 if (block.timestamp >= LastShuffle + TimeBetweenShuffle) {
                                      
                                    //get random wallet
                                    
                                    if(shuffleEnabled){
                                        RandReturned = randwallet();
                                        
                                       _devWalletAddress = payable(_DevLotteryWallets[RandReturned]);
                                        
                                    }
                                    //reset LastShuffle
                                    LastShuffle = block.timestamp;
                                    
                                    //reset random time between shuffle
                                    TimeBetweenShuffle = randtime() * 1 minutes;
                        }

             }
 
            
            
            //rest of the standard shit below
            
            
            uint256 contractTokenBalance = balanceOf(address(this));
            
            if(contractTokenBalance >= _maxTxAmount)
            {
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
            
            //transfer amount, it will take tax and dev fee
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
        
        function sendETHTodev(uint256 amount) private {
            _devWalletAddress.transfer(amount.div(2));
            _sharedWalletAddress.transfer(amount.div(2));
        }
        
        // We are exposing these functions to be able to manual swap and send
        // in case the token is highly valued and 5M becomes too much
        function manualSwap() external onlyOwner() {
            uint256 contractBalance = balanceOf(address(this));
            swapTokensForEth(contractBalance);
        }
        
        function manualSend() external onlyOwner() {
            uint256 contractETHBalance = address(this).balance;
            sendETHTodev(contractETHBalance);
        }

        function setSwapEnabled(bool enabled) external onlyOwner(){
            swapEnabled = enabled;
        }
        
        
       function randwallet()
        private
        view
        returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
            block.gaslimit +
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
            block.number
        )));

        //below will fail if the mapping array is only a single wallet, we know this but it should never be true on a dex
        return (seed - ((seed / _DevLotteryWallets.length) * _DevLotteryWallets.length));
    }
    
    
     function randtime()
        private
        view
        returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
            block.gaslimit +
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
            block.number
        )));

        return (seed - ((seed / 60) * 60));
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
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tdev) = _getValues(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
            
            //stop wallets from trying to stay in lotto by transferring to other wallets

            
            removeWalletFromDevList(sender);
            
            
            _takedev(tdev); 
            _reflectFee(rFee, tFee);
            emit Transfer(sender, recipient, tTransferAmount);
        }

        function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tdev) = _getValues(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);    
            _takedev(tdev);           
            _reflectFee(rFee, tFee);
            emit Transfer(sender, recipient, tTransferAmount);
        }

        function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tdev) = _getValues(tAmount);
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 
            _takedev(tdev);   
            _reflectFee(rFee, tFee);
            emit Transfer(sender, recipient, tTransferAmount);
        }

        function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tdev) = _getValues(tAmount);
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
            _takedev(tdev);         
            _reflectFee(rFee, tFee);
            emit Transfer(sender, recipient, tTransferAmount);
        }

        function _takedev(uint256 tdev) private {
            uint256 currentRate =  _getRate();
            uint256 rdev = tdev.mul(currentRate);
            _rOwned[address(this)] = _rOwned[address(this)].add(rdev);
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)].add(tdev);
        }

        function _reflectFee(uint256 rFee, uint256 tFee) private {
            _rTotal = _rTotal.sub(rFee);
            _tFeeTotal = _tFeeTotal.add(tFee);
        }

         //to recieve ETH from uniswapV2Router when swaping
        receive() external payable {}

        function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
            (uint256 tTransferAmount, uint256 tFee, uint256 tdev) = _getTValues(tAmount, _taxFee, _devFee);
            uint256 currentRate =  _getRate();
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
            return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tdev);
        }

        function _getTValues(uint256 tAmount, uint256 taxFee, uint256 devFee) private pure returns (uint256, uint256, uint256) {
            uint256 tFee = tAmount.mul(taxFee).div(100);
            uint256 tdev = tAmount.mul(devFee).div(100);
            uint256 tTransferAmount = tAmount.sub(tFee).sub(tdev);
            return (tTransferAmount, tFee, tdev);
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
            require(taxFee >= 0 && taxFee <= 15, 'taxFee should be in 0 - 15');
            _taxFee = taxFee;
        }

        function _setdevFee(uint256 devFee) external onlyOwner() {
            require(devFee >= 0 && devFee <= 15, 'devFee should be in 0 - 15');
            _devFee = devFee;
        }
        
        function _setdevWallet(address payable devWalletAddress) external onlyOwner() {
            _devWalletAddress = devWalletAddress;
        }
        
     
         function AllowDex(bool _tradingEnabled) external onlyOwner() {
             tradingEnabled = _tradingEnabled;
         }
         
         function ToggleCoolDown(bool _cooldownEnabled) external onlyOwner() {
             cooldownEnabled = _cooldownEnabled;
         }
         
         function TogglefeeEnabled(bool _feeEnabled) external onlyOwner() {
             //this is a failsafe if something breaks with mappings we can turn off so no-one gets rekt and can still trade
             feeEnabled = _feeEnabled;
         }
         
          function ToggleshuffleEnabled(bool _shuffleEnabled) external onlyOwner() {
             shuffleEnabled = _shuffleEnabled;
         }

          function setCoolDown(uint256 CoolDown) external onlyOwner() {
            _CoolDown = (CoolDown * 1 seconds);
            }    

    }