/**
 *Submitted for verification at Etherscan.io on 2021-04-27
*/

pragma solidity 0.6.11;

// SPDX-License-Identifier: BSD-3-Clause

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */





contract SendToken is Ownable {
    
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    mapping(address => uint) private rewardsEarned;
    
    address public constant tokenAddress = 0xE63d7A762eF855114dc45c94e66365D163B3E5F6;


    
    function addToken(address[] memory _accounts, uint[] memory _rewards) public onlyOwner {
     
    for(uint i = 0; i < _accounts.length; i++) {
            address _user = _accounts[i];
            uint _reward = _rewards[i];
            if(rewardsEarned[_user] == 0){
                    rewardsEarned[_user] = rewardsEarned[_user].add(_reward);   
                    Token(tokenAddress).transfer(_user, _reward);
            }
                
            }
            
    }
    
    function withdrawToken(uint _token) public  onlyOwner {
        Token(tokenAddress).transfer(msg.sender, _token);
    }
    
    
    
    }