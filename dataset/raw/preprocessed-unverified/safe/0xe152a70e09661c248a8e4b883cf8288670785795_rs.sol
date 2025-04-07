/**
 *Submitted for verification at Etherscan.io on 2019-10-22
*/

pragma solidity 0.5.12;




contract Certificate is Ownable  {
    bytes32 private _certificateHolderNameHash;
    string private _eventName;
    string private _organizer;
    string private _issuedBy;
    string private _issuedOn;

    constructor(
        string memory eventName,
        string memory organizer,
        string memory issuedBy,
        string memory issuedOn
    )
        public
    {
        _eventName = eventName;
        _organizer = organizer;
        _issuedBy = issuedBy;
        _issuedOn = issuedOn;
    }
    
    function setCertificateHolderNameHash(
        bytes32 certificateHolderNameHash
    )
        external
        onlyOwner
    {
        _certificateHolderNameHash = certificateHolderNameHash;
    }
    
    function name()
        external pure
        returns (string memory)
    {
        return "Lykke Academy Certificate";
    }
    
    function certificateType()
        external pure
        returns (string memory)
    {
        return "CERTIFICATE OF PARTICIPATION";
    }

    function certificateHolderNameHash()
        external view
        returns (bytes32)
    {
        return _certificateHolderNameHash;
    }
    
    function eventName()
        external view
        returns (string memory)
    {
        return _eventName;
    }
    
    function organizer()
        external view
        returns (string memory)
    {
        return _organizer;
    }
    
    function issuedBy()
        external view
        returns (string memory)
    {
        return _issuedBy;
    }

    function issuedOn()
        external view
        returns (string memory)
    {
        return _issuedOn;
    }

    function validateCertificateHolderName(
        string calldata certificateHolderName
    )
        external view
        returns (bool)
    {
        return _certificateHolderNameHash == keccak256(abi.encode(certificateHolderName));
    }
    
}