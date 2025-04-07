/**
 *Submitted for verification at Etherscan.io on 2021-03-22
*/

/**
 *Submitted for verification at Etherscan.io on 2021-02-12
*/

/**
 *Submitted for verification at Etherscan.io on 2021-02-12
*/

/**
 *Submitted for verification at Etherscan.io on 2021-02-11
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: No License

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
    
    
    
    


    

    contract PredictzPoints is Ownable {
        using SafeMath for uint;
        using EnumerableSet for EnumerableSet.AddressSet;
        

        // PRDZ token contract address
        address public constant tokenAddress = 0x4e085036A1b732cBe4FfB1C12ddfDd87E7C3664d;
        

        mapping(address => uint) public unclaimed;
        
        mapping(address => uint) public claimed;
        
        event RewardAdded(address indexed user,uint amount ,uint time);
            
        event RewardClaimed(address indexed user, uint amount ,uint time );
    

        
        function addCashback(address _user , uint _amount ) public  onlyOwner returns (bool)   {

                    unclaimed[_user] =  unclaimed[_user].add(_amount) ;
                   
                    emit RewardAdded(_user,_amount,now);
                               
                    return true ;

        }


        function addCashbackBulk(address[] memory _users, uint[] memory _amount) public onlyOwner {
      
            for(uint i = 0; i < _users.length; i++) {
                address _user = _users[i];
                uint _reward = _amount[i];
                unclaimed[_user] =  unclaimed[_user].add(_reward) ;
                emit RewardAdded(_user,_reward,now);
            }
         
        }
        
        
        function claim() public returns (uint)  {
            
            require(unclaimed[msg.sender] > 0, "Cannot claim 0 or less");

            uint amount = unclaimed[msg.sender] ;
           
            Token(tokenAddress).transfer(msg.sender, amount);
           
          
            emit RewardClaimed(msg.sender,unclaimed[msg.sender],now);
            
            claimed[msg.sender] = claimed[msg.sender].add(unclaimed[msg.sender]) ;
            
            unclaimed[msg.sender] =  0 ;

        }
          

        function getUnclaimedCashback(address _user) view public returns ( uint  ) {
                        return unclaimed[_user];
        }
        
        function getClaimedCashback(address _user) view public returns ( uint  ) {
                        return claimed[_user];
        }
          
 
        function addContractBalance(uint amount) public onlyOwner{
            require(Token(tokenAddress).transferFrom(msg.sender, address(this), amount), "Cannot add balance!");
            
        }
        
        function withdrawBalance() public onlyOwner {
           msg.sender.transfer(address(this).balance);
            
        } 
        
        function withdrawToken() public onlyOwner {
            require(Token(tokenAddress).transfer(msg.sender, Token(tokenAddress).balanceOf(address(this))), "Cannot withdraw balance!");
            
        } 
 
    

    }