/**
 *Submitted for verification at Etherscan.io on 2021-05-13
*/

pragma solidity =0.6.6;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */







contract bcMarket is Ownable{
    using SafeMath for uint;

    uint oneUsdg = 1000000000;
    uint8  public rate = 100;

    address[] pathUsdg2Bc;
    IUniswapV2Router01 public uniswapRouter;

    constructor(address _usdg, address _bc, address _uniswap)public {
        _setPath(_usdg,_bc,_uniswap);
    }

    function _setPath(address _usdg, address _bc,address _uniswap)private {
        uniswapRouter = IUniswapV2Router01(_uniswap);
        pathUsdg2Bc.push(_usdg);
        pathUsdg2Bc.push(_bc);
    }

    function getUniOutput(uint _input, address _token1, address _token2)public view returns (uint) {
        address[] memory paths = new address[](2);
        paths[0] = _token1;
        paths[1] = _token2;
        uint[] memory amounts = uniswapRouter.getAmountsOut( _input, paths);
        return amounts[1];
    }

    function usdgToBc() external view returns (uint){
        uint[] memory amounts = uniswapRouter.getAmountsOut( oneUsdg, pathUsdg2Bc);
        uint rs =  amounts[1];
        if(rate != 100){
            rs = rs.mul(rate).div(100);
        }
        return rs;
    }

    function changeRates(uint8 _rate)onlyOwner public {
        require(201 > _rate, "_rate big than 200");
        rate = _rate;
    }

}