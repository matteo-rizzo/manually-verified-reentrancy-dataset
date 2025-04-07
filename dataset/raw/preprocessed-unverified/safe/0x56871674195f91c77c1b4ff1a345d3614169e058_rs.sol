/**
 *Submitted for verification at Etherscan.io on 2021-02-06
*/

// SPDX-License-Identifier: GPL
pragma solidity 0.6.12;







interface IGraSwapToken is IERC20, IGraSwapBlackList, IGraWhiteList{
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    // function multiTransfer(uint256[] calldata mixedAddrVal) external returns (bool);
    function batchTransfer(address[] memory addressList, uint256[] memory amountList) external returns (bool);
}







contract GraSwapBuyback is IGraSwapBuyback {

    uint256 private constant _MAX_UINT256 = uint256(-1); 
    address private constant _ETH = address(0);

    address public immutable override graContract;
    address public immutable override router;
    address public immutable override factory;

    mapping (address => bool) private _mainTokens;
    address[] private _mainTokenArr;

    constructor(address _graContract, address _router, address _factory) public {
        graContract = _graContract;
        router = _router;
        factory = _factory;

        // add ETH & GraS to main token list
        _mainTokens[_ETH] = true;
        _mainTokenArr.push(_ETH);
        _mainTokens[_graContract] = true;
        _mainTokenArr.push(_graContract);
    }

    receive() external payable { }

    // add token into main token list
    function addMainToken(address token) external override {
        require(msg.sender == IGraSwapToken(graContract).owner(), "GraSwapBuyback: NOT_Gra_OWNER");
        if (!_mainTokens[token]) {
            _mainTokens[token] = true;
            _mainTokenArr.push(token);
        }
    }
    // remove token from main token list
    function removeMainToken(address token) external override {
        require(msg.sender == IGraSwapToken(graContract).owner(), "GraSwapBuyback: NOT_Gra_OWNER");
        require(token != _ETH, "GraSwapBuyback: REMOVE_ETH_FROM_MAIN");
        require(token != graContract, "GraSwapBuyback: REMOVE_Gra_FROM_MAIN");
        if (_mainTokens[token]) {
            _mainTokens[token] = false;
            uint256 lastIdx = _mainTokenArr.length - 1;
            for (uint256 i = 2; i < lastIdx; i++) { // skip ETH & Gra
                if (_mainTokenArr[i] == token) {
                    _mainTokenArr[i] = _mainTokenArr[lastIdx];
                    break;
                }
            }
            _mainTokenArr.pop();
        }
    }
    // check if token is in main token list
    function isMainToken(address token) external view override returns (bool) {
        return _mainTokens[token];
    }
    // query main token list
    function mainTokens() external view override returns (address[] memory list) {
        list = _mainTokenArr;
    }

    // remove Buyback's liquidity from all pairs
    // swap got minor tokens for main tokens if possible
    function removeLiquidity(address[] calldata pairs) external override {
        for (uint256 i = 0; i < pairs.length; i++) {
            _removeLiquidity(pairs[i]);
        }
    }
    function _removeLiquidity(address pair) private {
        (address a, address b) = IGraSwapFactory(factory).getTokensFromPair(pair);
        require(a != address(0) || b != address(0), "GraSwapBuyback: INVALID_PAIR");

        uint256 amt = IERC20(pair).balanceOf(address(this));
        // require(amt > 0, "GraSwapBuyback: NO_LIQUIDITY");
        if (amt == 0) { return; }

        IERC20(pair).approve(router, 0);
        IERC20(pair).approve(router, amt);
        IGraSwapRouter(router).removeLiquidity(
            pair, amt, 0, 0, address(this), _MAX_UINT256);

        // minor -> main
        bool aIsMain = _mainTokens[a];
        bool bIsMain = _mainTokens[b];
        if ((aIsMain && !bIsMain) || (!aIsMain && bIsMain)) {
            _swapForMainToken(pair);
        }
    }

    // swap minor tokens for main tokens
    function swapForMainToken(address[] calldata pairs) external override {
        for (uint256 i = 0; i < pairs.length; i++) {
            _swapForMainToken(pairs[i]);
        }
    }
    function _swapForMainToken(address pair) private {
        (address a, address b) = IGraSwapFactory(factory).getTokensFromPair(pair);
        require(a != address(0) || b != address(0), "GraSwapBuyback: INVALID_PAIR");

        address mainToken;
        address minorToken;
        if (_mainTokens[a]) {
            require(!_mainTokens[b], "GraSwapBuyback: SWAP_TWO_MAIN_TOKENS");
            (mainToken, minorToken) = (a, b);
        } else {
            require(_mainTokens[b], "GraSwapBuyback: SWAP_TWO_MINOR_TOKENS");
            (mainToken, minorToken) = (b, a);
        }

        uint256 minorTokenAmt = IERC20(minorToken).balanceOf(address(this));
        // require(minorTokenAmt > 0, "GraSwapBuyback: NO_MINOR_TOKENS");
        if (minorTokenAmt == 0) { return; }

        address[] memory path = new address[](1);
        path[0] = pair;

        // minor -> main
        IERC20(minorToken).approve(router, 0);
        IERC20(minorToken).approve(router, minorTokenAmt);
        IGraSwapRouter(router).swapToken(
            minorToken, minorTokenAmt, 0, path, address(this), _MAX_UINT256);
    }

    // swap main tokens for Gras, then burn all Gras
    function swapForGrasAndBurn(address[] calldata pairs) external override {
        for (uint256 i = 0; i < pairs.length; i++) {
            _swapForGras(pairs[i]);
        }

        // burn all Gras
        uint256 allGras = IERC20(graContract).balanceOf(address(this));
        if (allGras == 0) { return; }
        IGraSwapToken(graContract).burn(allGras);
        emit BurnGras(allGras);
    }
    function _swapForGras(address pair) private {
        (address a, address b) = IGraSwapFactory(factory).getTokensFromPair(pair);
        require(a != address(0) || b != address(0), "GraSwapBuyback: INVALID_PAIR");
        require(a == graContract || b == graContract, "GraSwapBuyback: GraS_NOT_IN_PAIR");

        address token = (a == graContract) ? b : a;
        require(_mainTokens[token], "GraSwapBuyback: MAIN_TOKEN_NOT_IN_PAIR");

        address[] memory path = new address[](1);
        path[0] = pair;

        if (token == _ETH) { // eth -> Gras
            uint256 ethAmt = address(this).balance;
            // require(ethAmt > 0, "GraSwapBuyback: NO_ETH");
            if (ethAmt == 0) { return; }

            IGraSwapRouter(router).swapToken{value: ethAmt}(
                _ETH, ethAmt, 0, path, address(this), _MAX_UINT256);
        } else { // main token -> Gras
            uint256 tokenAmt = IERC20(token).balanceOf(address(this));
            // require(tokenAmt > 0, "GraSwapBuyback: NO_MAIN_TOKENS");
            if (tokenAmt == 0) { return; }

            IERC20(token).approve(router, 0);
            IERC20(token).approve(router, tokenAmt);
            IGraSwapRouter(router).swapToken(
                token, tokenAmt, 0, path, address(this), _MAX_UINT256);
        }
    }

}