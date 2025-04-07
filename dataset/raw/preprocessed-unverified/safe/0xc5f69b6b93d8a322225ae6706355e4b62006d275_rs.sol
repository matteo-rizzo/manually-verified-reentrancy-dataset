/**
 *Submitted for verification at Etherscan.io on 2020-02-26
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


contract oCurveFlashLiquidate is ReentrancyGuard, Ownable, Structs {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  address public dydx;
  address public weth;
  address payable public _oToken;
  address payable public _vault;
  uint256 public _amount;

  constructor () public {
    dydx = address(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);
    weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  }

  function liquidate(uint256 amount, address payable vault, address payable oToken) public {
    _vault = vault;
    _amount = amount;
    _oToken = oToken;

    Info[] memory infos = new Info[](1);
    ActionArgs[] memory args = new ActionArgs[](3);

    infos[0] = Info(address(this), 0);

    AssetAmount memory wamt = AssetAmount(false, AssetDenomination.Wei, AssetReference.Delta, amount);
    ActionArgs memory withdraw;
    withdraw.actionType = ActionType.Withdraw;
    withdraw.accountId = 0;
    withdraw.amount = wamt;
    withdraw.primaryMarketId = 0;
    withdraw.otherAddress = address(this);

    args[0] = withdraw;

    ActionArgs memory call;
    call.actionType = ActionType.Call;
    call.accountId = 0;
    call.otherAddress = address(this);

    args[1] = call;

    ActionArgs memory deposit;
    AssetAmount memory damt = AssetAmount(true, AssetDenomination.Wei, AssetReference.Delta, amount.add(1));
    deposit.actionType = ActionType.Deposit;
    deposit.accountId = 0;
    deposit.amount = damt;
    deposit.primaryMarketId = 0;
    deposit.otherAddress = address(this);

    args[2] = deposit;

    DyDx(dydx).operate(infos, args);
  }

  function callFunction(
      address sender,
      Info memory accountInfo,
      bytes memory data
  ) public {
    OptionsContract oToken = OptionsContract(_oToken);
    require(oToken.isUnsafe(_vault), 'cannot liquidate a safe vault');

    WETH(weth).withdraw(_amount);

    uint256 tokensPerETH = oToken.maxOTokensIssuable(1e18);
    uint256 maxToLiquidate = oToken.maxOTokensLiquidatable(_vault); //100 * 1e15
    uint256 ethRequired = maxToLiquidate.mul(1e18).div(tokensPerETH);
    if (oToken.hasVault(address(this))) {
      oToken.addETHCollateralOption.value(ethRequired)(maxToLiquidate, address(this));
    } else {
      oToken.createETHCollateralOption.value(ethRequired)(maxToLiquidate, address(this));
    }
    oToken.liquidate(_vault, maxToLiquidate);

    WETH(weth).deposit.value(_amount)();
  }

  function() external payable {

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