pragma solidity 0.4.24;


//base on //import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




/**
* @dev This is my personal contract
*/
contract DZariusz is Ownable {


    string public name;
    string public contact;

    event LogSetName(address indexed executor, string newName);
    event LogSetContact(address indexed executor, string newContact);


    constructor(string _name, string _contact) public {

        setName(_name);
        setContact(_contact);

    }



    function setName(string _name)
    public
    onlyOwner
    returns (bool)
    {
        name = _name;
        emit LogSetName(msg.sender, _name);

        return true;
    }



    function setContact(string _contact)
    public
    onlyOwner
    returns (bool)
    {
        contact = _contact;
        emit LogSetContact(msg.sender, _contact);

        return true;
    }



}