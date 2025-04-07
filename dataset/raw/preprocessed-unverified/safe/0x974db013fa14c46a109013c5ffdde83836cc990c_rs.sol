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
 * @dev Uint256 wrappers over Solidity's arithmetic operations with added overflow checks.
 */



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
 * @dev Interface of Voken shareholders
 */



/**
 * @dev Interface of Voken public-sale
 */



/**
 * @title Voken Panel
 */
contract VokenPanel is Ownable {
    using SafeMath256 for uint256;

    IVoken2 private _VOKEN = IVoken2(0xFfFAb974088Bd5bF3d7E6F522e93Dd7861264cDB);
    VokenShareholders private _SHAREHOLDERS = VokenShareholders(0x7712F76D2A52141D44461CDbC8b660506DCAB752);
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


    function shareholders() public view returns (uint256 page,
                                                 uint256 weis,
                                                 uint256 vokens) {
        page = _SHAREHOLDERS.page();
        weis = _SHAREHOLDERS.weis();
        vokens = _SHAREHOLDERS.vokens();
    }

    function publicSaleStatus() public view returns (uint16 stage,
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

    function accountVoken2(address account) public view returns (bool whitelisted,
                                                                 uint256 whitelistReferralsCount,
                                                                 uint256 balance,
                                                                 uint256 reserved) {
        whitelisted = _VOKEN.whitelisted(account);
        whitelistReferralsCount = _VOKEN.whitelistReferralsCount(account);
        balance = _VOKEN.balanceOf(account);
        reserved = _VOKEN.reservedOf(account);
    }

    function pageShareholders(uint256 pageNumber) public view returns (uint256 weis,
                                                                       uint256 vokens,
                                                                       uint256 sumWeis,
                                                                       uint256 sumVokens,
                                                                       uint256 endingBlock) {
        if (pageNumber > 0) {
            weis = _SHAREHOLDERS.pageEther(pageNumber);
            vokens = _SHAREHOLDERS.pageVoken(pageNumber);
            sumWeis = _SHAREHOLDERS.pageEtherSum(pageNumber);
            sumVokens = _SHAREHOLDERS.pageVokenSum(pageNumber);
            endingBlock = _SHAREHOLDERS.pageEndingBlock(pageNumber);
        }
    }

    function accountShareholders(address account, uint256 pageNumber) public view returns (bool isShareholder,
                                                                                           uint256 proportion,
                                                                                           uint256 devidendWeis,
                                                                                           uint256 dividendWithdrawed,
                                                                                           uint256 dividendRemain) {
        uint256 __vokenHolding = _SHAREHOLDERS.vokenHolding(account, pageNumber);
        isShareholder = __vokenHolding > 0;

        uint256 __page = _SHAREHOLDERS.page();

        if (pageNumber > 0 && pageNumber < __page) {
            proportion = __vokenHolding.mul(100000000).div(_SHAREHOLDERS.pageVokenSum(pageNumber));

            (uint256 __devidendEthers, uint256 __dividendWithdrawed, uint256 __dividendRemain) = _SHAREHOLDERS.etherDividend(account, pageNumber);
            devidendWeis = devidendWeis.add(__devidendEthers);
            dividendWithdrawed = dividendWithdrawed.add(__dividendWithdrawed);
            dividendRemain = dividendRemain.add(__dividendRemain);
        }
    }

    function accountPublicSale(address account) public view returns (uint256 vokenIssued,
                                                                     uint256 vokenBonus,
                                                                     uint256 vokenReferral,
                                                                     uint256 vokenReferrals,
                                                                     uint256 weiRewarded,
                                                                     uint256 usdRewarded,
                                                                     uint256 reserved) {
        (vokenIssued, vokenBonus, vokenReferral, vokenReferrals, , weiRewarded, , usdRewarded) = _PUBLIC_SALE.queryAccount(account);
        reserved = _PUBLIC_SALE.reservedOf(account);
    }

    function accountPublicSaleSeason(address account, uint16 seasonNumber) public view returns (uint256 vokenIssued,
                                                                                                uint256 vokenBonus,
                                                                                                uint256 vokenReferral,
                                                                                                uint256 vokenReferrals,
                                                                                                uint256 weiRewarded,
                                                                                                uint256 usdRewarded) {
        (vokenIssued, vokenBonus, vokenReferral, vokenReferrals, , , weiRewarded, , , usdRewarded) = _PUBLIC_SALE.accountInSeason(account, seasonNumber);
    }
}