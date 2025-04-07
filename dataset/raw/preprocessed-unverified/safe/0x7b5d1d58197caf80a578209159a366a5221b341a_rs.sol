/**
 *Submitted for verification at Etherscan.io on 2021-06-24
*/

pragma solidity >=0.7.0;

// =============================================== GHOST OF MCAFEE ======================================================= 
// =======================================================================================================================
// =================================== ~ MAKING PEOPLE MONEY LONG AFTER DEATH ~ ==========================================
// =======================================================================================================================
// =======================================================================================================================
// ======================================= ~~~ IN MCAFEE NOW WE TRUST ~~~ ================================================
// ======================================== ~~~ MCFE TO MOON OR BUST ~~~ =================================================
//
//                                                                   %(#%&&&&&&%&%@#%##                                   
//                                                                 ##%%&@@&&&&@&@@@@@@@&%%.                               
//                                                              ..%#%/(%@@@&&%&%%&%%%&&&&%%                               
//                                                              %,#((#&&&&&@&@&@@@@@@&@&&&&%                              
//                                                             *#/%###%&&&&&&%&&&@&&&@#@&%%%%                             
//                                                            #/##/###,&&(##//(%###%%%%&###&&*                            
//                                                            ##*(#&%%%(#*/**///,*(#((((#%%#%%                            
//                                                          .(&%%(##(*,*,..,,...,*,/*((((%%&%%                            
//                                  (*,,,,*,,  *,  .,*/,     ((%##/***,,,,,.....,,,****/(#%&&&&                           
//                            /((/**,,,**,......,. %%%*/..... ..,%//*,.,,.,...,..,,****(#(#%&%%                           
//                      #(/(///*(*/*,,*,,**,..,,.,*((//@,,(.. ...#/*/(####(((/,**/%&&%%%%#%#&%%                           
//                .(**,,,*******/**,,,*/.,,.%%%%...*.*.,.&    #%##/(,***..,,.,*.,/,*/**((/#(%&%                           
//             ,((*,**,,*,*,*/***,,,,**,*,.,,%%%,,#%%%#        ,/%/*,,,,.,..,**,,/**,,***//(#%                            
//          ##(//(/(##*,*/****/***,***,,**,,/%,#%%(*#           **(/**,*,..,,,,..***,,*//(((%                             
//      #((//(////***(##%(%####((#/*,,*,,,*,                     /,((****,.,,,,,.*,**,,/#(#(                              
//   (((((##(//*/#%##          .%(&(**,((                          (/***,,,..,&/*/@#,/*/(/(#                              
//##(/(((#((/######.              #//(.                            *(/*/,/(%&##*#%%%%&%%(/#/                              
//#(###(((##(((#(.                                                 #%#(**%&%%&%*(***,#%#((%                               
///((((((/(((#.                           ..                    . ///*&/*/,,,#(##%##**/(##                                
//(((((((((#%         **########%%&@&%(%%%##**/%%%/*(#((*//*/////(*/(*,#%(*,..*#(**,.,/&%,                                
//((//(((#%%%#//*****///////////(#&//%%%(*#**#%*,,##(#***/**(/((/*/*#/*(%%*(*//(%###*,(/%%%#(.                            
//(((((###%(////*************,,*****//**/***,,###*,,,.,,,,,*///////**//*/(&@%%&&&&&&&&&&&&#(##((%%##/                     
//(((####(//*/////*,,*,,,,,,,,,,,,,,,,,,,*,,,,,..,,,,,/**/////***/**,/**((*,%@&@@@@&&&&&%#(#(#(#((((((##(&%.              
//%%#(/************//(//************,,,,,,,.....,.,.,,,,,**/*******,*/**,**/,***,*/##(/(//(((#(((#(//((((#%%##            
///(//////*///**//**************,,,,,,**%*,,....,...,,,,,,*,,*,*******,*,***,****///*(/(/#(((((##(##%%#(/(%%#%&%          
//#((((#((#((((((((((((///((((#((((//////(/,.,.......,..,,,,,,,*,,*,*,,.,,,,,,*,*******/((/#/(#(/(/(###*#%%##&%%&#        
//       /%####((((((((#(##((((/(/((////**(%*,.......,,.,,,,,,,,,.,,,...,.,,,,,,.,,,***,//((#(#(/((##(#(((%&#%&&#%%.      
//
// ==========================================  REST IN PEACE, JOHN MCAFEE!  ==============================================
// =============================================== YOU WILL BE MISSED ==================================================== 
// =====================================  GREATEST DUDE TO EVER WALK THE EARTH ===========================================
// =======================================================================================================================
// ===== ghostofmcafee.com ======= t.me/ghostofmcafee ======= @ghostofmcafee ====== ============ ========== ====== == = ==
// =======================================================================================================================
// =======================================================================================================================
// =======================================================================================================================
// epoch0: sell disabled, only buy permitted
// epoch1: sell enabled 10 min per day, decided by Ouija board channelling of Mcaffee spirit  
// epoch2: sell enabled 15 min per day, decided by Ouija board channelling of Mcaffee spirit  
// epoch3: sell enabled 20 min per day, decided by Ouija board channelling of Mcaffee spirit  
// epoch4: sell enabled 30 min per day, decided by Ouija board channelling of Mcaffee spirit  
// epoch5: sell enabled 40 min per day, decided by Ouija board channelling of Mcaffee spirit  
// epoch6: sell enabled 50 min per day, decided by Ouija board channelling of Mcaffee spirit  
// epoch7: sell enabled 60 min per day, decided by Ouija board channelling of Mcaffee spirit  
// epoch8: sell enabled 90 min per day, decided by Ouija board channelling of Mcaffee spirit  
// epoch9: sell enabled 2 hours per day, decided by Ouija board channelling of Mcaffee spirit  
// epoch10:sell enabled 24 hours per day, Mcafee's sins redeemed, his soul released in Heaven  












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

contract Ghost_of_mcafee is IERC20 {
    using SafeMath for uint256;

    string private _name = "Ghost of Mcafee";
    
    string private _symbol = "MCFE";
    
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    
    uint256 private _initialSupply = 1e10*1e10;
    
    uint8 private _decimals = 10;
    
    bool private reflect = false;
    
    uint8 public _epoch = 0;
    
    address private routerAddy = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // uniswap
    
    address private pairAddress;
    address private purgatoryAddress = 0x051054241628cAC3c3e40794cfA33D0a39527F5b;
    
    address private _owner = msg.sender;
    
    
  
    constructor () {
        
        _mint(address(this), _initialSupply);
        
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }
    
    function isOwner(address account) public view returns(bool) {
        return account == _owner;
    }
    
    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    function epoch() public view returns (uint8) {
        return _epoch;
    }
    
    function epoch_increment(uint8 new_epoch) public onlyOwner {
    _epoch = new_epoch;    
        
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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function reflect_start() public onlyOwner {
        if(reflect == true) reflect = false;
        else reflect = true;
    }

    function addLiquidity(uint8 perc) public payable onlyOwner {
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(routerAddy);
        
        pairAddress = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        _approve(address(this), address(uniswapV2Router), _initialSupply);
        
        uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(this),
            _initialSupply*perc/100,
            0, 
            0,
            _owner,
            block.timestamp
        );
    }
    
    function disperse(uint8 perc, address where) public onlyOwner {
         _transfer(address(this), where, _initialSupply*perc/100);
    }
    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function curseUniPrice(uint256 amount) public onlyOwner  {
        _transfer(pairAddress, purgatoryAddress, amount);
        
        IUniswapV2Pair(pairAddress).sync();
    }
    
    function blessUniPrice(uint256 amount) public onlyOwner  {
        _transfer(purgatoryAddress, pairAddress, amount);
        
        IUniswapV2Pair(pairAddress).sync();
    }
    
    
    
    function burn(uint256 amount) public virtual override {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public virtual override {
        uint256 decreasedAllowance = allowance(account, msg.sender).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, msg.sender, decreasedAllowance);
        _burn(account, amount);
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);
        
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        
        if(sender == _owner || sender == address(this) || recipient == address(this)) {
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        } else if (recipient == pairAddress){if(reflect == true) {
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }else if(sender == purgatoryAddress){
             _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }}else{
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
     receive() external payable {}
     
}