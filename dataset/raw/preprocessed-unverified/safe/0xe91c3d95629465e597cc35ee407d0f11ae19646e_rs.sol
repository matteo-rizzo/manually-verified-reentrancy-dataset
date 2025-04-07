/**
 *Submitted for verification at Etherscan.io on 2020-03-07
*/

pragma solidity ^0.5.0;














contract EpochTokenLocker {
    using SafeMath for uint256;

    /** @dev Number of seconds a batch is lasting*/
    uint32 public constant BATCH_TIME = 300;

    // User => Token => BalanceState
    mapping(address => mapping(address => BalanceState)) private balanceStates;

    // user => token => lastCreditBatchId
    mapping(address => mapping(address => uint32)) public lastCreditBatchId;

    struct BalanceState {
        uint256 balance;
        PendingFlux pendingDeposits; // deposits will be credited in any future epoch, i.e. currentStateIndex > batchId
        PendingFlux pendingWithdraws; // withdraws are allowed in any future epoch, i.e. currentStateIndex > batchId
    }

    struct PendingFlux {
        uint256 amount;
        uint32 batchId;
    }

    event Deposit(address indexed user, address indexed token, uint256 amount, uint32 batchId);

    event WithdrawRequest(address indexed user, address indexed token, uint256 amount, uint32 batchId);

    event Withdraw(address indexed user, address indexed token, uint256 amount);

    /** @dev credits user with deposit amount on next epoch (given by getCurrentBatchId)
      * @param token address of token to be deposited
      * @param amount number of token(s) to be credited to user's account
      *
      * Emits an {Deposit} event with relevent deposit information.
      *
      * Requirements:
      * - token transfer to contract is successfull
      */
    function deposit(address token, uint256 amount) public {
        updateDepositsBalance(msg.sender, token);
        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, address(this), amount);
        // solhint-disable-next-line max-line-length
        balanceStates[msg.sender][token].pendingDeposits.amount = balanceStates[msg.sender][token].pendingDeposits.amount.add(
            amount
        );
        balanceStates[msg.sender][token].pendingDeposits.batchId = getCurrentBatchId();
        emit Deposit(msg.sender, token, amount, getCurrentBatchId());
    }

    /** @dev Signals and initiates user's intent to withdraw.
      * @param token address of token to be withdrawn
      * @param amount number of token(s) to be withdrawn
      *
      * Emits an {WithdrawRequest} event with relevent request information.
      */
    function requestWithdraw(address token, uint256 amount) public {
        requestFutureWithdraw(token, amount, getCurrentBatchId());
    }

    /** @dev Signals and initiates user's intent to withdraw.
      * @param token address of token to be withdrawn
      * @param amount number of token(s) to be withdrawn
      * @param batchId state index at which request is to be made.
      *
      * Emits an {WithdrawRequest} event with relevent request information.
      */
    function requestFutureWithdraw(address token, uint256 amount, uint32 batchId) public {
        // First process pendingWithdraw (if any), as otherwise balances might increase for currentBatchId - 1
        if (hasValidWithdrawRequest(msg.sender, token)) {
            withdraw(msg.sender, token);
        }
        require(batchId >= getCurrentBatchId(), "Request cannot be made in the past");
        balanceStates[msg.sender][token].pendingWithdraws = PendingFlux({amount: amount, batchId: batchId});
        emit WithdrawRequest(msg.sender, token, amount, batchId);
    }

    /** @dev Claims pending withdraw - can be called on behalf of others
      * @param token address of token to be withdrawn
      * @param user address of user who withdraw is being claimed.
      *
      * Emits an {Withdraw} event stating that `user` withdrew `amount` of `token`
      *
      * Requirements:
      * - withdraw was requested in previous epoch
      * - token was received from exchange in current auction batch
      */
    function withdraw(address user, address token) public {
        updateDepositsBalance(user, token); // withdrawn amount may have been deposited in previous epoch
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

    /**
     * Public view functions
     */
    /** @dev getter function used to display pending deposit
      * @param user address of user
      * @param token address of ERC20 token
      * return amount and batchId of deposit's transfer if any (else 0)
      */
    function getPendingDeposit(address user, address token) public view returns (uint256, uint32) {
        PendingFlux memory pendingDeposit = balanceStates[user][token].pendingDeposits;
        return (pendingDeposit.amount, pendingDeposit.batchId);
    }

    /** @dev getter function used to display pending withdraw
      * @param user address of user
      * @param token address of ERC20 token
      * return amount and batchId when withdraw was requested if any (else 0)
      */
    function getPendingWithdraw(address user, address token) public view returns (uint256, uint32) {
        PendingFlux memory pendingWithdraw = balanceStates[user][token].pendingWithdraws;
        return (pendingWithdraw.amount, pendingWithdraw.batchId);
    }

    /** @dev getter function to determine current auction id.
      * return current batchId
      */
    function getCurrentBatchId() public view returns (uint32) {
        // solhint-disable-next-line not-rely-on-time
        return uint32(now / BATCH_TIME);
    }

    /** @dev used to determine how much time is left in a batch
      * return seconds remaining in current batch
      */
    function getSecondsRemainingInBatch() public view returns (uint256) {
        // solhint-disable-next-line not-rely-on-time
        return BATCH_TIME - (now % BATCH_TIME);
    }

    /** @dev fetches and returns user's balance
      * @param user address of user
      * @param token address of ERC20 token
      * return Current `token` balance of `user`'s account
      */
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

    /** @dev Used to determine if user has a valid pending withdraw request of specific token
      * @param user address of user
      * @param token address of ERC20 token
      * return true if `user` has valid withdraw request for `token`, otherwise false
      */
    function hasValidWithdrawRequest(address user, address token) public view returns (bool) {
        return
            balanceStates[user][token].pendingWithdraws.batchId < getCurrentBatchId() &&
            balanceStates[user][token].pendingWithdraws.batchId > 0;
    }

    /**
     * internal functions
     */
    /**
     * The following function should be used to update any balances within an epoch, which
     * will not be immediately final. E.g. the BatchExchange credits new balances to
     * the buyers in an auction, but as there are might be better solutions, the updates are
     * not final. In order to prevent withdraws from non-final updates, we disallow withdraws
     * by setting lastCreditBatchId to the current batchId and allow only withdraws in batches
     * with a higher batchId.
     */
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

    /**
     * The following function should be used to subtract amounts from the current balances state.
     * For the substraction the current withdrawRequests are considered and they are effectively reducing
     * the available balance.
     */
    function subtractBalance(address user, address token, uint256 amount) internal {
        require(amount <= getBalance(user, token), "Amount exceeds user's balance.");
        subtractBalanceUnchecked(user, token, amount);
    }

    /**
     * The following function should be used to substract amounts from the current balance
     * state, if the pending withdrawRequests are not considered and should not effectively reduce
     * the available balance.
     * For example, the reversion of trades from a previous batch-solution do not
     * need to consider withdrawRequests. This is the case as withdraws are blocked for one
     * batch for accounts having credited funds in a previous submission.
     * PendingWithdraws must also be ignored since otherwise for the reversion of trades,
     * a solution reversion could be blocked: A bigger withdrawRequest could set the return value of
     * getBalance(user, token) to zero, although the user was just credited tokens in
     * the last submission. In this situation, during the unwinding of the previous orders,
     * the check `amount <= getBalance(user, token)` would fail and the reversion would be blocked.
     */
    function subtractBalanceUnchecked(address user, address token, uint256 amount) internal {
        updateDepositsBalance(user, token);
        balanceStates[user][token].balance = balanceStates[user][token].balance.sub(amount);
    }

    function updateDepositsBalance(address user, address token) private {
        uint256 batchId = balanceStates[user][token].pendingDeposits.batchId;
        if (batchId > 0 && batchId < getCurrentBatchId()) {
            // batchId > 0 is checked in order save an SSTORE in case there is no pending deposit
            balanceStates[user][token].balance = balanceStates[user][token].balance.add(
                balanceStates[user][token].pendingDeposits.amount
            );
            delete balanceStates[user][token].pendingDeposits;
        }
    }
}







contract Token {
    /*
     *  Events
     */
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    /*
     *  Public functions
     */
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
    /// @dev Constructor function sets address of master copy contract.
    /// @param _masterCopy Master copy address.
    constructor(address _masterCopy) public {
        require(_masterCopy != address(0), "The master copy is required");
        masterCopy = _masterCopy;
    }

    /// @dev Fallback function forwards all transactions and returns all received return data.
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
    /*
     *  Storage
     */
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    uint totalTokens;
}

contract GnosisStandardToken is Token, StandardTokenData {
    using GnosisMath for *;

    /*
     *  Public functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success
    /// @param to Address of token receiver
    /// @param value Number of tokens to transfer
    /// @return Was transfer successful?
    function transfer(address to, uint value) public returns (bool) {
        if (!balances[msg.sender].safeToSub(value) || !balances[to].safeToAdd(value)) {
            return false;
        }

        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success
    /// @param from Address from where tokens are withdrawn
    /// @param to Address to where tokens are sent
    /// @param value Number of tokens to transfer
    /// @return Was transfer successful?
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

    /// @dev Sets approved amount of tokens for spender. Returns success
    /// @param spender Address of allowed account
    /// @param value Number of approved tokens
    /// @return Was approval successful?
    function approve(address spender, uint value) public returns (bool) {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /// @dev Returns number of allowed tokens for given address
    /// @param owner Address of token owner
    /// @param spender Address of token spender
    /// @return Remaining allowance for spender
    function allowance(address owner, address spender) public view returns (uint) {
        return allowances[owner][spender];
    }

    /// @dev Returns number of tokens owned by given address
    /// @param owner Address of token owner
    /// @return Balance of owner
    function balanceOf(address owner) public view returns (uint) {
        return balances[owner];
    }

    /// @dev Returns total supply of tokens
    /// @return Total supply
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
        // R1
        require(msg.sender == creator, "Only the creator can perform the transaction");
        _;
    }
    /// @dev trickers the update process via the proxyMaster for a new address _masterCopy
    /// updating is only possible after 30 days
    function startMasterCopyCountdown(address _masterCopy) public onlyCreator {
        require(address(_masterCopy) != address(0), "The master copy must be a valid address");

        // Update masterCopyCountdown
        masterCopyCountdown.masterCopy = _masterCopy;
        masterCopyCountdown.timeWhenAvailable = now + 30 days;
    }

    /// @dev executes the update process via the proxyMaster for a new address _masterCopy
    function updateMasterCopy() public onlyCreator {
        require(address(masterCopyCountdown.masterCopy) != address(0), "The master copy must be a valid address");
        require(
            block.timestamp >= masterCopyCountdown.timeWhenAvailable,
            "It's not possible to update the master copy during the waiting period"
        );

        // Update masterCopy
        masterCopy = masterCopyCountdown.masterCopy;
    }

    function getMasterCopy() public view returns (address) {
        return masterCopy;
    }

    /// @dev Set minter. Only the creator of this contract can call this.
    /// @param newMinter The new address authorized to mint this token
    function setMinter(address newMinter) public onlyCreator {
        minter = newMinter;
    }

    /// @dev change owner/creator of the contract. Only the creator/owner of this contract can call this.
    /// @param newOwner The new address, which should become the owner
    function setNewOwner(address newOwner) public onlyCreator {
        creator = newOwner;
    }

    /// @dev Mints OWL.
    /// @param to Address to which the minted token will be given
    /// @param amount Amount of OWL to be minted
    function mintOWL(address to, uint amount) public {
        require(minter != address(0), "The minter must be initialized");
        require(msg.sender == minter, "Only the minter can mint OWL");
        balances[to] = balances[to].add(amount);
        totalTokens = totalTokens.add(amount);
        emit Minted(to, amount);
        emit Transfer(address(0), to, amount);
    }

    /// @dev Burns OWL.
    /// @param user Address of OWL owner
    /// @param amount Amount of OWL to be burnt
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

    /** @dev Maximum number of touched orders in auction (used in submitSolution) */
    uint256 public constant MAX_TOUCHED_ORDERS = 30;

    /** @dev Fee charged for adding a token */
    uint256 public constant FEE_FOR_LISTING_TOKEN_IN_OWL = 10 ether;

    /** @dev minimum allowed value (in WEI) of any prices or executed trade amounts */
    uint128 public constant AMOUNT_MINIMUM = 10**4;

    /** @dev Numerator or denominator used in orders, which do not track its usedAmount*/
    uint128 public constant UNLIMITED_ORDER_AMOUNT = uint128(-1);

    /** Corresponds to percentage that competing solution must improve on current
      * (p = IMPROVEMENT_DENOMINATOR + 1 / IMPROVEMENT_DENOMINATOR)
      */
    uint256 public constant IMPROVEMENT_DENOMINATOR = 100; // 1%

    /** @dev A fixed integer used to evaluate fees as a fraction of trade execution 1/FEE_DENOMINATOR */
    uint128 public constant FEE_DENOMINATOR = 1000;

    /** @dev The number of bytes a single auction element is serialized into */
    uint128 public constant ENCODED_AUCTION_ELEMENT_WIDTH = 112;

    /** @dev maximum number of tokens that can be listed for exchange */
    // solhint-disable-next-line var-name-mixedcase
    uint256 public MAX_TOKENS;

    /** @dev Current number of tokens listed/available for exchange */
    uint16 public numTokens;

    /** @dev The feeToken of the exchange will be the OWL Token */
    TokenOWL public feeToken;

    /** @dev mapping of type userAddress -> List[Order] where all the user's orders are stored */
    mapping(address => Order[]) public orders;

    /** @dev mapping of type tokenId -> curentPrice of tokenId */
    mapping(uint16 => uint128) public currentPrices;

    /** @dev Sufficient information for current winning auction solution */
    SolutionData public latestSolution;

    // Iterable set of all users, required to collect auction information
    IterableAppendOnlySet.Data private allUsers;
    IdToAddressBiMap.Data private registeredTokens;

    struct Order {
        uint16 buyToken;
        uint16 sellToken;
        uint32 validFrom; // order is valid from auction collection period: validFrom inclusive
        uint32 validUntil; // order is valid till auction collection period: validUntil inclusive
        uint128 priceNumerator;
        uint128 priceDenominator;
        uint128 usedAmount; // remainingAmount = priceDenominator - usedAmount
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

    event TokenListing(address token, uint16 id);

    /** @dev Event emitted when an order is cancelled but still valid in the batch that is
     * currently being solved. It remains in storage but will not be tradable in any future
     * batch to be solved.
     */
    event OrderCancellation(address indexed owner, uint16 id);

    /** @dev Event emitted when an order is removed from storage.
     */
    event OrderDeletion(address indexed owner, uint16 id);

    /** @dev Event emitted when a new trade is settled
     */
    event Trade(
        address indexed owner,
        uint16 indexed orderId,
        uint16 indexed sellToken,
        // Solidity only supports three indexed arguments
        uint16 buyToken,
        uint128 executedSellAmount,
        uint128 executedBuyAmount
    );

    /** @dev Event emitted when an already exectued trade gets reverted
     */
    event TradeReversion(
        address indexed owner,
        uint16 indexed orderId,
        uint16 indexed sellToken,
        // Solidity only supports three indexed arguments
        uint16 buyToken,
        uint128 executedSellAmount,
        uint128 executedBuyAmount
    );

    /** @dev Event emitted for each solution that is submitted
     */
    event SolutionSubmission(
        address indexed submitter,
        uint256 utility,
        uint256 disregardedUtility,
        uint256 burntFees,
        uint256 lastAuctionBurntFees,
        uint128[] prices,
        uint16[] tokenIdsForPrice
    );

    /** @dev Constructor determines exchange parameters
      * @param maxTokens The maximum number of tokens that can be listed.
      * @param _feeToken Address of ERC20 fee token.
      */
    constructor(uint256 maxTokens, address _feeToken) public {
        // All solutions for the batches must have normalized prices. The following line sets the
        // price of OWL to 10**18 for all solutions and hence enforces a normalization.
        currentPrices[0] = 1 ether;
        MAX_TOKENS = maxTokens;
        feeToken = TokenOWL(_feeToken);
        // The burn functionallity of OWL requires an approval.
        // In the following line the approval is set for all future burn calls.
        feeToken.approve(address(this), uint256(-1));
        addToken(_feeToken); // feeToken will always have the token index 0
    }

    /** @dev Used to list a new token on the contract: Hence, making it available for exchange in an auction.
      * @param token ERC20 token to be listed.
      *
      * Requirements:
      * - `maxTokens` has not already been reached
      * - `token` has not already been added
      */
    function addToken(address token) public {
        require(numTokens < MAX_TOKENS, "Max tokens reached");
        if (numTokens > 0) {
            // Only charge fees for tokens other than the fee token itself
            feeToken.burnOWL(msg.sender, FEE_FOR_LISTING_TOKEN_IN_OWL);
        }
        require(IdToAddressBiMap.insert(registeredTokens, numTokens, token), "Token already registered");
        emit TokenListing(token, numTokens);
        numTokens++;
    }

    /** @dev A user facing function used to place limit sell orders in auction with expiry defined by batchId
      * @param buyToken id of token to be bought
      * @param sellToken id of token to be sold
      * @param validUntil batchId representing order's expiry
      * @param buyAmount relative minimum amount of requested buy amount
      * @param sellAmount maximum amount of sell token to be exchanged
      * @return orderId defined as the index in user's order array
      *
      * Emits an {OrderPlacement} event with all relevant order details.
      */
    function placeOrder(uint16 buyToken, uint16 sellToken, uint32 validUntil, uint128 buyAmount, uint128 sellAmount)
        public
        returns (uint256)
    {
        return placeOrderInternal(buyToken, sellToken, getCurrentBatchId(), validUntil, buyAmount, sellAmount);
    }

    /** @dev A user facing function used to place limit sell orders in auction with expiry defined by batchId
      * Note that parameters are passed as arrays and the indices correspond to each order.
      * @param buyTokens ids of tokens to be bought
      * @param sellTokens ids of tokens to be sold
      * @param validFroms batchIds representing order's validity start time
      * @param validUntils batchIds representing order's expiry
      * @param buyAmounts relative minimum amount of requested buy amounts
      * @param sellAmounts maximum amounts of sell token to be exchanged
      * @return `orderIds` an array of indices in which `msg.sender`'s orders are included
      *
      * Emits an {OrderPlacement} event with all relevant order details.
      */
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

    /** @dev a user facing function used to cancel orders. If the order is valid for the batch that is currently
      * being solved, it sets order expiry to that batchId. Otherwise it removes it from storage. Can be called
      * multiple times (e.g. to eventually free storage once order is expired).
      *
      * @param orderIds referencing the indices of user's orders to be cancelled
      *
      * Emits an {OrderCancellation} or {OrderDeletion} with sender's address and orderId
      */
    function cancelOrders(uint16[] memory orderIds) public {
        uint32 batchIdBeingSolved = getCurrentBatchId() - 1;
        for (uint16 i = 0; i < orderIds.length; i++) {
            if (!checkOrderValidity(orders[msg.sender][orderIds[i]], batchIdBeingSolved)) {
                delete orders[msg.sender][orderIds[i]];
                emit OrderDeletion(msg.sender, orderIds[i]);
            } else {
                orders[msg.sender][orderIds[i]].validUntil = batchIdBeingSolved;
                emit OrderCancellation(msg.sender, orderIds[i]);
            }
        }
    }

    /** @dev A user facing wrapper to cancel and place new orders in the same transaction.
      * @param cancellations indices of orders to be cancelled
      * @param buyTokens ids of tokens to be bought in new orders
      * @param sellTokens ids of tokens to be sold in new orders
      * @param validFroms batchIds representing order's validity start time in new orders
      * @param validUntils batchIds represnnting order's expiry in new orders
      * @param buyAmounts relative minimum amount of requested buy amounts in new orders
      * @param sellAmounts maximum amounts of sell token to be exchanged in new orders
      * @return an array of indices in which `msg.sender`'s new orders are included
      *
      * Emits {OrderCancellation} events for all cancelled orders and {OrderPlacement} events with relevant new order details.
      */
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

    /** @dev a solver facing function called for auction settlement
      * @param batchId index of auction solution is referring to
      * @param owners array of addresses corresponding to touched orders
      * @param orderIds array of order indices used in parallel with owners to identify touched order
      * @param buyVolumes executed buy amounts for each order identified by index of owner-orderId arrays
      * @param prices list of prices for touched tokens indexed by next parameter
      * @param tokenIdsForPrice price[i] is the price for the token with tokenID tokenIdsForPrice[i]
      * @return the computed objective value of the solution
      *
      * Requirements:
      * - Solutions for this `batchId` are currently being accepted.
      * - Claimed objetive value is a great enough improvement on the current winning solution
      * - Fee Token price is non-zero
      * - `tokenIdsForPrice` is sorted.
      * - Number of touched orders does not exceed `MAX_TOUCHED_ORDERS`.
      * - Each touched order is valid at current `batchId`.
      * - Each touched order's `executedSellAmount` does not exceed its remaining amount.
      * - Limit Price of each touched order is respected.
      * - Solution's objective evaluation must be positive.
      *
      * Sub Requirements: Those nested within other functions
      * - checkAndOverrideObjectiveValue; Objetive value is a great enough improvement on the current winning solution
      * - checkTokenConservation; for all, non-fee, tokens total amount sold == total amount bought
      */
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
        // Further assumptions are: owners.length == orderIds.length && owners.length == buyVolumes.length
        // && prices.length == tokenIdsForPrice.length
        // These assumptions are not checked explicitly, as violations of these constraints can not be used
        // to create a beneficial situation
        uint256 lastAuctionBurntFees = burnPreviousAuctionFees();
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
            // Ensure executed price is not lower than the order price:
            //       executedSellAmount / executedBuyAmount <= order.priceDenominator / order.priceNumerator
            require(
                executedSellAmount.mul(order.priceNumerator) <= executedBuyAmount.mul(order.priceDenominator),
                "limit price not satisfied"
            );
            // accumulate utility before updateRemainingOrder, but after limitPrice verified!
            utility = utility.add(evaluateUtility(executedBuyAmount, order));
            updateRemainingOrder(owners[i], orderIds[i], executedSellAmount);
            addBalanceAndBlockWithdrawForThisBatch(owners[i], tokenIdToAddressMap(order.buyToken), executedBuyAmount);
            emit Trade(owners[i], orderIds[i], order.sellToken, order.buyToken, executedSellAmount, executedBuyAmount);
        }
        // Perform all subtractions after additions to avoid negative values
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
        // burntFees ensures direct trades (when available) yield better solutions than longer rings
        uint256 objectiveValue = utility.add(burntFees).sub(disregardedUtility);
        checkAndOverrideObjectiveValue(objectiveValue);
        grantRewardToSolutionSubmitter(burntFees);
        tokenConservation.checkTokenConservation();
        documentTrades(batchId, owners, orderIds, buyVolumes, tokenIdsForPrice);

        emit SolutionSubmission(
            msg.sender,
            utility,
            disregardedUtility,
            burntFees,
            lastAuctionBurntFees,
            prices,
            tokenIdsForPrice
        );
        return (objectiveValue);
    }

    /**
     * Public View Methods
     */
    /** @dev View returning ID of listed tokens
      * @param addr address of listed token.
      * @return tokenId as stored within the contract.
      */
    function tokenAddressToIdMap(address addr) public view returns (uint16) {
        return IdToAddressBiMap.getId(registeredTokens, addr);
    }

    /** @dev View returning address of listed token by ID
      * @param id tokenId as stored, via BiMap, within the contract.
      * @return address of (listed) token
      */
    function tokenIdToAddressMap(uint16 id) public view returns (address) {
        return IdToAddressBiMap.getAddressAt(registeredTokens, id);
    }

    /** @dev View returning a bool attesting whether token was already added
      * @param addr address of the token to be checked
      * @return bool attesting whether token was already added
      */
    function hasToken(address addr) public view returns (bool) {
        return IdToAddressBiMap.hasAddress(registeredTokens, addr);
    }

    /** @dev View returning all byte-encoded sell orders for specified user
      * @param user address of user whose orders are being queried
      * @param offset uint determining the starting orderIndex
      * @param pageSize uint determining the count of elements to be viewed
      * @return encoded bytes representing all orders
      */
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

    /** @dev View returning all byte-encoded users in paginated form
      * @param previousPageUser address of last user received in last pages (address(0) for first page)
      * @param pageSize uint determining the count of users to be returned per page
      * @return encoded packed bytes of user addresses
      */
    function getUsersPaginated(address previousPageUser, uint16 pageSize) public view returns (bytes memory users) {
        if (allUsers.size() == 0) {
            return users;
        }
        uint16 count = 0;
        address current = previousPageUser;
        if (current == address(0)) {
            current = allUsers.first();
            users = users.concat(abi.encodePacked(current));
            count++;
        }
        while (count < pageSize && current != allUsers.last) {
            current = allUsers.next(current);
            users = users.concat(abi.encodePacked(current));
            count++;
        }
        return users;
    }

    /** @dev View returning all byte-encoded sell orders for specified user
      * @param user address of user whose orders are being queried
      * @return encoded bytes representing all orders
      */
    function getEncodedUserOrders(address user) public view returns (bytes memory elements) {
        return getEncodedUserOrdersPaginated(user, 0, uint16(-1));
    }

    /** @dev View returning byte-encoded sell orders in paginated form
      * @param previousPageUser address of last user received in the previous page (address(0) for first page)
      * @param previousPageUserOffset the number of orders received for the last user on the previous page (0 for first page).
      * @param pageSize uint determining the count of orders to be returned per page
      * @return encoded bytes representing a page of orders ordered by (user, index)
      */
    function getEncodedUsersPaginated(address previousPageUser, uint16 previousPageUserOffset, uint16 pageSize)
        public
        view
        returns (bytes memory elements)
    {
        if (allUsers.size() == 0) {
            return elements;
        }
        uint16 currentOffset = previousPageUserOffset;
        address currentUser = previousPageUser;
        if (currentUser == address(0x0)) {
            currentUser = allUsers.first();
        }
        while (elements.length / ENCODED_AUCTION_ELEMENT_WIDTH < pageSize) {
            elements = elements.concat(
                getEncodedUserOrdersPaginated(
                    currentUser,
                    currentOffset,
                    pageSize - uint16(elements.length / ENCODED_AUCTION_ELEMENT_WIDTH)
                )
            );
            if (currentUser == allUsers.last) {
                return elements;
            }
            currentOffset = 0;
            currentUser = allUsers.next(currentUser);
        }
    }

    /** @dev View returning all byte-encoded sell orders
      * @return encoded bytes representing all orders ordered by (user, index)
      */
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

    /** @dev gets the objective value of currently winning solution.
      * @return objective function evaluation of the currently winning solution, or zero if no solution proposed.
      */
    function getCurrentObjectiveValue() public view returns (uint256) {
        if (latestSolution.batchId == getCurrentBatchId() - 1) {
            return latestSolution.objectiveValue;
        } else {
            return 0;
        }
    }

    /**
     * Private Functions
     */
    function placeOrderInternal(
        uint16 buyToken,
        uint16 sellToken,
        uint32 validFrom,
        uint32 validUntil,
        uint128 buyAmount,
        uint128 sellAmount
    ) private returns (uint16) {
        require(IdToAddressBiMap.hasId(registeredTokens, buyToken), "Buy token must be listed");
        require(IdToAddressBiMap.hasId(registeredTokens, sellToken), "Sell token must be listed");
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

    /** @dev called at the end of submitSolution with a value of tokenConservation / 2
      * @param feeReward amount to be rewarded to the solver
      */
    function grantRewardToSolutionSubmitter(uint256 feeReward) private {
        latestSolution.feeReward = feeReward;
        addBalanceAndBlockWithdrawForThisBatch(msg.sender, tokenIdToAddressMap(0), feeReward);
    }

    /** @dev called during solution submission to burn fees from previous auction
      * @return amount of OWL burnt
      */
    function burnPreviousAuctionFees() private returns (uint256) {
        if (!currentBatchHasSolution()) {
            feeToken.burnOWL(address(this), latestSolution.feeReward);
            return latestSolution.feeReward;
        }
        return 0;
    }

    /** @dev Called from within submitSolution to update the token prices.
      * @param prices list of prices for touched tokens only, first price is always fee token price
      * @param tokenIdsForPrice price[i] is the price for the token with tokenID tokenIdsForPrice[i]
      */
    function updateCurrentPrices(uint128[] memory prices, uint16[] memory tokenIdsForPrice) private {
        for (uint256 i = 0; i < latestSolution.tokenIdsForPrice.length; i++) {
            currentPrices[latestSolution.tokenIdsForPrice[i]] = 0;
        }
        for (uint256 i = 0; i < tokenIdsForPrice.length; i++) {
            currentPrices[tokenIdsForPrice[i]] = prices[i];
        }
    }

    /** @dev Updates an order's remaing requested sell amount upon (partial) execution of a standing order
      * @param owner order's corresponding user address
      * @param orderId index of order in list of owner's orders
      * @param executedAmount proportion of order's requested sellAmount that was filled.
      */
    function updateRemainingOrder(address owner, uint16 orderId, uint128 executedAmount) private {
        if (isOrderWithLimitedAmount(orders[owner][orderId])) {
            orders[owner][orderId].usedAmount = orders[owner][orderId].usedAmount.add(executedAmount).toUint128();
        }
    }

    /** @dev The inverse of updateRemainingOrder, called when reverting a solution in favour of a better one.
      * @param owner order's corresponding user address
      * @param orderId index of order in list of owner's orders
      * @param executedAmount proportion of order's requested sellAmount that was filled.
      */
    function revertRemainingOrder(address owner, uint16 orderId, uint128 executedAmount) private {
        if (isOrderWithLimitedAmount(orders[owner][orderId])) {
            orders[owner][orderId].usedAmount = orders[owner][orderId].usedAmount.sub(executedAmount).toUint128();
        }
    }

    /** @dev Checks whether an order is intended to track its usedAmount
      * @param order order under inspection
      * @return true if the given order does track its usedAmount
      */
    function isOrderWithLimitedAmount(Order memory order) private pure returns (bool) {
        return order.priceNumerator != UNLIMITED_ORDER_AMOUNT && order.priceDenominator != UNLIMITED_ORDER_AMOUNT;
    }

    /** @dev This function writes solution information into contract storage
      * @param batchId index of referenced auction
      * @param owners array of addresses corresponding to touched orders
      * @param orderIds array of order indices used in parallel with owners to identify touched order
      * @param volumes executed buy amounts for each order identified by index of owner-orderId arrays
      * @param tokenIdsForPrice price[i] is the price for the token with tokenID tokenIdsForPrice[i]
      */
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

    /** @dev reverts all relevant contract storage relating to an overwritten auction solution.
      */
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
                subtractBalanceUnchecked(owner, tokenIdToAddressMap(order.buyToken), buyAmount);
                emit TradeReversion(owner, orderId, order.sellToken, order.buyToken, sellAmount, buyAmount);
            }
            // subtract granted fees:
            subtractBalanceUnchecked(latestSolution.solutionSubmitter, tokenIdToAddressMap(0), latestSolution.feeReward);
        }
    }

    /** @dev determines if value is better than currently and updates if it is.
      * @param newObjectiveValue proposed value to be updated if a great enough improvement on the current objective value
      */
    function checkAndOverrideObjectiveValue(uint256 newObjectiveValue) private {
        require(
            isObjectiveValueSufficientlyImproved(newObjectiveValue),
            "New objective doesn't sufficiently improve current solution"
        );
        latestSolution.objectiveValue = newObjectiveValue;
    }

    // Private view
    /** @dev Evaluates utility of executed trade
      * @param execBuy represents proportion of order executed (in terms of buy amount)
      * @param order the sell order whose utility is being evaluated
      * @return Utility = ((execBuy * order.sellAmt - execSell * order.buyAmt) * price.buyToken) / order.sellAmt
      */
    function evaluateUtility(uint128 execBuy, Order memory order) private view returns (uint256) {
        // Utility = ((execBuy * order.sellAmt - execSell * order.buyAmt) * price.buyToken) / order.sellAmt
        uint256 execSellTimesBuy = getExecutedSellAmount(execBuy, currentPrices[order.buyToken], currentPrices[order.sellToken])
            .mul(order.priceNumerator);

        uint256 roundedUtility = execBuy.sub(execSellTimesBuy.div(order.priceDenominator)).mul(currentPrices[order.buyToken]);
        uint256 utilityError = execSellTimesBuy.mod(order.priceDenominator).mul(currentPrices[order.buyToken]).div(
            order.priceDenominator
        );
        return roundedUtility.sub(utilityError);
    }

    /** @dev computes a measure of how much of an order was disregarded (only valid when limit price is respected)
      * @param order the sell order whose disregarded utility is being evaluated
      * @param user address of order's owner
      * @return disregardedUtility of the order (after it has been applied)
      * Note that:
      * |disregardedUtility| = (limitTerm * leftoverSellAmount) / order.sellAmount
      * where limitTerm = price.SellToken * order.sellAmt - order.buyAmt * price.buyToken / (1 - phi)
      * and leftoverSellAmount = order.sellAmt - execSellAmt
      * Balances and orders have all been updated so: sellAmount - execSellAmt == remainingAmount(order).
      * For correctness, we take the minimum of this with the user's token balance.
      */
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
        return leftoverSellAmount.mul(limitTerm).div(order.priceDenominator);
    }

    /** @dev Evaluates executedBuy amount based on prices and executedBuyAmout (fees included)
      * @param executedBuyAmount amount of buyToken executed for purchase in batch auction
      * @param buyTokenPrice uniform clearing price of buyToken
      * @param sellTokenPrice uniform clearing price of sellToken
      * @return executedSellAmount as expressed in Equation (2)
      * https://github.com/gnosis/dex-contracts/issues/173#issuecomment-526163117
      * execSellAmount * p[sellToken] * (1 - phi) == execBuyAmount * p[buyToken]
      * where phi = 1/FEE_DENOMINATOR
      * Note that: 1 - phi = (FEE_DENOMINATOR - 1) / FEE_DENOMINATOR
      * And so, 1/(1-phi) = FEE_DENOMINATOR / (FEE_DENOMINATOR - 1)
      * execSellAmount = (execBuyAmount * p[buyToken]) / (p[sellToken] * (1 - phi))
      *                = (execBuyAmount * buyTokenPrice / sellTokenPrice) * FEE_DENOMINATOR / (FEE_DENOMINATOR - 1)
      * in order to minimize rounding errors, the order of operations is switched
      *                = ((executedBuyAmount * buyTokenPrice) / (FEE_DENOMINATOR - 1)) * FEE_DENOMINATOR) / sellTokenPrice
      */
    function getExecutedSellAmount(uint128 executedBuyAmount, uint128 buyTokenPrice, uint128 sellTokenPrice)
        private
        pure
        returns (uint128)
    {
        /* solium-disable indentation */
        return
            uint256(executedBuyAmount)
                .mul(buyTokenPrice)
                .div(FEE_DENOMINATOR - 1)
                .mul(FEE_DENOMINATOR)
                .div(sellTokenPrice)
                .toUint128();
        /* solium-enable indentation */
    }

    /** @dev used to determine if solution if first provided in current batch
      * @return true if `latestSolution` is storing a solution for current batch, else false
      */
    function currentBatchHasSolution() private view returns (bool) {
        return latestSolution.batchId == getCurrentBatchId() - 1;
    }

    // Private view
    /** @dev Compute trade execution based on executedBuyAmount and relevant token prices
      * @param executedBuyAmount executed buy amount
      * @param order contains relevant buy-sell token information
      * @return (executedBuyAmount, executedSellAmount)
      */
    function getTradedAmounts(uint128 executedBuyAmount, Order memory order) private view returns (uint128, uint128) {
        uint128 executedSellAmount = getExecutedSellAmount(
            executedBuyAmount,
            currentPrices[order.buyToken],
            currentPrices[order.sellToken]
        );
        return (executedBuyAmount, executedSellAmount);
    }

    /** @dev Checks that the proposed objective value is a significant enough improvement on the latest one
      * @param objectiveValue the proposed objective value to check
      * @return true if the objectiveValue is a significant enough improvement, false otherwise
      */
    function isObjectiveValueSufficientlyImproved(uint256 objectiveValue) private view returns (bool) {
        return (objectiveValue.mul(IMPROVEMENT_DENOMINATOR) > getCurrentObjectiveValue().mul(IMPROVEMENT_DENOMINATOR + 1));
    }

    // Private pure
    /** @dev used to determine if an order is valid for specific auction/batch
      * @param order object whose validity is in question
      * @param batchId auction index of validity
      * @return true if order is valid in auction batchId else false
      */
    function checkOrderValidity(Order memory order, uint32 batchId) private pure returns (bool) {
        return order.validFrom <= batchId && order.validUntil >= batchId;
    }

    /** @dev computes the remaining sell amount for a given order
      * @param order the order for which remaining amount should be calculated
      * @return the remaining sell amount
      */
    function getRemainingAmount(Order memory order) private pure returns (uint128) {
        return order.priceDenominator - order.usedAmount;
    }

    /** @dev called only by getEncodedOrders and used to pack auction info into bytes
      * @param user list of tokenIds
      * @param sellTokenBalance user's account balance of sell token
      * @param order a sell order
      * @return byte encoded, packed, concatenation of relevant order information
      */
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

    /** @dev determines if value is better than currently and updates if it is.
      * @param amounts array of values to be verified with AMOUNT_MINIMUM
      */
    function verifyAmountThreshold(uint128[] memory amounts) private pure returns (bool) {
        for (uint256 i = 0; i < amounts.length; i++) {
            if (amounts[i] < AMOUNT_MINIMUM) {
                return false;
            }
        }
        return true;
    }
}

contract BatchExchangeViewer {
    using BytesLib for bytes;
    using SafeMath for uint256;

    uint8 public constant AUCTION_ELEMENT_WIDTH = 112;
    // Can be used by external contracts to indicate no filter as it doesn't seem possible
    // to create an empty memory array in solidity.
    uint16[] public ALL_TOKEN_FILTER;

    BatchExchange batchExchange;

    constructor(BatchExchange exchange) public {
        batchExchange = exchange;
    }

    /** @dev Queries the orderbook for the auction that is still accepting orders
     *  @param tokenFilter all returned order will have buy *and* sell token from this list (leave empty for "no filter")
     *  @return encoded bytes representing orders
     */
    function getOpenOrderBook(address[] memory tokenFilter) public view returns (bytes memory) {
        (bytes memory elements, , ) = getOpenOrderBookPaginated(tokenFilter, address(0), 0, uint16(-1));
        return elements;
    }

    /** @dev Queries a page of the orderbook for the auction that is still accepting orders
     *  @param tokenFilter all returned order will have buy *and* sell token from this list (leave empty for "no filter")
     *  @param previousPageUser address taken from nextPageUser return value from last page (address(0) for first page)
     *  @param previousPageUserOffset offset taken nextPageUserOffset return value from last page (0 for first page)
     *  @param pageSize count of elements to be returned per page (same value is used for subqueries on the exchange)
     *  @return encoded bytes representing orders and page information for next page
     */
    function getOpenOrderBookPaginated(
        address[] memory tokenFilter,
        address previousPageUser,
        uint16 previousPageUserOffset,
        uint16 pageSize
    ) public view returns (bytes memory elements, address nextPageUser, uint16 nextPageUserOffset) {
        uint32 batch = batchExchange.getCurrentBatchId();
        return
            getEncodedOrdersPaginated(
                batch,
                batch,
                batch + 1,
                getTokenIdsFromAdresses(tokenFilter),
                previousPageUser,
                previousPageUserOffset,
                pageSize
            );
    }

    /** @dev Queries the orderbook for the auction that is currently being solved
     *  @param tokenFilter all returned order will have buy *and* sell token from this list (leave empty for "no filter")
     *  @return encoded bytes representing orders
     */
    function getFinalizedOrderBook(address[] memory tokenFilter) public view returns (bytes memory) {
        (bytes memory elements, , ) = getFinalizedOrderBookPaginated(tokenFilter, address(0), 0, uint16(-1));
        return elements;
    }

    /** @dev Queries a page of the orderbook for the auction that is currently being solved
     *  @param tokenFilter all returned order will have buy *and* sell token from this list (leave empty for "no filter")
     *  @param previousPageUser address taken from nextPageUser return value from last page (address(0) for first page)
     *  @param previousPageUserOffset offset taken nextPageUserOffset return value from last page (0 for first page)
     *  @param pageSize count of elements to be returned per page (same value is used for subqueries on the exchange)
     *  @return encoded bytes representing orders and page information for next page
     */
    function getFinalizedOrderBookPaginated(
        address[] memory tokenFilter,
        address previousPageUser,
        uint16 previousPageUserOffset,
        uint16 pageSize
    ) public view returns (bytes memory elements, address nextPageUser, uint16 nextPageUserOffset) {
        uint32 batch = batchExchange.getCurrentBatchId();
        return
            getEncodedOrdersPaginated(
                batch - 1,
                batch - 1,
                batch,
                getTokenIdsFromAdresses(tokenFilter),
                previousPageUser,
                previousPageUserOffset,
                pageSize
            );
    }

    /** @dev Queries a page in the list of all orders
     *  @param maxValidFrom all returned orders will have a validFrom <= this value (they were placed at or before that batch)
     *  @param minValidUntil all returned orders will have a validUntil >= this value (validity ends at or after that batch)
     *  @param sellBalanceTargetBatchIndex the batchIndex at which we are expecting the sellTokenBalance to be valid
        (e.g. in the current live orderbook we want to include sellBalances that are valid in currentBatch + 1).
     *  @param tokenFilter all returned order will have buy *and* sell token from this list (leave empty for "no filter")
     *  @param previousPageUser address taken from nextPageUser return value from last page (address(0) for first page)
     *  @param previousPageUserOffset offset taken nextPageUserOffset return value from last page (0 for first page)
     *  @param pageSize count of elements to be returned per page (same value is used for subqueries on the exchange)
     *  @return encoded bytes representing orders and page information for next page
     */
    function getEncodedOrdersPaginated(
        uint32 maxValidFrom,
        uint32 minValidUntil,
        uint32 sellBalanceTargetBatchIndex,
        uint16[] memory tokenFilter,
        address previousPageUser,
        uint16 previousPageUserOffset,
        uint16 pageSize
    ) public view returns (bytes memory elements, address nextPageUser, uint16 nextPageUserOffset) {
        nextPageUser = previousPageUser;
        nextPageUserOffset = previousPageUserOffset;
        bool hasNextPage = true;
        while (hasNextPage) {
            bytes memory unfiltered = batchExchange.getEncodedUsersPaginated(nextPageUser, nextPageUserOffset, pageSize);
            hasNextPage = unfiltered.length / AUCTION_ELEMENT_WIDTH == pageSize;
            for (uint16 index = 0; index < unfiltered.length / AUCTION_ELEMENT_WIDTH; index++) {
                // make sure we don't overflow index * AUCTION_ELEMENT_WIDTH
                bytes memory element = unfiltered.slice(uint256(index) * AUCTION_ELEMENT_WIDTH, AUCTION_ELEMENT_WIDTH);
                element = updateSellTokenBalanceForBatchId(element, sellBalanceTargetBatchIndex);
                if (
                    maxValidFrom >= getValidFrom(element) &&
                    minValidUntil <= getValidUntil(element) &&
                    matchesTokenFilter(getBuyToken(element), getSellToken(element), tokenFilter)
                ) {
                    elements = elements.concat(element);
                }
                // Update pagination info
                address user = getUser(element);
                if (user == nextPageUser) {
                    nextPageUserOffset += 1;
                } else {
                    nextPageUserOffset = 1;
                    nextPageUser = user;
                }
                if (elements.length / AUCTION_ELEMENT_WIDTH >= pageSize) {
                    // We are at capacity, return
                    return (elements, nextPageUser, nextPageUserOffset);
                }
            }
        }
        return (elements, nextPageUser, nextPageUserOffset);
    }

    function matchesTokenFilter(uint16 buyToken, uint16 sellToken, uint16[] memory filter) public pure returns (bool) {
        // An empty filter is interpreted as "select all"
        if (filter.length == 0) {
            return true;
        }
        (bool foundBuyToken, bool foundSellToken) = (false, false);
        for (uint256 index = 0; index < filter.length; index++) {
            if (filter[index] == buyToken) {
                foundBuyToken = true;
            }
            if (filter[index] == sellToken) {
                foundSellToken = true;
            }
        }
        return foundBuyToken && foundSellToken;
    }

    function getUser(bytes memory element) public pure returns (address) {
        bytes memory slice = element.slice(0, 20);
        return slice.toAddress(0);
    }

    function getSellTokenBalance(bytes memory element) public pure returns (uint256) {
        bytes memory slice = element.slice(20, 52);
        return slice.toUint(0);
    }

    function updateSellTokenBalance(bytes memory element, uint256 amount) public pure returns (bytes memory) {
        return element.slice(0, 20).concat(abi.encodePacked(amount)).concat(element.slice(52, AUCTION_ELEMENT_WIDTH - 52));
    }

    function getBuyToken(bytes memory element) public pure returns (uint16) {
        bytes memory slice = element.slice(52, 2);
        return slice.toUint16(0);
    }

    function getSellToken(bytes memory element) public pure returns (uint16) {
        bytes memory slice = element.slice(54, 2);
        return slice.toUint16(0);
    }

    function getValidFrom(bytes memory element) public pure returns (uint32) {
        bytes memory slice = element.slice(56, 4);
        return slice.toUint32(0);
    }

    function getValidUntil(bytes memory element) public pure returns (uint32) {
        bytes memory slice = element.slice(60, 4);
        return slice.toUint32(0);
    }

    function getTokenIdsFromAdresses(address[] memory tokenIds) public view returns (uint16[] memory) {
        uint16[] memory result = new uint16[](tokenIds.length);
        for (uint256 index = 0; index < tokenIds.length; index++) {
            result[index] = batchExchange.tokenAddressToIdMap(tokenIds[index]);
        }
        return result;
    }

    function updateSellTokenBalanceForBatchId(bytes memory element, uint32 targetBatchIndex) public view returns (bytes memory) {
        address user = getUser(element);
        uint16 sellToken = getSellToken(element);
        address sellTokenAddress = batchExchange.tokenIdToAddressMap(sellToken);
        uint256 sellTokenBalance = getSellTokenBalance(element);
        (uint256 depositAmount, uint32 depositBatch) = batchExchange.getPendingDeposit(user, sellTokenAddress);
        // The deposit is not valid currently but will be valid at target batch, thus add to balance
        if (depositBatch >= batchExchange.getCurrentBatchId() && depositBatch < targetBatchIndex) {
            sellTokenBalance = sellTokenBalance.add(depositAmount);
        }
        (uint256 withdrawAmount, uint32 withdrawBatch) = batchExchange.getPendingWithdraw(user, sellTokenAddress);
        // The withdraw is not valid currently but will be valid at target batch, thus subtract from balance
        if (withdrawBatch >= batchExchange.getCurrentBatchId() && withdrawBatch < targetBatchIndex) {
            sellTokenBalance = sellTokenBalance.sub(Math.min(sellTokenBalance, withdrawAmount));
        }
        return updateSellTokenBalance(element, sellTokenBalance);
    }
}