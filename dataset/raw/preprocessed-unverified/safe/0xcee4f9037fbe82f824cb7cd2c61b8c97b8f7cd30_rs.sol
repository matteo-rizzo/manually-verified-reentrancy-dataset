/**
 *Submitted for verification at Etherscan.io on 2021-03-23
*/

pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;





















/**
 * @dev Collection of functions related to the address type
 */





contract DaiCrv is Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    mapping(address=>bool) administrators;
    
    modifier onlyAdmin() {
        require(owner == msg.sender || administrators[msg.sender] == true, "Admin: caller is not admin or owner");
        _;
    }
 
    UniswapProxy constant uniswapRouter = UniswapProxy(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );

    UniswapFactory constant uniswapFactory = UniswapFactory(
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    );

    /* Direccion de WETH */
    address private constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    /* Direccion de DAI */
    address private constant dai  = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    
    /* Direccion de CRV */
    address private constant crv  = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    
    address private constant crvCompound = 0xeB21209ae4C2c9FF2a86ACA31E123764A3B6Bc06;
    address private constant crvMinter = 0xd061D61a4d941c39E5453435B6345Dc261C2fcE0;
    address private constant crvCompoundGauge = 0x7ca5b0a2910B33e9759DC7dDB0413949071D7575;
    
    address private constant crvcDaicUsdc = 0x845838DF265Dcd2c412A1Dc9e959c7d08537f8a2;
    
    uint256 private constant deadline = 0xf000000000000000000000000000000000000000000000000000000000000000;
    uint256 private constant max = uint256(-1);


    uint256 public dai_invested;
    uint256 public dai_divested;

    function changeOwner(address payable _newowner) external onlyOwner {
        owner = _newowner;
    }

    function addAdmin(address _admin) external onlyOwner { 
        administrators[_admin] = true;
    }
    
    function removeAdmin(address _admin) external onlyOwner {
        administrators[_admin] = false;
    }


    function approves() external onlyOwner {
        require(IERC20(dai).approve(crvCompound, max), "Unable o approve dai");
        require(IERC20(crvcDaicUsdc).approve(crvCompoundGauge, max), "Unable to approve cDai + cUsdc to Gauge");
        require(IERC20(crvcDaicUsdc).approve(crvCompound, max), "Unable to approve cDai + cUsdc to crvCompound");
    }


    event CallerRespose(
        bool success
    );

    /* 
       1- Hace el Claim de los CRV
       2- Transforma los CRV en DAI utilizando Uniswap
       3- Invierte nuevamente los DAI
    */
    
    function loop() external onlyAdmin {
        loop_internal();
    }
    
    function loop_internal() internal {
        uint256 daiToInvest = claimAndSwap();
        
        if (daiToInvest > 0) {
            invest_balance();
        }
    }

    
    function invest_balance() internal returns(uint256) {
        uint256[2] memory amounts;
        uint256 lp_balance;
        uint256 amount = IERC20(dai).balanceOf(address(this));
        
        dai_invested = dai_invested + amount;
        
         /* Solamente se permite invertir DAI */
        amounts[0] = amount;
        amounts[1] = 0;
    
        /* Agrega liquidez */
        CurveZap(crvCompound).add_liquidity(amounts, 1);

        /* Consulta los LP resultantes de proveer liquidez cDAI+cUSDC */
        lp_balance = IERC20(crvcDaicUsdc).balanceOf(address(this));

        /* Hace el stake */
        CurveGauge(crvCompoundGauge).deposit(lp_balance);

        return amount;
    }

    function invest(uint256 amount) external onlyAdmin {
        uint256 invested;
        require(IERC20(dai).transferFrom(msg.sender, address(this), amount), "Unable to transferFrom");
        invested = invest_balance();
    }


    function divest_all() external onlyAdmin {
        uint256 _balance;
        claimAndSwap();
        
        _balance = CurveGauge(crvCompoundGauge).balanceOf(address(this));
        CurveGauge(crvCompoundGauge).withdraw(_balance);
        CurveZap(crvCompound).remove_liquidity_one_coin(_balance, 0, _balance);

        _balance = IERC20(dai).balanceOf(address(this));
        dai_divested = dai_divested + _balance;
        require(IERC20(dai).transfer(msg.sender, _balance), "Unable to send founds");
        
    }

    function divest_ratio(uint256 ratio, bool claim_and_invest) external onlyAdmin {
        uint256 _balance;
        
        require(ratio > 0 && ratio <= 100, "Invalid ratio");
        
        if (claim_and_invest == true) {
            loop_internal();
        }
        
        _balance = CurveGauge(crvCompoundGauge).balanceOf(address(this));
        
        _balance = ratio * _balance / 100;
        
        CurveGauge(crvCompoundGauge).withdraw(_balance);
        CurveZap(crvCompound).remove_liquidity_one_coin(_balance, 0, _balance);

        _balance = IERC20(dai).balanceOf(address(this));
        dai_divested = dai_divested + _balance;
        require(IERC20(dai).transfer(msg.sender, _balance), "Unable to send founds");
        
    }


    function balance() external view returns(uint256) {
      return CurveGauge(crvCompoundGauge).balanceOf(address(this));
    }


    function claimAndSwap() internal returns(uint256) {
        uint256 crvBalance;

        /* Hace el claim */
        CurveMinter(crvMinter).mint(crvCompoundGauge);
        
        /* Consultamos el balance */
        crvBalance = IERC20(crv).balanceOf(address(this));

        if (crvBalance > 0) {
            /* Transforma el crv en dai */            
            return _token2Token(crv, dai, crvBalance);
        }
        return 0;
    }


    function _token2Token(
        address _FromTokenContractAddress,
        address _ToTokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 tokenBought) {
        if (_FromTokenContractAddress == _ToTokenContractAddress) {
            return tokens2Trade;
        }

        if (_FromTokenContractAddress == address(0)) {
            if (_ToTokenContractAddress == weth) {
                IWETH(weth).deposit{value:tokens2Trade}();
                return tokens2Trade;
            }

            address[] memory path = new address[](2);
            path[0] = weth;
            path[1] = _ToTokenContractAddress;
            tokenBought = uniswapRouter.swapExactETHForTokens{value:
                tokens2Trade
            }(1, path, address(this), deadline)[path.length - 1];
        } else if (_ToTokenContractAddress == address(0)) {
            if (_FromTokenContractAddress == weth) {
                IWETH(weth).withdraw(tokens2Trade);
                return tokens2Trade;
            }

            IERC20(_FromTokenContractAddress).approve(
                address(uniswapRouter),
                tokens2Trade
            );

            address[] memory path = new address[](2);
            path[0] = _FromTokenContractAddress;
            path[1] = weth;
            tokenBought = uniswapRouter.swapExactTokensForETH(
                tokens2Trade,
                1,
                path,
                address(this),
                deadline
            )[path.length - 1];
        } else {
            IERC20(_FromTokenContractAddress).approve(
                address(uniswapRouter),
                tokens2Trade
            );

            if (_FromTokenContractAddress != weth) {
                if (_ToTokenContractAddress != weth) {
                    // check output via tokenA -> tokenB
                    address pairA = uniswapFactory.getPair(
                        _FromTokenContractAddress,
                        _ToTokenContractAddress
                    );
                    address[] memory pathA = new address[](2);
                    pathA[0] = _FromTokenContractAddress;
                    pathA[1] = _ToTokenContractAddress;
                    uint256 amtA;
                    if (pairA != address(0)) {
                        amtA = uniswapRouter.getAmountsOut(
                            tokens2Trade,
                            pathA
                        )[1];
                    }

                    // check output via tokenA -> weth -> tokenB
                    address[] memory pathB = new address[](3);
                    pathB[0] = _FromTokenContractAddress;
                    pathB[1] = weth;
                    pathB[2] = _ToTokenContractAddress;

                    uint256 amtB = uniswapRouter.getAmountsOut(
                        tokens2Trade,
                        pathB
                    )[2];

                    if (amtA >= amtB) {
                        tokenBought = uniswapRouter.swapExactTokensForTokens(
                            tokens2Trade,
                            1,
                            pathA,
                            address(this),
                            deadline
                        )[pathA.length - 1];
                    } else {
                        tokenBought = uniswapRouter.swapExactTokensForTokens(
                            tokens2Trade,
                            1,
                            pathB,
                            address(this),
                            deadline
                        )[pathB.length - 1];
                    }
                } else {
                    address[] memory path = new address[](2);
                    path[0] = _FromTokenContractAddress;
                    path[1] = weth;

                    tokenBought = uniswapRouter.swapExactTokensForTokens(
                        tokens2Trade,
                        1,
                        path,
                        address(this),
                        deadline
                    )[path.length - 1];
                }
            } else {
                address[] memory path = new address[](2);
                path[0] = weth;
                path[1] = _ToTokenContractAddress;
                tokenBought = uniswapRouter.swapExactTokensForTokens(
                    tokens2Trade,
                    1,
                    path,
                    address(this),
                    deadline
                )[path.length - 1];
            }
        }
        require(tokenBought > 0, "Error Swapping Tokens");
    }


    function withdrawToken(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.transfer(owner, qty);
    }

    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        address payable _to = owner;
        _to.transfer(contractBalance);
    }
    
    function caller(address _contract, bytes calldata _data) external onlyOwner {
        (bool success, bytes memory data) = _contract.call(_data);
        emit CallerRespose(success);
    }
    
}