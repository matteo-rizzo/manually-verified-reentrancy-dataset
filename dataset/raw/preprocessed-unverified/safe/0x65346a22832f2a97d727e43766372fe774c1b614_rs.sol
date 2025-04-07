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
    
    
    
    


    

    contract FINTCB is Ownable {
        using SafeMath for uint;
        using EnumerableSet for EnumerableSet.AddressSet;
        

        // FINT token contract address
        address public constant tokenAddress = 0xe06381943f7EF2674fA497e5962459AbF36BD4BF;
        address public constant rewardAddress = 0xaA99007aa41ff10d76E91d96Ff4b0Bc773336C27 ;


        mapping(address => uint) public unclaimed;
        
        mapping(address => uint) public claimed;
        
        event CashbackAdded(address indexed user,uint amount );
            
        event CashbackClaimed(address indexed user, uint amount );
    

        
        function addCashback(address _user , uint _amount ) public  onlyOwner returns (bool)   {

                    unclaimed[_user] =  unclaimed[_user].add(_amount) ;
                   
                    emit CashbackAdded(_user,_amount);
                               
                    return true ;

        }
        
        function claim() public returns (uint)  {
            
            require(unclaimed[msg.sender] > 0, "Cannot claim 0 or less");

            uint amount = unclaimed[msg.sender] ;
            
            uint fee = amount.mul(500).div(1e4) ;
            
            amount = amount.sub(fee);

            Token(tokenAddress).transfer(msg.sender, amount);
            
            Token(tokenAddress).transfer(rewardAddress, fee);
          
            emit CashbackClaimed(msg.sender,unclaimed[msg.sender]);
            
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