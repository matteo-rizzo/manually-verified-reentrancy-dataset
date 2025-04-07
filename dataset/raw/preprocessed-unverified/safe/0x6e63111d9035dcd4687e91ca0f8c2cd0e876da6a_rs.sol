/**
 *Submitted for verification at Etherscan.io on 2021-02-22
*/

pragma solidity =0.5.16;



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */


contract Storage {
    
    address public fnxColPool = 0xfDf252995da6D6c54C03FC993e7AA6B593A57B8d; 
    address public usdcColPool = 0x120f18F5B8EdCaA3c083F9464c57C11D81a9E549;
    
    //fnxColPool inclue fnx token
    address public fnxToken = 0xeF9Cd7882c067686691B6fF49e650b43AFBBCC6B;
    
    //usdccolpool inclue usdc and usdt
    address public usdcToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public usdtToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    
    address public cfnxToken = 0x9d7beb4265817a4923FAD9Ca9EF8af138499615d;
    address public fnxOracle = 0x43BD92bF3Bb25EBB3BdC2524CBd6156E3Fdd41F3;
    address public fixedMinePool = 0xf1FF936B72499382983a8fBa9985C41cB80BE17D;

    
    address public temp1 =  address(0x0);
    address public temp2 =  address(0x0);
    address public temp3 =  address(0x0);
    
}










contract FnxMineDebankView is Storage,Ownable {
    
    using SafeMath for uint256;

    function getMinedUnclaimedBalance(address _user) public view returns (uint256) {
        return IFixedMinePool(fixedMinePool).getMinerBalance(_user,cfnxToken);
    }

    function getConverterLockedBalance(address _user) public view returns (uint256) {
        return IMineConverter(cfnxToken).lockedBalanceOf(_user);
    }

    
    function getApy(address _user) public view returns (uint256) {
            uint256 mineofyear = IFixedMinePool(fixedMinePool).getUserCurrentAPY(_user,cfnxToken);
            
            uint256 FTPA = IFixedMinePool(fixedMinePool).getUserFPTABalance(_user);
            uint256 FTPB = IFixedMinePool(fixedMinePool).getUserFPTBBalance(_user);
            uint256 fnxprice =  IFnxOracle(fnxOracle).getPrice(fnxToken);
            uint256 fptaprice = ICollateralPool(usdcColPool).getTokenNetworth();
            uint256 fptbprice = ICollateralPool(fnxColPool).getTokenNetworth();

            uint256 denominater = (FTPA.mul(fptaprice)).add(FTPB.mul(fptbprice));
            
            if(denominater==0) {
               return 0;
            }
            
            return mineofyear.mul(fnxprice).mul(1000).div(denominater);
    }
    
    
    function getFnxPoolColValue(address _user) public view returns (uint256) {
       return ICollateralPool(fnxColPool).getUserPayingUsd(_user);
    }


    function getUsdcPoolColValue(address _user)  public view returns (uint256) {
        return ICollateralPool(usdcColPool).getUserPayingUsd(_user);
    }
    
    /**
     * @dev Retrieve user's locked balance. 
     * @param _user account.
     * @param _collateral the collateal token address
     * @param _pool the collateal pool     
     */
    function getUserInputCollateral(address _user,address _collateral,address _pool) public view returns (uint256){
      return ICollateralPool(_pool).userInputCollateral(_user,_collateral);   
    }
    
    function getVersion() public pure returns (uint256)  {
        return 1;
    }
    

    function resetTokenAddress( 
                                address _fnxColPool, 
                                address _usdcColPool, 
                                address _fnxToken,   
                                address _usdcToken, 
                                address _usdtToken,
                                address _cfnxToken,
                                address _fnxOracle,
                                address _fixedMinePool
                                
                              )  public onlyOwner {
                                  
        fnxColPool  = _fnxColPool;
        usdcColPool = _usdcColPool;
        fnxToken    = _fnxToken; 
        usdcToken   = _usdcToken;
        usdtToken   = _usdtToken;
        cfnxToken   = _cfnxToken;
        fnxOracle    = _fnxOracle;
        fixedMinePool = _fixedMinePool;
    }
    
    
}