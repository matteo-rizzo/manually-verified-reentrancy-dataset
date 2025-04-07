/**

 *Submitted for verification at Etherscan.io on 2019-05-30

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





/// @title Utility Functions for bytes

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







/// @title ITradeHistory

/// @dev Stores the trade history and cancelled data of orders

/// @author Brecht Devos - <[email protected]>.

contract ITradeHistory {



    // The following map is used to keep trace of order fill and cancellation

    // history.

    mapping (bytes32 => uint) public filled;



    // This map is used to keep trace of order's cancellation history.

    mapping (address => mapping (bytes32 => bool)) public cancelled;



    // A map from a broker to its cutoff timestamp.

    mapping (address => uint) public cutoffs;



    // A map from a broker to its trading-pair cutoff timestamp.

    mapping (address => mapping (bytes20 => uint)) public tradingPairCutoffs;



    // A map from a broker to an order owner to its cutoff timestamp.

    mapping (address => mapping (address => uint)) public cutoffsOwner;



    // A map from a broker to an order owner to its trading-pair cutoff timestamp.

    mapping (address => mapping (address => mapping (bytes20 => uint))) public tradingPairCutoffsOwner;





    function batchUpdateFilled(

        bytes32[] calldata filledInfo

        )

        external;



    function setCancelled(

        address broker,

        bytes32 orderHash

        )

        external;



    function setCutoffs(

        address broker,

        uint cutoff

        )

        external;



    function setTradingPairCutoffs(

        address broker,

        bytes20 tokenPair,

        uint cutoff

        )

        external;



    function setCutoffsOfOwner(

        address broker,

        address owner,

        uint cutoff

        )

        external;



    function setTradingPairCutoffsOfOwner(

        address broker,

        address owner,

        bytes20 tokenPair,

        uint cutoff

        )

        external;



    function batchGetFilledAndCheckCancelled(

        bytes32[] calldata orderInfo

        )

        external

        view

        returns (uint[] memory fills);





    /// @dev Add a Loopring protocol address.

    /// @param addr A loopring protocol address.

    function authorizeAddress(

        address addr

        )

        external;



    /// @dev Remove a Loopring protocol address.

    /// @param addr A loopring protocol address.

    function deauthorizeAddress(

        address addr

        )

        external;



    function isAddressAuthorized(

        address addr

        )

        public

        view

        returns (bool);





    function suspend()

        external;



    function resume()

        external;



    function kill()

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







/// @title ITradeDelegate

/// @dev Acts as a middle man to transfer ERC20 tokens on behalf of different

/// versions of Loopring protocol to avoid ERC20 re-authorization.

/// @author Daniel Wang - <[email protected]>.

contract ITradeDelegate {



    function batchTransfer(

        bytes32[] calldata batch

        )

        external;





    /// @dev Add a Loopring protocol address.

    /// @param addr A loopring protocol address.

    function authorizeAddress(

        address addr

        )

        external;



    /// @dev Remove a Loopring protocol address.

    /// @param addr A loopring protocol address.

    function deauthorizeAddress(

        address addr

        )

        external;



    function isAddressAuthorized(

        address addr

        )

        public

        view

        returns (bool);





    function suspend()

        external;



    function resume()

        external;



    function kill()

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







/// @title IOrderRegistry

/// @author Daniel Wang - <[email protected]>.

contract IOrderRegistry {



    /// @dev   Returns wether the order hash was registered in the registry.

    /// @param broker The broker of the order

    /// @param orderHash The hash of the order

    /// @return True if the order hash was registered, else false.

    function isOrderHashRegistered(

        address broker,

        bytes32 orderHash

        )

        external

        view

        returns (bool);



    /// @dev   Registers an order in the registry.

    ///        msg.sender needs to be the broker of the order.

    /// @param orderHash The hash of the order

    function registerOrderHash(

        bytes32 orderHash

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







/// @title IOrderBook

/// @author Daniel Wang - <[email protected]>.

/// @author Kongliang Zhong - <[email protected]>.

contract IOrderBook {

    // The map of registered order hashes

    mapping(bytes32 => bool) public orderSubmitted;



    /// @dev  Event emitted when an order was successfully submitted

    ///        orderHash      The hash of the order

    ///        orderData      The data of the order as passed to submitOrder()

    event OrderSubmitted(

        bytes32 orderHash,

        bytes   orderData

    );



    /// @dev   Submits an order to the on-chain order book.

    ///        No signature is needed. The order can only be sumbitted by its

    ///        owner or its broker (the owner can be the address of a contract).

    /// @param orderData The data of the order. Contains all fields that are used

    ///        for the order hash calculation.

    ///        See OrderHelper.updateHash() for detailed information.

    function submitOrder(

        bytes calldata orderData

        )

        external

        returns (bytes32);

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







/// @author Brecht Devos - <[email protected]>

/// @title IBurnRateTable - A contract for managing burn rates for tokens

contract IBurnRateTable {



    struct TokenData {

        uint    tier;

        uint    validUntil;

    }



    mapping(address => TokenData) public tokens;



    uint public constant YEAR_TO_SECONDS = 31556952;



    // Tiers

    uint8 public constant TIER_4 = 0;

    uint8 public constant TIER_3 = 1;

    uint8 public constant TIER_2 = 2;

    uint8 public constant TIER_1 = 3;



    uint16 public constant BURN_BASE_PERCENTAGE           =                 100 * 10; // 100%



    // Cost of upgrading the tier level of a token in a percentage of the total LRC supply

    uint16 public constant TIER_UPGRADE_COST_PERCENTAGE   =                        1; // 0.1%



    // Burn rates

    // Matching

    uint16 public constant BURN_MATCHING_TIER1            =                       25; // 2.5%

    uint16 public constant BURN_MATCHING_TIER2            =                  15 * 10; //  15%

    uint16 public constant BURN_MATCHING_TIER3            =                  30 * 10; //  30%

    uint16 public constant BURN_MATCHING_TIER4            =                  50 * 10; //  50%

    // P2P

    uint16 public constant BURN_P2P_TIER1                 =                       25; // 2.5%

    uint16 public constant BURN_P2P_TIER2                 =                  15 * 10; //  15%

    uint16 public constant BURN_P2P_TIER3                 =                  30 * 10; //  30%

    uint16 public constant BURN_P2P_TIER4                 =                  50 * 10; //  50%



    event TokenTierUpgraded(

        address indexed addr,

        uint            tier

    );



    /// @dev   Returns the P2P and matching burn rate for the token.

    /// @param token The token to get the burn rate for.

    /// @return The burn rate. The P2P burn rate and matching burn rate

    ///         are packed together in the lowest 4 bytes.

    ///         (2 bytes P2P, 2 bytes matching)

    function getBurnRate(

        address token

        )

        external

        view

        returns (uint32 burnRate);



    /// @dev   Returns the tier of a token.

    /// @param token The token to get the token tier for.

    /// @return The tier of the token

    function getTokenTier(

        address token

        )

        public

        view

        returns (uint);



    /// @dev   Upgrades the tier of a token. Before calling this function,

    ///        msg.sender needs to approve this contract for the neccessary funds.

    /// @param token The token to upgrade the tier for.

    /// @return True if successful, false otherwise.

    function upgradeTokenTier(

        address token

        )

        external

        returns (bool);



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







/// @title IBrokerRegistry

/// @dev A broker is an account that can submit orders on behalf of other

///      accounts. When registering a broker, the owner can also specify a

///      pre-deployed BrokerInterceptor to hook into the exchange smart contracts.

/// @author Daniel Wang - <[email protected]>.

contract IBrokerRegistry {

    event BrokerRegistered(

        address owner,

        address broker,

        address interceptor

    );



    event BrokerUnregistered(

        address owner,

        address broker,

        address interceptor

    );



    event AllBrokersUnregistered(

        address owner

    );



    /// @dev   Validates if the broker was registered for the order owner and

    ///        returns the possible BrokerInterceptor to be used.

    /// @param owner The owner of the order

    /// @param broker The broker of the order

    /// @return True if the broker was registered for the owner

    ///         and the BrokerInterceptor to use.

    function getBroker(

        address owner,

        address broker

        )

        external

        view

        returns(

            bool registered,

            address interceptor

        );



    /// @dev   Gets all registered brokers for an owner.

    /// @param owner The owner

    /// @param start The start index of the list of brokers

    /// @param count The number of brokers to return

    /// @return The list of requested brokers and corresponding BrokerInterceptors

    function getBrokers(

        address owner,

        uint    start,

        uint    count

        )

        external

        view

        returns (

            address[] memory brokers,

            address[] memory interceptors

        );



    /// @dev   Registers a broker for msg.sender and an optional

    ///        corresponding BrokerInterceptor.

    /// @param broker The broker to register

    /// @param interceptor The optional BrokerInterceptor to use (0x0 allowed)

    function registerBroker(

        address broker,

        address interceptor

        )

        external;



    /// @dev   Unregisters a broker for msg.sender

    /// @param broker The broker to unregister

    function unregisterBroker(

        address broker

        )

        external;



    /// @dev   Unregisters all brokers for msg.sender

    function unregisterAllBrokers(

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











/// @title Utility Functions for Multihash signature verificaiton

/// @author Daniel Wang - <[email protected]>

/// For more information:

///   - https://github.com/saurfang/ipfs-multihash-on-solidity

///   - https://github.com/multiformats/multihash

///   - https://github.com/multiformats/js-multihash





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







/// @title ERC20 Token Interface

/// @dev see https://github.com/ethereum/EIPs/issues/20

/// @author Daniel Wang - <[email protected]>

contract ERC20 {

    function totalSupply()

        public

        view

        returns (uint256);



    function balanceOf(

        address who

        )

        public

        view

        returns (uint256);



    function allowance(

        address owner,

        address spender

        )

        public

        view

        returns (uint256);



    function transfer(

        address to,

        uint256 value

        )

        public

        returns (bool);



    function transferFrom(

        address from,

        address to,

        uint256 value

        )

        public

        returns (bool);



    function approve(

        address spender,

        uint256 value

        )

        public

        returns (bool);



    function verifyTransfer(

        address from,

        address to,

        uint256 amount,

        bytes memory data

        )

        public

        returns (bool);

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







/// @title IRingSubmitter

/// @author Daniel Wang - <[email protected]>

/// @author Kongliang Zhong - <[email protected]>

contract IRingSubmitter {

    uint16  public constant FEE_PERCENTAGE_BASE = 1000;



    /// @dev  Event emitted when a ring was successfully mined

    ///        _ringIndex     The index of the ring

    ///        _ringHash      The hash of the ring

    ///        _feeRecipient  The recipient of the matching fee

    ///        _fills         The info of the orders in the ring stored like:

    ///                       [orderHash, owner, tokenS, amountS, split, feeAmount, feeAmountS, feeAmountB]

    event RingMined(

        uint            _ringIndex,

        bytes32 indexed _ringHash,

        address indexed _feeRecipient,

        bytes           _fills

    );



    /// @dev   Event emitted when a ring was not successfully mined

    ///         _ringHash  The hash of the ring

    event InvalidRing(

        bytes32 _ringHash

    );



    /// @dev   Submit order-rings for validation and settlement.

    /// @param data Packed data of all rings.

    function submitRings(

        bytes calldata data

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













/// @title MiningHelper

/// @author Daniel Wang - <[email protected]>.





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

















/// @title OrderHelper

/// @author Daniel Wang - <[email protected]>.





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















/// @title ParticipationHelper

/// @author Daniel Wang - <[email protected]>.









/// @title RingHelper





























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













/// @title Deserializes the data passed to submitRings

/// @author Daniel Wang - <[email protected]>,









/// @title An Implementation of IRingSubmitter.

/// @author Daniel Wang - <[email protected]>,

/// @author Kongliang Zhong - <[email protected]>

/// @author Brechtpd - <[email protected]>

/// Recognized contributing developers from the community:

///     https://github.com/rainydio

///     https://github.com/BenjaminPrice

///     https://github.com/jonasshen

///     https://github.com/Hephyrius

contract RingSubmitter is IRingSubmitter, NoDefaultFunc {

    using MathUint      for uint;

    using BytesUtil     for bytes;

    using OrderHelper     for Data.Order;

    using RingHelper      for Data.Ring;

    using MiningHelper    for Data.Mining;



    address public constant lrcTokenAddress             = 0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD;

    address public constant wethTokenAddress            = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public constant delegateAddress             = 0xb258f5C190faDAB30B5fF0D6ab7E32a646A4BaAe;

    address public constant tradeHistoryAddress         = 0xBF5a37670B3DE1E606EC68bE3558c536b2008669;

    address public constant orderBrokerRegistryAddress  = 0x4e1E917F030556788AB3C9d8D0971Ebf0d5439E9;

    address public constant orderRegistryAddress        = 0x6fb707F15Ab3657Dc52776b057B33cB7D95e4E90;

    address public constant feeHolderAddress            = 0x5beaEA36efA78F43a6d61145817FDFf6A9929e60;

    address public constant orderBookAddress            = 0xaC0F8a27012fe8dc5a0bB7f5fc7170934F7e3577;

    address public constant burnRateTableAddress        = 0xA62ACd4ab0065daD489b6a459073ebfa50fEc46a;



    uint64  public  ringIndex                   = 0;



    uint    public constant MAX_RING_SIZE       = 8;



    struct SubmitRingsParam {

        uint16[]    encodeSpecs;

        uint16      miningSpec;

        uint16[]    orderSpecs;

        uint8[][]   ringSpecs;

        address[]   addressList;

        uint[]      uintList;

        bytes[]     bytesList;

    }



    /* constructor( */

    /*     address _lrcTokenAddress, */

    /*     address _wethTokenAddress, */

    /*     address _delegateAddress, */

    /*     address _tradeHistoryAddress, */

    /*     address _orderBrokerRegistryAddress, */

    /*     address _orderRegistryAddress, */

    /*     address _feeHolderAddress, */

    /*     address _orderBookAddress, */

    /*     address _burnRateTableAddress */

    /*     ) */

    /*     public */

    /* { */

    /*     require(_lrcTokenAddress != address(0x0), ZERO_ADDRESS); */

    /*     require(_wethTokenAddress != address(0x0), ZERO_ADDRESS); */

    /*     require(_delegateAddress != address(0x0), ZERO_ADDRESS); */

    /*     require(_tradeHistoryAddress != address(0x0), ZERO_ADDRESS); */

    /*     require(_orderBrokerRegistryAddress != address(0x0), ZERO_ADDRESS); */

    /*     require(_orderRegistryAddress != address(0x0), ZERO_ADDRESS); */

    /*     require(_feeHolderAddress != address(0x0), ZERO_ADDRESS); */

    /*     require(_orderBookAddress != address(0x0), ZERO_ADDRESS); */

    /*     require(_burnRateTableAddress != address(0x0), ZERO_ADDRESS); */



    /*     lrcTokenAddress = _lrcTokenAddress; */

    /*     wethTokenAddress = _wethTokenAddress; */

    /*     delegateAddress = _delegateAddress; */

    /*     tradeHistoryAddress = _tradeHistoryAddress; */

    /*     orderBrokerRegistryAddress = _orderBrokerRegistryAddress; */

    /*     orderRegistryAddress = _orderRegistryAddress; */

    /*     feeHolderAddress = _feeHolderAddress; */

    /*     orderBookAddress = _orderBookAddress; */

    /*     burnRateTableAddress = _burnRateTableAddress; */

    /* } */



    function submitRings(

        bytes calldata data

        )

        external

    {

        uint i;

        bytes32[] memory tokenBurnRates;

        Data.Context memory ctx = Data.Context(

            lrcTokenAddress,

            ITradeDelegate(delegateAddress),

            ITradeHistory(tradeHistoryAddress),

            IBrokerRegistry(orderBrokerRegistryAddress),

            IOrderRegistry(orderRegistryAddress),

            IFeeHolder(feeHolderAddress),

            IOrderBook(orderBookAddress),

            IBurnRateTable(burnRateTableAddress),

            ringIndex,

            FEE_PERCENTAGE_BASE,

            tokenBurnRates,

            0,

            0,

            0,

            0

        );



        // Check if the highest bit of ringIndex is '1'

        require((ctx.ringIndex >> 63) == 0, REENTRY);



        // Set the highest bit of ringIndex to '1' (IN STORAGE!)

        ringIndex = ctx.ringIndex | (1 << 63);



        (

            Data.Mining  memory mining,

            Data.Order[] memory orders,

            Data.Ring[]  memory rings

        ) = ExchangeDeserializer.deserialize(lrcTokenAddress, data);



        // Allocate memory that is used to batch things for all rings

        setupLists(ctx, orders, rings);



        for (i = 0; i < orders.length; i++) {

            orders[i].updateHash();

            orders[i].updateBrokerAndInterceptor(ctx);

        }



        batchGetFilledAndCheckCancelled(ctx, orders);



        for (i = 0; i < orders.length; i++) {

            orders[i].check(ctx);

            // An order can only be sent once

            for (uint j = i + 1; j < orders.length; j++) {

                require(orders[i].hash != orders[j].hash, INVALID_VALUE);

            }

        }



        for (i = 0; i < rings.length; i++) {

            rings[i].updateHash();

        }



        mining.updateHash(rings);

        mining.updateMinerAndInterceptor();

        require(mining.checkMinerSignature(), INVALID_SIG);



        for (i = 0; i < orders.length; i++) {

            // We don't need to verify the dual author signature again if it uses the same

            // dual author address as the previous order (the miner can optimize the order of the orders

            // so this happens as much as possible). We don't need to check if the signature is the same

            // because the same mining hash is signed for all orders.

            if(i > 0 && orders[i].dualAuthAddr == orders[i - 1].dualAuthAddr) {

                continue;

            }

            orders[i].checkDualAuthSignature(mining.hash);

        }



        for (i = 0; i < rings.length; i++) {

            Data.Ring memory ring = rings[i];

            ring.checkOrdersValid();

            ring.checkForSubRings();

            ring.calculateFillAmountAndFee(ctx);

            if (ring.valid) {

                ring.adjustOrderStates();

            }

        }



        // Check if the allOrNone orders are completely filled over all rings

        // This can invalidate rings

        checkRings(orders, rings);



        for (i = 0; i < rings.length; i++) {

            Data.Ring memory ring = rings[i];

            if (ring.valid) {

                // Only settle rings we have checked to be valid

                ring.doPayments(ctx, mining);

                emitRingMinedEvent(

                    ring,

                    ctx.ringIndex++,

                    mining.feeRecipient

                );

            } else {

                emit InvalidRing(ring.hash);

            }

        }



        // Do all token transfers for all rings

        batchTransferTokens(ctx);

        // Do all fee payments for all rings

        batchPayFees(ctx);

        // Update all order stats

        updateOrdersStats(ctx, orders);



        // Update ringIndex while setting the highest bit of ringIndex back to '0'

        ringIndex = ctx.ringIndex;

    }



    function checkRings(

        Data.Order[] memory orders,

        Data.Ring[] memory rings

        )

        internal

        pure

    {

        // Check if allOrNone orders are completely filled

        // When a ring is turned invalid because of an allOrNone order we have to

        // recheck the other rings again because they may contain other allOrNone orders

        // that may not be completely filled anymore.

        bool reevaluateRings = true;

        while (reevaluateRings) {

            reevaluateRings = false;

            for (uint i = 0; i < orders.length; i++) {

                if (orders[i].valid) {

                    orders[i].validateAllOrNone();

                    // Check if the order valid status has changed

                    reevaluateRings = reevaluateRings || !orders[i].valid;

                }

            }

            if (reevaluateRings) {

                for (uint i = 0; i < rings.length; i++) {

                    Data.Ring memory ring = rings[i];

                    if (ring.valid) {

                        ring.checkOrdersValid();

                        if (!ring.valid) {

                            // If the ring was valid before the completely filled check we have to revert the filled amountS

                            // of the orders in the ring. This is a bit awkward so maybe there's a better solution.

                            ring.revertOrderStats();

                        }

                    }

                }

            }

        }

    }



    function emitRingMinedEvent(

        Data.Ring memory ring,

        uint _ringIndex,

        address feeRecipient

        )

        internal

    {

        bytes32 ringHash = ring.hash;

        // keccak256("RingMined(uint256,bytes32,address,bytes)")

        bytes32 ringMinedSignature = 0xb2ef4bc5209dff0c46d5dfddb2b68a23bd4820e8f33107fde76ed15ba90695c9;

        uint fillsSize = ring.size * 8 * 32;



        uint data;

        uint ptr;

        assembly {

            data := mload(0x40)

            ptr := data

            mstore(ptr, _ringIndex)                     // ring index data

            mstore(add(ptr, 32), 0x40)                  // offset to fills data

            mstore(add(ptr, 64), fillsSize)             // fills length

            ptr := add(ptr, 96)

        }

        ptr = ring.generateFills(ptr);



        assembly {

            log3(

                data,                                   // data start

                sub(ptr, data),                         // data length

                ringMinedSignature,                     // Topic 0: RingMined signature

                ringHash,                               // Topic 1: ring hash

                feeRecipient                            // Topic 2: feeRecipient

            )

        }

    }



    function setupLists(

        Data.Context memory ctx,

        Data.Order[] memory orders,

        Data.Ring[] memory rings

        )

        internal

        pure

    {

        setupTokenBurnRateList(ctx, orders);

        setupFeePaymentList(ctx, rings);

        setupTokenTransferList(ctx, rings);

    }



    function setupTokenBurnRateList(

        Data.Context memory ctx,

        Data.Order[] memory orders

        )

        internal

        pure

    {

        // Allocate enough memory to store burn rates for all tokens even

        // if every token is unique (max 2 unique tokens / order)

        uint maxNumTokenBurnRates = orders.length * 2;

        bytes32[] memory tokenBurnRates;

        assembly {

            tokenBurnRates := mload(0x40)

            mstore(tokenBurnRates, 0)                               // tokenBurnRates.length

            mstore(0x40, add(

                tokenBurnRates,

                add(32, mul(maxNumTokenBurnRates, 64))

            ))

        }

        ctx.tokenBurnRates = tokenBurnRates;

    }



    function setupFeePaymentList(

        Data.Context memory ctx,

        Data.Ring[] memory rings

        )

        internal

        pure

    {

        uint totalMaxSizeFeePayments = 0;

        for (uint i = 0; i < rings.length; i++) {

            // Up to (ringSize + 3) * 3 payments per order (because of fee sharing by miner)

            // (3 x 32 bytes for every fee payment)

            uint ringSize = rings[i].size;

            uint maxSize = (ringSize + 3) * 3 * ringSize * 3;

            totalMaxSizeFeePayments += maxSize;

        }

        // Store the data directly in the call data format as expected by batchAddFeeBalances:

        // - 0x00: batchAddFeeBalances selector (4 bytes)

        // - 0x04: parameter offset (batchAddFeeBalances has a single function parameter) (32 bytes)

        // - 0x24: length of the array passed into the function (32 bytes)

        // - 0x44: the array data (32 bytes x length)

        bytes4 batchAddFeeBalancesSelector = ctx.feeHolder.batchAddFeeBalances.selector;

        uint ptr;

        assembly {

            let data := mload(0x40)

            mstore(data, batchAddFeeBalancesSelector)

            mstore(add(data, 4), 32)

            ptr := add(data, 68)

            mstore(0x40, add(ptr, mul(totalMaxSizeFeePayments, 32)))

        }

        ctx.feeData = ptr;

        ctx.feePtr = ptr;

    }



    function setupTokenTransferList(

        Data.Context memory ctx,

        Data.Ring[] memory rings

        )

        internal

        pure

    {

        uint totalMaxSizeTransfers = 0;

        for (uint i = 0; i < rings.length; i++) {

            // Up to 4 transfers per order

            // (4 x 32 bytes for every transfer)

            uint maxSize = 4 * rings[i].size * 4;

            totalMaxSizeTransfers += maxSize;

        }

        // Store the data directly in the call data format as expected by batchTransfer:

        // - 0x00: batchTransfer selector (4 bytes)

        // - 0x04: parameter offset (batchTransfer has a single function parameter) (32 bytes)

        // - 0x24: length of the array passed into the function (32 bytes)

        // - 0x44: the array data (32 bytes x length)

        bytes4 batchTransferSelector = ctx.delegate.batchTransfer.selector;

        uint ptr;

        assembly {

            let data := mload(0x40)

            mstore(data, batchTransferSelector)

            mstore(add(data, 4), 32)

            ptr := add(data, 68)

            mstore(0x40, add(ptr, mul(totalMaxSizeTransfers, 32)))

        }

        ctx.transferData = ptr;

        ctx.transferPtr = ptr;

    }



    function updateOrdersStats(

        Data.Context memory ctx,

        Data.Order[] memory orders

        )

        internal

    {

        // Store the data directly in the call data format as expected by batchUpdateFilled:

        // - 0x00: batchUpdateFilled selector (4 bytes)

        // - 0x04: parameter offset (batchUpdateFilled has a single function parameter) (32 bytes)

        // - 0x24: length of the array passed into the function (32 bytes)

        // - 0x44: the array data (32 bytes x length)

        // For every (valid) order we store 2 words:

        // - order.hash

        // - order.filledAmountS after all rings

        bytes4 batchUpdateFilledSelector = ctx.tradeHistory.batchUpdateFilled.selector;

        address _tradeHistoryAddress = address(ctx.tradeHistory);

        assembly {

            let data := mload(0x40)

            mstore(data, batchUpdateFilledSelector)

            mstore(add(data, 4), 32)

            let ptr := add(data, 68)

            let arrayLength := 0

            for { let i := 0 } lt(i, mload(orders)) { i := add(i, 1) } {

                let order := mload(add(orders, mul(add(i, 1), 32)))

                let filledAmount := mload(add(order, 928))                               // order.filledAmountS

                let initialFilledAmount := mload(add(order, 960))                        // order.initialFilledAmountS

                let filledAmountChanged := iszero(eq(filledAmount, initialFilledAmount))

                // if (order.valid && filledAmountChanged)

                if and(gt(mload(add(order, 992)), 0), filledAmountChanged) {             // order.valid

                    mstore(add(ptr,   0), mload(add(order, 864)))                        // order.hash

                    mstore(add(ptr,  32), filledAmount)



                    ptr := add(ptr, 64)

                    arrayLength := add(arrayLength, 2)

                }

            }



            // Only do the external call if the list is not empty

            if gt(arrayLength, 0) {

                mstore(add(data, 36), arrayLength)      // filledInfo.length



                let success := call(

                    gas,                                // forward all gas

                    _tradeHistoryAddress,               // external address

                    0,                                  // wei

                    data,                               // input start

                    sub(ptr, data),                     // input length

                    data,                               // output start

                    0                                   // output length

                )

                if eq(success, 0) {

                    // Propagate the revert message

                    returndatacopy(0, 0, returndatasize())

                    revert(0, returndatasize())

                }

            }

        }

    }



    function batchGetFilledAndCheckCancelled(

        Data.Context memory ctx,

        Data.Order[] memory orders

        )

        internal

    {

        // Store the data in the call data format as expected by batchGetFilledAndCheckCancelled:

        // - 0x00: batchGetFilledAndCheckCancelled selector (4 bytes)

        // - 0x04: parameter offset (batchGetFilledAndCheckCancelled has a single function parameter) (32 bytes)

        // - 0x24: length of the array passed into the function (32 bytes)

        // - 0x44: the array data (32 bytes x length)

        // For every order we store 5 words:

        // - order.broker

        // - order.owner

        // - order.hash

        // - order.validSince

        // - The trading pair of the order: order.tokenS ^ order.tokenB

        bytes4 batchGetFilledAndCheckCancelledSelector = ctx.tradeHistory.batchGetFilledAndCheckCancelled.selector;

        address _tradeHistoryAddress = address(ctx.tradeHistory);

        assembly {

            let data := mload(0x40)

            mstore(data, batchGetFilledAndCheckCancelledSelector)

            mstore(add(data,  4), 32)

            mstore(add(data, 36), mul(mload(orders), 5))                // orders.length

            let ptr := add(data, 68)

            for { let i := 0 } lt(i, mload(orders)) { i := add(i, 1) } {

                let order := mload(add(orders, mul(add(i, 1), 32)))     // orders[i]

                mstore(add(ptr,   0), mload(add(order, 320)))           // order.broker

                mstore(add(ptr,  32), mload(add(order,  32)))           // order.owner

                mstore(add(ptr,  64), mload(add(order, 864)))           // order.hash

                mstore(add(ptr,  96), mload(add(order, 192)))           // order.validSince

                // bytes20(order.tokenS) ^ bytes20(order.tokenB)        // tradingPair

                mstore(add(ptr, 128), mul(

                    xor(

                        mload(add(order, 64)),                 // order.tokenS

                        mload(add(order, 96))                  // order.tokenB

                    ),

                    0x1000000000000000000000000)               // shift left 12 bytes (bytes20 is padded on the right)

                )

                ptr := add(ptr, 160)                                    // 5 * 32

            }

            // Return data is stored just like the call data without the signature:

            // 0x00: Offset to data

            // 0x20: Array length

            // 0x40: Array data

            let returnDataSize := mul(add(2, mload(orders)), 32)

            let success := call(

                gas,                                // forward all gas

                _tradeHistoryAddress,               // external address

                0,                                  // wei

                data,                               // input start

                sub(ptr, data),                     // input length

                data,                               // output start

                returnDataSize                      // output length

            )

            // Check if the call was successful and the return data is the expected size

            if or(eq(success, 0), iszero(eq(returndatasize(), returnDataSize))) {

                if eq(success, 0) {

                    // Propagate the revert message

                    returndatacopy(0, 0, returndatasize())

                    revert(0, returndatasize())

                }

                revert(0, 0)

            }

            for { let i := 0 } lt(i, mload(orders)) { i := add(i, 1) } {

                let order := mload(add(orders, mul(add(i, 1), 32)))     // orders[i]

                let fill := mload(add(data,  mul(add(i, 2), 32)))       // fills[i]

                mstore(add(order, 928), fill)                           // order.filledAmountS

                mstore(add(order, 960), fill)                           // order.initialFilledAmountS

                // If fills[i] == ~uint(0) the order was cancelled

                // order.valid = order.valid && (order.filledAmountS != ~uint(0))

                mstore(add(order, 992),                                 // order.valid

                    and(

                        gt(mload(add(order, 992)), 0),                  // order.valid

                        iszero(eq(fill, not(0)))                        // fill != ~uint(0

                    )

                )

            }

        }

    }



    function batchTransferTokens(

        Data.Context memory ctx

        )

        internal

    {

        // Check if there are any transfers

        if (ctx.transferData == ctx.transferPtr) {

            return;

        }

        // We stored the token transfers in the call data as expected by batchTransfer.

        // The only thing we still need to do is update the final length of the array and call

        // the function on the TradeDelegate contract with the generated data.

        address _tradeDelegateAddress = address(ctx.delegate);

        uint arrayLength = (ctx.transferPtr - ctx.transferData) / 32;

        uint data = ctx.transferData - 68;

        uint ptr = ctx.transferPtr;

        assembly {

            mstore(add(data, 36), arrayLength)      // batch.length



            let success := call(

                gas,                                // forward all gas

                _tradeDelegateAddress,              // external address

                0,                                  // wei

                data,                               // input start

                sub(ptr, data),                     // input length

                data,                               // output start

                0                                   // output length

            )

            if eq(success, 0) {

                // Propagate the revert message

                returndatacopy(0, 0, returndatasize())

                revert(0, returndatasize())

            }

        }

    }



    function batchPayFees(

        Data.Context memory ctx

        )

        internal

    {

        // Check if there are any fee payments

        if (ctx.feeData == ctx.feePtr) {

            return;

        }

        // We stored the fee payments in the call data as expected by batchAddFeeBalances.

        // The only thing we still need to do is update the final length of the array and call

        // the function on the FeeHolder contract with the generated data.

        address _feeHolderAddress = address(ctx.feeHolder);

        uint arrayLength = (ctx.feePtr - ctx.feeData) / 32;

        uint data = ctx.feeData - 68;

        uint ptr = ctx.feePtr;

        assembly {

            mstore(add(data, 36), arrayLength)      // batch.length



            let success := call(

                gas,                                // forward all gas

                _feeHolderAddress,                  // external address

                0,                                  // wei

                data,                               // input start

                sub(ptr, data),                     // input length

                data,                               // output start

                0                                   // output length

            )

            if eq(success, 0) {

                // Propagate the revert message

                returndatacopy(0, 0, returndatasize())

                revert(0, returndatasize())

            }

        }

    }



}