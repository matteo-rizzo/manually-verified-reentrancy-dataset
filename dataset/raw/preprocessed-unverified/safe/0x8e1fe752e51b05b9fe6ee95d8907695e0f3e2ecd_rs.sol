/*

    /     |  __    / ____|
   /      | |__) | | |
  / /    |  _  /  | |
 / ____   | |    | |____
/_/    _ |_|  _  _____|

* ARC: v1/CoreV2.sol
*
* Latest source (may be newer): https://github.com/arcxgame/contracts/blob/master/contracts/v1/CoreV2.sol
*
* Contract Dependencies: 
*	- Adminable
*	- Context
*	- Ownable
*	- StorageV1
* Libraries: 
*	- Address
*	- Decimal
*	- Math
*	- SafeERC20
*	- SafeMath
*	- Storage
*	- TypesV1
*
* MIT License
* ===========
*
* Copyright (c) 2020 ARC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

pragma experimental ABIEncoderV2;

/* ===============================================
* Flattened with Solidifier by Coinage
* 
* https://solidifier.coina.ge
* ===============================================
*/


pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */



/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



/**
 * @dev Collection of functions related to the address type
 */



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// SPDX-License-Identifier: MIT





// SPDX-License-Identifier: MIT





// SPDX-License-Identifier: MIT


/**
 * @title Math
 *
 * Library for non-standard Math functions
 */


// SPDX-License-Identifier: MIT


/**
 * @title Decimal
 *
 * Library that defines a fixed-point number with 18 decimal places.
 */


// SPDX-License-Identifier: MIT





// SPDX-License-Identifier: MIT





// SPDX-License-Identifier: MIT





/**
 * @title Adminable
 * @author dYdX
 *
 * @dev EIP-1967 Proxy Admin contract.
 */
contract Adminable {
    /**
     * @dev Storage slot with the admin of the contract.
     *  This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1.
     */
    bytes32 internal constant ADMIN_SLOT =
    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
    * @dev Modifier to check whether the `msg.sender` is the admin.
    *  If it is, it will run the function. Otherwise, it will revert.
    */
    modifier onlyAdmin() {
        require(
            msg.sender == getAdmin(),
            "Adminable: caller is not admin"
        );
        _;
    }

    /**
     * @return The EIP-1967 proxy admin
     */
    function getAdmin()
        public
        view
        returns (address)
    {
        return address(uint160(uint256(Storage.load(ADMIN_SLOT))));
    }
}


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// SPDX-License-Identifier: MIT


/**
 * @title StateV1
 * @author Kerman Kohli
 * @notice This contract holds all the state regarding a sythetic asset protocol.
 *         The contract has an owner and core address which can call certain functions.
 */
contract StateV1 is Ownable {

    using Math for uint256;
    using SafeMath for uint256;
    using TypesV1 for TypesV1.Par;

    // ============ Variables ============

    address public core;

    TypesV1.MarketParams public market;
    TypesV1.RiskParams public risk;

    IOracle public oracle;
    address public collateralAsset;
    address public syntheticAsset;

    uint256 public positionCount;
    uint256 public totalSupplied;

    mapping (uint256 => TypesV1.Position) public positions;

    // ============ Events ============

    event MarketParamsUpdated(TypesV1.MarketParams updatedMarket);
    event RiskParamsUpdated(TypesV1.RiskParams updatedParams);
    event OracleUpdated(address updatedOracle);

    // ============ Constructor ============

    constructor(
        address _core,
        address _collateralAsset,
        address _syntheticAsset,
        address _oracle,
        TypesV1.MarketParams memory _marketParams,
        TypesV1.RiskParams memory _riskParams
    )
        public
    {
        core = _core;
        collateralAsset = _collateralAsset;
        syntheticAsset = _syntheticAsset;

        setOracle(_oracle);
        setMarketParams(_marketParams);
        setRiskParams(_riskParams);
    }

    // ============ Modifiers ============

    modifier onlyCore() {
        require(
            msg.sender == core,
            "StateV1: only core can call"
        );
        _;
    }

    // ============ Admin Setters ============

    /**
     * @dev Set the address of the oracle
     *
     * @param _oracle Address of the oracle to set
     */
    function setOracle(
        address _oracle
    )
        public
        onlyOwner
    {
        require(
            _oracle != address(0),
            "StateV1: cannot set 0 for oracle address"
        );

        oracle = IOracle(_oracle);
        emit OracleUpdated(_oracle);
    }

    /**
     * @dev Set the parameters of the market
     *
     * @param _marketParams Set the new market params
     */
    function setMarketParams(
        TypesV1.MarketParams memory _marketParams
    )
        public
        onlyOwner
    {
        market = _marketParams;
        emit MarketParamsUpdated(market);
    }

    /**
     * @dev Set the risk parameters of the market
     *
     * @param _riskParams Set the risk levels of the market
     */
    function setRiskParams(
        TypesV1.RiskParams memory _riskParams
    )
        public
        onlyOwner
    {
        risk = _riskParams;
        emit RiskParamsUpdated(risk);
    }

    // ============ Core Setters ============

    function updateTotalSupplied(
        uint256 amount
    )
        public
        onlyCore
    {
        totalSupplied = totalSupplied.add(amount);
    }

    function savePosition(
        TypesV1.Position memory position
    )
        public
        onlyCore
        returns (uint256)
    {
        uint256 idToAllocate = positionCount;
        positions[positionCount] = position;
        positionCount = positionCount.add(1);

        return idToAllocate;
    }

    function setAmount(
        uint256 id,
        TypesV1.AssetType asset,
        TypesV1.Par memory amount
    )
        public
        onlyCore
        returns (TypesV1.Position memory)
    {
        TypesV1.Position storage position = positions[id];

        if (position.collateralAsset == asset) {
            position.collateralAmount = amount;
        } else {
            position.borrowedAmount = amount;
        }

        return position;
    }

    function updatePositionAmount(
        uint256 id,
        TypesV1.AssetType asset,
        TypesV1.Par memory amount
    )
        public
        onlyCore
        returns (TypesV1.Position memory)
    {
        TypesV1.Position storage position = positions[id];

        if (position.collateralAsset == asset) {
            position.collateralAmount = position.collateralAmount.add(amount);
        } else {
            position.borrowedAmount = position.borrowedAmount.add(amount);
        }

        return position;
    }

    // ============ Public Getters ============

    function getAddress(
        TypesV1.AssetType asset
    )
        public
        view
        returns (address)
    {
        return asset == TypesV1.AssetType.Collateral ?
            address(collateralAsset) :
            address(syntheticAsset);
    }

    function getPosition(
        uint256 id
    )
        public
        view
        returns (TypesV1.Position memory)
    {
        return positions[id];
    }

    function getCurrentPrice()
        public
        view
        returns (Decimal.D256 memory)
    {
        return oracle.fetchCurrentPrice();
    }

    // ============ Calculation Getters ============

    function isCollateralized(
        TypesV1.Position memory position
    )
        public
        view
        returns (bool)
    {
        if (position.borrowedAmount.value == 0) {
            return true;
        }

        Decimal.D256 memory currentPrice = oracle.fetchCurrentPrice();

        (TypesV1.Par memory collateralDelta) = calculateCollateralDelta(
            position.borrowedAsset,
            position.collateralAmount,
            position.borrowedAmount,
            currentPrice
        );

        return collateralDelta.sign || collateralDelta.value == 0;
    }

    /**
     * @dev Given an asset, calculate the inverse amount of that asset
     *
     * @param asset The asset in question here
     * @param amount The amount of this asset
     * @param price What price do you want to calculate the inverse at
     */
    function calculateInverseAmount(
        TypesV1.AssetType asset,
        uint256 amount,
        Decimal.D256 memory price
    )
        public
        pure
        returns (uint256)
    {
        uint256 borrowRequired;

        if (asset == TypesV1.AssetType.Collateral) {
            borrowRequired = Decimal.mul(
                amount,
                price
            );
        } else if (asset == TypesV1.AssetType.Synthetic) {
            borrowRequired = Decimal.div(
                amount,
                price
            );
        }

        return borrowRequired;
    }

    /**
     * @dev Similar to calculateInverseAmount although the difference being
     *      that this factors in the collateral ratio.
     *
     * @param asset The asset in question here
     * @param amount The amount of this asset
     * @param price What price do you want to calculate the inverse at
     */
    function calculateInverseRequired(
        TypesV1.AssetType asset,
        uint256 amount,
        Decimal.D256 memory price
    )
        public
        view
        returns (TypesV1.Par memory)
    {

        uint256 inverseRequired = calculateInverseAmount(
            asset,
            amount,
            price
        );

        if (asset == TypesV1.AssetType.Collateral) {
            inverseRequired = Decimal.div(
                inverseRequired,
                market.collateralRatio
            );

        } else if (asset == TypesV1.AssetType.Synthetic) {
            inverseRequired = Decimal.mul(
                inverseRequired,
                market.collateralRatio
            );
        }

        return TypesV1.Par({
            sign: true,
            value: inverseRequired.to128()
        });
    }

    /**
     * @dev When executing a liqudation, the price of the asset has to be calculated
     *      at a discount in order for it to be profitable for the liquidator. This function
     *      will get the current oracle price for the asset and find the discounted price.
     *
     * @param asset The asset in question here
     */
    function calculateLiquidationPrice(
        TypesV1.AssetType asset
    )
        public
        view
        returns (Decimal.D256 memory)
    {
        Decimal.D256 memory result;
        Decimal.D256 memory currentPrice = oracle.fetchCurrentPrice();

        uint256 totalSpread = market.liquidationUserFee.value.add(
            market.liquidationArcFee.value
        );

        if (asset == TypesV1.AssetType.Collateral) {
            result = Decimal.sub(
                Decimal.one(),
                totalSpread
            );
        } else if (asset == TypesV1.AssetType.Synthetic) {
            result = Decimal.add(
                Decimal.one(),
                totalSpread
            );
        }

        result = Decimal.mul(
            currentPrice,
            result
        );

        return result;
    }

    /**
     * @dev Given an asset being borrowed, figure out how much collateral can this still borrow or
     *      is in the red by. This function is used to check if a position is undercolalteralised and
     *      also to calculate how much can a position be liquidated by.
     *
     * @param borrowedAsset The asset which is being borrowed
     * @param parSupply The amount being supplied
     * @param parBorrow The amount being borrowed
     * @param price The price to calculate this difference by
     */
    function calculateCollateralDelta(
        TypesV1.AssetType borrowedAsset,
        TypesV1.Par memory parSupply,
        TypesV1.Par memory parBorrow,
        Decimal.D256 memory price
    )
        public
        view
        returns (TypesV1.Par memory)
    {
        TypesV1.Par memory collateralDelta;
        TypesV1.Par memory collateralRequired;

        if (borrowedAsset == TypesV1.AssetType.Collateral) {
            collateralRequired = calculateInverseRequired(
                borrowedAsset,
                parBorrow.value,
                price
            );
        } else if (borrowedAsset == TypesV1.AssetType.Synthetic) {
            collateralRequired = calculateInverseRequired(
                borrowedAsset,
                parBorrow.value,
                price
            );
        }

        collateralDelta = parSupply.sub(collateralRequired);

        return collateralDelta;
    }

    /**
     * @dev Add the user liqudation fee with the arc liquidation fee
     */
    function totalLiquidationSpread()
        public
        view
        returns (Decimal.D256 memory)
    {
        return Decimal.D256({
            value: market.liquidationUserFee.value.add(
                market.liquidationArcFee.value
            )
        });
    }

    /**
     * @dev Calculate the liquidation ratio between the user and ARC.
     *
     * @return First parameter it the user ratio, second is ARC's ratio
     */
    function calculateLiquidationSplit()
        public
        view
        returns (
            Decimal.D256 memory,
            Decimal.D256 memory
        )
    {
        Decimal.D256 memory total = Decimal.D256({
            value: market.liquidationUserFee.value.add(
                market.liquidationArcFee.value
            )
        });

        Decimal.D256 memory userRatio = Decimal.D256({
            value: Decimal.div(
                market.liquidationUserFee.value,
                total
            )
        });

        return (
            userRatio,
            Decimal.sub(
                Decimal.one(),
                userRatio.value
            )
        );
    }

}


// SPDX-License-Identifier: MIT


contract StorageV1 {

    bool public paused;

    StateV1 public state;

}

// SPDX-License-Identifier: MIT


/**
 * @title CoreV2
 * @author Kerman Kohli
 * @notice This contract holds the core logic for manipulating ARC state. Ideally
        both state and logic could be in one or as libraries however the bytecode
        size is too large for this to occur. The core can be replaced via a new
        proxy implementation for upgrade purposes. Important to note that NO user
        funds are held in this contract. All funds are held inside the synthetic
        asset itself. This was done to show transparency around how much collateral
        is always backing a synth via Etherscan.

        The V2 version fixes the liquidation split to be net profit not total +
        allowing the repay function to be called if the position is underwater.
 */
contract CoreV2 is StorageV1, Adminable {

    // ============ Libraries ============

    using SafeMath for uint256;
    using Math for uint256;
    using TypesV1 for TypesV1.Par;

    // ============ Types ============

    enum Operation {
        Open,
        Borrow,
        Repay,
        Liquidate
    }

    struct OperationParams {
        uint256 id;
        uint256 amountOne;
        uint256 amountTwo;
    }

    // ============ Events ============

    event ActionOperated(
        uint8 operation,
        OperationParams params,
        TypesV1.Position updatedPosition
    );

    event ExcessTokensWithdrawn(
        address token,
        uint256 amount,
        address destination
    );

    event PauseStatusUpdated(
        bool value
    );

    // ============ Constructor ============

    constructor() public {
        paused = true;
    }

    function init(address _state)
        external
    {
        require(
            address(state) == address(0),
            "CoreV1.init(): cannot recall init"
        );

        state = StateV1(_state);
        paused = false;
    }

    // ============ Public Functions ============

    /**
     * @dev This is the only function that can be called by user's of the system
     *      and uses an enum and struct to parse the args. This structure guarantees
     *      the state machine will always meet certain properties
     *
     * @param operation An enum of the operation to execute
     * @param params Parameters to exceute the operation against
     */
    function operateAction(
        Operation operation,
        OperationParams memory params
    )
        public
    {
        require(
            paused == false,
            "operateAction(): contracts cannot be paused"
        );

        TypesV1.Position memory operatedPosition;

        (
            uint256 collateralLimit,
            uint256 syntheticLimit,
            uint256 collateralMinimum
        ) = state.risk();

        if (operation == Operation.Open) {
            (operatedPosition, params.id) = openPosition(
                params.amountOne,
                params.amountTwo
            );

            require(
                params.amountOne >= collateralMinimum,
                "operateAction(): must exceed minimum collateral amount"
            );

        } else if (operation == Operation.Borrow) {
            operatedPosition = borrow(
                params.id,
                params.amountOne,
                params.amountTwo
            );
        } else if (operation == Operation.Repay) {
            operatedPosition = repay(
                params.id,
                params.amountOne,
                params.amountTwo
            );
        } else if (operation == Operation.Liquidate) {
            operatedPosition = liquidate(
                params.id
            );
        }

        IERC20 synthetic = IERC20(state.syntheticAsset());
        IERC20 collateralAsset = IERC20(state.collateralAsset());

        require(
            synthetic.totalSupply() <= syntheticLimit || syntheticLimit == 0,
            "operateAction(): synthetic supply cannot be greater than limit"
        );

        require(
            collateralAsset.balanceOf(address(synthetic)) <= collateralLimit || collateralLimit == 0,
            "operateAction(): collateral locked cannot be greater than limit"
        );

        // SUGGESTION: Making sure the state doesn't get trapped. Echnida fuzzing could help.
        //             Testing very specific cases which a fuzzer may not be able to hit.
        //             Setup derived contract which allows direct entry point of internal functions.

        // Ensure that the operated action is collateralised again
        require(
            state.isCollateralized(operatedPosition) == true,
            "operateAction(): the operated position is undercollateralised"
        );

        emit ActionOperated(
            uint8(operation),
            params,
            operatedPosition
        );
    }

    /**
     * @dev Withdraw tokens owned by the proxy. This will never include depositor funds
     *      since all the collateral is held by the synthetic token itself. The only funds
     *      that will accrue based on CoreV1 & StateV1 is the liquidation fees.
     *
     * @param token Address of the token to withdraw
     * @param destination Destination to withdraw to
     * @param amount The total amount of tokens withdraw
     */
    function withdrawTokens(
        address token,
        address destination,
        uint256 amount
    )
        external
        onlyAdmin
    {
        SafeERC20.safeTransfer(
            IERC20(token),
            destination,
            amount
        );
    }

    function setPause(bool value)
        external
        onlyAdmin
    {
        paused = value;

        emit PauseStatusUpdated(value);
    }

    // ============ Internal Functions ============

    /**
     * @dev Open a new position.
     *
     * @return The new position and the ID of the opened position
     */
    function openPosition(
        uint256 collateralAmount,
        uint256 borrowAmount
    )
        internal
        returns (TypesV1.Position memory, uint256)
    {
        // CHECKS:
        // 1. No checks required as it's all processed in borrow()

        // EFFECTS:
        // 1. Create a new Position struct with the basic fields filled out and save it to storage
        // 2. Call `borrowPosition()`

        TypesV1.Position memory newPosition = TypesV1.Position({
            owner: msg.sender,
            collateralAsset: TypesV1.AssetType.Collateral,
            borrowedAsset: TypesV1.AssetType.Synthetic,
            collateralAmount: TypesV1.positiveZeroPar(),
            borrowedAmount: TypesV1.zeroPar()
        });

        // This position is saved to storage to make the logic around borrowing
        // uniform. This is slightly gas inefficient but ok given the ability to
        // ensure no diverging logic.

        uint256 positionId = state.savePosition(newPosition);

        newPosition = borrow(
            positionId,
            collateralAmount,
            borrowAmount
        );

        return (
            newPosition,
            positionId
        );
    }

    /**
     * @dev Borrow against an existing position.
     *
     * @param positionId ID of the position you'd like to borrow against
     * @param collateralAmount Collateral deposit amount
     * @param borrowAmount How much would you'd like to borrow/mint
     */
    function borrow(
        uint256 positionId,
        uint256 collateralAmount,
        uint256 borrowAmount
    )
        internal
        returns (TypesV1.Position memory)
    {
        // CHECKS:
        // 1. Ensure that the position actually exists
        // 2. Ensure the position is collateralised before borrowing against it
        // 3. Ensure that msg.sender == owner of position
        // 4. Determine if there's enough liquidity of the `borrowAsset`
        // 5. Calculate the amount of collateral actually needed given the `collateralRatio`
        // 6. Ensure the user has provided enough of the collateral asset

        // EFFECTS:
        // 1. Increase the collateral amount to calculate the maximum the amount the user can borrow
        // 2. Calculate the proportional new par value based on the borrow amount
        // 3. Update the total supplied collateral amount
        // 4. Calculate the collateral needed and ensuring the position has that much

        // INTERACTIONS:
        // 1. Mint the synthetic asset
        // 2. Transfer the collateral to the synthetic token itself.
        //    This ensures on Etherscan people can see how much collateral is backing
        //    the synthetic

        // Get the current position
        TypesV1.Position memory position = state.getPosition(positionId);

        // Ensure it's collateralized
        require(
            state.isCollateralized(position) == true,
            "borrowPosition(): position is not collateralised"
        );

        require(
            position.owner == msg.sender,
            "borrowPosition(): must be a valid position"
        );

        Decimal.D256 memory currentPrice = state.getCurrentPrice();

        // Increase the user's collateral amount
        position = state.updatePositionAmount(
            positionId,
            position.collateralAsset,
            TypesV1.Par({
                sign: true,
                value: collateralAmount.to128()
            })
        );

        state.updateTotalSupplied(collateralAmount);

        // Only if they're borrowing
        if (borrowAmount > 0) {
            // Calculate the new borrow amount
            TypesV1.Par memory newPar = position.borrowedAmount.add(
                TypesV1.Par({
                    sign: false,
                    value: borrowAmount.to128()
                })
            );

            // Update the position's borrow amount
            position = state.setAmount(
                positionId,
                position.borrowedAsset,
                newPar
            );

            // Check how much collateral they need based on their new position details
            TypesV1.Par memory collateralRequired = state.calculateInverseRequired(
                position.borrowedAsset,
                position.borrowedAmount.value,
                currentPrice
            );

            // Ensure the user's collateral amount is greater than the collateral needed
            require(
                position.collateralAmount.value >= collateralRequired.value,
                "borrowPosition(): not enough collateral provided"
            );
        }

        IERC20 syntheticAsset = IERC20(state.syntheticAsset());
        IERC20 collateralAsset = IERC20(state.collateralAsset());

        // Transfer the collateral asset to the synthetic contract
        SafeERC20.safeTransferFrom(
            collateralAsset,
            msg.sender,
            address(syntheticAsset),
            collateralAmount
        );

        // Mint the synthetic token to user opening the borrow position
        ISyntheticToken(address(syntheticAsset)).mint(
            msg.sender,
            borrowAmount
        );

        return position;
    }

    /**
     * @dev Repay money against a borrowed position. When this process occurs the position's
     *      debt will be reduced and in turn will allow them to withdraw their collateral should they choose.
     *
     * @param positionId ID of the position to repay
     * @param repayAmount Amount of collateral to repay
     * @param withdrawAmount Amount of collateral to withdraw
     */
    function repay(
        uint256 positionId,
        uint256 repayAmount,
        uint256 withdrawAmount
    )
        private
        returns (TypesV1.Position memory)
    {
        // CHECKS:
        // 1. Ensure the position actually exists by ensuring the owner == msg.sender
        // 2. The position does not have to be collateralised since we want people to repay
        //    before a liquidator does if they do actually have a chance

        // EFFECTS:
        // 1. Calculate the new par value of the position based on the amount paid back
        // 2. Update the position's new borrow amount
        // 3. Calculate how much collateral you need based on your current position balance
        // 4. If the amount being withdrawn is less than or equal to amount withdrawn you're good

        // INTERACTIONS:
        // 1. Burn the synthetic asset directly from their wallet
        // 2.Transfer the stable coins back to the user
        TypesV1.Position memory position = state.getPosition(positionId);

        Decimal.D256 memory currentPrice = state.getCurrentPrice();

        require(
            position.owner == msg.sender,
            "repay(): must be a valid position"
        );

        // Calculate the user's new borrow requirements after decreasing their debt
        // An positive wei value will reduce the negative wei borrow value
        TypesV1.Par memory newPar = position.borrowedAmount.add(
            TypesV1.Par({
                sign: true,
                value: repayAmount.to128()
            })
        );

        // Update the position's new borrow amount
        position = state.setAmount(positionId, position.borrowedAsset, newPar);

        // Calculate how much the user is allowed to withdraw given their debt was repaid
        (TypesV1.Par memory collateralDelta) = state.calculateCollateralDelta(
            position.borrowedAsset,
            position.collateralAmount,
            position.borrowedAmount,
            currentPrice
        );

        // Ensure that the amount they are trying to withdraw is less than their limit
        require(
            withdrawAmount <= collateralDelta.value,
            "repay(): cannot withdraw more than you're allowed"
        );

        // Decrease the collateral amount of the position
        position = state.updatePositionAmount(
            positionId,
            position.collateralAsset,
            TypesV1.Par({
                sign: false,
                value: withdrawAmount.to128()
            })
        );

        ISyntheticToken synthetic = ISyntheticToken(state.syntheticAsset());
        IERC20 collateralAsset = IERC20(state.collateralAsset());

        // Burn the synthetic asset from the user
        synthetic.burn(
            msg.sender,
            repayAmount
        );

        // Transfer collateral back to the user
        bool transferResult = synthetic.transferCollateral(
            address(collateralAsset),
            msg.sender,
            withdrawAmount
        );

        require(
            transferResult == true,
            "repay(): collateral failed to transfer"
        );

        return position;
    }

    /**
     * @dev Liquidate a user's position. When this process occurs you're essentially
     *      purchasing the users's debt at a discount (liquidation spread) in exchange
     *      for the collateral they have deposited inside their position.
     *
     * @param positionId ID of the position to liquidate
     */
    function liquidate(
        uint256 positionId
    )
        private
        returns (TypesV1.Position memory)
    {
        // CHECKS:
        // 1. Ensure that the position id is valid
        // 2. Check the status of the position, only if it's undercollateralized you can call this

        // EFFECTS:
        // 1. Calculate the liquidation price price based on the liquidation penalty
        // 2. Calculate how much the user is in debt by
        // 3. Add the liquidation penalty on to the liquidation amount so they have some
        //    margin of safety to make sure they don't get liquidated again
        // 4. If the collateral to liquidate is greater than the collateral, bound it.
        // 5. Calculate how much of the borrowed asset is to be liquidated based on the collateral delta
        // 6. Decrease the user's debt obligation by that amount
        // 7. Update the new borrow and collateral amounts

        // INTERACTIONS:
        // 1. Burn the synthetic asset from the liquidator
        // 2. Transfer the collateral from the synthetic token to the liquidator
        // 3. Transfer a portion to the ARC Core contract as a fee

        TypesV1.Position memory position = state.getPosition(positionId);

        require(
            position.owner != address(0),
            "liquidatePosition(): must be a valid position"
        );

        // Ensure that the position is not collateralized
        require(
            state.isCollateralized(position) == false,
            "liquidatePosition(): position is collateralised"
        );

        // Get the liquidation price of the asset (discount for liquidator)
        Decimal.D256 memory liquidationPrice = state.calculateLiquidationPrice(
            position.collateralAsset
        );

        // Calculate how much the user is in debt by to be whole again at a discounted price
        (TypesV1.Par memory liquidationCollateralDelta) = state.calculateCollateralDelta(
            position.borrowedAsset,
            position.collateralAmount,
            position.borrowedAmount,
            liquidationPrice
        );

        // Calculate how much the user is in debt by to be whole again at original prices
        (TypesV1.Par memory originalCollateralDelta) = state.calculateCollateralDelta(
            position.borrowedAsset,
            position.collateralAmount,
            position.borrowedAmount,
            state.getCurrentPrice()
        );

        Decimal.D256 memory discountRatio = Decimal.add(
            state.totalLiquidationSpread(),
            Decimal.one().value
        );

        // Liquidate a slight bit more to ensure the user is guarded against futher price drops
        liquidationCollateralDelta.value = Decimal.mul(
            liquidationCollateralDelta.value,
            discountRatio
        ).to128();

        originalCollateralDelta.value = Decimal.mul(
            originalCollateralDelta.value,
            discountRatio
        ).to128();

        // If the maximum they're down by is greater than their collateral, bound to the maximum
        if (liquidationCollateralDelta.value > position.collateralAmount.value) {
            liquidationCollateralDelta.value = position.collateralAmount.value;

            // If the the original collateral delta is to be the same as the
            // collateral amount. What this does is that the profit calculated
            // will be 0 since the liquidationCollateralDelta less the
            // originalCollateralDelta will be the same.
            originalCollateralDelta.value = position.collateralAmount.value;
        }

        // Calculate how much borrowed assets to liquidate (at a discounted price)
        uint256 borrowToLiquidate = state.calculateInverseAmount(
            position.collateralAsset,
            liquidationCollateralDelta.value,
            liquidationPrice
        );

        // Decrease the user's debt obligation
        // This amount is denominated in par since collateralDelta uses the borrow index
        TypesV1.Par memory newPar = position.borrowedAmount.add(
            TypesV1.Par({
                sign: true,
                value: borrowToLiquidate.to128()
            })
        );

        // Set the user's new borrow amount
        position = state.setAmount(positionId, position.borrowedAsset, newPar);

        // Decrease their collateral amount by the amount they were missing
        position = state.updatePositionAmount(
            positionId,
            position.collateralAsset,
            liquidationCollateralDelta
        );

        address borrowAddress = state.getAddress(position.borrowedAsset);

        require(
            IERC20(borrowAddress).balanceOf(msg.sender) >= borrowToLiquidate,
            "liquidatePosition(): msg.sender not enough of borrowed asset to liquidate"
        );

        _settleLiquidation(
            borrowToLiquidate,
            liquidationCollateralDelta,
            originalCollateralDelta
        );

        return position;
    }

    function _settleLiquidation(
        uint256 borrowToLiquidate,
        TypesV1.Par memory liquidationCollateralDelta,
        TypesV1.Par memory originalCollateralDelta
    )
        private
    {
        ISyntheticToken synthetic = ISyntheticToken(
            state.syntheticAsset()
        );

        IERC20 collateralAsset = IERC20(state.collateralAsset());

        (
            /* solium-disable-next-line */
            Decimal.D256 memory userSplit,
            Decimal.D256 memory arcSplit
        ) = state.calculateLiquidationSplit();

        // Burn the synthetic asset from the liquidator
        synthetic.burn(
            msg.sender,
            borrowToLiquidate
        );

        // This is the actual profit collected from the liquidation
        TypesV1.Par memory collateralProfit = liquidationCollateralDelta.sub(
            originalCollateralDelta
        );

        // ARC's profit is simple a percentage of the profit, not net total
        uint256 arcProfit = Decimal.mul(
            collateralProfit.value,
            arcSplit
        );

        // Transfer them the collateral assets they acquired at a discount
        bool userTransferResult = synthetic.transferCollateral(
            address(collateralAsset),
            msg.sender,
            uint256(liquidationCollateralDelta.value).sub(arcProfit)
        );

        require(
            userTransferResult == true,
            "liquidate(): collateral failed to transfer to user"
        );

        // Transfer ARC the collateral asset acquired at a discount
        bool arcTransferResult = synthetic.transferCollateral(
            address(collateralAsset),
            address(this),
            arcProfit
        );

        require(
            arcTransferResult == true,
            "liquidate(): collateral failed to transfer to arc"
        );
    }

}