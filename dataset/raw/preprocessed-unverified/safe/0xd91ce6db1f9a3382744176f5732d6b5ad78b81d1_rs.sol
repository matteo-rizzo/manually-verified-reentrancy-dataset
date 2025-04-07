/**
 *Submitted for verification at Etherscan.io on 2020-01-09
*/

pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;
// File: @airswap/types/contracts/Types.sol
/*
  Copyright 2019 Swap Holdings Ltd.
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
/**
  * @title Types: Library of Swap Protocol Types and Hashes
  */

// File: @airswap/delegate/contracts/interfaces/IDelegate.sol
/*
  Copyright 2019 Swap Holdings Ltd.
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

// File: @airswap/indexer/contracts/interfaces/IIndexer.sol
/*
  Copyright 2019 Swap Holdings Ltd.
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

// File: @airswap/swap/contracts/interfaces/ISwap.sol
/*
  Copyright 2019 Swap Holdings Ltd.
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

// File: openzeppelin-solidity/contracts/GSN/Context.sol
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
// File: openzeppelin-solidity/contracts/ownership/Ownable.sol
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
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
// File: openzeppelin-solidity/contracts/math/SafeMath.sol
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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */

// File: @airswap/delegate/contracts/Delegate.sol
/*
  Copyright 2019 Swap Holdings Ltd.
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
/**
  * @title Delegate: Deployable Trading Rules for the AirSwap Network
  * @notice Supports fungible tokens (ERC-20)
  * @dev inherits IDelegate, Ownable uses SafeMath library
  */
contract Delegate is IDelegate, Ownable {
  using SafeMath for uint256;
  // The Swap contract to be used to settle trades
  ISwap public swapContract;
  // The Indexer to stake intent to trade on
  IIndexer public indexer;
  // Maximum integer for token transfer approval
  uint256 constant internal MAX_INT =  2**256 - 1;
  // Address holding tokens that will be trading through this delegate
  address public tradeWallet;
  // Mapping of senderToken to signerToken for rule lookup
  mapping (address => mapping (address => Rule)) public rules;
  // ERC-20 (fungible token) interface identifier (ERC-165)
  bytes4 constant internal ERC20_INTERFACE_ID = 0x36372b07;
  // The protocol identifier for setting intents on an Index
  bytes2 public protocol;
  /**
    * @notice Contract Constructor
    * @dev owner defaults to msg.sender if delegateContractOwner is provided as address(0)
    * @param delegateSwap address Swap contract the delegate will deploy with
    * @param delegateIndexer address Indexer contract the delegate will deploy with
    * @param delegateContractOwner address Owner of the delegate
    * @param delegateTradeWallet address Wallet the delegate will trade from
    * @param delegateProtocol bytes2 The protocol identifier for Delegate contracts
    */
  constructor(
    ISwap delegateSwap,
    IIndexer delegateIndexer,
    address delegateContractOwner,
    address delegateTradeWallet,
    bytes2 delegateProtocol
  ) public {
    swapContract = delegateSwap;
    indexer = delegateIndexer;
    protocol = delegateProtocol;
    // If no delegate owner is provided, the deploying address is the owner.
    if (delegateContractOwner != address(0)) {
      transferOwnership(delegateContractOwner);
    }
    // If no trade wallet is provided, the owner's wallet is the trade wallet.
    if (delegateTradeWallet != address(0)) {
      tradeWallet = delegateTradeWallet;
    } else {
      tradeWallet = owner();
    }
    // Ensure that the indexer can pull funds from delegate account.
    require(
      IERC20(indexer.stakingToken())
      .approve(address(indexer), MAX_INT), "STAKING_APPROVAL_FAILED"
    );
  }
  /**
    * @notice Set a Trading Rule
    * @dev only callable by the owner of the contract
    * @dev 1 senderToken = priceCoef * 10^(-priceExp) * signerToken
    * @param senderToken address Address of an ERC-20 token the delegate would send
    * @param signerToken address Address of an ERC-20 token the consumer would send
    * @param maxSenderAmount uint256 Maximum amount of ERC-20 token the delegate would send
    * @param priceCoef uint256 Whole number that will be multiplied by 10^(-priceExp) - the price coefficient
    * @param priceExp uint256 Exponent of the price to indicate location of the decimal priceCoef * 10^(-priceExp)
    */
  function setRule(
    address senderToken,
    address signerToken,
    uint256 maxSenderAmount,
    uint256 priceCoef,
    uint256 priceExp
  ) external onlyOwner {
    _setRule(
      senderToken,
      signerToken,
      maxSenderAmount,
      priceCoef,
      priceExp
    );
  }
  /**
    * @notice Unset a Trading Rule
    * @dev only callable by the owner of the contract, removes from a mapping
    * @param senderToken address Address of an ERC-20 token the delegate would send
    * @param signerToken address Address of an ERC-20 token the consumer would send
    */
  function unsetRule(
    address senderToken,
    address signerToken
  ) external onlyOwner {
    _unsetRule(
      senderToken,
      signerToken
    );
  }
  /**
    * @notice sets a rule on the delegate and an intent on the indexer
    * @dev only callable by owner
    * @dev delegate needs to be given allowance from msg.sender for the newStakeAmount
    * @dev swap needs to be given permission to move funds from the delegate
    * @param senderToken address Token the delgeate will send
    * @param signerToken address Token the delegate will receive
    * @param rule Rule Rule to set on a delegate
    * @param newStakeAmount uint256 Amount to stake for an intent
    */
  function setRuleAndIntent(
    address senderToken,
    address signerToken,
    Rule calldata rule,
    uint256 newStakeAmount
  ) external onlyOwner {
    _setRule(
      senderToken,
      signerToken,
      rule.maxSenderAmount,
      rule.priceCoef,
      rule.priceExp
    );
    // get currentAmount staked or 0 if never staked
    uint256 oldStakeAmount = indexer.getStakedAmount(address(this), signerToken, senderToken, protocol);
    if (oldStakeAmount == newStakeAmount && oldStakeAmount > 0) {
      return; // forgo trying to reset intent with non-zero same stake amount
    } else if (oldStakeAmount < newStakeAmount) {
      // transfer only the difference from the sender to the Delegate.
      require(
        IERC20(indexer.stakingToken())
        .transferFrom(msg.sender, address(this), newStakeAmount - oldStakeAmount), "STAKING_TRANSFER_FAILED"
      );
    }
    indexer.setIntent(
      signerToken,
      senderToken,
      protocol,
      newStakeAmount,
      bytes32(uint256(address(this)) << 96) //NOTE: this will pad 0's to the right
    );
    if (oldStakeAmount > newStakeAmount) {
      // return excess stake back
      require(
        IERC20(indexer.stakingToken())
        .transfer(msg.sender, oldStakeAmount - newStakeAmount), "STAKING_RETURN_FAILED"
      );
    }
  }
  /**
    * @notice unsets a rule on the delegate and removes an intent on the indexer
    * @dev only callable by owner
    * @param senderToken address Maker token in the token pair for rules and intents
    * @param signerToken address Taker token  in the token pair for rules and intents
    */
  function unsetRuleAndIntent(
    address senderToken,
    address signerToken
  ) external onlyOwner {
    _unsetRule(senderToken, signerToken);
    // Query the indexer for the amount staked.
    uint256 stakedAmount = indexer.getStakedAmount(address(this), signerToken, senderToken, protocol);
    indexer.unsetIntent(signerToken, senderToken, protocol);
    // Upon unstaking, the Delegate will be given the staking amount.
    // This is returned to the msg.sender.
    if (stakedAmount > 0) {
      require(
        IERC20(indexer.stakingToken())
          .transfer(msg.sender, stakedAmount),"STAKING_RETURN_FAILED"
      );
    }
  }
  /**
    * @notice Provide an Order
    * @dev Rules get reset with new maxSenderAmount
    * @param order Types.Order Order a user wants to submit to Swap.
    */
  function provideOrder(
    Types.Order calldata order
  ) external {
    Rule memory rule = rules[order.sender.token][order.signer.token];
    require(order.signature.v != 0,
      "SIGNATURE_MUST_BE_SENT");
    // Ensure the order is for the trade wallet.
    require(order.sender.wallet == tradeWallet,
      "INVALID_SENDER_WALLET");
    // Ensure the tokens are valid ERC20 tokens.
    require(order.signer.kind == ERC20_INTERFACE_ID,
      "SIGNER_KIND_MUST_BE_ERC20");
    require(order.sender.kind == ERC20_INTERFACE_ID,
      "SENDER_KIND_MUST_BE_ERC20");
    // Ensure that a rule exists.
    require(rule.maxSenderAmount != 0,
      "TOKEN_PAIR_INACTIVE");
    // Ensure the order does not exceed the maximum amount.
    require(order.sender.amount <= rule.maxSenderAmount,
      "AMOUNT_EXCEEDS_MAX");
    // Ensure the order is priced according to the rule.
    require(order.sender.amount <= _calculateSenderAmount(order.signer.amount, rule.priceCoef, rule.priceExp),
      "PRICE_INVALID");
    // Overwrite the rule with a decremented maxSenderAmount.
    rules[order.sender.token][order.signer.token] = Rule({
      maxSenderAmount: (rule.maxSenderAmount).sub(order.sender.amount),
      priceCoef: rule.priceCoef,
      priceExp: rule.priceExp
    });
    // Perform the swap.
    swapContract.swap(order);
    emit ProvideOrder(
      owner(),
      tradeWallet,
      order.sender.token,
      order.signer.token,
      order.sender.amount,
      rule.priceCoef,
      rule.priceExp
    );
  }
  /**
    * @notice Set a new trade wallet
    * @param newTradeWallet address Address of the new trade wallet
    */
  function setTradeWallet(address newTradeWallet) external onlyOwner {
    require(newTradeWallet != address(0), "TRADE_WALLET_REQUIRED");
    tradeWallet = newTradeWallet;
  }
  /**
    * @notice Get a Signer-Side Quote from the Delegate
    * @param senderAmount uint256 Amount of ERC-20 token the delegate would send
    * @param senderToken address Address of an ERC-20 token the delegate would send
    * @param signerToken address Address of an ERC-20 token the consumer would send
    * @return uint256 signerAmount Amount of ERC-20 token the consumer would send
    */
  function getSignerSideQuote(
    uint256 senderAmount,
    address senderToken,
    address signerToken
  ) external view returns (
    uint256 signerAmount
  ) {
    Rule memory rule = rules[senderToken][signerToken];
    // Ensure that a rule exists.
    if(rule.maxSenderAmount > 0) {
      // Ensure the senderAmount does not exceed maximum for the rule.
      if(senderAmount <= rule.maxSenderAmount) {
        signerAmount = _calculateSignerAmount(senderAmount, rule.priceCoef, rule.priceExp);
        // Return the quote.
        return signerAmount;
      }
    }
    return 0;
  }
  /**
    * @notice Get a Sender-Side Quote from the Delegate
    * @param signerAmount uint256 Amount of ERC-20 token the consumer would send
    * @param signerToken address Address of an ERC-20 token the consumer would send
    * @param senderToken address Address of an ERC-20 token the delegate would send
    * @return uint256 senderAmount Amount of ERC-20 token the delegate would send
    */
  function getSenderSideQuote(
    uint256 signerAmount,
    address signerToken,
    address senderToken
  ) external view returns (
    uint256 senderAmount
  ) {
    Rule memory rule = rules[senderToken][signerToken];
    // Ensure that a rule exists.
    if(rule.maxSenderAmount > 0) {
      // Calculate the senderAmount.
      senderAmount = _calculateSenderAmount(signerAmount, rule.priceCoef, rule.priceExp);
      // Ensure the senderAmount does not exceed the maximum trade amount.
      if(senderAmount <= rule.maxSenderAmount) {
        return senderAmount;
      }
    }
    return 0;
  }
  /**
    * @notice Get a Maximum Quote from the Delegate
    * @param senderToken address Address of an ERC-20 token the delegate would send
    * @param signerToken address Address of an ERC-20 token the consumer would send
    * @return uint256 senderAmount Amount the delegate would send
    * @return uint256 signerAmount Amount the consumer would send
    */
  function getMaxQuote(
    address senderToken,
    address signerToken
  ) external view returns (
    uint256 senderAmount,
    uint256 signerAmount
  ) {
    Rule memory rule = rules[senderToken][signerToken];
    senderAmount = rule.maxSenderAmount;
    // Ensure that a rule exists.
    if (senderAmount > 0) {
      // calculate the signerAmount
      signerAmount = _calculateSignerAmount(senderAmount, rule.priceCoef, rule.priceExp);
      // Return the maxSenderAmount and calculated signerAmount.
      return (
        senderAmount,
        signerAmount
      );
    }
    return (0, 0);
  }
  /**
    * @notice Set a Trading Rule
    * @dev only callable by the owner of the contract
    * @dev 1 senderToken = priceCoef * 10^(-priceExp) * signerToken
    * @param senderToken address Address of an ERC-20 token the delegate would send
    * @param signerToken address Address of an ERC-20 token the consumer would send
    * @param maxSenderAmount uint256 Maximum amount of ERC-20 token the delegate would send
    * @param priceCoef uint256 Whole number that will be multiplied by 10^(-priceExp) - the price coefficient
    * @param priceExp uint256 Exponent of the price to indicate location of the decimal priceCoef * 10^(-priceExp)
    */
  function _setRule(
    address senderToken,
    address signerToken,
    uint256 maxSenderAmount,
    uint256 priceCoef,
    uint256 priceExp
  ) internal {
    require(priceCoef > 0, "INVALID_PRICE_COEF");
    rules[senderToken][signerToken] = Rule({
      maxSenderAmount: maxSenderAmount,
      priceCoef: priceCoef,
      priceExp: priceExp
    });
    emit SetRule(
      owner(),
      senderToken,
      signerToken,
      maxSenderAmount,
      priceCoef,
      priceExp
    );
  }
  /**
    * @notice Unset a Trading Rule
    * @param senderToken address Address of an ERC-20 token the delegate would send
    * @param signerToken address Address of an ERC-20 token the consumer would send
    */
  function _unsetRule(
    address senderToken,
    address signerToken
  ) internal {
    // using non-zero rule.priceCoef for rule existence check
    if (rules[senderToken][signerToken].priceCoef > 0) {
      // Delete the rule.
      delete rules[senderToken][signerToken];
      emit UnsetRule(
        owner(),
        senderToken,
        signerToken
    );
    }
  }
  /**
    * @notice Calculate the signer amount for a given sender amount and price
    * @param senderAmount uint256 The amount the delegate would send in the swap
    * @param priceCoef uint256 Coefficient of the token price defined in the rule
    * @param priceExp uint256 Exponent of the token price defined in the rule
    */
  function _calculateSignerAmount(
    uint256 senderAmount,
    uint256 priceCoef,
    uint256 priceExp
  ) internal pure returns (
    uint256 signerAmount
  ) {
    // Calculate the signer amount using the price formula
    uint256 multiplier = senderAmount.mul(priceCoef);
    signerAmount = multiplier.div(10 ** priceExp);
    // If the div rounded down, round up
    if (multiplier.mod(10 ** priceExp) > 0) {
      signerAmount++;
    }
  }
  /**
    * @notice Calculate the sender amount for a given signer amount and price
    * @param signerAmount uint256 The amount the signer would send in the swap
    * @param priceCoef uint256 Coefficient of the token price defined in the rule
    * @param priceExp uint256 Exponent of the token price defined in the rule
    */
  function _calculateSenderAmount(
    uint256 signerAmount,
    uint256 priceCoef,
    uint256 priceExp
  ) internal pure returns (
    uint256 senderAmount
  ) {
    // Calculate the sender anount using the price formula
    senderAmount = signerAmount
      .mul(10 ** priceExp)
      .div(priceCoef);
  }
}
// File: @airswap/delegate/contracts/interfaces/IDelegateFactory.sol
/*
  Copyright 2019 Swap Holdings Ltd.
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

// File: @airswap/indexer/contracts/interfaces/ILocatorWhitelist.sol
/*
  Copyright 2019 Swap Holdings Ltd.
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

// File: @airswap/delegate/contracts/DelegateFactory.sol
/*
  Copyright 2019 Swap Holdings Ltd.
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
contract DelegateFactory is IDelegateFactory, ILocatorWhitelist {
  // Mapping specifying whether an address was deployed by this factory
  mapping(address => bool) internal _deployedAddresses;
  // The swap and indexer contracts to use in the deployment of Delegates
  ISwap public swapContract;
  IIndexer public indexerContract;
  bytes2 public protocol;
  /**
    * @notice Create a new Delegate contract
    * @dev swapContract is unable to be changed after the factory sets it
    * @param factorySwapContract address Swap contract the delegate will deploy with
    * @param factoryIndexerContract address Indexer contract the delegate will deploy with
    * @param factoryProtocol bytes2 Protocol type of the delegates the factory deploys
    */
  constructor(
    ISwap factorySwapContract,
    IIndexer factoryIndexerContract,
    bytes2 factoryProtocol
  ) public {
    swapContract = factorySwapContract;
    indexerContract = factoryIndexerContract;
    protocol = factoryProtocol;
  }
  /**
    * @param delegateTradeWallet address Wallet the delegate will trade from
    * @return address delegateContractAddress Address of the delegate contract created
    */
  function createDelegate(
    address delegateTradeWallet
  ) external returns (address delegateContractAddress) {
    delegateContractAddress = address(
      new Delegate(swapContract, indexerContract, msg.sender, delegateTradeWallet, protocol)
    );
    _deployedAddresses[delegateContractAddress] = true;
    emit CreateDelegate(
      delegateContractAddress,
      address(swapContract),
      address(indexerContract),
      msg.sender,
      delegateTradeWallet
    );
    return delegateContractAddress;
  }
  /**
    * @notice To check whether a locator was deployed
    * @dev Implements ILocatorWhitelist.has
    * @param locator bytes32 Locator of the delegate in question
    * @return bool True if the delegate was deployed by this contract
    */
  function has(bytes32 locator) external view returns (bool) {
    return _deployedAddresses[address(bytes20(locator))];
  }
}
// File: @airswap/indexer/contracts/Index.sol
/*
  Copyright 2019 Swap Holdings Ltd.
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
/**
  * @title Index: A List of Locators
  * @notice The Locators are sorted in reverse order based on the score
  * meaning that the first element in the list has the largest score
  * and final element has the smallest
  * @dev A mapping is used to mimic a circular linked list structure
  * where every mapping Entry contains a pointer to the next
  * and the previous
  */
contract Index is Ownable {
  // The number of entries in the index
  uint256 public length;
  // Identifier to use for the head of the list
  address constant internal HEAD = address(uint160(2**160-1));
  // Mapping of an identifier to its entry
  mapping(address => Entry) public entries;
  /**
    * @notice Index Entry
    * @param score uint256
    * @param locator bytes32
    * @param prev address Previous address in the linked list
    * @param next address Next address in the linked list
    */
  struct Entry {
    bytes32 locator;
    uint256 score;
    address prev;
    address next;
  }
  /**
    * @notice Contract Events
    */
  event SetLocator(
    address indexed identifier,
    uint256 score,
    bytes32 indexed locator
  );
  event UnsetLocator(
    address indexed identifier
  );
  /**
    * @notice Contract Constructor
    */
  constructor() public {
    // Create initial entry.
    entries[HEAD] = Entry(bytes32(0), 0, HEAD, HEAD);
  }
  /**
    * @notice Set a Locator
    * @param identifier address On-chain address identifying the owner of a locator
    * @param score uint256 Score for the locator being set
    * @param locator bytes32 Locator
    */
  function setLocator(
    address identifier,
    uint256 score,
    bytes32 locator
  ) external onlyOwner {
    // Ensure the entry does not already exist.
    require(!_hasEntry(identifier), "ENTRY_ALREADY_EXISTS");
    _setLocator(identifier, score, locator);
    // Increment the index length.
    length = length + 1;
    emit SetLocator(identifier, score, locator);
  }
  /**
    * @notice Unset a Locator
    * @param identifier address On-chain address identifying the owner of a locator
    */
  function unsetLocator(
    address identifier
  ) external onlyOwner {
    _unsetLocator(identifier);
    // Decrement the index length.
    length = length - 1;
    emit UnsetLocator(identifier);
  }
  /**
    * @notice Update a Locator
    * @dev score and/or locator do not need to be different from old values
    * @param identifier address On-chain address identifying the owner of a locator
    * @param score uint256 Score for the locator being set
    * @param locator bytes32 Locator
    */
  function updateLocator(
    address identifier,
    uint256 score,
    bytes32 locator
  ) external onlyOwner {
    // Don't need to update length as it is not used in set/unset logic
    _unsetLocator(identifier);
    _setLocator(identifier, score, locator);
    emit SetLocator(identifier, score, locator);
  }
  /**
    * @notice Get a Score
    * @param identifier address On-chain address identifying the owner of a locator
    * @return uint256 Score corresponding to the identifier
    */
  function getScore(
    address identifier
  ) external view returns (uint256) {
    return entries[identifier].score;
  }
    /**
    * @notice Get a Locator
    * @param identifier address On-chain address identifying the owner of a locator
    * @return bytes32 Locator information
    */
  function getLocator(
    address identifier
  ) external view returns (bytes32) {
    return entries[identifier].locator;
  }
  /**
    * @notice Get a Range of Locators
    * @dev start value of 0x0 starts at the head
    * @param cursor address Cursor to start with
    * @param limit uint256 Maximum number of locators to return
    * @return bytes32[] List of locators
    * @return uint256[] List of scores corresponding to locators
    * @return address The next cursor to provide for pagination
    */
  function getLocators(
    address cursor,
    uint256 limit
  ) external view returns (
    bytes32[] memory locators,
    uint256[] memory scores,
    address nextCursor
  ) {
    address identifier;
    // If a valid cursor is provided, start there.
    if (cursor != address(0) && cursor != HEAD) {
      // Check that the provided cursor exists.
      if (!_hasEntry(cursor)) {
        return (new bytes32[](0), new uint256[](0), address(0));
      }
      // Set the starting identifier to the provided cursor.
      identifier = cursor;
    } else {
      identifier = entries[HEAD].next;
    }
    // Although it's not known how many entries are between `cursor` and the end
    // We know that it is no more than `length`
    uint256 size = (length < limit) ? length : limit;
    locators = new bytes32[](size);
    scores = new uint256[](size);
    // Iterate over the list until the end or size.
    uint256 i;
    while (i < size && identifier != HEAD) {
      locators[i] = entries[identifier].locator;
      scores[i] = entries[identifier].score;
      i = i + 1;
      identifier = entries[identifier].next;
    }
    return (locators, scores, identifier);
  }
  /**
    * @notice Internal function to set a Locator
    * @param identifier address On-chain address identifying the owner of a locator
    * @param score uint256 Score for the locator being set
    * @param locator bytes32 Locator
    */
  function _setLocator(
    address identifier,
    uint256 score,
    bytes32 locator
  ) internal {
    // Disallow locator set to 0x0 to ensure list integrity.
    require(locator != bytes32(0), "LOCATOR_MUST_BE_SENT");
    // Find the first entry with a lower score.
    address nextEntry = _getEntryLowerThan(score);
    // Link the new entry between previous and next.
    address prevEntry = entries[nextEntry].prev;
    entries[prevEntry].next = identifier;
    entries[nextEntry].prev = identifier;
    entries[identifier] = Entry(locator, score, prevEntry, nextEntry);
  }
  /**
    * @notice Internal function to unset a Locator
    * @param identifier address On-chain address identifying the owner of a locator
    */
  function _unsetLocator(
    address identifier
  ) internal {
    // Ensure the entry exists.
    require(_hasEntry(identifier), "ENTRY_DOES_NOT_EXIST");
    // Link the previous and next entries together.
    address prevUser = entries[identifier].prev;
    address nextUser = entries[identifier].next;
    entries[prevUser].next = nextUser;
    entries[nextUser].prev = prevUser;
    // Delete entry from the index.
    delete entries[identifier];
  }
  /**
    * @notice Check if the Index has an Entry
    * @param identifier address On-chain address identifying the owner of a locator
    * @return bool True if the identifier corresponds to an Entry in the list
    */
  function _hasEntry(
    address identifier
  ) internal view returns (bool) {
    return entries[identifier].locator != bytes32(0);
  }
  /**
    * @notice Returns the largest scoring Entry Lower than a Score
    * @param score uint256 Score in question
    * @return address Identifier of the largest score lower than score
    */
  function _getEntryLowerThan(
    uint256 score
  ) internal view returns (address) {
    address identifier = entries[HEAD].next;
    // Head indicates last because the list is circular.
    if (score == 0) {
      return HEAD;
    }
    // Iterate until a lower score is found.
    while (score <= entries[identifier].score) {
      identifier = entries[identifier].next;
    }
    return identifier;
  }
}
// File: @airswap/indexer/contracts/Indexer.sol
/*
  Copyright 2019 Swap Holdings Ltd.
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
/**
  * @title Indexer: A Collection of Index contracts by Token Pair
  */
contract Indexer is IIndexer, Ownable {
  // Token to be used for staking (ERC-20)
  IERC20 public stakingToken;
  // Mapping of signer token to sender token to protocol type to index
  mapping (address => mapping (address => mapping (bytes2 => Index))) public indexes;
  // The whitelist contract for checking whether a peer is whitelisted per peer type
  mapping (bytes2 => address) public locatorWhitelists;
  // Mapping of token address to boolean
  mapping (address => bool) public tokenBlacklist;
  /**
    * @notice Contract Constructor
    * @param indexerStakingToken address
    */
  constructor(
    address indexerStakingToken
  ) public {
    stakingToken = IERC20(indexerStakingToken);
  }
  /**
    * @notice Modifier to check an index exists
    */
  modifier indexExists(address signerToken, address senderToken, bytes2 protocol) {
    require(indexes[signerToken][senderToken][protocol] != Index(0),
      "INDEX_DOES_NOT_EXIST");
    _;
  }
  /**
    * @notice Set the address of an ILocatorWhitelist to use
    * @dev Allows removal of locatorWhitelist by passing 0x0
    * @param newLocatorWhitelist address Locator whitelist
    */
  function setLocatorWhitelist(
    bytes2 protocol,
    address newLocatorWhitelist
  ) external onlyOwner {
    locatorWhitelists[protocol] = newLocatorWhitelist;
  }
  /**
    * @notice Create an Index (List of Locators for a Token Pair)
    * @dev Deploys a new Index contract and stores the address. If the Index already
    * @dev exists, returns its address, and does not emit a CreateIndex event
    * @param signerToken address Signer token for the Index
    * @param senderToken address Sender token for the Index
    */
  function createIndex(
    address signerToken,
    address senderToken,
    bytes2 protocol
  ) external returns (address) {
    // If the Index does not exist, create it.
    if (indexes[signerToken][senderToken][protocol] == Index(0)) {
      // Create a new Index contract for the token pair.
      indexes[signerToken][senderToken][protocol] = new Index();
      emit CreateIndex(signerToken, senderToken, protocol, address(indexes[signerToken][senderToken][protocol]));
    }
    // Return the address of the Index contract.
    return address(indexes[signerToken][senderToken][protocol]);
  }
  /**
    * @notice Add a Token to the Blacklist
    * @param token address Token to blacklist
    */
  function addTokenToBlacklist(
    address token
  ) external onlyOwner {
    if (!tokenBlacklist[token]) {
      tokenBlacklist[token] = true;
      emit AddTokenToBlacklist(token);
    }
  }
  /**
    * @notice Remove a Token from the Blacklist
    * @param token address Token to remove from the blacklist
    */
  function removeTokenFromBlacklist(
    address token
  ) external onlyOwner {
    if (tokenBlacklist[token]) {
      tokenBlacklist[token] = false;
      emit RemoveTokenFromBlacklist(token);
    }
  }
  /**
    * @notice Set an Intent to Trade
    * @dev Requires approval to transfer staking token for sender
    *
    * @param signerToken address Signer token of the Index being staked
    * @param senderToken address Sender token of the Index being staked
    * @param stakingAmount uint256 Amount being staked
    * @param locator bytes32 Locator of the staker
    */
  function setIntent(
    address signerToken,
    address senderToken,
    bytes2 protocol,
    uint256 stakingAmount,
    bytes32 locator
  ) external indexExists(signerToken, senderToken, protocol) {
    // If whitelist set, ensure the locator is valid.
    if (locatorWhitelists[protocol] != address(0)) {
      require(ILocatorWhitelist(locatorWhitelists[protocol]).has(locator),
      "LOCATOR_NOT_WHITELISTED");
    }
    // Ensure neither of the tokens are blacklisted.
    require(!tokenBlacklist[signerToken] && !tokenBlacklist[senderToken],
      "PAIR_IS_BLACKLISTED");
    bool notPreviouslySet = (indexes[signerToken][senderToken][protocol].getLocator(msg.sender) == bytes32(0));
    if (notPreviouslySet) {
      // Only transfer for staking if stakingAmount is set.
      if (stakingAmount > 0) {
        // Transfer the stakingAmount for staking.
        require(stakingToken.transferFrom(msg.sender, address(this), stakingAmount),
          "UNABLE_TO_STAKE");
      }
      // Set the locator on the index.
      indexes[signerToken][senderToken][protocol].setLocator(msg.sender, stakingAmount, locator);
      emit Stake(msg.sender, signerToken, senderToken, protocol, stakingAmount);
    } else {
      uint256 oldStake = indexes[signerToken][senderToken][protocol].getScore(msg.sender);
      _updateIntent(msg.sender, signerToken, senderToken, protocol, stakingAmount, locator, oldStake);
    }
  }
  /**
    * @notice Unset an Intent to Trade
    * @dev Users are allowed to unstake from blacklisted indexes
    *
    * @param signerToken address Signer token of the Index being unstaked
    * @param senderToken address Sender token of the Index being staked
    */
  function unsetIntent(
    address signerToken,
    address senderToken,
    bytes2 protocol
  ) external {
    _unsetIntent(msg.sender, signerToken, senderToken, protocol);
  }
  /**
    * @notice Get the locators of those trading a token pair
    * @dev Users are allowed to unstake from blacklisted indexes
    *
    * @param signerToken address Signer token of the trading pair
    * @param senderToken address Sender token of the trading pair
    * @param cursor address Address to start from
    * @param limit uint256 Total number of locators to return
    * @return bytes32[] List of locators
    * @return uint256[] List of scores corresponding to locators
    * @return address The next cursor to provide for pagination
    */
  function getLocators(
    address signerToken,
    address senderToken,
    bytes2 protocol,
    address cursor,
    uint256 limit
  ) external view returns (
    bytes32[] memory locators,
    uint256[] memory scores,
    address nextCursor
  ) {
    // Ensure neither token is blacklisted.
    if (tokenBlacklist[signerToken] || tokenBlacklist[senderToken]) {
      return (new bytes32[](0), new uint256[](0), address(0));
    }
    // Ensure the index exists.
    if (indexes[signerToken][senderToken][protocol] == Index(0)) {
      return (new bytes32[](0), new uint256[](0), address(0));
    }
    return indexes[signerToken][senderToken][protocol].getLocators(cursor, limit);
  }
  /**
    * @notice Gets the Stake Amount for a User
    * @param user address User who staked
    * @param signerToken address Signer token the user staked on
    * @param senderToken address Sender token the user staked on
    * @return uint256 Amount the user staked
    */
  function getStakedAmount(
    address user,
    address signerToken,
    address senderToken,
    bytes2 protocol
  ) public view returns (uint256 stakedAmount) {
    if (indexes[signerToken][senderToken][protocol] == Index(0)) {
      return 0;
    }
    // Return the score, equivalent to the stake amount.
    return indexes[signerToken][senderToken][protocol].getScore(user);
  }
  function _updateIntent(
    address user,
    address signerToken,
    address senderToken,
    bytes2 protocol,
    uint256 newAmount,
    bytes32 newLocator,
    uint256 oldAmount
  ) internal {
    // If the new stake is bigger, collect the difference.
    if (oldAmount < newAmount) {
      // Note: SafeMath not required due to the inequality check above
      require(stakingToken.transferFrom(user, address(this), newAmount - oldAmount),
        "UNABLE_TO_STAKE");
    }
    // If the old stake is bigger, return the excess.
    if (newAmount < oldAmount) {
      // Note: SafeMath not required due to the inequality check above
      require(stakingToken.transfer(user, oldAmount - newAmount));
    }
    // Update their intent.
    indexes[signerToken][senderToken][protocol].updateLocator(user, newAmount, newLocator);
    emit Stake(user, signerToken, senderToken, protocol, newAmount);
  }
  /**
    * @notice Unset intents and return staked tokens
    * @param user address Address of the user who staked
    * @param signerToken address Signer token of the trading pair
    * @param senderToken address Sender token of the trading pair
    */
  function _unsetIntent(
    address user,
    address signerToken,
    address senderToken,
    bytes2 protocol
  ) internal indexExists(signerToken, senderToken, protocol) {
     // Get the score for the user.
    uint256 score = indexes[signerToken][senderToken][protocol].getScore(user);
    // Unset the locator on the index.
    indexes[signerToken][senderToken][protocol].unsetLocator(user);
    if (score > 0) {
      // Return the staked tokens. Reverts on failure.
      require(stakingToken.transfer(user, score));
    }
    emit Unstake(user, signerToken, senderToken, protocol, score);
  }
}
// File: openzeppelin-solidity/contracts/introspection/IERC165.sol
/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721.sol
/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);
    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}
// File: openzeppelin-solidity/contracts/utils/Address.sol
/**
 * @dev Collection of functions related to the address type
 */

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */

// File: @airswap/swap/contracts/Swap.sol
/*
  Copyright 2019 Swap Holdings Ltd.
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
/**
  * @title Swap: The Atomic Swap used on the AirSwap Network
  */
contract Swap is ISwap {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  // Domain and version for use in signatures (EIP-712)
  bytes constant internal DOMAIN_NAME = "SWAP";
  bytes constant internal DOMAIN_VERSION = "2";
  // Unique domain identifier for use in signatures (EIP-712)
  bytes32 private _domainSeparator;
  // Possible nonce statuses
  byte constant internal AVAILABLE = 0x00;
  byte constant internal UNAVAILABLE = 0x01;
  // ERC-721 (non-fungible token) interface identifier (EIP-165)
  bytes4 constant internal ERC721_INTERFACE_ID = 0x80ac58cd;
  // Mapping of sender address to a delegated sender address and bool
  mapping (address => mapping (address => bool)) public senderAuthorizations;
  // Mapping of signer address to a delegated signer and bool
  mapping (address => mapping (address => bool)) public signerAuthorizations;
  // Mapping of signers to nonces with value AVAILABLE (0x00) or UNAVAILABLE (0x01)
  mapping (address => mapping (uint256 => byte)) public signerNonceStatus;
  // Mapping of signer addresses to an optionally set minimum valid nonce
  mapping (address => uint256) public signerMinimumNonce;
  /**
    * @notice Contract Constructor
    * @dev Sets domain for signature validation (EIP-712)
    */
  constructor() public {
    _domainSeparator = Types.hashDomain(
      DOMAIN_NAME,
      DOMAIN_VERSION,
      address(this)
    );
  }
  /**
    * @notice Atomic Token Swap
    * @param order Types.Order Order to settle
    */
  function swap(
    Types.Order calldata order
  ) external {
    // Ensure the order is not expired.
    require(order.expiry > block.timestamp,
      "ORDER_EXPIRED");
    // Ensure the nonce is AVAILABLE (0x00).
    require(signerNonceStatus[order.signer.wallet][order.nonce] == AVAILABLE,
      "ORDER_TAKEN_OR_CANCELLED");
    // Ensure the order nonce is above the minimum.
    require(order.nonce >= signerMinimumNonce[order.signer.wallet],
      "NONCE_TOO_LOW");
    // Mark the nonce UNAVAILABLE (0x01).
    signerNonceStatus[order.signer.wallet][order.nonce] = UNAVAILABLE;
    // Validate the sender side of the trade.
    address finalSenderWallet;
    if (order.sender.wallet == address(0)) {
      /**
        * Sender is not specified. The msg.sender of the transaction becomes
        * the sender of the order.
        */
      finalSenderWallet = msg.sender;
    } else {
      /**
        * Sender is specified. If the msg.sender is not the specified sender,
        * this determines whether the msg.sender is an authorized sender.
        */
      require(isSenderAuthorized(order.sender.wallet, msg.sender),
          "SENDER_UNAUTHORIZED");
      // The msg.sender is authorized.
      finalSenderWallet = order.sender.wallet;
    }
    // Validate the signer side of the trade.
    if (order.signature.v == 0) {
      /**
        * Signature is not provided. The signer may have authorized the
        * msg.sender to swap on its behalf, which does not require a signature.
        */
      require(isSignerAuthorized(order.signer.wallet, msg.sender),
        "SIGNER_UNAUTHORIZED");
    } else {
      /**
        * The signature is provided. Determine whether the signer is
        * authorized and if so validate the signature itself.
        */
      require(isSignerAuthorized(order.signer.wallet, order.signature.signatory),
        "SIGNER_UNAUTHORIZED");
      // Ensure the signature is valid.
      require(isValid(order, _domainSeparator),
        "SIGNATURE_INVALID");
    }
    // Transfer token from sender to signer.
    transferToken(
      finalSenderWallet,
      order.signer.wallet,
      order.sender.amount,
      order.sender.id,
      order.sender.token,
      order.sender.kind
    );
    // Transfer token from signer to sender.
    transferToken(
      order.signer.wallet,
      finalSenderWallet,
      order.signer.amount,
      order.signer.id,
      order.signer.token,
      order.signer.kind
    );
    // Transfer token from signer to affiliate if specified.
    if (order.affiliate.token != address(0)) {
      transferToken(
        order.signer.wallet,
        order.affiliate.wallet,
        order.affiliate.amount,
        order.affiliate.id,
        order.affiliate.token,
        order.affiliate.kind
      );
    }
    emit Swap(
      order.nonce,
      block.timestamp,
      order.signer.wallet,
      order.signer.amount,
      order.signer.id,
      order.signer.token,
      finalSenderWallet,
      order.sender.amount,
      order.sender.id,
      order.sender.token,
      order.affiliate.wallet,
      order.affiliate.amount,
      order.affiliate.id,
      order.affiliate.token
    );
  }
  /**
    * @notice Cancel one or more open orders by nonce
    * @dev Cancelled nonces are marked UNAVAILABLE (0x01)
    * @dev Emits a Cancel event
    * @dev Out of gas may occur in arrays of length > 400
    * @param nonces uint256[] List of nonces to cancel
    */
  function cancel(
    uint256[] calldata nonces
  ) external {
    for (uint256 i = 0; i < nonces.length; i++) {
      if (signerNonceStatus[msg.sender][nonces[i]] == AVAILABLE) {
        signerNonceStatus[msg.sender][nonces[i]] = UNAVAILABLE;
        emit Cancel(nonces[i], msg.sender);
      }
    }
  }
  /**
    * @notice Cancels all orders below a nonce value
    * @dev Emits a CancelUpTo event
    * @param minimumNonce uint256 Minimum valid nonce
    */
  function cancelUpTo(
    uint256 minimumNonce
  ) external {
    signerMinimumNonce[msg.sender] = minimumNonce;
    emit CancelUpTo(minimumNonce, msg.sender);
  }
  /**
    * @notice Authorize a delegated sender
    * @dev Emits an AuthorizeSender event
    * @param authorizedSender address Address to authorize
    */
  function authorizeSender(
    address authorizedSender
  ) external {
    require(msg.sender != authorizedSender, "INVALID_AUTH_SENDER");
    if (!senderAuthorizations[msg.sender][authorizedSender]) {
      senderAuthorizations[msg.sender][authorizedSender] = true;
      emit AuthorizeSender(msg.sender, authorizedSender);
    }
  }
  /**
    * @notice Authorize a delegated signer
    * @dev Emits an AuthorizeSigner event
    * @param authorizedSigner address Address to authorize
    */
  function authorizeSigner(
    address authorizedSigner
  ) external {
    require(msg.sender != authorizedSigner, "INVALID_AUTH_SIGNER");
    if (!signerAuthorizations[msg.sender][authorizedSigner]) {
      signerAuthorizations[msg.sender][authorizedSigner] = true;
      emit AuthorizeSigner(msg.sender, authorizedSigner);
    }
  }
  /**
    * @notice Revoke an authorized sender
    * @dev Emits a RevokeSender event
    * @param authorizedSender address Address to revoke
    */
  function revokeSender(
    address authorizedSender
  ) external {
    if (senderAuthorizations[msg.sender][authorizedSender]) {
      delete senderAuthorizations[msg.sender][authorizedSender];
      emit RevokeSender(msg.sender, authorizedSender);
    }
  }
  /**
    * @notice Revoke an authorized signer
    * @dev Emits a RevokeSigner event
    * @param authorizedSigner address Address to revoke
    */
  function revokeSigner(
    address authorizedSigner
  ) external {
    if (signerAuthorizations[msg.sender][authorizedSigner]) {
      delete signerAuthorizations[msg.sender][authorizedSigner];
      emit RevokeSigner(msg.sender, authorizedSigner);
    }
  }
  /**
    * @notice Determine whether a sender delegate is authorized
    * @param authorizer address Address doing the authorization
    * @param delegate address Address being authorized
    * @return bool True if a delegate is authorized to send
    */
  function isSenderAuthorized(
    address authorizer,
    address delegate
  ) internal view returns (bool) {
    return ((authorizer == delegate) ||
      senderAuthorizations[authorizer][delegate]);
  }
  /**
    * @notice Determine whether a signer delegate is authorized
    * @param authorizer address Address doing the authorization
    * @param delegate address Address being authorized
    * @return bool True if a delegate is authorized to sign
    */
  function isSignerAuthorized(
    address authorizer,
    address delegate
  ) internal view returns (bool) {
    return ((authorizer == delegate) ||
      signerAuthorizations[authorizer][delegate]);
  }
  /**
    * @notice Validate signature using an EIP-712 typed data hash
    * @param order Types.Order Order to validate
    * @param domainSeparator bytes32 Domain identifier used in signatures (EIP-712)
    * @return bool True if order has a valid signature
    */
  function isValid(
    Types.Order memory order,
    bytes32 domainSeparator
  ) internal pure returns (bool) {
    if (order.signature.version == byte(0x01)) {
      return order.signature.signatory == ecrecover(
        Types.hashOrder(
          order,
          domainSeparator
        ),
        order.signature.v,
        order.signature.r,
        order.signature.s
      );
    }
    if (order.signature.version == byte(0x45)) {
      return order.signature.signatory == ecrecover(
        keccak256(
          abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            Types.hashOrder(order, domainSeparator)
          )
        ),
        order.signature.v,
        order.signature.r,
        order.signature.s
      );
    }
    return false;
  }
  /**
    * @notice Perform an ERC-20 or ERC-721 token transfer
    * @dev Transfer type specified by the bytes4 kind param
    * @dev ERC721: uses transferFrom for transfer
    * @dev ERC20: Takes into account non-standard ERC-20 tokens.
    * @param from address Wallet address to transfer from
    * @param to address Wallet address to transfer to
    * @param amount uint256 Amount for ERC-20
    * @param id token ID for ERC-721
    * @param token address Contract address of token
    * @param kind bytes4 EIP-165 interface ID of the token
    */
  function transferToken(
      address from,
      address to,
      uint256 amount,
      uint256 id,
      address token,
      bytes4 kind
  ) internal {
    // Ensure the transfer is not to self.
    require(from != to, "INVALID_SELF_TRANSFER");
    if (kind == ERC721_INTERFACE_ID) {
      require(amount == 0, "NO_AMOUNT_FIELD_IN_ERC721");
      // Attempt to transfer an ERC-721 token.
      IERC721(token).transferFrom(from, to, id);
    } else {
      require(id == 0, "NO_ID_FIELD_IN_ERC20");
      // Attempt to transfer an ERC-20 token, underlying SafeERC20 calls require.
      IERC20(token).safeTransferFrom(from, to, amount);
    }
  }
}
// File: @airswap/tokens/contracts/interfaces/IWETH.sol

// File: @airswap/wrapper/contracts/Wrapper.sol
/*
  Copyright 2019 Swap Holdings Ltd.
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
/**
  * @title Wrapper: Send and receive ether for WETH trades
  */
contract Wrapper {
  // The Swap contract to settle trades
  ISwap public swapContract;
  // The WETH contract to wrap ether
  IWETH public wethContract;
  /**
    * @notice Contract Constructor
    * @param wrapperSwapContract address
    * @param wrapperWethContract address
    */
  constructor(
    address wrapperSwapContract,
    address wrapperWethContract
  ) public {
    swapContract = ISwap(wrapperSwapContract);
    wethContract = IWETH(wrapperWethContract);
  }
  /**
    * @notice Required when withdrawing from WETH
    * @dev During unwraps, WETH.withdraw transfers ether to msg.sender (this contract)
    */
  function() external payable {
    // Ensure the message sender is the WETH contract.
    if(msg.sender != address(wethContract)) {
      revert("DO_NOT_SEND_ETHER");
    }
  }
  /**
    * @notice Send an Order to be forwarded to Swap
    * @dev Sender must authorize this contract on the swapContract
    * @dev Sender must approve this contract on the wethContract
    * @param order Types.Order The Order
    */
  function swap(
    Types.Order calldata order
  ) external payable {
    // Ensure msg.sender is sender wallet.
    require(order.sender.wallet == msg.sender,
      "MSG_SENDER_MUST_BE_ORDER_SENDER");
    // Ensure that the signature is present.
    // The signature will be explicitly checked in Swap.
    require(order.signature.v != 0,
      "SIGNATURE_MUST_BE_SENT");
    // Wraps ETH to WETH when the sender provides ETH and the order is WETH
    _wrapEther(order.sender);
    // Perform the swap.
    swapContract.swap(order);
    // Unwraps WETH to ETH when the sender receives WETH
    _unwrapEther(order.sender.wallet, order.signer.token, order.signer.amount);
  }
  /**
    * @notice Send an Order to be forwarded to a Delegate
    * @dev Sender must authorize the Delegate contract on the swapContract
    * @dev Sender must approve this contract on the wethContract
    * @dev Delegate's tradeWallet must be order.sender - checked in Delegate
    * @param order Types.Order The Order
    * @param delegate IDelegate The Delegate to provide the order to
    */
  function provideDelegateOrder(
    Types.Order calldata order,
    IDelegate delegate
  ) external payable {
    // Ensure that the signature is present.
    // The signature will be explicitly checked in Swap.
    require(order.signature.v != 0,
      "SIGNATURE_MUST_BE_SENT");
    // Wraps ETH to WETH when the signer provides ETH and the order is WETH
    _wrapEther(order.signer);
    // Provide the order to the Delegate.
    delegate.provideOrder(order);
    // Unwraps WETH to ETH when the signer receives WETH
    _unwrapEther(order.signer.wallet, order.sender.token, order.sender.amount);
  }
  /**
    * @notice Wraps ETH to WETH when a trade requires it
    * @param party Types.Party The side of the trade that may need wrapping
    */
  function _wrapEther(Types.Party memory party) internal {
    // Check whether ether needs wrapping
    if (party.token == address(wethContract)) {
      // Ensure message value is param.
      require(party.amount == msg.value,
        "VALUE_MUST_BE_SENT");
      // Wrap (deposit) the ether.
      wethContract.deposit.value(msg.value)();
      // Transfer the WETH from the wrapper to party.
      // Return value not checked - WETH throws on error and does not return false
      wethContract.transfer(party.wallet, party.amount);
    } else {
      // Ensure no unexpected ether is sent.
      require(msg.value == 0,
        "VALUE_MUST_BE_ZERO");
    }
  }
  /**
    * @notice Unwraps WETH to ETH when a trade requires it
    * @dev The unwrapping only succeeds if recipientWallet has approved transferFrom
    * @param recipientWallet address The trade recipient, who may have received WETH
    * @param receivingToken address The token address the recipient received
    * @param amount uint256 The amount of token the recipient received
    */
  function _unwrapEther(address recipientWallet, address receivingToken, uint256 amount) internal {
    // Check whether ether needs unwrapping
    if (receivingToken == address(wethContract)) {
      // Transfer weth from the recipient to the wrapper.
      wethContract.transferFrom(recipientWallet, address(this), amount);
      // Unwrap (withdraw) the ether.
      wethContract.withdraw(amount);
      // Transfer ether to the recipient.
      // solium-disable-next-line security/no-call-value
      (bool success, ) = recipientWallet.call.value(amount)("");
      require(success, "ETH_RETURN_FAILED");
    }
  }
}
// File: contracts/Imports.sol
//Import all the contracts desired to be deployed
contract Imports {}