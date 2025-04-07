/**

 *Submitted for verification at Etherscan.io on 2018-09-05

*/



pragma solidity ^0.4.24;







contract FeedPrice is Ownable {

    

    address public sourcePrice ;

    

    constructor ( address _sourcePrice ) public {

        setSourcePrice(_sourcePrice);

    }

    

    function setSourcePrice( address _sourcePrice ) public onlyOwner returns (bool) {

        require( _sourcePrice != address(0), "The address of source's price cannot be 0." );

        sourcePrice = _sourcePrice;

        return true;

    }

    

    function read(bytes32 _currency) view public returns (uint256 value) {

        value = SourcePrice(sourcePrice).read(_currency);

    }

    

}



contract SourcePrice {

    mapping (bytes32 => address) public sourceContract;



    constructor (address _sourceContract) public {

        sourceContract[ keccak256( abi.encodePacked( "usd" ) ) ] = _sourceContract;

    }

    

    function read(bytes32 _currency) view public returns (uint256 value) {

        address source = sourceContract[ _currency ];

        if( source != address(0) ) { 

            value = uint256( EndPointInterface(source).read()  );

        } else {

            revert("Not implemented source's price.");

        }

    }

}



contract EndPointInterface {

    function read() view public returns (bytes32);

}