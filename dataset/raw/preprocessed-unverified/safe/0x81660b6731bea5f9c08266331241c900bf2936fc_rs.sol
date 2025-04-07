/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

// SPDX-License-Identifier: MIT
// solium-disable security/no-low-level-calls
pragma solidity ^0.6.12;











contract UniV2toSushiMigrator is Ownable {
    uint256 public migrateRefund = 0; // 50000000? SUSHI refund per gwei in gasprice
    uint256 public newPairRefund = 0; // 400000000? SUSHI refund per gwei in gasprice
    uint256 public maxGasPrice = 100000000000; // Max gas price to limit exploits

    function set(uint256 migrateRefund_, uint256 newPairRefund_, uint256 maxGasPrice_) public onlyOwner {
        migrateRefund = migrateRefund_;
        newPairRefund = newPairRefund_;
        maxGasPrice = maxGasPrice_;
    }
    
    function drain(address token) public onlyOwner {
        safeTransfer(token, msg.sender, IERC20(token).balanceOf(address(this)));
    }
    
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function safeTransfer(address token, address to, uint256 amount) private {
        if (amount > 0) {
            (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, amount));
            require(success && (data.length == 0 || abi.decode(data, (bool))), "Transfer failed at ERC20");
        }
    }
    
    function reward(uint256 amount) private {
        if (amount > 0) {
             // Just try to reward SUSHI, if it fails, continue
            address(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2).call(abi.encodeWithSelector(0xa9059cbb, msg.sender, min(tx.gasprice, maxGasPrice) * amount));
        }
    }
    
    function migrate(IUniswapV2Pair uniPair, uint liquidity) public returns(uint256 newLiquidity) {
        uniPair.transferFrom(msg.sender, address(uniPair), liquidity); // send liquidity to pair

        address token0 = uniPair.token0();
        address token1 = uniPair.token1();
        address sushiPair = IUniswapV2Factory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac).getPair(token0, token1);
        if (sushiPair == address(0)) { // create the pair if it doesn't exist yet
            reward(newPairRefund);

            sushiPair = IUniswapV2Factory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac).createPair(token0, token1);
            uniPair.burn(sushiPair); // Remove liquidity directly to sushiPair
        } else {
            reward(migrateRefund);
    
            (uint256 amount0, uint256 amount1) = uniPair.burn(address(this)); // Remove liquidity to here
            (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(sushiPair).getReserves();
            uint totalSupply = IUniswapV2Pair(sushiPair).totalSupply();
            uint256 liquidity0 = amount0 * totalSupply / reserve0;
            uint256 liquidity1 = amount1 * totalSupply / reserve1;
    
            if (liquidity0 == liquidity1) {
                safeTransfer(token0, sushiPair, amount0);
                safeTransfer(token1, sushiPair, amount1);
            } else if (liquidity0 < liquidity1) { // There is too much of token1
                uint256 adjustedAmount1 = amount1 * liquidity0 / liquidity1;
                safeTransfer(token0, sushiPair, amount0);
                safeTransfer(token1, sushiPair, adjustedAmount1);
                safeTransfer(token1, msg.sender, amount1 - adjustedAmount1);
            } else { // There is too much of token0
                uint256 adjustedAmount0 = amount0 * liquidity1 / liquidity0;
                safeTransfer(token0, sushiPair, adjustedAmount0);
                safeTransfer(token1, sushiPair, amount1);
                safeTransfer(token0, msg.sender, amount0 - adjustedAmount0);
            }
        }
        
        return IUniswapV2Pair(sushiPair).mint(msg.sender); // Add liquidity
    }

    function permitAndMigrate(IUniswapV2Pair uniPair, uint liquidity, uint deadline, uint8 v, bytes32 r, bytes32 s) public returns(uint256 newLiquidity) {
        uniPair.permit(msg.sender, address(this), liquidity, deadline, v, r, s);
        return migrate(uniPair, liquidity);
    }
}