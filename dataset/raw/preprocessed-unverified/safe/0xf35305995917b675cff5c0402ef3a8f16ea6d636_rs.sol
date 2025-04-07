/**
 *Submitted for verification at Etherscan.io on 2021-03-03
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
    IERC20 public WETH; // 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IFactory public sushiFactory; // IFactory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac);
    IFactory public uniV2Factory; // IFactory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IBentoBox public bentoBox; // 0xB5891167796722331b7ea7824F036b3Bdcb4531C

    constructor(
        IERC20 WETH_,
        IFactory sushiFactory_,
        IFactory uniV2Factory_,
        IBentoBox bentoBox_
    ) public {
        WETH = WETH_;
        sushiFactory = sushiFactory_;
        uniV2Factory = uniV2Factory_;
        bentoBox = bentoBox_;
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
            return uint256(reserve1) * 1e18 / reserve0;
        } else {
            return uint256(reserve0) * 1e18 / reserve1;
        }
    }

    struct BalanceFull {
        IERC20 token;
        uint256 balance;
        uint256 bentoBalance;
        uint256 bentoAllowance;
        uint128 bentoAmount;
        uint128 bentoShare;
        uint256 rate;
    }

    function getBalances(address who, IERC20[] calldata addresses) public view returns (BalanceFull[] memory) {
        BalanceFull[] memory balances = new BalanceFull[](addresses.length);

        for (uint256 i = 0; i < addresses.length; i++) {
            IERC20 token = addresses[i];
            balances[i].token = token;
            balances[i].balance = token.balanceOf(who);
            balances[i].bentoAllowance = token.allowance(who, address(bentoBox));
            balances[i].bentoBalance = bentoBox.balanceOf(token, who);
            if (balances[i].bentoBalance != 0) {
                (balances[i].bentoAmount, balances[i].bentoShare) = bentoBox.totals(token);
            }
            balances[i].rate = getETHRate(token);
        }

        return balances;
    }
}