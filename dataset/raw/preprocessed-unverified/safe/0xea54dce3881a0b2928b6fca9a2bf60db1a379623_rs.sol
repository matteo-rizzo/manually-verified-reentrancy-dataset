/**
 *Submitted for verification at Etherscan.io on 2019-07-18
*/

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 * 
 * @dev Default OpenZeppelin
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * 
 * @dev Completely default OpenZeppelin.
 */


/**
 * @dev This has been changed slightly from OpenZeppelin to get rid of the Roles library 
 *      and only allow owner to add pausers (and allow them to renounce).
**/
contract Pauser is Ownable {

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    mapping (address => bool) private pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return pausers[account];
    }

    function addPauser(address account) public onlyOwner {
        _addPauser(account);
    }

    function renouncePauser(address account) public {
        require(msg.sender == account || isOwner());
        _removePauser(account);
    }

    function _addPauser(address account) internal {
        pausers[account] = true;
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        pausers[account] = false;
        emit PauserRemoved(account);
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable  is Pauser {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.01
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Subscriptions allows recurring payments to be made to businesses or individuals with
 *      no interaction by the user required after the initial subscription.
**/
contract PostAuditSubscriptions is Pausable {

    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using BokkyDateTime for *;

    // Contract that will be inputting date and prices.
    address public subOracle;

    // Incrementing ID count to assign ID when a new subscription is created.
    // First ID is 1.
    uint256 public idCount;

    // Addresses to pay out fees to.
    address public monarch;

    // Fee to be sent to the Monarch wallet--a value of 100 == 1%.
    uint256 public adminFee;

    // Gas amount that will be paid for each payment call and the maximum gas price that can be used.
    uint256 public gasAmt;
    uint256 public gasPriceCap;

    // User => subscription id => subscription details.
    // Need to change to account for monthly payments and set length.
    mapping (address => mapping (uint256 => Subscription)) public subscriptions;

    // ID => universal data for subscription types.
    mapping (uint256 => Template) public templates;

    // IERC20 and Ether balances of users
    mapping (address => mapping (address => uint256)) public balances;

    // Mapping of tokens that are approved to be used as payment to their number of decimals (we don't want to take fees in worthless tokens).
    mapping (address => uint256) public approvedTokens;

    // Mapping of token => eth conversion in order to pay payment senders accurately. Only able to be changed by SubOracle. uint256 = amount of wei 1 token is worth.
    mapping (address => uint256) public tokenPrices;

    // Emitted when a company creates a new subscription structure.
    event Creation(uint256 indexed id, address indexed recipient, address token, uint256 price, uint256 interval,
                   uint8 target, bool setLen, uint48 payments, address creator, bool payNow, bool payInFiat);

    // User deposits Ether or IERC20 tokens to the contract.
    event Deposit(address indexed user, address indexed token, uint256 balance);

    // User withdraws Ether or IERC20 tokens from the contract.
    event Withdrawal(address indexed user, address indexed token, uint256 balance);

    // Used for when balance changes outside of deposit and withdrawal.
    event NewBals(address[4] users, uint256[4] balances, address token);

    // Emitted if a payment is attempting to be made for a subscription that never existed, has been cancelled, or is not yet due.
    event NotDue(address indexed user, uint256 indexed id);

    // Emit user, id of subscription, and time for subscription payment.
    event Paid(address indexed user, uint256 indexed id, uint48 nextDue, uint256 datetime, bool setLen, uint48 paymentsLeft);

    // Emit user, id of subscription, and time for a payment failure.
    event Failed(address indexed user, uint256 indexed id, uint256 datetime);

    // Emit user, id, and time for new subscription.
    event Subscribed(address indexed user, uint256 indexed id, uint256 datetime, uint48 nextDue);

    // Emit user, id, and time for cancelled subscription.
    event Unsubscribed(address indexed user, uint256 indexed id, uint256 datetime);

    /**
     * @dev Data for a subscription type created by company.
     * @param price The price of the template in token wei or USD wei in the case of payInFiat.
     * @param recipient Company/entity to receive funds.
     * @param token Token to receive funds in.
     * @param amount Amount of the token to receive.
     * @param interval Number of seconds between each payment.
     * @param monthly Whether this is made on a specific day of the month.
     * @param target If monthly, this is the day of the month that the payment should be made.
     * @param setLen Whether or not the subscriptions will have a fixed number of payments.
     * @param payments The number of payments to be made before the subscription cancels if setLen.
     * @param creator The address that created this template.
     * @param payNow Whether or not the first payment should be made immediately.
     * @param payInFiat Allows the template to be paid using a token's USD value.
    **/
    struct Template {
        uint256 price;
        address recipient;
        uint48 interval;
        uint8 target;
        address token;
        bool setLen;
        uint48 payments;
        address creator;
        bool payNow;
        bool payInFiat;
    }

    /**
     * @dev Data for each individual subscription.
     * @param startTime The original unix time this subscription was created.
     * @param lastPaid The last time this subscription was paid, either unix time or month.
     * @param nextDue The next unix time or next month that the subscription is due.
     * @param paymentsLeft The amount of payments left (if the template is setLen)
     * @param startPaid Whether or not the user has paid the first installment of a payNow template.
    **/
    struct Subscription {
        uint48 startTime;
        uint48 lastPaid;
        uint48 nextDue;
        uint48 paymentsLeft;
        bool startPaid;
    }

/** ************************************************* Constructor ******************************************************** **/

    /**
     * @param _subOracle The address of the subscription Oracle contract that will be fetching token prices.
     * @param _monarch The Monarch wallet that will be receiving admin fees.
    **/
    constructor(address _subOracle, address _monarch)
      public
    {
        subOracle = _subOracle;
        approveToken(address(0), true);
        approveToken(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359, true);
        tokenPrices[address(0)] = 1 ether;
        setMonarch(_monarch);
        setAdminFee(100);

        // 40 gwei for test, will lower.
        setGasFees(85000, 40000000000);
    }

/** ************************************************* Deposit/Withdrawal ******************************************************** **/

    /**
     * @dev Deposit an IERC20 or Ether to the contract to fund it for subscriptions.
     * @param _token The address of the token to deposit (0x000... for Ether).
     * @param _amount The amount of the token to deposit (for Ether this will change to msg.value).
    **/
    function deposit(address _token, uint256 _amount)
      public
      payable
      whenNotPaused
    {
        require(approvedTokens[_token] > 0, "You may only deposit approved tokens.");
        require(_amount > 0, "You must deposit a non-zero amount.");

        if (_token != address(0)) {

            IERC20 token = IERC20(_token);
            SafeERC20.safeTransferFrom(token, msg.sender, address(this), _amount);

        } else {

            _amount = msg.value;
            require(_amount > 0, "No Ether was included in the transaction.");

        }

        uint256 newBal = balances[msg.sender][_token].add(_amount);
        balances[msg.sender][_token] = newBal;

        emit Deposit(msg.sender, _token, newBal);
    }

    /**
     * @dev Deposit an IERC20 or Ether to the contract to fund it for subscriptions.
     * @param _token The address of the token to be withdrawn (address(0) for Ether).
     * @param _amount The amount of token to withdraw (msg.value is used for Ether).
    **/
    function withdraw(address _token, uint256 _amount)
      external
    {
        require(_amount > 0, "You must withdraw a non-zero amount.");

        // Will throw if there's an inadequate balance.
        uint256 newBal = balances[msg.sender][_token].sub(_amount);
        balances[msg.sender][_token] = newBal;

        if (_token != address(0)) {

            IERC20 token = IERC20(_token);
            SafeERC20.safeTransfer(token, msg.sender, _amount);

        } else {

            msg.sender.transfer(_amount);

        }

        emit Withdrawal(msg.sender, _token, newBal);
    }

/** ************************************************* Subscriptions ******************************************************** **/

    /**
     * @dev User creates a subscription.
     * @param _id The ID of the template to sign up for that was emitted on template creation.
    **/
    function subscribe(uint256 _id)
      public
      whenNotPaused
    {
        // Require subscription exists
        require(_id != 0 && _id <= idCount, "Subscription does not exist.");

        // Require user is not already subscribed.
        require(subscriptions[msg.sender][_id].lastPaid == 0, "User is already subscribed.");

        Template memory template = templates[_id];

        // Target and interval types require some different information.
        uint48 lastPaid;
        uint48 nextDue;

        if (template.target > 0) {

            lastPaid = uint48(now);

            // Pacific Standard Time
            uint256 pstNow = BokkyDateTime.subHours(now, 8);

            // Simply adding 1 month may not keep target accurate.
            uint256 year = BokkyDateTime.getYear(pstNow);
            uint256 month = BokkyDateTime.getMonth(pstNow);
            uint256 day = BokkyDateTime.getDay(pstNow);

            // If we're before the target in a month it's due, make nextDue this month's target, else next month's.
            if (day < template.target) nextDue = uint48(BokkyDateTime.timestampFromDate(year, month, template.target));
            else nextDue = uint48(BokkyDateTime.timestampFromDate(BokkyDateTime.getYear(BokkyDateTime.addMonths(pstNow, 1)), (month % 12) + 1, template.target));

        } else {

            lastPaid = uint48(now);
            nextDue = uint48(now + template.interval);

        }

        subscriptions[msg.sender][_id] = Subscription(uint48(now), lastPaid, nextDue, template.payments, false);
        emit Subscribed(msg.sender, _id, now, nextDue);

        if (template.payNow) require(payment(msg.sender, _id), "Payment failed.");
    }

    /**
     * @dev Unsubscribe from a service.
     * @param _id ID of the template that the user is currently subscribed to.
    **/
    function unsubscribe(uint256 _id)
      public
    {
        _unsubscribe(msg.sender, _id);
    }

    /**
     * @dev Unsubscribe one of your users from a subscription. May only be used by template creator.
     * @param _user The user to unsubscribe.
     * @param _id The template to unsubscribe the user from.
    **/
    function unsubscribeUser(address _user, uint256 _id)
      public
    {
        require(msg.sender == templates[_id].creator, "Only the template creator may unsubscribe a user.");
        _unsubscribe(_user, _id);
    }

    /**
     * @dev Internal unsubscribe.
     * @param _user The user to unsubscribe.
     * @param _id The of the subscription.
    **/
    function _unsubscribe(address _user, uint256 _id)
      internal
    {
        delete subscriptions[_user][_id];
        emit Unsubscribed(_user, _id, now);
    }

    /**
     * @dev If a user is depositing for a specific subscription, they can use this to do both at once.
     * @param _token The address of the token to be deposited.
     * @param _amount The amount of the token to be deposited.
     * @param _id The ID of the template to subscribe to.
    **/
    function depositAndSubscribe(address _token, uint256 _amount, uint256 _id)
      public
      payable
      whenNotPaused
    {
        deposit(_token, _amount);
        subscribe(_id);
    }

/** ************************************************* Payments ******************************************************** **/

    /**
     * @dev Make a payment for a subscription, may be called by anyone.
     * @param _user The user whose subscription is being paid.
     * @param _id The ID of the subscription.
     * @return Whether the payment was a success or not.
    **/
    function payment(address _user, uint256 _id)
      public
      whenNotPaused
    returns (bool)
    {
        Subscription memory sub = subscriptions[_user][_id];
        Template memory template = templates[_id];

        // Convert Fiat price to a token value. Original token price is in USD wei, return is token wei.
        if (template.payInFiat) template.price = tokenToFiat(template.token, template.price);

        // Check subscription for whether it's due.
        if (!checkDue(_user, _id, template, sub)) return false;

        // Update the 4 balances being altered (user, recipient, monarch, payment daemon).
        updateBals(_user, template);

        // Set new due dates.
        sub = updateDue(_user, _id, template, sub);

        emit Paid(_user, _id, sub.nextDue, now, template.setLen, sub.paymentsLeft);

        return true;
    }

    /**
     * @dev Accepts token and USD amount desired then finds token value equivalent.
     * @param _token The address of the token to convert.
     * @param _usdAmount The amount of USD the token amount must equal.
     * @return How much Dai the given token and amount is worth.
    **/
    function tokenToFiat(address _token, uint256 _usdAmount)
      public
      view
    returns (uint256 tokenAmount)
    {
        // Dai is our USD stand-in.
        uint256 daiPerEth = tokenPrices[0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359];
        uint256 tokenPerEth = tokenPrices[_token];

        // (USD * buffer) / ((Eth USD price * buffer) / Eth token price).
        tokenAmount = (_usdAmount.mul(1 ether)).div(((daiPerEth.mul(1 ether)).div((tokenPerEth))));

        // Hacked approvedTokens into also saving the decimals of a token.
        uint256 decimals = 10 ** approvedTokens[_token];
        tokenAmount = tokenAmount.mul(decimals).div(1 ether);
    }

    /**
     * @dev Check whether the payment is due and if it can be paid.
     * @param _user The address of the user who is paying.
     * @param _id The id of the subscription to update.
     * @param _template Memory struct of the template information.
     * @param _sub Memory struct of the user subscription information.
     * @return Whether or not a payment is currently due.
    **/
    function checkDue(address _user, uint256 _id, Template memory _template, Subscription memory _sub)
      internal
    returns (bool due)
    {
        // We must check user balance and allowance beforehand so, in the case of bulk payments, one failed payment won't revert everything.
        uint256 balance = balances[_user][_template.token];

        // Fail if not enough balance.
        if (balance < _template.price) {

            emit Failed(_user, _id, now);
            return false;

        }

        // Protection in case user is not subscribed.
        if (_sub.lastPaid == 0) {

            emit NotDue(_user, _id);
            return false;

        }

        // If this is the first payment and payNow is true, let it through.
        if (_template.payNow && !_sub.startPaid) return true;

        // Check if interval payment is owed.
        if (_sub.nextDue >= now) {

            emit NotDue(_user, _id);
            return false;

        }

        return true;
    }

    /**
     * @dev Update each relevant balance.
     * @param _user The address of the user who is paying.
     * @param _template Memory struct of the template information.
    **/
    function updateBals(address _user, Template memory _template)
      internal
    {
        address token = _template.token;
        uint256 price = _template.price;
        uint256 monarchFee = price / adminFee;

        uint256 gasPrice = tx.gasprice;
        if (gasPrice > gasPriceCap) gasPrice = gasPriceCap;

        // If a token is being paid, convert the Ether gas fee to equivalent token value.
        uint256 gasFee;
        if (token != address(0)) gasFee = (tokenPrices[token].mul(gasAmt).mul(gasPrice)).div(1 ether);
        else gasFee = gasAmt.mul(gasPrice);

        // User balance - price
        uint256 userBal = balances[_user][token].sub(price);
        balances[_user][token] = userBal;

        // Recipient balance + (price - (gasFee + monarchFee))
        uint256 recipBal = balances[_template.recipient][token].add(price.sub(gasFee.add(monarchFee)));
        balances[_template.recipient][token] = recipBal;

        // Pay daemon balance + gasFee
        uint256 paydBal = balances[msg.sender][token].add(gasFee);
        balances[msg.sender][token] = paydBal;

        // Monarch balance + monarchFee
        uint256 monarchBal = balances[monarch][token].add(monarchFee);
        balances[monarch][token] = monarchBal;

        emit NewBals([_user, _template.recipient, msg.sender, monarch], [userBal, recipBal, paydBal, monarchBal], token);
    }

    /**
     * @dev Update due dates and payments left.
     * @param _user The address of the user who is paying.
     * @param _id The id of the subscription to update.
     * @param _template Memory struct of the template information.
     * @param _sub Memory struct of the user subscription information.
     * @return The user's updated subscription struct.
    **/
    function updateDue(address _user, uint256 _id, Template memory _template, Subscription memory _sub)
      internal
    returns (Subscription memory)
    {
        // We don't want lastPaid and nextDue changed if it's a payNow payment.
        bool payNow = _template.payNow && !_sub.startPaid;

        // If this is called late, we don't want to use 'now' but rather give them 'interval' time from last payment.
        if (!payNow && _template.interval > 0) {

            _sub.lastPaid = _sub.nextDue;
            _sub.nextDue = _sub.lastPaid + _template.interval;

        } else if (!payNow) {

            _sub.lastPaid = _sub.nextDue;
            _sub.nextDue = uint48(BokkyDateTime.addMonths(_sub.lastPaid, 1));

        }

        // If there's a set length, alter paymentsLeft, unsubscribe if 0.
        if (_template.setLen) _sub.paymentsLeft = _sub.paymentsLeft - 1;

        // Set original payment to true.
        if (payNow) _sub.startPaid = true;

        if (_template.setLen && _sub.paymentsLeft == 0) _unsubscribe(_user, _id);
        else subscriptions[_user][_id] = _sub;

        return _sub;
    }

    /**
     * @dev Used for bulk payments.
     * @param _users Address of users to ping contracts for payments.
     * @param _ids IDs of template to pay for the corresponding user.
    **/
    function bulkPayments(address[] calldata _users, uint256[] calldata _ids)
      external
      whenNotPaused
    {
        require(_users.length == _ids.length, "The submitted arrays are of uneven length.");

        for (uint256 i = 0; i < _users.length; i++) {

            payment(_users[i], _ids[i]);

        }
    }

/** ************************************************* Creation ******************************************************** **/

    /**
     * @dev Used by a company to create a new subscription structure.
     * @param _recipient The entity to be paid by the subscription.
     * @param _token The token the subscription should be paid in.
     * @param _price The amount of tokens to be paid (token wei).
     * @param _interval How often the subscription should be paid.
     * @param _target The target day of the month to be paid (if not interval).
     * @param _setLen Whether or not there will be a fixed amount of payments.
     * @param _payments The number of payments if fixed.
     * @param _payNow True if the payment is to be made immediately.
     * @param _payInFiat True if the price should be paid in Fiat (i.e. $10 USD of the token each interval).
     * @return The ID of the newly created template.
    **/
    function createTemplate(address payable _recipient, address _token, uint256 _price, uint48 _interval,
                            uint8 _target, bool _setLen, uint48 _payments, bool _payNow, bool _payInFiat)
      public
      whenNotPaused
    returns (uint256 id)
    {
        // Make sure the template is EITHER interval or target. Interval should be more than a day to prevent payment spam.
        require((_interval >= 86400 && _target == 0) || (_interval == 0 && _target > 0), "You must choose >= 1 day interval or target.");

        // Prevent overflow with a max interval of 100 years.
        require(_interval <= 3153600000, "You may not have an interval of over 100 years.");

        // Target must be a valid day of the month.
        if (_target > 0) require(_target <= 28, "Target must be a valid day.");

        // Token must be on our approved list.
        require(approvedTokens[_token] > 0, "The desired token is not on the approved tokens list.");

        // Price must be above $1.
        require(_price >= tokenToFiat(_token, 1 ether), "Your subscription must have a price of at least $1.");

        // Must have a set amount of payments if it's a set length and vice versa.
        if (_setLen) require(_payments > 0, "A set-length template must have non-zero payments.");
        else require(_payments == 0, "A non-set-length template must have zero payments.");

        Template memory template = Template(_price, _recipient, _interval, _target, _token, _setLen, _payments, msg.sender, _payNow, _payInFiat);

        idCount++;
        id = idCount;
        templates[id] = template;

        emit Creation(id, _recipient, _token, _price, _interval, _target, _setLen, _payments, msg.sender, _payNow, _payInFiat);
    }

    /**
     * @dev Simpler way for an individual to make their own subscription and subscribe with only one function call.
     *      Same params as createSubscription.
    **/
    function createAndSubscribe(address payable _recipient, address _token, uint256 _price, uint48 _interval,
                                uint8 _target, bool _setLen, uint48 _payments, bool _payNow, bool _payInFiat)
      external
      whenNotPaused
    {
        uint256 id = createTemplate(_recipient, _token, _price, _interval, _target, _setLen, _payments, _payNow, _payInFiat);
        subscribe(id);
    }

    /**
     * @dev As above but with deposit added.
     * @param _amount The amount of token wei to deposit.
    **/
    function createDepositAndSubscribe(address payable _recipient, address _token, uint256 _price, uint48 _interval, uint8 _target,
                                       bool _setLen, uint48 _payments, bool _payNow, bool _payInFiat, uint256 _amount)
        external
        payable
        whenNotPaused
    {
        uint256 id = createTemplate(_recipient, _token, _price, _interval, _target, _setLen, _payments, _payNow, _payInFiat);
        deposit(_token, _amount);
        subscribe(id);
    }

/** ************************************************* onlyOracle ******************************************************** **/

    /**
     * @dev For functions that only admins can call.
    **/
    modifier onlyOracle
    {
        require(msg.sender == subOracle, "Only the oracle may call this function.");
        _;
    }

    /**
     * @dev Used by the subscription oracle to set the current token prices (in Ether).
     * @param _tokens Array of the token addresses.
     * @param _prices Array of the prices for each address.
    **/
    function setPrices(address[] calldata _tokens, uint256[] calldata _prices)
      external
      onlyOracle
    {
        require(_tokens.length == _prices.length, "Submitted arrays are of uneven length.");

        for (uint256 i = 0; i < _tokens.length; i++) {

            require(approvedTokens[_tokens[i]] > 0, "Price may only be set for approved tokens.");
            tokenPrices[_tokens[i]] = _prices[i];

        }
    }

/** ************************************************* Privileged ******************************************************** **/

    /**
     * @dev Used in the case that something happens to the contract or the contract is being updated and all funds must be withdrawn.
     * @param _users Array of users to withdraw for.
     * @param _tokens Token to withdraw for the corresponding user.
    **/
    function bulkWithdraw(address payable[] calldata _users, address[] calldata _tokens)
      external
      onlyOwner
    {
        require(_users.length == _tokens.length, "Submitted arrays are of uneven length.");

        for (uint256 i = 0; i < _users.length; i++) {

            address payable user = _users[i];
            address token = _tokens[i];

            uint256 balance = balances[user][token];
            if (balance == 0) continue;

            balances[user][token] = 0;

            if (token != address(0)) {

                IERC20 tokenC = IERC20(token);
                SafeERC20.safeTransfer(tokenC, user, balance);

                // require(tokenC.transfer(user, balance), "Token transfer failed.");

            } else {

                // We don't want one user to cause a revert so we're allowing send to fail.
                if (!user.send(balance)) {
                    balances[user][token] = balance;
                    continue;
                }

            }

            emit Withdrawal(user, token, balance);
        }

    }

    /**
     * @dev Used to change the Monarch address that will be given the admin fees.
     * @param _monarch The new Monarch wallet address.
    **/
    function setMonarch(address _monarch)
      public
      onlyOwner
    {
        monarch = _monarch;
    }

    /**
     * @dev Used by Monarch to approve (or disapprove) tokens that may be used for payment.
     * @param _token The address of the token in question.
     * @param _add Whether to add or remove the token.
    **/
    function approveToken(address _token, bool _add)
      public
      onlyPauser
    {
        if (_add) {

            uint256 decimals;
            //if (_token == address(0)) decimals = 18;
            //else decimals = uint256(IERC20(_token).decimals());
            decimals = 18;

            approvedTokens[_token] = decimals;

        } else {

            delete approvedTokens[_token];

        }
    }

    /**
     * @dev Used by Monarch to change the current gas fee.
     * @param _gasAmt The amount of gas that the payment function will cost to execute.
     * @param _gasPriceCap The maximum gwei cost that may be used to pay for sending payments.
    **/
    function setGasFees(uint256 _gasAmt, uint256 _gasPriceCap)
      public
      onlyPauser
    {
        // Generally this is a constant number but we may want it lowered in some cases.
        require(_gasAmt <= 85000, "Desired gas amount is too high.");

        // Limit gas price to 40 gwei to dissuade malicious admins.
        require(_gasPriceCap <= 40000000000, "Desired gas price is too high.");

        gasAmt = _gasAmt;
        gasPriceCap = _gasPriceCap;
    }

    /**
     * @dev Used by Monarch to change the current gas fee.
     * @param _adminFee is a number to divide price by: i.e. adminFee of 100 is 1%
    **/
    function setAdminFee(uint256 _adminFee)
      public
      onlyPauser
    {
        // Limit fee to 10% to dissuade malicious admins.
        require(_adminFee >= 10, "Desired fee is too large.");
        adminFee = _adminFee;
    }

}