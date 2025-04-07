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

// File: contracts/interfaces/IScoreOracle.sol



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


// File: contracts/OwnedScoreOracle.sol

contract OwnedScoreOracle is KnowsConstants, KnowsSquares, KnowsTime, Ownable, IScoreOracle {
    using SafeMath for uint;

    // score can be reported 1 day after the game
    uint public constant SCORE_REPORT_START_TIME = GAME_START_TIME + 1 days;

    // the number of quarters is the total number of wins
    uint public constant TOTAL_WINS = 4;

    // number of wins that have been reported
    uint public winsReported = 0;

    // the grid of how much each box won
    uint[10][10] public squareWins;

    // whether the score is finalized
    bool public finalized;

    event LogSquareWinsUpdated(uint home, uint away, uint wins);

    function setSquareWins(uint home, uint away, uint wins) public onlyOwner isValidSquare(home, away) {
        require(currentTime() >= SCORE_REPORT_START_TIME);
        require(wins <= TOTAL_WINS);
        require(!finalized);

        uint currentSquareWins = squareWins[home][away];

        // account the number of quarters reported
        if (currentSquareWins > wins) {
            winsReported = winsReported.sub(currentSquareWins.sub(wins));
        } else if (currentSquareWins < wins) {
            winsReported = winsReported.add(wins.sub(currentSquareWins));
        }

        // mark the number of wins in that square
        squareWins[home][away] = wins;

        LogSquareWinsUpdated(home, away, wins);
    }

    event LogFinalized(uint time);

    // finalize the score after it&#39;s been reported
    function finalize() public onlyOwner {
        require(winsReported == TOTAL_WINS);
        require(!finalized);

        finalized = true;

        LogFinalized(currentTime());
    }

    function getSquareWins(uint home, uint away) public view returns (uint numSquareWins, uint totalWins) {
        return (squareWins[home][away], TOTAL_WINS);
    }

    function isFinalized() public view returns (bool) {
        return finalized;
    }
}

// File: contracts/interfaces/IKnowsVoterStakes.sol



// File: contracts/AcceptedScoreOracle.sol

contract AcceptedScoreOracle is OwnedScoreOracle {
    using SafeMath for uint;

    // how long voters are given to affirm the score
    uint public constant VOTING_PERIOD_DURATION = 1 weeks;

    // when the voting period started
    uint public votingPeriodStartTime;
    // the block number when the voting period started
    uint public votingPeriodBlockNumber;

    // whether the voters have accepted the score as true
    bool public accepted;

    uint public affirmations;
    uint public totalVotes;

    struct Vote {
        bool affirmed;
        bool counted;
    }

    // for the voting period blcok number, these are the votes counted from each address
    mapping(uint => mapping(address => Vote)) votes;

    IKnowsVoterStakes public voterStakes;

    // only once, the voter stakes can be set by the owner, to allow us to deploy a circular dependency
    function setVoterStakesContract(IKnowsVoterStakes _voterStakes) public onlyOwner {
        require(address(voterStakes) == address(0));
        voterStakes = _voterStakes;
    }

    // start the acceptance period
    function finalize() public onlyOwner {
        super.finalize();

        // start the voting period immediately
        affirmations = 0;
        totalVotes = 0;
        votingPeriodStartTime = currentTime();
        votingPeriodBlockNumber = block.number;
    }

    event LogAccepted(uint time);

    // anyone can call this if the score is finalized and not accepted
    function accept() public {
        // score is finalized
        require(finalized);

        // voting period is over
        require(currentTime() >= votingPeriodStartTime + VOTING_PERIOD_DURATION);

        // score is not already accepted as truth
        require(!accepted);

        // require 66.666% majority of voters affirmed the score
        require(affirmations.mul(100000).div(totalVotes) >= 66666);

        // score is accepted as truth
        accepted = true;

        LogAccepted(currentTime());
    }

    event LogUnfinalized(uint time);

    // called when the voting period ends with a minority
    function unfinalize() public {
        // score is finalized
        require(finalized);

        // however it&#39;s not accepted
        require(!accepted);

        // and the voting period for the score has ended
        require(currentTime() >= votingPeriodStartTime + VOTING_PERIOD_DURATION);

        // require people to have
        require(affirmations.mul(10000).div(totalVotes) < 6666);

        // score is no longer finalized
        finalized = false;

        LogUnfinalized(currentTime());
    }

    event LogVote(address indexed voter, bool indexed affirm, uint stake);

    // vote to affirm or unaffirm the score called by a user that has some stake
    function vote(bool affirm) public {
        // the voting period has started
        require(votingPeriodStartTime != 0);

        // the score is finalized
        require(finalized);

        // the score is not accepted
        require(!accepted);

        uint stake = voterStakes.getVoterStakes(msg.sender, votingPeriodBlockNumber);

        // user has some stake
        require(stake > 0);

        Vote storage userVote = votes[votingPeriodBlockNumber][msg.sender];

        // vote has not been counted, so
        if (!userVote.counted) {
            userVote.counted = true;
            userVote.affirmed = affirm;

            totalVotes = totalVotes.add(stake);
            if (affirm) {
                affirmations = affirmations.add(stake);
            }
        } else {
            // changing their vote to an affirmation
            if (affirm && !userVote.affirmed) {
                affirmations = affirmations.add(stake);
            } else if (!affirm && userVote.affirmed) {
                // changing their vote to a disaffirmation
                affirmations = affirmations.sub(stake);
            }
            userVote.affirmed = affirm;
        }

        LogVote(msg.sender, affirm, stake);
    }

    function isFinalized() public view returns (bool) {
        return super.isFinalized() && accepted;
    }
}