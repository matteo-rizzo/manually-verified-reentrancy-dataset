/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity ^0.5.7;

// TG Team Fund
//   Freezed till 2022-12-31 23:59:59, (timestamp 1625039999).
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
 * @title TG Team Fund
 */
contract TGTeamFund is Ownable{
    using SafeMath for uint256;

    IERC20 public TG;

    uint256 private _till = 1671606000;
    uint256 private _TGAmount = 4200000000000000; // 4.2 billion
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
    constructor() public {}

    /**
     * @dev TG freezed amount.
     */
    function TGFreezed() public view returns (uint256) {
        uint256 __freezed;

        if (now > _till) {
            uint256 __qrPassed = now.sub(_till).div(_3mo);

            if (__qrPassed >= 10) {
                __freezed = 0;
            }
            else {
                __freezed = _TGAmount.mul(_freezedPct[__qrPassed]).div(100);
            }

            return __freezed;
        }

        return _TGAmount;
    }

    /**
     * @dev Donate
     */
    function () external payable {
        emit Donate(msg.sender, msg.value);
    }

    /**
     * @dev transfer TG
     */
    function transferTG(address to, uint256 amount) external onlyOwner {
        uint256 __freezed = TGFreezed();
        uint256 __released = TG.balanceOf(address(this)).sub(__freezed);

        require(__released >= amount);

        assert(TG.transfer(to, amount));
    }

    /**
     * @dev Rescue compatible ERC20 Token, except "TG"
     *
     * @param tokenAddr ERC20 The address of the ERC20 token contract
     * @param receiver The address of the receiver
     * @param amount uint256
     */
    function rescueTokens(address tokenAddr, address receiver, uint256 amount) external onlyOwner {
        IERC20 _token = IERC20(tokenAddr);
        require(TG != _token);
        require(receiver != address(0));

        uint256 balance = _token.balanceOf(address(this));
        require(balance >= amount);
        assert(_token.transfer(receiver, amount));
    }

    /**
     * @dev set TG Address
     */
    function setTGAddress(address _TGAddr) public onlyOwner {
        TG = IERC20(_TGAddr);
    }

}