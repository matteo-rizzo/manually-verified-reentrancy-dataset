pragma solidity ^0.4.13;


/**
 * Math operations with safety checks
 */



/*
 * Ownable
 *
 * Base contract with an owner.
 *
 * Provides onlyOwner modifier, which prevents function from running
 * if it is called by anyone other than the owner.
 */



/*
 * Haltable
 *
 * Abstract contract that allows children to implement a halt mechanism.
 */
contract Haltable is Ownable {

  bool public halted;

  modifier revertIfHalted {
    if (halted) revert();
    _;
  }

  modifier onlyIfHalted {
    if (!halted) revert();
    _;
  }

  function halt() external onlyOwner {
    halted = true;
  }

  function unhalt() external onlyOwner onlyIfHalted {
    halted = false;
  }
}


/**
 * Forward ETH payments associated with the Provide (PRVD)
 * token sale and track them with an event.
 *
 * Associates purchasers who made payment for token issuance with an identifier.
 * Enables the ability to make a purchase on behalf of another address.
 *
 * Allows the sale to be halted upon completion.
 */
contract ProvideSale is Haltable {
  using SafeMath for uint;

  /** Multisig to which all ETH is forwarded. */
  address public multisig;

  /** Total ETH raised (in wei). */
  uint public totalTransferred;

  /** Total number of distinct purchasers. */
  uint public purchaserCount;

  /** Total incoming ETH (in wei) per centrally tracked purchaser. */
  mapping (uint128 => uint) public paymentsByPurchaser;

  /** Total incoming ETH (in wei) per benefactor address. */
  mapping (address => uint) public paymentsByBenefactor;

  /** Emitted when a purchase is made; benefactor is the address where the tokens will be ultimately issued. */
  event PaymentForwarded(address source, uint amount, uint128 identifier, address benefactor);

  /**
   * @param _owner Owner is able to pause and resume crowdsale
   * @param _multisig Multisig to which all ETH is forwarded
   */
  function ProvideSale(address _owner, address _multisig) {
    owner = _owner;
    multisig = _multisig;
  }

  /**
   * Purchase on a behalf of a benefactor.
   *
   * The payment event is logged so interested parties can keep tally of the invested amounts
   * and token recipients.
   *
   * The actual payment is forwarded to the multisig.
   *
   * @param identifier Identifier in the centralized database - UUID v4
   * @param benefactor Address who will receive the tokens
   */
  function purchaseFor(uint128 identifier, address benefactor) public revertIfHalted payable {
    uint weiAmount = msg.value;

    if (weiAmount == 0) {
      revert(); // no invalid payments
    }

    if (benefactor == 0) {
      revert(); // bad payment address
    }

    PaymentForwarded(msg.sender, weiAmount, identifier, benefactor);

    totalTransferred = totalTransferred.add(weiAmount);

    if (paymentsByPurchaser[identifier] == 0) {
      purchaserCount++;
    }

    paymentsByPurchaser[identifier] = paymentsByPurchaser[identifier].add(weiAmount);
    paymentsByBenefactor[benefactor] = paymentsByBenefactor[benefactor].add(weiAmount);

    if (!multisig.send(weiAmount)) revert(); // may run out of gas
  }

  /**
   * Purchase on a behalf of the sender.
   *
   * @param identifier Identifier of the purchaser - UUID v4
   */
  function purchase(uint128 identifier) public payable {
    purchaseFor(identifier, msg.sender);
  }

  /**
   * Purchase on a behalf of the sender, but uses a nil identifier.
   */
  function() public payable {
    purchase(0);
  }
}