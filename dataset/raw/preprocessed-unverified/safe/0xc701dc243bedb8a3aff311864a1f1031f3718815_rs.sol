/**
 *Submitted for verification at Etherscan.io on 2020-02-20
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;



contract Context {
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

contract ReentrancyGuard {
    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}









contract Structs {
    struct Val {
        uint256 value;
    }

    enum ActionType {
      Deposit,   // supply tokens
      Withdraw,  // borrow tokens
      Transfer,  // transfer balance between accounts
      Buy,       // buy an amount of some token (externally)
      Sell,      // sell an amount of some token (externally)
      Trade,     // trade tokens against another account
      Liquidate, // liquidate an undercollateralized or expiring account
      Vaporize,  // use excess tokens to zero-out a completely negative account
      Call       // send arbitrary data to an address
    }

    enum AssetDenomination {
        Wei // the amount is denominated in wei
    }

    enum AssetReference {
        Delta // the amount is given as a delta from the current value
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    struct Info {
        address owner;  // The address that owns the account
        uint256 number; // A nonce that allows a single address to control many accounts
    }

    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }
}

contract DyDx is Structs {
    function getAccountWei(Info memory account, uint256 marketId) public view returns (Wei memory);
    function operate(Info[] memory, ActionArgs[] memory) public;
}


contract CurveFlash is ReentrancyGuard, Ownable, Structs {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  address public swap;
  address public dydx;
  address public dai;
  address public usdc;
  uint256 public _amount;

  constructor () public {
    dydx = address(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);
    swap = address(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
    dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    approveToken();
  }

  function swapUSDCtoDAI(uint256 amount) public {
    _amount = amount;
    Info[] memory infos = new Info[](3);
    ActionArgs[] memory args = new ActionArgs[](3);

    infos[0] = Info(address(this), 0);
    infos[1] = Info(address(this), 0);
    infos[2] = Info(address(this), 0);

    AssetAmount memory amt = AssetAmount(false, AssetDenomination.Wei, AssetReference.Delta, amount);
    ActionArgs memory act;
    act.actionType = ActionType.Withdraw;
    act.accountId = 0;
    act.amount = amt;
    act.primaryMarketId = 2;
    act.otherAddress = address(this);

    args[0] = act;

    act.actionType = ActionType.Call;
    act.accountId = 0;
    act.otherAddress = address(this);

    args[1] = act;

    uint256 _dai = amount.mul(1e12);

    amt = AssetAmount(true, AssetDenomination.Wei, AssetReference.Delta, _dai);
    act.actionType = ActionType.Deposit;
    act.accountId = 0;
    act.amount = amt;
    act.primaryMarketId = 3;
    act.otherAddress = address(this);

    args[2] = act;

    DyDx(dydx).operate(infos, args);
  }

  function callFunction(
      address sender,
      Info memory accountInfo,
      bytes memory data
  ) public {
    ICurveFi(swap).exchange_underlying(1, 0, _amount, 0);
  }

  function() external payable {

  }

  function approveToken() public {
      IERC20(dai).safeApprove(swap, uint(-1));
      IERC20(dai).safeApprove(dydx, uint(-1));
      IERC20(usdc).safeApprove(swap, uint(-1));
      IERC20(usdc).safeApprove(dydx, uint(-1));
  }

  // incase of half-way error
  function inCaseTokenGetsStuck(IERC20 _TokenAddress) onlyOwner public {
      uint qty = _TokenAddress.balanceOf(address(this));
      _TokenAddress.safeTransfer(msg.sender, qty);
  }

  // incase of half-way error
  function inCaseETHGetsStuck() onlyOwner public{
      (bool result, ) = msg.sender.call.value(address(this).balance)("");
      require(result, "transfer of ETH failed");
  }
}