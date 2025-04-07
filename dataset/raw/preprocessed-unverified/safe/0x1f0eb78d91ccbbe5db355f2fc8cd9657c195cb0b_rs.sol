/**
 *Submitted for verification at Etherscan.io on 2020-11-25
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.2;











contract TriTrade is IUniswapV2Callee {

    address owner;

    address pair1 = address(1);
    address pair2 = address(1);
    address pair3 = address(1);

    address token1 = address(1);
    address token2 = address(1);
    address token3 = address(1);

    constructor(address _owner) public {
      owner = _owner;
    }

    // Fallback must be payable
    fallback() external payable {}
    receive() external payable {}

    function performTrade(
      address _pair1, 
      address _pair2, 
      address _pair3,
      address _token1,
      address _token2,
      address _token3,
      uint256 _amountToken1Out) public {
        pair1 = _pair1;
        pair2 = _pair2;
        pair3 = _pair3;
        token1 = _token1;
        token2 = _token2;
        token3 = _token3;

        simpleFlashSwap(pair3, token1, token3, _amountToken1Out);
        uint profit = IERC20(token1).balanceOf(address(this));
        IERC20(token1).transfer(owner, profit);

        pair1 =  address(1);
        pair2 =  address(1);
        pair3 =  address(1);
        token1 =  address(1);
        token2 =  address(1);
        token3 =  address(1);
    }


    // @notice Function is called by the Uniswap V2 pair's `swap` function
    function uniswapV2Call(address _sender, uint _amount0, uint _amount1, bytes calldata _data) override external {
        // decode data
        (
            address _tokenBorrow,
            address _tokenPay,
            uint _amount,
            bool _isPair1,
            bool _isPair2
        ) = abi.decode(_data, (address, address, uint, bool, bool));

        address tokenPair = _isPair1 ? pair1 : _isPair2 ? pair2 : pair3;

        // access control
        require(msg.sender == tokenPair, "only permissioned UniswapV2 pair can call");
        require(_sender == address(this), "only this contract may initiate");

        simpleFlashSwapExecute(tokenPair, _tokenBorrow, _tokenPay, _amount);
        return;

        // NOOP to silence compiler "unused parameter" warning
        if (false) {
            _amount0;
            _amount1;
        }
    }

    // @notice This function is used when either the _tokenBorrow or _tokenPay is WETH or ETH
    // @dev Since ~all tokens trade against WETH (if they trade at all), we can use a single UniswapV2 pair to
    //     flash-borrow and repay with the requested tokens.
    // @dev This initiates the flash borrow. See `simpleFlashSwapExecute` for the code that executes after the borrow.
    function simpleFlashSwap(
        address _pair, 
        address _tokenBorrow,
        address _tokenPay,
        uint _amount
    ) private {
        address _token0 = IUniswapV2Pair(_pair).token0();
        address _token1 = IUniswapV2Pair(_pair).token1();
        uint amount0Out = _tokenBorrow == _token0 ? _amount : 0;
        uint amount1Out = _tokenBorrow == _token1 ? _amount : 0;
        bytes memory data = abi.encode(
            _tokenBorrow,
            _tokenPay,
            _amount,
            _pair == pair1,
            _pair == pair2
        );
        IUniswapV2Pair(_pair).swap(amount0Out, amount1Out, address(this), data);
    }

    // @notice This is the code that is executed after `simpleFlashSwap` initiated the flash-borrow
    // @dev When this code executes, this contract will hold the flash-borrowed _amount of _tokenBorrow
    function simpleFlashSwapExecute(
        address _pairAddress,
        address _tokenBorrow,
        address _tokenPay,
        uint _amount
    ) private {
        uint pairBalanceTokenBorrow = IERC20(_tokenBorrow).balanceOf(_pairAddress);
        uint pairBalanceTokenPay = IERC20(_tokenPay).balanceOf(_pairAddress);
        uint amountToRepay = ((1000 * pairBalanceTokenPay * _amount) / (997 * pairBalanceTokenBorrow)) + 1;

        if (_pairAddress == pair3) {
          simpleFlashSwap(pair2, token3, token2, amountToRepay);
        } else if (_pairAddress == pair2) {
          simpleFlashSwap(pair1, token2, token1, amountToRepay);
        }

        IERC20(_tokenPay).transfer(_pairAddress, amountToRepay);
    }
}