/**
 *Submitted for verification at Etherscan.io on 2020-10-30
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

contract ElectionBetting is IRewardDistributionRecipient {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    enum Candidate {
        Undecided,
        Biden,
        Trump
    }

    //IERC20 public constant war = IERC20(0xf4A81C18816C9B0AB98FAC51B36Dcb63b0E58Fde);
    IERC20 public constant war = IERC20(0x5896E1c50E4D2d315052aAd8383D7104C3891CD6); // temp fake token (FWAR) for testing

    string public constant desc = "US Election 2020 Battle: Biden vs Trump";

    // TODO: set these to real timestamps
    uint256 public constant starttime = 0;
    uint256 public constant endtime = 2**256-1;

    bool public isPaused;
    bool public isCanceled;
    bool public isFinal;

    Candidate public winner;

    mapping(address => uint256) public bidenETHBet;
    mapping(address => uint256) public trumpETHBet;
    mapping(address => uint256) public bidenWARBet;
    mapping(address => uint256) public trumpWARBet;

    uint256 public bidenETHPot;
    uint256 public trumpETHPot;
    uint256 public bidenWARPot;
    uint256 public trumpWARPot;

    event BidenETHBet(address indexed user, uint256 amount);
    event TrumpETHBet(address indexed user, uint256 amount);
    event BidenWARBet(address indexed user, uint256 amount);
    event TrumpWARBet(address indexed user, uint256 amount);

    event EarningsPaid(address indexed user, uint256 ethEarnings, uint256 warEarnings);

    modifier checkStatus() {
        require(!isFinal, "election is decided");
        require(!isCanceled, "election is canceled, claim your bet");
        require(!isPaused, "betting is paused");
        require(block.timestamp < endtime, "betting has ended");
        require(block.timestamp >= starttime, "betting not started");
        _;
    }

    function ETHBet(Candidate candidate) public payable checkStatus {
        require(msg.value != 0, "no ether sent");
        if (candidate == Candidate.Biden) {
            require(trumpETHBet[msg.sender] == 0, "Sorry. You already bet on Trump with ETH!");
            bidenETHBet[msg.sender] += msg.value;
            bidenETHPot += msg.value;
            emit BidenETHBet(msg.sender, msg.value);
        } else if (candidate == Candidate.Trump) {
            require(bidenETHBet[msg.sender] == 0, "Sorry. You already bet on Biden with ETH!");
            trumpETHBet[msg.sender] += msg.value;
            trumpETHPot += msg.value;
            emit TrumpETHBet(msg.sender, msg.value);
        } else {
            revert("Come on man! Pick a candidate.");
        }
    }

    function WARBet(Candidate candidate, uint256 amount) public checkStatus {
        require(amount != 0, "no token sent");
        if (candidate == Candidate.Biden) {
            require(trumpWARBet[msg.sender] == 0, "Sorry. You already bet on Trump with WAR!");
            war.safeTransferFrom(msg.sender, address(this), amount);
            bidenWARBet[msg.sender] += amount;
            bidenWARPot += amount;
            emit BidenWARBet(msg.sender, amount);
        } else if (candidate == Candidate.Trump) {
            require(bidenWARBet[msg.sender] == 0, "Sorry. You already bet on Biden with WAR!");
            war.safeTransferFrom(msg.sender, address(this), amount);
            trumpWARBet[msg.sender] += amount;
            trumpWARPot += amount;
            emit TrumpWARBet(msg.sender, amount);
        } else {
            revert("Come on man! Pick a candidate.");
        }
    }

    function pauseBetting() external onlyRewardDistribution {
        isPaused = true;
    }
    function unpauseBetting() external onlyRewardDistribution {
        isPaused = false;
    }
    function cancelElection() external onlyRewardDistribution {
        require(!isFinal, "election is decided");
        isCanceled = true;
    }
    function finalizeElection(Candidate candidate) external onlyRewardDistribution {
        require(!isFinal, "election is decided");
        require(!isCanceled, "election is canceled");
        require(candidate == Candidate.Biden || candidate == Candidate.Trump, "invalid candidate");
        winner = candidate;
        isFinal = true;
    }

    function earned(address account) public view returns (uint256 ethEarnings, uint256 warEarnings) {
        if (isFinal) {
            uint256 _bidenETHBet = bidenETHBet[account];
            uint256 _trumpETHBet = trumpETHBet[account];
            uint256 _bidenWARBet = bidenWARBet[account];
            uint256 _trumpWARBet = trumpWARBet[account];
            
            if (winner == Candidate.Biden && _bidenETHBet != 0) {
                ethEarnings = trumpETHPot.mul(_bidenETHBet).div(bidenETHPot).add(_bidenETHBet);
            } else if (winner == Candidate.Trump && _trumpETHBet != 0) {
                ethEarnings = bidenETHPot.mul(_trumpETHBet).div(trumpETHPot).add(_trumpETHBet);
            }

            if (winner == Candidate.Biden && _bidenWARBet != 0) {
                warEarnings = trumpWARPot.mul(_bidenWARBet).div(bidenWARPot).add(_bidenWARBet);
            } else if (winner == Candidate.Trump && _trumpWARBet != 0) {
                warEarnings = bidenWARPot.mul(_trumpWARBet).div(trumpWARPot).add(_trumpWARBet);
            }
        } else if (isCanceled) {
            ethEarnings = bidenETHBet[account] + trumpETHBet[account];
            warEarnings = bidenWARBet[account] + trumpWARBet[account];
        }
    }

    function getRewards() public {
        require(isFinal || isCanceled, "election not decided");
        
        (uint256 ethEarnings, uint256 warEarnings) = earned(msg.sender);
        if (ethEarnings != 0) {
            bidenETHBet[msg.sender] = 0;
            trumpETHBet[msg.sender] = 0;
            Address.sendValue(msg.sender, ethEarnings);
        }
        if (warEarnings != 0) {
            bidenWARBet[msg.sender] = 0;
            trumpWARBet[msg.sender] = 0;
            war.safeTransfer(msg.sender, warEarnings);
        }
        emit EarningsPaid(msg.sender, ethEarnings, warEarnings);
    }

    // unused
    function notifyRewardAmount(uint256 reward, uint256 _duration) external { return; }
}

contract ElectionBettingMock is ElectionBetting {
    function uncancelElection() external onlyRewardDistribution {
        isCanceled = false;
    }
    function cancelElection() external onlyRewardDistribution {
        isCanceled = true;
    }
    function unfinalizeElection() external onlyRewardDistribution {
        winner = Candidate.Undecided;
        isFinal = false;
    }
    function finalizeElection(Candidate candidate) external onlyRewardDistribution {
        require(candidate != Candidate.Undecided, "invalid");
        winner = candidate;
        isFinal = true;
    }

    function rescueToken(IERC20 _token, uint256 amount) external onlyRewardDistribution {
        _token.safeTransfer(msg.sender, amount);
    }
    function rescueEth(uint256 amount) external onlyRewardDistribution {
        Address.sendValue(msg.sender, amount);
    }
}