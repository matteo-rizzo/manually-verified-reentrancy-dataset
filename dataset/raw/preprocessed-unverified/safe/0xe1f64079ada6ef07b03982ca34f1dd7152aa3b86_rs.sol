/**
 *Submitted for verification at Etherscan.io on 2020-02-20
*/

/*
* Synthetix - Depot.sol
*
* https://github.com/Synthetixio/synthetix
* https://synthetix.io
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
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
    
/* ===============================================
* Flattened with Solidifier by Coinage
* 
* https://solidifier.coina.ge
* ===============================================
*/


pragma solidity ^0.4.24;

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2дл.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev counter to allow mutex lock with only one SSTORE operation
  uint256 private _guardCounter;

  constructor() internal {
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


/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       Owned.sol
version:    1.1
author:     Anton Jurisevic
            Dominic Romanowski

date:       2018-2-26

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

An Owned contract, to be inherited by other contracts.
Requires its owner to be explicitly set in the constructor.
Provides an onlyOwner access modifier.

To change owner, the current owner must nominate the next owner,
who then has to accept the nomination. The nomination can be
cancelled before it is accepted by the new owner by having the
previous owner change the nomination (setting it to 0).

-----------------------------------------------------------------
*/


/**
 * @title A contract with an owner.
 * @notice Contract ownership can be transferred by first nominating the new owner,
 * who must then accept the ownership, which prevents accidental incorrect ownership transfers.
 */



/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       SelfDestructible.sol
version:    1.2
author:     Anton Jurisevic

date:       2018-05-29

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

This contract allows an inheriting contract to be destroyed after
its owner indicates an intention and then waits for a period
without changing their mind. All ether contained in the contract
is forwarded to a nominated beneficiary upon destruction.

-----------------------------------------------------------------
*/


/**
 * @title A contract that can be destroyed by its owner after a delay elapses.
 */
contract SelfDestructible is Owned {
    uint public initiationTime;
    bool public selfDestructInitiated;
    address public selfDestructBeneficiary;
    uint public constant SELFDESTRUCT_DELAY = 4 weeks;

    /**
     * @dev Constructor
     * @param _owner The account which controls this contract.
     */
    constructor(address _owner) public Owned(_owner) {
        require(_owner != address(0), "Owner must not be zero");
        selfDestructBeneficiary = _owner;
        emit SelfDestructBeneficiaryUpdated(_owner);
    }

    /**
     * @notice Set the beneficiary address of this contract.
     * @dev Only the contract owner may call this. The provided beneficiary must be non-null.
     * @param _beneficiary The address to pay any eth contained in this contract to upon self-destruction.
     */
    function setSelfDestructBeneficiary(address _beneficiary) external onlyOwner {
        require(_beneficiary != address(0), "Beneficiary must not be zero");
        selfDestructBeneficiary = _beneficiary;
        emit SelfDestructBeneficiaryUpdated(_beneficiary);
    }

    /**
     * @notice Begin the self-destruction counter of this contract.
     * Once the delay has elapsed, the contract may be self-destructed.
     * @dev Only the contract owner may call this.
     */
    function initiateSelfDestruct() external onlyOwner {
        initiationTime = now;
        selfDestructInitiated = true;
        emit SelfDestructInitiated(SELFDESTRUCT_DELAY);
    }

    /**
     * @notice Terminate and reset the self-destruction timer.
     * @dev Only the contract owner may call this.
     */
    function terminateSelfDestruct() external onlyOwner {
        initiationTime = 0;
        selfDestructInitiated = false;
        emit SelfDestructTerminated();
    }

    /**
     * @notice If the self-destruction delay has elapsed, destroy this contract and
     * remit any ether it owns to the beneficiary address.
     * @dev Only the contract owner may call this.
     */
    function selfDestruct() external onlyOwner {
        require(selfDestructInitiated, "Self Destruct not yet initiated");
        require(initiationTime + SELFDESTRUCT_DELAY < now, "Self destruct delay not met");
        address beneficiary = selfDestructBeneficiary;
        emit SelfDestructed(beneficiary);
        selfdestruct(beneficiary);
    }

    event SelfDestructTerminated();
    event SelfDestructed(address beneficiary);
    event SelfDestructInitiated(uint selfDestructDelay);
    event SelfDestructBeneficiaryUpdated(address newBeneficiary);
}


/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       Pausable.sol
version:    1.0
author:     Kevin Brown

date:       2018-05-22

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

This contract allows an inheriting contract to be marked as
paused. It also defines a modifier which can be used by the
inheriting contract to prevent actions while paused.

-----------------------------------------------------------------
*/


/**
 * @title A contract that can be paused by its owner
 */
contract Pausable is Owned {
    uint public lastPauseTime;
    bool public paused;

    /**
     * @dev Constructor
     * @param _owner The account which controls this contract.
     */
    constructor(address _owner) public Owned(_owner) {
        // Paused will be false, and lastPauseTime will be 0 upon initialisation
    }

    /**
     * @notice Change the paused state of the contract
     * @dev Only the contract owner may call this.
     */
    function setPaused(bool _paused) external onlyOwner {
        // Ensure we're actually changing the state before we do anything
        if (_paused == paused) {
            return;
        }

        // Set our paused state.
        paused = _paused;

        // If applicable, set the last pause time.
        if (paused) {
            lastPauseTime = now;
        }

        // Let everyone know that our pause state has changed.
        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */



/*

-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       SafeDecimalMath.sol
version:    2.0
author:     Kevin Brown
            Gavin Conway
date:       2018-10-18

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

A library providing safe mathematical operations for division and
multiplication with the capability to round or truncate the results
to the nearest increment. Operations can return a standard precision
or high precision decimal. High precision decimals are useful for
example when attempting to calculate percentages or fractions
accurately.

-----------------------------------------------------------------
*/


/**
 * @title Safely manipulate unsigned fixed-point decimals at a given precision level.
 * @dev Functions accepting uints in this contract and derived contracts
 * are taken to be such fixed point decimals of a specified precision (either standard
 * or high).
 */






/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract IERC20 {
    function totalSupply() public view returns (uint);

    function balanceOf(address owner) public view returns (uint);

    function allowance(address owner, address spender) public view returns (uint);

    function transfer(address to, uint value) public returns (bool);

    function approve(address spender, uint value) public returns (bool);

    function transferFrom(address from, address to, uint value) public returns (bool);

    // ERC20 Optional
    function name() public view returns (string);

    function symbol() public view returns (string);

    function decimals() public view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}


/**
 * @title ExchangeRates interface
 */



contract AddressResolver is Owned {
    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}

    /* ========== MUTATIVE FUNCTIONS ========== */

    function importAddresses(bytes32[] names, address[] destinations) public onlyOwner {
        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            repository[names[i]] = destinations[i];
        }
    }

    /* ========== VIEWS ========== */

    function getAddress(bytes32 name) public view returns (address) {
        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string reason) public view returns (address) {
        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }
}


contract MixinResolver is Owned {
    AddressResolver public resolver;

    constructor(address _owner, address _resolver) public Owned(_owner) {
        resolver = AddressResolver(_resolver);
    }

    /* ========== SETTERS ========== */

    function setResolver(AddressResolver _resolver) public onlyOwner {
        resolver = _resolver;
    }
}


contract Depot is SelfDestructible, Pausable, ReentrancyGuard, MixinResolver {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    bytes32 constant SNX = "SNX";
    bytes32 constant ETH = "ETH";

    /* ========== STATE VARIABLES ========== */

    // Address where the ether and Synths raised for selling SNX is transfered to
    // Any ether raised for selling Synths gets sent back to whoever deposited the Synths,
    // and doesn't have anything to do with this address.
    address public fundsWallet;

    /* Stores deposits from users. */
    struct synthDeposit {
        // The user that made the deposit
        address user;
        // The amount (in Synths) that they deposited
        uint amount;
    }

    /* User deposits are sold on a FIFO (First in First out) basis. When users deposit
       synths with us, they get added this queue, which then gets fulfilled in order.
       Conceptually this fits well in an array, but then when users fill an order we
       end up copying the whole array around, so better to use an index mapping instead
       for gas performance reasons.

       The indexes are specified (inclusive, exclusive), so (0, 0) means there's nothing
       in the array, and (3, 6) means there are 3 elements at 3, 4, and 5. You can obtain
       the length of the "array" by querying depositEndIndex - depositStartIndex. All index
       operations use safeAdd, so there is no way to overflow, so that means there is a
       very large but finite amount of deposits this contract can handle before it fills up. */
    mapping(uint => synthDeposit) public deposits;
    // The starting index of our queue inclusive
    uint public depositStartIndex;
    // The ending index of our queue exclusive
    uint public depositEndIndex;

    /* This is a convenience variable so users and dApps can just query how much sUSD
       we have available for purchase without having to iterate the mapping with a
       O(n) amount of calls for something we'll probably want to display quite regularly. */
    uint public totalSellableDeposits;

    // The minimum amount of sUSD required to enter the FiFo queue
    uint public minimumDepositAmount = 50 * SafeDecimalMath.unit();

    // A cap on the amount of sUSD you can buy with ETH in 1 transaction
    uint public maxEthPurchase = 500 * SafeDecimalMath.unit();

    // If a user deposits a synth amount < the minimumDepositAmount the contract will keep
    // the total of small deposits which will not be sold on market and the sender
    // must call withdrawMyDepositedSynths() to get them back.
    mapping(address => uint) public smallDeposits;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        // Ownable
        address _owner,
        // Funds Wallet
        address _fundsWallet,
        // Address Resolver
        address _resolver
    )
        public
        /* Owned is initialised in SelfDestructible */
        SelfDestructible(_owner)
        Pausable(_owner)
        MixinResolver(_owner, _resolver)
    {
        fundsWallet = _fundsWallet;
    }

    /* ========== SETTERS ========== */

    function setMaxEthPurchase(uint _maxEthPurchase) external onlyOwner {
        maxEthPurchase = _maxEthPurchase;
        emit MaxEthPurchaseUpdated(maxEthPurchase);
    }

    /**
     * @notice Set the funds wallet where ETH raised is held
     * @param _fundsWallet The new address to forward ETH and Synths to
     */
    function setFundsWallet(address _fundsWallet) external onlyOwner {
        fundsWallet = _fundsWallet;
        emit FundsWalletUpdated(fundsWallet);
    }

    /**
     * @notice Set the minimum deposit amount required to depoist sUSD into the FIFO queue
     * @param _amount The new new minimum number of sUSD required to deposit
     */
    function setMinimumDepositAmount(uint _amount) external onlyOwner {
        // Do not allow us to set it less than 1 dollar opening up to fractional desposits in the queue again
        require(_amount > SafeDecimalMath.unit(), "Minimum deposit amount must be greater than UNIT");
        minimumDepositAmount = _amount;
        emit MinimumDepositAmountUpdated(minimumDepositAmount);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /**
     * @notice Fallback function (exchanges ETH to sUSD)
     */
    function() external payable {
        exchangeEtherForSynths();
    }

    /**
     * @notice Exchange ETH to sUSD.
     */
    function exchangeEtherForSynths()
        public
        payable
        nonReentrant
        rateNotStale(ETH)
        notPaused
        returns (
            uint // Returns the number of Synths (sUSD) received
        )
    {
        require(msg.value <= maxEthPurchase, "ETH amount above maxEthPurchase limit");
        uint ethToSend;

        // The multiplication works here because exchangeRates().rateForCurrency(ETH) is specified in
        // 18 decimal places, just like our currency base.
        uint requestedToPurchase = msg.value.multiplyDecimal(exchangeRates().rateForCurrency(ETH));
        uint remainingToFulfill = requestedToPurchase;

        // Iterate through our outstanding deposits and sell them one at a time.
        for (uint i = depositStartIndex; remainingToFulfill > 0 && i < depositEndIndex; i++) {
            synthDeposit memory deposit = deposits[i];

            // If it's an empty spot in the queue from a previous withdrawal, just skip over it and
            // update the queue. It's already been deleted.
            if (deposit.user == address(0)) {
                depositStartIndex = depositStartIndex.add(1);
            } else {
                // If the deposit can more than fill the order, we can do this
                // without touching the structure of our queue.
                if (deposit.amount > remainingToFulfill) {
                    // Ok, this deposit can fulfill the whole remainder. We don't need
                    // to change anything about our queue we can just fulfill it.
                    // Subtract the amount from our deposit and total.
                    uint newAmount = deposit.amount.sub(remainingToFulfill);
                    deposits[i] = synthDeposit({user: deposit.user, amount: newAmount});

                    totalSellableDeposits = totalSellableDeposits.sub(remainingToFulfill);

                    // Transfer the ETH to the depositor. Send is used instead of transfer
                    // so a non payable contract won't block the FIFO queue on a failed
                    // ETH payable for synths transaction. The proceeds to be sent to the
                    // synthetix foundation funds wallet. This is to protect all depositors
                    // in the queue in this rare case that may occur.
                    ethToSend = remainingToFulfill.divideDecimal(exchangeRates().rateForCurrency(ETH));

                    // We need to use send here instead of transfer because transfer reverts
                    // if the recipient is a non-payable contract. Send will just tell us it
                    // failed by returning false at which point we can continue.
                    // solium-disable-next-line security/no-send
                    if (!deposit.user.send(ethToSend)) {
                        fundsWallet.transfer(ethToSend);
                        emit NonPayableContract(deposit.user, ethToSend);
                    } else {
                        emit ClearedDeposit(msg.sender, deposit.user, ethToSend, remainingToFulfill, i);
                    }

                    // And the Synths to the recipient.
                    // Note: Fees are calculated by the Synth contract, so when
                    //       we request a specific transfer here, the fee is
                    //       automatically deducted and sent to the fee pool.
                    synthsUSD().transfer(msg.sender, remainingToFulfill);

                    // And we have nothing left to fulfill on this order.
                    remainingToFulfill = 0;
                } else if (deposit.amount <= remainingToFulfill) {
                    // We need to fulfill this one in its entirety and kick it out of the queue.
                    // Start by kicking it out of the queue.
                    // Free the storage because we can.
                    delete deposits[i];
                    // Bump our start index forward one.
                    depositStartIndex = depositStartIndex.add(1);
                    // We also need to tell our total it's decreased
                    totalSellableDeposits = totalSellableDeposits.sub(deposit.amount);

                    // Now fulfill by transfering the ETH to the depositor. Send is used instead of transfer
                    // so a non payable contract won't block the FIFO queue on a failed
                    // ETH payable for synths transaction. The proceeds to be sent to the
                    // synthetix foundation funds wallet. This is to protect all depositors
                    // in the queue in this rare case that may occur.
                    ethToSend = deposit.amount.divideDecimal(exchangeRates().rateForCurrency(ETH));

                    // We need to use send here instead of transfer because transfer reverts
                    // if the recipient is a non-payable contract. Send will just tell us it
                    // failed by returning false at which point we can continue.
                    // solium-disable-next-line security/no-send
                    if (!deposit.user.send(ethToSend)) {
                        fundsWallet.transfer(ethToSend);
                        emit NonPayableContract(deposit.user, ethToSend);
                    } else {
                        emit ClearedDeposit(msg.sender, deposit.user, ethToSend, deposit.amount, i);
                    }

                    // And the Synths to the recipient.
                    // Note: Fees are calculated by the Synth contract, so when
                    //       we request a specific transfer here, the fee is
                    //       automatically deducted and sent to the fee pool.
                    synthsUSD().transfer(msg.sender, deposit.amount);

                    // And subtract the order from our outstanding amount remaining
                    // for the next iteration of the loop.
                    remainingToFulfill = remainingToFulfill.sub(deposit.amount);
                }
            }
        }

        // Ok, if we're here and 'remainingToFulfill' isn't zero, then
        // we need to refund the remainder of their ETH back to them.
        if (remainingToFulfill > 0) {
            msg.sender.transfer(remainingToFulfill.divideDecimal(exchangeRates().rateForCurrency(ETH)));
        }

        // How many did we actually give them?
        uint fulfilled = requestedToPurchase.sub(remainingToFulfill);

        if (fulfilled > 0) {
            // Now tell everyone that we gave them that many (only if the amount is greater than 0).
            emit Exchange("ETH", msg.value, "sUSD", fulfilled);
        }

        return fulfilled;
    }

    /**
     * @notice Exchange ETH to sUSD while insisting on a particular rate. This allows a user to
     *         exchange while protecting against frontrunning by the contract owner on the exchange rate.
     * @param guaranteedRate The exchange rate (ether price) which must be honored or the call will revert.
     */
    function exchangeEtherForSynthsAtRate(uint guaranteedRate)
        public
        payable
        rateNotStale(ETH)
        notPaused
        returns (
            uint // Returns the number of Synths (sUSD) received
        )
    {
        require(guaranteedRate == exchangeRates().rateForCurrency(ETH), "Guaranteed rate would not be received");

        return exchangeEtherForSynths();
    }

    /**
     * @notice Exchange ETH to SNX.
     */
    function exchangeEtherForSNX()
        public
        payable
        rateNotStale(SNX)
        rateNotStale(ETH)
        notPaused
        returns (
            uint // Returns the number of SNX received
        )
    {
        // How many SNX are they going to be receiving?
        uint synthetixToSend = synthetixReceivedForEther(msg.value);

        // Store the ETH in our funds wallet
        fundsWallet.transfer(msg.value);

        // And send them the SNX.
        synthetix().transfer(msg.sender, synthetixToSend);

        emit Exchange("ETH", msg.value, "SNX", synthetixToSend);

        return synthetixToSend;
    }

    /**
     * @notice Exchange ETH to SNX while insisting on a particular set of rates. This allows a user to
     *         exchange while protecting against frontrunning by the contract owner on the exchange rates.
     * @param guaranteedEtherRate The ether exchange rate which must be honored or the call will revert.
     * @param guaranteedSynthetixRate The synthetix exchange rate which must be honored or the call will revert.
     */
    function exchangeEtherForSNXAtRate(uint guaranteedEtherRate, uint guaranteedSynthetixRate)
        public
        payable
        rateNotStale(SNX)
        rateNotStale(ETH)
        notPaused
        returns (
            uint // Returns the number of SNX received
        )
    {
        require(guaranteedEtherRate == exchangeRates().rateForCurrency(ETH), "Guaranteed ether rate would not be received");
        require(
            guaranteedSynthetixRate == exchangeRates().rateForCurrency(SNX),
            "Guaranteed synthetix rate would not be received"
        );

        return exchangeEtherForSNX();
    }

    /**
     * @notice Exchange sUSD for SNX
     * @param synthAmount The amount of synths the user wishes to exchange.
     */
    function exchangeSynthsForSNX(uint synthAmount)
        public
        rateNotStale(SNX)
        notPaused
        returns (
            uint // Returns the number of SNX received
        )
    {
        // How many SNX are they going to be receiving?
        uint synthetixToSend = synthetixReceivedForSynths(synthAmount);

        // Ok, transfer the Synths to our funds wallet.
        // These do not go in the deposit queue as they aren't for sale as such unless
        // they're sent back in from the funds wallet.
        synthsUSD().transferFrom(msg.sender, fundsWallet, synthAmount);

        // And send them the SNX.
        synthetix().transfer(msg.sender, synthetixToSend);

        emit Exchange("sUSD", synthAmount, "SNX", synthetixToSend);

        return synthetixToSend;
    }

    /**
     * @notice Exchange sUSD for SNX while insisting on a particular rate. This allows a user to
     *         exchange while protecting against frontrunning by the contract owner on the exchange rate.
     * @param synthAmount The amount of synths the user wishes to exchange.
     * @param guaranteedRate A rate (synthetix price) the caller wishes to insist upon.
     */
    function exchangeSynthsForSNXAtRate(uint synthAmount, uint guaranteedRate)
        public
        rateNotStale(SNX)
        notPaused
        returns (
            uint // Returns the number of SNX received
        )
    {
        require(guaranteedRate == exchangeRates().rateForCurrency(SNX), "Guaranteed rate would not be received");

        return exchangeSynthsForSNX(synthAmount);
    }

    /**
     * @notice Allows the owner to withdraw SNX from this contract if needed.
     * @param amount The amount of SNX to attempt to withdraw (in 18 decimal places).
     */
    function withdrawSynthetix(uint amount) external onlyOwner {
        synthetix().transfer(owner, amount);

        // We don't emit our own events here because we assume that anyone
        // who wants to watch what the Depot is doing can
        // just watch ERC20 events from the Synth and/or Synthetix contracts
        // filtered to our address.
    }

    /**
     * @notice Allows a user to withdraw all of their previously deposited synths from this contract if needed.
     *         Developer note: We could keep an index of address to deposits to make this operation more efficient
     *         but then all the other operations on the queue become less efficient. It's expected that this
     *         function will be very rarely used, so placing the inefficiency here is intentional. The usual
     *         use case does not involve a withdrawal.
     */
    function withdrawMyDepositedSynths() external {
        uint synthsToSend = 0;

        for (uint i = depositStartIndex; i < depositEndIndex; i++) {
            synthDeposit memory deposit = deposits[i];

            if (deposit.user == msg.sender) {
                // The user is withdrawing this deposit. Remove it from our queue.
                // We'll just leave a gap, which the purchasing logic can walk past.
                synthsToSend = synthsToSend.add(deposit.amount);
                delete deposits[i];
                //Let the DApps know we've removed this deposit
                emit SynthDepositRemoved(deposit.user, deposit.amount, i);
            }
        }

        // Update our total
        totalSellableDeposits = totalSellableDeposits.sub(synthsToSend);

        // Check if the user has tried to send deposit amounts < the minimumDepositAmount to the FIFO
        // queue which would have been added to this mapping for withdrawal only
        synthsToSend = synthsToSend.add(smallDeposits[msg.sender]);
        smallDeposits[msg.sender] = 0;

        // If there's nothing to do then go ahead and revert the transaction
        require(synthsToSend > 0, "You have no deposits to withdraw.");

        // Send their deposits back to them (minus fees)
        synthsUSD().transfer(msg.sender, synthsToSend);

        emit SynthWithdrawal(msg.sender, synthsToSend);
    }

    /**
     * @notice depositSynths: Allows users to deposit synths via the approve / transferFrom workflow
     * @param amount The amount of sUSD you wish to deposit (must have been approved first)
     */
    function depositSynths(uint amount) external {
        // Grab the amount of synths. Will fail if not approved first
        synthsUSD().transferFrom(msg.sender, this, amount);

        // A minimum deposit amount is designed to protect purchasers from over paying
        // gas for fullfilling multiple small synth deposits
        if (amount < minimumDepositAmount) {
            // We cant fail/revert the transaction or send the synths back in a reentrant call.
            // So we will keep your synths balance seperate from the FIFO queue so you can withdraw them
            smallDeposits[msg.sender] = smallDeposits[msg.sender].add(amount);

            emit SynthDepositNotAccepted(msg.sender, amount, minimumDepositAmount);
        } else {
            // Ok, thanks for the deposit, let's queue it up.
            deposits[depositEndIndex] = synthDeposit({user: msg.sender, amount: amount});
            emit SynthDeposit(msg.sender, amount, depositEndIndex);

            // Walk our index forward as well.
            depositEndIndex = depositEndIndex.add(1);

            // And add it to our total.
            totalSellableDeposits = totalSellableDeposits.add(amount);
        }
    }

    /* ========== VIEWS ========== */

    /**
     * @notice Calculate how many SNX you will receive if you transfer
     *         an amount of synths.
     * @param amount The amount of synths (in 18 decimal places) you want to ask about
     */
    function synthetixReceivedForSynths(uint amount) public view returns (uint) {
        // And what would that be worth in SNX based on the current price?
        return amount.divideDecimal(exchangeRates().rateForCurrency(SNX));
    }

    /**
     * @notice Calculate how many SNX you will receive if you transfer
     *         an amount of ether.
     * @param amount The amount of ether (in wei) you want to ask about
     */
    function synthetixReceivedForEther(uint amount) public view returns (uint) {
        // How much is the ETH they sent us worth in sUSD (ignoring the transfer fee)?
        uint valueSentInSynths = amount.multiplyDecimal(exchangeRates().rateForCurrency(ETH));

        // Now, how many SNX will that USD amount buy?
        return synthetixReceivedForSynths(valueSentInSynths);
    }

    /**
     * @notice Calculate how many synths you will receive if you transfer
     *         an amount of ether.
     * @param amount The amount of ether (in wei) you want to ask about
     */
    function synthsReceivedForEther(uint amount) public view returns (uint) {
        // How many synths would that amount of ether be worth?
        return amount.multiplyDecimal(exchangeRates().rateForCurrency(ETH));
    }

    /* ========== INTERNAL VIEWS ========== */

    function synthsUSD() internal view returns (ISynth) {
        return ISynth(resolver.requireAndGetAddress("SynthsUSD", "Missing SynthsUSD address"));
    }

    function synthetix() internal view returns (IERC20) {
        return IERC20(resolver.requireAndGetAddress("Synthetix", "Missing Synthetix address"));
    }

    function exchangeRates() internal view returns (IExchangeRates) {
        return IExchangeRates(resolver.requireAndGetAddress("ExchangeRates", "Missing ExchangeRates address"));
    }

    // ========== MODIFIERS ==========

    modifier rateNotStale(bytes32 currencyKey) {
        require(!exchangeRates().rateIsStale(currencyKey), "Rate stale or not a synth");
        _;
    }

    /* ========== EVENTS ========== */

    event MaxEthPurchaseUpdated(uint amount);
    event FundsWalletUpdated(address newFundsWallet);
    event Exchange(string fromCurrency, uint fromAmount, string toCurrency, uint toAmount);
    event SynthWithdrawal(address user, uint amount);
    event SynthDeposit(address indexed user, uint amount, uint indexed depositIndex);
    event SynthDepositRemoved(address indexed user, uint amount, uint indexed depositIndex);
    event SynthDepositNotAccepted(address user, uint amount, uint minimum);
    event MinimumDepositAmountUpdated(uint amount);
    event NonPayableContract(address indexed receiver, uint amount);
    event ClearedDeposit(
        address indexed fromAddress,
        address indexed toAddress,
        uint fromETHAmount,
        uint toAmount,
        uint indexed depositIndex
    );
}