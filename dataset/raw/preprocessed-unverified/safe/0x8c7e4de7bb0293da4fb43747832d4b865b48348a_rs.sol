pragma solidity ^0.4.21;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */











contract ENS {

    function owner(bytes32 node) constant returns (address);

    function resolver(bytes32 node) constant returns (Resolver);

    function ttl(bytes32 node) constant returns (uint64);

    function setOwner(bytes32 node, address owner);

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner);

    function setResolver(bytes32 node, address resolver);

    function setTTL(bytes32 node, uint64 ttl);

}



contract Resolver {

    function addr(bytes32 node) constant returns (address);

}



contract ENSResolver is Ownable {

    ENS public ens;



    function ENSResolver(address ensAddress) public {

        require(ensAddress != address(0));

        ens = ENS(ensAddress);

    }



    function setENS(address ensAddress) public onlyOwner {

        require(ensAddress != address(0));

        ens = ENS(ensAddress);

    }



    function resolve(bytes32 node) public view returns (address) {

        Resolver resolver = Resolver(ens.resolver(node));

        return resolver.addr(node);

    }

}