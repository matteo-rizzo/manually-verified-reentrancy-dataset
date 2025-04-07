/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

/*
 ENS Contanthash resolver (EIP-1577) which may be updated with signatures from contenthash-signer-ens


 Copyright (c) Ulf Bartel

 Public repository:
 https://github.com/berlincode/contenthash-signer-ens

 License: MIT

 Contact:
 elastic.code@gmail.com

 Version 4.1.0

 This contract acts as a ens resolver. It always serves only one contenthash (for all nodes).
 Implements contenthash field for ENS (EIP 1577) (https://eips.ethereum.org/EIPS/eip-1577).
*/

pragma solidity 0.5.10;
pragma experimental ABIEncoderV2;

/*

*/


contract ResolverContenthashSignerENS {

    /* public constant contractVersion */
    uint64 public constant CONTRACT_VERSION = (
        (4 << 32) + /* major */
        (1 << 16) + /* minor */
        0 /* bugfix */
    );

    bytes4 constant CONTENTHASH_INTERFACE_ID = 0xbc1c58d1;

    event ContenthashChanged(bytes hash);

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct Record {
        uint64 version;
        bytes contenthash;
    }

    address signer; /* signer address */

    Record record;

    /**
     * Constructor.
     * @param signerAddr The signer address.
     */
    constructor(address signerAddr) public {
        signer = signerAddr;
    }

    /**
     * Sets the contenthash associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param hash The contenthash to set
     */
    /*
    function setContenthash(bytes32 node, bytes calldata hash) external {
        require(
            false,
            "Function call not supported"
        );
    }
    */

    /**
     * Returns the contenthash associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated contenthash.
     */
    function contenthash(bytes32 node) external view returns (bytes memory) {
        return record.contenthash;
    }

    /**
     * Returns true if the resolver implements the interface specified by the provided hash.
     * @param interfaceID The ID of the interface to check for.
     * @return True if the contract implements the requested interface.
     */
    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return interfaceID == CONTENTHASH_INTERFACE_ID;
    }

    /**
     * Sets the contenthash associated with an ENS node using a prebuild signature.
     * May be called by anyone with a valid signature.
     * @param hash The contenthash to set
     * @param version The version (which is part of the signature)
     * @param signature The signature over the keccak256(hash, version)
     */
    function setContenthashBySignature (
        bytes memory hash,
        uint64 version,
        Signature memory signature
    ) public
    {
        require(
            signer == verify(
                keccak256(
                    abi.encodePacked(
                        hash,
                        version
                    )
                ),
                signature
            ),
            "Invalid signature"
        );

        // update only if new version is higher than current version
        if (version > record.version) {
            record.contenthash = hash;
            record.version = version;
            emit ContenthashChanged(hash);
        }
    }

    /* internal functions */

    function verify(
        bytes32 _message,
        Signature memory signature
    ) internal pure returns (address)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(
            abi.encodePacked(
                prefix,
                _message
            )
        );
        return ecrecover(
            prefixedHash,
            signature.v,
            signature.r,
            signature.s
        );
    }

}