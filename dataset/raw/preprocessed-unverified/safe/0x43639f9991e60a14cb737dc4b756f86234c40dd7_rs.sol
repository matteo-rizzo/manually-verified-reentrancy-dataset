/**

 *Submitted for verification at Etherscan.io on 2019-05-29

*/



/*



  Copyright 2017 Loopring Project Ltd (Loopring Foundation).



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



pragma solidity 0.5.7;



/*



  Copyright 2017 Loopring Project Ltd (Loopring Foundation).



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







/// @author Kongliang Zhong - <[email protected]>

/// @title IFeeHolder - A contract holding fees.

contract IFeeHolder {



    event TokenWithdrawn(

        address owner,

        address token,

        uint value

    );



    // A map of all fee balances

    mapping(address => mapping(address => uint)) public feeBalances;



    /// @dev   Allows withdrawing the tokens to be burned by

    ///        authorized contracts.

    /// @param token The token to be used to burn buy and burn LRC

    /// @param value The amount of tokens to withdraw

    function withdrawBurned(

        address token,

        uint value

        )

        external

        returns (bool success);



    /// @dev   Allows withdrawing the fee payments funds

    ///        msg.sender is the recipient of the fee and the address

    ///        to which the tokens will be sent.

    /// @param token The token to withdraw

    /// @param value The amount of tokens to withdraw

    function withdrawToken(

        address token,

        uint value

        )

        external

        returns (bool success);



    function batchAddFeeBalances(

        bytes32[] calldata batch

        )

        external;

}



/*



  Copyright 2017 Loopring Project Ltd (Loopring Foundation).



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







/// @title ERC20 safe transfer

/// @dev see https://github.com/sec-bit/badERC20Fix

/// @author Brecht Devos - <[email protected]>



/*



  Copyright 2017 Loopring Project Ltd (Loopring Foundation).



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







/// @title Utility Functions for uint

/// @author Daniel Wang - <[email protected]>





/*



  Copyright 2017 Loopring Project Ltd (Loopring Foundation).



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





/*



  Copyright 2017 Loopring Project Ltd (Loopring Foundation).



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







/// @title Errors

contract Errors {

    string constant ZERO_VALUE                 = "ZERO_VALUE";

    string constant ZERO_ADDRESS               = "ZERO_ADDRESS";

    string constant INVALID_VALUE              = "INVALID_VALUE";

    string constant INVALID_ADDRESS            = "INVALID_ADDRESS";

    string constant INVALID_SIZE               = "INVALID_SIZE";

    string constant INVALID_SIG                = "INVALID_SIG";

    string constant INVALID_STATE              = "INVALID_STATE";

    string constant NOT_FOUND                  = "NOT_FOUND";

    string constant ALREADY_EXIST              = "ALREADY_EXIST";

    string constant REENTRY                    = "REENTRY";

    string constant UNAUTHORIZED               = "UNAUTHORIZED";

    string constant UNIMPLEMENTED              = "UNIMPLEMENTED";

    string constant UNSUPPORTED                = "UNSUPPORTED";

    string constant TRANSFER_FAILURE           = "TRANSFER_FAILURE";

    string constant WITHDRAWAL_FAILURE         = "WITHDRAWAL_FAILURE";

    string constant BURN_FAILURE               = "BURN_FAILURE";

    string constant BURN_RATE_FROZEN           = "BURN_RATE_FROZEN";

    string constant BURN_RATE_MINIMIZED        = "BURN_RATE_MINIMIZED";

    string constant UNAUTHORIZED_ONCHAIN_ORDER = "UNAUTHORIZED_ONCHAIN_ORDER";

    string constant INVALID_CANDIDATE          = "INVALID_CANDIDATE";

    string constant ALREADY_VOTED              = "ALREADY_VOTED";

    string constant NOT_OWNER                  = "NOT_OWNER";

}







/// @title NoDefaultFunc

/// @dev Disable default functions.

contract NoDefaultFunc is Errors {

    function ()

        external

        payable

    {

        revert(UNSUPPORTED);

    }

}







/// @author Brecht Devos - <[email protected]>

contract BurnManager is NoDefaultFunc {

    using MathUint for uint;

    using ERC20SafeTransfer for address;



    address public constant feeHolderAddress = 0x5beaEA36efA78F43a6d61145817FDFf6A9929e60;

    address public constant lrcAddress = 0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD;



    /* constructor( */

    /*     address _feeHolderAddress, */

    /*     address _lrcAddress */

    /*     ) */

    /*     public */

    /* { */

    /*     require(_feeHolderAddress != address(0x0), ZERO_ADDRESS); */

    /*     require(_lrcAddress != address(0x0), ZERO_ADDRESS); */

    /*     feeHolderAddress = _feeHolderAddress; */

    /*     lrcAddress = _lrcAddress; */

    /* } */



    function burn(

        address token

        )

        external

        returns (bool)

    {

        IFeeHolder feeHolder = IFeeHolder(feeHolderAddress);



        // Withdraw the complete token balance

        uint balance = feeHolder.feeBalances(token, feeHolderAddress);

        bool success = feeHolder.withdrawBurned(token, balance);

        require(success, WITHDRAWAL_FAILURE);



        // We currently only support burning LRC directly

        if (token != lrcAddress) {

            require(false, UNIMPLEMENTED);

        }



        // Burn the LRC

        require(

            lrcAddress.safeTransfer(

                address(0x0),

                balance

            ),

            BURN_FAILURE

        );



        return true;

    }



}