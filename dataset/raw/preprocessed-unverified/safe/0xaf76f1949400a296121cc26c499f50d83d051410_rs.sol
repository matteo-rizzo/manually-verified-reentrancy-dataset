/**
 *Submitted for verification at Etherscan.io on 2019-09-04
*/

pragma solidity ^0.5.11;

// Voken Public-Sale Panel
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
 * @dev Interface of Voken public-sale
 */



/**
 * @title Voken Public-Sale Panel
 */
contract VokenPublicSalePanel is Ownable {
    VokenPublicSale private _PUBLIC_SALE = VokenPublicSale(0xfEb75b3cC7281B18f2d475A04F1fFAAA3C9a6E36);

    event Donate(address indexed account, uint256 amount);


    /**
     * @dev Donate
     */
    function () external payable {
        if (msg.value > 0) {
            emit Donate(msg.sender, msg.value);
        }
    }

    function status() public view returns (uint16 stage,
                                           uint16 season,
                                           uint256 etherUsdPrice,
                                           uint256 vokenUsdPrice,
                                           uint256 shareholdersRatio,
                                           uint256 txs,
                                           uint256 vokenIssued,
                                           uint256 vokenBonus,
                                           uint256 weiRewarded,
                                           uint256 usdRewarded) {
        (stage, season, etherUsdPrice, vokenUsdPrice, shareholdersRatio) = _PUBLIC_SALE.status();
        (vokenIssued, vokenBonus, , weiRewarded, , , , usdRewarded, ) = _PUBLIC_SALE.sum();
        (txs, ,) = _PUBLIC_SALE.transactions();
    }

    function queryAccount(address account) public view returns (uint256 vokenIssued,
                                                                uint256 vokenBonus,
                                                                uint256 vokenReferral,
                                                                uint256 vokenReferrals,
                                                                uint256 weiRewarded,
                                                                uint256 usdRewarded,
                                                                uint256 reserved) {
        (vokenIssued, vokenBonus, vokenReferral, vokenReferrals, , weiRewarded, , usdRewarded) = _PUBLIC_SALE.queryAccount(account);
        reserved = _PUBLIC_SALE.reservedOf(account);
    }

    function queryAccountInSeason(address account, uint16 seasonNumber) public view returns (uint256 vokenIssued,
                                                                                             uint256 vokenBonus,
                                                                                             uint256 vokenReferral,
                                                                                             uint256 vokenReferrals,
                                                                                             uint256 weiRewarded,
                                                                                             uint256 usdRewarded) {
        (vokenIssued, vokenBonus, vokenReferral, vokenReferrals, , , weiRewarded, , , usdRewarded) = _PUBLIC_SALE.accountInSeason(account, seasonNumber);
    }
}