pragma solidity ^0.4.16;

/// @author Jordi Baylina
/// Auditors: Griff Green & psdev
/// @notice Based on http://hudsonjameson.com/ethereummarriage/
/// License: GNU-3

/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed



contract Marriage is Owned
{
    // Marriage data variables
    string public partner1;
    string public partner2;
    uint public marriageDate;
    string public marriageStatus;
    string public vows;

    Event[] public majorEvents;
    Message[] public messages;

    struct Event {
        uint date;
        string name;
        string description;
        string url;
    }

    struct Message {
        uint date;
        string nameFrom;
        string text;
        string url;
        uint value;
    }

    modifier areMarried {
        require(sha3(marriageStatus) == sha3("Married"));
        _;
    }

    //Set Owner
    function Marriage(address _owner) {
        owner = _owner;
    }

    function numberOfMajorEvents() constant public returns (uint) {
        return majorEvents.length;
    }

    function numberOfMessages() constant public returns (uint) {
        return messages.length;
    }

    // Create initial marriage contract
    function createMarriage(
        string _partner1,
        string _partner2,
        string _vows,
        string url) onlyOwner
    {
        require(majorEvents.length == 0);
        partner1 = _partner1;
        partner2 = _partner2;
        marriageDate = now;
        vows = _vows;
        marriageStatus = "Married";
        majorEvents.push(Event(now, "Marriage", vows, url));
        MajorEvent("Marrigage", vows, url);
    }

    // Set the marriage status if it changes
    function setStatus(string status, string url) onlyOwner
    {
        marriageStatus = status;
        setMajorEvent("Changed Status", status, url);
    }

    // Set the IPFS hash of the image of the couple
    function setMajorEvent(string name, string description, string url) onlyOwner areMarried
    {
        majorEvents.push(Event(now, name, description, url));
        MajorEvent(name, description, url);
    }

    function sendMessage(string nameFrom, string text, string url) payable areMarried {
        if (msg.value > 0) {
            owner.transfer(this.balance);
        }
        messages.push(Message(now, nameFrom, text, url, msg.value));
        MessageSent(nameFrom, text, url, msg.value);
    }


    // Declare event structure
    event MajorEvent(string name, string description, string url);
    event MessageSent(string name, string description, string url, uint value);
}