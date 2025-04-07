/**
 *Submitted for verification at Etherscan.io on 2021-04-08
*/

//SPDX-License-Identifier: MIT 
pragma solidity 0.6.11; 
pragma experimental ABIEncoderV2;


// File: contracts\@openzeppelin\contracts\GSN\Context.sol
// License: MIT

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

// File: contracts\@openzeppelin\contracts\access\Ownable.sol
// License: MIT


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

// File: contracts\@openzeppelin\contracts\token\ERC20\IERC20.sol
// License: MIT

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts\@openzeppelin\contracts\math\SafeMath.sol
// License: MIT

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


// File: contracts\@openzeppelin\contracts\utils\Address.sol
// License: MIT

/**
 * @dev Collection of functions related to the address type
 */


// File: contracts\@openzeppelin\contracts\token\ERC20\SafeERC20.sol
// License: MIT




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts\@uniswap\IUniswapV2Pair.sol
// License: MIT

// https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol


// File: contracts\@uniswap\IUniswapV2Factory.sol
// License: MIT

// https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol


// File: contracts\@uniswap\IUniswapV2Router01.sol
// License: MIT

// https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router01.sol


// File: contracts\@libs\UniswapUtils.sol
//License: MIT








contract UniswapUtils  { 
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 public constant PERCENT = 10000;  
    struct LiquidityItem{
        //remove 
        uint256 tokenRemoved;
        uint256 currencyRemoved;
        uint256 liquidityRemoved;
        //swap
        uint256 currencyIn;
        uint256 tokenOut;
        //add
        uint256 tokenAdded;
        uint256 currencyAdded;
        uint256 liquidityAdded;       
    }
    event LiquidityInfo(address token,address currency,uint256 lpp,uint256 cp,LiquidityItem q,uint256 burnAmount);
    function _getPair(address router,address token0,address token1) internal view returns(address){
        address _factory =  IUniswapV2Router01(router).factory();
        return IUniswapV2Factory(_factory).getPair(token0,token1);
    }
    function _checkOrApproveRouter(address _router,address _token,uint256 _amount) internal{
        if(IERC20(_token).allowance(address(this),_router) < _amount){
            IERC20(_token).safeApprove(_router,0);
            IERC20(_token).safeApprove(_router,uint256(-1));
        }        
    }
    function _swapToken(address router,address tokenIn,address tokenOut,uint256 amountIn) internal returns (uint256){
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut; 
        uint256 exptime = block.timestamp+60;
        _checkOrApproveRouter(router,tokenIn,amountIn); 
        return IUniswapV2Router01(router).swapExactTokensForTokens(amountIn,0,path,address(this),exptime)[1];
    }
    function _addLiquidity(
        address router,
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal returns (uint amountA, uint amountB, uint liquidity){
         uint256 exptime = block.timestamp+60;
        _checkOrApproveRouter(router,tokenA,amountADesired);
        _checkOrApproveRouter(router,tokenB,amountBDesired);
        return IUniswapV2Router01(router).addLiquidity(tokenA,tokenB,amountADesired,amountBDesired,amountAMin,amountBMin,address(this), exptime);
    }
    function _removeLiquidity(
        address router,
        address pair,
        address tokenA,
        address tokenB,
        uint256 lpp 
    ) internal returns (uint amountA, uint amountB,uint256 liquidity){
        uint256 exptime = block.timestamp+60;
        liquidity = IERC20(pair).balanceOf(address(this)).mul(lpp).div(PERCENT);
        _checkOrApproveRouter(router,pair,liquidity);
        (amountA, amountB) = IUniswapV2Router01(router).removeLiquidity(tokenA,tokenB,liquidity,0,0,address(this),exptime);
    }
    function getPairToken(address _pair,address _rewardToken) public view returns(address){
        address token0 = IUniswapV2Pair(_pair).token0();
        address token1 = IUniswapV2Pair(_pair).token1(); 
        require(token0 == _rewardToken || token1 == _rewardToken,"!_rewardToken");
        return _rewardToken == token0 ? token1 : token0;
    } 
}

// File: contracts\@libs\IRewardToken.sol
// License: MIT


interface IRewardToken is IERC20 {
    function cap() external view returns (uint256);
    function mint(address _to, uint256 _amount) external; 
    function burn(uint256 amount) external;
}

// File: contracts\@libs\Authorizable.sol
// License: MIT


contract Authorizable is Ownable {
    mapping(address => bool) public authorized;
    modifier onlyAuthorized() {
        require(authorized[msg.sender] || owner() == msg.sender,"!auth");
        _;
    }
    function addAuthorized(address _toAdd) onlyOwner public {
        authorized[_toAdd] = true;
    }
    function removeAuthorized(address _toRemove) onlyOwner public {
        require(_toRemove != msg.sender);
        authorized[_toRemove] = false;
    }
}

// File: contracts\FEIIMasterChef.sol
// License: MIT








// MasterChef is the master of rewardToken. He can make rewardToken and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once rewardToken is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract FEIIMasterChef is Authorizable,UniswapUtils {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of rewardTokens
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accrewardTokenPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accrewardTokenPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }
    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. rewardTokens to distribute per block.
        uint256 lastRewardBlock; // Last block number that rewardTokens distribution occurs.
        uint256 accrewardTokenPerShare; // Accumulated rewardTokens per share, times 1e12. See below.
    } 
    // The rewardToken TOKEN!
    IRewardToken public rewardToken;
    address public uniswapRouter;
    // Dev address.
    address public devAddr;
    uint256 public protocolFee = 1000; //1%
    uint256 public devRewardAmount; 
    // rewardToken tokens created per block.
    uint256 public rewardTokenPerBlock; 
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when rewardToken mining starts.
    uint256 public startBlock;
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount,uint256 rewardToken);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount,uint256 rewardToken);
    constructor(
        address _uniswapRouter,
        address _rewardToken,     
        uint256 _rewardTokenPerBlock,
        uint256 _startBlock 
    ) public {
        rewardToken = IRewardToken(_rewardToken);
        devAddr = msg.sender;
        uniswapRouter = _uniswapRouter;
        rewardTokenPerBlock = _rewardTokenPerBlock; 
        startBlock = _startBlock;    
    }
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyAuthorized {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accrewardTokenPerShare: 0
            })
        );
    }
    // Update the given pool's rewardToken allocation point. Can only be called by the owner.
    function set(uint256 _pid,uint256 _allocPoint, bool _withUpdate) public onlyAuthorized {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }
    function updateDevAddr(address _dev,uint256 _fee) public onlyAuthorized{
        devAddr = _dev;
        protocolFee = _fee;
    }
    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256){
        return _to.sub(_from);
    }
    // View function to see pending rewardTokens on frontend.
    function pendingrewardToken(uint256 _pid, address _user)external view returns (uint256){
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accrewardTokenPerShare = pool.accrewardTokenPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 rewardTokenReward =
                multiplier.mul(rewardTokenPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accrewardTokenPerShare = accrewardTokenPerShare.add(
                rewardTokenReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accrewardTokenPerShare).div(1e12).sub(user.rewardDebt);
    }
    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }
    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 rewardTokenReward = multiplier.mul(rewardTokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        devRewardAmount = devRewardAmount.add(rewardTokenReward.div(10));
        rewardToken.mint(address(this), rewardTokenReward);
        pool.accrewardTokenPerShare = pool.accrewardTokenPerShare.add(
            rewardTokenReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }
    // Deposit LP tokens to MasterChef for rewardToken allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        require(block.number >= startBlock,"!start");
        uint256 pending = 0;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender]; 
        updatePool(_pid);
        if (user.amount > 0) {
            pending = user.amount.mul(pool.accrewardTokenPerShare).div(1e12).sub(user.rewardDebt);
            safeRewardTokenTransfer(msg.sender, pending);
        }
        //save gas for claimReward
        if(_amount > 0){
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount); 
            user.amount = user.amount.add(_amount); 
        }
        user.rewardDebt = user.amount.mul(pool.accrewardTokenPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount,pending);
    }
    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        UserInfo storage dever = userInfo[_pid][devAddr];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accrewardTokenPerShare).div(1e12).sub(user.rewardDebt);
        safeRewardTokenTransfer(msg.sender, pending); 
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accrewardTokenPerShare).div(1e12);
        uint256 _fee = _amount.mul(protocolFee).div(PERCENT);
        dever.amount = dever.amount.add(_fee); 
        pool.lpToken.safeTransfer(address(msg.sender), _amount.sub(_fee));
        emit Withdraw(msg.sender, _pid, _amount,pending);
    }
    function claimReward(uint256 _pid) public {
        deposit(_pid,0);
    } 
    function rewardTokenLiquidity(address _pair,uint256 _lpp,uint256 _cp) public onlyAuthorized{ 
        address _token = address(rewardToken);
        //only guard rewardToken 
        address _currency = getPairToken(_pair,_token); 
        LiquidityItem memory q =  LiquidityItem(0,0,0,0,0,0,0,0);
        //removeLiquidity  
        (q.tokenRemoved,q.currencyRemoved,q.liquidityRemoved) = _removeLiquidity(uniswapRouter, _pair, _token, _currency,_lpp);
        //swap rewardToken
        q.currencyIn = q.currencyRemoved.mul(_cp).div(PERCENT);
        q.tokenOut = _swapToken(uniswapRouter,_currency,_token,q.currencyIn);
        //addLiquidity
        uint256 tokenRemain  = q.tokenRemoved.add(q.tokenOut);  
        uint256 currencyRemain =  q.currencyRemoved.sub(q.currencyIn);       
        (q.tokenAdded, q.currencyAdded, q.liquidityAdded) = _addLiquidity(uniswapRouter, _token,_currency,
                                                                         tokenRemain,currencyRemain,
                                                                         0,currencyRemain);
        tokenRemain = tokenRemain.sub(q.tokenAdded);
        //burn rewardToken
        rewardToken.burn(tokenRemain);
        emit LiquidityInfo(_token,_currency,_lpp,_cp,q,tokenRemain); 
    }
    // Safe rewardToken transfer function, just in case if rounding error causes pool to not have enough rewardTokens.
    function safeRewardTokenTransfer(address _to, uint256 _amount) internal {
        uint256 rewardTokenBal = rewardToken.balanceOf(address(this));
        if (_amount > rewardTokenBal) {
            rewardToken.transfer(_to, rewardTokenBal);
        } else {
            rewardToken.transfer(_to, _amount);
        }
    }
    function claimDevReward(uint256 _p) public onlyAuthorized{
        require(devRewardAmount > 0,"No community rate"); 
        uint256 _community_amount = devRewardAmount.mul(_p).div(PERCENT);
        devRewardAmount = devRewardAmount.sub(_community_amount);
        rewardToken.mint(msg.sender,_community_amount);   
    } 
    function updateRewardRate(uint256 _rewardTokenPerBlock,uint256 _startBlock) public onlyAuthorized{ 
        rewardTokenPerBlock = _rewardTokenPerBlock;
        startBlock = _startBlock;
    }
}