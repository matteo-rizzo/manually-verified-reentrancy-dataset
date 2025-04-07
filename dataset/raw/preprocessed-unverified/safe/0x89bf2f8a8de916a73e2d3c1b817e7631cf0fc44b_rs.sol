/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// Dependency file: contracts/libraries/TransferHelper.sol

// SPDX-License-Identifier: MIT

// pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false



// Dependency file: contracts/uniswap/UniswapV2Router01.sol


/*
*   Copyright Uniswap
*/

// pragma solidity 0.6.12;




// Dependency file: contracts/uniswap/UniswapV2Router02.sol


/*
*   Copyright Uniswap
*/

// pragma solidity 0.6.12;

// import "contracts/uniswap/UniswapV2Router01.sol";


interface UniswapV2Router02 is UniswapV2Router01 {
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

// Dependency file: @openzeppelin/contracts/GSN/Context.sol


// pragma solidity ^0.6.0;

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


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/GSN/Context.sol";
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
contract Ownable is Context {
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


// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


// pragma solidity ^0.6.0;

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



// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Root file: contracts/periphery/KerberosExchange.sol


/*
*   Copyright 2020 @ Kerberos Finance Development Team
*   License: MIT
*
*   The Kerberos Exchange Order contracts
*/


pragma solidity 0.6.12;

// import "contracts/libraries/TransferHelper.sol";
// import "contracts/uniswap/UniswapV2Router02.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface KerberosToken is IERC20 {
    function mint(address, uint256) external;
}




contract KerberosExchange is Ownable {
    using SafeMath for uint256;

    address public kbrfToken;

    address public yfBetaSwap;

    // maximum mint amount is 10k KBRF
    uint256 constant public mintAllow = 10000e18;

    // total KBRF ordered
    uint256 public totalMinted;

    // release, allow users claim KBRF
    bool public released;

    // enable to make orders
    bool public enabled;

    // minimum amount of ETH can swap
    uint256 constant public minAllow = 1e17; // 0.1 ETH

    // maximum amount of ETH can swap
    uint256 constant public maxAllow = 5e18; // 5 ETH

    // user swap in bonusPrice in this period
    uint256 public bonusTimeEnd;

    // price in bonus time only
    // 1 KBRF = 0.04 ETH
    uint256 constant public bonusPrice = 4e16;

    // price after bonus period
    // 1 KBRF = 0.045 ETH
    uint256 constant public price = 45e15;

    // amount of KBRF user ordered
    mapping(address => uint256) public balances;
    mapping(address => uint256) public ethBalances;
    mapping(address => bool) public claimed;

    constructor(address _yfBetaSwap) public {
        yfBetaSwap = _yfBetaSwap;
    }

    function getPrice() public view returns(uint256) {
        if (now <= bonusTimeEnd) {
            return bonusPrice;
        } else {
            return price;
        }
    }

    // get total amount of KBRF of account
    // include yfBetaSwap amount
    function getBalance(address _account) public view returns(uint256) {
        uint256 balance = balances[_account];
        KerberosYfBetaSwap yfBetaSwapContract = KerberosYfBetaSwap(yfBetaSwap);
        balance = balance.add(yfBetaSwapContract.getTotalOrderedAmount(_account));
        return balance;
    }

    // function receive direct ETH from user
    receive() payable external {
        require(enabled, "ERROR: Exchange is disabled");
        require(msg.value >= minAllow, "ERROR: Amount must be greater than or equal to 0.1 ETH");
        require(msg.value <= maxAllow, "ERROR: Amount must be less than or equal to 5 ETH");
        uint256 currentPrice = getPrice();
        _exchange(msg.sender, msg.value, currentPrice);
    }

    // safe call this function
    function exchange() payable public {
        require(enabled, "ERROR: Exchange is disabled");
        require(msg.value >= minAllow, "ERROR: Amount must be greater than or equal to 0.1 ETH");
        require(msg.value <= maxAllow, "ERROR: Amount must be less than or equal to 5 ETH");
        uint256 currentPrice = getPrice();
        _exchange(msg.sender, msg.value, currentPrice);
    }

    function _exchange(address _user, uint256 _amount, uint256 _price) internal {
        uint256 expoAmount = _amount.mul(1e18);
        uint256 receiveAmount = expoAmount.div(_price);

        require(_amount + ethBalances[_user] <= maxAllow, "ERROR: Max buy amount per address must not be greater than 5 ETH");
        require(totalMinted + receiveAmount <= mintAllow, "ERROR: Not enough token for exchange");

        balances[_user] = balances[_user].add(receiveAmount);
        ethBalances[_user] = ethBalances[_user].add(_amount);
        totalMinted = totalMinted.add(receiveAmount);
    }

    // buyer claim KBRF token
    // made after KBRF released
    function claim() public {
        require(released, "ERROR: Not released yet");
        require(!claimed[msg.sender], "ERROR: Already claimed");

        KerberosToken kbrf = KerberosToken(kbrfToken);
        uint256 balance = getBalance(msg.sender);
        kbrf.mint(msg.sender, balance);

        claimed[msg.sender] = true;
    }

    function enable(uint256 _bonusTimeEnd) public onlyOwner {
        enabled = true;

        // 7 days in bonus price
        bonusTimeEnd = _bonusTimeEnd;
    }

    function release(address _kbrf) public onlyOwner {
        enabled = false;
        released = true;

        // set the token address
        kbrfToken = _kbrf;

        // distribute balance
        TransferHelper.safeTransferETH(owner(), address(this).balance);
    }
}