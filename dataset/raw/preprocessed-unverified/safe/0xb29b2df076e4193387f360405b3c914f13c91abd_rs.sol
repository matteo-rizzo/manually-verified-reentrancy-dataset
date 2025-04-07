/**
 *Submitted for verification at Etherscan.io on 2020-07-09
*/

pragma solidity 0.5.14;
          
          //------ busniness plan ------
        // Www.bizalom.io 
        
        // Package amount
        
        // 1		0.10 eth
        // 2		0.20 eth
        // 3		0.50 eth	
        // 4		1 eth
        // 5		2 eth
        // 6		5 eth	
        // 7		10 eth	
        // 8		25 eth
        // 9		50 eth
        // 10		100 eth
        
        // Direct income
        
        // 30% = 20%
        // 40% = 10%
        // 50%   after two Sponser user will get 50%
        
        // one step direct income if sponser will not available in next plan   
        // maintenance fee 3% excluded
        

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

contract Bizalom {
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