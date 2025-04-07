/**
 *Submitted for verification at Etherscan.io on 2019-11-18
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

// File: contracts/external/traders/DaiMigrator.sol

/**
 * @title DaiMigrator
 * @author dYdX
 *
 * Allows for moving SAI positions to DAI positions.
 */
contract DaiMigrator is
    Ownable,
    IAutoTrader
{
    using Types for Types.Wei;
    using Types for Types.Par;

    // ============ Constants ============

    bytes32 constant FILE = "DaiMigrator";

    uint256 constant SAI_MARKET = 1;

    uint256 constant DAI_MARKET = 3;

    // ============ Events ============

    event LogMigratorAdded(
        address migrator
    );

    event LogMigratorRemoved(
        address migrator
    );

    // ============ Storage ============

    // the addresses that are able to migrate positions
    mapping (address => bool) public g_migrators;

    // ============ Constructor ============

    constructor (
        address[] memory migrators
    )
        public
    {
        for (uint256 i = 0; i < migrators.length; i++) {
            g_migrators[migrators[i]] = true;
        }
    }

    // ============ Admin Functions ============

    function addMigrator(
        address migrator
    )
        external
        onlyOwner
    {
        emit LogMigratorAdded(migrator);
        g_migrators[migrator] = true;
    }

    function removeMigrator(
        address migrator
    )
        external
        onlyOwner
    {
        emit LogMigratorRemoved(migrator);
        g_migrators[migrator] = false;
    }

    // ============ Only-Solo Functions ============

    function getTradeCost(
        uint256 inputMarketId,
        uint256 outputMarketId,
        Account.Info memory /* makerAccount */,
        Account.Info memory takerAccount,
        Types.Par memory oldInputPar,
        Types.Par memory newInputPar,
        Types.Wei memory inputWei,
        bytes memory /* data */
    )
        public
        /* view */
        returns (Types.AssetAmount memory)
    {
        Require.that(
            g_migrators[takerAccount.owner],
            FILE,
            "Migrator not approved",
            takerAccount.owner
        );

        Require.that(
            inputMarketId == SAI_MARKET && outputMarketId == DAI_MARKET,
            FILE,
            "Invalid markets"
        );

        // require that SAI amount is getting smaller (closer to zero)
        if (oldInputPar.isPositive()) {
            Require.that(
                inputWei.isNegative(),
                FILE,
                "inputWei must be negative"
            );
            Require.that(
                !newInputPar.isNegative(),
                FILE,
                "newInputPar cannot be negative"
            );
        } else if (oldInputPar.isNegative()) {
            Require.that(
                inputWei.isPositive(),
                FILE,
                "inputWei must be positive"
            );
            Require.that(
                !newInputPar.isPositive(),
                FILE,
                "newInputPar cannot be positive"
            );
        } else {
            Require.that(
                inputWei.isZero() && newInputPar.isZero(),
                FILE,
                "inputWei must be zero"
            );
        }

        /* return the exact opposite amount of SAI in DAI */
        return Types.AssetAmount ({
            sign: !inputWei.sign,
            denomination: Types.AssetDenomination.Wei,
            ref: Types.AssetReference.Delta,
            value: inputWei.value
        });
    }
}