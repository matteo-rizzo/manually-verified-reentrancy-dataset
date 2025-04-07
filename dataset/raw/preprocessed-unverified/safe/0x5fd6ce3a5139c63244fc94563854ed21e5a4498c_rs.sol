/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;





interface IPair is IERC20 {
    function token0() external view returns (IERC20);
    function token1() external view returns (IERC20);

    function getReserves()
        external
        view
        returns (
            uint112,
            uint112,
            uint32
        );
}










contract BoringHelper is Ownable {
    using BoringMath for uint256;
    using BoringERC20 for IERC20;
    using BoringERC20 for IPair;
    using BoringPair for IPair;

    IMasterChef public chef; // IMasterChef(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);
    address public maker; // ISushiMaker(0xE11fc0B43ab98Eb91e9836129d1ee7c3Bc95df50);
    IERC20 public sushi; // ISushiToken(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    IERC20 public WETH; // 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IERC20 public WBTC; // 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    IFactory public sushiFactory; // IFactory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac);
    IFactory public uniV2Factory; // IFactory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IERC20 public bar; // 0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272;

    constructor(
        IMasterChef chef_,
        address maker_,
        IERC20 sushi_,
        IERC20 WETH_,
        IERC20 WBTC_,
        IFactory sushiFactory_,
        IFactory uniV2Factory_,
        IERC20 bar_
    ) public {
        chef = chef_;
        maker = maker_;
        sushi = sushi_;
        WETH = WETH_;
        WBTC = WBTC_;
        sushiFactory = sushiFactory_;
        uniV2Factory = uniV2Factory_;
        bar = bar_;
    }

    function setContracts(
        IMasterChef chef_,
        address maker_,
        IERC20 sushi_,
        IERC20 WETH_,
        IERC20 WBTC_,
        IFactory sushiFactory_,
        IFactory uniV2Factory_,
        IERC20 bar_
    ) public onlyOwner {
        chef = chef_;
        maker = maker_;
        sushi = sushi_;
        WETH = WETH_;
        WBTC = WBTC_;
        sushiFactory = sushiFactory_;
        uniV2Factory = uniV2Factory_;
        bar = bar_;
    }

    function getETHRate(IERC20 token) public view returns (uint256) {
        if (token == WETH) {
            return 1e18;
        }
        IPair pairUniV2 = IPair(uniV2Factory.getPair(token, WETH));
        IPair pairSushi = IPair(sushiFactory.getPair(token, WETH));
        if (address(pairUniV2) == address(0) && address(pairSushi) == address(0)) {
            return 0;
        }

        uint112 reserve0;
        uint112 reserve1;
        IERC20 token0;
        if (address(pairUniV2) != address(0)) {
            (uint112 reserve0UniV2, uint112 reserve1UniV2, ) = pairUniV2.getReserves();
            reserve0 += reserve0UniV2;
            reserve1 += reserve1UniV2;
            token0 = pairUniV2.token0();
        }

        if (address(pairSushi) != address(0)) {
            (uint112 reserve0Sushi, uint112 reserve1Sushi, ) = pairSushi.getReserves();
            reserve0 += reserve0Sushi;
            reserve1 += reserve1Sushi;
            if (token0 == IERC20(0)) {
                token0 = pairSushi.token0();
            }
        }

        if (token0 == WETH) {
            return uint256(reserve1).mul(1e18) / reserve0;
        } else {
            return uint256(reserve0).mul(1e18) / reserve1;
        }
    }

    struct Factory {
        IFactory factory;
        uint256 allPairsLength;
    }

    struct UIInfo {
        uint256 ethBalance;
        uint256 sushiBalance;
        uint256 sushiBarBalance;
        uint256 xsushiBalance;
        uint256 xsushiSupply;
        uint256 sushiBarAllowance;
        Factory[] factories;
        uint256 ethRate;
        uint256 sushiRate;
        uint256 btcRate;
        uint256 pendingSushi;
    }

    function getUIInfo(
        address who,
        IFactory[] calldata factoryAddresses,
        IERC20 currency
    ) public view returns (UIInfo memory) {
        UIInfo memory info;
        info.ethBalance = who.balance;

        info.factories = new Factory[](factoryAddresses.length);

        for (uint256 i = 0; i < factoryAddresses.length; i++) {
            IFactory factory = factoryAddresses[i];
            info.factories[i].factory = factory;
            info.factories[i].allPairsLength = factory.allPairsLength();
        }

        info.ethRate = getETHRate(currency);
        info.sushiRate = getETHRate(sushi);
        info.btcRate = getETHRate(WBTC);

        info.sushiBalance = sushi.balanceOf(who);
        info.sushiBarBalance = sushi.balanceOf(address(bar));
        info.xsushiBalance = bar.balanceOf(who);
        info.xsushiSupply = bar.totalSupply();
        info.sushiBarAllowance = sushi.allowance(who, address(bar));

        uint256 poolLength = chef.poolLength();
        uint256 pendingSushi;
        for (uint256 i = 0; i < poolLength; i++) {
            pendingSushi += chef.pendingSushi(i, who);
        }
        info.pendingSushi = pendingSushi;

        return info;
    }

    struct Balance {
        IERC20 token;
        uint256 balance;
        uint256 bentoBalance;
    }

    struct BalanceFull {
        IERC20 token;
        uint256 balance;
        uint256 rate;
    }

    struct TokenInfo {
        IERC20 token;
        uint256 decimals;
        string name;
        string symbol;
    }

    function getTokenInfo(address[] calldata addresses) public view returns (TokenInfo[] memory) {
        TokenInfo[] memory infos = new TokenInfo[](addresses.length);

        for (uint256 i = 0; i < addresses.length; i++) {
            IERC20 token = IERC20(addresses[i]);
            infos[i].token = token;

            infos[i].name = token.name();
            infos[i].symbol = token.symbol();
            infos[i].decimals = token.decimals();
        }

        return infos;
    }

    function findBalances(address who, address[] calldata addresses) public view returns (Balance[] memory) {
        Balance[] memory balances = new Balance[](addresses.length);

        uint256 len = addresses.length;
        for (uint256 i = 0; i < len; i++) {
            IERC20 token = IERC20(addresses[i]);
            balances[i].token = token;
            balances[i].balance = token.balanceOf(who);
        }

        return balances;
    }

    function getBalances(address who, address[] calldata addresses) public view returns (BalanceFull[] memory) {
        BalanceFull[] memory balances = new BalanceFull[](addresses.length);

        for (uint256 i = 0; i < addresses.length; i++) {
            IERC20 token = IERC20(addresses[i]);
            balances[i].token = token;
            balances[i].balance = IERC20(token).balanceOf(who);
            balances[i].rate = getETHRate(token);
        }

        return balances;
    }

    struct PairBase {
        IPair token;
        IERC20 token0;
        IERC20 token1;
        uint256 totalSupply;
    }

    function getPairs(
        IFactory factory,
        uint256 fromID,
        uint256 toID
    ) public view returns (PairBase[] memory) {
        PairBase[] memory pairs = new PairBase[](toID - fromID);

        for (uint256 id = fromID; id < toID; id++) {
            IPair token = factory.allPairs(id);
            uint256 i = id - fromID;
            pairs[i].token = token;
            pairs[i].token0 = token.token0();
            pairs[i].token1 = token.token1();
            pairs[i].totalSupply = token.totalSupply();
        }
        return pairs;
    }

    struct PairPoll {
        IPair token;
        uint256 reserve0;
        uint256 reserve1;
        uint256 totalSupply;
        uint256 balance;
    }

    function pollPairs(address who, IPair[] calldata addresses) public view returns (PairPoll[] memory) {
        PairPoll[] memory pairs = new PairPoll[](addresses.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            IPair token = addresses[i];
            pairs[i].token = token;
            (uint256 reserve0, uint256 reserve1, ) = token.getReserves();
            pairs[i].reserve0 = reserve0;
            pairs[i].reserve1 = reserve1;
            pairs[i].balance = token.balanceOf(who);
            pairs[i].totalSupply = token.totalSupply();
        }
        return pairs;
    }

    struct PoolsInfo {
        uint256 totalAllocPoint;
        uint256 poolLength;
    }

    struct PoolInfo {
        uint256 pid;
        IPair lpToken;
        uint256 allocPoint;
        bool isPair;
        IFactory factory;
        IERC20 token0;
        IERC20 token1;
        string name;
        string symbol;
        uint8 decimals;
    }

    function getPools(uint256[] calldata pids) public view returns (PoolsInfo memory, PoolInfo[] memory) {
        PoolsInfo memory info;
        info.totalAllocPoint = chef.totalAllocPoint();
        uint256 poolLength = chef.poolLength();
        info.poolLength = poolLength;

        PoolInfo[] memory pools = new PoolInfo[](pids.length);

        for (uint256 i = 0; i < pids.length; i++) {
            pools[i].pid = pids[i];
            (address lpToken, uint256 allocPoint, , ) = chef.poolInfo(pids[i]);
            IPair uniV2 = IPair(lpToken);
            pools[i].lpToken = uniV2;
            pools[i].allocPoint = allocPoint;

            pools[i].name = uniV2.name();
            pools[i].symbol = uniV2.symbol();
            pools[i].decimals = uniV2.decimals();

            pools[i].factory = uniV2.factory();
            if (pools[i].factory != IFactory(0)) {
                pools[i].isPair = true;
                pools[i].token0 = uniV2.token0();
                pools[i].token1 = uniV2.token1();
            }
        }
        return (info, pools);
    }

    struct PoolFound {
        uint256 pid;
        uint256 balance;
    }

    function findPools(address who, uint256[] calldata pids) public view returns (PoolFound[] memory) {
        PoolFound[] memory pools = new PoolFound[](pids.length);

        for (uint256 i = 0; i < pids.length; i++) {
            pools[i].pid = pids[i];
            (pools[i].balance, ) = chef.userInfo(pids[i], who);
        }

        return pools;
    }

    struct UserPoolInfo {
        uint256 pid;
        uint256 balance; // Balance of pool tokens
        uint256 totalSupply; // Token staked lp tokens
        uint256 lpBalance; // Balance of lp tokens not staked
        uint256 lpTotalSupply; // TotalSupply of lp tokens
        uint256 lpAllowance; // LP tokens approved for masterchef
        uint256 reserve0;
        uint256 reserve1;
        uint256 rewardDebt;
        uint256 pending; // Pending SUSHI
    }

    function pollPools(address who, uint256[] calldata pids) public view returns (UserPoolInfo[] memory) {
        UserPoolInfo[] memory pools = new UserPoolInfo[](pids.length);

        for (uint256 i = 0; i < pids.length; i++) {
            (uint256 amount, ) = chef.userInfo(pids[i], who);
            pools[i].balance = amount;
            pools[i].pending = chef.pendingSushi(pids[i], who);

            (address lpToken, , , ) = chef.poolInfo(pids[i]);
            pools[i].pid = pids[i];
            IPair uniV2 = IPair(lpToken);
            IFactory factory = uniV2.factory();
            if (factory != IFactory(0)) {
                pools[i].totalSupply = uniV2.balanceOf(address(chef));
                pools[i].lpAllowance = uniV2.allowance(who, address(chef));
                pools[i].lpBalance = uniV2.balanceOf(who);
                pools[i].lpTotalSupply = uniV2.totalSupply();

                (uint112 reserve0, uint112 reserve1, ) = uniV2.getReserves();
                pools[i].reserve0 = reserve0;
                pools[i].reserve1 = reserve1;
            }
        }
        return pools;
    }
}