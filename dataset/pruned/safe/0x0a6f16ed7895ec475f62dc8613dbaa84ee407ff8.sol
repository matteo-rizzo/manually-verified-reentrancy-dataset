// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;

import './libraries/Ownable.sol';
import './interfaces/ICentaurFactory.sol';
import './interfaces/ICentaurPool.sol';
import './interfaces/ICentaurRouter.sol';
import './interfaces/ICloneFactory.sol';
import './CentaurSettlement.sol';
import './CentaurRouter.sol';
import './CentaurPool.sol';

contract CentaurFactory is ICentaurFactory, Ownable {
	uint public override poolFee;

    address public override poolLogic;
	address public override cloneFactory;
    address public override settlement;
    address payable public override router;

    // Base token => Pool
    mapping(address => address) public override getPool;
    address[] public override allPools;

    event PoolCreated(address indexed baseToken, address pool, uint);

    constructor(address _poolLogic, address _cloneFactory, address _WETH) public {
        poolLogic = _poolLogic;
        cloneFactory = _cloneFactory;

        // Deploy CentaurSettlement
        CentaurSettlement settlementContract = new CentaurSettlement(address(this), 3 minutes);
        settlement = address(settlementContract);


        // Deploy CentaurRouter
        CentaurRouter routerContract = new CentaurRouter(address(this), _WETH);
        router = address(routerContract);

        // Default poolFee = 0.2%
        poolFee = 200000000000000000;
    }

    function allPoolsLength() external override view returns (uint) {
        return allPools.length;
    }

    function isValidPool(address _pool) external view override returns (bool) {
        for (uint i = 0; i < allPools.length; i++) {
            if (allPools[i] == _pool) {
                return true;
            }
        }

        return false;
    }

    function createPool(address _baseToken, address _oracle, uint _liquidityParameter) external onlyOwner override returns (address pool) {
    	require(_baseToken != address(0) && _oracle != address(0), 'CentaurSwap: ZERO_ADDRESS');
    	require(getPool[_baseToken] == address(0), 'CentaurSwap: POOL_EXISTS');

    	pool = ICloneFactory(cloneFactory).createClone(poolLogic);
    	ICentaurPool(pool).init(
            address(this),
            _baseToken,
            _oracle,
            _liquidityParameter
        );

    	getPool[_baseToken] = pool;
        allPools.push(pool);

        emit PoolCreated(_baseToken, pool, allPools.length);
    }

    function addPool(address _pool) external onlyOwner override {
        address baseToken = ICentaurPool(_pool).baseToken();
        require(baseToken != address(0), 'CentaurSwap: ZERO_ADDRESS');
        require(getPool[baseToken] == address(0), 'CentaurSwap: POOL_EXISTS');

        getPool[baseToken] = _pool;
        allPools.push(_pool);
    }

    function removePool(address _pool) external onlyOwner override {
        address baseToken = ICentaurPool(_pool).baseToken();
        require(baseToken != address(0), 'CentaurSwap: ZERO_ADDRESS');
        require(getPool[baseToken] != address(0), 'CentaurSwap: POOL_NOT_FOUND');

        getPool[baseToken] = address(0);
        for (uint i = 0; i < allPools.length; i++) {
            if (allPools[i] == _pool) {
                allPools[i] = allPools[allPools.length - 1];
                allPools.pop();
                break;
            }
        }
    }

    // Pool Functions
    function setPoolTradeEnabled(address _pool, bool _tradeEnabled) public onlyOwner override {
        ICentaurPool(_pool).setTradeEnabled(_tradeEnabled);
    }

    function setPoolDepositEnabled(address _pool, bool _depositEnabled) public onlyOwner override {
        ICentaurPool(_pool).setDepositEnabled(_depositEnabled);
    }

    function setPoolWithdrawEnabled(address _pool, bool _withdrawEnabled) public onlyOwner override {
        ICentaurPool(_pool).setWithdrawEnabled(_withdrawEnabled);
    }

    function setPoolLiquidityParameter(address _pool, uint _liquidityParameter) public onlyOwner override {
        ICentaurPool(_pool).setLiquidityParameter(_liquidityParameter);
    }

    function setAllPoolsTradeEnabled(bool _tradeEnabled) external onlyOwner override {
        for (uint i = 0; i < allPools.length; i++) {
            setPoolTradeEnabled(allPools[i], _tradeEnabled);
        }
    }

    function setAllPoolsDepositEnabled(bool _depositEnabled) external onlyOwner override {
        for (uint i = 0; i < allPools.length; i++) {
            setPoolDepositEnabled(allPools[i], _depositEnabled);
        }
    }

    function setAllPoolsWithdrawEnabled(bool _withdrawEnabled) external onlyOwner override {
        for (uint i = 0; i < allPools.length; i++) {
            setPoolWithdrawEnabled(allPools[i], _withdrawEnabled);
        }
    }

    function emergencyWithdrawFromPool(address _pool, address _token, uint _amount, address _to) external onlyOwner override {
        ICentaurPool(_pool).emergencyWithdraw(_token, _amount, _to);
    }

    // Router Functions
    function setRouterOnlyEOAEnabled(bool _onlyEOAEnabled) external onlyOwner override {
        CentaurRouter(router).setOnlyEOAEnabled(_onlyEOAEnabled);
    }

    function setRouterContractWhitelist(address _address, bool _whitelist) external onlyOwner override {
        if (_whitelist) {
            CentaurRouter(router).addContractToWhitelist(_address);
        } else {
            CentaurRouter(router).removeContractFromWhitelist(_address);
        }
    }

    // Settlement Functions
    function setSettlementDuration(uint _duration) external onlyOwner override {
        CentaurSettlement(settlement).setSettlementDuration(_duration);
    }

    // Helper Functions
    function setPoolFee(uint _poolFee) external onlyOwner override {
        poolFee = _poolFee;
    }

    function setPoolLogic(address _poolLogic) external onlyOwner override {
        poolLogic = _poolLogic;
    }

    function setCloneFactory(address _cloneFactory) external onlyOwner override {
        cloneFactory = _cloneFactory;
    }

    function setSettlement(address _settlement) external onlyOwner override {
        settlement = _settlement;
    }

    function setRouter(address payable _router) external onlyOwner override {
        router = _router;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;



// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;



// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;



// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;



// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

import './libraries/SafeMath.sol';
import './interfaces/ICentaurFactory.sol';
import './interfaces/ICentaurPool.sol';
import './interfaces/ICentaurSettlement.sol';

contract CentaurSettlement is ICentaurSettlement {

	using SafeMath for uint;

	bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

	address public override factory;
	uint public override settlementDuration;

	// User address -> Token address -> Settlement
	mapping(address => mapping (address => Settlement)) pendingSettlement;

	modifier onlyFactory() {
        require(msg.sender == factory, 'CentaurSwap: ONLY_FACTORY_ALLOWED');
        _;
    }

	constructor (address _factory, uint _settlementDuration) public {
		factory = _factory;
		settlementDuration = _settlementDuration;
	}

	function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'CentaurSwap: TRANSFER_FAILED');
    }

	function addSettlement(
		address _sender,
		Settlement memory _pendingSettlement
	) external override {
		require(ICentaurFactory(factory).isValidPool(_pendingSettlement.fPool), 'CentaurSwap: POOL_NOT_FOUND');
		require(ICentaurFactory(factory).isValidPool(_pendingSettlement.tPool), 'CentaurSwap: POOL_NOT_FOUND');

		require(msg.sender == _pendingSettlement.tPool, 'CentaurSwap: INVALID_POOL');

		require(pendingSettlement[_sender][_pendingSettlement.fPool].settlementTimestamp == 0, 'CentaurSwap: SETTLEMENT_EXISTS');
		require(pendingSettlement[_sender][_pendingSettlement.tPool].settlementTimestamp == 0, 'CentaurSwap: SETTLEMENT_EXISTS');

		pendingSettlement[_sender][_pendingSettlement.fPool] = _pendingSettlement;
		pendingSettlement[_sender][_pendingSettlement.tPool] = _pendingSettlement;

	}

	function removeSettlement(
		address _sender,
		address _fPool,
		address _tPool
	) external override {
		require(msg.sender == _tPool, 'CentaurSwap: INVALID_POOL');

		require(pendingSettlement[_sender][_fPool].settlementTimestamp != 0, 'CentaurSwap: SETTLEMENT_DOES_NOT_EXISTS');
		require(pendingSettlement[_sender][_tPool].settlementTimestamp != 0, 'CentaurSwap: SETTLEMENT_DOES_NOT_EXISTS');

		require(block.timestamp >= pendingSettlement[_sender][_fPool].settlementTimestamp, 'CentaurSwap: SETTLEMENT_PENDING');

		_safeTransfer(ICentaurPool(_tPool).baseToken(), _tPool, pendingSettlement[_sender][_fPool].maxAmountOut);

		delete pendingSettlement[_sender][_fPool];
		delete pendingSettlement[_sender][_tPool];
	}

	function getPendingSettlement(address _sender, address _pool) external override view returns (Settlement memory) {
		return pendingSettlement[_sender][_pool];
	}
	
	function hasPendingSettlement(address _sender, address _pool) external override view returns (bool) {
		return (pendingSettlement[_sender][_pool].settlementTimestamp != 0);
	}

	// Helper Functions
	function setSettlementDuration(uint _settlementDuration) onlyFactory external override {
		settlementDuration = _settlementDuration;
	}
}

// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;

import './libraries/SafeMath.sol';
import './libraries/TransferHelper.sol';
import './interfaces/IERC20.sol';
import './interfaces/IWETH.sol';
import './interfaces/ICentaurFactory.sol';
import './interfaces/ICentaurPool.sol';
import './interfaces/ICentaurRouter.sol';
import "@openzeppelin/contracts/utils/Address.sol";

contract CentaurRouter is ICentaurRouter {
	using SafeMath for uint;

	address public override factory;
    address public immutable override WETH;
    bool public override onlyEOAEnabled;
    mapping(address => bool) public override whitelistContracts;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'CentaurSwap: EXPIRED');
        _;
    }

    modifier onlyEOA(address _address) {
        if (onlyEOAEnabled) {
            require((!Address.isContract(_address) || whitelistContracts[_address]), 'CentaurSwap: ONLY_EOA_ALLOWED');
        }
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == factory, 'CentaurSwap: ONLY_FACTORY_ALLOWED');
        _;
    }

    constructor(address _factory, address _WETH) public {
        factory = _factory;
        WETH = _WETH;
        onlyEOAEnabled = true;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address _baseToken,
        uint _amount,
        uint _minLiquidity
    ) internal view virtual returns (uint liquidity) {
		ICentaurPool pool = ICentaurPool(ICentaurFactory(factory).getPool(_baseToken));

        uint _totalSupply = pool.totalSupply();
        uint _baseTokenTargetAmount = pool.baseTokenTargetAmount();
        liquidity = _amount;

        if (_totalSupply == 0) {
            liquidity = _amount.add(_baseTokenTargetAmount);
        } else {
            liquidity = _amount.mul(_totalSupply).div(_baseTokenTargetAmount);
        }

    	require(liquidity > _minLiquidity, 'CentaurSwap: INSUFFICIENT_OUTPUT_AMOUNT');
    }

    function addLiquidity(
        address _baseToken,
        uint _amount,
        address _to,
        uint _minLiquidity,
        uint _deadline
    ) external virtual override ensure(_deadline) onlyEOA(msg.sender) returns (uint amount, uint liquidity) {
        address pool = ICentaurFactory(factory).getPool(_baseToken);
        require(pool != address(0), 'CentaurSwap: POOL_NOT_FOUND');

        (liquidity) = _addLiquidity(_baseToken, _amount, _minLiquidity);
        
        TransferHelper.safeTransferFrom(_baseToken, msg.sender, pool, _amount);
        liquidity = ICentaurPool(pool).mint(_to);
        require(liquidity > _minLiquidity, 'CentaurSwap: INSUFFICIENT_OUTPUT_AMOUNT');

        return (_amount, liquidity);
    }

    function addLiquidityETH(
        address _to,
        uint _minLiquidity,
        uint _deadline
    ) external virtual override payable ensure(_deadline) onlyEOA(msg.sender) returns (uint amount, uint liquidity) {
        address pool = ICentaurFactory(factory).getPool(WETH);
        require(pool != address(0), 'CentaurSwap: POOL_NOT_FOUND');

        (liquidity) = _addLiquidity(WETH, msg.value, _minLiquidity);

        IWETH(WETH).deposit{value: msg.value}();
        assert(IWETH(WETH).transfer(pool, msg.value));
        liquidity = ICentaurPool(pool).mint(_to);

        require(liquidity > _minLiquidity, 'CentaurSwap: INSUFFICIENT_OUTPUT_AMOUNT');
        
        return (msg.value, liquidity);
    }

    function removeLiquidity(
        address _baseToken,
        uint _liquidity,
        address _to,
        uint _minAmount,
        uint _deadline
    ) public virtual override ensure(_deadline) onlyEOA(msg.sender) returns (uint amount) {
        address pool = ICentaurFactory(factory).getPool(_baseToken);
        require(pool != address(0), 'CentaurSwap: POOL_NOT_FOUND');

        ICentaurPool(pool).transferFrom(msg.sender, pool, _liquidity); // send liquidity to pool
        amount = ICentaurPool(pool).burn(_to);
        require(amount > _minAmount, 'CentaurSwap: INSUFFICIENT_OUTPUT_AMOUNT');

        return amount;
    }

    function removeLiquidityETH(
        uint _liquidity,
        address _to,
        uint _minAmount,
        uint _deadline
    ) public virtual override ensure(_deadline) onlyEOA(msg.sender) returns (uint amount) {
        amount = removeLiquidity(
            WETH,
            _liquidity,
            address(this),
            _minAmount,
            _deadline
        );

        IWETH(WETH).withdraw(amount);
        TransferHelper.safeTransferETH(_to, amount);

        return amount;
    }

    function swapExactTokensForTokens(
        address _fromToken,
        uint _amountIn,
        address _toToken,
        uint _amountOutMin,
        address _to,
        uint _deadline
    ) external virtual override ensure(_deadline) onlyEOA(msg.sender) {
        require(getAmountOut(_fromToken, _toToken, _amountIn) >= _amountOutMin, 'CentaurSwap: INSUFFICIENT_OUTPUT_AMOUNT');
        
        (address inputTokenPool, address outputTokenPool) = validatePools(_fromToken, _toToken);

        TransferHelper.safeTransferFrom(_fromToken, msg.sender, inputTokenPool, _amountIn);

        (uint finalAmountIn, uint value) = ICentaurPool(inputTokenPool).swapFrom(msg.sender);
        ICentaurPool(outputTokenPool).swapTo(msg.sender, _fromToken, finalAmountIn, value, _to);
    }

    function swapExactETHForTokens(
        address _toToken,
        uint _amountOutMin,
        address _to,
        uint _deadline
    ) external virtual override payable ensure(_deadline) onlyEOA(msg.sender) {
        require(getAmountOut(WETH, _toToken, msg.value) >= _amountOutMin, 'CentaurSwap: INSUFFICIENT_OUTPUT_AMOUNT');
        
        (address inputTokenPool, address outputTokenPool) = validatePools(WETH, _toToken);
        IWETH(WETH).deposit{value: msg.value}();
        assert(IWETH(WETH).transfer(inputTokenPool, msg.value));
        // TransferHelper.safeTransferFrom(WETH, msg.sender, inputTokenPool, msg.value);

        (uint finalAmountIn, uint value) = ICentaurPool(inputTokenPool).swapFrom(msg.sender);
        ICentaurPool(outputTokenPool).swapTo(msg.sender, WETH, finalAmountIn, value, _to);
    }

    function swapTokensForExactTokens(
        address _fromToken,
        uint _amountInMax,
        address _toToken,
        uint _amountOut,
        address _to,
        uint _deadline
    ) external virtual override ensure(_deadline) onlyEOA(msg.sender) {
        uint amountIn = getAmountIn(_fromToken, _toToken, _amountOut);
        require(amountIn <= _amountInMax, 'CentaurSwap: EXCESSIVE_INPUT_AMOUNT');
        
        (address inputTokenPool, address outputTokenPool) = validatePools(_fromToken, _toToken);

        TransferHelper.safeTransferFrom(_fromToken, msg.sender, inputTokenPool, amountIn);

        (uint finalAmountIn, uint value) = ICentaurPool(inputTokenPool).swapFrom(msg.sender);
        ICentaurPool(outputTokenPool).swapTo(msg.sender, _fromToken, finalAmountIn, value, _to);
    }

    function swapETHForExactTokens(
        address _toToken,
        uint _amountOut,
        address _to,
        uint _deadline
    ) external virtual override payable ensure(_deadline) onlyEOA(msg.sender) {
        uint amountIn = getAmountIn(WETH, _toToken, _amountOut);
        require(amountIn <= msg.value, 'CentaurSwap: EXCESSIVE_INPUT_AMOUNT');
        
        (address inputTokenPool, address outputTokenPool) = validatePools(WETH, _toToken);

        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(inputTokenPool, amountIn));

        (uint finalAmountIn, uint value) = ICentaurPool(inputTokenPool).swapFrom(msg.sender);
        ICentaurPool(outputTokenPool).swapTo(msg.sender, WETH, finalAmountIn, value, _to);

        if (msg.value > amountIn) TransferHelper.safeTransferETH(msg.sender, msg.value - amountIn);
    }

    function swapSettle(address _sender, address _pool) external virtual override returns (uint amount, address receiver) {
        (amount, receiver) = ICentaurPool(_pool).swapSettle(_sender);
        address token = ICentaurPool(_pool).baseToken();
        if (token == WETH) {
            IWETH(WETH).withdraw(amount);
            TransferHelper.safeTransferETH(receiver, amount);
        } else {
            TransferHelper.safeTransfer(token, receiver, amount);
        }
    }

    function swapSettleMultiple(address _sender, address[] memory _pools) external virtual override {
        for(uint i = 0; i < _pools.length; i++) {
            (uint amount, address receiver) = ICentaurPool(_pools[i]).swapSettle(_sender);
            address token = ICentaurPool(_pools[i]).baseToken();
            if (token == WETH) {
                IWETH(WETH).withdraw(amount);
                TransferHelper.safeTransferETH(receiver, amount);
            } else {
                TransferHelper.safeTransfer(token, receiver, amount);
            }
        }
    }

    function validatePools(address _fromToken, address _toToken) public view virtual override returns (address inputTokenPool, address outputTokenPool) {
        inputTokenPool = ICentaurFactory(factory).getPool(_fromToken);
        require(inputTokenPool != address(0), 'CentaurSwap: POOL_NOT_FOUND');

        outputTokenPool = ICentaurFactory(factory).getPool(_toToken);
        require(outputTokenPool != address(0), 'CentaurSwap: POOL_NOT_FOUND');

        return (inputTokenPool, outputTokenPool);
    } 

    function getAmountOut(
        address _fromToken,
        address _toToken,
        uint _amountIn
    ) public view virtual override returns (uint amountOut) {
        uint poolFee = ICentaurFactory(factory).poolFee();
        uint value = ICentaurPool(ICentaurFactory(factory).getPool(_fromToken)).getValueFromAmountIn(_amountIn);
        uint amountOutBeforeFees = ICentaurPool(ICentaurFactory(factory).getPool(_toToken)).getAmountOutFromValue(value);
        amountOut = (amountOutBeforeFees).mul(uint(100 ether).sub(poolFee)).div(100 ether);
    }

    function getAmountIn(
        address _fromToken,
        address _toToken,
        uint _amountOut
    ) public view virtual override returns (uint amountIn) {
        uint poolFee = ICentaurFactory(factory).poolFee();
        uint amountOut = _amountOut.mul(100 ether).div(uint(100 ether).sub(poolFee));
        uint value = ICentaurPool(ICentaurFactory(factory).getPool(_toToken)).getValueFromAmountOut(amountOut);
        amountIn = ICentaurPool(ICentaurFactory(factory).getPool(_fromToken)).getAmountInFromValue(value);
    }

    // Helper functions
    function setFactory(address _factory) external virtual override onlyFactory {
        factory = _factory;
    }

    function setOnlyEOAEnabled(bool _onlyEOAEnabled) external virtual override onlyFactory {
        onlyEOAEnabled = _onlyEOAEnabled;
    }

    function addContractToWhitelist(address _address) external virtual override onlyFactory {
        require(Address.isContract(_address), 'CentaurSwap: NOT_CONTRACT');
        whitelistContracts[_address] = true;
    }

    function removeContractFromWhitelist(address _address) external virtual override onlyFactory {
        whitelistContracts[_address] = false;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

import './CentaurLPToken.sol';
import './libraries/Initializable.sol';
import './libraries/SafeMath.sol';
import './libraries/CentaurMath.sol';
import './interfaces/IERC20.sol';
import './interfaces/ICentaurFactory.sol';
import './interfaces/ICentaurPool.sol';
import './interfaces/ICentaurSettlement.sol';
import './interfaces/IOracle.sol';

contract CentaurPool is Initializable, CentaurLPToken {
    using SafeMath for uint;

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;
    address public baseToken;
    uint public baseTokenDecimals;
    address public oracle;
    uint public oracleDecimals;

    uint public baseTokenTargetAmount;
    uint public baseTokenBalance;

    uint public liquidityParameter;

    bool public tradeEnabled;
    bool public depositEnabled;
    bool public withdrawEnabled;

    uint private unlocked;
    modifier lock() {
        require(unlocked == 1, 'CentaurSwap: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier tradeAllowed() {
        require(tradeEnabled, "CentaurSwap: TRADE_NOT_ALLOWED");
        _;
    }

    modifier depositAllowed() {
        require(depositEnabled, "CentaurSwap: DEPOSIT_NOT_ALLOWED");
        _;
    }

    modifier withdrawAllowed() {
        require(withdrawEnabled, "CentaurSwap: WITHDRAW_NOT_ALLOWED");
        _;
    }

    modifier onlyRouter() {
        require(msg.sender == ICentaurFactory(factory).router(), 'CentaurSwap: ONLY_ROUTER_ALLOWED');
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == factory, 'CentaurSwap: ONLY_FACTORY_ALLOWED');
        _;
    }

    event Mint(address indexed sender, uint amount);
    event Burn(address indexed sender, uint amount, address indexed to);
    event AmountIn(address indexed sender, uint amount);
    event AmountOut(address indexed sender, uint amount, address indexed to);
    event EmergencyWithdraw(uint256 _timestamp, address indexed _token, uint256 _amount, address indexed _to);

    function init(address _factory, address _baseToken, address _oracle, uint _liquidityParameter) external initializer {
        factory = _factory;
        baseToken = _baseToken;
        baseTokenDecimals = IERC20(baseToken).decimals();
        oracle = _oracle;
        oracleDecimals = IOracle(oracle).decimals();

        tradeEnabled = false;
        depositEnabled = false;
        withdrawEnabled = false;

        liquidityParameter = _liquidityParameter;

        symbol = string(abi.encodePacked("CS-", IERC20(baseToken).symbol()));
        decimals = baseTokenDecimals;

        unlocked = 1;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'CentaurSwap: TRANSFER_FAILED');
    }

    function mint(address to) external lock onlyRouter depositAllowed returns (uint liquidity) {
        uint balance = IERC20(baseToken).balanceOf(address(this));
        uint amount = balance.sub(baseTokenBalance);

        if (totalSupply == 0) {
            liquidity = amount.add(baseTokenTargetAmount);
        } else {
            liquidity = amount.mul(totalSupply).div(baseTokenTargetAmount);
        }

        require(liquidity > 0, 'CentaurSwap: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        baseTokenBalance = baseTokenBalance.add(amount);
        baseTokenTargetAmount = baseTokenTargetAmount.add(amount);

        emit Mint(msg.sender, amount);
    }

    function burn(address to) external lock onlyRouter withdrawAllowed returns (uint amount) {
        uint liquidity = balanceOf[address(this)];

        amount = liquidity.mul(baseTokenTargetAmount).div(totalSupply);

        require(amount > 0, 'CentaurSwap: INSUFFICIENT_LIQUIDITY_BURNED');

        require(baseTokenBalance >= amount, 'CentaurSwap: INSUFFICIENT_LIQUIDITY');

        _burn(address(this), liquidity);
        _safeTransfer(baseToken, to, amount);

        baseTokenBalance = baseTokenBalance.sub(amount);
        baseTokenTargetAmount = baseTokenTargetAmount.sub(amount);

        emit Burn(msg.sender, amount, to);
    }

    function swapTo(address _sender, address _fromToken, uint _amountIn, uint _value, address _receiver) external lock onlyRouter tradeAllowed returns (uint maxAmount) {
        require(_fromToken != baseToken, 'CentaurSwap: INVALID_POOL');

        address pool = ICentaurFactory(factory).getPool(_fromToken);
        require(pool != address(0), 'CentaurSwap: POOL_NOT_FOUND');

        // Check if has pendingSettlement
        address settlement = ICentaurFactory(factory).settlement();
        require(!ICentaurSettlement(settlement).hasPendingSettlement(_sender, address(this)), 'CentaurSwap: PENDING_SETTLEMENT');
        
        // maxAmount because amount might be lesser during settlement. (If amount is more, excess is given back to pool)
        maxAmount = getAmountOutFromValue(_value);

        ICentaurSettlement.Settlement memory pendingSettlement = ICentaurSettlement.Settlement(
                pool,
                _amountIn,
                ICentaurPool(pool).baseTokenTargetAmount(),
                (ICentaurPool(pool).baseTokenBalance()).sub(_amountIn),
                ICentaurPool(pool).liquidityParameter(),
                address(this), 
                maxAmount,
                baseTokenTargetAmount,
                baseTokenBalance,
                liquidityParameter,
                _receiver,
                block.timestamp.add(ICentaurSettlement(settlement).settlementDuration())
            );

        // Subtract maxAmount from baseTokenBalance first, difference (if any) will be added back during settlement
        baseTokenBalance = baseTokenBalance.sub(maxAmount);

        // Add to pending settlement
        ICentaurSettlement(settlement).addSettlement(_sender, pendingSettlement);

        // Transfer amount to settlement for escrow
        _safeTransfer(baseToken, settlement, maxAmount);

        return maxAmount;
    }

    function swapFrom(address _sender) external lock onlyRouter tradeAllowed returns (uint amount, uint value) {
        uint balance = IERC20(baseToken).balanceOf(address(this));

        require(balance > baseTokenBalance, 'CentaurSwap: INSUFFICIENT_SWAP_AMOUNT');

        // Check if has pendingSettlement
        address settlement = ICentaurFactory(factory).settlement();
        require(!ICentaurSettlement(settlement).hasPendingSettlement(_sender, address(this)), 'CentaurSwap: PENDING_SETTLEMENT');

        amount = balance.sub(baseTokenBalance);
        value = getValueFromAmountIn(amount);

        baseTokenBalance = balance;

        emit AmountIn(_sender, amount);

        return (amount, value);
    }

    function swapSettle(address _sender) external lock returns (uint, address) {
        address settlement = ICentaurFactory(factory).settlement();
        ICentaurSettlement.Settlement memory pendingSettlement = ICentaurSettlement(settlement).getPendingSettlement(_sender, address(this));

        require (pendingSettlement.settlementTimestamp != 0, 'CentaurSwap: NO_PENDING_SETTLEMENT');
        require (pendingSettlement.tPool == address(this), 'CentaurSwap: WRONG_POOL_SETTLEMENT');
        require (block.timestamp >= pendingSettlement.settlementTimestamp, 'CentaurSwap: SETTLEMENT_STILL_PENDING');

        uint newfPoolOraclePrice = ICentaurPool(pendingSettlement.fPool).getOraclePrice();
        uint newtPoolOraclePrice = getOraclePrice();

        uint newValue = CentaurMath.getValueFromAmountIn(pendingSettlement.amountIn, newfPoolOraclePrice, ICentaurPool(pendingSettlement.fPool).baseTokenDecimals(), pendingSettlement.fPoolBaseTokenTargetAmount, pendingSettlement.fPoolBaseTokenBalance, pendingSettlement.fPoolLiquidityParameter);
        uint newAmount = CentaurMath.getAmountOutFromValue(newValue, newtPoolOraclePrice, baseTokenDecimals, pendingSettlement.tPoolBaseTokenTargetAmount, pendingSettlement.tPoolBaseTokenBalance, pendingSettlement.tPoolLiquidityParameter);

        uint poolFee = ICentaurFactory(factory).poolFee();
        address router = ICentaurFactory(factory).router();

        // Remove settlement and receive escrowed amount
        ICentaurSettlement(settlement).removeSettlement(_sender, pendingSettlement.fPool, pendingSettlement.tPool);

        if (newAmount > pendingSettlement.maxAmountOut) {

            uint fee = (pendingSettlement.maxAmountOut).mul(poolFee).div(100 ether);
            uint amountOut = pendingSettlement.maxAmountOut.sub(fee);

            if (msg.sender == router) {
                _safeTransfer(baseToken, router, amountOut);
            } else {
                _safeTransfer(baseToken, pendingSettlement.receiver, amountOut);
            }
            emit AmountOut(_sender, amountOut, pendingSettlement.receiver);

            baseTokenBalance = baseTokenBalance.add(fee);
            baseTokenTargetAmount = baseTokenTargetAmount.add(fee);

            return (amountOut, pendingSettlement.receiver);
        } else {
            uint fee = (newAmount).mul(poolFee).div(100 ether);
            uint amountOut = newAmount.sub(fee);

            if (msg.sender == router) {
                _safeTransfer(baseToken, router, amountOut);
            } else {
                _safeTransfer(baseToken, pendingSettlement.receiver, amountOut);
            }
            emit AmountOut(_sender, amountOut, pendingSettlement.receiver);

            // Difference added back to baseTokenBalance
            uint difference = (pendingSettlement.maxAmountOut).sub(amountOut);
            baseTokenBalance = baseTokenBalance.add(difference);

            // TX fee goes back into pool for liquidity providers
            baseTokenTargetAmount = baseTokenTargetAmount.add(difference);

            return (amountOut, pendingSettlement.receiver);
        }
    }

    function getOraclePrice() public view returns (uint price) {
        (, int answer,,,) = IOracle(oracle).latestRoundData();

        // Returns price in 18 decimals
        price = uint(answer).mul(10 ** uint(18).sub(oracleDecimals));
    }

    // Swap Exact Tokens For Tokens (getAmountOut)
    function getAmountOutFromValue(uint _value) public view returns (uint amount) {
        amount = CentaurMath.getAmountOutFromValue(_value, getOraclePrice(), baseTokenDecimals,  baseTokenTargetAmount, baseTokenBalance, liquidityParameter);
    
        require(baseTokenBalance > amount, "CentaurSwap: INSUFFICIENT_LIQUIDITY");
    }

    function getValueFromAmountIn(uint _amount) public view returns (uint value) {
        value = CentaurMath.getValueFromAmountIn(_amount, getOraclePrice(), baseTokenDecimals, baseTokenTargetAmount, baseTokenBalance, liquidityParameter);
    }

    // Swap Tokens For Exact Tokens (getAmountIn)
    function getAmountInFromValue(uint _value) public view returns (uint amount) {
        amount = CentaurMath.getAmountInFromValue(_value, getOraclePrice(), baseTokenDecimals,  baseTokenTargetAmount, baseTokenBalance, liquidityParameter);
    }

    function getValueFromAmountOut(uint _amount) public view returns (uint value) {
        require(baseTokenBalance > _amount, "CentaurSwap: INSUFFICIENT_LIQUIDITY");

        value = CentaurMath.getValueFromAmountOut(_amount, getOraclePrice(), baseTokenDecimals, baseTokenTargetAmount, baseTokenBalance, liquidityParameter);
    }

    // Helper functions
    function setFactory(address _factory) external onlyFactory {
        factory = _factory;
    }

    function setTradeEnabled(bool _tradeEnabled) external onlyFactory {
        tradeEnabled = _tradeEnabled;
    }

    function setDepositEnabled(bool _depositEnabled) external onlyFactory {
        depositEnabled = _depositEnabled;
    }

    function setWithdrawEnabled(bool _withdrawEnabled) external onlyFactory {
        withdrawEnabled = _withdrawEnabled;
    }

    function setLiquidityParameter(uint _liquidityParameter) external onlyFactory {
        liquidityParameter = _liquidityParameter;
    }

    function emergencyWithdraw(address _token, uint _amount, address _to) external onlyFactory {
        _safeTransfer(_token, _to, _amount);

        emit EmergencyWithdraw(block.timestamp, _token, _amount, _to);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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


// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;



// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false


// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;



// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */


// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;

import './libraries/SafeMath.sol';

contract CentaurLPToken {
    using SafeMath for uint;

    string public constant name = 'CentaurSwap LP Token';
    string public symbol;
    uint256 public decimals = 18;
    uint  public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 * 
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 * 
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { SafeMath } from "./SafeMath.sol";
import { ABDKMathQuad } from './ABDKMathQuad.sol';



// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;



// SPDX-License-Identifier: BSD-4-Clause
/*
 * ABDK Math Quad Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <[email protected]>
 */
pragma solidity ^0.5.0 || ^0.6.0 || ^0.7.0;

/**
 * Smart contract library of mathematical functions operating with IEEE 754
 * quadruple-precision binary floating-point numbers (quadruple precision
 * numbers).  As long as quadruple precision numbers are 16-bytes long, they are
 * represented by bytes16 type.
 */


{
  "optimizer": {
    "enabled": false,
    "runs": 200
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}