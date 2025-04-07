/**
 *Submitted for verification at Etherscan.io on 2020-10-31
*/

// Dependency file: @openzeppelin/contracts/GSN/Context.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

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


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/GSN/Context.sol";
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


// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


// pragma solidity ^0.6.0;

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



// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: @openzeppelin/contracts/utils/EnumerableSet.sol


// pragma solidity ^0.6.0;

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



// Root file: contracts/MasterGame.sol

pragma solidity ^0.6.12;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/utils/EnumerableSet.sol";

/**
 * @dev Ticket contract interface
 */
interface ITicketsToken is IERC20 {
    function burnFromUsdt(address account, uint256 usdtAmount) external;

    function vendingAndBurn(address account, uint256 amount) external;

    function price() external returns (uint256);

    function totalVending() external returns (uint256);
}

/**
 * @dev Master contract
 */
contract MasterGame is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    IERC20 usdt;
    uint256 constant usdter = 1e6;

    // Creation time
    uint256 public createdAt;
    // Total revenue
    uint256 public totalRevenue;

    // Ticket contract
    ITicketsToken ticket;

    // Static income cycle: 1 day
    uint256 constant STATIC_CYCLE = 1 days;
    // Daily prize pool cycle: 1 day
    uint256 constant DAY_POOL_CYCLE = 1 days;
    // Weekly prize pool cycle: 7 days
    uint256 constant WEEK_POOL_CYCLE = 7 days;
    // Upgrade node discount: 100 days
    uint256 constant NODE_DISCOUNT_TIME = 100 days;

    // Static rate of return, parts per thousand
    uint256 staticRate = 5;
    // Dynamic rate of return, parts per thousand
    uint256[12] dynamicRates = [
        100,
        80,
        60,
        50,
        50,
        60,
        70,
        50,
        50,
        50,
        60,
        80
    ];
    // Technology founding team
    uint256 public founder;
    // Market value management fee
    uint256 public operation;
    // Insurance pool
    uint256 public insurance;
    // Perpetual capital pool
    uint256 public sustainable;
    // Dex Market making
    uint256 public dex;
    // Account ID
    uint256 public id;
    // Number of people activating Pa Point
    uint8 public nodeBurnNumber;
    // Account data
    mapping(address => Account) public accounts;
    mapping(address => AccountCount) public stats;
    // Node burn data
    mapping(address => AccountNodeBurn) public burns;
    // Team data
    mapping(address => AccountPerformance) public performances;
    mapping(address => address[]) public teams;
    // Node data
    // 1 Light node; 2 Intermediate node; 3 Super node; 4 Genesis node
    mapping(uint8 => address[]) public nodes;

    // Weekly prize pool
    uint64 public weekPoolId;
    mapping(uint64 => Pool) public weekPool;

    // Daily prize pool
    uint64 public dayPoolId;
    mapping(uint64 => Pool) public dayPool;

    // Address with a deposit of 15,000 or more
    EnumerableSet.AddressSet private richman;

    // Account
    struct Account {
        uint256 id;
        address referrer; // Direct push
        bool reinvest; // Whether to reinvest
        uint8 nodeLevel; // Node level
        uint256 joinTime; // Join time: This value needs to be updated when joining again
        uint256 lastTakeTime; // Last time the static income was received
        uint256 deposit; // Deposited quantity: 0 means "out"
        uint256 nodeIncome; // Node revenue balance
        uint256 dayPoolIncome; // Daily bonus pool income balance
        uint256 weekPoolIncome; // Weekly bonus pool income balance
        uint256 dynamicIncome; // Dynamic income balance
        uint256 income; // Total revenue
        uint256 maxIncome; // Exit condition
        uint256 reward; // Additional other rewards
    }

    // Account statistics
    struct AccountCount {
        uint256 income; // Total revenue
        uint256 investment; // Total investment
    }

    // Performance
    struct AccountPerformance {
        uint256 performance; // Direct performance
        uint256 wholeLine; // Performance of all layers below
    }

    // Node burn
    struct AccountNodeBurn {
        bool active; // Whether to activate Node burn
        uint256 income; // Node burn income
    }

    // Prize pool
    struct Pool {
        uint256 amount; // Prize pool amount
        uint256 date; // Creation time: Use this field to determine the draw time
        mapping(uint8 => address) ranks; // Ranking: up to 256
        mapping(address => uint256) values; // Quantity/Performance
    }

    /**
     * @dev Determine whether the address is an already added address
     */
    modifier onlyJoined(address addr) {
        require(accounts[addr].id > 0, "ANR");
        _;
    }

    constructor(IERC20 _usdt) public {
        usdt = _usdt;

        createdAt = now;

        // Genius
        Account storage user = accounts[msg.sender];
        user.id = ++id;
        user.referrer = address(0);
        user.joinTime = now;
    }

    /**
     * @dev Join or reinvest the game
     */
    function join(address referrer, uint256 _amount)
        public
        onlyJoined(referrer)
    {
        require(referrer != msg.sender, "NS");
        require(_amount >= usdter.mul(100), "MIN");

        // Receive USDT
        usdt.safeTransferFrom(msg.sender, address(this), _amount);

        // Burn 12%
        _handleJoinBurn(msg.sender, _amount);

        Account storage user = accounts[msg.sender];
        // Create new account
        if (user.id == 0) {
            user.id = ++id;
            user.referrer = referrer;
            user.joinTime = now;
            // Direct team
            teams[referrer].push(msg.sender);
        }

        // Reinvest to join
        if (user.deposit != 0) {
            require(!user.reinvest, "Reinvest");

            // Can reinvest after paying back
            uint256 income = calculateStaticIncome(msg.sender)
                .add(user.dynamicIncome)
                .add(user.nodeIncome)
                .add(burns[msg.sender].income)
                .add(user.income);
            require(income >= user.deposit, "Not Coast");

            // Half or all reinvestment
            require(
                _amount == user.deposit || _amount == user.deposit.div(2),
                "FOH"
            );

            if (_amount == user.deposit) {
                // All reinvestment
                user.maxIncome = user.maxIncome.add(
                    _calculateFullOutAmount(_amount)
                );
            } else {
                // Half return
                user.maxIncome = user.maxIncome.add(
                    _calculateOutAmount(_amount)
                );
            }
            user.reinvest = true;
            user.deposit = user.deposit.add(_amount);
        } else {
            // Join out
            user.deposit = _amount;
            user.lastTakeTime = now;
            user.maxIncome = _calculateOutAmount(_amount);
            // Cumulative income cleared
            user.nodeIncome = 0;
            user.dayPoolIncome = 0;
            user.weekPoolIncome = 0;
            user.dynamicIncome = 0;
            burns[msg.sender].income = 0;
        }

        // Processing performance
        performances[msg.sender].wholeLine = performances[msg.sender]
            .wholeLine
            .add(_amount);
        _handlePerformance(user.referrer, _amount);
        // Processing node rewards
        _handleNodeReward(_amount);
        // Handling Node burn Reward
        _handleNodeBurnReward(msg.sender, _amount);
        // Processing node level
        _handleNodeLevel(user.referrer);
        // Handling prizes and draws
        _handlePool(user.referrer, _amount);

        // Technology founding team: 4%
        founder = founder.add(_amount.mul(4).div(100));
        // Expansion operating expenses: 4%
        operation = operation.add(_amount.mul(4).div(100));
        // Dex market making capital 2%
        dex = dex.add(_amount.mul(2).div(100));

        // Insurance pool: 1.5%
        insurance = insurance.add(_amount.mul(15).div(1000));
        // Perpetual pool: 3.5%
        sustainable = sustainable.add(_amount.mul(35).div(1000));

        // Record the address of deposit 15000
        if (user.deposit >= usdter.mul(15000)) {
            EnumerableSet.add(richman, msg.sender);
        }

        // Statistics total investment
        stats[msg.sender].investment = stats[msg.sender].investment.add(
            _amount
        );
        // Total revenue
        totalRevenue = totalRevenue.add(_amount);
    }

    /**
     * @dev Burn tickets when you join
     */
    function _handleJoinBurn(address addr, uint256 _amount) internal {
        uint256 burnUsdt = _amount.mul(12).div(100);
        uint256 burnAmount = burnUsdt.mul(ticket.price()).div(usdter);
        uint256 bal = ticket.balanceOf(addr);

        if (bal >= burnAmount) {
            ticket.burnFromUsdt(addr, burnUsdt);
        } else {
            // USDT can be used to deduct tickets after the resonance of 4.5 million
            require(
                ticket.totalVending() >= uint256(1e18).mul(4500000),
                "4.5M"
            );

            // Use USDT to deduct tickets
            usdt.safeTransferFrom(addr, address(this), burnUsdt);
            ticket.vendingAndBurn(addr, burnAmount);
        }
    }

    /**
     * @dev Receive revenue and calculate outgoing data
     */
    function take() public onlyJoined(msg.sender) {
        Account storage user = accounts[msg.sender];

        require(user.deposit > 0, "OUT");

        uint256 staticIncome = calculateStaticIncome(msg.sender);
        if (staticIncome > 0) {
            user.lastTakeTime =
                now -
                ((now - user.lastTakeTime) % STATIC_CYCLE);
        }

        uint256 paid = staticIncome
            .add(user.dynamicIncome)
            .add(user.nodeIncome)
            .add(burns[msg.sender].income);

        // Cleared
        user.nodeIncome = 0;
        user.dynamicIncome = 0;
        burns[msg.sender].income = 0;

        // Cumulative income
        user.income = user.income.add(paid);

        // Meet the exit conditions, or no re-investment and reach 1.3 times
        uint256 times13 = user.deposit.mul(13).div(10);
        bool special = !user.reinvest && user.income >= times13;
        // Out of the game
        if (user.income >= user.maxIncome || special) {
            // Deduct excess income
            if (special) {
                paid = times13.sub(user.income.sub(paid));
            } else {
                paid = paid.sub(user.income.sub(user.maxIncome));
            }
            // Data clear
            user.deposit = 0;
            user.income = 0;
            user.maxIncome = 0;
            user.reinvest = false;
        }

        // Static income returns to superior dynamic income
        // When zooming in half of the quota (including re-investment), dynamic acceleration is not provided to the upper 12 layers
        if (staticIncome > 0 && user.income < user.maxIncome.div(2)) {
            _handleDynamicIncome(msg.sender, staticIncome);
        }

        // Total income statistics
        stats[msg.sender].income = stats[msg.sender].income.add(paid);

        // USDT transfer
        _safeUsdtTransfer(msg.sender, paid);

        // Trigger
        _openWeekPool();
        _openDayPool();
    }

    /**
     * @dev Receive insurance pool rewards
     */
    function takeReward() public {
        uint256 paid = accounts[msg.sender].reward;
        accounts[msg.sender].reward = 0;
        usdt.safeTransfer(msg.sender, paid);

        // Total income statistics
        stats[msg.sender].income = stats[msg.sender].income.add(paid);
    }

    /**
     * @dev Receive prize pool income
     */
    function takePoolIncome() public {
        Account storage user = accounts[msg.sender];

        uint256 paid = user.dayPoolIncome.add(user.weekPoolIncome);
        user.dayPoolIncome = 0;
        user.weekPoolIncome = 0;

        // Total income statistics
        stats[msg.sender].income = stats[msg.sender].income.add(paid);

        _safeUsdtTransfer(msg.sender, paid);
    }

    /**
     * @dev To activate Node burn, you need to destroy some tickets worth a specific USDT
     */
    function activateNodeBurn() public onlyJoined(msg.sender) {
        require(!burns[msg.sender].active, "ACT");
        require(nodeBurnNumber < 500, "LIMIT");

        uint256 burn = activateNodeBurnAmount();

        ticket.burnFromUsdt(msg.sender, burn);
        nodeBurnNumber++;

        burns[msg.sender].active = true;
    }

    /**
     * @dev Get the amount of USDT that activates the burned ticket for Node burn
     */
    function activateNodeBurnAmount() public view returns (uint256) {
        uint8 num = nodeBurnNumber + 1;

        if (num >= 400) {
            return usdter.mul(7000);
        } else if (num >= 300) {
            return usdter.mul(6000);
        } else if (num >= 200) {
            return usdter.mul(5000);
        } else if (num >= 100) {
            return usdter.mul(4000);
        } else {
            return usdter.mul(3000);
        }
    }

    /**
     * @dev Handling Node burn Reward
     */
    function _handleNodeBurnReward(address addr, uint256 _amount) internal {
        address referrer = accounts[addr].referrer;
        bool pioneer = false;

        while (referrer != address(0)) {
            AccountNodeBurn storage ap = burns[referrer];
            if (ap.active) {
                if (accounts[referrer].nodeLevel > 0) {
                    uint256 paid;
                    if (pioneer) {
                        paid = _amount.mul(4).div(100); // 4%
                    } else {
                        paid = _amount.mul(7).div(100); // 7%
                    }
                    ap.income = ap.income.add(paid);
                    break;
                } else if (!pioneer) {
                    ap.income = ap.income.add(_amount.mul(3).div(100)); // 3%
                    pioneer = true;
                }
            }
            referrer = accounts[referrer].referrer;
        }
    }

    /**
     * @dev Dealing with dynamic revenue
     */
    function _handleDynamicIncome(address addr, uint256 _amount) internal {
        address account = accounts[addr].referrer;
        // Up to 12 layers
        for (uint8 i = 1; i <= 12; i++) {
            if (account == address(0)) {
                break;
            }

            Account storage user = accounts[account];
            if (
                user.deposit > 0 &&
                _canDynamicIncomeAble(
                    performances[account].performance,
                    user.deposit,
                    i
                )
            ) {
                uint256 _income = _amount.mul(dynamicRates[i - 1]).div(1000);
                user.dynamicIncome = user.dynamicIncome.add(_income);
            }

            account = user.referrer;
        }
    }

    /**
     * @dev Judge whether you can get dynamic income
     */
    function _canDynamicIncomeAble(
        uint256 performance,
        uint256 deposit,
        uint8 floor
    ) internal pure returns (bool) {
        // Deposit more than 1500
        if (deposit >= usdter.mul(1500)) {
            if (performance >= usdter.mul(10000)) {
                return floor <= 12;
            }
            if (performance >= usdter.mul(6000)) {
                return floor <= 8;
            }
            if (performance >= usdter.mul(3000)) {
                return floor <= 5;
            }
            if (performance >= usdter.mul(1500)) {
                return floor <= 3;
            }
        } else if (deposit >= usdter.mul(300)) {
            if (performance >= usdter.mul(1500)) {
                return floor <= 3;
            }
        }
        return floor <= 1;
    }

    /**
     * @dev Process prize pool data and draw
     */
    function _handlePool(address referrer, uint256 _amount) internal {
        _openWeekPool();
        _openDayPool();

        uint256 prize = _amount.mul(3).div(100); // 3%

        uint256 dayPrize = prize.mul(60).div(100); // 60%
        uint256 weekPrize = prize.sub(dayPrize); // 40%

        _handleWeekPool(referrer, _amount, weekPrize);
        _handleDayPool(referrer, _amount, dayPrize);
    }

    /**
     * @dev Manually trigger the draw
     */
    function triggerOpenPool() public {
        _openWeekPool();
        _openDayPool();
    }

    /**
     * @dev Processing weekly prize pool
     */
    function _handleWeekPool(
        address referrer,
        uint256 _amount,
        uint256 _prize
    ) internal {
        Pool storage week = weekPool[weekPoolId];

        week.amount = week.amount.add(_prize);
        week.values[referrer] = week.values[referrer].add(_amount);
        _PoolSort(week, referrer, 3);
    }

    /**
     * @dev Handling the daily prize pool
     */
    function _handleDayPool(
        address referrer,
        uint256 _amount,
        uint256 _prize
    ) internal {
        Pool storage day = dayPool[dayPoolId];

        day.amount = day.amount.add(_prize);
        day.values[referrer] = day.values[referrer].add(_amount);
        _PoolSort(day, referrer, 7);
    }

    /**
     * @dev Prize pool sorting
     */
    function _PoolSort(
        Pool storage pool,
        address addr,
        uint8 number
    ) internal {
        for (uint8 i = 0; i < number; i++) {
            address key = pool.ranks[i];
            if (key == addr) {
                break;
            }
            if (pool.values[addr] > pool.values[key]) {
                for (uint8 j = number; j > i; j--) {
                    pool.ranks[j] = pool.ranks[j - 1];
                }
                pool.ranks[i] = addr;

                for (uint8 k = i + 1; k < number; k++) {
                    if (pool.ranks[k] == addr) {
                        for (uint8 l = k; l < number; l++) {
                            pool.ranks[l] = pool.ranks[l + 1];
                        }
                        break;
                    }
                }
                break;
            }
        }
    }

    /**
     * @dev Weekly prize pool draw
     */
    function _openWeekPool() internal {
        Pool storage week = weekPool[weekPoolId];
        // Determine whether the weekly prize pool can draw prizes
        if (now >= week.date + WEEK_POOL_CYCLE) {
            weekPoolId++;
            weekPool[weekPoolId].date = now;

            // 15% for the draw
            uint256 prize = week.amount.mul(15).div(100);
            // 85% naturally rolled into the next round
            weekPool[weekPoolId].amount = week.amount.sub(prize);

            if (prize > 0) {
                // No prizes left
                uint256 surplus = prize;

                // Proportion 70%¡¢20%¡¢10%
                uint256[3] memory rates = [
                    uint256(70),
                    uint256(20),
                    uint256(10)
                ];
                // Top 3
                for (uint8 i = 0; i < 3; i++) {
                    address addr = week.ranks[i];
                    uint256 reward = prize.mul(rates[i]).div(100);

                    // Reward for rankings, and rollover to the next round without rankings
                    if (addr != address(0)) {
                        accounts[addr].weekPoolIncome = accounts[addr]
                            .weekPoolIncome
                            .add(reward);
                        surplus = surplus.sub(reward);
                    }
                }

                // Add the rest to the next round
                weekPool[weekPoolId].amount = weekPool[weekPoolId].amount.add(
                    surplus
                );
            }
        }
    }

    /**
     * @dev Daily prize pool draw
     */
    function _openDayPool() internal {
        Pool storage day = dayPool[dayPoolId];
        // Determine whether the daily prize pool can be drawn
        if (now >= day.date + DAY_POOL_CYCLE) {
            dayPoolId++;
            dayPool[dayPoolId].date = now;

            // 15% for the draw
            uint256 prize = day.amount.mul(15).div(100);
            // 85% naturally rolled into the next round
            dayPool[dayPoolId].amount = day.amount.sub(prize);

            if (prize > 0) {
                // No prizes left
                uint256 surplus = prize;

                // The first and second place ratios are 70%, 20%; 10% is evenly distributed to the remaining 5
                uint256[2] memory rates = [uint256(70), uint256(20)];

                // Top 2
                for (uint8 i = 0; i < 2; i++) {
                    address addr = day.ranks[i];
                    uint256 reward = prize.mul(rates[i]).div(100);

                    // Reward for rankings, and rollover to the next round without rankings
                    if (addr != address(0)) {
                        accounts[addr].dayPoolIncome = accounts[addr]
                            .dayPoolIncome
                            .add(reward);
                        surplus = surplus.sub(reward);
                    }
                }

                // 10% is evenly divided among the remaining 5
                uint256 avg = prize.div(50);
                for (uint8 i = 2; i <= 6; i++) {
                    address addr = day.ranks[i];

                    if (addr != address(0)) {
                        accounts[addr].dayPoolIncome = accounts[addr]
                            .dayPoolIncome
                            .add(avg);
                        surplus = surplus.sub(avg);
                    }
                }

                // Add the rest to the next round
                dayPool[dayPoolId].amount = dayPool[dayPoolId].amount.add(
                    surplus
                );
            }
        }
    }

    /**
     * @dev Processing account performance
     */
    function _handlePerformance(address referrer, uint256 _amount) internal {
        // Direct performance
        performances[referrer].performance = performances[referrer]
            .performance
            .add(_amount);
        // Full line performance
        address addr = referrer;
        while (addr != address(0)) {
            performances[addr].wholeLine = performances[addr].wholeLine.add(
                _amount
            );
            addr = accounts[addr].referrer;
        }
    }

    /**
     * @dev Processing node level
     */
    function _handleNodeLevel(address referrer) internal {
        address addr = referrer;

        // Condition
        uint256[4] memory c1s = [
            usdter.mul(100000),
            usdter.mul(300000),
            usdter.mul(600000),
            usdter.mul(1200000)
        ];
        uint256[4] memory c2s = [
            usdter.mul(250000),
            usdter.mul(600000),
            usdter.mul(1200000),
            usdter.mul(2250000)
        ];
        uint256[4] memory s1s = [
            usdter.mul(20000),
            usdter.mul(60000),
            usdter.mul(90000),
            usdter.mul(160000)
        ];
        uint256[4] memory s2s = [
            usdter.mul(30000),
            usdter.mul(90000),
            usdter.mul(135000),
            usdter.mul(240000)
        ];

        while (addr != address(0)) {
            uint8 level = accounts[addr].nodeLevel;
            if (level < 4) {
                uint256 c1 = c1s[level];
                uint256 c2 = c2s[level];

                if (now - accounts[addr].joinTime <= NODE_DISCOUNT_TIME) {
                    c1 = c1.sub(s1s[level]);
                    c2 = c2.sub(s2s[level]);
                }

                if (_handleNodeLevelUpgrade(addr, c1, c2)) {
                    accounts[addr].nodeLevel = level + 1;
                    nodes[level + 1].push(addr);
                }
            }

            addr = accounts[addr].referrer;
        }
    }

    /**
     * @dev Determine whether the upgrade conditions are met according to the conditions
     */
    function _handleNodeLevelUpgrade(
        address addr,
        uint256 c1,
        uint256 c2
    ) internal view returns (bool) {
        uint8 count = 0;
        uint256 min = uint256(-1);

        for (uint256 i = 0; i < teams[addr].length; i++) {
            uint256 w = performances[teams[addr][i]].wholeLine;

            // Case 1
            if (w >= c1) {
                count++;
                if (count >= 3) {
                    return true;
                }
            }

            // Case 2
            if (w >= c2 && w < min) {
                min = w;
            }
        }
        if (min < uint256(-1) && performances[addr].wholeLine.sub(min) >= c2) {
            return true;
        }

        return false;
    }

    /**
     * @dev Processing node rewards
     */
    function _handleNodeReward(uint256 _amount) internal {
        uint256 reward = _amount.div(25);
        for (uint8 i = 1; i <= 4; i++) {
            address[] storage _nodes = nodes[i];
            uint256 len = _nodes.length;
            if (len > 0) {
                uint256 _reward = reward.div(len);
                for (uint256 j = 0; j < len; j++) {
                    Account storage user = accounts[_nodes[j]];
                    user.nodeIncome = user.nodeIncome.add(_reward);
                }
            }
        }
    }

    /**
     * @dev Calculate static income
     */
    function calculateStaticIncome(address addr) public view returns (uint256) {
        Account storage user = accounts[addr];
        if (user.deposit > 0) {
            uint256 last = user.lastTakeTime;
            uint256 day = (now - last) / STATIC_CYCLE;

            if (day == 0) {
                return 0;
            }

            if (day > 30) {
                day = 30;
            }

            return user.deposit.mul(staticRate).div(1000).mul(day);
        }
        return 0;
    }

    /**
     * @dev Calculate out multiple
     */
    function _calculateOutAmount(uint256 _amount)
        internal
        pure
        returns (uint256)
    {
        if (_amount >= usdter.mul(15000)) {
            return _amount.mul(35).div(10);
        } else if (_amount >= usdter.mul(4000)) {
            return _amount.mul(30).div(10);
        } else if (_amount >= usdter.mul(1500)) {
            return _amount.mul(25).div(10);
        } else {
            return _amount.mul(20).div(10);
        }
    }

    /**
     * @dev Calculate the out multiple of all reinvestments
     */
    function _calculateFullOutAmount(uint256 _amount)
        internal
        pure
        returns (uint256)
    {
        if (_amount >= usdter.mul(15000)) {
            return _amount.mul(45).div(10);
        } else if (_amount >= usdter.mul(4000)) {
            return _amount.mul(40).div(10);
        } else if (_amount >= usdter.mul(1500)) {
            return _amount.mul(35).div(10);
        } else {
            return _amount.mul(25).div(10);
        }
    }

    /**
     * @dev Get the number of nodes at a certain level
     */
    function nodeLength(uint8 level) public view returns (uint256) {
        return nodes[level].length;
    }

    /**
     * @dev Number of teams
     */
    function teamsLength(address addr) public view returns (uint256) {
        return teams[addr].length;
    }

    /**
     * @dev Daily prize pool ranking
     */
    function dayPoolRank(uint64 _id, uint8 _rank)
        public
        view
        returns (address)
    {
        return dayPool[_id].ranks[_rank];
    }

    /**
     * @dev Daily prize pool performance
     */
    function dayPoolValue(uint64 _id, address _addr)
        public
        view
        returns (uint256)
    {
        return dayPool[_id].values[_addr];
    }

    /**
     * @dev Weekly prize pool ranking
     */
    function weekPoolRank(uint64 _id, uint8 _rank)
        public
        view
        returns (address)
    {
        return weekPool[_id].ranks[_rank];
    }

    /**
     * @dev Weekly prize pool performance
     */
    function weekPoolValue(uint64 _id, address _addr)
        public
        view
        returns (uint256)
    {
        return weekPool[_id].values[_addr];
    }

    /**
     * @dev Team statistics, return the smallest, medium and most performance
     */
    function teamsStats(address addr) public view returns (uint256, uint256) {
        uint256 count = teams[addr].length;
        if (count > 0) {
            uint256 max = performances[teams[addr][count - 1]].wholeLine;
            uint256 min = performances[teams[addr][count - 1]].wholeLine;
            for (uint256 i = 0; i < count; i++) {
                if (performances[teams[addr][i]].wholeLine > max) {
                    max = performances[teams[addr][i]].wholeLine;
                }
                if (performances[teams[addr][i]].wholeLine < min) {
                    min = performances[teams[addr][i]].wholeLine;
                }
            }

            return (max, min);
        }
        return (0, 0);
    }

    /**
     * @dev Count how many people meet the conditions
     */
    function teamsCount(address addr, uint256 _amount)
        public
        view
        returns (uint256)
    {
        uint256 count;

        for (uint256 i = 0; i < teams[addr].length; i++) {
            if (_amount <= performances[teams[addr][i]].wholeLine) {
                count++;
            }
        }

        return count;
    }

    /**
     * @dev Get the number of large account addresses
     */
    function richmanLength() public view returns (uint256) {
        return EnumerableSet.length(richman);
    }

    /**
     * @dev Safe USDT transfer, excluding the balance of insurance pool and perpetual pool
     */
    function _safeUsdtTransfer(address addr, uint256 _amount) internal {
        uint256 bal = usdt.balanceOf(address(this));
        bal = bal.sub(insurance).sub(sustainable);

        if (bal < _amount) {
            usdt.safeTransfer(addr, bal);
        } else {
            usdt.safeTransfer(addr, _amount);
        }
    }

    /**
     * @dev Activate the insurance pool, only the administrator can call
     */
    function activeInsurance() public onlyOwner {
        uint256 nodePaid = insurance.mul(70).div(100);
        uint256 bigPaid = insurance.sub(nodePaid);

        insurance = 0;

        // Issued to richman
        uint256 _richmanLen = EnumerableSet.length(richman);
        if (_richmanLen > 0) {
            uint256 paid = bigPaid.div(_richmanLen);
            for (uint256 i = 0; i < _richmanLen; i++) {
                Account storage user = accounts[EnumerableSet.at(richman, i)];
                user.reward = user.reward.add(paid);
            }
        }

        // Issued to node
        uint256[4] memory _rates = [
            uint256(10),
            uint256(20),
            uint256(30),
            uint256(40)
        ];
        for (uint8 i = 1; i <= 4; i++) {
            uint256 _nodeLen = nodes[i].length;
            if (_nodeLen > 0) {
                uint256 paid = nodePaid.mul(_rates[i - 1]).div(100).div(
                    _nodeLen
                );
                for (uint256 j = 0; j < _nodeLen; j++) {
                    Account storage user = accounts[nodes[i][j]];
                    user.reward = user.reward.add(paid);
                }
            }
        }
    }

    /**
     * @dev Transfer to the perpetual pool, only the administrator can call
     */
    function activeSustainable(address next) public onlyOwner {
        require(sustainable > 0);
        uint256 paid = sustainable;
        uint256 bal = usdt.balanceOf(address(this));
        if (bal < paid) {
            usdt.safeTransfer(next, bal);
        } else {
            usdt.safeTransfer(next, paid);
        }
    }

    /**
     * @dev Set static rate of return, only the administrator can call
     */
    function setStaticRate(uint256 _rate) public onlyOwner {
        require(_rate <= 1000);
        staticRate = _rate;
    }

    /**
     * @dev Set dynamic rate of return, only the administrator can call
     */
    function setDynamicRates(uint8 level, uint256 _rate) public onlyOwner {
        require(level < 12);
        require(_rate <= 1000);
        dynamicRates[level] = _rate;
    }

    /**
     * @dev Set up the ticket contract, only the administrator can call
     */
    function setTicket(ITicketsToken _ticket) public onlyOwner {
        ticket = _ticket;
    }

    /**
     * @dev Receive the technical founding team, only the administrator can call
     */
    function takeFounder() public onlyOwner {
        uint256 paid = founder;
        founder = 0;
        usdt.safeTransfer(msg.sender, paid);
    }

    /**
     * @dev Receive expansion operation fee, only the administrator can call
     */
    function takeOperation() public onlyOwner {
        uint256 paid = operation.add(dex);
        operation = 0;
        dex = 0;
        usdt.safeTransfer(msg.sender, paid);
    }
}