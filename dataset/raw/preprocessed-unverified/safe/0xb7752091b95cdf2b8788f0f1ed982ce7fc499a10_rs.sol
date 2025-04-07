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

// File: contracts/external/Maker/Other/IScdMcdMigration.sol

/**
 * @title IScdMcdMigration
 * @author dYdX
 *
 * Interface for the SAI <-> DAI migration contract from MakerDao
 */


// File: contracts/interfaces/ExchangeWrapper.sol

/**
 * @title ExchangeWrapper
 * @author dYdX
 *
 * Contract interface that Exchange Wrapper smart contracts must implement in order to interface
 * with other smart contracts through a common interface.
 */


// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */


// File: contracts/lib/MathHelpers.sol

/**
 * @title MathHelpers
 * @author dYdX
 *
 * This library helps with common math functions in Solidity
 */


// File: contracts/lib/GeneralERC20.sol

/**
 * @title GeneralERC20
 * @author dYdX
 *
 * Interface for using ERC20 Tokens. We have to use a special interface to call ERC20 functions so
 * that we dont automatically revert when calling non-compliant tokens that have no return value for
 * transfer(), transferFrom(), or approve().
 */


// File: contracts/lib/TokenInteract.sol

/**
 * @title TokenInteract
 * @author dYdX
 *
 * This library contains basic functions for interacting with ERC20 tokens
 */


// File: contracts/lib/AdvancedTokenInteract.sol

/**
 * @title AdvancedTokenInteract
 * @author dYdX
 *
 * This library contains advanced functions for interacting with ERC20 tokens
 */


// File: contracts/exchange-wrappers/SaiDaiExchangeWrapper.sol

/**
 * @title SaiDaiExchangeWrapper
 * @author dYdX
 *
 * dYdX ExchangeWrapper to interface with Maker's ScdMcdMigration contract
 */
/**
 * @title SaiDaiExchangeWrapper
 * @author dYdX
 *
 * dYdX ExchangeWrapper to interface with Maker's ScdMcdMigration contract
 */
contract SaiDaiExchangeWrapper is
    ExchangeWrapper
{
    using AdvancedTokenInteract for address;
    using TokenInteract for address;

    // ============ Storage ============

    address public MIGRATION_CONTRACT;

    address public SAI;

    address public DAI;

    // ============ Constructor ============

    constructor(
        address migrationContract,
        address sai,
        address dai
    )
        public
    {
        MIGRATION_CONTRACT = migrationContract;
        SAI = sai;
        DAI = dai;

        sai.approve(migrationContract, uint256(-1));
        dai.approve(migrationContract, uint256(-1));
    }

    // ============ Public Functions ============

    function exchange(
        address /* tradeOriginator */,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes calldata /* orderData */
    )
        external
        returns (uint256)
    {
        address sai = SAI;
        address dai = DAI;

        bool tokensAreValid =
            (takerToken == sai && makerToken == dai)
            || (takerToken == dai && makerToken == sai);

        require(
            tokensAreValid,
            "SaiDaiExchangeWrapper#exchange: Invalid tokens"
        );

        IScdMcdMigration migration = IScdMcdMigration(MIGRATION_CONTRACT);

        if (takerToken == sai) {
            migration.swapSaiToDai(requestedFillAmount);
        } else {
            migration.swapDaiToSai(requestedFillAmount);
        }

        // ensure swap occurred properly
        assert(makerToken.balanceOf(address(this)) >= requestedFillAmount);

        // set allowance for the receiver
        makerToken.ensureAllowance(receiver, requestedFillAmount);

        return requestedFillAmount;
    }

    function getExchangeCost(
        address /* makerToken */,
        address /* takerToken */,
        uint256 desiredMakerToken,
        bytes calldata /* orderData */
    )
        external
        view
        returns (uint256)
    {
        return desiredMakerToken;
    }
}