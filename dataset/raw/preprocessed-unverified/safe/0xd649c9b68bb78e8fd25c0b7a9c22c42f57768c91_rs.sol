/**

 *Submitted for verification at Etherscan.io on 2018-10-07

*/



pragma solidity ^0.4.25;



// ----------------------------------------------------------------------------

// BokkyPooBah's Pricefeed from a single source

//

// Deployed to: 0xD649c9b68BB78e8fd25c0B7a9c22c42f57768c91

//

// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018. The MIT Licence.

// ----------------------------------------------------------------------------







// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------







// ----------------------------------------------------------------------------

// Maintain a list of operators that are permissioned to execute certain

// functions

// ----------------------------------------------------------------------------

contract Operated is Owned {

    mapping(address => bool) public operators;



    event OperatorAdded(address _operator);

    event OperatorRemoved(address _operator);



    modifier onlyOperator() {

        require(operators[msg.sender] || owner == msg.sender);

        _;

    }



    function initOperated(address _owner) internal {

        initOwned(_owner);

    }

    function addOperator(address _operator) public onlyOwner {

        require(!operators[_operator]);

        operators[_operator] = true;

        emit OperatorAdded(_operator);

    }

    function removeOperator(address _operator) public onlyOwner {

        require(operators[_operator]);

        delete operators[_operator];

        emit OperatorRemoved(_operator);

    }

}



// ----------------------------------------------------------------------------

// PriceFeed Interface - _live is true if the rate is valid, false if invalid

// ----------------------------------------------------------------------------

contract PriceFeedInterface {

    function name() public view returns (string);

    function getRate() public view returns (uint _rate, bool _live);

}





// ----------------------------------------------------------------------------

// Pricefeed from a single source

// ----------------------------------------------------------------------------

contract PriceFeed is PriceFeedInterface, Operated {

    string private _name;

    uint private _rate;

    bool private _live;



    event SetRate(uint oldRate, bool oldLive, uint newRate, bool newLive);



    constructor(string name, uint rate, bool live) public {

        initOperated(msg.sender);

        _name = name;

        _rate = rate;

        _live = live;

        emit SetRate(0, false, _rate, _live);

    }

    function name() public view returns (string) {

        return _name;

    }

    function setRate(uint rate, bool live) public onlyOperator {

        emit SetRate(_rate, _live, rate, live);

        _rate = rate;

        _live = live;

    }

    function getRate() public view returns (uint rate, bool live) {

        return (_rate, _live);

    }

}