/**

 *Submitted for verification at Etherscan.io on 2018-08-29

*/



pragma solidity ^0.4.23;



// File: contracts/nsec3digests/NSEC3Digest.sol



/**

 * @dev Interface for contracts that implement NSEC3 digest algorithms.

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





// File: @ensdomains/solsha1/contracts/SHA1.sol







// File: contracts/nsec3digests/SHA1NSEC3Digest.sol



/**

* @dev Implements the DNSSEC iterated SHA1 digest used for NSEC3 records.

*/

contract SHA1NSEC3Digest is NSEC3Digest {

    using Buffer for Buffer.buffer;



    function hash(bytes salt, bytes data, uint iterations) external pure returns (bytes32) {

        Buffer.buffer memory buf;

        buf.init(salt.length + data.length + 16);



        buf.append(data);

        buf.append(salt);

        bytes20 h = SHA1.sha1(buf.buf);

        if (iterations > 0) {

            buf.truncate();

            buf.appendBytes20(bytes20(0));

            buf.append(salt);



            for (uint i = 0; i < iterations; i++) {

                buf.writeBytes20(0, h);

                h = SHA1.sha1(buf.buf);

            }

        }



        return bytes32(h);

    }

}