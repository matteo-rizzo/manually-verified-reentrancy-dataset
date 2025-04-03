/**

 *Submitted for verification at Etherscan.io on 2018-12-08

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





// File: contracts/ExternalCall.sol







// File: contracts/ISetToken.sol



/*

    Copyright 2018 Set Labs Inc.



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



pragma solidity ^0.4.24;



/**

 * @title ISetToken

 * @author Set Protocol

 *

 * The ISetToken interface provides a light-weight, structured way to interact with the

 * SetToken contract from another contract.

 */





// File: contracts/SetBuyer.sol



contract IKyberNetworkProxy {

    function tradeWithHint(

        address src,

        uint256 srcAmount,

        address dest,

        address destAddress,

        uint256 maxDestAmount,

        uint256 minConversionRate,

        address walletId,

        bytes hint

    )

        public

        payable

        returns(uint);



    function getExpectedRate(

        address source,

        address dest,

        uint srcQty

    )

        public

        view

        returns (

            uint expectedPrice,

            uint slippagePrice

        );

}





contract SetBuyer {

    using SafeMath for uint256;

    using ExternalCall for address;



    address constant public ETHER_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;



    function buy(

        ISetToken set,

        IKyberNetworkProxy kyber

    )

        public

        payable

    {

        address[] memory components = set.getComponents();

        uint256[] memory units = set.getUnits();



        uint256 weightSum = 0;

        uint256[] memory weight = new uint256[](components.length);

        for (uint i = 0; i < components.length; i++) {

            (weight[i], ) = kyber.getExpectedRate(components[i], ETHER_ADDRESS, units[i]);

            weightSum = weightSum.add(weight[i]);

        }



        uint256 fitMintAmount = uint256(-1);

        for (i = 0; i < components.length; i++) {

            uint256 amount = msg.value.mul(weight[i]).div(weightSum);

            uint256 received = kyber.tradeWithHint.value(amount)(

                ETHER_ADDRESS,

                amount,

                components[i],

                this,

                1 << 255,

                0,

                0,

                ""

            );



            if (received / units[i] < fitMintAmount) {

                fitMintAmount = received / units[i];

            }

        }



        set.mint(msg.sender, fitMintAmount);



        if (address(this).balance > 0) {

            msg.sender.transfer(address(this).balance);

        }

        for (i = 0; i < components.length; i++) {

            IERC20 token = IERC20(components[i]);

            if (token.balanceOf(this) > 0) {

                require(token.transfer(msg.sender, token.balanceOf(this)), "transfer failed");

            }

        }

    }



    function() public payable {

        require(tx.origin != msg.sender);

    }



    // function sell(

    //     ISetToken set,

    //     uint256 amount,

    //     bytes callDatas,

    //     uint[] starts // including 0 and LENGTH values

    // )

    //     public

    // {

    //     set.burn(msg.sender, amount);



    //     change(callDatas, starts);



    //     address[] memory components = set.getComponents();



    //     if (address(this).balance > 0) {

    //         msg.sender.transfer(address(this).balance);

    //     }

    //     for (uint i = 0; i < components.length; i++) {

    //         IERC20 token = IERC20(components[i]);

    //         if (token.balanceOf(this) > 0) {

    //             require(token.transfer(msg.sender, token.balanceOf(this)), "transfer failed");

    //         }

    //     }

    // }

}