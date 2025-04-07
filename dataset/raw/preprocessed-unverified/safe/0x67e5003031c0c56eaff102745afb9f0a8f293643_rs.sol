/**

 *Submitted for verification at Etherscan.io on 2019-03-18

*/



pragma solidity 0.4.24;





/// @title SafeMath

/// @dev Math operations with safety checks that throw on error





/// @title Ownable

/// @dev Provide a modifier that permits only a single user to call the function





/// @notice Abstract contract for vesting schedule

/// @notice Implementations must provide vestedPercent()

contract Schedule is Ownable {

    using SafeMath for uint256;



    /// The timestamp of the start of vesting

    uint256 public tokenReleaseDate;



    /// The timestamp of the vesting release interval

    uint256 public releaseInterval = 30 days;



    constructor(uint256 _tokenReleaseDate) public {

        tokenReleaseDate = _tokenReleaseDate;

    }



    /// @notice Update the date that PLG trading unlocks

    /// @param newReleaseDate The new PLG release timestamp

    function setTokenReleaseDate(uint256 newReleaseDate) public onlyOwner {

        tokenReleaseDate = newReleaseDate;

    }



    /// @notice Calculates the percent of tokens that may be claimed at this time

    /// @return Number of tokens vested

    function vestedPercent() public view returns (uint256);



    /// @notice Helper for calculating the time of a specific release

    /// @param intervals The number of interval periods to calculate a release date for

    /// @return The timestamp of the release date

    function getReleaseTime(uint256 intervals) public view returns (uint256) {

        return tokenReleaseDate.add(releaseInterval.mul(intervals));

    }

}



/// @title ScheduleHold

/// @notice Holds tokens until six intervals after `tokenReleaseDate`

contract ScheduleHold is Schedule {



    constructor(uint256 _tokenReleaseDate) Schedule(_tokenReleaseDate) public {

    }



    /// @notice Calculates the percent of tokens that may be claimed at this time

    /// @return Number of tokens vested

    function vestedPercent() public view returns (uint256) {



        if(now < tokenReleaseDate || now < getReleaseTime(6)) {

            return 0;

            

        } else {

            return 100;

        }

    }

}