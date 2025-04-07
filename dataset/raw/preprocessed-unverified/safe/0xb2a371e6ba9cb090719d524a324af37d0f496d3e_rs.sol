/**
 *Submitted for verification at Etherscan.io on 2020-07-12
*/

pragma solidity 0.5.14;
          
          //------ busniness plan ------
        
        //       https://www.libaax.io
            
            // Level 1 : 0.05 ETH
            
            // Level 2 :0.10 ETH
            
            // Level 3 :0.25 ETH
            
            // Level 4 :0.50 ETH
            
            // Level 5 :1 ETH
            
            // Level 6 :5 ETH
            
            // Level 7 :8 ETH
            
            // Level 8 :16 ETH
            
            // Level 9 :32 ETH
            
            // Level 10 :64 ETH
        

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

contract Libaax {
    event Multisended(uint256 value , address sender);
    using SafeMath for uint256;

    function multisendEther(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
        emit Multisended(msg.value, msg.sender);
    }
}