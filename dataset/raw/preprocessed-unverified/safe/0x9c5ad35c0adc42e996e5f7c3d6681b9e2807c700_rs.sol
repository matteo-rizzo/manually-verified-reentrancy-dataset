/**
 *Submitted for verification at Etherscan.io on 2020-12-05
*/

pragma solidity ^0.6.0;


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


contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


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

    uint256[49] private __gap;
}




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */






contract FeeApprover is OwnableUpgradeSafe {
    using SafeMath for uint256;

    function initialize(
        address _TCOREAddress,
        address _WETHAddress,
        address _tcoreVaultAddress
    ) public initializer {
        OwnableUpgradeSafe.__Ownable_init();
        tcoreTokenAddress = _TCOREAddress;
        WETHAddress = _WETHAddress;
        tokenUniswapPair = IUniswapV2Factory(address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f)).getPair(WETHAddress,tcoreTokenAddress);
        tcoreVaultAddress = _tcoreVaultAddress;
        feePercentX100 = 15;
        paused = false; // We start paused until sync post LGE happens.
    }

    address tokenUniswapPair;
    IUniswapV2Factory public uniswapFactory;
    address internal WETHAddress;
    address tcoreTokenAddress;
    address tcoreVaultAddress;
    uint8 public feePercentX100;
    uint256 public lastTotalSupplyOfLPTokens;
    bool paused;

    // Pausing transfers of the token
    function setPaused(bool _pause) public onlyOwner {
        paused = _pause;
    }

    function setFeeMultiplier(uint8 _feeMultiplier) public onlyOwner {
        feePercentX100 = _feeMultiplier;
    }

    function setTcoreVaultAddress(address _tcoreVaultAddress) public onlyOwner {
        tcoreVaultAddress = _tcoreVaultAddress;
    }

    function sync() public {
        uint256 _LPSupplyOfPairTotal = IERC20(tokenUniswapPair).totalSupply();
        lastTotalSupplyOfLPTokens = _LPSupplyOfPairTotal;
    }

    function calculateAmountsAfterFee(
        address sender,
        address recipient, // unusued maybe use din future
        uint256 amount
    )
        public
        returns (
          uint256 transferToAmount,
          uint256 transferToFeeDistributorAmount
        )
    {
        require(paused == false, "FEE APPROVER: Transfers Paused");
        uint256 _LPSupplyOfPairTotal = IERC20(tokenUniswapPair).totalSupply();

        if(sender == tokenUniswapPair) {
            require(lastTotalSupplyOfLPTokens <= _LPSupplyOfPairTotal, "Liquidity withdrawals forbidden");
        }

        // Dont have a fee when tcoreVault is sending, or infinite loop
        // And when pair is sending ( buys are happening, do not tax on it)
        if(sender == tcoreVaultAddress || sender == tokenUniswapPair ) {
            console.log("Sending without fee");
            transferToFeeDistributorAmount = 0;
            transferToAmount = amount;
        } else {
            console.log("Normal fee transfer");
            transferToFeeDistributorAmount = amount.mul(feePercentX100).div(1000);
            transferToAmount = amount.sub(transferToFeeDistributorAmount);
        }

        lastTotalSupplyOfLPTokens = _LPSupplyOfPairTotal;
    }
}