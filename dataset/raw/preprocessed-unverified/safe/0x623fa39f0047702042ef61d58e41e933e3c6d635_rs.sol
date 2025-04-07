/**
 *Submitted for verification at Etherscan.io on 2019-09-06
*/

pragma solidity ^0.5.11;

// Send more than 1 ETH for 1,001 Voken2¡£0, and get unused ETH refund automatically.
//   Use the current voken price of Voken Public-Sale.
//   Discount: 20% OFF.
//
// Conditions:
//   1. You have no Voken2.0 yet.
//   2. You are not in the whitelist yet.
//   3. Send more than 1 ETH (for balance verification).
//
// More info:
//   https://vision.network
//   https://voken.io
//
// Contact us:
//   support@vision.network
//   support@voken.io


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow checks.
 */



/**
 * @dev Interface of the ERC20 standard
 */



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */



/**
 * @title Voken2.0 interface.
 */



/**
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    bool private _paused;

    event Paused();
    event Unpaused();


    /**
     * @dev Constructor
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @return Returns true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Paused");
        _;
    }

    /**
     * @dev Sets paused state.
     *
     * Can only be called by the current owner.
     */
    function setPaused(bool value) external onlyOwner {
        _paused = value;

        if (_paused) {
            emit Paused();
        } else {
            emit Unpaused();
        }
    }
}


/**
 * @title Voken2.0 public-sale interface.
 */



/**
 * @title Get 1001 Voken2.0
 */
contract Get1001Voken2 is Ownable, Pausable {
    using SafeMath256 for uint256;

    // Addresses
    IVoken2 private _VOKEN = IVoken2(0xFfFAb974088Bd5bF3d7E6F522e93Dd7861264cDB);
    VokenPublicSale private _PUBLIC_SALE = VokenPublicSale(0x2FA51d35d6731eb4e0E26229F0180e2D249Ea0A5);

    uint256 private WEI_MIN = 1 ether;
    uint256 private VOKEN_PER_TX = 1001000000; // 1001.000000 Voken2.0

    uint256 private _txs;

    mapping (address => bool) _got;

    /**
     * @dev Returns the VOKEN main contract address.
     */
    function VOKEN() public view returns (IVoken2) {
        return _VOKEN;
    }

    /**
     * @dev Returns the VOKEN public-sale contract address.
     */
    function PUBLIC_SALE() public view returns (VokenPublicSale) {
        return _PUBLIC_SALE;
    }

    /**
     * @dev Transaction counter
     */
    function txs() public view returns (uint256) {
        return _txs;
    }

    /**
     * @dev Get 1001 Voken2.0 and ETH refund.
     */
    function () external payable whenNotPaused {
        require(msg.value >= WEI_MIN, "Get1001Voken2: sent less than 1 ether");
        require(!(_VOKEN.balanceOf(msg.sender) > 0), "Get1001Voken2: balance is greater than zero");
        require(!_VOKEN.whitelisted(msg.sender), "Get1001Voken2: already whitelisted");
        require(!_got[msg.sender], "Get1001Voken2: had got already");

        (, , uint256 __etherUsdPrice, uint256 __vokenUsdPrice, ) = _PUBLIC_SALE.status();
        __vokenUsdPrice = __vokenUsdPrice.mul(8).div(10);
        require(__etherUsdPrice > 0, "Voken2PublicSale2: empty ether price");

        uint256 __usd = VOKEN_PER_TX.mul(__vokenUsdPrice).div(1000000);
        uint256 __wei = __usd.mul(1 ether).div(__etherUsdPrice);

        require(msg.value >= __wei, "Get1001Voken2: ether is not enough");

        _txs = _txs.add(1);
        _got[msg.sender] = true;

        msg.sender.transfer(msg.value.sub(__wei));
        assert(_VOKEN.mint(msg.sender, VOKEN_PER_TX));
    }
}