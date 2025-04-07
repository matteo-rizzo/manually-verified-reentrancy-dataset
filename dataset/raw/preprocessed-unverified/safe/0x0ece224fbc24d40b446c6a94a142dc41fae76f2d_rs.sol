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





// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

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



// File: contracts/protocol/lib/Decimal.sol



/**

 * @title Decimal

 * @author dYdX

 *

 * Library that defines a fixed-point number with 18 decimal places.

 */





// File: contracts/protocol/lib/Monetary.sol



/**

 * @title Monetary

 * @author dYdX

 *

 * Library for types involving money

 */





// File: contracts/protocol/lib/Time.sol



/**

 * @title Time

 * @author dYdX

 *

 * Library for dealing with time, assuming timestamps fit within 32 bits (valid until year 2106)

 */





// File: openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol



/**

 * @title Helps contracts guard against reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>

 * @dev If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {

    /// @dev counter to allow mutex lock with only one SSTORE operation

    uint256 private _guardCounter;



    constructor () internal {

        // The counter starts at one to prevent changing it from zero to a non-zero

        // value, which is a more expensive operation.

        _guardCounter = 1;

    }



    /**

     * @dev Prevents a contract from calling itself, directly or indirectly.

     * Calling a `nonReentrant` function from another `nonReentrant`

     * function is not supported. It is possible to prevent this from happening

     * by making the `nonReentrant` function external, and make it call a

     * `private` function that does the actual work.

     */

    modifier nonReentrant() {

        _guardCounter += 1;

        uint256 localCounter = _guardCounter;

        _;

        require(localCounter == _guardCounter);

    }

}



// File: contracts/protocol/lib/Cache.sol



/**

 * @title Cache

 * @author dYdX

 *

 * Library for caching information about markets

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





// File: contracts/protocol/State.sol



/**

 * @title State

 * @author dYdX

 *

 * Base-level contract that holds the state of Solo

 */

contract State

{

    Storage.State g_state;

}



// File: contracts/protocol/impl/AdminImpl.sol



/**

 * @title AdminImpl

 * @author dYdX

 *

 * Administrative functions to keep the protocol updated

 */





// File: contracts/protocol/Admin.sol



/**

 * @title Admin

 * @author dYdX

 *

 * Public functions that allow the privileged owner address to manage Solo

 */

contract Admin is

    State,

    Ownable,

    ReentrancyGuard

{

    // ============ Token Functions ============



    /**

     * Withdraw an ERC20 token for which there is an associated market. Only excess tokens can be

     * withdrawn. The number of excess tokens is calculated by taking the current number of tokens

     * held in Solo, adding the number of tokens owed to Solo by borrowers, and subtracting the

     * number of tokens owed to suppliers by Solo.

     */

    function ownerWithdrawExcessTokens(

        uint256 marketId,

        address recipient

    )

        public

        onlyOwner

        nonReentrant

        returns (uint256)

    {

        return AdminImpl.ownerWithdrawExcessTokens(

            g_state,

            marketId,

            recipient

        );

    }



    /**

     * Withdraw an ERC20 token for which there is no associated market.

     */

    function ownerWithdrawUnsupportedTokens(

        address token,

        address recipient

    )

        public

        onlyOwner

        nonReentrant

        returns (uint256)

    {

        return AdminImpl.ownerWithdrawUnsupportedTokens(

            g_state,

            token,

            recipient

        );

    }



    // ============ Market Functions ============



    /**

     * Add a new market to Solo. Must be for a previously-unsupported ERC20 token.

     */

    function ownerAddMarket(

        address token,

        IPriceOracle priceOracle,

        IInterestSetter interestSetter,

        Decimal.D256 memory marginPremium,

        Decimal.D256 memory spreadPremium

    )

        public

        onlyOwner

        nonReentrant

    {

        AdminImpl.ownerAddMarket(

            g_state,

            token,

            priceOracle,

            interestSetter,

            marginPremium,

            spreadPremium

        );

    }



    /**

     * Set (or unset) the status of a market to "closing". The borrowedValue of a market cannot

     * increase while its status is "closing".

     */

    function ownerSetIsClosing(

        uint256 marketId,

        bool isClosing

    )

        public

        onlyOwner

        nonReentrant

    {

        AdminImpl.ownerSetIsClosing(

            g_state,

            marketId,

            isClosing

        );

    }



    /**

     * Set the price oracle for a market.

     */

    function ownerSetPriceOracle(

        uint256 marketId,

        IPriceOracle priceOracle

    )

        public

        onlyOwner

        nonReentrant

    {

        AdminImpl.ownerSetPriceOracle(

            g_state,

            marketId,

            priceOracle

        );

    }



    /**

     * Set the interest-setter for a market.

     */

    function ownerSetInterestSetter(

        uint256 marketId,

        IInterestSetter interestSetter

    )

        public

        onlyOwner

        nonReentrant

    {

        AdminImpl.ownerSetInterestSetter(

            g_state,

            marketId,

            interestSetter

        );

    }



    /**

     * Set a premium on the minimum margin-ratio for a market. This makes it so that any positions

     * that include this market require a higher collateralization to avoid being liquidated.

     */

    function ownerSetMarginPremium(

        uint256 marketId,

        Decimal.D256 memory marginPremium

    )

        public

        onlyOwner

        nonReentrant

    {

        AdminImpl.ownerSetMarginPremium(

            g_state,

            marketId,

            marginPremium

        );

    }



    /**

     * Set a premium on the liquidation spread for a market. This makes it so that any liquidations

     * that include this market have a higher spread than the global default.

     */

    function ownerSetSpreadPremium(

        uint256 marketId,

        Decimal.D256 memory spreadPremium

    )

        public

        onlyOwner

        nonReentrant

    {

        AdminImpl.ownerSetSpreadPremium(

            g_state,

            marketId,

            spreadPremium

        );

    }



    // ============ Risk Functions ============



    /**

     * Set the global minimum margin-ratio that every position must maintain to prevent being

     * liquidated.

     */

    function ownerSetMarginRatio(

        Decimal.D256 memory ratio

    )

        public

        onlyOwner

        nonReentrant

    {

        AdminImpl.ownerSetMarginRatio(

            g_state,

            ratio

        );

    }



    /**

     * Set the global liquidation spread. This is the spread between oracle prices that incentivizes

     * the liquidation of risky positions.

     */

    function ownerSetLiquidationSpread(

        Decimal.D256 memory spread

    )

        public

        onlyOwner

        nonReentrant

    {

        AdminImpl.ownerSetLiquidationSpread(

            g_state,

            spread

        );

    }



    /**

     * Set the global earnings-rate variable that determines what percentage of the interest paid

     * by borrowers gets passed-on to suppliers.

     */

    function ownerSetEarningsRate(

        Decimal.D256 memory earningsRate

    )

        public

        onlyOwner

        nonReentrant

    {

        AdminImpl.ownerSetEarningsRate(

            g_state,

            earningsRate

        );

    }



    /**

     * Set the global minimum-borrow value which is the minimum value of any new borrow on Solo.

     */

    function ownerSetMinBorrowedValue(

        Monetary.Value memory minBorrowedValue

    )

        public

        onlyOwner

        nonReentrant

    {

        AdminImpl.ownerSetMinBorrowedValue(

            g_state,

            minBorrowedValue

        );

    }



    // ============ Global Operator Functions ============



    /**

     * Approve (or disapprove) an address that is permissioned to be an operator for all accounts in

     * Solo. Intended only to approve smart-contracts.

     */

    function ownerSetGlobalOperator(

        address operator,

        bool approved

    )

        public

        onlyOwner

        nonReentrant

    {

        AdminImpl.ownerSetGlobalOperator(

            g_state,

            operator,

            approved

        );

    }

}



// File: contracts/protocol/Getters.sol



/**

 * @title Getters

 * @author dYdX

 *

 * Public read-only functions that allow transparency into the state of Solo

 */

contract Getters is

    State

{

    using Cache for Cache.MarketCache;

    using Storage for Storage.State;

    using Types for Types.Par;



    // ============ Constants ============



    bytes32 FILE = "Getters";



    // ============ Getters for Risk ============



    /**

     * Get the global minimum margin-ratio that every position must maintain to prevent being

     * liquidated.

     *

     * @return  The global margin-ratio

     */

    function getMarginRatio()

        public

        view

        returns (Decimal.D256 memory)

    {

        return g_state.riskParams.marginRatio;

    }



    /**

     * Get the global liquidation spread. This is the spread between oracle prices that incentivizes

     * the liquidation of risky positions.

     *

     * @return  The global liquidation spread

     */

    function getLiquidationSpread()

        public

        view

        returns (Decimal.D256 memory)

    {

        return g_state.riskParams.liquidationSpread;

    }



    /**

     * Get the global earnings-rate variable that determines what percentage of the interest paid

     * by borrowers gets passed-on to suppliers.

     *

     * @return  The global earnings rate

     */

    function getEarningsRate()

        public

        view

        returns (Decimal.D256 memory)

    {

        return g_state.riskParams.earningsRate;

    }



    /**

     * Get the global minimum-borrow value which is the minimum value of any new borrow on Solo.

     *

     * @return  The global minimum borrow value

     */

    function getMinBorrowedValue()

        public

        view

        returns (Monetary.Value memory)

    {

        return g_state.riskParams.minBorrowedValue;

    }



    /**

     * Get all risk parameters in a single struct.

     *

     * @return  All global risk parameters

     */

    function getRiskParams()

        public

        view

        returns (Storage.RiskParams memory)

    {

        return g_state.riskParams;

    }



    /**

     * Get all risk parameter limits in a single struct. These are the maximum limits at which the

     * risk parameters can be set by the admin of Solo.

     *

     * @return  All global risk parameter limnits

     */

    function getRiskLimits()

        public

        view

        returns (Storage.RiskLimits memory)

    {

        return g_state.riskLimits;

    }



    // ============ Getters for Markets ============



    /**

     * Get the total number of markets.

     *

     * @return  The number of markets

     */

    function getNumMarkets()

        public

        view

        returns (uint256)

    {

        return g_state.numMarkets;

    }



    /**

     * Get the ERC20 token address for a market.

     *

     * @param  marketId  The market to query

     * @return           The token address

     */

    function getMarketTokenAddress(

        uint256 marketId

    )

        public

        view

        returns (address)

    {

        _requireValidMarket(marketId);

        return g_state.getToken(marketId);

    }



    /**

     * Get the total principal amounts (borrowed and supplied) for a market.

     *

     * @param  marketId  The market to query

     * @return           The total principal amounts

     */

    function getMarketTotalPar(

        uint256 marketId

    )

        public

        view

        returns (Types.TotalPar memory)

    {

        _requireValidMarket(marketId);

        return g_state.getTotalPar(marketId);

    }



    /**

     * Get the most recently cached interest index for a market.

     *

     * @param  marketId  The market to query

     * @return           The most recent index

     */

    function getMarketCachedIndex(

        uint256 marketId

    )

        public

        view

        returns (Interest.Index memory)

    {

        _requireValidMarket(marketId);

        return g_state.getIndex(marketId);

    }



    /**

     * Get the interest index for a market if it were to be updated right now.

     *

     * @param  marketId  The market to query

     * @return           The estimated current index

     */

    function getMarketCurrentIndex(

        uint256 marketId

    )

        public

        view

        returns (Interest.Index memory)

    {

        _requireValidMarket(marketId);

        return g_state.fetchNewIndex(marketId, g_state.getIndex(marketId));

    }



    /**

     * Get the price oracle address for a market.

     *

     * @param  marketId  The market to query

     * @return           The price oracle address

     */

    function getMarketPriceOracle(

        uint256 marketId

    )

        public

        view

        returns (IPriceOracle)

    {

        _requireValidMarket(marketId);

        return g_state.markets[marketId].priceOracle;

    }



    /**

     * Get the interest-setter address for a market.

     *

     * @param  marketId  The market to query

     * @return           The interest-setter address

     */

    function getMarketInterestSetter(

        uint256 marketId

    )

        public

        view

        returns (IInterestSetter)

    {

        _requireValidMarket(marketId);

        return g_state.markets[marketId].interestSetter;

    }



    /**

     * Get the margin premium for a market. A margin premium makes it so that any positions that

     * include the market require a higher collateralization to avoid being liquidated.

     *

     * @param  marketId  The market to query

     * @return           The market's margin premium

     */

    function getMarketMarginPremium(

        uint256 marketId

    )

        public

        view

        returns (Decimal.D256 memory)

    {

        _requireValidMarket(marketId);

        return g_state.markets[marketId].marginPremium;

    }



    /**

     * Get the spread premium for a market. A spread premium makes it so that any liquidations

     * that include the market have a higher spread than the global default.

     *

     * @param  marketId  The market to query

     * @return           The market's spread premium

     */

    function getMarketSpreadPremium(

        uint256 marketId

    )

        public

        view

        returns (Decimal.D256 memory)

    {

        _requireValidMarket(marketId);

        return g_state.markets[marketId].spreadPremium;

    }



    /**

     * Return true if a particular market is in closing mode. Additional borrows cannot be taken

     * from a market that is closing.

     *

     * @param  marketId  The market to query

     * @return           True if the market is closing

     */

    function getMarketIsClosing(

        uint256 marketId

    )

        public

        view

        returns (bool)

    {

        _requireValidMarket(marketId);

        return g_state.markets[marketId].isClosing;

    }



    /**

     * Get the price of the token for a market.

     *

     * @param  marketId  The market to query

     * @return           The price of each atomic unit of the token

     */

    function getMarketPrice(

        uint256 marketId

    )

        public

        view

        returns (Monetary.Price memory)

    {

        _requireValidMarket(marketId);

        return g_state.fetchPrice(marketId);

    }



    /**

     * Get the current borrower interest rate for a market.

     *

     * @param  marketId  The market to query

     * @return           The current interest rate

     */

    function getMarketInterestRate(

        uint256 marketId

    )

        public

        view

        returns (Interest.Rate memory)

    {

        _requireValidMarket(marketId);

        return g_state.fetchInterestRate(

            marketId,

            g_state.getIndex(marketId)

        );

    }



    /**

     * Get the adjusted liquidation spread for some market pair. This is equal to the global

     * liquidation spread multiplied by (1 + spreadPremium) for each of the two markets.

     *

     * @param  heldMarketId  The market for which the account has collateral

     * @param  owedMarketId  The market for which the account has borrowed tokens

     * @return               The adjusted liquidation spread

     */

    function getLiquidationSpreadForPair(

        uint256 heldMarketId,

        uint256 owedMarketId

    )

        public

        view

        returns (Decimal.D256 memory)

    {

        _requireValidMarket(heldMarketId);

        _requireValidMarket(owedMarketId);

        return g_state.getLiquidationSpreadForPair(heldMarketId, owedMarketId);

    }



    /**

     * Get basic information about a particular market.

     *

     * @param  marketId  The market to query

     * @return           A Storage.Market struct with the current state of the market

     */

    function getMarket(

        uint256 marketId

    )

        public

        view

        returns (Storage.Market memory)

    {

        _requireValidMarket(marketId);

        return g_state.markets[marketId];

    }



    /**

     * Get comprehensive information about a particular market.

     *

     * @param  marketId  The market to query

     * @return           A tuple containing the values:

     *                    - A Storage.Market struct with the current state of the market

     *                    - The current estimated interest index

     *                    - The current token price

     *                    - The current market interest rate

     */

    function getMarketWithInfo(

        uint256 marketId

    )

        public

        view

        returns (

            Storage.Market memory,

            Interest.Index memory,

            Monetary.Price memory,

            Interest.Rate memory

        )

    {

        _requireValidMarket(marketId);

        return (

            getMarket(marketId),

            getMarketCurrentIndex(marketId),

            getMarketPrice(marketId),

            getMarketInterestRate(marketId)

        );

    }



    /**

     * Get the number of excess tokens for a market. The number of excess tokens is calculated

     * by taking the current number of tokens held in Solo, adding the number of tokens owed to Solo

     * by borrowers, and subtracting the number of tokens owed to suppliers by Solo.

     *

     * @param  marketId  The market to query

     * @return           The number of excess tokens

     */

    function getNumExcessTokens(

        uint256 marketId

    )

        public

        view

        returns (Types.Wei memory)

    {

        _requireValidMarket(marketId);

        return g_state.getNumExcessTokens(marketId);

    }



    // ============ Getters for Accounts ============



    /**

     * Get the principal value for a particular account and market.

     *

     * @param  account   The account to query

     * @param  marketId  The market to query

     * @return           The principal value

     */

    function getAccountPar(

        Account.Info memory account,

        uint256 marketId

    )

        public

        view

        returns (Types.Par memory)

    {

        _requireValidMarket(marketId);

        return g_state.getPar(account, marketId);

    }



    /**

     * Get the token balance for a particular account and market.

     *

     * @param  account   The account to query

     * @param  marketId  The market to query

     * @return           The token amount

     */

    function getAccountWei(

        Account.Info memory account,

        uint256 marketId

    )

        public

        view

        returns (Types.Wei memory)

    {

        _requireValidMarket(marketId);

        return Interest.parToWei(

            g_state.getPar(account, marketId),

            g_state.fetchNewIndex(marketId, g_state.getIndex(marketId))

        );

    }



    /**

     * Get the status of an account (Normal, Liquidating, or Vaporizing).

     *

     * @param  account  The account to query

     * @return          The account's status

     */

    function getAccountStatus(

        Account.Info memory account

    )

        public

        view

        returns (Account.Status)

    {

        return g_state.getStatus(account);

    }



    /**

     * Get the total supplied and total borrowed value of an account.

     *

     * @param  account  The account to query

     * @return          The following values:

     *                   - The supplied value of the account

     *                   - The borrowed value of the account

     */

    function getAccountValues(

        Account.Info memory account

    )

        public

        view

        returns (Monetary.Value memory, Monetary.Value memory)

    {

        return getAccountValuesInternal(account, /* adjustForLiquidity = */ false);

    }



    /**

     * Get the total supplied and total borrowed values of an account adjusted by the marginPremium

     * of each market. Supplied values are divided by (1 + marginPremium) for each market and

     * borrowed values are multiplied by (1 + marginPremium) for each market. Comparing these

     * adjusted values gives the margin-ratio of the account which will be compared to the global

     * margin-ratio when determining if the account can be liquidated.

     *

     * @param  account  The account to query

     * @return          The following values:

     *                   - The supplied value of the account (adjusted for marginPremium)

     *                   - The borrowed value of the account (adjusted for marginPremium)

     */

    function getAdjustedAccountValues(

        Account.Info memory account

    )

        public

        view

        returns (Monetary.Value memory, Monetary.Value memory)

    {

        return getAccountValuesInternal(account, /* adjustForLiquidity = */ true);

    }



    /**

     * Get an account's summary for each market.

     *

     * @param  account  The account to query

     * @return          The following values:

     *                   - The ERC20 token address for each market

     *                   - The account's principal value for each market

     *                   - The account's (supplied or borrowed) number of tokens for each market

     */

    function getAccountBalances(

        Account.Info memory account

    )

        public

        view

        returns (

            address[] memory,

            Types.Par[] memory,

            Types.Wei[] memory

        )

    {

        uint256 numMarkets = g_state.numMarkets;

        address[] memory tokens = new address[](numMarkets);

        Types.Par[] memory pars = new Types.Par[](numMarkets);

        Types.Wei[] memory weis = new Types.Wei[](numMarkets);



        for (uint256 m = 0; m < numMarkets; m++) {

            tokens[m] = getMarketTokenAddress(m);

            pars[m] = getAccountPar(account, m);

            weis[m] = getAccountWei(account, m);

        }



        return (

            tokens,

            pars,

            weis

        );

    }



    // ============ Getters for Permissions ============



    /**

     * Return true if a particular address is approved as an operator for an owner's accounts.

     * Approved operators can act on the accounts of the owner as if it were the operator's own.

     *

     * @param  owner     The owner of the accounts

     * @param  operator  The possible operator

     * @return           True if operator is approved for owner's accounts

     */

    function getIsLocalOperator(

        address owner,

        address operator

    )

        public

        view

        returns (bool)

    {

        return g_state.isLocalOperator(owner, operator);

    }



    /**

     * Return true if a particular address is approved as a global operator. Such an address can

     * act on any account as if it were the operator's own.

     *

     * @param  operator  The address to query

     * @return           True if operator is a global operator

     */

    function getIsGlobalOperator(

        address operator

    )

        public

        view

        returns (bool)

    {

        return g_state.isGlobalOperator(operator);

    }



    // ============ Private Helper Functions ============



    /**

     * Revert if marketId is invalid.

     */

    function _requireValidMarket(

        uint256 marketId

    )

        private

        view

    {

        Require.that(

            marketId < g_state.numMarkets,

            FILE,

            "Market OOB"

        );

    }



    /**

     * Private helper for getting the monetary values of an account.

     */

    function getAccountValuesInternal(

        Account.Info memory account,

        bool adjustForLiquidity

    )

        private

        view

        returns (Monetary.Value memory, Monetary.Value memory)

    {

        uint256 numMarkets = g_state.numMarkets;



        // populate cache

        Cache.MarketCache memory cache = Cache.create(numMarkets);

        for (uint256 m = 0; m < numMarkets; m++) {

            if (!g_state.getPar(account, m).isZero()) {

                cache.addMarket(g_state, m);

            }

        }



        return g_state.getAccountValues(account, cache, adjustForLiquidity);

    }

}



// File: contracts/protocol/lib/Actions.sol



/**

 * @title Actions

 * @author dYdX

 *

 * Library that defines and parses valid Actions

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





// File: contracts/protocol/Operation.sol



/**

 * @title Operation

 * @author dYdX

 *

 * Primary public function for allowing users and contracts to manage accounts within Solo

 */

contract Operation is

    State,

    ReentrancyGuard

{

    // ============ Public Functions ============



    /**

     * The main entry-point to Solo that allows users and contracts to manage accounts.

     * Take one or more actions on one or more accounts. The msg.sender must be the owner or

     * operator of all accounts except for those being liquidated, vaporized, or traded with.

     * One call to operate() is considered a singular "operation". Account collateralization is

     * ensured only after the completion of the entire operation.

     *

     * @param  accounts  A list of all accounts that will be used in this operation. Cannot contain

     *                   duplicates. In each action, the relevant account will be referred-to by its

     *                   index in the list.

     * @param  actions   An ordered list of all actions that will be taken in this operation. The

     *                   actions will be processed in order.

     */

    function operate(

        Account.Info[] memory accounts,

        Actions.ActionArgs[] memory actions

    )

        public

        nonReentrant

    {

        OperationImpl.operate(

            g_state,

            accounts,

            actions

        );

    }

}



// File: contracts/protocol/Permission.sol



/**

 * @title Permission

 * @author dYdX

 *

 * Public function that allows other addresses to manage accounts

 */

contract Permission is

    State

{

    // ============ Events ============



    event LogOperatorSet(

        address indexed owner,

        address operator,

        bool trusted

    );



    // ============ Structs ============



    struct OperatorArg {

        address operator;

        bool trusted;

    }



    // ============ Public Functions ============



    /**

     * Approves/disapproves any number of operators. An operator is an external address that has the

     * same permissions to manipulate an account as the owner of the account. Operators are simply

     * addresses and therefore may either be externally-owned Ethereum accounts OR smart contracts.

     *

     * Operators are also able to act as AutoTrader contracts on behalf of the account owner if the

     * operator is a smart contract and implements the IAutoTrader interface.

     *

     * @param  args  A list of OperatorArgs which have an address and a boolean. The boolean value

     *               denotes whether to approve (true) or revoke approval (false) for that address.

     */

    function setOperators(

        OperatorArg[] memory args

    )

        public

    {

        for (uint256 i = 0; i < args.length; i++) {

            address operator = args[i].operator;

            bool trusted = args[i].trusted;

            g_state.operators[msg.sender][operator] = trusted;

            emit LogOperatorSet(msg.sender, operator, trusted);

        }

    }

}



// File: contracts/protocol/SoloMargin.sol



/**

 * @title SoloMargin

 * @author dYdX

 *

 * Main contract that inherits from other contracts

 */

contract SoloMargin is

    State,

    Admin,

    Getters,

    Operation,

    Permission

{

    // ============ Constructor ============



    constructor(

        Storage.RiskParams memory riskParams,

        Storage.RiskLimits memory riskLimits

    )

        public

    {

        g_state.riskParams = riskParams;

        g_state.riskLimits = riskLimits;

    }

}



// File: contracts/external/helpers/OnlySolo.sol



/**

 * @title OnlySolo

 * @author dYdX

 *

 * Inheritable contract that restricts the calling of certain functions to Solo only

 */

contract OnlySolo {



    // ============ Constants ============



    bytes32 constant FILE = "OnlySolo";



    // ============ Storage ============



    SoloMargin public SOLO_MARGIN;



    // ============ Constructor ============



    constructor (

        address soloMargin

    )

        public

    {

        SOLO_MARGIN = SoloMargin(soloMargin);

    }



    // ============ Modifiers ============



    modifier onlySolo(address from) {

        Require.that(

            from == address(SOLO_MARGIN),

            FILE,

            "Only Solo can call function",

            from

        );

        _;

    }

}



// File: contracts/external/traders/Expiry.sol



/**

 * @title Expiry

 * @author dYdX

 *

 * Sets the negative balance for an account to expire at a certain time. This allows any other

 * account to repay that negative balance after expiry using any positive balance in the same

 * account. The arbitrage incentive is the same as liquidation in the base protocol.

 */

contract Expiry is

    Ownable,

    OnlySolo,

    ICallee,

    IAutoTrader

{

    using SafeMath for uint32;

    using SafeMath for uint256;

    using Types for Types.Par;

    using Types for Types.Wei;



    // ============ Constants ============



    bytes32 constant FILE = "Expiry";



    // ============ Events ============



    event ExpirySet(

        address owner,

        uint256 number,

        uint256 marketId,

        uint32 time

    );



    event LogExpiryRampTimeSet(

        uint256 expiryRampTime

    );



    // ============ Storage ============



    // owner => number => market => time

    mapping (address => mapping (uint256 => mapping (uint256 => uint32))) g_expiries;



    // time over which the liquidation ratio goes from zero to maximum

    uint256 public g_expiryRampTime;



    // ============ Constructor ============



    constructor (

        address soloMargin,

        uint256 expiryRampTime

    )

        public

        OnlySolo(soloMargin)

    {

        g_expiryRampTime = expiryRampTime;

    }



    // ============ Owner Functions ============



    function ownerSetExpiryRampTime(

        uint256 newExpiryRampTime

    )

        external

        onlyOwner

    {

        emit LogExpiryRampTimeSet(newExpiryRampTime);

        g_expiryRampTime = newExpiryRampTime;

    }



    // ============ Getters ============



    function getExpiry(

        Account.Info memory account,

        uint256 marketId

    )

        public

        view

        returns (uint32)

    {

        return g_expiries[account.owner][account.number][marketId];

    }



    function getSpreadAdjustedPrices(

        uint256 heldMarketId,

        uint256 owedMarketId,

        uint32 expiry

    )

        public

        view

        returns (

            Monetary.Price memory,

            Monetary.Price memory

        )

    {

        Decimal.D256 memory spread = SOLO_MARGIN.getLiquidationSpreadForPair(

            heldMarketId,

            owedMarketId

        );



        uint256 expiryAge = Time.currentTime().sub(expiry);



        if (expiryAge < g_expiryRampTime) {

            spread.value = Math.getPartial(spread.value, expiryAge, g_expiryRampTime);

        }



        Monetary.Price memory heldPrice = SOLO_MARGIN.getMarketPrice(heldMarketId);

        Monetary.Price memory owedPrice = SOLO_MARGIN.getMarketPrice(owedMarketId);

        owedPrice.value = owedPrice.value.add(Decimal.mul(owedPrice.value, spread));



        return (heldPrice, owedPrice);

    }



    // ============ Only-Solo Functions ============



    function callFunction(

        address /* sender */,

        Account.Info memory account,

        bytes memory data

    )

        public

        onlySolo(msg.sender)

    {

        (

            uint256 marketId,

            uint32 expiryTime

        ) = parseCallArgs(data);



        // don't set expiry time for accounts with positive balance

        if (expiryTime != 0 && !SOLO_MARGIN.getAccountPar(account, marketId).isNegative()) {

            return;

        }



        setExpiry(account, marketId, expiryTime);

    }



    function getTradeCost(

        uint256 inputMarketId,

        uint256 outputMarketId,

        Account.Info memory makerAccount,

        Account.Info memory /* takerAccount */,

        Types.Par memory oldInputPar,

        Types.Par memory newInputPar,

        Types.Wei memory inputWei,

        bytes memory data

    )

        public

        onlySolo(msg.sender)

        returns (Types.AssetAmount memory)

    {

        // return zero if input amount is zero

        if (inputWei.isZero()) {

            return Types.AssetAmount({

                sign: true,

                denomination: Types.AssetDenomination.Par,

                ref: Types.AssetReference.Delta,

                value: 0

            });

        }



        (

            uint256 owedMarketId,

            uint32 maxExpiry

        ) = parseTradeArgs(data);



        uint32 expiry = getExpiry(makerAccount, owedMarketId);



        // validate expiry

        Require.that(

            expiry != 0,

            FILE,

            "Expiry not set",

            makerAccount.owner,

            makerAccount.number,

            owedMarketId

        );

        Require.that(

            expiry <= Time.currentTime(),

            FILE,

            "Borrow not yet expired",

            expiry

        );

        Require.that(

            expiry <= maxExpiry,

            FILE,

            "Expiry past maxExpiry",

            expiry

        );



        return getTradeCostInternal(

            inputMarketId,

            outputMarketId,

            makerAccount,

            oldInputPar,

            newInputPar,

            inputWei,

            owedMarketId,

            expiry

        );

    }



    // ============ Private Functions ============



    function getTradeCostInternal(

        uint256 inputMarketId,

        uint256 outputMarketId,

        Account.Info memory makerAccount,

        Types.Par memory oldInputPar,

        Types.Par memory newInputPar,

        Types.Wei memory inputWei,

        uint256 owedMarketId,

        uint32 expiry

    )

        private

        returns (Types.AssetAmount memory)

    {

        Types.AssetAmount memory output;

        Types.Wei memory maxOutputWei = SOLO_MARGIN.getAccountWei(makerAccount, outputMarketId);



        if (inputWei.isPositive()) {

            Require.that(

                inputMarketId == owedMarketId,

                FILE,

                "inputMarket mismatch",

                inputMarketId

            );

            Require.that(

                !newInputPar.isPositive(),

                FILE,

                "Borrows cannot be overpaid",

                newInputPar.value

            );

            assert(oldInputPar.isNegative());

            Require.that(

                maxOutputWei.isPositive(),

                FILE,

                "Collateral must be positive",

                outputMarketId,

                maxOutputWei.value

            );

            output = owedWeiToHeldWei(

                inputWei,

                outputMarketId,

                inputMarketId,

                expiry

            );



            // clear expiry if borrow is fully repaid

            if (newInputPar.isZero()) {

                setExpiry(makerAccount, owedMarketId, 0);

            }

        } else {

            Require.that(

                outputMarketId == owedMarketId,

                FILE,

                "outputMarket mismatch",

                outputMarketId

            );

            Require.that(

                !newInputPar.isNegative(),

                FILE,

                "Collateral cannot be overused",

                newInputPar.value

            );

            assert(oldInputPar.isPositive());

            Require.that(

                maxOutputWei.isNegative(),

                FILE,

                "Borrows must be negative",

                outputMarketId,

                maxOutputWei.value

            );

            output = heldWeiToOwedWei(

                inputWei,

                inputMarketId,

                outputMarketId,

                expiry

            );



            // clear expiry if borrow is fully repaid

            if (output.value == maxOutputWei.value) {

                setExpiry(makerAccount, owedMarketId, 0);

            }

        }



        Require.that(

            output.value <= maxOutputWei.value,

            FILE,

            "outputMarket too small",

            output.value,

            maxOutputWei.value

        );

        assert(output.sign != maxOutputWei.sign);



        return output;

    }



    function setExpiry(

        Account.Info memory account,

        uint256 marketId,

        uint32 time

    )

        private

    {

        g_expiries[account.owner][account.number][marketId] = time;



        emit ExpirySet(

            account.owner,

            account.number,

            marketId,

            time

        );

    }



    function heldWeiToOwedWei(

        Types.Wei memory heldWei,

        uint256 heldMarketId,

        uint256 owedMarketId,

        uint32 expiry

    )

        private

        view

        returns (Types.AssetAmount memory)

    {

        (

            Monetary.Price memory heldPrice,

            Monetary.Price memory owedPrice

        ) = getSpreadAdjustedPrices(

            heldMarketId,

            owedMarketId,

            expiry

        );



        uint256 owedAmount = Math.getPartialRoundUp(

            heldWei.value,

            heldPrice.value,

            owedPrice.value

        );



        return Types.AssetAmount({

            sign: true,

            denomination: Types.AssetDenomination.Wei,

            ref: Types.AssetReference.Delta,

            value: owedAmount

        });

    }



    function owedWeiToHeldWei(

        Types.Wei memory owedWei,

        uint256 heldMarketId,

        uint256 owedMarketId,

        uint32 expiry

    )

        private

        view

        returns (Types.AssetAmount memory)

    {

        (

            Monetary.Price memory heldPrice,

            Monetary.Price memory owedPrice

        ) = getSpreadAdjustedPrices(

            heldMarketId,

            owedMarketId,

            expiry

        );



        uint256 heldAmount = Math.getPartial(

            owedWei.value,

            owedPrice.value,

            heldPrice.value

        );



        return Types.AssetAmount({

            sign: false,

            denomination: Types.AssetDenomination.Wei,

            ref: Types.AssetReference.Delta,

            value: heldAmount

        });

    }



    function parseCallArgs(

        bytes memory data

    )

        private

        pure

        returns (

            uint256,

            uint32

        )

    {

        Require.that(

            data.length == 64,

            FILE,

            "Call data invalid length",

            data.length

        );



        uint256 marketId;

        uint256 rawExpiry;



        /* solium-disable-next-line security/no-inline-assembly */

        assembly {

            marketId := mload(add(data, 32))

            rawExpiry := mload(add(data, 64))

        }



        return (

            marketId,

            Math.to32(rawExpiry)

        );

    }



    function parseTradeArgs(

        bytes memory data

    )

        private

        pure

        returns (

            uint256,

            uint32

        )

    {

        Require.that(

            data.length == 64,

            FILE,

            "Trade data invalid length",

            data.length

        );



        uint256 owedMarketId;

        uint256 rawExpiry;



        /* solium-disable-next-line security/no-inline-assembly */

        assembly {

            owedMarketId := mload(add(data, 32))

            rawExpiry := mload(add(data, 64))

        }



        return (

            owedMarketId,

            Math.to32(rawExpiry)

        );

    }

}