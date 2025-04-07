/**
 *Submitted for verification at Etherscan.io on 2021-02-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: IAddressResolver



// Part: IFeePool



// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/ReentrancyGuard

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: SafeDecimalMath

// https://docs.synthetix.io/contracts/SafeDecimalMath


// File: FeePool.sol

contract FeePool is ReentrancyGuard, IFeePool{
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    bytes32 public constant BOR = "BOR";
    bytes32 public constant OTOKEN = "oToken";
    bytes32 public constant PPTOKEN = "ppToken";

    bytes32 public tunnelKey;
    IAddressResolver public addrReso;

    uint public borFeePerTokenStored;
    uint public oTokenFeePerTokenStored;

    mapping(address => uint) public userBORFee;
    mapping(address => uint) public userBORFeePaid;
    mapping(address => uint) public userOTokenFee;
    mapping(address => uint) public userOTokenFeePaid;



    mapping(address => uint) private _balances;

    constructor(IAddressResolver _addrReso, bytes32 _tunnelKey) public {
        addrReso = _addrReso;
        tunnelKey = _tunnelKey;
    }

    function bor() internal view returns (IERC20) {
        return IERC20(addrReso.requireAndKey2Address(BOR, "BOR contract is address(0) in FeePool"));
    }

    function otoken() internal view returns(IERC20) {
        return IERC20(addrReso.requireKKAddrs(tunnelKey, OTOKEN, "oToken contract is address(0) in FeePool"));
    }

    function ptoken() internal view returns(IERC20) {
        return IERC20(addrReso.requireKKAddrs(tunnelKey, PPTOKEN, "oToken contract is address(0) in FeePool"));
    }

    function totalSupply() external view returns (uint256) {
        return ptoken().totalSupply();
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function borFeePerToken() public view returns(uint) {
        return borFeePerTokenStored;
    }

    function oTokenFeePerToken() public view returns(uint) {
        return oTokenFeePerTokenStored;
    }

    function earned(address account) public view override returns(uint, uint) {
        uint borFee = _balances[account].multiplyDecimal(borFeePerTokenStored.sub(userBORFeePaid[account])).add(userBORFee[account]);
        uint btokenFee = _balances[account].multiplyDecimal(oTokenFeePerTokenStored.sub(userOTokenFeePaid[account])).add(userOTokenFee[account]);
        return (borFee, btokenFee);
    }

    function getTotalFee() public view returns(uint, uint) {
        return (bor().balanceOf(address(this)), otoken().balanceOf(address(this)));
    }

    function notifyBORFeeAmount(uint amount) external override onlyTunnel {
        borFeePerTokenStored = borFeePerTokenStored.add(amount.divideDecimal(ptoken().totalSupply()));
    }

    function notifyBTokenFeeAmount(uint amount) external override onlyTunnel {

        oTokenFeePerTokenStored = oTokenFeePerTokenStored.add(amount.divideDecimal(ptoken().totalSupply()));
    }

    function notifyPTokenAmount(address account, uint amount) external override onlyTunnel {
        // first update account rewards
        (uint earnedBOR, uint earnedOToken) = earned(account);
        userBORFee[account] = earnedBOR; 
        userOTokenFee[account] = earnedOToken; 

        userBORFeePaid[account] = borFeePerTokenStored;
        userOTokenFeePaid[account] = oTokenFeePerTokenStored;

        _balances[account] = _balances[account].add(amount);
    }

    function withdraw(address account, uint amount) external override onlyTunnel{
        _claimFee(account);
        _balances[account] = _balances[account].sub(amount);
    }

    function claimFee() external {
        _claimFee(msg.sender);
    }

    function _claimFee(address account) internal {
        (uint earnedBOR, uint earnedOToken) = earned(account);
        userBORFee[account] = 0;
        userBORFeePaid[account] = borFeePerTokenStored;

        userOTokenFee[account] = 0;
        userOTokenFeePaid[account] = oTokenFeePerTokenStored;
        
        bor().transfer(account, earnedBOR);
        otoken().transfer(account, earnedOToken);

    }

    // modifier
    modifier onlyTunnel {
        require(
            msg.sender == addrReso.key2address(tunnelKey),
            "caller is not tunnel"
        );
        _;
    }


}