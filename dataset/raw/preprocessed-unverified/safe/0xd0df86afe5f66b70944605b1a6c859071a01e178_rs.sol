/**
 *Submitted for verification at Etherscan.io on 2021-02-09
*/

/**
 *Submitted for verification at Etherscan.io on 2021-02-09
*/

/**
 *Submitted for verification at Etherscan.io on 2021-02-09
*/

/**
 *Submitted for verification at Etherscan.io on 2021-02-09
*/

/**
 *Submitted for verification at Etherscan.io on 2021-02-09
*/

/**
 *Submitted for verification at Etherscan.io on 2021-01-30
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
    
    
    


    

    contract GCBVault is Ownable {
        using SafeMath for uint;
        using EnumerableSet for EnumerableSet.AddressSet;
        
         uint public  vaultClose = 1e21;
         constructor(uint endTime) public {
            vaultClose = endTime;
        }
    

        // GCB token contract address
        address public constant tokenAddress = 0x3539a4F4C0dFfC813B75944821e380C9209D3446;
        
        uint public oneVaultLimit = 6e20;
        uint public fourVaultLimit = 6e20;

        uint public  oneCliff = 30 days;
        
        uint public  fourthCliff = 120 days;

        uint public  vaultTotal = 0;
        
        mapping(address => uint) public onemonth;
        
        mapping(address => uint) public onemonthCliff;
        
         mapping(address => uint) public claimed;
        
        mapping(address => uint) public fourmonth;
        
        mapping(address => uint) public fourmonthCliff;
        
        event DepositAdded(address indexed user,uint amount );
            
        event VaultClaimed(address indexed user, uint amount );
    

        
        function oneDeposit(uint _amount) public  returns (bool)   {
                    
                    uint amount = _amount.sub(_amount.mul(350).div(1e4));
                    require(oneVaultLimit >= amount , "Can't deposit more than limit") ;

                    require(vaultClose > now , "Can't deposit now") ;

                    Token(tokenAddress).transferFrom(msg.sender , address(this), _amount);
                    
                    onemonth[msg.sender] =  onemonth[msg.sender].add(amount) ;
                    
                    vaultTotal = vaultTotal.add(amount) ;

                    onemonthCliff[msg.sender] = now + oneCliff ;
                    
                    oneVaultLimit = oneVaultLimit.sub(amount) ;
                    
                    emit DepositAdded(msg.sender,amount);
                               
                    return true ;

            }
            
              function fourDeposit(uint _amount) public  returns (bool)   {

                    uint amount = _amount.sub(_amount.mul(350).div(1e4));
                    
                    require(fourVaultLimit >= amount , "Can't deposit more than limit") ;


                    require(vaultClose > now , "Can't deposit now") ;

                    Token(tokenAddress).transferFrom(msg.sender , address(this), _amount);
                    
                    fourmonth[msg.sender] =  fourmonth[msg.sender].add(amount) ;
                    
                    vaultTotal = vaultTotal.add(amount) ;

                    fourmonthCliff[msg.sender] = now + fourthCliff ;
                   
                    fourVaultLimit = fourVaultLimit.sub(amount);
                     
                    emit DepositAdded(msg.sender,amount);
                               
                    return true ;

            }
        
       
        function claim() public returns (uint)  {
            
            uint returnAmt = getTotalReturn(msg.sender) ;
            
            require(returnAmt > 0, "Cannot claim 0 or less");
            
            Token(tokenAddress).transfer(msg.sender, returnAmt);
          
            emit VaultClaimed(msg.sender,returnAmt);
            
            claimed[msg.sender] = claimed[msg.sender].add(returnAmt) ;
            
            if(onemonthCliff[msg.sender] < now ){
              oneVaultLimit = oneVaultLimit.add(onemonth[msg.sender]);
              vaultTotal = vaultTotal.sub(onemonth[msg.sender]) ;

              onemonth[msg.sender] =  0 ;
              onemonthCliff[msg.sender] =  0 ;
            }

            if(fourmonthCliff[msg.sender] < now){
              fourVaultLimit = fourVaultLimit.add(fourmonth[msg.sender]);
              vaultTotal = vaultTotal.sub(fourmonth[msg.sender]) ;

            fourmonth[msg.sender] =  0 ;
            fourmonthCliff[msg.sender] = 0 ;
            }


        }
          
        function getOneReturn(address _user) view public returns ( uint  ) {
                        
                        
                        uint oneR = 0 ;
                        if(onemonthCliff[_user] < now ){
                              oneR = onemonth[_user].add(onemonth[_user].mul(4200).div(1e4));
                        }
                       
                        return oneR ;
        }
        
          function getFourReturn(address _user) view public returns ( uint  ) {
                     
                        uint fourR = 0 ;
                        if(fourmonthCliff[_user] < now){
                             fourR = fourmonth[_user].add(fourmonth[_user].mul(24500).div(1e4));
                        }
                       
                        return fourR ;
        }

        function getTotalReturn(address _user) view public returns ( uint  ) {
                        
                        uint oneR = 0 ;
                        if(onemonthCliff[_user] < now ){
                              oneR = onemonth[_user].add(onemonth[_user].mul(4200).div(1e4));
                        }
                        
                        uint fourR = 0 ;
                        if(fourmonthCliff[_user] < now){
                             fourR = fourmonth[_user].add(fourmonth[_user].mul(24500).div(1e4));
                        }
                        uint total = oneR + fourR ;
                        return total ;
        }
        
        function getClaimeReturn(address _user) view public returns ( uint  ) {
                        return claimed[_user];
        }
          
          
        function updateCliff(uint one, uint four)  public onlyOwner returns ( bool  ) {
                        oneCliff = one ;
                        fourthCliff = four;
                        return true;
        }

        function updateVaultClose(uint _vaultClose)  public onlyOwner returns ( bool  ) {                        
                        vaultClose = _vaultClose;
                        return true;
        }
        
          
         
        function withdrawToken(uint amount) public onlyOwner {
            require(Token(tokenAddress).transfer(msg.sender, amount), "Cannot withdraw balance!");
            
        }   
    
 
        function addContractBalance(uint amount) public {
            require(Token(tokenAddress).transferFrom(msg.sender, address(this), amount), "Cannot add balance!");
            
        }
 
    

    }