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



/// @title ScheduleMB

/// @notice Vesting schedule that releases:

/// @notice  15% at `tokenReleaseDate`,

/// @notice  15% at `tokenReleaseDate + releaseInterval`

/// @notice  25% at `tokenReleaseDate + (2 * releaseInterval)`

/// @notice  15% at `tokenReleaseDate + (3 * releaseInterval)`

/// @notice  15% at `tokenReleaseDate + (4 * releaseInterval)`

/// @notice  15% at `tokenReleaseDate + (5 * releaseInterval)`

contract ScheduleMB is Schedule {



    constructor(uint256 _tokenReleaseDate) Schedule(_tokenReleaseDate) public {

    }



    /// @notice Calculates the percent of tokens that may be claimed at this time

    /// @return Number of tokens vested

    function vestedPercent() public view returns (uint256) {

        uint256 percentReleased = 0;



        if(now < tokenReleaseDate) {

            percentReleased = 0;

            

        } else if(now >= getReleaseTime(6)) {

            percentReleased = 100;

            

        } else if(now >= getReleaseTime(5)) {

            percentReleased = 75;



        } else if(now >= getReleaseTime(4)) {

            percentReleased = 66;



        } else if(now >= getReleaseTime(3)) {

            percentReleased = 58;



        } else if(now >= getReleaseTime(2)) {

            percentReleased = 41;



        } else if(now >= getReleaseTime(1)) {

            percentReleased = 33;



        } else {

            percentReleased = 25;

        }

        return percentReleased;

    }

}