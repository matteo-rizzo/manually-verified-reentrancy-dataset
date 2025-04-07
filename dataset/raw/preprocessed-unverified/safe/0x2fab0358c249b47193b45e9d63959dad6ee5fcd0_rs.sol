// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// 
/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


// 
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

// 
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

// 


// 
/**
Copyright 2020 PoolTogether Inc.
This file is part of PoolTogether.
PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.
PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/
/**
 * @author Brendan Asselstine
 * @notice A library that uses entropy to select a random number within a bound.  Compensates for modulo bias.
 * @dev Thanks to https://medium.com/hownetworks/dont-waste-cycles-with-modulo-bias-35b6fdafcf94
 */


contract Brewer is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Airdrop list
    address[] public airdropList;
    // Only deposit user can get airdrop.
    mapping(address => bool) addressAvailable;
    mapping(address => bool) addressAvailableHistory;

    // Claimable wine of user.
    struct UserWineInfo {
        uint256 amount;
    }
    // Info of each user that claimable wine.
    mapping (address => mapping (uint256 => UserWineInfo)) public userWineInfo;

    // Ticket of users
    mapping(address => uint256) ticketBalances;
    // Info of each wine.
    struct WineInfo {
        uint256 wineID;            // Wine's ID. 
        uint256 amount;            // Distribution amount.
        uint256 fixedPrice;        // Claim the wine need pay some wETH.
    }
    // Info of each wine.
    WineInfo[] public wineInfo;
    // Total wine amount.
    uint256 public totalWineAmount = 0;
    // Original total wine amount.
    uint256 public originalTotalWineAmount = 0;
    // Draw consumption
    uint256 public ticketsConsumed = 1000 * (10 ** 18);
    // Base number
    uint256 public base = 10 ** 6;
    // Claim fee is 3%.
    // Pool's fee 1%. Artist's fee 2%.
    uint256 public totalFee = 3 * (base) / 100;

    // Wine token.
    IGRAPWine GRAPWine;

    event Reward(address indexed user, uint256 indexed wineID);
    event AirDrop(address indexed user, uint256 indexed wineID);

    function wineLength() public view returns (uint256) {
        return wineInfo.length;
    }

    function ticketBalanceOf(address tokenOwner) public view returns (uint256) {
        return ticketBalances[tokenOwner];
    }

    function userWineBalanceOf(address tokenOwner, uint256 _wineID) public view returns (uint256) {
        return userWineInfo[tokenOwner][_wineID].amount;
    }

    function userUnclaimWine(address tokenOwner) public view returns (uint256[] memory) {
        uint256[] memory userWine = new uint256[](wineInfo.length);
        for(uint i = 0; i < wineInfo.length; i++) {
            userWine[i] = userWineInfo[tokenOwner][i].amount;
        }
        return userWine;
    }

    function wineBalanceOf(uint256 _wineID) public view returns (uint256) {
        return wineInfo[_wineID].amount;
    }

    // Add a new wine. Can only be called by the owner.
    function addWine(uint256 _wineID, uint256 _amount, uint256 _fixedPrice) external onlyOwner {
        require(_amount.add(GRAPWine.totalSupply(_wineID)) <= GRAPWine.maxSupply(_wineID), "Max supply reached");
        totalWineAmount = totalWineAmount.add(_amount);
        originalTotalWineAmount = originalTotalWineAmount.add(_amount);
        wineInfo.push(WineInfo({
            wineID: _wineID,
            amount: _amount,
            fixedPrice: _fixedPrice
        }));
    }

    // Update wine.
    // It's always decrease.
    function _updateWine(uint256 _wid, uint256 amount) internal {
        WineInfo storage wine = wineInfo[_wid];
        wine.amount = wine.amount.sub(amount);
        totalWineAmount = totalWineAmount.sub(amount);
    }

    // Update user wine
    function _addUserWine(address user, uint256 _wid, uint256 amount) internal {
        UserWineInfo storage userWine = userWineInfo[user][_wid];
        userWine.amount = userWine.amount.add(amount);
    }
    function _removeUserWine(address user, uint256 _wid, uint256 amount) internal {
        UserWineInfo storage userWine = userWineInfo[user][_wid];
        userWine.amount = userWine.amount.sub(amount);
    }

    // Draw main function
    function _draw() internal view returns (uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(now, block.difficulty, msg.sender)));
        uint256 rnd = UniformRandomNumber.uniform(seed, totalWineAmount);
        // Sort by rarity. Avoid gas attacks, start from the tail.
        for(uint i = wineInfo.length - 1; i > 0; --i){
            if(rnd < wineInfo[i].amount){
                return i;
            }
            rnd = rnd - wineInfo[i].amount;
        }
        // should not happen.
        return uint256(-1);
    }

    // Draw a wine
    function draw() external {
        // EOA only
        require(msg.sender == tx.origin);

        require(ticketBalances[msg.sender] >= ticketsConsumed, "Tickets are not enough.");
        ticketBalances[msg.sender] = ticketBalances[msg.sender].sub(ticketsConsumed);

        uint256 _rwid = _draw();
        // Reward reduced
        _updateWine(_rwid, 1);
        _addUserWine(msg.sender, _rwid, 1);

        emit Reward(msg.sender, _rwid);
    }

    // Airdrop by owner
    function airDrop() external onlyOwner {

        uint256 _rwid = _draw();
        // Reward reduced
        _updateWine(_rwid, 1);

        uint256 seed = uint256(keccak256(abi.encodePacked(now, _rwid)));
        bool status = false;
        uint256 rnd = 0;

        while (!status) {
            rnd = UniformRandomNumber.uniform(seed, airdropList.length);
            status = addressAvailable[airdropList[rnd]];
            seed = uint256(keccak256(abi.encodePacked(seed, rnd)));
        }

        _addUserWine(airdropList[rnd], _rwid, 1);
        emit AirDrop(airdropList[rnd], _rwid);
    }

    // Airdrop by user
    function airDropByUser() external {

        // EOA only
        require(msg.sender == tx.origin);

        require(ticketBalances[msg.sender] >= ticketsConsumed, "Tickets are not enough.");
        ticketBalances[msg.sender] = ticketBalances[msg.sender].sub(ticketsConsumed);
        
        uint256 _rwid = _draw();
        // Reward reduced
        _updateWine(_rwid, 1);

        uint256 seed = uint256(keccak256(abi.encodePacked(now, _rwid)));
        bool status = false;
        uint256 rnd = 0;

        while (!status) {
            rnd = UniformRandomNumber.uniform(seed, airdropList.length);
            status = addressAvailable[airdropList[rnd]];
            seed = uint256(keccak256(abi.encodePacked(seed, rnd)));
        }

        _addUserWine(airdropList[rnd], _rwid, 1);
        emit AirDrop(airdropList[rnd], _rwid);
    }

    // pool's fee & artist's fee
    function withdrawFee() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    // Compute claim fee.
    function claimFee(uint256 _wid, uint256 amount) public view returns (uint256){
        WineInfo storage wine = wineInfo[_wid];
        return amount * wine.fixedPrice * (totalFee) / (base);
    }

    // User claim wine.
    function claim(uint256 _wid, uint256 amount) external payable {
        UserWineInfo storage userWine = userWineInfo[msg.sender][_wid];
        require(amount > 0, "amount must not zero");
        require(userWine.amount >= amount, "amount is bad");
        require(msg.value == claimFee(_wid, amount), "need payout claim fee");

        _removeUserWine(msg.sender, _wid, amount);
        GRAPWine.mint(msg.sender, _wid, amount, "");
    }
}

contract BrewMaster is Brewer {
    // Info of each user.
    struct UserLPInfo {
        uint256 amount;       // How many LP tokens the user has provided.
        uint256 rewardTicket; // Reward ticket. 
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;            // Address of LP token contract.
        uint256 allocPoint;        // How many allocation points assigned to this pool. TICKETs to distribute per block.
        uint256 lastRewardBlock;   // Last block number that TICKETs distribution occurs.
        uint256 accTicketPerShare; // Accumulated TICKETs per share, times 1e12. See below.
    }
    // TICKET tokens created per block.
    uint256 public ticketPerBlock;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserLPInfo)) public userLPInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when TICKET mining starts.
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IGRAPWine _GRAPWine,
        uint256 _ticketPerBlock,
        uint256 _startBlock
    ) public {
        GRAPWine = _GRAPWine;
        ticketPerBlock = _ticketPerBlock;
        startBlock = _startBlock;
        wineInfo.push(WineInfo({
            wineID: 0,
            amount: 0,
            fixedPrice: 0
        }));
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accTicketPerShare: 0
        }));
    }

    // Update the given pool's Tickets allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }

    // View function to see pending Tickets on frontend.
    function pendingTicket(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserLPInfo storage user = userLPInfo[_pid][_user];
        uint256 accTicketPerShare = pool.accTicketPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 ticketReward = multiplier.mul(ticketPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accTicketPerShare = accTicketPerShare.add(ticketReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accTicketPerShare).div(1e12).sub(user.rewardTicket);
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
        uint256 ticketReward = multiplier.mul(ticketPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accTicketPerShare = pool.accTicketPerShare.add(ticketReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to Brewer for TICKET allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        // EOA only
        require(msg.sender == tx.origin);

        PoolInfo storage pool = poolInfo[_pid];
        UserLPInfo storage user = userLPInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTicketPerShare).div(1e12).sub(user.rewardTicket);
            ticketBalances[msg.sender] = ticketBalances[msg.sender].add(pending);
        }
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        user.amount = user.amount.add(_amount);
        user.rewardTicket = user.amount.mul(pool.accTicketPerShare).div(1e12);
        if (user.amount > 0){
            addressAvailable[msg.sender] = true;
            if(!addressAvailableHistory[msg.sender]){
                addressAvailableHistory[msg.sender] = true;
                airdropList.push(msg.sender);
            }
        }
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from Brewer.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserLPInfo storage user = userLPInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accTicketPerShare).div(1e12).sub(user.rewardTicket);
        ticketBalances[msg.sender] = ticketBalances[msg.sender].add(pending);
        user.amount = user.amount.sub(_amount);
        user.rewardTicket = user.amount.mul(pool.accTicketPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        if (user.amount == 0){
            addressAvailable[msg.sender] = false;
        }
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserLPInfo storage user = userLPInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardTicket = 0;
        addressAvailable[msg.sender] = false;
    }
}