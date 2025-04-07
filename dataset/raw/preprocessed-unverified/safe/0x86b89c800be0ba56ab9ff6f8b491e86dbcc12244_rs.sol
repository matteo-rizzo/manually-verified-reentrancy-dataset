/**
 *Submitted for verification at Etherscan.io on 2020-08-03
*/

pragma solidity ^0.6.0;

/*  
    Ethverse : https://ethverse.com
    Symbol: ETHV
    Decimals: 18
    
    
                       ``````````````                       
                  `````              `````                  
                ..`                       ```               
             `.`                            `.`             
            .`                                `.`           
          `.            :oydmmmmdyo/`           ``          
         ::          :yNMMMMMMMMMMMMMd+`         `:         
       -d+         -dMMMMMMMMMMMMMMMMMMN+         .h:       
     .hMy         +MMMMMMMMMMMMMMMMMMMMMMh         /Mh.     
   `sMMN-        /MMMMMMMMMMMMMMMMMMMMMMMMy         mMMs`   
 `oNMMMm         mMMMMMMMMMMMMMMMMMMMMMMMMM-        oMMMNo` 
:mNNNNNh        .MMMMMMMMMMMMMMMMMMMMMMMMMM+        +NNNNNm/
 +hddddy        `NMMMMMMMMMMMMMMMMMMMMMMMMM/        /dddddo`
  `odddd`        yMMMMMMMMMMMMMMMMMMMMMMMMN`        sddds.  
    .sdd/        `mMMMMMMMMMMMMMMMMMMMMMMM:        .ddy-    
      -yh.        `hMMMMMMMMMMMMMMMMMMMMm-         sh:      
        :s`         :dMMMMMMMMMMMMMMMMmo`         //        
          :`          .ohNMMMMMMMMMms:           -`         
           ..             .:////:.             `.           
            `.`                              `.`            
              `..                          `.`              
                 ````                   ```                 
                    ````````    ````````                    
                            `````                       
*/







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


contract ETHVerseLockup is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    uint256 public unlockTime = 1596808800;  // Fri, 07 Aug 2020 14:00:00 +0000
    address public ethvToken = 0xEeEeeeeEe2aF8D0e1940679860398308e0eF24d6;  // ETHV Token smart contract


    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    
    constructor () public {
        _name = "Ethverse Lockups";
        _symbol = "ETHVL";
        _decimals = 18;
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
    
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        require(now > unlockTime, "tokens locked !");
        
        _burn(sender, amount);
        IERC20(ethvToken).transfer(recipient, amount);
    }
    
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    
    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

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
    
    
    function mintTokens(address _to, uint256 amount) external onlyOwner {
        amount = amount * 10**uint256(_decimals);
        IERC20(ethvToken).transferFrom(msg.sender, address(this), amount);
        _mint(_to, amount);
    }
    
    
    // in case uniswap listing extends
    function extendLockTime(uint256 _time) external onlyOwner {
        unlockTime = unlockTime.add(_time);
    }
    
}