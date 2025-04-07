/**

 *Submitted for verification at Etherscan.io on 2019-05-03

*/



pragma solidity ^0.5.7;



// Voken Team Fund

//   Freezed till 2021-06-30 23:59:59, (timestamp 1625039999).

//   Release 10% per 3 months.

//

// More info:

//   https://vision.network

//   https://voken.io

//

// Contact us:

//   [emailÂ protected]

//   [emailÂ protected]





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

 * @title Voken Team Fund

 */

contract VokenTeamFund is Ownable{

    using SafeMath for uint256;

    

    IERC20 public VOKEN;



    uint256 private _till = 1625039999;

    uint256 private _vokenAmount = 4200000000000000; // 4.2 billion

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

        VOKEN = IERC20(0x82070415FEe803f94Ce5617Be1878503e58F0a6a);

    }



    /**

     * @dev Voken freezed amount.

     */

    function vokenFreezed() public view returns (uint256) {

        uint256 __freezed;



        if (now > _till) {

            uint256 __qrPassed = now.sub(_till).div(_3mo);



            if (__qrPassed >= 10) {

                __freezed = 0;

            }

            else {

                __freezed = _vokenAmount.mul(_freezedPct[__qrPassed]).div(100);

            }



            return __freezed;

        }



        return _vokenAmount;

    }



    /**

     * @dev Donate

     */

    function () external payable {

        emit Donate(msg.sender, msg.value);

    }



    /**

     * @dev transfer Voken

     */

    function transferVoken(address to, uint256 amount) external onlyOwner {

        uint256 __freezed = vokenFreezed();

        uint256 __released = VOKEN.balanceOf(address(this)).sub(__freezed);



        require(__released >= amount);



        assert(VOKEN.transfer(to, amount));

    }



    /**

     * @dev Rescue compatible ERC20 Token, except "Voken"

     *

     * @param tokenAddr ERC20 The address of the ERC20 token contract

     * @param receiver The address of the receiver

     * @param amount uint256

     */

    function rescueTokens(address tokenAddr, address receiver, uint256 amount) external onlyOwner {

        IERC20 _token = IERC20(tokenAddr);

        require(VOKEN != _token);

        require(receiver != address(0));

    

        uint256 balance = _token.balanceOf(address(this));

        require(balance >= amount);

        assert(_token.transfer(receiver, amount));

    }

}