/**

 *Submitted for verification at Etherscan.io on 2018-12-29

*/



pragma solidity 0.4.24;

 

/**

 * Copyright 2018, Flowchain.co

 *

 * The FlowchainCoin (FLC) token contract for vesting sale

 */



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */









/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title TokenVesting

 * @dev A token holder contract that can release its token balance gradually like a

 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the

 * owner.

 */

contract Vesting is Ownable {

    using SafeMath for uint256;



    Token public tokenReward;



    // beneficiary of tokens after they are released

    address private _beneficiary;



    uint256 private _cliff;

    uint256 private _start;

    uint256 private _duration;



    address public _addressOfTokenUsedAsReward;

    address public creator;



    mapping (address => uint256) private _released;



    /* Constrctor function */

    function Vesting() payable {

        creator = msg.sender;

    }



    /**

     * @dev Creates a vesting contract that vests its balance of FLC token to the

     * beneficiary, gradually in a linear fashion until start + duration. By then all

     * of the balance will have vested.

     * @param beneficiary address of the beneficiary to whom vested tokens are transferred     

     * @param cliffDuration duration in seconds of the cliff in which tokens will begin to vest

     * @param start the time (as Unix time) at which point vesting starts

     * @param duration duration in seconds of the period in which the tokens will vest

     * @param addressOfTokenUsedAsReward where is the token contract

     */

    function createVestingPeriod(address beneficiary, uint256 start, uint256 cliffDuration, uint256 duration, address addressOfTokenUsedAsReward) public {

        require(msg.sender == creator);

        require(cliffDuration <= duration);

        require(duration > 0);

        require(start.add(duration) > block.timestamp);



        _beneficiary = beneficiary;

        _duration = duration;

        _cliff = start.add(cliffDuration);

        _start = start;

        _addressOfTokenUsedAsReward = addressOfTokenUsedAsReward;

        tokenReward = Token(addressOfTokenUsedAsReward);

    }



    /**

     * @return the beneficiary of the tokens.

     */

    function beneficiary() public view returns (address) {

        return _beneficiary;

    }



    /**

     * @return the cliff time of the token vesting.

     */

    function cliff() public view returns (uint256) {

        return _cliff;

    }



    /**

     * @return the start time of the token vesting.

     */

    function start() public view returns (uint256) {

        return _start;

    }



    /**

     * @return the duration of the token vesting.

     */

    function duration() public view returns (uint256) {

        return _duration;

    }



    /**

     * @return the amount of the token released.

     */

    function released(address token) public view returns (uint256) {

        return _released[token];

    }



    /**

     * @notice Mints and transfers tokens to beneficiary.

     * @param token ERC20 token which is being vested

     */

    function release(address token) public {

        require(msg.sender == creator);

    

        uint256 unreleased = _releasableAmount(token);



        require(unreleased > 0);



        _released[token] = _released[token].add(unreleased);



        tokenReward.transfer(_beneficiary, unreleased);

    }



    /**

     * @dev Calculates the amount that has already vested but hasn't been released yet.

     * @param token ERC20 token which is being vested

     */

    function _releasableAmount(address token) private view returns (uint256) {

        return _vestedAmount(token).sub(_released[token]);

    }



    /**

     * @dev Calculates the amount that has already vested.

     * @param token ERC20 token which is being vested

     */

    function _vestedAmount(address token) private view returns (uint256) {

        uint256 currentBalance = tokenReward.balanceOf(address(this));

        uint256 totalBalance = currentBalance.add(_released[token]);



        if (block.timestamp < _cliff) {

            return 0;

        } else if (block.timestamp >= _start.add(_duration)) {

            return totalBalance;

        } else {

            return totalBalance.mul(block.timestamp.sub(_start)).div(_duration);

        }

    }

}