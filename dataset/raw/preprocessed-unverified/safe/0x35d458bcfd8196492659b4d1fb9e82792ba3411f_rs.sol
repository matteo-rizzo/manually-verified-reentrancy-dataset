/**
 *Submitted for verification at Etherscan.io on 2019-07-10
*/

pragma solidity ^0.5.0;






/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract SeedPrivateAdvisorVesting is Ownable {
    using SafeMath for uint256;

    enum User { Public, Seed, Private, Advisor }

    mapping (address => Holding) public holdings;

    uint256 constant public MinimumHoldingPeriod = 90 days;
    uint256 constant public Interval = 30 days;
    uint256 constant public MaximumHoldingPeriod = 180 days;

    uint256 constant public SeedCap = 28000000 ether; // 28 million tokens
    uint256 constant public PrivateCap = 9000000 ether; // 9 million tokens
    uint256 constant public AdvisorCap = 7400000 ether; // 7.4 million tokens

    uint256 public totalSeedTokensCommitted;
    uint256 public totalPrivateTokensCommitted;
    uint256 public totalAdvisorTokensCommitted;

    struct Holding {
        uint256 tokensCommitted;
        uint256 tokensRemaining;
        uint256 startTime;
        User user;
    }

    event VestingInitialized(address _to, uint256 _tokens, uint256 _startTime, User user);
    event VestingUpdated(address _to, uint256 _totalTokens, uint256 _startTime, User user);

    function claimTokens(address beneficiary)
        external
        onlyOwner
        returns (uint256 tokensToClaim)
    {
        uint256 tokensRemaining = holdings[beneficiary].tokensRemaining;
        uint256 startTime = holdings[beneficiary].startTime;
        require(tokensRemaining > 0, "All tokens claimed");

        require(now.sub(startTime) > MinimumHoldingPeriod, "Claiming period not started yet");

        if (now.sub(startTime) >= MaximumHoldingPeriod) {

            tokensToClaim = tokensRemaining;
            delete holdings[beneficiary];

        } else {

            uint256 percentage = calculatePercentageToRelease(startTime);

            uint256 tokensNotToClaim = (holdings[beneficiary].tokensCommitted.mul(100 - percentage)).div(100);
            tokensToClaim = tokensRemaining.sub(tokensNotToClaim);
            tokensRemaining = tokensNotToClaim;
            holdings[beneficiary].tokensRemaining = tokensRemaining;

        }
    }

    function calculatePercentageToRelease(uint256 _startTime) internal view returns (uint256 percentage) {
        // how many 30 day periods have passed
        uint periodsPassed = ((now.sub(_startTime.add(MinimumHoldingPeriod))).div(Interval)).add(1);
        percentage = periodsPassed.mul(25); // 25% to be released every 30 days
    }

    function initializeVesting(
        address _beneficiary,
        uint256 _tokens,
        uint256 _startTime,
        uint8 user
    )
        external
        onlyOwner
    {
        User _user;
        if (user == uint8(User.Seed)) {
            _user = User.Seed;
            totalSeedTokensCommitted = totalSeedTokensCommitted.add(_tokens);
            require(totalSeedTokensCommitted <= SeedCap);
        } else if (user == uint8(User.Private)) {
            _user = User.Private;
            totalPrivateTokensCommitted = totalPrivateTokensCommitted.add(_tokens);
            require(totalPrivateTokensCommitted <= PrivateCap);
        } else if (user == uint8(User.Advisor)) {
            _user = User.Advisor;
            totalAdvisorTokensCommitted = totalAdvisorTokensCommitted.add(_tokens);
            require(totalAdvisorTokensCommitted <= AdvisorCap);
        } else {
            revert( "incorrect category, not eligible for vesting" );
        }

        if (holdings[_beneficiary].tokensCommitted != 0) {
            holdings[_beneficiary].tokensCommitted = holdings[_beneficiary].tokensCommitted.add(_tokens);
            holdings[_beneficiary].tokensRemaining = holdings[_beneficiary].tokensRemaining.add(_tokens);

            emit VestingUpdated(
                _beneficiary,
                holdings[_beneficiary].tokensRemaining,
                holdings[_beneficiary].startTime,
                holdings[_beneficiary].user
            );

        } else {
            holdings[_beneficiary] = Holding(
                _tokens,
                _tokens,
                _startTime,
                _user
            );

            emit VestingInitialized(_beneficiary, _tokens, _startTime, _user);
        }
    }
}