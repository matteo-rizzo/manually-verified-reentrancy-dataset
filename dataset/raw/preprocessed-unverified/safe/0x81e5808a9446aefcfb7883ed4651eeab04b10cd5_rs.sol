/**
 *Submitted for verification at Etherscan.io on 2020-07-15
*/

pragma solidity 0.5.14;
          
          //------ busniness plan ------
        
            //      Startup-0.1 eth
           
            // växalium v3/ växalium v4                
            // 1 - 0.05              1 - 0.05
            // 2 - 0.1                2 - 0.1
            // 3 - 0.2           3 - 0.2
            // 4 - 0.4          4 - 0.4
            // 5 - 0.8           5 - 0.8
            // 6 - 1.6           6 - 1.6
            // 7 - 3.2            7 - 3.2
            // 8 - 6.4             8 - 6.4
            // 9 - 12.4            9 - 12.4
            // 10 - 25.6         10 - 25.6
            // Maintenance charge :- 10%
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

contract Vaxalium {
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