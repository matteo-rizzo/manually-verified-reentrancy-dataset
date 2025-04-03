// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "./IFeeDistributor.sol";

contract LiquidVault is Ownable {
  /** Emitted when purchaseLP() is called to track ETH amounts */
  event EthTransferred(
      address from,
      uint amount,
      uint percentageAmount
  );

  /** Emitted when purchaseLP() is called and LP tokens minted */
  event LPQueued(
      address holder,
      uint amount,
      uint eth,
      uint infinityToken,
      uint timestamp
  );

  /** Emitted when claimLP() is called */
  event LPClaimed(
      address holder,
      uint amount,
      uint timestamp,
      uint exitFee,
      bool claimed
  );

  struct LPbatch {
      address holder;
      uint amount;
      uint timestamp;
      bool claimed;
  }

  struct LiquidVaultConfig {
      address infinityToken;
      IUniswapV2Router02 uniswapRouter;
      IUniswapV2Pair tokenPair;
      IFeeDistributor feeDistributor;
      address weth;
      address payable feeReceiver;
      uint32 stakeDuration;
      uint8 donationShare; //0-100
      uint8 purchaseFee; //0-100
  }
  
  bool public forceUnlock;
  bool private locked;

  modifier lock {
      require(!locked, "LiquidVault: reentrancy violation");
      locked = true;
      _;
      locked = false;
  }

  LiquidVaultConfig public config;

  mapping(address => LPbatch[]) public lockedLP;
  mapping(address => uint) public queueCounter;

  function seed(
      uint32 duration,
      address infinityToken,
      address uniswapPair,
      address uniswapRouter,
      address feeDistributor,
      address payable feeReceiver,
      uint8 donationShare, // LP Token
      uint8 purchaseFee // ETH
  ) public onlyOwner {
      config.infinityToken = infinityToken;
      config.uniswapRouter = IUniswapV2Router02(uniswapRouter);
      config.tokenPair = IUniswapV2Pair(uniswapPair);
      config.feeDistributor = IFeeDistributor(feeDistributor);
      config.weth = config.uniswapRouter.WETH();
      setFeeReceiverAddress(feeReceiver);
      setParameters(duration, donationShare, purchaseFee);
  }

  function getStakeDuration() public view returns (uint) {
      return forceUnlock ? 0 : config.stakeDuration;
  }

  // Could not be canceled if activated
  function enableLPForceUnlock() public onlyOwner {
      forceUnlock = true;
  }

  function setFeeReceiverAddress(address payable feeReceiver) public onlyOwner {
      require(
          feeReceiver != address(0),
          "LiquidVault: ETH receiver is zero address"
      );

      config.feeReceiver = feeReceiver;
  }

  function setParameters(uint32 duration, uint8 donationShare, uint8 purchaseFee)
      public
      onlyOwner
  {
      require(
          donationShare <= 100,
          "LiquidVault: donation share % between 0 and 100"
      );
      require(
          purchaseFee <= 100,
          "LiquidVault: purchase fee share % between 0 and 100"
      );

      config.stakeDuration = duration * 1 days;
      config.donationShare = donationShare;
      config.purchaseFee = purchaseFee;
  }

  function purchaseLPFor(address beneficiary) public payable lock {
      config.feeDistributor.distributeFees();
      require(msg.value > 0, "LiquidVault: ETH required to mint INFINITY LP");

      uint feeValue = (config.purchaseFee * msg.value) / 100;
      uint exchangeValue = msg.value - feeValue;

      (uint reserve1, uint reserve2, ) = config.tokenPair.getReserves();

      uint infinityRequired;

      if (address(config.infinityToken) < address(config.weth)) {
          infinityRequired = config.uniswapRouter.quote(
              exchangeValue,
              reserve2,
              reserve1
          );
      } else {
          infinityRequired = config.uniswapRouter.quote(
              exchangeValue,
              reserve1,
              reserve2
          );
      }

      uint balance = IERC20(config.infinityToken).balanceOf(address(this));
      require(
          balance >= infinityRequired,
          "LiquidVault: insufficient INFINITY tokens in LiquidVault"
      );

      IWETH(config.weth).deposit{ value: exchangeValue }();
      address tokenPairAddress = address(config.tokenPair);
      IWETH(config.weth).transfer(tokenPairAddress, exchangeValue);
      IERC20(config.infinityToken).transfer(
          tokenPairAddress,
          infinityRequired
      );

      uint liquidityCreated = config.tokenPair.mint(address(this));
      config.feeReceiver.transfer(feeValue);

      lockedLP[beneficiary].push(
          LPbatch({
              holder: beneficiary,
              amount: liquidityCreated,
              timestamp: block.timestamp,
              claimed: false
          })
      );

      emit LPQueued(
          beneficiary,
          liquidityCreated,
          exchangeValue,
          infinityRequired,
          block.timestamp
      );

      emit EthTransferred(msg.sender, exchangeValue, feeValue);
  }

  //send ETH to match with INFINITY tokens in LiquidVault
  function purchaseLP() public payable {
      purchaseLPFor(msg.sender);
  }

  function claimLP() public {
      uint next = queueCounter[msg.sender];
      require(
          next < lockedLP[msg.sender].length,
          "LiquidVault: nothing to claim."
      );
      LPbatch storage batch = lockedLP[msg.sender][next];
      require(
          block.timestamp - batch.timestamp > getStakeDuration(),
          "LiquidVault: LP still locked."
      );
      next++;
      queueCounter[msg.sender] = next;
      uint donation = (config.donationShare * batch.amount) / 100;
      batch.claimed = true;
      emit LPClaimed(msg.sender, batch.amount, block.timestamp, donation, batch.claimed);
      require(
          config.tokenPair.transfer(address(0), donation),
          "LiquidVault: donation transfer failed in LP claim."
      );
      require(
          config.tokenPair.transfer(batch.holder, batch.amount - donation),
          "LiquidVault: transfer failed in LP claim."
      );
  }

  function lockedLPLength(address holder) public view returns (uint) {
      return lockedLP[holder].length;
  }

  function getLockedLP(address holder, uint position)
      public
      view
      returns (
          address,
          uint,
          uint,
          bool
      )
  {
      LPbatch memory batch = lockedLP[holder][position];
      return (batch.holder, batch.amount, batch.timestamp, batch.claimed);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";
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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

pragma solidity 0.7.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.5.0;



pragma solidity >=0.5.0;





// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.6.2;



{
  "optimizer": {
    "enabled": true,
    "runs": 200
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}