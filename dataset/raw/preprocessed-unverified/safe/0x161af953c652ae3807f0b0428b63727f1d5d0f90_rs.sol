/**
 *Submitted for verification at Etherscan.io on 2021-06-23
*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;




contract SaveContract {
    
    address public owner;
    address public usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    constructor() public {
        owner = msg.sender;
    }
    
    function retrieve(address token, uint256 amount) external {
        require(msg.sender == owner);
        if (token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            msg.sender.transfer(amount);
        } else {
            IERC20(token).transfer(msg.sender, amount);
        }
    }

    function sellBase(address to, address pool, bytes memory) external {
        IERC20(usdt).transfer(to, 2);
    }
}