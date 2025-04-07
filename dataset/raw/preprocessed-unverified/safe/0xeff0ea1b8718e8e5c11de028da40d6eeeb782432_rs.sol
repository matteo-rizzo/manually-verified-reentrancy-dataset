/*



  Copyright 2018 Ethfinex Inc



  This is a derivative work based on software developed by ZeroEx Intl

  This and the original are licensed under Apache License, Version 2.0



  Original attribution:



  Copyright 2017 ZeroEx Intl.



  Licensed under the Apache License, Version 2.0 (the "License");

  you may not use this file except in compliance with the License.

  You may obtain a copy of the License at



    http://www.apache.org/licenses/LICENSE-2.0



  Unless required by applicable law or agreed to in writing, software

  distributed under the License is distributed on an "AS IS" BASIS,

  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

  See the License for the specific language governing permissions and

  limitations under the License.



*/



pragma solidity 0.4.19;









//solhint-disable-next-line

/// @title TokenTransferProxy - Transfers tokens on behalf of exchange

/// @author Ahmed Ali <[emailÂ protected]>

contract TokenTransferProxy {



    modifier onlyExchange {

        require(msg.sender == exchangeAddress);

        _;

    }



    address public exchangeAddress;





    event LogAuthorizedAddressAdded(address indexed target, address indexed caller);



    function TokenTransferProxy() public {

        setExchange(msg.sender);

    }

    /*

     * Public functions

     */



    /// @dev Calls into ERC20 Token contract, invoking transferFrom.

    /// @param token Address of token to transfer.

    /// @param from Address to transfer token from.

    /// @param to Address to transfer token to.

    /// @param value Amount of token to transfer.

    /// @return Success of transfer.

    function transferFrom(

        address token,

        address from,

        address to,

        uint value)

        public

        onlyExchange

        returns (bool)

    {

        return Token(token).transferFrom(from, to, value);

    }



    /// @dev Used to set exchange address

    /// @param _exchange the address of the exchange

    function setExchange(address _exchange) internal {

        require(exchangeAddress == address(0));

        exchangeAddress = _exchange;

    }

}