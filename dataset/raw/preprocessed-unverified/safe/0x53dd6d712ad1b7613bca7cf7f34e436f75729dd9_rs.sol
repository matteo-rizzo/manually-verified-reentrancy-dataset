/**
 *Submitted for verification at Etherscan.io on 2021-08-20
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;





/// @title The interface for Graviton oracle router
/// @notice Forwards data about crosschain locking/unlocking events to balance keepers
/// @author Artemij Artamonov - <[email protected]>
/// @author Anton Davydov - <[email protected]>








/// @title The interface for Graviton relay contract
/// @notice Trades native tokens for gton to start crosschain swap,
/// trades gton for native tokens to compelete crosschain swap
/// @author Artemij Artamonov - <[email protected]>
/// @author Anton Davydov - <[email protected]>
interface IRelay is IOracleRouterV2 {
    /// @notice ERC20 wrapped version of the native token
    function wnative() external view returns (IWETH);

    /// @notice UniswapV2 router
    function router() external view returns (IUniswapV2Router01);

    /// @notice relay token
    function gton() external view returns (IERC20);

    /// @notice chains for relay swaps to and from
    function isAllowedChain(string calldata chain) external view returns (bool);

    /// @notice allow/forbid chain to relay swap
    /// @param chain blockchain name, e.g. 'FTM', 'PLG'
    /// @param newBool new permission for the chain
    function setIsAllowedChain(string calldata chain, bool newBool) external;

    /// @notice minimum fee for a destination
    function feeMin(string calldata destination) external view returns (uint256);

    /// @notice percentage fee for a destination
    function feePercent(string calldata destination) external view returns (uint256);

    /// @notice Sets fees for a destination
    /// @param _feeMin Minimum fee
    /// @param _feePercent Percentage fee
    function setFees(string calldata destination, uint256 _feeMin, uint256 _feePercent) external;

    /// @notice minimum amount of native tokens allowed to swap
    function lowerLimit(string calldata destination) external view returns (uint256);

    /// @notice maximum amount of native tokens allowed to swap
    function upperLimit(string calldata destination) external view returns (uint256);

    /// @notice Sets limits for a destination
    /// @param _lowerLimit Minimum amount of native tokens allowed to swap
    /// @param _upperLimit Maximum amount of native tokens allowed to swap
    function setLimits(string calldata destination, uint256 _lowerLimit, uint256 _upperLimit) external;

    /// @notice topic0 of the event associated with initiating a relay transfer
    function relayTopic() external view returns (bytes32);

    /// @notice Sets topic0 of the event associated with initiating a relay transfer
    function setRelayTopic(bytes32 _relayTopic) external;

    /// @notice Trades native tokens for relay, takes fees,
    /// emits event to start crosschain transfer
    /// @param destination The blockchain that will receive native tokens
    /// @param receiver The account that will receive native tokens
    function lock(string calldata destination, bytes calldata receiver) external payable;

    /// @notice Transfers locked ERC20 tokens to owner
    function reclaimERC20(IERC20 token, uint256 amount) external;

    /// @notice Transfers locked native tokens to owner
    function reclaimNative(uint256 amount) external;

    /// @notice Event emitted when native tokens equivalent to
    /// `amount` of relay tokens are locked via `#lock`
    /// @dev Oracles read this event and unlock
    /// equivalent amount of native tokens on the destination chain
    /// @param destinationHash The blockchain that will receive native tokens
    /// @dev indexed string returns keccak256 of the value
    /// @param receiverHash The account that will receive native tokens
    /// @dev indexed bytes returns keccak256 of the value
    /// @param destination The blockchain that will receive native tokens
    /// @param receiver The account that will receive native tokens
    /// @param amount The amount of relay tokens equivalent to the
    /// amount of locked native tokens
    event Lock(
        string indexed destinationHash,
        bytes indexed receiverHash,
        string destination,
        bytes receiver,
        uint256 amount
    );

    /// @notice Event emitted when fees are calculated
    /// @param amountIn Native tokens sent to dex
    /// @param amountOut Relay tokens received on dex
    /// @param feeMin Minimum fee
    /// @param feePercent Percentage for the fee in %
    /// @dev precision 3 decimals
    /// @param fee Percentage fee in relay tokens
    /// @param amountMinusFee Relay tokens minus fees
    event CalculateFee(
        uint256 amountIn,
        uint256 amountOut,
        uint256 feeMin,
        uint256 feePercent,
        uint256 fee,
        uint256 amountMinusFee
    );

    /// @notice Event emitted when the relay tokens are traded for
    /// `amount0` of gton swaped for native tokens via '#routeValue'
    /// `amount1` of native tokens sent to the `user` via '#routeValue'
    event DeliverRelay(address user, uint256 amount0, uint256 amount1);

    /// @notice Event emitted when the RelayTopic is set via '#setRelayTopic'
    /// @param topicOld The previous topic
    /// @param topicNew The new topic
    event SetRelayTopic(bytes32 indexed topicOld, bytes32 indexed topicNew);

    /// @notice Event emitted when the wallet is set via '#setWallet'
    /// @param walletOld The previous wallet address
    /// @param walletNew The new wallet address
    event SetWallet(address indexed walletOld, address indexed walletNew);

    /// @notice Event emitted when permission for a chain is set via '#setIsAllowedChain'
    /// @param chain Name of blockchain whose permission is changed, i.e. "FTM", "PLG"
    /// @param newBool Updated permission
    event SetIsAllowedChain(string chain, bool newBool);

    /// @notice Event emitted when fees are set via '#setFees'
    /// @param _feeMin Minimum fee
    /// @param _feePercent Percentage fee
    event SetFees(string destination, uint256 _feeMin, uint256 _feePercent);

    /// @notice Event emitted when limits are set via '#setLimits'
    /// @param _lowerLimit Minimum fee
    /// @param _upperLimit Percentage fee
    event SetLimits(string destination, uint256 _lowerLimit, uint256 _upperLimit);
}

/// @title Relay
/// @author Artemij Artamonov - <[email protected]>
/// @author Anton Davydov - <[email protected]>
contract Relay is IRelay {

    /// @inheritdoc IOracleRouterV2
    address public override owner;

    modifier isOwner() {
        require(msg.sender == owner, "ACW");
        _;
    }

    /// @inheritdoc IRelay
    IWETH public override wnative;
    /// @inheritdoc IRelay
    IUniswapV2Router01 public override router;
    /// @inheritdoc IRelay
    IERC20 public override gton;

    /// @inheritdoc IRelay
    mapping (string => uint256) public override feeMin;
    /// @inheritdoc IRelay
    /// @dev 30000 = 30%, 200 = 0.2%, 1 = 0.001%
    mapping (string => uint256) public override feePercent;

    /// @inheritdoc IRelay
    mapping(string => uint256) public override lowerLimit;

    /// @inheritdoc IRelay
    mapping(string => uint256) public override upperLimit;

    /// @inheritdoc IRelay
    bytes32 public override relayTopic;

    /// @inheritdoc IOracleRouterV2
    mapping(address => bool) public override canRoute;

    /// @inheritdoc IRelay
    mapping(string => bool) public override isAllowedChain;

    receive() external payable {
        // only accept ETH via fallback from the WETH contract
        assert(msg.sender == address(wnative));
    }

    constructor (
        IWETH _wnative,
        IUniswapV2Router01 _router,
        IERC20 _gton,
        bytes32 _relayTopic,
        string[] memory allowedChains,
        uint[2][] memory fees,
        uint[2][] memory limits
    ) {
        owner = msg.sender;
        wnative = _wnative;
        router = _router;
        gton = _gton;
        relayTopic = _relayTopic;
        for (uint256 i = 0; i < allowedChains.length; i++) {
            isAllowedChain[allowedChains[i]] = true;
            feeMin[allowedChains[i]] = fees[i][0];
            feePercent[allowedChains[i]] = fees[i][1];
            lowerLimit[allowedChains[i]] = limits[i][0];
            upperLimit[allowedChains[i]] = limits[i][1];
        }
    }

    /// @inheritdoc IOracleRouterV2
    function setOwner(address _owner) external override isOwner {
        address ownerOld = owner;
        owner = _owner;
        emit SetOwner(ownerOld, _owner);
    }

    /// @inheritdoc IRelay
    function setIsAllowedChain(string calldata chain, bool newBool)
        external
        override
        isOwner
    {
        isAllowedChain[chain] = newBool;
        emit SetIsAllowedChain(chain, newBool);
    }

    /// @inheritdoc IRelay
    function setFees(string calldata destination, uint256 _feeMin, uint256 _feePercent) external override isOwner {
        feeMin[destination] = _feeMin;
        feePercent[destination] = _feePercent;
        emit SetFees(destination, _feeMin, _feePercent);
    }

    /// @inheritdoc IRelay
    function setLimits(string calldata destination, uint256 _lowerLimit, uint256 _upperLimit) external override isOwner {
        lowerLimit[destination] = _lowerLimit;
        upperLimit[destination] = _upperLimit;
        emit SetLimits(destination, _lowerLimit, _upperLimit);
    }

    /// @inheritdoc IRelay
    function lock(string calldata destination, bytes calldata receiver) external payable override {
        require(isAllowedChain[destination], "R1");
        require(msg.value > lowerLimit[destination], "R2");
        require(msg.value < upperLimit[destination], "R3");
        // wrap native tokens
        wnative.deposit{value: msg.value}();
        // trade wrapped native tokens for relay tokens
        wnative.approve(address(router), msg.value);
        address[] memory path = new address[](2);
        path[0] = address(wnative);
        path[1] = address(gton);
        uint256[] memory amounts = router.swapExactTokensForTokens(msg.value, 0, path, address(this), block.timestamp+3600);
        // subtract fee
        uint256 amountMinusFee;
        uint256 fee = amounts[1] * feePercent[destination] / 100000;
        if (fee > feeMin[destination]) {
            amountMinusFee = amounts[1] - fee;
        } else {
            amountMinusFee = amounts[1] - feeMin[destination];
        }
        emit CalculateFee(amounts[0], amounts[1], feeMin[destination], feePercent[destination], fee, amountMinusFee);
        // check that remainder after subtracting fees is larger than 0
        require(amountMinusFee > 0, "R4");
        // emit event to notify oracles and initiate crosschain transfer
        emit Lock(destination, receiver, destination, receiver, amountMinusFee);
    }

    /// @inheritdoc IRelay
    function reclaimERC20(IERC20 token, uint256 amount) external override isOwner {
        token.transfer(msg.sender, amount);
    }

    /// @inheritdoc IRelay
    function reclaimNative(uint256 amount) external override isOwner {
        payable(msg.sender).transfer(amount);
    }

    /// @inheritdoc IOracleRouterV2
    function setCanRoute(address parser, bool _canRoute)
        external
        override
        isOwner
    {
        canRoute[parser] = _canRoute;
        emit SetCanRoute(msg.sender, parser, canRoute[parser]);
    }

    /// @inheritdoc IRelay
    function setRelayTopic(bytes32 _relayTopic) external override isOwner {
        bytes32 topicOld = relayTopic;
        relayTopic = _relayTopic;
        emit SetRelayTopic(topicOld, _relayTopic);
    }

    function equal(bytes32 a, bytes32 b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function deserializeUint(
        bytes memory b,
        uint256 startPos,
        uint256 len
    ) internal pure returns (uint256) {
        uint256 v = 0;
        for (uint256 p = startPos; p < startPos + len; p++) {
            v = v * 256 + uint256(uint8(b[p]));
        }
        return v;
    }

    function deserializeAddress(bytes memory b, uint256 startPos)
        internal
        pure
        returns (address)
    {
        return address(uint160(deserializeUint(b, startPos, 20)));
    }

    /// @inheritdoc IOracleRouterV2
    function routeValue(
        bytes16 uuid,
        string memory chain,
        bytes memory emiter,
        bytes32 topic0,
        bytes memory token,
        bytes memory sender,
        bytes memory receiver,
        uint256 amount
    ) external override {
        require(canRoute[msg.sender], "ACR");
        if (equal(topic0, relayTopic)) {
            // trade relay tokens for wrapped native tokens
            gton.approve(address(router), amount);
            address[] memory path = new address[](2);
            path[0] = address(gton);
            path[1] = address(wnative);
            uint[] memory amounts = router.swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp+3600);
            // unwrap to get native tokens
            wnative.withdraw(amounts[1]);
            // transfer native tokens to the receiver
            address payable user = payable(deserializeAddress(receiver, 0));
            user.transfer(amounts[1]);
            emit DeliverRelay(user, amounts[0], amounts[1]);
        }
        emit RouteValue(uuid, chain, emiter, token, sender, receiver, amount);
    }
}