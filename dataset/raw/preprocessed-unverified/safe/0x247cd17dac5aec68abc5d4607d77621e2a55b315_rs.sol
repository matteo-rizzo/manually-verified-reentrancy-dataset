/**

 *Submitted for verification at Etherscan.io on 2018-08-29

*/



pragma solidity ^0.4.23;



// File: contracts/BytesUtils.sol







// File: contracts/algorithms/Algorithm.sol



/**

* @dev An interface for contracts implementing a DNSSEC (signing) algorithm.

*/





// File: @ensdomains/buffer/contracts/Buffer.sol



/**

* @dev A library for working with mutable byte buffers in Solidity.

*

* Byte buffers are mutable and expandable, and provide a variety of primitives

* for writing to them. At any time you can fetch a bytes object containing the

* current contents of the buffer. The bytes object should not be stored between

* operations, as it may change due to resizing of the buffer.

*/





// File: contracts/algorithms/ModexpPrecompile.sol







// File: contracts/algorithms/RSAVerify.sol







// File: contracts/algorithms/RSASHA256Algorithm.sol



/**

* @dev Implements the DNSSEC RSASHA256 algorithm.

*/

contract RSASHA256Algorithm is Algorithm {

    using BytesUtils for *;



    function verify(bytes key, bytes data, bytes sig) external view returns (bool) {

        bytes memory exponent;

        bytes memory modulus;



        uint16 exponentLen = uint16(key.readUint8(4));

        if (exponentLen != 0) {

            exponent = key.substring(5, exponentLen);

            modulus = key.substring(exponentLen + 5, key.length - exponentLen - 5);

        } else {

            exponentLen = key.readUint16(5);

            exponent = key.substring(7, exponentLen);

            modulus = key.substring(exponentLen + 7, key.length - exponentLen - 7);

        }



        // Recover the message from the signature

        bool ok;

        bytes memory result;

        (ok, result) = RSAVerify.rsarecover(modulus, exponent, sig);



        // Verify it ends with the hash of our data

        return ok && sha256(data) == result.readBytes32(result.length - 32);

    }

}