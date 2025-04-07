/**

 *Submitted for verification at Etherscan.io on 2018-10-05

*/



pragma solidity ^0.4.24;



/**

* @title Ownable

* @dev The Ownable contract has an owner address, and provides basic authorization control

* functions, this simplifies the implementation of "user permissions".

*/





contract SnowflakeResolver is Ownable {

    string public snowflakeName;

    string public snowflakeDescription;

    address public snowflakeAddress;



    bool public callOnSignUp;

    bool public callOnRemoval;



    function setSnowflakeAddress(address _address) public onlyOwner {

        snowflakeAddress = _address;

    }



    modifier senderIsSnowflake() {

        require(msg.sender == snowflakeAddress, "Did not originate from Snowflake.");

        _;

    }



    // onSignUp is called every time a user sets your contract as a resolver if callOnSignUp is true

    // this function **must** use the senderIsSnowflake modifier

    // returning false will disallow users from setting your contract as a resolver

    // function onSignUp(string hydroId, uint allowance) public returns (bool);



    // onRemoval is called every time a user sets your contract as a resolver if callOnRemoval is true

    // this function **must** use the senderIsSnowflake modifier

    // returning false soft prevents users from removing your contract as a resolver

    // however, they can force remove your resolver, bypassing this function

    // function onRemoval(string hydroId, uint allowance) public returns (bool);

}





contract Snowflake {

    function whitelistResolver(address resolver) external;

    function withdrawSnowflakeBalanceFrom(string hydroIdFrom, address to, uint amount) public returns (bool);

    function getHydroId(address _address) public view returns (string hydroId);

}





contract Status is SnowflakeResolver {

    mapping (string => string) internal statuses;



    uint signUpFee = 1000000000000000000;

    string firstStatus = "My first status ðŸ˜Ž";



    constructor (address snowflakeAddress) public {

        snowflakeName = "Status";

        snowflakeDescription = "Set your status.";

        setSnowflakeAddress(snowflakeAddress);



        callOnSignUp = true;



        Snowflake snowflake = Snowflake(snowflakeAddress);

        snowflake.whitelistResolver(address(this));

    }



    // implement signup function

    function onSignUp(string hydroId, uint allowance) public senderIsSnowflake() returns (bool) {

        require(allowance >= signUpFee, "Must set an allowance of at least 1.");

        Snowflake snowflake = Snowflake(snowflakeAddress);

        snowflake.withdrawSnowflakeBalanceFrom(hydroId, owner, signUpFee);

        statuses[hydroId] = firstStatus;

        emit StatusUpdated(hydroId, firstStatus);

        return true;

    }



    function getStatus(string hydroId) public view returns (string) {

        return statuses[hydroId];

    }



    // example function that calls withdraw on a linked hydroID

    function setStatus(string status) public {

        Snowflake snowflake = Snowflake(snowflakeAddress);

        string memory hydroId = snowflake.getHydroId(msg.sender);

        statuses[hydroId] = status;

        emit StatusUpdated(hydroId, status);

    }



    event StatusUpdated(string hydroId, string status);

}