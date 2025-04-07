/**
 *Submitted for verification at Etherscan.io on 2019-09-13
*/

pragma solidity ^0.5.11;

// Contract for Voken2.0 Offer
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
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */



/**
 * @dev Interface of the ERC20 standard
 */



/**
 * @dev Interface of an allocation contract
 */



/**
 * @dev Interface of Voken2.0
 */



/**
 * @dev Interface of Voken public-sale
 */



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */



/**
 * @title Voken 2.0 Offer
 */
contract VokenOffer is Ownable, IAllocation {
    using SafeMath256 for uint256;
    using Roles for Roles.Role;

    IVoken2 private _VOKEN = IVoken2(0xFfFAb974088Bd5bF3d7E6F522e93Dd7861264cDB);
    VokenPublicSale private _PUBLIC_SALE = VokenPublicSale(0xd4260e4Bfb354259F5e30279cb0D7F784Ea5f37A);

    Roles.Role private _proxies;

    mapping(address => bool) private _offered;
    mapping(address => uint256) private _allocations;
    mapping(address => uint256[]) private _rewards;
    mapping(address => uint256[]) private _sales;

    event Donate(address indexed account, uint256 amount);
    event ProxyAdded(address indexed account);
    event ProxyRemoved(address indexed account);


    /**
     * @dev Throws if called by account which is not a proxy.
     */
    modifier onlyProxy() {
        require(isProxy(msg.sender), "ProxyRole: caller does not have the Proxy role");
        _;
    }

    /**
     * @dev Returns true if the `account` has the Proxy role.
     */
    function isProxy(address account) public view returns (bool) {
        return _proxies.has(account);
    }

    /**
     * @dev Give an `account` access to the Proxy role.
     *
     * Can only be called by the current owner.
     */
    function addProxy(address account) public onlyOwner {
        _proxies.add(account);
        emit ProxyAdded(account);
    }

    /**
     * @dev Remove an `account` access from the Proxy role.
     *
     * Can only be called by the current owner.
     */
    function removeProxy(address account) public onlyOwner {
        _proxies.remove(account);
        emit ProxyRemoved(account);
    }

    /**
     * @dev Returns the allocation of `account`.
     */
    function allocation(address account) public view returns (uint256 amount, uint256[] memory sales, uint256[] memory rewards) {
        amount = _allocations[account];
        sales = _sales[account];
        rewards = _rewards[account];
    }

    /**
     * @dev Returns the reserved amount of Voken by `account`.
     */
    function reservedOf(address account) public view returns (uint256 reserved) {
        reserved = _allocations[account];

        (,,, uint256 __vokenReferrals,,) = _PUBLIC_SALE.queryAccount(account);

        for (uint256 i = 0; i < _sales[account].length; i++) {
            if (__vokenReferrals >= _sales[account][i] && reserved >= _rewards[account][i]) {
                reserved = reserved.sub(_rewards[account][i]);
                break;
            }
        }
    }


    /**
     * @dev Constructor
     */
    constructor () public {
        addProxy(msg.sender);
    }

    /**
     * @dev {Donate}
     */
    function() external payable {
        if (msg.value > 0) {
            emit Donate(msg.sender, msg.value);
        }
    }

    /**
     * @dev Send offer
     *
     * Can only be called by a proxy.
     */
    function offer(address account, uint256 amount, uint256[] memory sales, uint256[] memory rewards) public onlyProxy {
        require(!_offered[account], "VokenOffer: have already sent offer to this account");
        require(sales.length == rewards.length, "VokenOffer: length is not match (sales and rewards)");

        _offered[account] = true;
        _allocations[account] = amount;
        _sales[account] = sales;
        _rewards[account] = rewards;

        assert(_VOKEN.mintWithAllocation(account, amount, address(this)));
    }
}