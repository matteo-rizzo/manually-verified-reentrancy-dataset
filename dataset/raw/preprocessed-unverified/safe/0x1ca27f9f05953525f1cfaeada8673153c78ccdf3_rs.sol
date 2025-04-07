pragma solidity ^0.4.24;



/**

 * @title Helps contracts guard agains reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>

 * @notice If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {



  /**

   * @dev We use a single lock for the whole contract.

   */

  bool private reentrancyLock = false;



  /**

   * @dev Prevents a contract from calling itself, directly or indirectly.

   * @notice If you mark a function `nonReentrant`, you should also

   * mark it `external`. Calling one nonReentrant function from

   * another is not supported. Instead, you can implement a

   * `private` function doing the actual work, and a `external`

   * wrapper marked as `nonReentrant`.

   */

  modifier nonReentrant() {

    require(!reentrancyLock);

    reentrancyLock = true;

    _;

    reentrancyLock = false;

  }



}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */









contract Rainmaker is Ownable, ReentrancyGuard {

    function letItRain(address[] _to, uint[] _value) nonReentrant onlyOwner public payable returns (bool _success) {

        for (uint8 i = 0; i < _to.length; i++){

            uint amount = _value[i] * 1 finney;

            _to[i].transfer(amount);

        }

        return true;

    }

    

    //If accidentally tokens are transferred to this

    //contract. They can be withdrawn by the following interface.

    function withdrawERC20Token(ERC20 anyToken) public onlyOwner nonReentrant returns(bool){

        if( anyToken != address(0x0) ) {

            assert(anyToken.transfer(owner, anyToken.balanceOf(this)));

        }

        return true;

    }



    //ETH cannot get locked in this contract. If it does, this can be used to withdraw

    //the locked ether.

    function withdrawEther() public onlyOwner nonReentrant returns(bool){

        if(address(this).balance > 0){

            owner.transfer(address(this).balance);

        }        

        return true;

    }

}