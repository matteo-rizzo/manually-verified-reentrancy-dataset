/**
 *Submitted for verification at Etherscan.io on 2019-07-10
*/

/**
 *Submitted for verification at Etherscan.io on 2019-07-10
*/

pragma solidity ^0.5.0;






/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract CommunityVesting is Ownable {
    using SafeMath for uint256;

    mapping (address => Holding) public holdings;

    uint256 constant public MinimumHoldingPeriod = 90 days;
    uint256 constant public Interval = 90 days;
    uint256 constant public MaximumHoldingPeriod = 360 days;

    uint256 constant public CommunityCap = 14300000 ether; // 14.3 million tokens

    uint256 public totalCommunityTokensCommitted;

    struct Holding {
        uint256 tokensCommitted;
        uint256 tokensRemaining;
        uint256 startTime;
    }

    event CommunityVestingInitialized(address _to, uint256 _tokens, uint256 _startTime);
    event CommunityVestingUpdated(address _to, uint256 _totalTokens, uint256 _startTime);

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
        // how many 90 day periods have passed
        uint periodsPassed = ((now.sub(_startTime)).div(Interval));
        percentage = periodsPassed.mul(25); // 25% to be released every 90 days
    }

    function initializeVesting(
        address _beneficiary,
        uint256 _tokens,
        uint256 _startTime
    )
        external
        onlyOwner
    {
        totalCommunityTokensCommitted = totalCommunityTokensCommitted.add(_tokens);
        require(totalCommunityTokensCommitted <= CommunityCap);

        if (holdings[_beneficiary].tokensCommitted != 0) {
            holdings[_beneficiary].tokensCommitted = holdings[_beneficiary].tokensCommitted.add(_tokens);
            holdings[_beneficiary].tokensRemaining = holdings[_beneficiary].tokensRemaining.add(_tokens);

            emit CommunityVestingUpdated(
                _beneficiary,
                holdings[_beneficiary].tokensRemaining,
                holdings[_beneficiary].startTime
            );

        } else {
            holdings[_beneficiary] = Holding(
                _tokens,
                _tokens,
                _startTime
            );

            emit CommunityVestingInitialized(_beneficiary, _tokens, _startTime);
        }
    }
}