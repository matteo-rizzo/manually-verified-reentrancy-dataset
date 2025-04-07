/**

 *Submitted for verification at Etherscan.io on 2018-09-30

*/



pragma solidity ^0.4.23;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract Notary is Ownable {



    struct Record {

        bytes notarisedData;

        uint256 timestamp;

    }



    mapping(bytes32 => Record) public records;

    uint256 public notarisationFee;



    /**

    * @dev initialize Notary

    * @param _owner of the notary

    */

    constructor (address _owner) public {

        owner = _owner;

    }



    /**

    * @dev make sure that the call has the notarisation cost

    */

    modifier callHasNotarisationCost() {

        require(msg.value >= notarisationFee);

        _;

    }



    /**

    * @dev set notarisation cost

    * @param _fee to notarize a record

    */

    function setNotarisationFee(uint256 _fee) public onlyOwner {

        notarisationFee = _fee;

    }



    /**

    * @dev fetch a Record by it's data notarised data

    * @param _notarisedData the data that got notarised

    */

    function record(bytes _notarisedData) public constant returns(bytes, uint256) {

        Record memory r = records[keccak256(_notarisedData)];

        return (r.notarisedData, r.timestamp);

    }



    /**

    * @dev notarize a new record

    * @param _record the record to notarize

    */

    function notarize(bytes _record)

        public

        payable

        callHasNotarisationCost

    {



        // create hash of record to to have an unique and deterministic key

        bytes32 recordHash = keccak256(_record);



        // make sure the record hasn't been notarised

        require(records[recordHash].timestamp == 0);



        // transfer notarisation fee to owner

        if (owner != address(0)){

            owner.transfer(address(this).balance);

        }



        // notarize record

        records[recordHash] = Record({

            notarisedData: _record,

            timestamp: now

        });



    }



}



contract NotaryMulti {



    Notary public notary;



    constructor(Notary _notary) public {

        notary = _notary;

    }



    function notaryFee() public constant returns (uint256) {

        return 2 * notary.notarisationFee();

    }



    /**

    * @dev notarize two records

    * @param _firstRecord is the first record that should be notarized

    * @param _secondRecord is the second record that should be notarized

    */

    function notarizeTwo(bytes _firstRecord, bytes _secondRecord) payable public {

        notary.notarize(_firstRecord);

        notary.notarize(_secondRecord);

    }



}