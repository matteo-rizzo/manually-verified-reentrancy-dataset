pragma solidity ^0.6.2;



/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
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
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}




contract Staking is IStaking, Ownable, ReentrancyGuard  {
    //using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address internal tokenToStake;
    address internal issuingToken;
    uint256 internal frozenFrom;
    uint256 internal frozenUntil;
    uint256 internal dripPerBlock;
    uint256 internal totalDeposited;
    uint256 internal totalDepositedDynamic;
    mapping(address => uint256) internal deposited;
    mapping(address => uint256) internal latestRedeem;

    event Deposited(address account, uint256 amount);
    event WithdrawnAndRedeemed(address acount, uint256 amount, uint256 issued);
    event Redeemed(address account, uint256 amount);

    constructor(
        address stakedToken,
        address issuedToken
    ) public {
        tokenToStake  = stakedToken;
        issuingToken = issuedToken;
    }

    /**
    *
    */
    function getFrozenFrom() external view override returns (uint256) {
        return frozenFrom;
    }

    /**
    *
    */
    function getFrozenUntil() external view override returns (uint256) {
        return frozenUntil;
    }

    /**
    *
    */
    function getDripPerBlock() external view override returns (uint256) {
        return dripPerBlock;
    }

    /**
    *
    */
    function getTotalDeposited() external view override returns (uint256) {
        return totalDepositedDynamic;
    }

    /**
    *
    */
    function getTokenToStake() external view override returns (address) {
        return tokenToStake;
    }

    /**
    *
    */
    function getIssuingToken() external view override returns (address) {
        return issuingToken;
    }

    /**
    *
    */
    function getUserDeposit(address user) external view override returns (uint256) {
        return deposited[user];
    }

    /**
    *
    */
    function setTimeWindow(uint256 from, uint256 to) internal returns (bool) {
        require(from > block.number, "'from' too small");
        require(to > block.number, "'to' too small");
        require(from < to, "'from' is larger than 'to'");
        frozenFrom = from;
        frozenUntil = to;
        return true;
    }

    /**
    *
    */
    function setDripRate(uint256 drip) internal returns (bool) {
        dripPerBlock = drip;
        return true;
    }

    /**
    *
    */
    function initializeNewRound(
        uint256 _frozenFrom,
        uint256 _frozenUntil,
        uint256 drip) external onlyOwner override returns (bool) {
        setTimeWindow(_frozenFrom, _frozenUntil);
        dripPerBlock = drip;
        return true;
    }

    /**
    *
    */
    function deposit(uint256 amount) external override nonReentrant returns (bool) {
        require(block.number < frozenFrom, "deposits not allowed");
        deposited[msg.sender] = deposited[msg.sender].add(amount);
        totalDeposited = totalDeposited.add(amount);
        totalDepositedDynamic = totalDepositedDynamic.add(amount);
        latestRedeem[msg.sender] = frozenFrom;
        emit Deposited(msg.sender, amount);
        require(IERC20(tokenToStake).transferFrom(msg.sender, address(this), amount),"deposit() failed.");
        return true;
    }

    /**
    *
    */
    function withdrawAndRedeem(uint256 amount) external override nonReentrant returns (bool) {
        require(deposited[msg.sender] >= amount, "deposit too small");
        if(block.number < frozenFrom){
            deposited[msg.sender] = deposited[msg.sender].sub(amount);
            totalDeposited = totalDeposited.sub(amount);
            totalDepositedDynamic = totalDepositedDynamic.sub(amount);
            require(IERC20(tokenToStake).transfer(msg.sender, amount),"withdrawAndRedeem() failed.");
        } else {
            require(block.number >= frozenUntil, "withdraws not allowed");
            uint256 accumulated = accumulated(msg.sender);
            deposited[msg.sender] = deposited[msg.sender].sub(amount);
            emit WithdrawnAndRedeemed(msg.sender, amount, accumulated);
            totalDepositedDynamic = totalDepositedDynamic.sub(amount);
            require(_redeem(msg.sender, accumulated), "Failed to redeem tokens");
            require(IERC20(tokenToStake).transfer(msg.sender, amount),"withdrawAndRedeem() failed.");
        }
        return true;
    }

    /**
    *
    */
    function redeem() external override nonReentrant returns (bool) {
        uint256 accumulated = accumulated(msg.sender);
        Redeemed(msg.sender, accumulated);
        return _redeem(msg.sender, accumulated);
    }

    /**
    *
    */
    function _redeem(address account, uint256 amount) internal returns (bool) {
        if (block.number >= frozenUntil) {
            latestRedeem[account] = frozenUntil;
        } else {
            if(block.number > frozenFrom){
                latestRedeem[account] = block.number;
            } else {
                latestRedeem[account] = frozenFrom;
            }
        }
        if(amount > 0) {
            IERC20(issuingToken).transfer(account, amount);
        }
        return true;
    }

    /**
    *
    */
    function accumulated(address account) public view override returns (uint256) {
        if(deposited[account] == 0) {
            return 0;
        }
        if(block.number > frozenFrom) {
            if(block.number <= frozenUntil) {
                return deposited[account].mul(
                    dripPerBlock.mul(
                        block.number.sub(
                            latestRedeem[account]
                        )
                    )
                ).div(totalDeposited);
            } else {
                return deposited[account].mul(
                    dripPerBlock.mul(
                        frozenUntil.sub(
                            latestRedeem[account]
                        )
                    )
                ).div(totalDeposited);
            }
        } else {
            return 0;
        }
    }


}