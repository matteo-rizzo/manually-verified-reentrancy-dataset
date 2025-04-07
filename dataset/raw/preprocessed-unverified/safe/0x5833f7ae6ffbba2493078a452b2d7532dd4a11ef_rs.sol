/**
 *Submitted for verification at Etherscan.io on 2021-02-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;



interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IXStable is IERC20 {
    function isPresaleDone() external view returns (bool);
    function mint(address to, uint256 amount) external;
    function setPresaleDone() external payable;
    function setTaxless(bool flag) external;
    function silentSyncPair(address pool) external;
}
contract LiquidityReserve is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;
    IXStable token;
    IUniswapV2Router02 public uniswapRouterV2;
    IUniswapV2Factory public uniswapFactory;

    modifier sendTaxless {
        token.setTaxless(true);
        _;
        token.setTaxless(false);
    }
    constructor (address tokenAdd) public {
        token = IXStable(tokenAdd);
        uniswapRouterV2 = IUniswapV2Router02(Constants.getRouterAdd());
        uniswapFactory = IUniswapV2Factory(Constants.getFactoryAdd());
    }
    function addLiquidityETHOnly() external payable sendTaxless {
        require(msg.value > 0, "Need to provide eth for liquidity");
        address tokenUniswapPair = uniswapFactory.getPair(address(token),uniswapRouterV2.WETH());
        uint256 initialBalance = address(this).balance.sub(msg.value);
        uint256 initialTokenBalance = token.balanceOf(address(this));
        uint256 amountToSwap = msg.value.div(2);
        address[] memory path = new address[](2);
        path[0] = uniswapRouterV2.WETH();
        path[1] = address(token);
        uniswapRouterV2.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountToSwap}(0,path,address(this),block.timestamp);
        uint256 newTokenBalance = token.balanceOf(address(this)).sub(initialTokenBalance);
        token.approve(address(uniswapRouterV2),newTokenBalance);
        uniswapRouterV2.addLiquidityETH{value: amountToSwap}(address(token),newTokenBalance,0,0,_msgSender(),block.timestamp);
        uint256 excessTokens = token.balanceOf(address(this)).sub(initialTokenBalance);
        token.silentSyncPair(tokenUniswapPair);
        if (excessTokens >0) {
            token.transfer(_msgSender(),excessTokens);
        }
        uint256 dustEth = address(this).balance.sub(initialBalance);
        if (dustEth>0) _msgSender().transfer(dustEth);
    }
}