/**

 *Submitted for verification at Etherscan.io on 2018-08-29

*/



pragma solidity ^0.4.23;



// File: contracts/BytesUtils.sol







// File: contracts/digests/Digest.sol



/**

* @dev An interface for contracts implementing a DNSSEC digest.

*/





// File: contracts/digests/SHA256Digest.sol



/**

* @dev Implements the DNSSEC SHA256 digest.

*/

contract SHA256Digest is Digest {

    using BytesUtils for *;



    function verify(bytes data, bytes hash) external pure returns (bool) {

        return sha256(data) == hash.readBytes32(0);

    }

}