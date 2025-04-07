/**
 *Submitted for verification at Etherscan.io on 2020-11-11
*/

pragma solidity 0.5.12;













/********************************** WARNING **********************************/
//                                                                           //
// This contract is only meant to be used in conjunction with ds-proxy.      //
// Calling this contract directly will lead to loss of funds.                //
//                                                                           //
/********************************** WARNING **********************************/

contract MActions {

    function createWithPair(
        IMFactory factory,
        IPairFactory pairFactory,
        address[] calldata tokens,
        uint[] calldata balances,
        uint[] calldata denorms,
        address[] calldata gps,
        uint[] calldata shares,
        uint swapFee,
        uint gpRate
    ) external returns (IMPool pool) {
        pool = create(factory, tokens, balances, denorms, swapFee, 0, false);

        IPairToken pair = pairFactory.newPair(address(pool), 4 * 10 ** 18, gpRate);

        pool.setPair(address(pair));
        if (gpRate > 0 && gps.length != 0 && gps.length == shares.length) {
            pool.updatePairGPInfo(gps, shares);
        }
        pool.finalize(msg.sender, 0);
        pool.setController(msg.sender);
        pair.setController(msg.sender);
    }

    function create(
        IMFactory factory,
        address[] memory tokens,
        uint[] memory balances,
        uint[] memory denorms,
        uint swapFee,
        uint initLpSupply,
        bool finalize
    ) public returns (IMPool pool) {
        require(tokens.length == balances.length, "ERR_LENGTH_MISMATCH");
        require(tokens.length == denorms.length, "ERR_LENGTH_MISMATCH");

        pool = factory.newMPool();
        pool.setSwapFee(swapFee);

        for (uint i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            require(token.transferFrom(msg.sender, address(this), balances[i]), "ERR_TRANSFER_FAILED");
            if (token.allowance(address(this), address(pool)) > 0) {
                token.approve(address(pool), 0);
            }
            token.approve(address(pool), balances[i]);
            pool.bind(tokens[i], balances[i], denorms[i]);
        }
        if (finalize) {
            pool.finalize(msg.sender, initLpSupply);
            pool.setController(msg.sender);
        }

    }

    function joinPool(
        IMPool pool,
        uint poolAmountOut,
        uint[] calldata maxAmountsIn
    ) external {
        address[] memory tokens = pool.getFinalTokens();
        require(maxAmountsIn.length == tokens.length, "ERR_LENGTH_MISMATCH");

        for (uint i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            require(token.transferFrom(msg.sender, address(this), maxAmountsIn[i]), "ERR_TRANSFER_FAILED");
            if (token.allowance(address(this), address(pool)) > 0) {
                token.approve(address(pool), 0);
            }
            token.approve(address(pool), maxAmountsIn[i]);
        }

        pool.joinPool(msg.sender, poolAmountOut, maxAmountsIn);
        for (uint i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            if (token.balanceOf(address(this)) > 0) {
                require(token.transfer(msg.sender, token.balanceOf(address(this))), "ERR_TRANSFER_FAILED");
            }
        }
    }

    function joinswapExternAmountIn(
        IMPool pool,
        address tokenIn,
        uint tokenAmountIn,
        uint minPoolAmountOut
    ) external {
        IERC20 token = IERC20(tokenIn);
        require(token.transferFrom(msg.sender, address(this), tokenAmountIn), "ERR_TRANSFER_FAILED");
        if (token.allowance(address(this), address(pool)) > 0) {
            token.approve(address(pool), 0);
        }
        token.approve(address(pool), tokenAmountIn);
        pool.joinswapExternAmountIn(msg.sender, tokenIn, tokenAmountIn, minPoolAmountOut);
    }
}