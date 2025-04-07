pragma solidity 0.4.18;

// File: contracts/KnowsConstants.sol

contract KnowsConstants {
    // 2/4/18 @ 6:30 PM EST, the deadline for bets
    uint public constant GAME_START_TIME = 1517787000;
}

// File: contracts/KnowsSquares.sol

// knows what a valid box is
contract KnowsSquares {
    modifier isValidSquare(uint home, uint away) {
        require(home >= 0 && home < 10);
        require(away >= 0 && away < 10);
        _;
    }
}

// File: contracts/interfaces/IKnowsTime.sol



// File: contracts/KnowsTime.sol

// knows what time it is
contract KnowsTime is IKnowsTime {
    function currentTime() public view returns (uint) {
        return now;
    }
}

// File: contracts/interfaces/IKnowsVoterStakes.sol



// File: contracts/interfaces/IScoreOracle.sol



// File: zeppelin-solidity/contracts/math/Math.sol

/**
 * @title Math
 * @dev Assorted math operations
 */



// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


// File: contracts/Squares.sol

contract Squares is KnowsConstants, KnowsTime, KnowsSquares, IKnowsVoterStakes {
    using SafeMath for uint;

    function Squares(IScoreOracle _oracle, address _developer) public {
        oracle = _oracle;
        developer = _developer;
    }

    // the oracle for the scores
    IScoreOracle public oracle;

    // the developer of the smart contract
    address public developer;

    // staked ether for each player and each box
    mapping(address => uint[10][10]) public totalSquareStakesByUser;

    // total stakes for each box
    uint[10][10] public totalSquareStakes;

    // the total stakes for each user
    mapping(address => uint) public totalUserStakes;

    // the overall total of money stakes in the grid
    uint public totalStakes;

    event LogBet(address indexed better, uint indexed home, uint indexed away, uint stake);

    function bet(uint home, uint away) public payable isValidSquare(home, away) {
        require(msg.value > 0);
        require(currentTime() < GAME_START_TIME);

        // the stake is the message value
        uint stake = msg.value;

        // add the stake amount to the overall total
        totalStakes = totalStakes.add(stake);

        // add their stake to the total user stakes
        totalUserStakes[msg.sender] = totalUserStakes[msg.sender].add(stake);

        // add their stake to their own accounting
        totalSquareStakesByUser[msg.sender][home][away] = totalSquareStakesByUser[msg.sender][home][away].add(stake);

        // add it to the total stakes as well
        totalSquareStakes[home][away] = totalSquareStakes[home][away].add(stake);

        LogBet(msg.sender, home, away, stake);
    }

    event LogPayout(address indexed winner, uint payout, uint donation);

    // calculate the winnings owed for a user&#39;s bet on a particular square
    function getWinnings(address user, uint home, uint away) public view returns (uint winnings) {
        // the square wins and the total wins are used to calculate
        // the percentage of the total stake that the square is worth
        var (numSquareWins, totalWins) = oracle.getSquareWins(home, away);

        return totalSquareStakesByUser[user][home][away]
            .mul(totalStakes)
            .mul(numSquareWins)
            .div(totalWins)
            .div(totalSquareStakes[home][away]);
    }

    // called by the winners to collect winnings for a box
    function collectWinnings(uint home, uint away, uint donationPercentage) public isValidSquare(home, away) {
        // score must be finalized
        require(oracle.isFinalized());

        // optional donation
        require(donationPercentage <= 100);

        // we cannot pay out more than we have
        // but we should not prevent paying out what we do have
        // this should never happen since integer math always truncates, we should only end up with too much
        // however it&#39;s worth writing in the protection
        uint winnings = Math.min256(this.balance, getWinnings(msg.sender, home, away));

        require(winnings > 0);

        // the donation amount
        uint donation = winnings.mul(donationPercentage).div(100);

        uint payout = winnings.sub(donation);

        // clear their stakes - can only collect once
        totalSquareStakesByUser[msg.sender][home][away] = 0;

        msg.sender.transfer(payout);
        developer.transfer(donation);

        LogPayout(msg.sender, payout, donation);
    }

    function getVoterStakes(address voter, uint asOfBlock) public view returns (uint) {
        return totalUserStakes[voter];
    }
}