/**
 *Submitted for verification at Etherscan.io on 2020-10-23
*/

pragma solidity 0.6.3;

contract Initializable {
  bool private initialized;
  bool private initializing;
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

  function isConstructor() private view returns (bool) {
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

contract ContextUpgradeSafe is Initializable {

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }

    uint256[50] private __gap;
}


contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}











contract FeeApprover is OwnableUpgradeSafe {
    using SafeMath for uint256;

    function initialize(
        address _QOREAddress,
        address _WETHAddress,
        address _qoreVaultAddress
    ) public initializer {
        OwnableUpgradeSafe.__Ownable_init();
        qoreTokenAddress = _QOREAddress;
        WETHAddress = _WETHAddress;
        tokenUniswapPair = IUniswapV2Factory(address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f)).getPair(WETHAddress,qoreTokenAddress);
        qoreVaultAddress = _qoreVaultAddress;
        feePercentX100 = 15;
        paused = false;
    }

    address tokenUniswapPair;
    IUniswapV2Factory public uniswapFactory;
    address internal WETHAddress;
    address qoreTokenAddress;
    address qoreVaultAddress;
    uint8 public feePercentX100;
    uint256 public lastTotalSupplyOfLPTokens;
    bool paused;

    function setPaused(bool _pause) public onlyOwner {
        paused = _pause;
    }

    function setFeeMultiplier(uint8 _feeMultiplier) public onlyOwner {
        feePercentX100 = _feeMultiplier;
    }

    function setQoreVaultAddress(address _qoreVaultAddress) public onlyOwner {
        qoreVaultAddress = _qoreVaultAddress;
    }

    function sync() public {
        uint256 _LPSupplyOfPairTotal = IERC20(tokenUniswapPair).totalSupply();
        lastTotalSupplyOfLPTokens = _LPSupplyOfPairTotal;
    }

    function calculateAmountsAfterFee(
        address sender,
        address recipient,
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

        if(sender == qoreVaultAddress || sender == tokenUniswapPair ) {
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