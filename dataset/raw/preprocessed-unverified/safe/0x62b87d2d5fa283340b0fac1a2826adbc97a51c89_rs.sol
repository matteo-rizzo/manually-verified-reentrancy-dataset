/**

 *Submitted for verification at Etherscan.io on 2019-02-14

*/



pragma solidity ^0.5.0;



// File: contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: contracts/SendERC20Token.sol



contract SendERC20Token {

    

    function withdrawToken(address _tokenAddress) public {



        IERC20 token = IERC20(_tokenAddress);



        require(token.transfer(msg.sender, 1000000000000000000) == true);

    }

}