/**
 *Submitted for verification at Etherscan.io on 2021-08-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Token {
  function transfer(address recipient, uint256 amount) virtual external returns (bool);
  function airdrop(address recipient, uint256 amount) virtual public;
  function transferOwnership(address newOwner) virtual public;
}

abstract contract FiatContract {
  function USD(uint id) virtual public view returns (uint256);
}

contract MintySale is Ownable {
  using SafeMath for uint256;

  event TokenPurchase(
    address indexed source,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  Token public token;
  FiatContract public feed;
  address payable public wallet;
  uint256 public raised;
  bool public useAirdrop;

  constructor() {
    token = Token(0xBbd900e05b4aF2124390D206F70bc4E583B1bE85);
    feed = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591);
    wallet = payable(0x65E45efBB8F8b89320D401AddEb7beE7d62DB5Cf);
  }

  function setUseAirdrop(bool use) public onlyOwner() {
    useAirdrop = use;
  }

  function transferTokenOwnership(address newOwner) public onlyOwner() {
    token.transferOwnership(newOwner);
  }

  // FiatContract will report $0.01 USD worth of ETH
  function weiFromUsd() public view returns (uint256) {
    return feed.USD(0);
  }

  // 1 MINTY = $0.2.
  function convertWeiToMintys(uint256 weiAmount) public view returns (uint256) {
    uint256 rate = weiFromUsd();
    uint256 weiForMinty = rate.mul(20);
    return weiToMintys(weiAmount, weiForMinty);
  }

  function weiToMintys(uint256 weiAmount, uint256 weiForMinty) internal pure returns (uint256) {
    require(weiAmount > 0, "Amount must be greater than 0.");
    require(weiForMinty != 0, "Conversion rate cannot be 0.");
    uint256 mintyCents = weiAmount.mul(10 ** 9);
    return mintyCents.div(weiForMinty);
  }

  function buyTokens(address recipient) public payable {
    require(recipient != address(0));

    uint256 weiAmount = msg.value;
    uint256 mintys = convertWeiToMintys(weiAmount);

    require(mintys > 0, "Purchasing 0 MINTYS.");

    if (useAirdrop) {
      token.airdrop(recipient, mintys);
    } else {
      token.transfer(recipient, mintys);
    }

    raised = raised.add(weiAmount);
    wallet.transfer(weiAmount);

    emit TokenPurchase(msg.sender, recipient, weiAmount, mintys);
  }

  fallback() external payable {
    buyTokens(msg.sender);
  }

  receive() external payable {
    buyTokens(msg.sender);
  }
}