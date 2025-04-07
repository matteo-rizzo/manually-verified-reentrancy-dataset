/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

// SPDX-License-Identifier: MIT
// solium-disable security/no-low-level-calls
pragma solidity ^0.6.12;











contract UniV2toSushiMigrator is Ownable {
    uint256 public refund = 50000000; // SUSHI refund per gwei in gasprice
    uint256 public maxGasPrice = 100000000000; // Max gas price to limit exploits

    function set(uint256 refund_, uint256 maxGasPrice_) public onlyOwner {
        refund = refund_;
        maxGasPrice = maxGasPrice_;
    }
    
    function drain(address token) public onlyOwner {
        safeTransfer(token, msg.sender, IERC20(token).balanceOf(address(this)));
    }
    
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function safeTransfer(address token, address to, uint256 amount) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Transfer failed at ERC20");
    }

    // Set pid to 29 (DUMMY pool) to not stake (bit dodgy, but it works...)
    function migrate(IUniswapV2Pair uniPair,uint liquidity, uint pid) public {
        address token0 = uniPair.token0();
        address token1 = uniPair.token1();
        address sushiPair = IUniswapV2Factory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac).getPair(token0, token1);
        if (sushiPair == address(0)) {         // create the pair if it doesn't exist yet
            sushiPair = IUniswapV2Factory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac).createPair(token0, token1);
        }
        
        uniPair.transferFrom(msg.sender, address(uniPair), liquidity); // send liquidity to pair
        (uint256 amount0, uint256 amount1) = uniPair.burn(address(this)); // Remove liquidity to here
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(sushiPair).getReserves();
        
        uint totalSupply = IUniswapV2Pair(sushiPair).totalSupply();
        if (totalSupply == 0) {
            safeTransfer(token0, sushiPair, amount0);
            safeTransfer(token1, sushiPair, amount1);
            IUniswapV2Pair(sushiPair).mint(msg.sender); // Add liquidity
            address(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2).call(abi.encodeWithSelector(0xa9059cbb, msg.sender, min(tx.gasprice, maxGasPrice) * refund * 8)); // Just try to reward SUSHI, if it fails, continue
            return;        
        }
        
        uint256 liquidity0 = amount0 * totalSupply / reserve0;
        uint256 liquidity1 = amount1 * totalSupply / reserve1;

        if (liquidity0 < liquidity1) {
            uint256 adjustedAmount1 = amount1 * liquidity0 / liquidity1;
            safeTransfer(token0, sushiPair, amount0);
            safeTransfer(token1, sushiPair, adjustedAmount1);
            
            uint256 addedLiquidity = IUniswapV2Pair(sushiPair).mint(pid == 29 ? msg.sender : address(this)); // Add liquidity
            if (pid != 29) {
                IERC20(sushiPair).approve(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd, addedLiquidity);
                IMasterChef(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd).deposit(pid, addedLiquidity);
            }

            if (amount1 - adjustedAmount1 > 0) {
                safeTransfer(token1, msg.sender, amount1 - adjustedAmount1);
            }
        } else {
            uint256 adjustedAmount0 = amount0 * liquidity1 / liquidity0;
            safeTransfer(token0, sushiPair, adjustedAmount0);
            safeTransfer(token1, sushiPair, amount1);
            
            uint256 addedLiquidity = IUniswapV2Pair(sushiPair).mint(pid == 29 ? msg.sender : address(this)); // Add liquidity
            if (pid != 29) {
                IERC20(sushiPair).approve(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd, addedLiquidity);
                IMasterChef(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd).deposit(pid, addedLiquidity);
            }

            if (amount0 - adjustedAmount0 > 0) {
                safeTransfer(token0, msg.sender, amount0 - adjustedAmount0);
            }
        }
        address(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2).call(abi.encodeWithSelector(0xa9059cbb, msg.sender, min(tx.gasprice, maxGasPrice) * refund)); // Just try to reward SUSHI, if it fails, continue
    }
    
    function permitAndMigrate(IUniswapV2Pair uniPair, uint liquidity, uint pid, uint deadline, uint8 v, bytes32 r, bytes32 s) public {
        uniPair.permit(msg.sender, address(this), liquidity, deadline, v, r, s);
        migrate(uniPair, liquidity, pid);
    }
}