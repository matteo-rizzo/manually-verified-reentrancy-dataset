/**

 *Submitted for verification at Etherscan.io on 2019-04-24

*/



pragma solidity ^0.5.7;











contract Authorizable is Ownable {

    mapping(address => bool) public authorized;

  

    event AuthorizationSet(address indexed addressAuthorized, bool indexed authorization);



    constructor() public {

        authorized[msg.sender] = true;

    }



    modifier onlyAuthorized() {

        require(authorized[msg.sender], "authorized[msg.sender]");

        _;

    }



    function setAuthorized(address addressAuthorized, bool authorization) onlyOwner public {

        emit AuthorizationSet(addressAuthorized, authorization);

        authorized[addressAuthorized] = authorization;

    }

  

}

 

contract tokenInterface {

    function transfer(address _to, uint256 _value) public returns (bool);

}



contract MultiSender is Authorizable {

	tokenInterface public tokenContract;

	

	constructor(address _tokenAddress) public {

	    tokenContract = tokenInterface(_tokenAddress);

	}

	

	function updateTokenContract(address _tokenAddress) public onlyAuthorized {

        tokenContract = tokenInterface(_tokenAddress);

    }

	

    function multiSend(address[] memory _dests, uint256[] memory _values) public onlyAuthorized returns(uint256) {

        require(_dests.length == _values.length, "_dests.length == _values.length");

        uint256 i = 0;

        while (i < _dests.length) {

           tokenContract.transfer(_dests[i], _values[i]);

           i += 1;

        }

        return(i);

    }

	

	function withdrawTokens(address to, uint256 value) public onlyAuthorized returns (bool) {

        return tokenContract.transfer(to, value);

    }

    

    function withdrawEther() public onlyAuthorized returns (bool) {

        msg.sender.transfer(address(this).balance);

        return true;

    }

}