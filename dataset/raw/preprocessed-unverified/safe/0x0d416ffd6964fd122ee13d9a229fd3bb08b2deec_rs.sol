/**

 *Submitted for verification at Etherscan.io on 2018-09-04

*/



// TAKEN FROM https://github.com/OpenZeppelin/openzeppelin-solidity/commit/5daaf60d11ee2075260d0f3adfb22b1c536db983

pragma solidity ^0.4.24;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







// This is an implementation (with some adaptations) of uPort erc780: https://etherscan.io/address/0xdb55d40684e7dc04655a9789937214b493a2c2c6#code && https://github.com/ethereum/EIPs/issues/780



contract Registry is Ownable {



    mapping(address =>

    mapping(address =>

    mapping(bytes32 =>

    mapping(bytes32 => bytes32)))) registry;



    event ClaimSet(

        address indexed subject,

        address indexed issuer,

        bytes32 indexed id,

        bytes32 key,

        bytes32 data,

        uint updatedAt

    );



    event ClaimRemoved(

        address indexed subject,

        address indexed issuer,

        bytes32 indexed id,

        bytes32 key,

        uint removedAt

    );



    function setClaim(

        address subject,

        address issuer,

        bytes32 id,

        bytes32 key,

        bytes32 data

    ) public {

        require(msg.sender == issuer || msg.sender == owner);

        registry[subject][issuer][id][key] = data;

        emit ClaimSet(subject, issuer, id, key, data, now);

    }



    function getClaim(

        address subject,

        address issuer,

        bytes32 id,

        bytes32 key

    )

    public view returns(bytes32) {

        return registry[subject][issuer][id][key];

    }



    function removeClaim(

        address subject,

        address issuer,

        bytes32 id,

        bytes32 key

    ) public {

        require(

            msg.sender == subject || msg.sender == issuer || msg.sender == owner

        );

        delete registry[subject][issuer][id][key];

        emit ClaimRemoved(subject, issuer, id, key, now);

    }

}