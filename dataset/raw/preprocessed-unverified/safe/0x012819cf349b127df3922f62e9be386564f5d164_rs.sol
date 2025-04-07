/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

pragma solidity = 0.7.0;






interface Minter is ERC20 {
    event Mint(address indexed to, uint256 value, uint indexed period, uint userEthLocked, uint totalEthLocked);

    function governanceRouter() external view returns (GovernanceRouter);
    function mint(address to, uint period, uint128 userEthLocked, uint totalEthLocked) external returns (uint amount);
    function userTokensToClaim(address user) external view returns (uint amount);
    function periodTokens(uint period) external pure returns (uint128);
    function periodDecayK() external pure returns (uint decayK);
    function initialPeriodTokens() external pure returns (uint128);
}



interface WETH is ERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}







abstract contract LiquifiToken is ERC20 {

    function transfer(address to, uint256 value) public override returns (bool success) {
        if (accountBalances[msg.sender] >= value && value > 0) {
            accountBalances[msg.sender] -= value;
            accountBalances[to] += value;
            emit Transfer(msg.sender, to, value);
            return true;
        }
        return false;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool success) {
        if (accountBalances[from] >= value && allowed[from][msg.sender] >= value && value > 0) {
            accountBalances[to] += value;
            accountBalances[from] -= value;
            allowed[from][msg.sender] -= value;
            emit Transfer(from, to, value);
            return true;
        }
        return false;
    }

    function balanceOf(address owner) public override view returns (uint256 balance) {
        return accountBalances[owner];
    }

    function approve(address spender, uint256 value) external override returns (bool success) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) external override view returns (uint256 remaining) {
      return allowed[owner][spender];
    }

    mapping (address => uint256) internal accountBalances;
    mapping (address => mapping (address => uint256)) internal allowed;
}

// SPDX-License-Identifier: GPL-3.0
//import { Debug } from "./libraries/Debug.sol";
contract LiquifiMinter is LiquifiToken, Minter {
    using Math for uint256;

    string public constant override name = "Liquifi DAO Token";
    string public constant override symbol = "LQF";
    uint8 public constant override decimals = 18;
    uint public override totalSupply;
    GovernanceRouter public override immutable governanceRouter;
    ActivityMeter public immutable activityMeter;

    uint128 public override constant initialPeriodTokens = 2500000 * (10 ** 18);
    uint public override constant periodDecayK = 250; // pre-multiplied by 2**8

    constructor(address _governanceRouter) public {
        GovernanceRouter(_governanceRouter).setMinter(this);
        governanceRouter = GovernanceRouter(_governanceRouter);
        activityMeter = GovernanceRouter(_governanceRouter).activityMeter();
    }

    function periodTokens(uint period) public override pure returns (uint128) {
        period -= 1; // decayK for 1st period = 1
        uint decay = periodDecayK ** (period % 16); // process periods not covered by the loop
        decay = decay << ((16 - period % 16) * 8); // ensure that result is pre-multiplied by 2**128
        period = period / 16;
        uint numerator = periodDecayK ** 16;
        uint denominator = 1 << 128;
        while(period * decay != 0) { // one loop multiplies result by 16 periods decay
            decay = (decay * numerator) / denominator;
            period--;
        }

        return uint128((decay * initialPeriodTokens) >> 128);
    }

    function mint(address to, uint period, uint128 userEthLocked, uint totalEthLocked) external override returns (uint amount) {
        require(msg.sender == address(activityMeter), "LIQUIFI: INVALID MINT SENDER");
        if (totalEthLocked == 0) {
            return 0;
        }
        amount = (uint(periodTokens(period)) * userEthLocked) / totalEthLocked;
        totalSupply = totalSupply.add(amount);
        accountBalances[to] += amount;
        emit Mint(to, amount, period, userEthLocked, totalEthLocked);
    }

    function userTokensToClaim(address user) external view override returns (uint amount) {
        (uint ethLockedPeriod, uint userEthLocked, uint totalEthLocked) = activityMeter.userEthLocked(user);
        if (ethLockedPeriod != 0 && totalEthLocked != 0) {
            amount = (uint(periodTokens(ethLockedPeriod)) * userEthLocked) / totalEthLocked;
        }
    }
}