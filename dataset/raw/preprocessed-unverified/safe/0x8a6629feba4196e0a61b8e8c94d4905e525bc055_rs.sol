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





// File: contracts/protocol/lib/Types.sol



/**

 * @title Types

 * @author dYdX

 *

 * Library for interacting with the basic structs used in Solo

 */





// File: contracts/protocol/lib/Interest.sol



/**

 * @title Interest

 * @author dYdX

 *

 * Library for managing the interest rate and interest indexes of Solo

 */





// File: contracts/protocol/interfaces/IInterestSetter.sol



/**

 * @title IInterestSetter

 * @author dYdX

 *

 * Interface that Interest Setters for Solo must implement in order to report interest rates.

 */





// File: contracts/protocol/lib/Monetary.sol



/**

 * @title Monetary

 * @author dYdX

 *

 * Library for types involving money

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



// File: contracts/protocol/lib/Account.sol



/**

 * @title Account

 * @author dYdX

 *

 * Library of structs and functions that represent an account

 */





// File: contracts/protocol/lib/Cache.sol



/**

 * @title Cache

 * @author dYdX

 *

 * Library for caching information about markets

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





// File: contracts/protocol/lib/Storage.sol



/**

 * @title Storage

 * @author dYdX

 *

 * Functions for reading, writing, and verifying state in Solo

 */





// File: contracts/protocol/impl/AdminImpl.sol



/**

 * @title AdminImpl

 * @author dYdX

 *

 * Administrative functions to keep the protocol updated

 */

