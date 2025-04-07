/**
 *Submitted for verification at Etherscan.io on 2019-09-04
*/

pragma solidity ^0.5.11;

// Voken panel
//
// More info:
//   https://vision.network
//   https://voken.io
//
// Contact us:
//   support@vision.network
//   support@voken.io


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */



/**
 * @dev Interface of the ERC20 standard
 */



/**
 * @dev Interface of Voken2.0
 */



/**
 * @title Voken2 Panel
 */
contract Voken2Panel is Ownable {

    IVoken2 private _VOKEN = IVoken2(0xFfFAb974088Bd5bF3d7E6F522e93Dd7861264cDB);

    event Donate(address indexed account, uint256 amount);


    /**
     * @dev Donate
     */
    function () external payable {
        if (msg.value > 0) {
            emit Donate(msg.sender, msg.value);
        }
    }

    function voken2() public view returns (uint256 totalSupply,
                                           uint256 whitelistCounter,
                                           bool whitelistingMode,
                                           bool safeMode,
                                           bool burningMode) {
        totalSupply = _VOKEN.totalSupply();

        whitelistCounter = _VOKEN.whitelistCounter();
        whitelistingMode = _VOKEN.whitelistingMode();
        safeMode = _VOKEN.safeMode();
        (burningMode,) = _VOKEN.burningMode();
    }


    function accountVoken2(address account) public view returns (bool whitelisted,
                                                                 uint256 whitelistReferralsCount,
                                                                 uint256 balance,
                                                                 uint256 reserved) {
        whitelisted = _VOKEN.whitelisted(account);
        whitelistReferralsCount = _VOKEN.whitelistReferralsCount(account);
        balance = _VOKEN.balanceOf(account);
        reserved = _VOKEN.reservedOf(account);
    }
}