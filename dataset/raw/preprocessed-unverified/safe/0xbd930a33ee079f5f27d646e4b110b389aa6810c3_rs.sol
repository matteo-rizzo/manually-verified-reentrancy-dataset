/**
 *Submitted for verification at Etherscan.io on 2019-12-27
*/

/**
Copyright 2019 PoolTogether LLC

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.5.12;

contract GemLike {
    function allowance(address, address) public returns (uint);
    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function transferFrom(address, address, uint) public returns (bool);
}

contract ValueLike {
    function peek() public returns (uint, bool);
}

contract SaiTubLike {
    function skr() public view returns (GemLike);
    function gem() public view returns (GemLike);
    function gov() public view returns (GemLike);
    function sai() public view returns (GemLike);
    function pep() public view returns (ValueLike);
    function vox() public view returns (VoxLike);
    function bid(uint) public view returns (uint);
    function ink(bytes32) public view returns (uint);
    function tag() public view returns (uint);
    function tab(bytes32) public returns (uint);
    function rap(bytes32) public returns (uint);
    function draw(bytes32, uint) public;
    function shut(bytes32) public;
    function exit(uint) public;
    function give(bytes32, address) public;
}

contract VoxLike {
    function par() public returns (uint);
}

contract JoinLike {
    function ilk() public returns (bytes32);
    function gem() public returns (GemLike);
    function dai() public returns (GemLike);
    function join(address, uint) public;
    function exit(address, uint) public;
}
contract VatLike {
    function ilks(bytes32) public view returns (uint, uint, uint, uint, uint);
    function hope(address) public;
    function frob(bytes32, address, address, address, int, int) public;
}

contract ManagerLike {
    function vat() public view returns (address);
    function urns(uint) public view returns (address);
    function open(bytes32, address) public returns (uint);
    function frob(uint, int, int) public;
    function give(uint, address) public;
    function move(uint, address, uint) public;
}

contract OtcLike {
    function getPayAmount(address, address, uint) public view returns (uint);
    function buyAllAmount(address, uint, address, uint) public;
}


/**
 * Implements a "lock" feature with a cooldown
 */

/**
Copyright 2019 PoolTogether LLC

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/



/**
Copyright 2019 PoolTogether LLC

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/





/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */




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







/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard is Initializable {
    // counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    function initialize() public initializer {
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
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }

    uint256[50] private ______gap;
}



/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


/**
Copyright 2019 PoolTogether LLC

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/



contract ICErc20 {
    address public underlying;
    function mint(uint mintAmount) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function getCash() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
}

/**
Copyright 2019 PoolTogether LLC

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/



/**
Copyright 2019 PoolTogether LLC

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/



/**
 * @author Brendan Asselstine
 * @notice A library that uses entropy to select a random number within a bound.  Compensates for modulo bias.
 * @dev Thanks to https://medium.com/hownetworks/dont-waste-cycles-with-modulo-bias-35b6fdafcf94
 */

/**
 *  @reviewers: [@clesaege, @unknownunknown1, @ferittuncer]
 *  @auditors: []
 *  @bounties: [<14 days 10 ETH max payout>]
 *  @deployments: []
 */



/**
 *  @title SortitionSumTreeFactory
 *  @author Enrique Piqueras - <epiquerass@gmail.com>
 *  @dev A factory of trees that keep track of staked values for sortition.
 */




/**
 * @author Brendan Asselstine
 * @notice Tracks committed and open balances for addresses.  Affords selection of an address by indexing all committed balances.
 *
 * Balances are tracked in Draws.  There is always one open Draw.  Deposits are always added to the open Draw.
 * When a new draw is opened, the previous opened draw is committed.
 *
 * The committed balance for an address is the total of their balances for committed Draws.
 * An address's open balance is their balance in the open Draw.
 */




/**
 * @title FixidityLib
 * @author Gadi Guy, Alberto Cuesta Canada
 * @notice This library provides fixed point arithmetic with protection against
 * overflow. 
 * All operations are done with int256 and the operands must have been created 
 * with any of the newFrom* functions, which shift the comma digits() to the 
 * right and check for limits.
 * When using this library be sure of using maxNewFixed() as the upper limit for
 * creation of fixed point numbers. Use maxFixedMul(), maxFixedDiv() and
 * maxFixedAdd() if you want to be certain that those operations don't 
 * overflow.
 */




/**
Copyright 2019 PoolTogether LLC

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/








/**
 * @dev Interface of the ERC777Token standard as defined in the EIP.
 *
 * This contract uses the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 registry standard] to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See {IERC1820Registry} and
 * {ERC1820Implementer}.
 */





/**
 * @dev Interface of the ERC777TokensSender standard as defined in the EIP.
 *
 * {IERC777} Token holders can be notified of operations performed on their
 * tokens by having a contract implement this interface (contract holders can be
 *  their own implementer) and registering it on the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 global registry].
 *
 * See {IERC1820Registry} and {ERC1820Implementer}.
 */




/**
 * @dev Interface of the global ERC1820 Registry, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1820[EIP]. Accounts may register
 * implementers for interfaces in this registry, as well as query support.
 *
 * Implementers may be shared by multiple accounts, and can also implement more
 * than a single interface for each account. Contracts can implement interfaces
 * for themselves, but externally-owned accounts (EOA) must delegate this to a
 * contract.
 *
 * {IERC165} interfaces can also be queried via the registry.
 *
 * For an in-depth explanation and source code analysis, see the EIP text.
 */




/**
 * @dev Collection of functions related to the address type
 */





/**
 * @dev Implementation of the {IERC777} interface.
 *
 * Largely taken from the OpenZeppelin ERC777 contract.
 *
 * Support for ERC20 is included in this contract, as specified by the EIP: both
 * the ERC777 and ERC20 interfaces can be safely used when interacting with it.
 * Both {IERC777-Sent} and {IERC20-Transfer} events are emitted on token
 * movements.
 *
 * Additionally, the {IERC777-granularity} value is hard-coded to `1`, meaning that there
 * are no special restrictions in the amount of tokens that created, moved, or
 * destroyed. This makes integration with ERC20 applications seamless.
 *
 * It is important to note that no Mint events are emitted.  Tokens are minted in batches
 * by a state change in a tree data structure, so emitting a Mint event for each user
 * is not possible.
 *
 */
contract PoolToken is Initializable, IERC20, IERC777 {
  using SafeMath for uint256;
  using Address for address;

  /**
   * Event emitted when a user or operator redeems tokens
   */
  event Redeemed(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

  IERC1820Registry constant internal ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

  // We inline the result of the following hashes because Solidity doesn't resolve them at compile time.
  // See https://github.com/ethereum/solidity/issues/4024.

  // keccak256("ERC777TokensSender")
  bytes32 constant internal TOKENS_SENDER_INTERFACE_HASH =
      0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

  // keccak256("ERC777TokensRecipient")
  bytes32 constant internal TOKENS_RECIPIENT_INTERFACE_HASH =
      0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

  // keccak256("ERC777Token")
  bytes32 constant internal TOKENS_INTERFACE_HASH =
      0xac7fbab5f54a3ca8194167523c6753bfeb96a445279294b6125b68cce2177054;

  // keccak256("ERC20Token")
  bytes32 constant internal ERC20_TOKENS_INTERFACE_HASH =
      0xaea199e31a596269b42cdafd93407f14436db6e4cad65417994c2eb37381e05a;

  string internal _name;
  string internal _symbol;

  // This isn't ever read from - it's only used to respond to the defaultOperators query.
  address[] internal _defaultOperatorsArray;

  // Immutable, but accounts may revoke them (tracked in __revokedDefaultOperators).
  mapping(address => bool) internal _defaultOperators;

  // For each account, a mapping of its operators and revoked default operators.
  mapping(address => mapping(address => bool)) internal _operators;
  mapping(address => mapping(address => bool)) internal _revokedDefaultOperators;

  // ERC20-allowances
  mapping (address => mapping (address => uint256)) internal _allowances;

  BasePool internal _pool;

  function init (
    string memory name,
    string memory symbol,
    address[] memory defaultOperators,
    BasePool pool
  ) public initializer {
      require(bytes(name).length != 0, "PoolToken/name");
      require(bytes(symbol).length != 0, "PoolToken/symbol");
      require(address(pool) != address(0), "PoolToken/pool-zero");

      _name = name;
      _symbol = symbol;
      _pool = pool;

      _defaultOperatorsArray = defaultOperators;
      for (uint256 i = 0; i < _defaultOperatorsArray.length; i++) {
          _defaultOperators[_defaultOperatorsArray[i]] = true;
      }

      // register interfaces
      ERC1820_REGISTRY.setInterfaceImplementer(address(this), TOKENS_INTERFACE_HASH, address(this));
      ERC1820_REGISTRY.setInterfaceImplementer(address(this), ERC20_TOKENS_INTERFACE_HASH, address(this));
  }

  function pool() public view returns (address) {
      return address(_pool);
  }

  function poolRedeem(address from, uint256 amount) external onlyPool {
      _callTokensToSend(from, from, address(0), amount, '', '');

      emit Redeemed(from, from, amount, '', '');
      emit Transfer(from, address(0), amount);
  }

  /**
    * @dev See {IERC777-name}.
    */
  function name() public view returns (string memory) {
      return _name;
  }

  /**
    * @dev See {IERC777-symbol}.
    */
  function symbol() public view returns (string memory) {
      return _symbol;
  }

  /**
    * @dev See {ERC20Detailed-decimals}.
    *
    * Always returns 18, as per the
    * [ERC777 EIP](https://eips.ethereum.org/EIPS/eip-777#backward-compatibility).
    */
  function decimals() public pure returns (uint8) {
      return 18;
  }

  /**
    * @dev See {IERC777-granularity}.
    *
    * This implementation always returns `1`.
    */
  function granularity() public view returns (uint256) {
      return 1;
  }

  /**
    * @dev See {IERC777-totalSupply}.
    */
  function totalSupply() public view returns (uint256) {
      return _pool.committedSupply();
  }

  /**
    * @dev See {IERC20-balanceOf}.
    */
  function balanceOf(address _addr) external view returns (uint256) {
      return _pool.committedBalanceOf(_addr);
  }

  /**
    * @dev See {IERC777-send}.
    *
    * Also emits a {Transfer} event for ERC20 compatibility.
    */
  function send(address recipient, uint256 amount, bytes calldata data) external {
      _send(msg.sender, msg.sender, recipient, amount, data, "");
  }

  /**
    * @dev See {IERC20-transfer}.
    *
    * Unlike `send`, `recipient` is _not_ required to implement the {IERC777Recipient}
    * interface if it is a contract.
    *
    * Also emits a {Sent} event.
    */
  function transfer(address recipient, uint256 amount) external returns (bool) {
      require(recipient != address(0), "PoolToken/transfer-zero");

      address from = msg.sender;

      _callTokensToSend(from, from, recipient, amount, "", "");

      _move(from, from, recipient, amount, "", "");

      _callTokensReceived(from, from, recipient, amount, "", "", false);

      return true;
  }

  /**
    * @dev Allows a user to withdraw their tokens as the underlying asset.
    *
    * Also emits a {Transfer} event for ERC20 compatibility.
    */
  function redeem(uint256 amount, bytes calldata data) external {
      _redeem(msg.sender, msg.sender, amount, data, "");
  }

  /**
    * @dev See {IERC777-burn}.  Not currently implemented.
    *
    * Also emits a {Transfer} event for ERC20 compatibility.
    */
  function burn(uint256, bytes calldata) external {
      revert("PoolToken/no-support");
  }

  /**
    * @dev See {IERC777-isOperatorFor}.
    */
  function isOperatorFor(
      address operator,
      address tokenHolder
  ) public view returns (bool) {
      return operator == tokenHolder ||
          (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
          _operators[tokenHolder][operator];
  }

  /**
    * @dev See {IERC777-authorizeOperator}.
    */
  function authorizeOperator(address operator) external {
      require(msg.sender != operator, "PoolToken/auth-self");

      if (_defaultOperators[operator]) {
          delete _revokedDefaultOperators[msg.sender][operator];
      } else {
          _operators[msg.sender][operator] = true;
      }

      emit AuthorizedOperator(operator, msg.sender);
  }

  /**
    * @dev See {IERC777-revokeOperator}.
    */
  function revokeOperator(address operator) external {
      require(operator != msg.sender, "PoolToken/revoke-self");

      if (_defaultOperators[operator]) {
          _revokedDefaultOperators[msg.sender][operator] = true;
      } else {
          delete _operators[msg.sender][operator];
      }

      emit RevokedOperator(operator, msg.sender);
  }

  /**
    * @dev See {IERC777-defaultOperators}.
    */
  function defaultOperators() public view returns (address[] memory) {
      return _defaultOperatorsArray;
  }

  /**
    * @dev See {IERC777-operatorSend}.
    *
    * Emits {Sent} and {Transfer} events.
    */
  function operatorSend(
      address sender,
      address recipient,
      uint256 amount,
      bytes calldata data,
      bytes calldata operatorData
  )
  external
  {
      require(isOperatorFor(msg.sender, sender), "PoolToken/not-operator");
      _send(msg.sender, sender, recipient, amount, data, operatorData);
  }

  /**
    * @dev See {IERC777-operatorBurn}.
    *
    * Currently not supported
    */
  function operatorBurn(address, uint256, bytes calldata, bytes calldata) external {
      revert("PoolToken/no-support");
  }

  /**
    * @dev Allows an operator to redeem tokens for the underlying asset on behalf of a user.
    *
    * Emits {Redeemed} and {Transfer} events.
    */
  function operatorRedeem(address account, uint256 amount, bytes calldata data, bytes calldata operatorData) external {
      require(isOperatorFor(msg.sender, account), "PoolToken/not-operator");
      _redeem(msg.sender, account, amount, data, operatorData);
  }

  /**
    * @dev See {IERC20-allowance}.
    *
    * Note that operator and allowance concepts are orthogonal: operators may
    * not have allowance, and accounts with allowance may not be operators
    * themselves.
    */
  function allowance(address holder, address spender) public view returns (uint256) {
      return _allowances[holder][spender];
  }

  /**
    * @dev See {IERC20-approve}.
    *
    * Note that accounts cannot have allowance issued by their operators.
    */
  function approve(address spender, uint256 value) external returns (bool) {
      address holder = msg.sender;
      _approve(holder, spender, value);
      return true;
  }

  /**
  * @dev See {IERC20-transferFrom}.
  *
  * Note that operator and allowance concepts are orthogonal: operators cannot
  * call `transferFrom` (unless they have allowance), and accounts with
  * allowance cannot call `operatorSend` (unless they are operators).
  *
  * Emits {Sent}, {Transfer} and {Approval} events.
  */
  function transferFrom(address holder, address recipient, uint256 amount) external returns (bool) {
      require(recipient != address(0), "PoolToken/to-zero");
      require(holder != address(0), "PoolToken/from-zero");

      address spender = msg.sender;

      _callTokensToSend(spender, holder, recipient, amount, "", "");

      _move(spender, holder, recipient, amount, "", "");
      _approve(holder, spender, _allowances[holder][spender].sub(amount, "PoolToken/exceed-allow"));

      _callTokensReceived(spender, holder, recipient, amount, "", "", false);

      return true;
  }

  /**
   * Called by the associated Pool to emit `Mint` events.
   * @param amount The amount that was minted
   */
  function poolMint(uint256 amount) external onlyPool {
    _mintEvents(address(_pool), address(_pool), amount, '', '');
  }

  /**
    * Emits {Minted} and {IERC20-Transfer} events.
    */
  function _mintEvents(
      address operator,
      address account,
      uint256 amount,
      bytes memory userData,
      bytes memory operatorData
  )
  internal
  {
      emit Minted(operator, account, amount, userData, operatorData);
      emit Transfer(address(0), account, amount);
  }

  /**
    * @dev Send tokens
    * @param operator address operator requesting the transfer
    * @param from address token holder address
    * @param to address recipient address
    * @param amount uint256 amount of tokens to transfer
    * @param userData bytes extra information provided by the token holder (if any)
    * @param operatorData bytes extra information provided by the operator (if any)
    */
  function _send(
      address operator,
      address from,
      address to,
      uint256 amount,
      bytes memory userData,
      bytes memory operatorData
  )
      private
  {
      require(from != address(0), "PoolToken/from-zero");
      require(to != address(0), "PoolToken/to-zero");

      _callTokensToSend(operator, from, to, amount, userData, operatorData);

      _move(operator, from, to, amount, userData, operatorData);

      _callTokensReceived(operator, from, to, amount, userData, operatorData, true);
  }

  /**
    * @dev Redeems tokens for the underlying asset.
    * @param operator address operator requesting the operation
    * @param from address token holder address
    * @param amount uint256 amount of tokens to redeem
    * @param data bytes extra information provided by the token holder
    * @param operatorData bytes extra information provided by the operator (if any)
    */
  function _redeem(
      address operator,
      address from,
      uint256 amount,
      bytes memory data,
      bytes memory operatorData
  )
      private
  {
      require(from != address(0), "PoolToken/from-zero");

      _callTokensToSend(operator, from, address(0), amount, data, operatorData);

      _pool.withdrawCommittedDeposit(from, amount);

      emit Redeemed(operator, from, amount, data, operatorData);
      emit Transfer(from, address(0), amount);
  }

  function _move(
      address operator,
      address from,
      address to,
      uint256 amount,
      bytes memory userData,
      bytes memory operatorData
  )
      private
  {
      _pool.moveCommitted(from, to, amount);

      emit Sent(operator, from, to, amount, userData, operatorData);
      emit Transfer(from, to, amount);
  }

  function _approve(address holder, address spender, uint256 value) private {
      require(spender != address(0), "PoolToken/from-zero");

      _allowances[holder][spender] = value;
      emit Approval(holder, spender, value);
  }

  /**
    * @dev Call from.tokensToSend() if the interface is registered
    * @param operator address operator requesting the transfer
    * @param from address token holder address
    * @param to address recipient address
    * @param amount uint256 amount of tokens to transfer
    * @param userData bytes extra information provided by the token holder (if any)
    * @param operatorData bytes extra information provided by the operator (if any)
    */
  function _callTokensToSend(
      address operator,
      address from,
      address to,
      uint256 amount,
      bytes memory userData,
      bytes memory operatorData
  )
      internal notLocked
  {
      address implementer = ERC1820_REGISTRY.getInterfaceImplementer(from, TOKENS_SENDER_INTERFACE_HASH);
      if (implementer != address(0)) {
          IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
      }
  }

  /**
    * @dev Call to.tokensReceived() if the interface is registered. Reverts if the recipient is a contract but
    * tokensReceived() was not registered for the recipient
    * @param operator address operator requesting the transfer
    * @param from address token holder address
    * @param to address recipient address
    * @param amount uint256 amount of tokens to transfer
    * @param userData bytes extra information provided by the token holder (if any)
    * @param operatorData bytes extra information provided by the operator (if any)
    * @param requireReceptionAck Whether the recipient, when a contract, *must* have a IERC777Recipient implementor
    */
  function _callTokensReceived(
      address operator,
      address from,
      address to,
      uint256 amount,
      bytes memory userData,
      bytes memory operatorData,
      bool requireReceptionAck
  )
      private
  {
      address implementer = ERC1820_REGISTRY.getInterfaceImplementer(to, TOKENS_RECIPIENT_INTERFACE_HASH);
      if (implementer != address(0)) {
          IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
      } else if (requireReceptionAck) {
          require(!to.isContract(), "PoolToken/no-recip-inter");
      }
  }

  modifier onlyPool() {
    require(msg.sender == address(_pool), "PoolToken/only-pool");
    _;
  }

  modifier notLocked() {
    require(!_pool.isLocked(), "PoolToken/is-locked");
    _;
  }
}


/**
 * @title The Pool contract
 * @author Brendan Asselstine
 * @notice This contract allows users to pool deposits into Compound and win the accrued interest in periodic draws.
 * Funds are immediately deposited and withdrawn from the Compound cToken contract.
 * Draws go through three stages: open, committed and rewarded in that order.
 * Only one draw is ever in the open stage.  Users deposits are always added to the open draw.  Funds in the open Draw are that user's open balance.
 * When a Draw is committed, the funds in it are moved to a user's committed total and the total committed balance of all users is updated.
 * When a Draw is rewarded, the gross winnings are the accrued interest since the last reward (if any).  A winner is selected with their chances being
 * proportional to their committed balance vs the total committed balance of all users.
 *
 *
 * With the above in mind, there is always an open draw and possibly a committed draw.  The progression is:
 *
 * Step 1: Draw 1 Open
 * Step 2: Draw 2 Open | Draw 1 Committed
 * Step 3: Draw 3 Open | Draw 2 Committed | Draw 1 Rewarded
 * Step 4: Draw 4 Open | Draw 3 Committed | Draw 2 Rewarded
 * Step 5: Draw 5 Open | Draw 4 Committed | Draw 3 Rewarded
 * Step X: ...
 */
contract BasePool is Initializable, ReentrancyGuard {
  using DrawManager for DrawManager.State;
  using SafeMath for uint256;
  using Roles for Roles.Role;
  using Blocklock for Blocklock.State;

  bytes32 internal constant ROLLED_OVER_ENTROPY_MAGIC_NUMBER = bytes32(uint256(1));
  uint256 internal constant DEFAULT_LOCK_DURATION = 40;
  uint256 internal constant DEFAULT_COOLDOWN_DURATION = 80;

  /**
   * Emitted when a user deposits into the Pool.
   * @param sender The purchaser of the tickets
   * @param amount The size of the deposit
   */
  event Deposited(address indexed sender, uint256 amount);

  /**
   * Emitted when a user deposits into the Pool and the deposit is immediately committed
   * @param sender The purchaser of the tickets
   * @param amount The size of the deposit
   */
  event DepositedAndCommitted(address indexed sender, uint256 amount);

  /**
   * Emitted when Sponsors have deposited into the Pool
   * @param sender The purchaser of the tickets
   * @param amount The size of the deposit
   */
  event SponsorshipDeposited(address indexed sender, uint256 amount);

  /**
   * Emitted when an admin has been added to the Pool.
   * @param admin The admin that was added
   */
  event AdminAdded(address indexed admin);

  /**
   * Emitted when an admin has been removed from the Pool.
   * @param admin The admin that was removed
   */
  event AdminRemoved(address indexed admin);

  /**
   * Emitted when a user withdraws from the pool.
   * @param sender The user that is withdrawing from the pool
   * @param amount The amount that the user withdrew
   */
  event Withdrawn(address indexed sender, uint256 amount);

  /**
   * Emitted when a user withdraws their sponsorship and fees from the pool.
   * @param sender The user that is withdrawing
   * @param amount The amount they are withdrawing
   */
  event SponsorshipAndFeesWithdrawn(address indexed sender, uint256 amount);

  /**
   * Emitted when a user withdraws from their open deposit.
   * @param sender The user that is withdrawing
   * @param amount The amount they are withdrawing
   */
  event OpenDepositWithdrawn(address indexed sender, uint256 amount);

  /**
   * Emitted when a user withdraws from their committed deposit.
   * @param sender The user that is withdrawing
   * @param amount The amount they are withdrawing
   */
  event CommittedDepositWithdrawn(address indexed sender, uint256 amount);

  /**
   * Emitted when an address collects a fee
   * @param sender The address collecting the fee
   * @param amount The fee amount
   * @param drawId The draw from which the fee was awarded
   */
  event FeeCollected(address indexed sender, uint256 amount, uint256 drawId);

  /**
   * Emitted when a new draw is opened for deposit.
   * @param drawId The draw id
   * @param feeBeneficiary The fee beneficiary for this draw
   * @param secretHash The committed secret hash
   * @param feeFraction The fee fraction of the winnings to be given to the beneficiary
   */
  event Opened(
    uint256 indexed drawId,
    address indexed feeBeneficiary,
    bytes32 secretHash,
    uint256 feeFraction
  );

  /**
   * Emitted when a draw is committed.
   * @param drawId The draw id
   */
  event Committed(
    uint256 indexed drawId
  );

  /**
   * Emitted when a draw is rewarded.
   * @param drawId The draw id
   * @param winner The address of the winner
   * @param entropy The entropy used to select the winner
   * @param winnings The net winnings given to the winner
   * @param fee The fee being given to the draw beneficiary
   */
  event Rewarded(
    uint256 indexed drawId,
    address indexed winner,
    bytes32 entropy,
    uint256 winnings,
    uint256 fee
  );

  /**
   * Emitted when the fee fraction is changed.  Takes effect on the next draw.
   * @param feeFraction The next fee fraction encoded as a fixed point 18 decimal
   */
  event NextFeeFractionChanged(uint256 feeFraction);

  /**
   * Emitted when the next fee beneficiary changes.  Takes effect on the next draw.
   * @param feeBeneficiary The next fee beneficiary
   */
  event NextFeeBeneficiaryChanged(address indexed feeBeneficiary);

  /**
   * Emitted when an admin pauses the contract
   */
  event Paused(address indexed sender);

  /**
   * Emitted when an admin unpauses the contract
   */
  event Unpaused(address indexed sender);

  /**
   * Emitted when the draw is rolled over in the event that the secret is forgotten.
   */
  event RolledOver(uint256 indexed drawId);

  struct Draw {
    uint256 feeFraction; //fixed point 18
    address feeBeneficiary;
    uint256 openedBlock;
    bytes32 secretHash;
    bytes32 entropy;
    address winner;
    uint256 netWinnings;
    uint256 fee;
  }

  /**
   * The Compound cToken that this Pool is bound to.
   */
  ICErc20 public cToken;

  /**
   * The fee beneficiary to use for subsequent Draws.
   */
  address public nextFeeBeneficiary;

  /**
   * The fee fraction to use for subsequent Draws.
   */
  uint256 public nextFeeFraction;

  /**
   * The total of all balances
   */
  uint256 public accountedBalance;

  /**
   * The total deposits and winnings for each user.
   */
  mapping (address => uint256) balances;

  /**
   * A mapping of draw ids to Draw structures
   */
  mapping(uint256 => Draw) draws;

  /**
   * A structure that is used to manage the user's odds of winning.
   */
  DrawManager.State drawState;

  /**
   * A structure containing the administrators
   */
  Roles.Role admins;

  /**
   * Whether the contract is paused
   */
  bool public paused;

  Blocklock.State blocklock;

  PoolToken public poolToken;

  /**
   * @notice Initializes a new Pool contract.
   * @param _owner The owner of the Pool.  They are able to change settings and are set as the owner of new lotteries.
   * @param _cToken The Compound Finance MoneyMarket contract to supply and withdraw tokens.
   * @param _feeFraction The fraction of the gross winnings that should be transferred to the owner as the fee.  Is a fixed point 18 number.
   * @param _feeBeneficiary The address that will receive the fee fraction
   */
  function init (
    address _owner,
    address _cToken,
    uint256 _feeFraction,
    address _feeBeneficiary,
    uint256 _lockDuration,
    uint256 _cooldownDuration
  ) public initializer {
    require(_owner != address(0), "Pool/owner-zero");
    require(_cToken != address(0), "Pool/ctoken-zero");
    cToken = ICErc20(_cToken);
    _addAdmin(_owner);
    _setNextFeeFraction(_feeFraction);
    _setNextFeeBeneficiary(_feeBeneficiary);
    initBlocklock(_lockDuration, _cooldownDuration);
  }

  function setPoolToken(PoolToken _poolToken) external onlyAdmin {
    require(address(poolToken) == address(0), "Pool/token-was-set");
    require(_poolToken.pool() == address(this), "Pool/token-mismatch");
    poolToken = _poolToken;
  }

  function initBlocklock(uint256 _lockDuration, uint256 _cooldownDuration) internal {
    blocklock.setLockDuration(_lockDuration);
    blocklock.setCooldownDuration(_cooldownDuration);
  }

  /**
   * @notice Opens a new Draw.
   * @param _secretHash The secret hash to commit to the Draw.
   */
  function open(bytes32 _secretHash) internal {
    drawState.openNextDraw();
    draws[drawState.openDrawIndex] = Draw(
      nextFeeFraction,
      nextFeeBeneficiary,
      block.number,
      _secretHash,
      bytes32(0),
      address(0),
      uint256(0),
      uint256(0)
    );
    emit Opened(
      drawState.openDrawIndex,
      nextFeeBeneficiary,
      _secretHash,
      nextFeeFraction
    );
  }

  /**
   * @notice Commits the current draw.
   */
  function emitCommitted() internal {
    uint256 drawId = currentOpenDrawId();
    emit Committed(drawId);
    if (address(poolToken) != address(0)) {
      poolToken.poolMint(openSupply());
    }
  }

  /**
   * @notice Commits the current open draw, if any, and opens the next draw using the passed hash.  Really this function is only called twice:
   * the first after Pool contract creation and the second immediately after.
   * Can only be called by an admin.
   * May fire the Committed event, and always fires the Open event.
   * @param nextSecretHash The secret hash to use to open a new Draw
   */
  function openNextDraw(bytes32 nextSecretHash) public onlyAdmin {
    if (currentCommittedDrawId() > 0) {
      require(currentCommittedDrawHasBeenRewarded(), "Pool/not-reward");
    }
    if (currentOpenDrawId() != 0) {
      emitCommitted();
    }
    open(nextSecretHash);
  }

  /**
   * @notice Ignores the current draw, and opens the next draw.
   * @dev This function will be removed once the winner selection has been decentralized.
   * @param nextSecretHash The hash to commit for the next draw
   */
  function rolloverAndOpenNextDraw(bytes32 nextSecretHash) public onlyAdmin {
    rollover();
    openNextDraw(nextSecretHash);
  }

  /**
   * @notice Rewards the current committed draw using the passed secret, commits the current open draw, and opens the next draw using the passed secret hash.
   * Can only be called by an admin.
   * Fires the Rewarded event, the Committed event, and the Open event.
   * @param nextSecretHash The secret hash to use to open a new Draw
   * @param lastSecret The secret to reveal to reward the current committed Draw.
   * @param _salt The salt that was combined with the revealed secret to use as the hash.  Expects secretHash == keccak256(abi.encodePacked(_secret, _salt))
   */
  function rewardAndOpenNextDraw(bytes32 nextSecretHash, bytes32 lastSecret, bytes32 _salt) public onlyAdmin {
    reward(lastSecret, _salt);
    openNextDraw(nextSecretHash);
  }

  /**
   * @notice Rewards the winner for the current committed Draw using the passed secret.
   * The gross winnings are calculated by subtracting the accounted balance from the current underlying cToken balance.
   * A winner is calculated using the revealed secret.
   * If there is a winner (i.e. any eligible users) then winner's balance is updated with their net winnings.
   * The draw beneficiary's balance is updated with the fee.
   * The accounted balance is updated to include the fee and, if there was a winner, the net winnings.
   * Fires the Rewarded event.
   * @param _secret The secret to reveal for the current committed Draw
   * @param _salt The salt that was combined with the revealed secret to use as the hash.  Expects secretHash == keccak256(abi.encodePacked(_secret, _salt))
   */
  function reward(bytes32 _secret, bytes32 _salt) public onlyAdmin onlyLocked requireCommittedNoReward nonReentrant {
    blocklock.unlock(block.number);

    // require that there is a committed draw
    // require that the committed draw has not been rewarded
    uint256 drawId = currentCommittedDrawId();

    Draw storage draw = draws[drawId];

    require(draw.secretHash == keccak256(abi.encodePacked(_secret, _salt)), "Pool/bad-secret");

    // derive entropy from the revealed secret
    bytes32 entropy = keccak256(abi.encodePacked(_secret));

    // Select the winner using the hash as entropy
    address winningAddress = calculateWinner(entropy);

    // Calculate the gross winnings
    uint256 underlyingBalance = balance();
    uint256 grossWinnings = underlyingBalance.sub(accountedBalance);

    // Calculate the beneficiary fee
    uint256 fee = calculateFee(draw.feeFraction, grossWinnings);

    // Update balance of the beneficiary
    balances[draw.feeBeneficiary] = balances[draw.feeBeneficiary].add(fee);

    // Calculate the net winnings
    uint256 netWinnings = grossWinnings.sub(fee);

    draw.winner = winningAddress;
    draw.netWinnings = netWinnings;
    draw.fee = fee;
    draw.entropy = entropy;

    // If there is a winner who is to receive non-zero winnings
    if (winningAddress != address(0) && netWinnings != 0) {
      // Updated the accounted total
      accountedBalance = underlyingBalance;

      awardWinnings(winningAddress, netWinnings);
    } else {
      // Only account for the fee
      accountedBalance = accountedBalance.add(fee);
    }

    emit Rewarded(
      drawId,
      winningAddress,
      entropy,
      netWinnings,
      fee
    );
    emit FeeCollected(draw.feeBeneficiary, fee, drawId);
  }

  function awardWinnings(address winner, uint256 amount) internal {
    // Update balance of the winner
    balances[winner] = balances[winner].add(amount);

    // Enter their winnings into the open draw
    drawState.deposit(winner, amount);
  }

  /**
   * @notice A function that skips the reward for the committed draw id.
   * @dev This function will be removed once the entropy is decentralized.
   */
  function rollover() public onlyAdmin requireCommittedNoReward {
    uint256 drawId = currentCommittedDrawId();

    Draw storage draw = draws[drawId];
    draw.entropy = ROLLED_OVER_ENTROPY_MAGIC_NUMBER;

    emit RolledOver(
      drawId
    );

    emit Rewarded(
      drawId,
      address(0),
      ROLLED_OVER_ENTROPY_MAGIC_NUMBER,
      0,
      0
    );
  }

  /**
   * @notice Calculate the beneficiary fee using the passed fee fraction and gross winnings.
   * @param _feeFraction The fee fraction, between 0 and 1, represented as a 18 point fixed number.
   * @param _grossWinnings The gross winnings to take a fraction of.
   */
  function calculateFee(uint256 _feeFraction, uint256 _grossWinnings) internal pure returns (uint256) {
    int256 grossWinningsFixed = FixidityLib.newFixed(int256(_grossWinnings));
    int256 feeFixed = FixidityLib.multiply(grossWinningsFixed, FixidityLib.newFixed(int256(_feeFraction), uint8(18)));
    return uint256(FixidityLib.fromFixed(feeFixed));
  }

  /**
   * @notice Allows a user to deposit a sponsorship amount.  The deposit is transferred into the cToken.
   * Sponsorships allow a user to contribute to the pool without becoming eligible to win.  They can withdraw their sponsorship at any time.
   * The deposit will immediately be added to Compound and the interest will contribute to the next draw.
   * @param _amount The amount of the token underlying the cToken to deposit.
   */
  function depositSponsorship(uint256 _amount) public unlessPaused nonReentrant {
    // Transfer the tokens into this contract
    require(token().transferFrom(msg.sender, address(this), _amount), "Pool/t-fail");

    // Deposit the sponsorship amount
    _depositSponsorshipFrom(msg.sender, _amount);
  }

  /**
   * @notice Deposits the token balance for this contract as a sponsorship.
   * If people erroneously transfer tokens to this contract, this function will allow us to recoup those tokens as sponsorship.
   */
  function transferBalanceToSponsorship() public unlessPaused {
    // Deposit the sponsorship amount
    _depositSponsorshipFrom(address(this), token().balanceOf(address(this)));
  }

  /**
   * @notice Deposits into the pool under the current open Draw.  The deposit is transferred into the cToken.
   * Once the open draw is committed, the deposit will be added to the user's total committed balance and increase their chances of winning
   * proportional to the total committed balance of all users.
   * @param _amount The amount of the token underlying the cToken to deposit.
   */
  function depositPool(uint256 _amount) public requireOpenDraw unlessPaused nonReentrant {
    // Transfer the tokens into this contract
    require(token().transferFrom(msg.sender, address(this), _amount), "Pool/t-fail");

    // Deposit the funds
    _depositPoolFrom(msg.sender, _amount);
  }

  function _depositSponsorshipFrom(address _spender, uint256 _amount) internal {
    // Deposit the funds
    _depositFrom(_spender, _amount);

    emit SponsorshipDeposited(_spender, _amount);
  }

  function _depositPoolFrom(address _spender, uint256 _amount) internal {
    // Update the user's eligibility
    drawState.deposit(_spender, _amount);

    _depositFrom(_spender, _amount);

    emit Deposited(_spender, _amount);
  }

  function _depositPoolFromCommitted(address _spender, uint256 _amount) internal notLocked {
    // Update the user's eligibility
    drawState.depositCommitted(_spender, _amount);

    _depositFrom(_spender, _amount);

    emit DepositedAndCommitted(_spender, _amount);
  }

  function _depositFrom(address _spender, uint256 _amount) internal {
    // Update the user's balance
    balances[_spender] = balances[_spender].add(_amount);

    // Update the total of this contract
    accountedBalance = accountedBalance.add(_amount);

    // Deposit into Compound
    require(token().approve(address(cToken), _amount), "Pool/approve");
    require(cToken.mint(_amount) == 0, "Pool/supply");
  }

  /**
   * @notice Withdraw the sender's entire balance back to them.
   */
  function withdraw() public nonReentrant notLocked {

    uint256 sponsorshipAndFees = sponsorshipAndFeeBalanceOf(msg.sender);
    uint256 openBalance = drawState.openBalanceOf(msg.sender);
    uint256 committedBalance = drawState.committedBalanceOf(msg.sender);

    uint balance = balances[msg.sender];
    // Update their chances of winning
    drawState.withdraw(msg.sender);
    _withdraw(msg.sender, balance);

    if (address(poolToken) != address(0)) {
      poolToken.poolRedeem(msg.sender, committedBalance);
    }

    emit SponsorshipAndFeesWithdrawn(msg.sender, sponsorshipAndFees);
    emit OpenDepositWithdrawn(msg.sender, openBalance);
    emit CommittedDepositWithdrawn(msg.sender, committedBalance);
    emit Withdrawn(msg.sender, balance);
  }

  /**
   * Withdraws only from the sender's sponsorship and fee balances
   * @param _amount The amount to withdraw
   */
  function withdrawSponsorshipAndFee(uint256 _amount) public {
    uint256 sponsorshipAndFees = sponsorshipAndFeeBalanceOf(msg.sender);
    require(_amount <= sponsorshipAndFees, "Pool/exceeds-sfee");
    _withdraw(msg.sender, _amount);

    emit SponsorshipAndFeesWithdrawn(msg.sender, _amount);
  }

  /**
   * Returns the total balance of the users sponsorship and fees
   * @param _sender The user whose balance should be returned
   */
  function sponsorshipAndFeeBalanceOf(address _sender) public view returns (uint256) {
    return balances[_sender] - drawState.balanceOf(_sender);
  }

  /**
   * Withdraws from the users open deposits
   * @param _amount The amount to withdraw
   */
  function withdrawOpenDeposit(uint256 _amount) public {
    drawState.withdrawOpen(msg.sender, _amount);
    _withdraw(msg.sender, _amount);

    emit OpenDepositWithdrawn(msg.sender, _amount);
  }

  /**
   * Withdraws from the users committed deposits
   * @param _amount The amount to withdraw
   */
  function withdrawCommittedDeposit(uint256 _amount) external notLocked returns (bool)  {
    _withdrawCommittedDepositAndEmit(msg.sender, _amount);
    if (address(poolToken) != address(0)) {
      poolToken.poolRedeem(msg.sender, _amount);
    }
    return true;
  }

  /**
   * Allows the associated PoolToken to withdraw for a user; useful when redeeming through the token.
   * @param _from The user to withdraw from
   * @param _amount The amount to withdraw
   */
  function withdrawCommittedDeposit(
    address _from,
    uint256 _amount
  ) external onlyToken notLocked returns (bool)  {
    return _withdrawCommittedDepositAndEmit(_from, _amount);
  }

  /**
   * A function that withdraws committed deposits for a user and emit the corresponding events.
   * @param _from User to withdraw for
   * @param _amount The amount to withdraw
   */
  function _withdrawCommittedDepositAndEmit(address _from, uint256 _amount) internal returns (bool) {
    drawState.withdrawCommitted(_from, _amount);
    _withdraw(_from, _amount);

    emit CommittedDepositWithdrawn(_from, _amount);

    return true;
  }

  /**
   * Allows the associated PoolToken to move committed tokens from one user to another.
   */
  function moveCommitted(
    address _from,
    address _to,
    uint256 _amount
  ) external onlyToken onlyCommittedBalanceGteq(_from, _amount) notLocked returns (bool) {
    balances[_from] = balances[_from].sub(_amount, "move could not sub amount");
    balances[_to] = balances[_to].add(_amount);
    drawState.withdrawCommitted(_from, _amount);
    drawState.depositCommitted(_to, _amount);

    return true;
  }

  /**
   * @notice Transfers tokens from the cToken contract to the sender.  Updates the accounted balance.
   */
  function _withdraw(address _sender, uint256 _amount) internal {
    uint balance = balances[_sender];

    require(_amount <= balance, "Pool/no-funds");

    // Update the user's balance
    balances[_sender] = balance.sub(_amount);

    // Update the total of this contract
    accountedBalance = accountedBalance.sub(_amount);

    // Withdraw from Compound and transfer
    require(cToken.redeemUnderlying(_amount) == 0, "Pool/redeem");
    require(token().transfer(_sender, _amount), "Pool/transfer");
  }

  /**
   * @notice Returns the id of the current open Draw.
   * @return The current open Draw id
   */
  function currentOpenDrawId() public view returns (uint256) {
    return drawState.openDrawIndex;
  }

  /**
   * @notice Returns the id of the current committed Draw.
   * @return The current committed Draw id
   */
  function currentCommittedDrawId() public view returns (uint256) {
    if (drawState.openDrawIndex > 1) {
      return drawState.openDrawIndex - 1;
    } else {
      return 0;
    }
  }

  /**
   * @notice Returns whether the current committed draw has been rewarded
   * @return True if the current committed draw has been rewarded, false otherwise
   */
  function currentCommittedDrawHasBeenRewarded() internal view returns (bool) {
    Draw storage draw = draws[currentCommittedDrawId()];
    return draw.entropy != bytes32(0);
  }

  /**
   * @notice Gets information for a given draw.
   * @param _drawId The id of the Draw to retrieve info for.
   * @return Fields including:
   *  feeFraction: the fee fraction
   *  feeBeneficiary: the beneficiary of the fee
   *  openedBlock: The block at which the draw was opened
   *  secretHash: The hash of the secret committed to this draw.
   */
  function getDraw(uint256 _drawId) public view returns (
    uint256 feeFraction,
    address feeBeneficiary,
    uint256 openedBlock,
    bytes32 secretHash,
    bytes32 entropy,
    address winner,
    uint256 netWinnings,
    uint256 fee
  ) {
    Draw storage draw = draws[_drawId];
    feeFraction = draw.feeFraction;
    feeBeneficiary = draw.feeBeneficiary;
    openedBlock = draw.openedBlock;
    secretHash = draw.secretHash;
    entropy = draw.entropy;
    winner = draw.winner;
    netWinnings = draw.netWinnings;
    fee = draw.fee;
  }

  /**
   * @notice Returns the total of the address's balance in committed Draws.  That is, the total that contributes to their chances of winning.
   * @param _addr The address of the user
   * @return The total committed balance for the user
   */
  function committedBalanceOf(address _addr) external view returns (uint256) {
    return drawState.committedBalanceOf(_addr);
  }

  /**
   * @notice Returns the total of the address's balance in the open Draw.  That is, the total that will *eventually* contribute to their chances of winning.
   * @param _addr The address of the user
   * @return The total open balance for the user
   */
  function openBalanceOf(address _addr) external view returns (uint256) {
    return drawState.openBalanceOf(_addr);
  }

  /**
   * @notice Returns a user's total balance.  This includes their sponsorships, fees, open deposits, and committed deposits.
   * @param _addr The address of the user to check.
   * @return The users's current balance.
   */
  function totalBalanceOf(address _addr) external view returns (uint256) {
    return balances[_addr];
  }

  /**
   * @notice Returns a user's total balance, including both committed Draw balance and open Draw balance.
   * @param _addr The address of the user to check.
   * @return The users's current balance.
   */
  function balanceOf(address _addr) external view returns (uint256) {
    return drawState.committedBalanceOf(_addr);
  }

  /**
   * @notice Calculates a winner using the passed entropy for the current committed balances.
   * @param _entropy The entropy to use to select the winner
   * @return The winning address
   */
  function calculateWinner(bytes32 _entropy) public view returns (address) {
    return drawState.drawWithEntropy(_entropy);
  }

  /**
   * @notice Returns the total committed balance.  Used to compute an address's chances of winning.
   * @return The total committed balance.
   */
  function committedSupply() public view returns (uint256) {
    return drawState.committedSupply();
  }

  /**
   * @notice Returns the total open balance.  This balance is the number of tickets purchased for the open draw.
   * @return The total open balance
   */
  function openSupply() public view returns (uint256) {
    return drawState.openSupply();
  }

  /**
   * @notice Calculates the total estimated interest earned for the given number of blocks
   * @param _blocks The number of block that interest accrued for
   * @return The total estimated interest as a 18 point fixed decimal.
   */
  function estimatedInterestRate(uint256 _blocks) public view returns (uint256) {
    return supplyRatePerBlock().mul(_blocks);
  }

  /**
   * @notice Convenience function to return the supplyRatePerBlock value from the money market contract.
   * @return The cToken supply rate per block
   */
  function supplyRatePerBlock() public view returns (uint256) {
    return cToken.supplyRatePerBlock();
  }

  /**
   * @notice Sets the beneficiary fee fraction for subsequent Draws.
   * Fires the NextFeeFractionChanged event.
   * Can only be called by an admin.
   * @param _feeFraction The fee fraction to use.
   * Must be between 0 and 1 and formatted as a fixed point number with 18 decimals (as in Ether).
   */
  function setNextFeeFraction(uint256 _feeFraction) public onlyAdmin {
    _setNextFeeFraction(_feeFraction);
  }

  function _setNextFeeFraction(uint256 _feeFraction) internal {
    require(_feeFraction <= 1 ether, "Pool/less-1");
    nextFeeFraction = _feeFraction;

    emit NextFeeFractionChanged(_feeFraction);
  }

  /**
   * @notice Sets the fee beneficiary for subsequent Draws.
   * Can only be called by admins.
   * @param _feeBeneficiary The beneficiary for the fee fraction.  Cannot be the 0 address.
   */
  function setNextFeeBeneficiary(address _feeBeneficiary) public onlyAdmin {
    _setNextFeeBeneficiary(_feeBeneficiary);
  }

  function _setNextFeeBeneficiary(address _feeBeneficiary) internal {
    require(_feeBeneficiary != address(0), "Pool/not-zero");
    nextFeeBeneficiary = _feeBeneficiary;

    emit NextFeeBeneficiaryChanged(_feeBeneficiary);
  }

  /**
   * @notice Adds an administrator.
   * Can only be called by administrators.
   * Fires the AdminAdded event.
   * @param _admin The address of the admin to add
   */
  function addAdmin(address _admin) public onlyAdmin {
    _addAdmin(_admin);
  }

  /**
   * @notice Checks whether a given address is an administrator.
   * @param _admin The address to check
   * @return True if the address is an admin, false otherwise.
   */
  function isAdmin(address _admin) public view returns (bool) {
    return admins.has(_admin);
  }

  function _addAdmin(address _admin) internal {
    admins.add(_admin);

    emit AdminAdded(_admin);
  }

  /**
   * @notice Removes an administrator
   * Can only be called by an admin.
   * Admins cannot remove themselves.  This ensures there is always one admin.
   * @param _admin The address of the admin to remove
   */
  function removeAdmin(address _admin) public onlyAdmin {
    require(admins.has(_admin), "Pool/no-admin");
    require(_admin != msg.sender, "Pool/remove-self");
    admins.remove(_admin);

    emit AdminRemoved(_admin);
  }

  modifier requireCommittedNoReward() {
    require(currentCommittedDrawId() > 0, "Pool/committed");
    require(!currentCommittedDrawHasBeenRewarded(), "Pool/already");
    _;
  }

  /**
   * @notice Returns the token underlying the cToken.
   * @return An ERC20 token address
   */
  function token() public view returns (IERC20) {
    return IERC20(cToken.underlying());
  }

  /**
   * @notice Returns the underlying balance of this contract in the cToken.
   * @return The cToken underlying balance for this contract.
   */
  function balance() public returns (uint256) {
    return cToken.balanceOfUnderlying(address(this));
  }

  /**
   * @notice Locks the movement of tokens (essentially the committed deposits and winnings)
   * @dev The lock only lasts for a duration of blocks.  The lock cannot be relocked until the cooldown duration completes.
   */
  function lockTokens() public onlyAdmin {
    blocklock.lock(block.number);
  }

  /**
   * @notice Unlocks the movement of tokens (essentially the committed deposits)
   */
  function unlockTokens() public onlyAdmin {
    blocklock.unlock(block.number);
  }

  /**
   * Pauses all deposits into the contract.  This was added so that we can slowly deprecate Pools.  Users can continue
   * to collect rewards, but eventually the Pool will grow smaller.
   */
  function pause() public unlessPaused onlyAdmin {
    paused = true;

    emit Paused(msg.sender);
  }

  /**
   * Unpauses all deposits into the contract
   */
  function unpause() public whenPaused onlyAdmin {
    paused = false;

    emit Unpaused(msg.sender);
  }

  function isLocked() public view returns (bool) {
    return blocklock.isLocked(block.number);
  }

  function lockEndAt() public view returns (uint256) {
    return blocklock.lockEndAt();
  }

  function cooldownEndAt() public view returns (uint256) {
    return blocklock.cooldownEndAt();
  }

  function canLock() public view returns (bool) {
    return blocklock.canLock(block.number);
  }

  function lockDuration() public view returns (uint256) {
    return blocklock.lockDuration;
  }

  function cooldownDuration() public view returns (uint256) {
    return blocklock.cooldownDuration;
  }

  modifier notLocked() {
    require(!blocklock.isLocked(block.number), "Pool/locked");
    _;
  }

  modifier onlyLocked() {
    require(blocklock.isLocked(block.number), "Pool/unlocked");
    _;
  }

  modifier onlyAdmin() {
    require(admins.has(msg.sender), "Pool/admin");
    _;
  }

  modifier requireOpenDraw() {
    require(currentOpenDrawId() != 0, "Pool/no-open");
    _;
  }

  modifier whenPaused() {
    require(paused, "Pool/be-paused");
    _;
  }

  modifier unlessPaused() {
    require(!paused, "Pool/not-paused");
    _;
  }

  modifier onlyToken() {
    require(msg.sender == address(poolToken), "Pool/only-token");
    _;
  }

  modifier onlyCommittedBalanceGteq(address _from, uint256 _amount) {
    uint256 committedBalance = drawState.committedBalanceOf(_from);
    require(_amount <= committedBalance, "not enough funds");
    _;
  }
}





contract ScdMcdMigration {
    SaiTubLike                  public tub;
    VatLike                     public vat;
    ManagerLike                 public cdpManager;
    JoinLike                    public saiJoin;
    JoinLike                    public wethJoin;
    JoinLike                    public daiJoin;

    constructor(
        address tub_,           // SCD tub contract address
        address cdpManager_,    // MCD manager contract address
        address saiJoin_,       // MCD SAI collateral adapter contract address
        address wethJoin_,      // MCD ETH collateral adapter contract address
        address daiJoin_        // MCD DAI adapter contract address
    ) public {
        tub = SaiTubLike(tub_);
        cdpManager = ManagerLike(cdpManager_);
        vat = VatLike(cdpManager.vat());
        saiJoin = JoinLike(saiJoin_);
        wethJoin = JoinLike(wethJoin_);
        daiJoin = JoinLike(daiJoin_);

        require(wethJoin.gem() == tub.gem(), "non-matching-weth");
        require(saiJoin.gem() == tub.sai(), "non-matching-sai");

        tub.gov().approve(address(tub), uint(-1));
        tub.skr().approve(address(tub), uint(-1));
        tub.sai().approve(address(tub), uint(-1));
        tub.sai().approve(address(saiJoin), uint(-1));
        wethJoin.gem().approve(address(wethJoin), uint(-1));
        daiJoin.dai().approve(address(daiJoin), uint(-1));
        vat.hope(address(daiJoin));
    }

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    // Function to swap SAI to DAI
    // This function is to be used by users that want to get new DAI in exchange of old one (aka SAI)
    // wad amount has to be <= the value pending to reach the debt ceiling (the minimum between general and ilk one)
    function swapSaiToDai(
        uint wad
    ) external {
        // Get wad amount of SAI from user's wallet:
        saiJoin.gem().transferFrom(msg.sender, address(this), wad);
        // Join the SAI wad amount to the `vat`:
        saiJoin.join(address(this), wad);
        // Lock the SAI wad amount to the CDP and generate the same wad amount of DAI
        vat.frob(saiJoin.ilk(), address(this), address(this), address(this), toInt(wad), toInt(wad));
        // Send DAI wad amount as a ERC20 token to the user's wallet
        daiJoin.exit(msg.sender, wad);
    }

    // Function to swap DAI to SAI
    // This function is to be used by users that want to get SAI in exchange of DAI
    // wad amount has to be <= the amount of SAI locked (and DAI generated) in the migration contract SAI CDP
    function swapDaiToSai(
        uint wad
    ) external {
        // Get wad amount of DAI from user's wallet:
        daiJoin.dai().transferFrom(msg.sender, address(this), wad);
        // Join the DAI wad amount to the vat:
        daiJoin.join(address(this), wad);
        // Payback the DAI wad amount and unlocks the same value of SAI collateral
        vat.frob(saiJoin.ilk(), address(this), address(this), address(this), -toInt(wad), -toInt(wad));
        // Send SAI wad amount as a ERC20 token to the user's wallet
        saiJoin.exit(msg.sender, wad);
    }

    // Function to migrate a SCD CDP to MCD one (needs to be used via a proxy so the code can be kept simpler). Check MigrationProxyActions.sol code for usage.
    // In order to use migrate function, SCD CDP debtAmt needs to be <= SAI previously deposited in the SAI CDP * (100% - Collateralization Ratio)
    function migrate(
        bytes32 cup
    ) external returns (uint cdp) {
        // Get values
        uint debtAmt = tub.tab(cup);    // CDP SAI debt
        uint pethAmt = tub.ink(cup);    // CDP locked collateral
        uint ethAmt = tub.bid(pethAmt); // CDP locked collateral equiv in ETH

        // Take SAI out from MCD SAI CDP. For this operation is necessary to have a very low collateralization ratio
        // This is not actually a problem as this ilk will only be accessed by this migration contract,
        // which will make sure to have the amounts balanced out at the end of the execution.
        vat.frob(
            bytes32(saiJoin.ilk()),
            address(this),
            address(this),
            address(this),
            -toInt(debtAmt),
            0
        );
        saiJoin.exit(address(this), debtAmt); // SAI is exited as a token

        // Shut SAI CDP and gets WETH back
        tub.shut(cup);      // CDP is closed using the SAI just exited and the MKR previously sent by the user (via the proxy call)
        tub.exit(pethAmt);  // Converts PETH to WETH

        // Open future user's CDP in MCD
        cdp = cdpManager.open(wethJoin.ilk(), address(this));

        // Join WETH to Adapter
        wethJoin.join(cdpManager.urns(cdp), ethAmt);

        // Lock WETH in future user's CDP and generate debt to compensate the SAI used to paid the SCD CDP
        (, uint rate,,,) = vat.ilks(wethJoin.ilk());
        cdpManager.frob(
            cdp,
            toInt(ethAmt),
            toInt(mul(debtAmt, 10 ** 27) / rate + 1) // To avoid rounding issues we add an extra wei of debt
        );
        // Move DAI generated to migration contract (to recover the used funds)
        cdpManager.move(cdp, address(this), mul(debtAmt, 10 ** 27));
        // Re-balance MCD SAI migration contract's CDP
        vat.frob(
            bytes32(saiJoin.ilk()),
            address(this),
            address(this),
            address(this),
            0,
            -toInt(debtAmt)
        );

        // Set ownership of CDP to the user
        cdpManager.give(cdp, msg.sender);
    }
}




/**
 * @dev Interface of the ERC777TokensRecipient standard as defined in the EIP.
 *
 * Accounts can be notified of {IERC777} tokens being sent to them by having a
 * contract implement this interface (contract holders can be their own
 * implementer) and registering it on the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 global registry].
 *
 * See {IERC1820Registry} and {ERC1820Implementer}.
 */



/**
 * @title MCDAwarePool
 * @author Brendan Asselstine brendan@pooltogether.us
 * @notice This contract is a Pool that is aware of the new Multi-Collateral Dai.  It uses the ERC777Recipient interface to
 * detect if it's being transferred tickets from the old single collateral Dai (Sai) Pool.  If it is, it migrates the Sai to Dai
 * and immediately deposits the new Dai as committed tickets for that user.  We are knowingly bypassing the committed period for
 * users to encourage them to migrate to the MCD Pool.
 */
contract MCDAwarePool is BasePool, IERC777Recipient {
  IERC1820Registry constant internal ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

  // keccak256("ERC777TokensRecipient")
  bytes32 constant internal TOKENS_RECIPIENT_INTERFACE_HASH =
      0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

  /**
   * @notice The address of the ScdMcdMigration contract (see https://github.com/makerdao/developerguides/blob/master/mcd/upgrading-to-multi-collateral-dai/upgrading-to-multi-collateral-dai.md#direct-integration-with-smart-contracts)
   */
  ScdMcdMigration public scdMcdMigration;

  /**
   * @notice The address of the Sai Pool contract
   */
  MCDAwarePool public saiPool;

  /**
   * @notice Initializes the contract.
   * @param _owner The initial administrator of the contract
   * @param _cToken The Compound cToken to bind this Pool to
   * @param _feeFraction The fraction of the winnings to give to the beneficiary
   * @param _feeBeneficiary The beneficiary who receives the fee
   */
  function init (
    address _owner,
    address _cToken,
    uint256 _feeFraction,
    address _feeBeneficiary,
    uint256 lockDuration,
    uint256 cooldownDuration
  ) public initializer {
    super.init(
      _owner,
      _cToken,
      _feeFraction,
      _feeBeneficiary,
      lockDuration,
      cooldownDuration
    );
    initRegistry();
    initBlocklock(lockDuration, cooldownDuration);
  }

  /**
   * @notice Used to initialze the BasePool contract after an upgrade.  Registers the MCDAwarePool with the ERC1820 registry so that it can receive tokens, and inits the block lock.
   */
  function initMCDAwarePool(uint256 lockDuration, uint256 cooldownDuration) public {
    initRegistry();
    if (blocklock.lockDuration == 0) {
      initBlocklock(lockDuration, cooldownDuration);
    }
  }

  function initRegistry() internal {
    ERC1820_REGISTRY.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
  }

  function initMigration(ScdMcdMigration _scdMcdMigration, MCDAwarePool _saiPool) public onlyAdmin {
    _initMigration(_scdMcdMigration, _saiPool);
  }

  function _initMigration(ScdMcdMigration _scdMcdMigration, MCDAwarePool _saiPool) internal {
    require(address(scdMcdMigration) == address(0), "Pool/init");
    require(address(_scdMcdMigration) != address(0), "Pool/mig-def");
    scdMcdMigration = _scdMcdMigration;
    saiPool = _saiPool; // may be null
  }

  /**
   * @notice Called by an ERC777 token when tokens are sent, transferred, or minted.  If the sender is the original Sai Pool
   * and this pool is bound to the Dai token then it will accept the transfer, migrate the tokens, and deposit on behalf of
   * the sender.  It will reject all other tokens.
   *
   * If there is a committed draw this function will mint the user tickets immediately, otherwise it will place them in the
   * open prize.  This is to encourage migration.
   *
   * @param from The sender
   * @param amount The amount they are transferring
   */
  function tokensReceived(
    address, // operator
    address from,
    address, // to address can't be anything but us because we don't implement ERC1820ImplementerInterface
    uint256 amount,
    bytes calldata,
    bytes calldata
  ) external unlessPaused {
    require(msg.sender == address(saiPoolToken()), "Pool/sai-only");
    require(address(token()) == address(daiToken()), "Pool/not-dai");

    // cash out of the Pool.  This call transfers sai to this contract
    saiPoolToken().redeem(amount, '');

    // approve of the transfer to the migration contract
    saiToken().approve(address(scdMcdMigration), amount);

    // migrate the sai to dai.  The contract now has dai
    scdMcdMigration.swapSaiToDai(amount);

    if (currentCommittedDrawId() > 0) {
      // now deposit the dai as tickets
      _depositPoolFromCommitted(from, amount);
    } else {
      _depositPoolFrom(from, amount);
    }
  }

  function saiPoolToken() internal view returns (PoolToken) {
    if (address(saiPool) != address(0)) {
      return saiPool.poolToken();
    } else {
      return PoolToken(0);
    }
  }

  function saiToken() public returns (GemLike) {
    return scdMcdMigration.saiJoin().gem();
  }

  function daiToken() public returns (GemLike) {
    return scdMcdMigration.daiJoin().dai();
  }
}