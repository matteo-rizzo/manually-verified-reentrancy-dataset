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
    
    
    
    


    

    contract GCBNCashClaim is Ownable {
        using SafeMath for uint;
        using EnumerableSet for EnumerableSet.AddressSet;
        

        // GCBN token contract address
        address public constant tokenAddress = 0x15c303B84045f67156AcF6963954e4247B526717;
        

        mapping(address => uint) public unclaimed;
        
        mapping(address => uint) public claimed;
        
        event CashbackAdded(address indexed user,uint amount ,uint time);
            
        event CashbackClaimed(address indexed user, uint amount ,uint time );
    

        
        function addCashback(address _user , uint _amount ) public  onlyOwner returns (bool)   {

                    unclaimed[_user] =  unclaimed[_user].add(_amount) ;
                   
                    emit CashbackAdded(_user,_amount,now);
                               
                    return true ;

        }
        
        
        function claim() public returns (uint)  {
            
            require(unclaimed[msg.sender] > 0, "Cannot claim 0 or less");

            uint amount = unclaimed[msg.sender] ;
           
            Token(tokenAddress).transfer(msg.sender, amount);
           
          
            emit CashbackClaimed(msg.sender,unclaimed[msg.sender],now);
            
            claimed[msg.sender] = claimed[msg.sender].add(unclaimed[msg.sender]) ;
            
            unclaimed[msg.sender] =  0 ;

        }
          

        function getUnclaimeCashback(address _user) view public returns ( uint  ) {
                        return unclaimed[_user];
        }
        
        function getClaimeCashback(address _user) view public returns ( uint  ) {
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