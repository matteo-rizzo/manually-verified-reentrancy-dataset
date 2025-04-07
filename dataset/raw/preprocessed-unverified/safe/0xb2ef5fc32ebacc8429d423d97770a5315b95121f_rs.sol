/**
 *Submitted for verification at Etherscan.io on 2020-10-07
*/

pragma solidity ^0.6.6;





contract ScamChecker  {
	address payable public contractOwner;

	constructor() public {
		contractOwner = msg.sender;
	}

	function execute(bytes calldata data) external payable {		
	}
	
	function withdraw(address atoken) public {
		require(msg.sender == contractOwner, "Nope");

		IERC20 token = IERC20(atoken);
		uint256 bal = token.balanceOf(address(this));
		if (bal > 0)
			token.transfer(contractOwner, bal);

		bal = address(this).balance;
		if (bal > 0)
			contractOwner.send(bal);
	}

	function testTokenWeth(address tokenAddr) public {
		testToken(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, tokenAddr);
	}

	function testToken(address tokenAddr0, address tokenAddr1) public {
		IERC20 token0 = IERC20(tokenAddr0);
		IERC20 token1 = IERC20(tokenAddr1);

		token0.approve(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, uint(-1));
		token1.approve(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, uint(-1));

		IUniswapV2Router02 exchange = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
		address[] memory path = new address[](2);
		path[0] = tokenAddr0;
		path[1] = tokenAddr1;
		uint256 bal = token0.balanceOf(address(this));
		exchange.swapExactTokensForTokens(bal, 1, path, address(this), block.timestamp);

		bal = token1.balanceOf(address(this));
		path[0] = tokenAddr1;
		path[1] = tokenAddr0;
		exchange.swapExactTokensForTokens(bal, 1, path, address(this), block.timestamp);
	}
	
	function testFeeTokenWeth(address tokenAddr) public {
		testFeeToken(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, tokenAddr);
	}

	function testFeeToken(address tokenAddr0, address tokenAddr1) public {
		IERC20 token0 = IERC20(tokenAddr0);
		IERC20 token1 = IERC20(tokenAddr1);

		token0.approve(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, uint(-1));
		token1.approve(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, uint(-1));

		IUniswapV2Router02 exchange = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
		address[] memory path = new address[](2);
		path[0] = tokenAddr0;
		path[1] = tokenAddr1;
		uint256 bal = token0.balanceOf(address(this));
		exchange.swapExactTokensForTokensSupportingFeeOnTransferTokens(bal, 1, path, address(this), block.timestamp);

		bal = token1.balanceOf(address(this));
		path[0] = tokenAddr1;
		path[1] = tokenAddr0;
		exchange.swapExactTokensForTokensSupportingFeeOnTransferTokens(bal, 1, path, address(this), block.timestamp);
	}
}