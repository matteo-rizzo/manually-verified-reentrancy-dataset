/**

 *Submitted for verification at Etherscan.io on 2019-05-07

*/



/*



    Copyright 2019 dYdX Trading Inc.



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

pragma experimental ABIEncoderV2;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





// File: contracts/protocol/lib/Require.sol



/**

 * @title Require

 * @author dYdX

 *

 * Stringifies parameters to pretty-print revert messages. Costs more gas than regular require()

 */





// File: contracts/protocol/lib/Math.sol



/**

 * @title Math

 * @author dYdX

 *

 * Library for non-standard Math functions

 */





// File: contracts/protocol/lib/Types.sol



/**

 * @title Types

 * @author dYdX

 *

 * Library for interacting with the basic structs used in Solo

 */





// File: contracts/protocol/lib/Account.sol



/**

 * @title Account

 * @author dYdX

 *

 * Library of structs and functions that represent an account

 */





// File: contracts/protocol/interfaces/IAutoTrader.sol



/**

 * @title IAutoTrader

 * @author dYdX

 *

 * Interface that Auto-Traders for Solo must implement in order to approve trades.

 */

contract IAutoTrader {



    // ============ Public Functions ============



    /**

     * Allows traders to make trades approved by this smart contract. The active trader's account is

     * the takerAccount and the passive account (for which this contract approves trades

     * on-behalf-of) is the makerAccount.

     *

     * @param  inputMarketId   The market for which the trader specified the original amount

     * @param  outputMarketId  The market for which the trader wants the resulting amount specified

     * @param  makerAccount    The account for which this contract is making trades

     * @param  takerAccount    The account requesting the trade

     * @param  oldInputPar     The old principal amount for the makerAccount for the inputMarketId

     * @param  newInputPar     The new principal amount for the makerAccount for the inputMarketId

     * @param  inputWei        The change in token amount for the makerAccount for the inputMarketId

     * @param  data            Arbitrary data passed in by the trader

     * @return                 The AssetAmount for the makerAccount for the outputMarketId

     */

    function getTradeCost(

        uint256 inputMarketId,

        uint256 outputMarketId,

        Account.Info memory makerAccount,

        Account.Info memory takerAccount,

        Types.Par memory oldInputPar,

        Types.Par memory newInputPar,

        Types.Wei memory inputWei,

        bytes memory data

    )

        public

        returns (Types.AssetAmount memory);

}



// File: contracts/protocol/interfaces/ICallee.sol



/**

 * @title ICallee

 * @author dYdX

 *

 * Interface that Callees for Solo must implement in order to ingest data.

 */

contract ICallee {



    // ============ Public Functions ============



    /**

     * Allows users to send this contract arbitrary data.

     *

     * @param  sender       The msg.sender to Solo

     * @param  accountInfo  The account from which the data is being sent

     * @param  data         Arbitrary data given by the sender

     */

    function callFunction(

        address sender,

        Account.Info memory accountInfo,

        bytes memory data

    )

        public;

}



// File: contracts/protocol/lib/Actions.sol



/**

 * @title Actions

 * @author dYdX

 *

 * Library that defines and parses valid Actions

 */





// File: contracts/protocol/lib/Monetary.sol



/**

 * @title Monetary

 * @author dYdX

 *

 * Library for types involving money

 */





// File: contracts/protocol/lib/Cache.sol



/**

 * @title Cache

 * @author dYdX

 *

 * Library for caching information about markets

 */





// File: contracts/protocol/lib/Decimal.sol



/**

 * @title Decimal

 * @author dYdX

 *

 * Library that defines a fixed-point number with 18 decimal places.

 */





// File: contracts/protocol/lib/Time.sol



/**

 * @title Time

 * @author dYdX

 *

 * Library for dealing with time, assuming timestamps fit within 32 bits (valid until year 2106)

 */





// File: contracts/protocol/lib/Interest.sol



/**

 * @title Interest

 * @author dYdX

 *

 * Library for managing the interest rate and interest indexes of Solo

 */





// File: contracts/protocol/interfaces/IErc20.sol



/**

 * @title IErc20

 * @author dYdX

 *

 * Interface for using ERC20 Tokens. We have to use a special interface to call ERC20 functions so

 * that we don't automatically revert when calling non-compliant tokens that have no return value for

 * transfer(), transferFrom(), or approve().

 */





// File: contracts/protocol/lib/Token.sol



/**

 * @title Token

 * @author dYdX

 *

 * This library contains basic functions for interacting with ERC20 tokens. Modified to work with

 * tokens that don't adhere strictly to the ERC20 standard (for example tokens that don't return a

 * boolean value on success).

 */





// File: contracts/protocol/interfaces/IInterestSetter.sol



/**

 * @title IInterestSetter

 * @author dYdX

 *

 * Interface that Interest Setters for Solo must implement in order to report interest rates.

 */





// File: contracts/protocol/interfaces/IPriceOracle.sol



/**

 * @title IPriceOracle

 * @author dYdX

 *

 * Interface that Price Oracles for Solo must implement in order to report prices.

 */

contract IPriceOracle {



    // ============ Constants ============



    uint256 public constant ONE_DOLLAR = 10 ** 36;



    // ============ Public Functions ============



    /**

     * Get the price of a token

     *

     * @param  token  The ERC20 token address of the market

     * @return        The USD price of a base unit of the token, then multiplied by 10^36.

     *                So a USD-stable coin with 18 decimal places would return 10^18.

     *                This is the price of the base unit rather than the price of a "human-readable"

     *                token amount. Every ERC20 may have a different number of decimals.

     */

    function getPrice(

        address token

    )

        public

        view

        returns (Monetary.Price memory);

}



// File: contracts/protocol/lib/Storage.sol



/**

 * @title Storage

 * @author dYdX

 *

 * Functions for reading, writing, and verifying state in Solo

 */





// File: contracts/protocol/lib/Events.sol



/**

 * @title Events

 * @author dYdX

 *

 * Library to parse and emit logs from which the state of all accounts and indexes can be followed

 */





// File: contracts/protocol/interfaces/IExchangeWrapper.sol



/**

 * @title IExchangeWrapper

 * @author dYdX

 *

 * Interface that Exchange Wrappers for Solo must implement in order to trade ERC20 tokens.

 */





// File: contracts/protocol/lib/Exchange.sol



/**

 * @title Exchange

 * @author dYdX

 *

 * Library for transferring tokens and interacting with ExchangeWrappers by using the Wei struct

 */





// File: contracts/protocol/impl/OperationImpl.sol



/**

 * @title OperationImpl

 * @author dYdX

 *

 * Logic for processing actions

 */

