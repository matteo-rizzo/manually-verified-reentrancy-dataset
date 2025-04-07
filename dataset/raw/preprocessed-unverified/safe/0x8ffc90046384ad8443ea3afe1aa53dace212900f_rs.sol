/**
 *Submitted for verification at Etherscan.io on 2021-05-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

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


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @title Blender is exchange contract for MILK2 <=> SHAKE tokens
 *
 * @dev Don't forget permit mint and burn in tokens contracts
 */
contract Blender {
    using SafeMath for uint256;

    uint256 public constant  SHAKE_PRICE_STEP = 1e18;  //MILK2

    address public immutable MILK_ADDRESS;
    address public immutable SHAKE_ADDRESS;
    uint32  public immutable START_FROM_BLOCK;

    uint256 public currShakePrice;
    address public owner;
    bool    public paused;

    /**
     * @dev Sets the values for {MILK_ADDRESS}, {SHAKE_ADDRESS}
     * {START_FROM_BLOCK} , initializes {currShakePrice} with
     * a default value of 1000*10**18.
     */
    constructor (
        address _milkAddress,
        address _shakeAddress,
        uint32  _startFromBlock
    )
    public
    {
        MILK_ADDRESS     = _milkAddress;
        SHAKE_ADDRESS    = _shakeAddress;
        currShakePrice   = 7500*1e18; //MILK2 // 7500
        START_FROM_BLOCK = _startFromBlock;
        owner            = msg.sender;
        paused           = false;
    }

    /**
     * @dev Just exchage your MILK2 for one(1) SHAKE.
     * Caller must have MILK2 on his/her balance, see `currShakePrice`
     * Each call will increase SHAKE price with one step, see `SHAKE_PRICE_STEP`.
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Function can be called after `START_FROM_BLOCK` 
     */
    function getOneShake() external {
        require(block.number >= START_FROM_BLOCK, "Please wait for start block");
        require(paused == false, "Paused by owner");

        IERC20 milk2Token = IERC20(MILK_ADDRESS);

        require(milk2Token.balanceOf(msg.sender) >= currShakePrice, "There is no enough MILK2");
        require(milk2Token.burn(msg.sender, currShakePrice), "Can't burn your MILK2");

        IERC20 shakeToken = IERC20(SHAKE_ADDRESS);
        currShakePrice  = currShakePrice.add(SHAKE_PRICE_STEP);
        shakeToken.mint(msg.sender, 1*10**18);

    }

    /**
    *@dev set pause state
    *for owner use ONLY!!
    */
    function setPauseState(bool _isPaused) external {
        require(msg.sender == owner, "For owner use ONLY!!!");
        paused = _isPaused;
    }

}