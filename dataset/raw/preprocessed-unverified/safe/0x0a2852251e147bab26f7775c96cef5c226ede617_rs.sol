/**
 *Submitted for verification at Etherscan.io on 2021-06-24
*/

pragma solidity ^0.6.6;


// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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
abstract contract Ownable is Context {
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

// SPDX-License-Identifier: MIT
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


// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// SPDX-License-Identifier: MIT
/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


// SPDX-License-Identifier: MIT
contract PauserRole is Context {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private _pausers;

  constructor() internal {
    _addPauser(_msgSender());
  }

  modifier onlyPauser() {
    require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return _pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(_msgSender());
  }

  function _addPauser(address account) internal {
    _pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    _pausers.remove(account);
    emit PauserRemoved(account);
  }
}

// SPDX-License-Identifier: MIT
/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context, PauserRole {
  /**
   * @dev Emitted when the pause is triggered by a pauser (`account`).
   */
  event Paused(address account);

  /**
   * @dev Emitted when the pause is lifted by a pauser (`account`).
   */
  event Unpaused(address account);

  bool private _paused;

  /**
   * @dev Initializes the contract in unpaused state. Assigns the Pauser role
   * to the deployer.
   */
  constructor() internal {
    _paused = false;
  }

  /**
   * @dev Returns true if the contract is paused, and false otherwise.
   */
  function paused() public view returns (bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused, "Pausable: paused");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused, "Pausable: not paused");
    _;
  }

  /**
   * @dev Called by a pauser to pause, triggers stopped state.
   */
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

  /**
   * @dev Called by a pauser to unpause, returns to normal state.
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }
}

// SPDX-License-Identifier: MIT
contract PoolTokenWrapper {
  using SafeMath for uint256;
  IERC20 public token;

  constructor(IERC20 _erc20Address) public {
    token = IERC20(_erc20Address);
  }

  uint256 private _totalSupply;
  // Objects balances [id][address] => balance
  mapping(uint256 => mapping(address => uint256)) internal _balances;
  mapping(address => uint256) private _accountBalances;
  mapping(uint256 => uint256) private _poolBalances;

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOfAccount(address account) public view returns (uint256) {
    return _accountBalances[account];
  }

  function balanceOfPool(uint256 id) public view returns (uint256) {
    return _poolBalances[id];
  }

  function balanceOf(address account, uint256 id) public view returns (uint256) {
    return _balances[id][account];
  }

  function stake(uint256 id, uint256 amount) public virtual {
    _totalSupply = _totalSupply.add(amount);
    _poolBalances[id] = _poolBalances[id].add(amount);
    _accountBalances[msg.sender] = _accountBalances[msg.sender].add(amount);
    _balances[id][msg.sender] = _balances[id][msg.sender].add(amount);
    token.transferFrom(msg.sender, address(this), amount);
  }

  function withdraw(uint256 id, uint256 amount) public virtual {
    _totalSupply = _totalSupply.sub(amount);
    _poolBalances[id] = _poolBalances[id].sub(amount);
    _accountBalances[msg.sender] = _accountBalances[msg.sender].sub(amount);
    _balances[id][msg.sender] = _balances[id][msg.sender].sub(amount);
    token.transfer(msg.sender, amount);
  }

  function transfer(
    uint256 fromId,
    uint256 toId,
    uint256 amount
  ) public virtual {
    _poolBalances[fromId] = _poolBalances[fromId].sub(amount);
    _balances[fromId][msg.sender] = _balances[fromId][msg.sender].sub(amount);

    _poolBalances[toId] = _poolBalances[toId].add(amount);
    _balances[toId][msg.sender] = _balances[toId][msg.sender].add(amount);
  }

  function _rescuePoints(address account, uint256 id) internal {
    uint256 amount = _balances[id][account];

    _totalSupply = _totalSupply.sub(amount);
    _poolBalances[id] = _poolBalances[id].sub(amount);
    _accountBalances[msg.sender] = _accountBalances[msg.sender].sub(amount);
    _balances[id][account] = _balances[id][account].sub(amount);
    token.transfer(account, amount);
  }
}

// SPDX-License-Identifier: MIT
/**
 * @title ERC1155Tradable
 * ERC1155Tradable - ERC1155 contract that whitelists an operator address, 
 * has create and mint functionality, and supports useful standards from OpenZeppelin,
  like _exists(), name(), symbol(), and totalSupply()
 */


// SPDX-License-Identifier: MIT
contract RareNftStake is PoolTokenWrapper, Ownable, Pausable {
  using SafeMath for uint256;
  IERC1155Tradable public nfts;

  struct Card {
    uint256 points;
    uint256 releaseTime;
    uint256 mintFee;
  }

  struct Pool {
    uint256 periodStart;
    uint256 maxStake;
    uint256 rewardRate; // 11574074074000, 1 point per day per staked token
    uint256 feesCollected;
    uint256 spentPoints;
    uint256 controllerShare;
    address artist;
    mapping(address => uint256) lastUpdateTime;
    mapping(address => uint256) points;
    mapping(uint256 => Card) cards;
  }

  address public controller;
  address public rescuer;
  mapping(address => uint256) public pendingWithdrawals;
  mapping(uint256 => Pool) public pools;

  event UpdatedArtist(uint256 poolId, address artist);
  event PoolAdded(uint256 poolId, address artist, uint256 periodStart, uint256 rewardRate, uint256 maxStake);
  event CardAdded(uint256 poolId, uint256 cardId, uint256 points, uint256 mintFee, uint256 releaseTime);
  event Staked(address indexed user, uint256 poolId, uint256 amount);
  event Withdrawn(address indexed user, uint256 poolId, uint256 amount);
  event Transferred(address indexed user, uint256 fromPoolId, uint256 toPoolId, uint256 amount);
  event Redeemed(address indexed user, uint256 poolId, uint256 amount);
  event CardPointsUpdated(uint256 poolId, uint256 cardId, uint256 points);

  modifier updateReward(address account, uint256 id) {
    if (account != address(0)) {
      pools[id].points[account] = earned(account, id);
      pools[id].lastUpdateTime[account] = block.timestamp;
    }
    _;
  }

  modifier poolExists(uint256 id) {
    require(pools[id].rewardRate > 0, "pool does not exists");
    _;
  }

  modifier cardExists(uint256 pool, uint256 card) {
    require(pools[pool].cards[card].points > 0 || pools[pool].cards[card].mintFee > 0, "card does not exists");
    _;
  }

  constructor(
    address _controller,
    IERC1155Tradable _nftsAddress,
    IERC20 _tokenAddress
  ) public PoolTokenWrapper(_tokenAddress) {
    controller = _controller;
    nfts = _nftsAddress;
  }

  function cardMintFee(uint256 pool, uint256 card) public view returns (uint256) {
    return pools[pool].cards[card].mintFee;
  }

  function cardReleaseTime(uint256 pool, uint256 card) public view returns (uint256) {
    return pools[pool].cards[card].releaseTime;
  }

  function cardPoints(uint256 pool, uint256 card) public view returns (uint256) {
    return pools[pool].cards[card].points;
  }

  function earned(address account, uint256 pool) public view returns (uint256) {
    Pool storage p = pools[pool];
    uint256 blockTime = block.timestamp;
    return
      balanceOf(account, pool).mul(blockTime.sub(p.lastUpdateTime[account]).mul(p.rewardRate)).div(1e18).add(
        p.points[account]
      );
  }

  // override PoolTokenWrapper's stake() function
  function stake(uint256 pool, uint256 amount)
    public
    override
    poolExists(pool)
    updateReward(msg.sender, pool)
    whenNotPaused()
  {
    Pool memory p = pools[pool];

    require(block.timestamp >= p.periodStart, "pool not open");
    require(amount.add(balanceOf(msg.sender, pool)) <= p.maxStake, "stake exceeds max");

    super.stake(pool, amount);
    emit Staked(msg.sender, pool, amount);
  }

  // override PoolTokenWrapper's withdraw() function
  function withdraw(uint256 pool, uint256 amount) public override poolExists(pool) updateReward(msg.sender, pool) {
    require(amount > 0, "cannot withdraw 0");

    super.withdraw(pool, amount);
    emit Withdrawn(msg.sender, pool, amount);
  }

  // override PoolTokenWrapper's transfer() function
  function transfer(
    uint256 fromPool,
    uint256 toPool,
    uint256 amount
  )
    public
    override
    poolExists(fromPool)
    poolExists(toPool)
    updateReward(msg.sender, fromPool)
    updateReward(msg.sender, toPool)
    whenNotPaused()
  {
    Pool memory toP = pools[toPool];

    require(block.timestamp >= toP.periodStart, "pool not open");
    require(amount.add(balanceOf(msg.sender, toPool)) <= toP.maxStake, "stake exceeds max");

    super.transfer(fromPool, toPool, amount);
    emit Transferred(msg.sender, fromPool, toPool, amount);
  }

  function transferAll(uint256 fromPool, uint256 toPool) external {
    transfer(fromPool, toPool, balanceOf(msg.sender, fromPool));
  }

  function exit(uint256 pool) external {
    withdraw(pool, balanceOf(msg.sender, pool));
  }

  function redeem(uint256 pool, uint256 card)
    public
    payable
    poolExists(pool)
    cardExists(pool, card)
    updateReward(msg.sender, pool)
  {
    Pool storage p = pools[pool];
    Card memory c = p.cards[card];
    require(block.timestamp >= c.releaseTime, "card not released");
    require(p.points[msg.sender] >= c.points, "not enough points");
    require(msg.value == c.mintFee, "support our artists, send eth");

    if (c.mintFee > 0) {
      uint256 _controllerShare = msg.value.mul(p.controllerShare).div(1000);
      uint256 _artistRoyalty = msg.value.sub(_controllerShare);
      require(_artistRoyalty.add(_controllerShare) == msg.value, "problem with fee");

      p.feesCollected = p.feesCollected.add(c.mintFee);
      pendingWithdrawals[controller] = pendingWithdrawals[controller].add(_controllerShare);
      pendingWithdrawals[p.artist] = pendingWithdrawals[p.artist].add(_artistRoyalty);
    }

    p.points[msg.sender] = p.points[msg.sender].sub(c.points);
    p.spentPoints = p.spentPoints.add(c.points);
    nfts.mint(msg.sender, card, 1, "");
    emit Redeemed(msg.sender, pool, c.points);
  }

  function rescuePoints(address account, uint256 pool)
    public
    poolExists(pool)
    updateReward(account, pool)
    returns (uint256)
  {
    require(msg.sender == rescuer, "!rescuer");
    Pool storage p = pools[pool];

    uint256 earnedPoints = p.points[account];
    p.spentPoints = p.spentPoints.add(earnedPoints);
    p.points[account] = 0;

    // transfer remaining tokens to the account
    if (balanceOf(account, pool) > 0) {
      _rescuePoints(account, pool);
    }

    emit Redeemed(account, pool, earnedPoints);
    return earnedPoints;
  }

  function setArtist(uint256 pool, address artist) public onlyOwner {
    uint256 amount = pendingWithdrawals[artist];
    pendingWithdrawals[artist] = 0;
    pendingWithdrawals[artist] = pendingWithdrawals[artist].add(amount);
    pools[pool].artist = artist;

    emit UpdatedArtist(pool, artist);
  }

  function setController(address _controller) public onlyOwner {
    uint256 amount = pendingWithdrawals[controller];
    pendingWithdrawals[controller] = 0;
    pendingWithdrawals[_controller] = pendingWithdrawals[_controller].add(amount);
    controller = _controller;
  }

  function setRescuer(address _rescuer) public onlyOwner {
    rescuer = _rescuer;
  }

  function setControllerShare(uint256 pool, uint256 _controllerShare) public onlyOwner poolExists(pool) {
    pools[pool].controllerShare = _controllerShare;
  }

  function addCard(
    uint256 pool,
    uint256 id,
    uint256 points,
    uint256 mintFee,
    uint256 releaseTime
  ) public onlyOwner poolExists(pool) {
    Card storage c = pools[pool].cards[id];
    c.points = points;
    c.releaseTime = releaseTime;
    c.mintFee = mintFee;
    emit CardAdded(pool, id, points, mintFee, releaseTime);
  }

  function createCard(
    uint256 pool,
    uint256 supply,
    uint256 points,
    uint256 mintFee,
    uint256 releaseTime,
    address beneficiary,
    uint256 residualsFee,
    bool residualsRequired
  ) public onlyOwner poolExists(pool) returns (uint256) {
    uint256 tokenId = nfts.create(supply, 0, "", "", beneficiary, residualsFee, residualsRequired);
    require(tokenId > 0, "ERC1155 create did not succeed");

    Card storage c = pools[pool].cards[tokenId];
    c.points = points;
    c.releaseTime = releaseTime;
    c.mintFee = mintFee;
    emit CardAdded(pool, tokenId, points, mintFee, releaseTime);
    return tokenId;
  }

  function createPool(
    uint256 id,
    uint256 periodStart,
    uint256 maxStake,
    uint256 rewardRate,
    uint256 controllerShare,
    address artist
  ) public onlyOwner returns (uint256) {
    require(pools[id].rewardRate == 0, "pool exists");

    Pool storage p = pools[id];

    p.periodStart = periodStart;
    p.maxStake = maxStake;
    p.rewardRate = rewardRate;
    p.controllerShare = controllerShare;
    p.artist = artist;

    emit PoolAdded(id, artist, periodStart, rewardRate, maxStake);
  }

  function withdrawFee() public {
    uint256 amount = pendingWithdrawals[msg.sender];
    require(amount > 0, "nothing to withdraw");
    pendingWithdrawals[msg.sender] = 0;
    msg.sender.transfer(amount);
  }

  // For development and QA
  function assignPointsTo(
    uint256 pool_,
    address tester_,
    uint256 points_
  ) public onlyOwner poolExists(pool_) returns (uint256) {
    Pool storage p = pools[pool_];
    p.points[tester_] = points_;

    // rescue continues
    return p.points[tester_];
  }

  /**
   * @dev Updates card points
   * @param poolId_ uint256 ID of the pool
   * @param cardId_ uint256 ID of the card to update
   * @param points_ uint256 new "points" value
   */
  function updateCardPoints(
    uint256 poolId_,
    uint256 cardId_,
    uint256 points_
  ) public onlyOwner poolExists(poolId_) cardExists(poolId_, cardId_) {
    Card storage c = pools[poolId_].cards[cardId_];
    c.points = points_;
    emit CardPointsUpdated(poolId_, cardId_, points_);
  }
}