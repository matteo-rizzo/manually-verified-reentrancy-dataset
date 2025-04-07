/**
 *Submitted for verification at Etherscan.io on 2020-08-03
*/

pragma solidity 0.5.14;
          
        
        // www.therapidmoney.com
        
              
/**     
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

contract TheRapidMoney {
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