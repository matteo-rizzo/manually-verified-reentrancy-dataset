



pragma solidity >=0.4.22 <0.6.0;







contract EthCCPlayingCards {



    mapping (address => bool) public addressFound;



    event LogAddressFound(address indexed whoAddress, bytes32 whoName);



    function addressFoundBy(bytes32 name) public {

        addressFound[msg.sender] = true;

        emit LogAddressFound(msg.sender, name);

    }

}