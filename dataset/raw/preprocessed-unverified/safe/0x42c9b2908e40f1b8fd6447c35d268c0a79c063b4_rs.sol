/**
 *Submitted for verification at Etherscan.io on 2020-06-26
*/

pragma solidity ^0.6.10;
pragma experimental ABIEncoderV2;




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
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}


contract ContextUpgradeable is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    function initialize() virtual public initializer { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract OwnableUpgradeable is ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize() override virtual public initializer {
        ContextUpgradeable.initialize();

        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}










contract dYdXWrapper is OwnableUpgradeable {
    IERC20 public constant DAI = IERC20(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    ISoloMargin public constant soloMargin = ISoloMargin(
        0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e
    );

    function initialize() public override initializer {
        OwnableUpgradeable.initialize();
        DAI.approve(address(soloMargin), 100000e18);
    }

    function deposit(uint256 value) external onlyOwner {
        Account.Info[] memory accounts = new Account.Info[](1);
        accounts[0] = Account.Info(address(this), 0);

        Actions.ActionArgs[] memory actions = new Actions.ActionArgs[](1);
        actions[0] = Actions.ActionArgs(
            Actions.ActionType.Deposit,
            0,
            Types.AssetAmount(
                true,
                Types.AssetDenomination.Wei,
                Types.AssetReference.Delta,
                value
            ),
            3,
            0,
            address(this),
            0,
            bytes("")
        );
        soloMargin.operate(accounts, actions);
    }

    function withdraw(uint256 value) external onlyOwner {
        Account.Info[] memory accounts = new Account.Info[](1);
        accounts[0] = Account.Info(address(this), 0);

        Actions.ActionArgs[] memory actions = new Actions.ActionArgs[](1);

        actions[0] = Actions.ActionArgs({
            actionType: Actions.ActionType.Withdraw,
            accountId: 0,
            amount: Types.AssetAmount({
                sign: false,
                denomination: Types.AssetDenomination.Wei,
                ref: Types.AssetReference.Delta,
                value: value
            }),
            primaryMarketId: 3,
            secondaryMarketId: 0,
            otherAddress: address(this),
            otherAccountId: 0,
            data: ""
        });
        soloMargin.operate(accounts, actions);
    }

    function me() public view returns (address) {
        return address(this);
    }

    function balance()
        external
        view
        returns (
            address[] memory,
            Types.Par[] memory,
            Types.Wei[] memory
        )
    {
        Account.Info memory account = Account.Info(address(this), 0);
        return soloMargin.getAccountBalances(account);
    }
}