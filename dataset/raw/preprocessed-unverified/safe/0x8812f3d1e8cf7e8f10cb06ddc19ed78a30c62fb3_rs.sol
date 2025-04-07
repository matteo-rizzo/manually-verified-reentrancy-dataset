/**
 *Submitted for verification at Etherscan.io on 2019-09-18
*/

pragma solidity 0.5.8;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */


// File: contracts/file_verification_v2.sol

contract Verification is Ownable {
    // Struct for each certificate
    struct Certificate {
        uint256 time;
        bytes32 pdfHash;
        bytes32 originHash;
    }

    // mapping that stores all the versions of a certificate, indexed by the hash of the first pdf
    mapping(bytes32 => bytes32[]) public versions;

    // events
    event CertificateCreated(bytes32 indexed _pdfHash, bytes32 indexed _originHash, address indexed _sender, uint256 _time);
    event CertificateUpdated(bytes32 indexed _pdfHash, bytes32 indexed _originHash, address indexed _sender, uint256 _time);

    // Create a certificate
    function createCert(bytes32 _pdfHash) public onlyOwner returns (bool) {
        require(_pdfHash != bytes32(0));

        // Making sure that we don't push the same hash multiple times
        require(versions[_pdfHash].length == 0);

        versions[_pdfHash].push(_pdfHash);
        emit CertificateCreated(_pdfHash, _pdfHash, msg.sender, block.timestamp);
        return true;
    }

    // Update the Certificate
    function updateCert(bytes32 _pdfHash, bytes32 _newPdfHash) public onlyOwner returns (bool) {
        require(_pdfHash != bytes32(0));
        require(_newPdfHash != bytes32(0));
        require(versions[_pdfHash].length != 0);
        versions[_pdfHash].push(_newPdfHash);
        emit CertificateUpdated(_newPdfHash, _pdfHash, msg.sender, block.timestamp);
        return true;
    }

    // View the record by `originHash`
    function viewRecord(bytes32 _originHash) public view returns (bytes32[] memory copy) {
        require(_originHash != bytes32(0));
        copy = versions[_originHash];
    }
}