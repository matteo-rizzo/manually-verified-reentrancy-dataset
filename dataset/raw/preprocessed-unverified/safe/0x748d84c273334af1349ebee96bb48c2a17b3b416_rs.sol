pragma solidity ^0.4.21;



contract owned {

        address public owner;



        function owned() public{

            owner = msg.sender;

        }



        modifier onlyOwner {

            require(msg.sender == owner);

            _;

        }



        function transferOwnership(address newOwner) public onlyOwner {

            owner = newOwner;

        }

    }



contract Verification is owned {

	using SafeMath for uint256;

    mapping(address => uint256) veruser;

	

	function RA(address _to) public view returns(bool){

		if(veruser[_to]>0){

			return true;

			}else{

				return false;

				}

	}

	

	function Verification() public {

	    if(RA(msg.sender) == false){

			veruser[msg.sender] = veruser[msg.sender].add(1);

			}

	}

	

	/*孝忱忘抖快扶我快 志快把我扳我抗忘扯我我*/

	function DelVer(address _address) public onlyOwner{

		if(RA(_address) == true){

			veruser[_address] = veruser[_address].sub(0);

		}

		

		

	}

	

}