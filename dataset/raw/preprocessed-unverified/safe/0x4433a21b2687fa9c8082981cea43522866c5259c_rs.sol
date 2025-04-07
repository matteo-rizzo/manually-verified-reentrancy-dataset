/**
 *Submitted for verification at Etherscan.io on 2019-06-21
*/

pragma solidity ^0.5.7;

// Wesion Team Fund
//   Freezed till 2021-06-30 23:59:59, (timestamp 1625039999).
//   Release 10% per 3 months.


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */



/**
 * @title Ownable
 */



/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */



/**
 * @title Wesion Team Fund
 */
contract WesionTeamFund is Ownable{
    using SafeMath for uint256;

    IERC20 public Wesion;

    uint256 private _till = 1671606000;
    uint256 private _WesionAmount = 4200000000000000; // 4.2 billion
    uint256 private _3mo = 2592000; // Three months: 2,592,000 seconds

    uint256[10] private _freezedPct = [
        100,    // 100%
        90,     // 90%
        80,     // 80%
        70,     // 70%
        60,     // 60%
        50,     // 50%
        40,     // 40%
        30,     // 30%
        20,     // 20%
        10      // 10%
    ];

    event Donate(address indexed account, uint256 amount);


    /**
     * @dev constructor
     */
    constructor() public {
        Wesion = IERC20(0x2c1564A74F07757765642ACef62a583B38d5A213);
    }

    /**
     * @dev Wesion freezed amount.
     */
    function WesionFreezed() public view returns (uint256) {
        uint256 __freezed;

        if (now > _till) {
            uint256 __qrPassed = now.sub(_till).div(_3mo);

            if (__qrPassed >= 10) {
                __freezed = 0;
            }
            else {
                __freezed = _WesionAmount.mul(_freezedPct[__qrPassed]).div(100);
            }

            return __freezed;
        }

        return _WesionAmount;
    }

    /**
     * @dev Donate
     */
    function () external payable {
        emit Donate(msg.sender, msg.value);
    }

    /**
     * @dev transfer Wesion
     */
    function transferWesion(address to, uint256 amount) external onlyOwner {
        uint256 __freezed = WesionFreezed();
        uint256 __released = Wesion.balanceOf(address(this)).sub(__freezed);

        require(__released >= amount);

        assert(Wesion.transfer(to, amount));
    }

    /**
     * @dev Rescue compatible ERC20 Token, except "Wesion"
     *
     * @param tokenAddr ERC20 The address of the ERC20 token contract
     * @param receiver The address of the receiver
     * @param amount uint256
     */
    function rescueTokens(address tokenAddr, address receiver, uint256 amount) external onlyOwner {
        IERC20 _token = IERC20(tokenAddr);
        require(Wesion != _token);
        require(receiver != address(0));

        uint256 balance = _token.balanceOf(address(this));
        require(balance >= amount);
        assert(_token.transfer(receiver, amount));
    }

    /**
     * @dev set Wesion Address
     */
    function setWesionAddress(address _WesionAddr) public onlyOwner {
        Wesion = IERC20(_WesionAddr);
    }

}