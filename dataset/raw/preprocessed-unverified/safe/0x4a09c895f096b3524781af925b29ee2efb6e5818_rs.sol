/**
 *Submitted for verification at Etherscan.io on 2021-02-27
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;






contract ConvertToken {

    mapping( address => uint256 ) public Converted ;    
    IERC20 OldToken ;   //PXT
    IERC20 NewToken ;   //PAIR

    constructor(address oldToken , address newToken ) public {
        OldToken = IERC20( oldToken ) ;
        NewToken = IERC20( newToken ) ;
    }

    function convertToken(uint amount ) public {
        require( amount > 0 , "no param." ) ;
        address sender = msg.sender ;
        // OldToken.transferFrom( sender , address(this) , amount ) ;
        if( OldToken.transferFrom( sender , address(this) , amount ) ){
            NewToken.transfer( sender, amount ) ;
            Converted[ sender ] = Converted[sender] + amount ;   //Log.
        }
    }

}