/**

 *Submitted for verification at Etherscan.io on 2019-01-28

*/



pragma solidity 0.4.21;



// Declaring the API of external functions.

contract IJNBToken {

    function acceptOwnership() public;

    function transfer(address _to, uint _value) public returns(bool);

}











contract JNBOwner is Ownable{



    address public constant addr = 0x21D5A14e625d767Ce6b7A167491C2d18e0785fDa; // The address of JNB Token.

     

	function JNBOwner(address _owner) public { 

		owner = _owner; // The constructor sets owner as '_owner'.

	}



    function acceptJNBOwner() public{

        IJNBToken(addr).acceptOwnership(); // Calling external function to compelete 'transferOwnership' operation.

    }

    

    function withdrawJNB(uint256 _amount) onlyOwner public{

        require(IJNBToken(addr).transfer(owner,_amount)); // Requiring the return value of callling external function 

    }



}