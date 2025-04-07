/**
 *Submitted for verification at Etherscan.io on 2020-02-25
*/

/*

    Copyright 2020 dYdX Trading Inc.

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


// File: contracts/protocol/lib/Monetary.sol

/**
 * @title Monetary
 * @author dYdX
 *
 * Library for types involving money
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

// File: contracts/protocol/SoloMargin.sol

contract SoloMargin {

    /* ... */

    function getAccountWei(
        Account.Info memory account,
        uint256 marketId
    )
        public
        view
        returns (Types.Wei memory);

    function getMarketPrice(
        uint256 marketId
    )
        public
        view
        returns (Monetary.Price memory);

    /* ... */
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

// File: contracts/external/lib/TypedSignature.sol

/**
 * @title TypedSignature
 * @author dYdX
 *
 * Library to unparse typed signatures
 */


// File: contracts/external/traders/CanonicalOrders.sol

/**
 * @title CanonicalOrders
 * @author dYdX
 *
 * Allows for Canonical Orders to be used with dYdX
 */
contract CanonicalOrders is
    Ownable,
    OnlySolo,
    IAutoTrader,
    ICallee
{
    using Math for uint256;
    using SafeMath for uint256;
    using Types for Types.Par;
    using Types for Types.Wei;

    // ============ Constants ============

    bytes32 constant private FILE = "CanonicalOrders";

    // EIP191 header for EIP712 prefix
    bytes2 constant private EIP191_HEADER = 0x1901;

    // EIP712 Domain Name value
    string constant private EIP712_DOMAIN_NAME = "CanonicalOrders";

    // EIP712 Domain Version value
    string constant private EIP712_DOMAIN_VERSION = "1.1";

    // Hash of the EIP712 Domain Separator Schema
    /* solium-disable-next-line indentation */
    bytes32 constant private EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = keccak256(abi.encodePacked(
        "EIP712Domain(",
        "string name,",
        "string version,",
        "uint256 chainId,",
        "address verifyingContract",
        ")"
    ));

    // Hash of the EIP712 CanonicalOrder struct
    /* solium-disable-next-line indentation */
    bytes32 constant private EIP712_ORDER_STRUCT_SCHEMA_HASH = keccak256(abi.encodePacked(
        "CanonicalOrder(",
        "bytes32 flags,",
        "uint256 baseMarket,",
        "uint256 quoteMarket,",
        "uint256 amount,",
        "uint256 limitPrice,",
        "uint256 triggerPrice,",
        "uint256 limitFee,",
        "address makerAccountOwner,",
        "uint256 makerAccountNumber,",
        "uint256 expiration",
        ")"
    ));

    // Number of bytes in an Order struct plus number of bytes in a FillArgs struct
    uint256 constant private NUM_ORDER_AND_FILL_BYTES = 416;

    // Number of bytes in a typed signature
    uint256 constant private NUM_SIGNATURE_BYTES = 66;

    // The number of decimal places of precision in the price ratio of a triggerPrice
    uint256 constant private PRICE_BASE = 10 ** 18;

    // Bitmasks for the order.flag argument
    bytes32 constant private IS_BUY_FLAG = bytes32(uint256(1));
    bytes32 constant private IS_DECREASE_ONLY_FLAG = bytes32(uint256(1 << 1));
    bytes32 constant private IS_NEGATIVE_FEE_FLAG = bytes32(uint256(1 << 2));

    // ============ Enums ============

    enum OrderStatus {
        Null,
        Approved,
        Canceled
    }

    enum CallFunctionType {
        Approve,
        Cancel,
        SetFillArgs
    }

    // ============ Structs ============

    struct Order {
        bytes32 flags; // salt, negativeFee, decreaseOnly, isBuy
        uint256 baseMarket;
        uint256 quoteMarket;
        uint256 amount;
        uint256 limitPrice;
        uint256 triggerPrice;
        uint256 limitFee;
        address makerAccountOwner;
        uint256 makerAccountNumber;
        uint256 expiration;
    }

    struct FillArgs {
        uint256 price;
        uint128 fee;
        bool isNegativeFee;
    }

    struct OrderInfo {
        Order order;
        FillArgs fill;
        bytes32 orderHash;
    }

    struct OrderQueryOutput {
        OrderStatus orderStatus;
        uint256 filledAmount;
    }

    // ============ Events ============

    event LogContractStatusSet(
        bool operational
    );

    event LogTakerSet(
        address taker
    );

    event LogCanonicalOrderCanceled(
        bytes32 indexed orderHash,
        address indexed canceler,
        uint256 baseMarket,
        uint256 quoteMarket
    );

    event LogCanonicalOrderApproved(
        bytes32 indexed orderHash,
        address indexed approver,
        uint256 baseMarket,
        uint256 quoteMarket
    );

    event LogCanonicalOrderFilled(
        bytes32 indexed orderHash,
        address indexed orderMaker,
        uint256 fillAmount,
        uint256 triggerPrice,
        bytes32 orderFlags,
        FillArgs fill
    );

    // ============ Immutable Storage ============

    // Hash of the EIP712 Domain Separator data
    bytes32 public EIP712_DOMAIN_HASH;

    // ============ Mutable Storage ============

    // true if this contract can process orders
    bool public g_isOperational;

    // order hash => filled amount (in baseAmount)
    mapping (bytes32 => uint256) public g_filledAmount;

    // order hash => status
    mapping (bytes32 => OrderStatus) public g_status;

    // stored fillArgs
    FillArgs public g_fillArgs;

    // required taker address
    address public g_taker;

    // ============ Constructor ============

    constructor (
        address soloMargin,
        address taker,
        uint256 chainId
    )
        public
        OnlySolo(soloMargin)
    {
        g_isOperational = true;
        g_taker = taker;

        /* solium-disable-next-line indentation */
        EIP712_DOMAIN_HASH = keccak256(abi.encode(
            EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,
            keccak256(bytes(EIP712_DOMAIN_NAME)),
            keccak256(bytes(EIP712_DOMAIN_VERSION)),
            chainId,
            address(this)
        ));
    }

    // ============ Admin Functions ============

    /**
     * The owner can shut down the exchange.
     */
    function shutDown()
        external
        onlyOwner
    {
        g_isOperational = false;
        emit LogContractStatusSet(false);
    }

    /**
     * The owner can start back up the exchange.
     */
    function startUp()
        external
        onlyOwner
    {
        g_isOperational = true;
        emit LogContractStatusSet(true);
    }

    /**
     * The owner can set the taker address.
     */
    function setTakerAddress(
        address taker
    )
        external
        onlyOwner
    {
        g_taker = taker;
        emit LogTakerSet(taker);
    }

    // ============ External Functions ============

    /**
     * Cancels an order.
     *
     * @param  order  The order to cancel
     */
    function cancelOrder(
        Order memory order
    )
        public
    {
        cancelOrderInternal(msg.sender, order);
    }

    /**
     * Approves an order. Cannot already be canceled.
     *
     * @param  order  The order to approve
     */
    function approveOrder(
        Order memory order
    )
        public
    {
        approveOrderInternal(msg.sender, order);
    }

    // ============ Only-Solo Functions ============

    /**
     * Allows traders to make trades approved by this smart contract. The active trader's account is
     * the takerAccount and the passive account (for which this contract approves trades
     * on-behalf-of) is the makerAccount.
     *
     * @param  inputMarketId   The market for which the trader specified the original amount
     * @param  outputMarketId  The market for which the trader wants the resulting amount specified
     * @param  makerAccount    The account for which this contract is making trades
     * @param  takerAccount    The account requesting the trade
     * @param  oldInputPar     The par balance of the makerAccount for inputMarketId pre-trade
     * @param  newInputPar     The par balance of the makerAccount for inputMarketId post-trade
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
        onlySolo(msg.sender)
        returns (Types.AssetAmount memory)
    {
        Require.that(
            g_isOperational,
            FILE,
            "Contract is not operational"
        );

        OrderInfo memory orderInfo = getOrderInfo(data);

        verifySignature(orderInfo, data);

        verifyOrderInfo(
            orderInfo,
            makerAccount,
            takerAccount,
            inputMarketId,
            outputMarketId,
            inputWei
        );

        Types.AssetAmount memory assetAmount = getOutputAssetAmount(
            inputMarketId,
            outputMarketId,
            inputWei,
            orderInfo
        );

        if (isDecreaseOnly(orderInfo.order)) {
            verifyDecreaseOnly(
                oldInputPar,
                newInputPar,
                assetAmount,
                makerAccount,
                outputMarketId
            );
        }

        return assetAmount;
    }

    /**
     * Allows users to send this contract arbitrary data.
     *
     *  param  sender       (unused)
     * @param  accountInfo  The account from which the data is being sent
     * @param  data         Arbitrary data given by the sender
     */
    function callFunction(
        address /* sender */,
        Account.Info memory accountInfo,
        bytes memory data
    )
        public
        onlySolo(msg.sender)
    {
        CallFunctionType cft = abi.decode(data, (CallFunctionType));

        if (cft == CallFunctionType.SetFillArgs) {
            FillArgs memory fillArgs;
            (cft, fillArgs) = abi.decode(data, (CallFunctionType, FillArgs));
            g_fillArgs = fillArgs;
        } else {
            Order memory order;
            (cft, order) = abi.decode(data, (CallFunctionType, Order));
            if (cft == CallFunctionType.Approve) {
                approveOrderInternal(accountInfo.owner, order);
            } else {
                assert(cft == CallFunctionType.Cancel);
                cancelOrderInternal(accountInfo.owner, order);
            }
        }
    }

    // ============ Getters ============

    /**
     * Returns the status and the filled amount of several orders.
     */
    function getOrderStates(
        bytes32[] memory orderHashes
    )
        public
        view
        returns(OrderQueryOutput[] memory)
    {
        uint256 numOrders = orderHashes.length;
        OrderQueryOutput[] memory output = new OrderQueryOutput[](numOrders);

        // for each order
        for (uint256 i = 0; i < numOrders; i++) {
            bytes32 orderHash = orderHashes[i];
            output[i] = OrderQueryOutput({
                orderStatus: g_status[orderHash],
                filledAmount: g_filledAmount[orderHash]
            });
        }
        return output;
    }

    // ============ Private Storage Functions ============

    /**
     * Cancels an order as long as it is not already canceled.
     */
    function cancelOrderInternal(
        address canceler,
        Order memory order
    )
        private
    {
        Require.that(
            canceler == order.makerAccountOwner,
            FILE,
            "Canceler must be maker"
        );
        bytes32 orderHash = getOrderHash(order);
        g_status[orderHash] = OrderStatus.Canceled;
        emit LogCanonicalOrderCanceled(
            orderHash,
            canceler,
            order.baseMarket,
            order.quoteMarket
        );
    }

    /**
     * Approves an order as long as it is not already approved or canceled.
     */
    function approveOrderInternal(
        address approver,
        Order memory order
    )
        private
    {
        Require.that(
            approver == order.makerAccountOwner,
            FILE,
            "Approver must be maker"
        );
        bytes32 orderHash = getOrderHash(order);
        Require.that(
            g_status[orderHash] != OrderStatus.Canceled,
            FILE,
            "Cannot approve canceled order",
            orderHash
        );
        g_status[orderHash] = OrderStatus.Approved;
        emit LogCanonicalOrderApproved(
            orderHash,
            approver,
            order.baseMarket,
            order.quoteMarket
        );
    }

    // ============ Private Helper Functions ============

    /**
     * Parses the order, verifies that it is not expired or canceled, and verifies the signature.
     */
    function getOrderInfo(
        bytes memory data
    )
        private
        returns (OrderInfo memory)
    {
        Require.that(
            (
                data.length == NUM_ORDER_AND_FILL_BYTES ||
                data.length == NUM_ORDER_AND_FILL_BYTES + NUM_SIGNATURE_BYTES
            ),
            FILE,
            "Cannot parse order from data"
        );

        // load orderInfo from calldata
        OrderInfo memory orderInfo;
        (
            orderInfo.order,
            orderInfo.fill
        ) = abi.decode(data, (Order, FillArgs));

        // load fillArgs from storage if price is zero
        if (orderInfo.fill.price == 0) {
            orderInfo.fill = g_fillArgs;
            g_fillArgs = FillArgs({
                price: 0,
                fee: 0,
                isNegativeFee: false
            });
        }
        Require.that(
            orderInfo.fill.price != 0,
            FILE,
            "FillArgs loaded price is zero"
        );

        orderInfo.orderHash = getOrderHash(orderInfo.order);

        return orderInfo;
    }

    function verifySignature(
        OrderInfo memory orderInfo,
        bytes memory data
    )
        private
        view
    {
        OrderStatus orderStatus = g_status[orderInfo.orderHash];

        // verify valid signature or is pre-approved
        if (orderStatus == OrderStatus.Null) {
            bytes memory signature = parseSignature(data);
            address signer = TypedSignature.recover(orderInfo.orderHash, signature);
            Require.that(
                orderInfo.order.makerAccountOwner == signer,
                FILE,
                "Order invalid signature",
                orderInfo.orderHash
            );
        } else {
            Require.that(
                orderStatus != OrderStatus.Canceled,
                FILE,
                "Order canceled",
                orderInfo.orderHash
            );
            assert(orderStatus == OrderStatus.Approved);
        }
    }

    /**
     * Verifies that the order is still fillable for the particular accounts and markets specified.
     */
    function verifyOrderInfo(
        OrderInfo memory orderInfo,
        Account.Info memory makerAccount,
        Account.Info memory takerAccount,
        uint256 inputMarketId,
        uint256 outputMarketId,
        Types.Wei memory inputWei
    )
        private
        view
    {
        // verify fill price
        FillArgs memory fill = orderInfo.fill;
        bool validPrice = isBuy(orderInfo.order)
            ? fill.price <= orderInfo.order.limitPrice
            : fill.price >= orderInfo.order.limitPrice;
        Require.that(
            validPrice,
            FILE,
            "Fill invalid price"
        );

        // verify fill fee
        bool validFee = isNegativeLimitFee(orderInfo.order)
            ? (fill.fee >= orderInfo.order.limitFee) && fill.isNegativeFee
            : (fill.fee <= orderInfo.order.limitFee) || fill.isNegativeFee;
        Require.that(
            validFee,
            FILE,
            "Fill invalid fee"
        );

        // verify triggerPrice
        if (orderInfo.order.triggerPrice > 0) {
            uint256 currentPrice = getCurrentPrice(
                orderInfo.order.baseMarket,
                orderInfo.order.quoteMarket
            );
            Require.that(
                isBuy(orderInfo.order)
                    ? currentPrice >= orderInfo.order.triggerPrice
                    : currentPrice <= orderInfo.order.triggerPrice,
                FILE,
                "Order triggerPrice not triggered",
                currentPrice
            );
        }

        // verify expriy
        Require.that(
            orderInfo.order.expiration == 0 || orderInfo.order.expiration >= block.timestamp,
            FILE,
            "Order expired",
            orderInfo.orderHash
        );

        // verify maker
        Require.that(
            makerAccount.owner == orderInfo.order.makerAccountOwner &&
            makerAccount.number == orderInfo.order.makerAccountNumber,
            FILE,
            "Order maker account mismatch",
            orderInfo.orderHash
        );

        // verify taker
        Require.that(
            takerAccount.owner == g_taker,
            FILE,
            "Order taker mismatch",
            orderInfo.orderHash
        );

        // verify markets
        Require.that(
            (
                orderInfo.order.baseMarket == outputMarketId &&
                orderInfo.order.quoteMarket == inputMarketId
            ) || (
                orderInfo.order.quoteMarket == outputMarketId &&
                orderInfo.order.baseMarket == inputMarketId
            ),
            FILE,
            "Market mismatch",
            orderInfo.orderHash
        );

        // verify inputWei is non-zero
        Require.that(
            !inputWei.isZero(),
            FILE,
            "InputWei is zero",
            orderInfo.orderHash
        );

        // verify inputWei is positive if-and-only-if:
        // 1) inputMarket is the baseMarket and the order is a buy order
        // 2) inputMarket is the quoteMarket and the order is a sell order
        Require.that(
            inputWei.sign ==
                ((orderInfo.order.baseMarket == inputMarketId) == isBuy(orderInfo.order)),
            FILE,
            "InputWei sign mismatch",
            orderInfo.orderHash
        );
    }

    /**
     * Verifies that the order is decreasing the size of the maker's position.
     */
    function verifyDecreaseOnly(
        Types.Par memory oldInputPar,
        Types.Par memory newInputPar,
        Types.AssetAmount memory assetAmount,
        Account.Info memory makerAccount,
        uint256 outputMarketId
    )
        private
        view
    {
        // verify that the balance of inputMarketId is not increased
        Require.that(
            newInputPar.isZero()
            || (newInputPar.value <= oldInputPar.value && newInputPar.sign == oldInputPar.sign),
            FILE,
            "inputMarket not decreased"
        );

        // verify that the balance of outputMarketId is not increased
        Types.Wei memory oldOutputWei = SOLO_MARGIN.getAccountWei(makerAccount, outputMarketId);
        Require.that(
            assetAmount.value == 0
            || (assetAmount.value <= oldOutputWei.value && assetAmount.sign != oldOutputWei.sign),
            FILE,
            "outputMarket not decreased"
        );
    }

    /**
     * Returns the AssetAmount for the outputMarketId given the order and the inputs. Updates the
     * filled amount of the order in storage.
     */
    function getOutputAssetAmount(
        uint256 inputMarketId,
        uint256 outputMarketId,
        Types.Wei memory inputWei,
        OrderInfo memory orderInfo
    )
        private
        returns (Types.AssetAmount memory)
    {
        uint256 fee = orderInfo.fill.price.getPartial(orderInfo.fill.fee, PRICE_BASE);
        uint256 adjustedPrice = (isBuy(orderInfo.order) == orderInfo.fill.isNegativeFee)
            ? orderInfo.fill.price.sub(fee)
            : orderInfo.fill.price.add(fee);

        uint256 outputAmount;
        uint256 fillAmount;
        if (orderInfo.order.quoteMarket == inputMarketId) {
            outputAmount = inputWei.value.getPartial(PRICE_BASE, adjustedPrice);
            fillAmount = outputAmount;
        } else {
            assert(orderInfo.order.quoteMarket == outputMarketId);
            outputAmount = inputWei.value.getPartial(adjustedPrice, PRICE_BASE);
            fillAmount = inputWei.value;
        }

        updateFilledAmount(orderInfo, fillAmount);

        return Types.AssetAmount({
            sign: !inputWei.sign,
            denomination: Types.AssetDenomination.Wei,
            ref: Types.AssetReference.Delta,
            value: outputAmount
        });
    }

    /**
     * Increases the stored filled amount of the order by fillAmount.
     * Returns the new total filled amount.
     */
    function updateFilledAmount(
        OrderInfo memory orderInfo,
        uint256 fillAmount
    )
        private
    {
        uint256 oldFilledAmount = g_filledAmount[orderInfo.orderHash];
        uint256 totalFilledAmount = oldFilledAmount.add(fillAmount);
        Require.that(
            totalFilledAmount <= orderInfo.order.amount,
            FILE,
            "Cannot overfill order",
            orderInfo.orderHash,
            oldFilledAmount,
            fillAmount
        );

        g_filledAmount[orderInfo.orderHash] = totalFilledAmount;

        emit LogCanonicalOrderFilled(
            orderInfo.orderHash,
            orderInfo.order.makerAccountOwner,
            fillAmount,
            orderInfo.order.triggerPrice,
            orderInfo.order.flags,
            orderInfo.fill
        );
    }

    /**
     * Returns the current price of baseMarket divided by the current price of quoteMarket. This
     * value is multiplied by 10^18.
     */
    function getCurrentPrice(
        uint256 baseMarket,
        uint256 quoteMarket
    )
        private
        view
        returns (uint256)
    {
        Monetary.Price memory basePrice = SOLO_MARGIN.getMarketPrice(baseMarket);
        Monetary.Price memory quotePrice = SOLO_MARGIN.getMarketPrice(quoteMarket);
        return basePrice.value.mul(PRICE_BASE).div(quotePrice.value);
    }

    // ============ Private Parsing Functions ============

    /**
     * Returns the EIP712 hash of an order.
     */
    function getOrderHash(
        Order memory order
    )
        private
        view
        returns (bytes32)
    {
        // compute the overall signed struct hash
        /* solium-disable-next-line indentation */
        bytes32 structHash = keccak256(abi.encode(
            EIP712_ORDER_STRUCT_SCHEMA_HASH,
            order
        ));

        // compute eip712 compliant hash
        /* solium-disable-next-line indentation */
        return keccak256(abi.encodePacked(
            EIP191_HEADER,
            EIP712_DOMAIN_HASH,
            structHash
        ));
    }

    /**
     * Parses out a signature from call data.
     */
    function parseSignature(
        bytes memory data
    )
        private
        pure
        returns (bytes memory)
    {
        Require.that(
            data.length == NUM_ORDER_AND_FILL_BYTES + NUM_SIGNATURE_BYTES,
            FILE,
            "Cannot parse signature from data"
        );

        bytes memory signature = new bytes(NUM_SIGNATURE_BYTES);

        uint256 sigOffset = NUM_ORDER_AND_FILL_BYTES;
        /* solium-disable-next-line security/no-inline-assembly */
        assembly {
            let sigStart := add(data, sigOffset)
            mstore(add(signature, 0x020), mload(add(sigStart, 0x20)))
            mstore(add(signature, 0x040), mload(add(sigStart, 0x40)))
            mstore(add(signature, 0x042), mload(add(sigStart, 0x42)))
        }

        return signature;
    }

    /**
     * Returns true if the order is a buy order.
     */
    function isBuy(
        Order memory order
    )
        private
        pure
        returns (bool)
    {
        return (order.flags & IS_BUY_FLAG) != bytes32(0);
    }

    /**
     * Returns true if the order is a decrease-only order.
     */
    function isDecreaseOnly(
        Order memory order
    )
        private
        pure
        returns (bool)
    {
        return (order.flags & IS_DECREASE_ONLY_FLAG) != bytes32(0);
    }

    /**
     * Returns true if the order's limitFee is negative.
     */
    function isNegativeLimitFee(
        Order memory order
    )
        private
        pure
        returns (bool)
    {
        return (order.flags & IS_NEGATIVE_FEE_FLAG) != bytes32(0);
    }
}