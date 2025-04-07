/**
 *Submitted for verification at Etherscan.io on 2020-07-27
*/

// File: openzeppelin-solidity/contracts/math/SafeMath.sol
pragma solidity ^0.5.0;
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


// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */


// File: contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */


// File: contracts/atomic-swap/AtomicSwap.sol
contract AtomicSwap is Ownable {
    using SafeMath for uint256;

    enum Direction { Buy, Sell }
    enum SwapState {
        INVALID,
        OPEN,
        CLOSED,
        EXPIRED
    }

    struct Swap {
        uint256 price;
        uint256 amount;
        uint256 remainingAmount;
        Direction direction;
        address openTrader;
        SwapState swapState;
    }
    mapping (uint256 => Swap) private swaps;
    uint256 public minimumSellPrice = 0;
    uint256 public minimumBuyPrice = 0;
    uint256 public minimumTradePrice = 0;
    uint256 public minimumAmount = 100 ether;
    uint256 priceMultiplicator = 1000000; // 6 decimals price

    uint256 swapId = 0;
    IERC20 awgContract;
    IERC20 awxContract;
    event Open(uint256 swapId);
    event Trade(uint256 swapId, address taker, uint256 amount);
    event Close(uint256 swapId);

    constructor(address _awgContract, address _awxContract) public {
        awgContract = IERC20(_awgContract);
        awxContract = IERC20(_awxContract);
    }

    function setMinimumPrices(uint256 _buyPrice, uint256 _sellPrice, uint256 _tradePrice) onlyOwner public {
        minimumBuyPrice = _buyPrice;
        minimumSellPrice = _sellPrice;
        minimumTradePrice = _tradePrice;
    }
    function setMinimumAmount(uint256 _amount) onlyOwner public {
        minimumAmount = _amount;
    }

    function forceCloseSwap(uint256 _swapId) onlyOwner public {
        Swap memory swap = swaps[_swapId];
        swap.swapState = SwapState.CLOSED;
        swaps[_swapId] = swap;
        if (swap.direction == Direction.Buy) {
            require(awgContract.transfer(swap.openTrader,(swap.remainingAmount).mul(swap.price).div(priceMultiplicator)), "Cannot transfer AWG");
        } else {
            require(awxContract.transfer(swap.openTrader,swap.remainingAmount), "Cannot transfer AWX");
        }
        emit Close(_swapId);
    }

    function openSwap(uint256 _price, uint256 _amount, Direction _direction) public {
        require(_amount > minimumAmount, "Amount is too low");
        if (_direction == Direction.Buy) {
            require((_price > minimumBuyPrice || isOwner()), "Price is too low");
            require(_amount.mul(_price).div(priceMultiplicator) <= awgContract.allowance(msg.sender, address(this)), "Cannot transfer AWG");
            require(awgContract.transferFrom(msg.sender, address(this), _amount.mul(_price).div(priceMultiplicator)));
        } else {
            require((_price > minimumSellPrice || isOwner()), "Price is too low");
            require(_amount <= awxContract.allowance(msg.sender, address(this)), "Cannot transfer AWX");
            require(awxContract.transferFrom(msg.sender, address(this), _amount));
        }
        Swap memory swap = Swap({
            price: _price,
            amount: _amount,
            direction: _direction,
            remainingAmount: _amount,
            openTrader: msg.sender,
            swapState: SwapState.OPEN
            });

        swaps[swapId] = swap;
        emit Open(swapId);
        swapId++;
    }

    function closeSwap(uint256 _swapId) public {
        Swap memory swap = swaps[_swapId];
        require(swap.swapState == SwapState.OPEN);
        require(swap.openTrader == msg.sender);

        if (swap.direction == Direction.Buy) {
            require(awgContract.transfer(msg.sender,(swap.remainingAmount).mul(swap.price).div(priceMultiplicator)), "Cannot transfer AWG");
        } else {
            require(awxContract.transfer(msg.sender,swap.remainingAmount), "Cannot transfer AWX");
        }

        swap.swapState = SwapState.CLOSED;
        swaps[_swapId] = swap;
        emit Close(_swapId);
    }

    function tradeSwap(uint256 _swapId, uint256 _amount) public {
        require(_amount > minimumAmount, "Amount is too low");
        Swap memory swap = swaps[_swapId];
        require(_amount <= swap.remainingAmount);
        require((swap.price > minimumTradePrice || isOwner()), "The swap price is too low.");
        require(swap.swapState == SwapState.OPEN);
        if (swap.direction == Direction.Buy) {
            require(_amount <= awxContract.allowance(msg.sender, address(this)));
            require(awxContract.transferFrom(msg.sender, swap.openTrader, _amount));
            require(awgContract.transfer(msg.sender, _amount.mul(swap.price).div(priceMultiplicator)));
        } else {
            require(_amount.mul(swap.price).div(priceMultiplicator) <= awgContract.allowance(msg.sender, address(this)));
            require(awgContract.transferFrom(msg.sender, swap.openTrader, _amount.mul(swap.price).div(priceMultiplicator)));
            require(awxContract.transfer(msg.sender, _amount));
        }
        swap.remainingAmount -= _amount;
        if (swap.remainingAmount == 0) {
            swap.swapState = SwapState.CLOSED;
            emit Close(_swapId);
        }
        swaps[_swapId] = swap;
        emit Trade(_swapId, msg.sender, _amount);
    }

    function getSwap(uint256 _swapId) public view returns (uint256 price, uint256 amount, uint256 remainingAmount, Direction direction, address openTrader, SwapState swapState) {
        Swap memory swap = swaps[_swapId];
        return (swap.price, swap.amount, swap.remainingAmount, swap.direction, swap.openTrader, swap.swapState);
    }
}