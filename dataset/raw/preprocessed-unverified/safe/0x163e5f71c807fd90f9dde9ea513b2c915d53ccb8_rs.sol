/**
 *Submitted for verification at Etherscan.io on 2020-11-05
*/

pragma solidity 0.5.17;

/*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Synthetix: WARRewards.sol
*
* Docs: https://docs.synthetix.io/
*
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



/**
 * @dev Collection of functions related to the address type
 */




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



contract IRewardDistributionRecipient is Ownable {
    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward, uint256 _duration) external;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution) external onlyOwner {
        rewardDistribution = _rewardDistribution;
    }
}

contract Betting2Choice is IRewardDistributionRecipient {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    enum Choice {
        Undecided,
        Choice1,
        Choice2
    }

    IERC20 public constant war = IERC20(0xf4A81C18816C9B0AB98FAC51B36Dcb63b0E58Fde);

    string public desc;
    uint256 public endTime;
    uint256 public lastClaimTime;

    bool public isPaused;
    bool public isCanceled;
    bool public isFinal;
    bool public isFeesClaimed;

    Choice public winner;

    mapping(address => uint256) public choice1ETHBet;
    mapping(address => uint256) public choice2ETHBet;
    mapping(address => uint256) public choice1WARBet;
    mapping(address => uint256) public choice2WARBet;

    uint256 public choice1ETHPot;
    uint256 public choice2ETHPot;
    uint256 public choice1WARPot;
    uint256 public choice2WARPot;

    event Choice1ETHBet(address indexed user, uint256 amount);
    event Choice2ETHBet(address indexed user, uint256 amount);
    event Choice1WARBet(address indexed user, uint256 amount);
    event Choice2WARBet(address indexed user, uint256 amount);

    event EarningsPaid(address indexed user, uint256 ethEarnings, uint256 warEarnings);

    modifier checkStatus() {
        require(!isFinal, "battle is decided");
        require(!isCanceled, "battle is canceled, claim your bet");
        require(!isPaused, "betting not started");
        require(block.timestamp < endTime, "betting has ended");
        _;
    }

    constructor(address _rewardDistribution, string memory _desc, uint256 _endTime) public {
        rewardDistribution = _rewardDistribution;
        desc = _desc;
        endTime = _endTime;
        lastClaimTime = _endTime + 1 days * 365 / 6; // 2 months
    }

    function ETHBet(Choice choice) public payable checkStatus {
        require(msg.value != 0, "no ether sent");
        if (choice == Choice.Choice1) {
            require(choice2ETHBet[msg.sender] == 0, "Sorry. You already bet on the other side with ETH!");
            choice1ETHBet[msg.sender] += msg.value;
            choice1ETHPot += msg.value;
            emit Choice1ETHBet(msg.sender, msg.value);
        } else if (choice == Choice.Choice2) {
            require(choice1ETHBet[msg.sender] == 0, "Sorry. You already bet on the other side with ETH!");
            choice2ETHBet[msg.sender] += msg.value;
            choice2ETHPot += msg.value;
            emit Choice2ETHBet(msg.sender, msg.value);
        } else {
            revert("invalid choice");
        }
    }

    function WARBet(Choice choice, uint256 amount) public checkStatus {
        require(amount != 0, "no token sent");
        if (choice == Choice.Choice1) {
            require(choice2WARBet[msg.sender] == 0, "Sorry. You already bet on the other side with WAR!");
            war.safeTransferFrom(msg.sender, address(this), amount);
            choice1WARBet[msg.sender] += amount;
            choice1WARPot += amount;
            emit Choice1WARBet(msg.sender, amount);
        } else if (choice == Choice.Choice2) {
            require(choice1WARBet[msg.sender] == 0, "Sorry. You already bet on the other side with WAR!");
            war.safeTransferFrom(msg.sender, address(this), amount);
            choice2WARBet[msg.sender] += amount;
            choice2WARPot += amount;
            emit Choice2WARBet(msg.sender, amount);
        } else {
            revert("invalid choice");
        }
    }

    function pauseBetting() external onlyRewardDistribution {
        isPaused = true;
    }
    function unpauseBetting() external onlyRewardDistribution {
        isPaused = false;
    }
    function cancelBattle() external onlyRewardDistribution {
        require(!isFinal, "battle is decided");
        isCanceled = true;
    }
    function finalizeBattle(Choice choice) external onlyRewardDistribution {
        require(!isFinal, "battle is decided");
        require(!isCanceled, "battle is canceled");
        require(choice == Choice.Choice1 || choice == Choice.Choice2, "invalid choice");
        winner = choice;
        isFinal = true;
    }
    function getFees() external onlyRewardDistribution returns (uint256 ethFees, uint256 warFees) {
        require(!isFeesClaimed, "fees claimed");
        if (isFinal) {
            isFeesClaimed = true;

            if (winner == Choice.Choice1) {
                ethFees = choice2ETHPot.mul(1e19).div(1e20);
                if (ethFees != 0) {
                    _safeTransfer(ethFees, true);
                }

                warFees = choice2WARPot.mul(1e19).div(1e20);
                if (warFees != 0) {
                    _safeTransfer(warFees, false);
                }
            } else if (winner == Choice.Choice2) {
                ethFees = choice1ETHPot.mul(1e19).div(1e20);
                if (ethFees != 0) {
                    _safeTransfer(ethFees, true);
                }

                warFees = choice1WARPot.mul(1e19).div(1e20);
                if (warFees != 0) {
                    _safeTransfer(warFees, false);
                }
            }
        }
    }
    function rescueFunds(address token) external onlyRewardDistribution {
        require(block.timestamp >= lastClaimTime, "not allowed yet");
        if (token == address(0)) {
            Address.sendValue(msg.sender, address(this).balance);
        } else {
            IERC20(token).safeTransfer(msg.sender, IERC20(token).balanceOf(address(this)));
        }
    }

    function earned(address account) public view returns (uint256 ethEarnings, uint256 warEarnings) {
        if (isFinal) {
            uint256 _choice1ETHBet = choice1ETHBet[account];
            uint256 _choice2ETHBet = choice2ETHBet[account];
            uint256 _choice1WARBet = choice1WARBet[account];
            uint256 _choice2WARBet = choice2WARBet[account];
            
            uint256 winnings;
            uint256 fee;

            if (winner == Choice.Choice1 && _choice1ETHBet != 0) {
                winnings = choice2ETHPot.mul(_choice1ETHBet).div(choice1ETHPot);
                fee = winnings.mul(1e19).div(1e20);
                winnings -= fee;
                ethEarnings = _choice1ETHBet.add(winnings);
            } else if (winner == Choice.Choice2 && _choice2ETHBet != 0) {
                winnings = choice1ETHPot.mul(_choice2ETHBet).div(choice2ETHPot);
                fee = winnings.mul(1e19).div(1e20);
                winnings -= fee;
                ethEarnings = _choice2ETHBet.add(winnings);
            }

            if (winner == Choice.Choice1 && _choice1WARBet != 0) {
                winnings = choice2WARPot.mul(_choice1WARBet).div(choice1WARPot);
                fee = winnings.mul(1e19).div(1e20);
                winnings -= fee;
                warEarnings = _choice1WARBet.add(winnings);
            } else if (winner == Choice.Choice2 && _choice2WARBet != 0) {
                winnings = choice1WARPot.mul(_choice2WARBet).div(choice2WARPot);
                fee = winnings.mul(1e19).div(1e20);
                winnings -= fee;
                warEarnings = _choice2WARBet.add(winnings);
            }
        } else if (isCanceled) {
            ethEarnings = choice1ETHBet[account] + choice2ETHBet[account];
            warEarnings = choice1WARBet[account] + choice2WARBet[account];
        }
    }

    function getRewards() public {
        require(isFinal || isCanceled, "battle not decided");

        (uint256 ethEarnings, uint256 warEarnings) = earned(msg.sender);
        if (ethEarnings != 0) {
            choice1ETHBet[msg.sender] = 0;
            choice2ETHBet[msg.sender] = 0;
            _safeTransfer(ethEarnings, true);
        }
        if (warEarnings != 0) {
            choice1WARBet[msg.sender] = 0;
            choice2WARBet[msg.sender] = 0;
            _safeTransfer(warEarnings, false);
        }
        emit EarningsPaid(msg.sender, ethEarnings, warEarnings);
    }

    function _safeTransfer(uint256 amount, bool isETH) internal {
        uint256 balance;
        if (isETH) {
            balance = address(this).balance;
            if (amount > balance) {
                amount = balance;
            }
            Address.sendValue(msg.sender, amount);
        } else {
            balance = war.balanceOf(address(this));
            if (amount > balance) {
                amount = balance;
            }
            war.safeTransfer(msg.sender, amount);
        }
    }

    // unused
    function notifyRewardAmount(uint256 reward, uint256 _duration) external { return; }
}