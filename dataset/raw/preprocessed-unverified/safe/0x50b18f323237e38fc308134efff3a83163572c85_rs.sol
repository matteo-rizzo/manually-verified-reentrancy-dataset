/**
 *Submitted for verification at Etherscan.io on 2021-09-28
*/

/**
 *Submitted for verification at Etherscan.io on 2021-09-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//polygon plasma bridge


//polygon PoS bridge


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

/**
 * @title Telcoin, LLC.
 * @dev Implements Openzeppelin Audited Contracts
 *
 * @notice this contract is meant for forwarding ERC20 and ETH accross the polygon bridge system.
 * This contract is meant to be a logic contract to work in conjunction with a proxy network.
 */
contract RootBridgeRelay is Initializable {
  event Relay(address indexed destination, address indexed currency, uint256 amount);

  // mainnet plasma bridge
  IPlasmaBridge constant public PLASMA_BRIDGE = IPlasmaBridge(0x401F6c983eA34274ec46f84D70b31C151321188b);
  // mainnet PoS bridge
  IPOSBridge constant public POS_BRIDGE = IPOSBridge(0xA0c68C638235ee32657e8f720a23ceC1bFc77C77);
  // mainnet predicate
  address constant public PREDICATE_ADDRESS = 0x40ec5B33f54e0E8A33A975908C5BA1c14e5BbbDf;
  //ETHER address
  address constant public ETHER_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  //MATIC address
  address constant public MATIC_ADDRESS = 0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0;
  //max integer value
  uint256 constant public MAX_INT = 2**256 - 1;
  //polygon network receiving address
  address payable public recipient;

  /**
   * @notice initializes the contract its own address
   * @dev the recipient receives the same address as there will be a corresponding address on the adjoining network
   * @dev the reason for the use of the initialize function belonging to the initializable class
   * is to allow this contract to behave as the logic contract behind proxies.
   * @dev this function is called with proxy deployment to update state data
   * @dev uses initializer modifier to only allow one initialization per proxy
   */
  function initialize() public initializer() {
    recipient = payable(address(this));
  }

  /**
  * @notice pushes token transfers through to the appropriate bridge
  * @dev the contract is designed in a way where anyone can call the function without risking funds
  * @param token is address of the token that is desired to be pushed accross the bridge
  * @param amount is integer value of the quantity of the token
  * @return a boolean value indicating whether the operation succeeded.
  */
  function bridgeTransfer(IERC20 token, uint256 amount) external payable returns (bool) {
    if (address(token) == ETHER_ADDRESS) {
      transferETHToBridge(amount);
    } else if (address(token) == MATIC_ADDRESS) {
      transferERCToPlasmaBridge(amount);
    } else {
      transferERCToBridge(token, amount);
    }
    return true;
  }

  /**
  * @notice pushes token transfers through to the PoS bridge
  * @dev this is for ERC20 tokens that are not the matic token
  * @dev only tokens that are already mapped on the bridge will succeed
  * @param token is address of the token that is desired to be pushed accross the bridge
  * @param amount is integer value of the quantity of the token
  */
  function transferERCToBridge(IERC20 token, uint256 amount) internal {
    if (amount > token.allowance(recipient, PREDICATE_ADDRESS)) {approveERC20(token, PREDICATE_ADDRESS);}
    POS_BRIDGE.depositFor(recipient, address(token), abi.encodePacked(amount));
    emit Relay(recipient, address(token), amount);
  }

  /**
  * @notice pushes matic token transfers through to the plasma bridge
  * @dev this is for the matic token
  * @param amount is integer value of the quantity of the matic token
  */
  function transferERCToPlasmaBridge(uint256 amount) internal {
    if (amount > IERC20(MATIC_ADDRESS).allowance(recipient, address(PLASMA_BRIDGE))) {approveERC20(IERC20(MATIC_ADDRESS), address(PLASMA_BRIDGE));}
    PLASMA_BRIDGE.depositERC20ForUser(MATIC_ADDRESS, recipient, amount);
    emit Relay(recipient, MATIC_ADDRESS, amount);
  }

  /**
  * @notice pushes ETHER transfers through to the PoS bridge
  * @dev WETH will be minted to the recipient
  * @param amount is integer value of the quantity of ETH
  */
  function transferETHToBridge(uint256 amount) internal {
    require(amount <= recipient.balance, "RootBridgeRelay: insufficient balance");
    POS_BRIDGE.depositEtherFor{value: amount}(recipient);
    emit Relay(recipient, ETHER_ADDRESS, amount);
  }

  /**
  * @notice this approves any tokens for use by the bridge
  * @dev this function is called automatically when the allowance is not high enough for a particular token
  * @param token is address of the token needed to be approved
  * @param bridge is address of the token spender
  */
  function approveERC20(IERC20 token, address bridge) internal {
    require(token.approve(bridge, MAX_INT), "RootBridgeRelay: Failed to approve tokens");
  }

  /**
  * @notice receives ETHER
  */
  receive() external payable {}
}