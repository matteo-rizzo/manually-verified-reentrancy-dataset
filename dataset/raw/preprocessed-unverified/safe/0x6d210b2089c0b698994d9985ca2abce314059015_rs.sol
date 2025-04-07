/**
 *Submitted for verification at Etherscan.io on 2019-12-20
*/

pragma solidity ^0.5.0;












contract EpochTokenLocker {
    using SafeMath for uint256;

    
    uint32 public constant BATCH_TIME = 300;

    
    mapping(address => mapping(address => BalanceState)) private balanceStates;

    
    mapping(address => mapping(address => uint32)) public lastCreditBatchId;

    struct BalanceState {
        uint256 balance;
        PendingFlux pendingDeposits; 
        PendingFlux pendingWithdraws; 
    }

    struct PendingFlux {
        uint256 amount;
        uint32 batchId;
    }

    event Deposit(address indexed user, address indexed token, uint256 amount, uint32 batchId);

    event WithdrawRequest(address indexed user, address indexed token, uint256 amount, uint32 batchId);

    event Withdraw(address indexed user, address indexed token, uint256 amount);

    
    function deposit(address token, uint256 amount) public {
        updateDepositsBalance(msg.sender, token);
        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, address(this), amount);
        
        balanceStates[msg.sender][token].pendingDeposits.amount = balanceStates[msg.sender][token].pendingDeposits.amount.add(
            amount
        );
        balanceStates[msg.sender][token].pendingDeposits.batchId = getCurrentBatchId();
        emit Deposit(msg.sender, token, amount, getCurrentBatchId());
    }

    
    function requestWithdraw(address token, uint256 amount) public {
        requestFutureWithdraw(token, amount, getCurrentBatchId());
    }

    
    function requestFutureWithdraw(address token, uint256 amount, uint32 batchId) public {
        
        if (hasValidWithdrawRequest(msg.sender, token)) {
            withdraw(msg.sender, token);
        }
        require(batchId >= getCurrentBatchId(), "Request cannot be made in the past");
        balanceStates[msg.sender][token].pendingWithdraws = PendingFlux({amount: amount, batchId: batchId});
        emit WithdrawRequest(msg.sender, token, amount, batchId);
    }

    
    function withdraw(address user, address token) public {
        updateDepositsBalance(user, token); 
        require(
            balanceStates[user][token].pendingWithdraws.batchId < getCurrentBatchId(),
            "withdraw was not registered previously"
        );
        require(
            lastCreditBatchId[user][token] < getCurrentBatchId(),
            "Withdraw not possible for token that is traded in the current auction"
        );
        uint256 amount = Math.min(balanceStates[user][token].balance, balanceStates[user][token].pendingWithdraws.amount);

        balanceStates[user][token].balance = balanceStates[user][token].balance.sub(amount);
        delete balanceStates[user][token].pendingWithdraws;

        SafeERC20.safeTransfer(IERC20(token), user, amount);
        emit Withdraw(user, token, amount);
    }
    

    
    function getPendingDeposit(address user, address token) public view returns (uint256, uint32) {
        PendingFlux memory pendingDeposit = balanceStates[user][token].pendingDeposits;
        return (pendingDeposit.amount, pendingDeposit.batchId);
    }

    
    function getPendingWithdraw(address user, address token) public view returns (uint256, uint32) {
        PendingFlux memory pendingWithdraw = balanceStates[user][token].pendingWithdraws;
        return (pendingWithdraw.amount, pendingWithdraw.batchId);
    }

    
    function getCurrentBatchId() public view returns (uint32) {
        
        return uint32(now / BATCH_TIME);
    }

    
    function getSecondsRemainingInBatch() public view returns (uint256) {
        
        return BATCH_TIME - (now % BATCH_TIME);
    }

    
    function getBalance(address user, address token) public view returns (uint256) {
        uint256 balance = balanceStates[user][token].balance;
        if (balanceStates[user][token].pendingDeposits.batchId < getCurrentBatchId()) {
            balance = balance.add(balanceStates[user][token].pendingDeposits.amount);
        }
        if (balanceStates[user][token].pendingWithdraws.batchId < getCurrentBatchId()) {
            balance = balance.sub(Math.min(balanceStates[user][token].pendingWithdraws.amount, balance));
        }
        return balance;
    }

    
    function hasValidWithdrawRequest(address user, address token) public view returns (bool) {
        return
            balanceStates[user][token].pendingWithdraws.batchId < getCurrentBatchId() &&
            balanceStates[user][token].pendingWithdraws.batchId > 0;
    }

    
    
    function addBalanceAndBlockWithdrawForThisBatch(address user, address token, uint256 amount) internal {
        if (hasValidWithdrawRequest(user, token)) {
            lastCreditBatchId[user][token] = getCurrentBatchId();
        }
        addBalance(user, token, amount);
    }

    function addBalance(address user, address token, uint256 amount) internal {
        updateDepositsBalance(user, token);
        balanceStates[user][token].balance = balanceStates[user][token].balance.add(amount);
    }

    function subtractBalance(address user, address token, uint256 amount) internal {
        updateDepositsBalance(user, token);
        balanceStates[user][token].balance = balanceStates[user][token].balance.sub(amount);
    }

    function updateDepositsBalance(address user, address token) private {
        if (balanceStates[user][token].pendingDeposits.batchId < getCurrentBatchId()) {
            balanceStates[user][token].balance = balanceStates[user][token].balance.add(
                balanceStates[user][token].pendingDeposits.amount
            );
            delete balanceStates[user][token].pendingDeposits;
        }
    }
}







contract Token {
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    
    function transfer(address to, uint value) public returns (bool);
    function transferFrom(address from, address to, uint value) public returns (bool);
    function approve(address spender, uint value) public returns (bool);
    function balanceOf(address owner) public view returns (uint);
    function allowance(address owner, address spender) public view returns (uint);
    function totalSupply() public view returns (uint);
}

contract Proxied {
    address public masterCopy;
}

contract Proxy is Proxied {
    
    
    constructor(address _masterCopy) public {
        require(_masterCopy != address(0), "The master copy is required");
        masterCopy = _masterCopy;
    }

    
    function() external payable {
        address _masterCopy = masterCopy;
        assembly {
            calldatacopy(0, 0, calldatasize)
            let success := delegatecall(not(0), _masterCopy, 0, calldatasize, 0, 0)
            returndatacopy(0, 0, returndatasize)
            switch success
                case 0 {
                    revert(0, returndatasize)
                }
                default {
                    return(0, returndatasize)
                }
        }
    }
}

contract StandardTokenData {
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    uint totalTokens;
}

contract GnosisStandardToken is Token, StandardTokenData {
    using GnosisMath for *;

    
    
    
    
    
    function transfer(address to, uint value) public returns (bool) {
        if (!balances[msg.sender].safeToSub(value) || !balances[to].safeToAdd(value)) {
            return false;
        }

        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    
    
    
    
    
    function transferFrom(address from, address to, uint value) public returns (bool) {
        if (!balances[from].safeToSub(value) || !allowances[from][msg.sender].safeToSub(
            value
        ) || !balances[to].safeToAdd(value)) {
            return false;
        }
        balances[from] -= value;
        allowances[from][msg.sender] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    
    
    
    
    function approve(address spender, uint value) public returns (bool) {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    
    
    
    
    function allowance(address owner, address spender) public view returns (uint) {
        return allowances[owner][spender];
    }

    
    
    
    function balanceOf(address owner) public view returns (uint) {
        return balances[owner];
    }

    
    
    function totalSupply() public view returns (uint) {
        return totalTokens;
    }
}

contract TokenOWL is Proxied, GnosisStandardToken {
    using GnosisMath for *;

    string public constant name = "OWL Token";
    string public constant symbol = "OWL";
    uint8 public constant decimals = 18;

    struct masterCopyCountdownType {
        address masterCopy;
        uint timeWhenAvailable;
    }

    masterCopyCountdownType masterCopyCountdown;

    address public creator;
    address public minter;

    event Minted(address indexed to, uint256 amount);
    event Burnt(address indexed from, address indexed user, uint256 amount);

    modifier onlyCreator() {
        
        require(msg.sender == creator, "Only the creator can perform the transaction");
        _;
    }
    
    
    function startMasterCopyCountdown(address _masterCopy) public onlyCreator {
        require(address(_masterCopy) != address(0), "The master copy must be a valid address");

        
        masterCopyCountdown.masterCopy = _masterCopy;
        masterCopyCountdown.timeWhenAvailable = now + 30 days;
    }

    
    function updateMasterCopy() public onlyCreator {
        require(address(masterCopyCountdown.masterCopy) != address(0), "The master copy must be a valid address");
        require(
            block.timestamp >= masterCopyCountdown.timeWhenAvailable,
            "It's not possible to update the master copy during the waiting period"
        );

        
        masterCopy = masterCopyCountdown.masterCopy;
    }

    function getMasterCopy() public view returns (address) {
        return masterCopy;
    }

    
    
    function setMinter(address newMinter) public onlyCreator {
        minter = newMinter;
    }

    
    
    function setNewOwner(address newOwner) public onlyCreator {
        creator = newOwner;
    }

    
    
    
    function mintOWL(address to, uint amount) public {
        require(minter != address(0), "The minter must be initialized");
        require(msg.sender == minter, "Only the minter can mint OWL");
        balances[to] = balances[to].add(amount);
        totalTokens = totalTokens.add(amount);
        emit Minted(to, amount);
        emit Transfer(address(0), to, amount);
    }

    
    
    
    function burnOWL(address user, uint amount) public {
        allowances[user][msg.sender] = allowances[user][msg.sender].sub(amount);
        balances[user] = balances[user].sub(amount);
        totalTokens = totalTokens.sub(amount);
        emit Burnt(msg.sender, user, amount);
        emit Transfer(user, address(0), amount);
    }

    function getMasterCopyCountdown() public view returns (address, uint) {
        return (masterCopyCountdown.masterCopy, masterCopyCountdown.timeWhenAvailable);
    }
}









contract BatchExchange is EpochTokenLocker {
    using SafeCast for uint256;
    using SafeMath for uint128;
    using BytesLib for bytes32;
    using BytesLib for bytes;
    using TokenConservation for int256[];
    using TokenConservation for uint16[];
    using IterableAppendOnlySet for IterableAppendOnlySet.Data;

    
    uint256 public constant MAX_TOUCHED_ORDERS = 25;

    
    uint256 public constant FEE_FOR_LISTING_TOKEN_IN_OWL = 10 ether;

    
    uint256 public constant AMOUNT_MINIMUM = 10**4;

    
    uint256 public constant IMPROVEMENT_DENOMINATOR = 100; 

    
    uint128 public constant FEE_DENOMINATOR = 1000;

    
    
    uint256 public MAX_TOKENS;

    
    uint16 public numTokens;

    
    TokenOWL public feeToken;

    
    mapping(address => Order[]) public orders;

    
    mapping(uint16 => uint128) public currentPrices;

    
    SolutionData public latestSolution;

    
    IterableAppendOnlySet.Data private allUsers;
    IdToAddressBiMap.Data private registeredTokens;

    struct Order {
        uint16 buyToken;
        uint16 sellToken;
        uint32 validFrom; 
        uint32 validUntil; 
        uint128 priceNumerator;
        uint128 priceDenominator;
        uint128 usedAmount; 
    }

    struct TradeData {
        address owner;
        uint128 volume;
        uint16 orderId;
    }

    struct SolutionData {
        uint32 batchId;
        TradeData[] trades;
        uint16[] tokenIdsForPrice;
        address solutionSubmitter;
        uint256 feeReward;
        uint256 objectiveValue;
    }

    event OrderPlacement(
        address indexed owner,
        uint16 index,
        uint16 indexed buyToken,
        uint16 indexed sellToken,
        uint32 validFrom,
        uint32 validUntil,
        uint128 priceNumerator,
        uint128 priceDenominator
    );

    
    event OrderCancelation(address indexed owner, uint256 id);

    
    event OrderDeletion(address indexed owner, uint256 id);

    
    event Trade(address indexed owner, uint16 indexed orderId, uint256 executedSellAmount, uint256 executedBuyAmount);

    
    event TradeReversion(address indexed owner, uint16 indexed orderId, uint256 executedSellAmount, uint256 executedBuyAmount);

    
    constructor(uint256 maxTokens, address _feeToken) public {
        
        
        currentPrices[0] = 1 ether;
        MAX_TOKENS = maxTokens;
        feeToken = TokenOWL(_feeToken);
        
        
        feeToken.approve(address(this), uint256(-1));
        addToken(_feeToken); 
    }

    
    function addToken(address token) public {
        require(numTokens < MAX_TOKENS, "Max tokens reached");
        if (numTokens > 0) {
            
            feeToken.burnOWL(msg.sender, FEE_FOR_LISTING_TOKEN_IN_OWL);
        }
        require(IdToAddressBiMap.insert(registeredTokens, numTokens, token), "Token already registered");
        numTokens++;
    }

    
    function placeOrder(uint16 buyToken, uint16 sellToken, uint32 validUntil, uint128 buyAmount, uint128 sellAmount)
        public
        returns (uint256)
    {
        return placeOrderInternal(buyToken, sellToken, getCurrentBatchId(), validUntil, buyAmount, sellAmount);
    }

    
    function placeValidFromOrders(
        uint16[] memory buyTokens,
        uint16[] memory sellTokens,
        uint32[] memory validFroms,
        uint32[] memory validUntils,
        uint128[] memory buyAmounts,
        uint128[] memory sellAmounts
    ) public returns (uint16[] memory orderIds) {
        orderIds = new uint16[](buyTokens.length);
        for (uint256 i = 0; i < buyTokens.length; i++) {
            orderIds[i] = placeOrderInternal(
                buyTokens[i],
                sellTokens[i],
                validFroms[i],
                validUntils[i],
                buyAmounts[i],
                sellAmounts[i]
            );
        }
    }

    
    function cancelOrders(uint16[] memory orderIds) public {
        uint32 batchIdBeingSolved = getCurrentBatchId() - 1;
        for (uint16 i = 0; i < orderIds.length; i++) {
            if (!checkOrderValidity(orders[msg.sender][orderIds[i]], batchIdBeingSolved)) {
                delete orders[msg.sender][orderIds[i]];
                emit OrderDeletion(msg.sender, orderIds[i]);
            } else {
                orders[msg.sender][orderIds[i]].validUntil = batchIdBeingSolved;
                emit OrderCancelation(msg.sender, orderIds[i]);
            }
        }
    }

    
    function replaceOrders(
        uint16[] memory cancellations,
        uint16[] memory buyTokens,
        uint16[] memory sellTokens,
        uint32[] memory validFroms,
        uint32[] memory validUntils,
        uint128[] memory buyAmounts,
        uint128[] memory sellAmounts
    ) public returns (uint16[] memory) {
        cancelOrders(cancellations);
        return placeValidFromOrders(buyTokens, sellTokens, validFroms, validUntils, buyAmounts, sellAmounts);
    }

    
    function submitSolution(
        uint32 batchId,
        uint256 claimedObjectiveValue,
        address[] memory owners,
        uint16[] memory orderIds,
        uint128[] memory buyVolumes,
        uint128[] memory prices,
        uint16[] memory tokenIdsForPrice
    ) public returns (uint256) {
        require(acceptingSolutions(batchId), "Solutions are no longer accepted for this batch");
        require(
            isObjectiveValueSufficientlyImproved(claimedObjectiveValue),
            "Claimed objective doesn't sufficiently improve current solution"
        );
        require(verifyAmountThreshold(prices), "At least one price lower than AMOUNT_MINIMUM");
        require(tokenIdsForPrice[0] != 0, "Fee token has fixed price!");
        require(tokenIdsForPrice.checkPriceOrdering(), "prices are not ordered by tokenId");
        require(owners.length <= MAX_TOUCHED_ORDERS, "Solution exceeds MAX_TOUCHED_ORDERS");
        
        
        
        
        burnPreviousAuctionFees();
        undoCurrentSolution();
        updateCurrentPrices(prices, tokenIdsForPrice);
        delete latestSolution.trades;
        int256[] memory tokenConservation = TokenConservation.init(tokenIdsForPrice);
        uint256 utility = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            Order memory order = orders[owners[i]][orderIds[i]];
            require(checkOrderValidity(order, batchId), "Order is invalid");
            (uint128 executedBuyAmount, uint128 executedSellAmount) = getTradedAmounts(buyVolumes[i], order);
            require(executedBuyAmount >= AMOUNT_MINIMUM, "buy amount less than AMOUNT_MINIMUM");
            require(executedSellAmount >= AMOUNT_MINIMUM, "sell amount less than AMOUNT_MINIMUM");
            tokenConservation.updateTokenConservation(
                order.buyToken,
                order.sellToken,
                tokenIdsForPrice,
                executedBuyAmount,
                executedSellAmount
            );
            require(getRemainingAmount(order) >= executedSellAmount, "executedSellAmount bigger than specified in order");
            
            
            require(
                executedSellAmount.mul(order.priceNumerator) <= executedBuyAmount.mul(order.priceDenominator),
                "limit price not satisfied"
            );
            
            utility = utility.add(evaluateUtility(executedBuyAmount, order));
            updateRemainingOrder(owners[i], orderIds[i], executedSellAmount);
            addBalanceAndBlockWithdrawForThisBatch(owners[i], tokenIdToAddressMap(order.buyToken), executedBuyAmount);
            emit Trade(owners[i], orderIds[i], executedSellAmount, executedBuyAmount);
        }
        
        for (uint256 i = 0; i < owners.length; i++) {
            Order memory order = orders[owners[i]][orderIds[i]];
            (, uint128 executedSellAmount) = getTradedAmounts(buyVolumes[i], order);
            subtractBalance(owners[i], tokenIdToAddressMap(order.sellToken), executedSellAmount);
        }
        uint256 disregardedUtility = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            disregardedUtility = disregardedUtility.add(evaluateDisregardedUtility(orders[owners[i]][orderIds[i]], owners[i]));
        }
        uint256 burntFees = uint256(tokenConservation.feeTokenImbalance()) / 2;
        
        uint256 objectiveValue = utility.add(burntFees).sub(disregardedUtility);
        checkAndOverrideObjectiveValue(objectiveValue);
        grantRewardToSolutionSubmitter(burntFees);
        tokenConservation.checkTokenConservation();
        documentTrades(batchId, owners, orderIds, buyVolumes, tokenIdsForPrice);
        return (objectiveValue);
    }
    

    
    function tokenAddressToIdMap(address addr) public view returns (uint16) {
        return IdToAddressBiMap.getId(registeredTokens, addr);
    }

    
    function tokenIdToAddressMap(uint16 id) public view returns (address) {
        return IdToAddressBiMap.getAddressAt(registeredTokens, id);
    }

    
    function hasToken(address addr) public view returns (bool) {
        return IdToAddressBiMap.hasAddress(registeredTokens, addr);
    }

    
    function getEncodedUserOrdersPaginated(address user, uint16 offset, uint16 pageSize)
        public
        view
        returns (bytes memory elements)
    {
        for (uint16 i = offset; i < Math.min(orders[user].length, offset + pageSize); i++) {
            elements = elements.concat(
                encodeAuctionElement(user, getBalance(user, tokenIdToAddressMap(orders[user][i].sellToken)), orders[user][i])
            );
        }
        return elements;
    }

    
    function getEncodedUserOrders(address user) public view returns (bytes memory elements) {
        return getEncodedUserOrdersPaginated(user, 0, uint16(-1));
    }

    
    function getEncodedOrders() public view returns (bytes memory elements) {
        if (allUsers.size() > 0) {
            address user = allUsers.first();
            bool stop = false;
            while (!stop) {
                elements = elements.concat(getEncodedUserOrders(user));
                if (user == allUsers.last) {
                    stop = true;
                } else {
                    user = allUsers.next(user);
                }
            }
        }
        return elements;
    }

    function acceptingSolutions(uint32 batchId) public view returns (bool) {
        return batchId == getCurrentBatchId() - 1 && getSecondsRemainingInBatch() >= 1 minutes;
    }

    
    function getCurrentObjectiveValue() public view returns (uint256) {
        if (latestSolution.batchId == getCurrentBatchId() - 1) {
            return latestSolution.objectiveValue;
        } else {
            return 0;
        }
    }
    

    function placeOrderInternal(
        uint16 buyToken,
        uint16 sellToken,
        uint32 validFrom,
        uint32 validUntil,
        uint128 buyAmount,
        uint128 sellAmount
    ) private returns (uint16) {
        require(buyToken != sellToken, "Exchange tokens not distinct");
        require(validFrom >= getCurrentBatchId(), "Orders can't be placed in the past");
        orders[msg.sender].push(
            Order({
                buyToken: buyToken,
                sellToken: sellToken,
                validFrom: validFrom,
                validUntil: validUntil,
                priceNumerator: buyAmount,
                priceDenominator: sellAmount,
                usedAmount: 0
            })
        );
        uint16 orderId = (orders[msg.sender].length - 1).toUint16();
        emit OrderPlacement(msg.sender, orderId, buyToken, sellToken, validFrom, validUntil, buyAmount, sellAmount);
        allUsers.insert(msg.sender);
        return orderId;
    }

    
    function grantRewardToSolutionSubmitter(uint256 feeReward) private {
        latestSolution.feeReward = feeReward;
        addBalanceAndBlockWithdrawForThisBatch(msg.sender, tokenIdToAddressMap(0), feeReward);
    }

    
    function burnPreviousAuctionFees() private {
        if (!currentBatchHasSolution()) {
            feeToken.burnOWL(address(this), latestSolution.feeReward);
        }
    }

    
    function updateCurrentPrices(uint128[] memory prices, uint16[] memory tokenIdsForPrice) private {
        for (uint256 i = 0; i < latestSolution.tokenIdsForPrice.length; i++) {
            currentPrices[latestSolution.tokenIdsForPrice[i]] = 0;
        }
        for (uint256 i = 0; i < tokenIdsForPrice.length; i++) {
            currentPrices[tokenIdsForPrice[i]] = prices[i];
        }
    }

    
    function updateRemainingOrder(address owner, uint16 orderId, uint128 executedAmount) private {
        orders[owner][orderId].usedAmount = orders[owner][orderId].usedAmount.add(executedAmount).toUint128();
    }

    
    function revertRemainingOrder(address owner, uint16 orderId, uint128 executedAmount) private {
        orders[owner][orderId].usedAmount = orders[owner][orderId].usedAmount.sub(executedAmount).toUint128();
    }

    
    function documentTrades(
        uint32 batchId,
        address[] memory owners,
        uint16[] memory orderIds,
        uint128[] memory volumes,
        uint16[] memory tokenIdsForPrice
    ) private {
        latestSolution.batchId = batchId;
        for (uint256 i = 0; i < owners.length; i++) {
            latestSolution.trades.push(TradeData({owner: owners[i], orderId: orderIds[i], volume: volumes[i]}));
        }
        latestSolution.tokenIdsForPrice = tokenIdsForPrice;
        latestSolution.solutionSubmitter = msg.sender;
    }

    
    function undoCurrentSolution() private {
        if (currentBatchHasSolution()) {
            for (uint256 i = 0; i < latestSolution.trades.length; i++) {
                address owner = latestSolution.trades[i].owner;
                uint16 orderId = latestSolution.trades[i].orderId;
                Order memory order = orders[owner][orderId];
                (, uint128 sellAmount) = getTradedAmounts(latestSolution.trades[i].volume, order);
                addBalance(owner, tokenIdToAddressMap(order.sellToken), sellAmount);
            }
            for (uint256 i = 0; i < latestSolution.trades.length; i++) {
                address owner = latestSolution.trades[i].owner;
                uint16 orderId = latestSolution.trades[i].orderId;
                Order memory order = orders[owner][orderId];
                (uint128 buyAmount, uint128 sellAmount) = getTradedAmounts(latestSolution.trades[i].volume, order);
                revertRemainingOrder(owner, orderId, sellAmount);
                subtractBalance(owner, tokenIdToAddressMap(order.buyToken), buyAmount);
                emit TradeReversion(owner, orderId, sellAmount, buyAmount);
            }
            
            subtractBalance(latestSolution.solutionSubmitter, tokenIdToAddressMap(0), latestSolution.feeReward);
        }
    }

    
    function checkAndOverrideObjectiveValue(uint256 newObjectiveValue) private {
        require(
            isObjectiveValueSufficientlyImproved(newObjectiveValue),
            "New objective doesn't sufficiently improve current solution"
        );
        latestSolution.objectiveValue = newObjectiveValue;
    }

    
    
    function evaluateUtility(uint128 execBuy, Order memory order) private view returns (uint256) {
        
        uint256 execSellTimesBuy = getExecutedSellAmount(execBuy, currentPrices[order.buyToken], currentPrices[order.sellToken])
            .mul(order.priceNumerator);

        uint256 roundedUtility = execBuy.sub(execSellTimesBuy.div(order.priceDenominator)).mul(currentPrices[order.buyToken]);
        uint256 utilityError = execSellTimesBuy.mod(order.priceDenominator).mul(currentPrices[order.buyToken]).div(
            order.priceDenominator
        );
        return roundedUtility.sub(utilityError).toUint128();
    }

    
    function evaluateDisregardedUtility(Order memory order, address user) private view returns (uint256) {
        uint256 leftoverSellAmount = Math.min(getRemainingAmount(order), getBalance(user, tokenIdToAddressMap(order.sellToken)));
        uint256 limitTermLeft = currentPrices[order.sellToken].mul(order.priceDenominator);
        uint256 limitTermRight = order.priceNumerator.mul(currentPrices[order.buyToken]).mul(FEE_DENOMINATOR).div(
            FEE_DENOMINATOR - 1
        );
        uint256 limitTerm = 0;
        if (limitTermLeft > limitTermRight) {
            limitTerm = limitTermLeft.sub(limitTermRight);
        }
        return leftoverSellAmount.mul(limitTerm).div(order.priceDenominator).toUint128();
    }

    
    function getExecutedSellAmount(uint128 executedBuyAmount, uint128 buyTokenPrice, uint128 sellTokenPrice)
        private
        pure
        returns (uint128)
    {
        
        return
            uint256(executedBuyAmount)
                .mul(buyTokenPrice)
                .div(FEE_DENOMINATOR - 1)
                .mul(FEE_DENOMINATOR)
                .div(sellTokenPrice)
                .toUint128();
        
    }

    
    function currentBatchHasSolution() private view returns (bool) {
        return latestSolution.batchId == getCurrentBatchId() - 1;
    }

    
    
    function getTradedAmounts(uint128 executedBuyAmount, Order memory order) private view returns (uint128, uint128) {
        uint128 executedSellAmount = getExecutedSellAmount(
            executedBuyAmount,
            currentPrices[order.buyToken],
            currentPrices[order.sellToken]
        );
        return (executedBuyAmount, executedSellAmount);
    }

    
    function isObjectiveValueSufficientlyImproved(uint256 objectiveValue) private view returns (bool) {
        return (objectiveValue.mul(IMPROVEMENT_DENOMINATOR) > getCurrentObjectiveValue().mul(IMPROVEMENT_DENOMINATOR + 1));
    }

    
    
    function checkOrderValidity(Order memory order, uint32 batchId) private pure returns (bool) {
        return order.validFrom <= batchId && order.validUntil >= batchId;
    }

    
    function getRemainingAmount(Order memory order) private pure returns (uint128) {
        return order.priceDenominator - order.usedAmount;
    }

    
    function encodeAuctionElement(address user, uint256 sellTokenBalance, Order memory order)
        private
        pure
        returns (bytes memory element)
    {
        element = abi.encodePacked(user);
        element = element.concat(abi.encodePacked(sellTokenBalance));
        element = element.concat(abi.encodePacked(order.buyToken));
        element = element.concat(abi.encodePacked(order.sellToken));
        element = element.concat(abi.encodePacked(order.validFrom));
        element = element.concat(abi.encodePacked(order.validUntil));
        element = element.concat(abi.encodePacked(order.priceNumerator));
        element = element.concat(abi.encodePacked(order.priceDenominator));
        element = element.concat(abi.encodePacked(getRemainingAmount(order)));
        return element;
    }

    
    function verifyAmountThreshold(uint128[] memory amounts) private pure returns (bool) {
        for (uint256 i = 0; i < amounts.length; i++) {
            if (amounts[i] < AMOUNT_MINIMUM) {
                return false;
            }
        }
        return true;
    }
}