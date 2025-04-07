/**

 *Submitted for verification at Etherscan.io on 2018-08-29

*/



pragma solidity ^0.4.23;



// File: contracts/BytesUtils.sol







// File: contracts/digests/Digest.sol



/**

* @dev An interface for contracts implementing a DNSSEC digest.

*/





// File: @ensdomains/solsha1/contracts/SHA1.sol







// File: contracts/digests/SHA1Digest.sol



/**

* @dev Implements the DNSSEC SHA1 digest.

*/

contract SHA1Digest {

    using BytesUtils for *;



    function verify(bytes data, bytes hash) external pure returns (bool) {

        bytes32 expected = hash.readBytes20(0);

        bytes20 computed = SHA1.sha1(data);

        return expected == computed;

    }

}