/**
 *Submitted for verification at Etherscan.io on 2019-12-07
*/

pragma solidity 0.5.7;

// File: contracts/protocol/lib/Require.sol

/**
 * @title Require
 * @author dYdX
 *
 * Stringifies parameters to pretty-print revert messages. Costs more gas than regular require()
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


// File: IScdMcdMigration.sol

/**
 * @title SaiToDaiFunds
 * @author dYdX
 *
 * Allows for moving insurance SAI to DAI.
 */



// File: SaiToDaiFunds.sol

/**
 * @title SaiToDaiFunds
 * @author dYdX
 *
 * Allows for moving insurance SAI to DAI.
 */
contract SaiToDaiFunds {
    using Token for address;

    address constant SAI = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;

    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    address constant MIGRATION_CONTRACT = 0xc73e0383F3Aff3215E6f04B0331D58CeCf0Ab849;

    address constant SOLO_MARGIN = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;

    constructor ()
        public
    {}

    function migrate()
        public
    {
        // evaluate SAI balance and migrate it
        uint256 saiBalance = SAI.balanceOf(address(this));
        SAI.approve(MIGRATION_CONTRACT, saiBalance);
        IScdMcdMigration(MIGRATION_CONTRACT).swapSaiToDai(saiBalance);

        // verify DAI balance and send back to SOLO_MARGIN
        uint256 daiBalance = DAI.balanceOf(address(this));
        assert(saiBalance <= daiBalance);
        DAI.transfer(SOLO_MARGIN, daiBalance);
    }
}