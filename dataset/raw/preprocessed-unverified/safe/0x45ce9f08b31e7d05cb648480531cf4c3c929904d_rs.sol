/**

 *Submitted for verification at Etherscan.io on 2019-06-13

*/



pragma solidity 0.5.7;



// File: openzeppelin-solidity/contracts/cryptography/ECDSA.sol



/**

 * @title Elliptic curve signature operations

 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d

 * TODO Remove this library once solidity supports passing a signature to ecrecover.

 * See https://github.com/ethereum/solidity/issues/864

 */







// File: contracts/AliorDurableMedium.sol



contract AliorDurableMedium {



    // ------------------------------------------------------------------------------------------ //

    // STRUCTS

    // ------------------------------------------------------------------------------------------ //

    

    // Defines a single document

    struct Document {

        string fileName;         // file name of the document

        bytes32 contentHash;     // hash of document's content

        address signer;          // address of the entity who signed the document

        address relayer;         // address of the entity who published the transaction

        uint40 blockNumber;      // number of the block in which the document was added

        uint40 canceled;         // block number in which document was canceled; 0 otherwise

    }



    // ------------------------------------------------------------------------------------------ //

    // MODIFIERS

    // ------------------------------------------------------------------------------------------ //



    // Restricts function use by verifying given signature with nonce

    modifier ifCorrectlySignedWithNonce(

        string memory _methodName,

        bytes memory _methodArguments,

        bytes memory _signature

    ) {

        bytes memory abiEncodedParams = abi.encode(address(this), nonce++, _methodName, _methodArguments);

        verifySignature(abiEncodedParams, _signature);

        _;

    }



    // Restricts function use by verifying given signature without nonce

    modifier ifCorrectlySigned(string memory _methodName, bytes memory _methodArguments, bytes memory _signature) {

        bytes memory abiEncodedParams = abi.encode(address(this), _methodName, _methodArguments);

        verifySignature(abiEncodedParams, _signature);

        _;

    }



    // Helper function used to verify signature for given bytes array

    function verifySignature(bytes memory abiEncodedParams, bytes memory signature) internal view {

        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(keccak256(abiEncodedParams));

        address recoveredAddress = ECDSA.recover(ethSignedMessageHash, signature);

        require(recoveredAddress != address(0), "Error during the signature recovery");

        require(recoveredAddress == owner, "Signature mismatch");

    }



    // Restricts function use after contract's retirement

    modifier ifNotRetired() {

        require(upgradedVersion == address(0), "Contract is retired");

        _;

    } 



    // ------------------------------------------------------------------------------------------ //

    // EVENTS

    // ------------------------------------------------------------------------------------------ //



    // An event emitted when the contract gets retired

    event ContractRetired(address indexed upgradedVersion);



    // An event emitted when a new document is published on the contract

    event DocumentAdded(uint indexed documentId);



    // An event emitted when a document is canceled

    event DocumentCanceled(uint indexed documentId);

    

    // An event emitted when contract owner changes

    event OwnershipChanged(address indexed newOwner);



    // ------------------------------------------------------------------------------------------ //

    // FIELDS

    // ------------------------------------------------------------------------------------------ //



    address public upgradedVersion;                           // if the contract gets retired; address of the new contract

    uint public nonce;                                        // ID of the next action

    uint private documentCount;                               // count of documents published on the contract

    mapping(uint => Document) private documents;              // document storage

    mapping(bytes32 => uint) private contentHashToDocumentId; // mapping that allows retrieving documentId by contentHash

    address public owner;                                     // owner of the contract

    // (this address is checked in signature verification)



    // ------------------------------------------------------------------------------------------ //

    // CONSTRUCTOR

    // ------------------------------------------------------------------------------------------ //



    constructor(address _owner) public {

        require(_owner != address(0), "Owner cannot be initialised to a null address");

        owner = _owner;    // address given as a constructor parameter becomes the 'owner'

        nonce = 0;         // first nonce is 0

    }



    // ------------------------------------------------------------------------------------------ //

    // VIEW FUNCTIONS

    // ------------------------------------------------------------------------------------------ //



    // Returns the number of documents stored in the contract

    function getDocumentCount() public view

    returns (uint)

    {

        return documentCount;

    }



    // Returns all information about a single document

    function getDocument(uint _documentId) public view

    returns (

        uint documentId,             // id of the document

        string memory fileName,      // file name of the document

        bytes32 contentHash,         // hash of document's content

        address signer,              // address of the entity who signed the document

        address relayer,             // address of the entity who published the transaction

        uint40 blockNumber,          // number of the block in which the document was added

        uint40 canceled              // block number in which document was canceled; 0 otherwise

    )

    {

        Document memory doc = documents[_documentId];

        return (

            _documentId, 

            doc.fileName, 

            doc.contentHash,

            doc.signer,

            doc.relayer,

            doc.blockNumber,

            doc.canceled

        );

    }



    // Gets the id of the document with given contentHash

    function getDocumentIdWithContentHash(bytes32 _contentHash) public view

    returns (uint) 

    {

        return contentHashToDocumentId[_contentHash];

    }



    // ------------------------------------------------------------------------------------------ //

    // STATE-CHANGING FUNCTIONS

    // ------------------------------------------------------------------------------------------ //



    // Changes the contract owner

    function transferOwnership(address _newOwner, bytes memory _signature) public

    ifCorrectlySignedWithNonce("transferOwnership", abi.encode(_newOwner), _signature)

    {

        require(_newOwner != address(0), "Owner cannot be changed to a null address");

        require(_newOwner != owner, "Cannot change owner to be the same address");

        owner = _newOwner;

        emit OwnershipChanged(_newOwner);

    }



    // Adds a new document

    function addDocument(

        string memory _fileName,

        bytes32 _contentHash,

        bytes memory _signature

    ) public

    ifNotRetired

    ifCorrectlySigned(

        "addDocument", 

        abi.encode(

            _fileName,

            _contentHash

        ),

        _signature

    )

    {

        require(contentHashToDocumentId[_contentHash] == 0, "Document with given hash is already published");

        uint documentId = documentCount + 1;

        contentHashToDocumentId[_contentHash] = documentId;

        emit DocumentAdded(documentId);

        documents[documentId] = Document(

            _fileName, 

            _contentHash,

            owner,

            msg.sender,

            uint40(block.number),

            0

        );

        documentCount++;

    }



    // Cancels a published document

    function cancelDocument(uint _documentId, bytes memory _signature) public

    ifNotRetired

    ifCorrectlySignedWithNonce("cancelDocument", abi.encode(_documentId), _signature)

    {

        require(_documentId <= documentCount && _documentId > 0, "Cannot cancel a non-existing document");

        require(documents[_documentId].canceled == 0, "Cannot cancel an already canceled document");

        documents[_documentId].canceled = uint40(block.number);

        emit DocumentCanceled(_documentId);

    }



    // Retires this contract and saves the address of the new one

    function retire(address _upgradedVersion, bytes memory _signature) public

    ifNotRetired

    ifCorrectlySignedWithNonce("retire", abi.encode(_upgradedVersion), _signature)

    {

        upgradedVersion = _upgradedVersion;

        emit ContractRetired(upgradedVersion);

    }

    

}