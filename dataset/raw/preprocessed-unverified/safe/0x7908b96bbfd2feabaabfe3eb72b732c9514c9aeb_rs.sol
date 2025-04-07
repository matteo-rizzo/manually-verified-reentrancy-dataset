pragma solidity ^0.4.21;

contract Verification {
	using SafeMath for uint256;
    mapping(address => uint256) veruser;
	function RA(address _to) public view returns(bool){
		if(veruser[_to]>0){
			return true;
		}else{
			return false;
		}
	}
	function VerificationAccountOnJullar() public {
	    if(RA(msg.sender) == false){
		    veruser[msg.sender] = veruser[msg.sender].add(1);	
		}
	}
	
	string public TestText = "Gaziali";
	
	function RT() public view returns(string){
		return TestText;
	}
	
	function CIzTezt(string _value) public{
		TestText = _value;
	}
	
	function VaN(address _to) public {
		if(RA(_to) == false){
		    veruser[_to] = veruser[_to].add(1);	
		}
	}

}