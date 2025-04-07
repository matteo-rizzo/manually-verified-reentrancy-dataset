/**
 *Submitted for verification at Etherscan.io on 2020-07-06
*/

pragma solidity 0.5.14;
          
          //------ busniness plan ------

                // www.etherbase.io         
                
                // level 1 = 0.1ETH,    
                // level 2 = 0.2 ETH,     
                // Level 3 =  0.5 ETH,     
                // Level 4 = 2 ETH ,      
                // Leval 5 = 16 ETH,         
                // Level 6 = 32 ETH,          
                // Level 7 =  64 ETH,          
                // Level 8 =  100 ETH
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

contract EtherBase {
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