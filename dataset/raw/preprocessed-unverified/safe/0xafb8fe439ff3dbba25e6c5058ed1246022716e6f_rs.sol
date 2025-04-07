/**

 *Submitted for verification at Etherscan.io on 2019-05-02

*/



pragma solidity ^0.5.2;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





/**

 * Utility library of inline functions on addresses

 */





/**

 * @title Helps contracts guard against reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>

 * @dev If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {

    /// @dev counter to allow mutex lock with only one SSTORE operation

    uint256 private _guardCounter;



    constructor () internal {

        // The counter starts at one to prevent changing it from zero to a non-zero

        // value, which is a more expensive operation.

        _guardCounter = 1;

    }



    /**

     * @dev Prevents a contract from calling itself, directly or indirectly.

     * Calling a `nonReentrant` function from another `nonReentrant`

     * function is not supported. It is possible to prevent this from happening

     * by making the `nonReentrant` function external, and make it call a

     * `private` function that does the actual work.

     */

    modifier nonReentrant() {

        _guardCounter += 1;

        uint256 localCounter = _guardCounter;

        _;

        require(localCounter == _guardCounter);

    }

}



/**

 * Phat Cats - Crypto-Cards

 *  - https://crypto-cards.io

 *  - https://phatcats.co

 *

 * Copyright 2019 (c) Phat Cats, Inc.

 */



/**

 * @title Crypto-Cards Payroll

 */

contract CryptoCardsPayroll is Ownable, ReentrancyGuard {

    using SafeMath for uint256;



    event PayeeAdded(address account, uint256 shares);

    event PayeeUpdated(address account, uint256 sharesAdded, uint256 totalShares);

    event PaymentReleased(address to, uint256 amount);

    event PaymentReceived(address from, uint256 amount);



    uint256 private _totalShares;

    uint256 private _totalReleased;

    uint256 private _totalReleasedAllTime;



    mapping(address => uint256) private _shares;

    mapping(address => uint256) private _released;

    address[] private _payees;



    /**

     * @dev Constructor

     */

    constructor () public {}



    /**

     * @dev payable fallback

     */

    function () external payable {

        emit PaymentReceived(msg.sender, msg.value);

    }



    /**

     * @return the total shares of the contract.

     */

    function totalShares() public view returns (uint256) {

        return _totalShares;

    }



    /**

     * @return the total amount already released.

     */

    function totalReleased() public view returns (uint256) {

        return _totalReleased;

    }



    /**

     * @return the total amount already released.

     */

    function totalReleasedAllTime() public view returns (uint256) {

        return _totalReleasedAllTime;

    }



    /**

     * @return the total amount of funds in the contract.

     */

    function totalFunds() public view returns (uint256) {

        return address(this).balance;

    }



    /**

     * @return the shares of an account.

     */

    function shares(address account) public view returns (uint256) {

        return _shares[account];

    }



    /**

     * @return the shares of an account.

     */

    function sharePercentage(address account) public view returns (uint256) {

        if (_totalShares == 0 || _shares[account] == 0) { return 0; }

        return _shares[account].mul(100).div(_totalShares);

    }



    /**

     * @return the amount already released to an account.

     */

    function released(address account) public view returns (uint256) {

        return _released[account];

    }



    /**

     * @return the amount available for release to an account.

     */

    function available(address account) public view returns (uint256) {

        uint256 totalReceived = address(this).balance.add(_totalReleased);

        uint256 totalCut = totalReceived.mul(_shares[account]).div(_totalShares);

        if (totalCut < _released[account]) { return 0; }

        return totalCut.sub(_released[account]);

    }



    /**

     * @return the address of a payee.

     */

    function payee(uint256 index) public view returns (address) {

        return _payees[index];

    }



    /**

     * @dev Release payee's proportional payment.

     */

    function release() external nonReentrant {

        address payable account = address(uint160(msg.sender));

        require(_shares[account] > 0, "Account not eligible for payroll");



        uint256 payment = available(account);

        require(payment != 0, "No payment available for account");



        _release(account, payment);

    }



    /**

     * @dev Release payment for all payees and reset state

     */

    function releaseAll() public onlyOwner {

        _releaseAll();

        _resetAll();

    }



    /**

     * @dev Add a new payee to the contract.

     * @param account The address of the payee to add.

     * @param shares_ The number of shares owned by the payee.

     */

    function addNewPayee(address account, uint256 shares_) public onlyOwner {

        require(account != address(0), "Invalid account");

        require(Address.isContract(account) == false, "Account cannot be a contract");

        require(shares_ > 0, "Shares must be greater than zero");

        require(_shares[account] == 0, "Payee already exists");

        require(_totalReleased == 0, "Must release all existing payments first");



        _payees.push(account);

        _shares[account] = shares_;

        _totalShares = _totalShares.add(shares_);

        emit PayeeAdded(account, shares_);

    }



    /**

     * @dev Increase he shares of an existing payee

     * @param account The address of the payee to increase.

     * @param shares_ The number of shares to add to the payee.

     */

    function increasePayeeShares(address account, uint256 shares_) public onlyOwner {

        require(account != address(0), "Invalid account");

        require(shares_ > 0, "Shares must be greater than zero");

        require(_shares[account] > 0, "Payee does not exist");

        require(_totalReleased == 0, "Must release all existing payments first");



        _shares[account] = _shares[account].add(shares_);

        _totalShares = _totalShares.add(shares_);

        emit PayeeUpdated(account, shares_, _shares[account]);

    }



    /**

     * @dev Release one of the payee's proportional payment.

     * @param account Whose payments will be released.

     */

    function _release(address payable account, uint256 payment) private {

        _released[account] = _released[account].add(payment);

        _totalReleased = _totalReleased.add(payment);

        _totalReleasedAllTime = _totalReleasedAllTime.add(payment);



        account.transfer(payment);

        emit PaymentReleased(account, payment);

    }



    /**

     * @dev Release payment for all payees

     */

    function _releaseAll() private {

        for (uint256 i = 0; i < _payees.length; i++) {

            _release(address(uint160(_payees[i])), available(_payees[i]));

        }

    }



    /**

     * @dev Reset state of released payments for all payees

     */

    function _resetAll() private {

        for (uint256 i = 0; i < _payees.length; i++) {

            _released[_payees[i]] = 0;

        }

        _totalReleased = 0;

    }

}