/**
 *Submitted for verification at Etherscan.io on 2021-07-29
*/

// SPDX-License-Identifier: MIT

/*
 *       $$$$$$_$$__$$__$$$$__$$$$$$
 *       ____$$_$$__$$_$$_______$$
 *       ____$$_$$__$$__$$$$____$$
 *       $$__$$_$$__$$_____$$___$$
 *       _$$$$___$$$$___$$$$____$$
 *
 *       $$__$$_$$$$$$_$$$$$__$$_____$$$$$
 *       _$$$$____$$___$$_____$$_____$$__$$
 *       __$$_____$$___$$$$___$$_____$$__$$
 *       __$$_____$$___$$_____$$_____$$__$$
 *       __$$___$$$$$$_$$$$$__$$$$$$_$$$$$
 *
 *       $$___$_$$$$$$_$$$$$$_$$__$$
 *       $$___$___$$_____$$___$$__$$
 *       $$_$_$___$$_____$$___$$$$$$
 *       $$$$$$___$$_____$$___$$__$$
 *       _$$_$$_$$$$$$___$$___$$__$$
 *
 *       $$__$$_$$$$$__$$
 *       _$$$$__$$_____$$
 *       __$$___$$$$___$$
 *       __$$___$$_____$$
 *       __$$___$$$$$__$$$$$$
 */

pragma solidity ^0.8.0;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



/**
 * To ensure proper governance and reward distribution YEL tokens
 * are locked in this vesting contract
 */
contract YelProject_Vesting is Ownable {
    using SafeERC20 for IERC20;
    
    // YEL Token pointer
    IERC20 immutable public yelToken;
    
    string private constant INSUFFICIENT_BALANCE = "Insufficient balance";
    string private constant VESTING_ALREADY_RELEASED = "Vesting already released";
    string private constant NOT_VESTED = "Tokens are locked yet";
    uint256 immutable public creationTime;
    
    // Total amount of tokens which were released from this contract
    uint256 public totalTokensReleased = 0;
    
    event TokenVestingReleased(uint256 indexed weekNumber, uint256 amount);
    event TokenVestingRemoved(uint256 indexed weekNumber, uint256 amount);
    
    
    uint256 SCALING_FACTOR = 10 ** 18; // decimals
    
    // Token amount that should be distributed from week 1 until the end of week 6
    uint256 public FROM_1_TILL_6_WEEKS = 30000000 * SCALING_FACTOR;
    
    // Token amount that should be distributed from week 7 until the end of week 17
    uint256 public FROM_7_TILL_16_WEEKS = 20000000 * SCALING_FACTOR;
    
    // Token amount that should be distributed from week 17 until the end of week 52
    uint256 public FROM_17_TILL_52_WEEKS = 40000000 * SCALING_FACTOR;
    
    uint256 week = 1 weeks;
    address receiverAddress1 = 0x950005C26e9899E749D75e239417324512bCB817;
    address receiverAddress2 = 0x2C6787f0b6aEB06446DE0314496203a6340C198F;
    address receiverAddress3 = 0x9ea87D2910e62c5c64D57f4a8A43525c2C1C3969;
    address receiverAddress4 = 0xC4F03e7992b2fBb6BC3C75DB0c6E68cfbcc5b5B3;

    // Info of each vesting.
    struct Vesting {
        uint256 amount; // amount that is released at specific point of time
        bool released; // flag that verifies if the funds are already withdrawn
    }
    
    // Info stack about requested vesting at specific period of time.
    mapping(uint256 =>  Vesting) public vestingInfo;
    
    constructor (IERC20 _token) {
        require(address(_token) != address(0x0), "YEL token address is not valid");
        yelToken = _token;

        creationTime = block.timestamp + 1;
    }
    
    /**
     * @dev Throws if called by any account other than the Receivers.
     */
    modifier onlyReceivers() {
        require(
            receiverAddress1 == msg.sender ||
            receiverAddress2 == msg.sender ||
            receiverAddress3 == msg.sender ||
            receiverAddress4 == msg.sender,
            "YelProject_Vesting: caller is not the receiver");
        _;
    }

    // Function returns reward token address
    function token() public view returns (IERC20) {
        return yelToken;
    }
    
    // Function returns timestamp in which funds can be withdrawn
    function releaseTime(uint256 weekNumber) public view returns (uint256) {
        return weekNumber * week + creationTime;
    }
    
    // Function returns amount that can be withdrawn at a specific time
    function vestingAmount(uint256 weekNumber) public view returns (uint256 amount) {
        if (weekNumber >= 1 && weekNumber <= 6) {
            amount = FROM_1_TILL_6_WEEKS / 6;
        }
        if (weekNumber >= 7 && weekNumber <= 16) {
            amount = FROM_7_TILL_16_WEEKS / 10;
        }
        if (weekNumber >= 17 && weekNumber <= 52) {
            amount = FROM_17_TILL_52_WEEKS / 36;
        }
    }
    
    // Adds vesting information to vesting array. Can be called only by contract owner
    function removeVesting(uint256 weekNumber) external onlyOwner {
        Vesting storage vesting = vestingInfo[weekNumber];
        require(!vesting.released , VESTING_ALREADY_RELEASED);
        vesting.amount = 0;
        vesting.released = true; // save some gas in the future
        emit TokenVestingRemoved(weekNumber, vesting.amount);
    }
    
    // Function is responsible for releasing the funds at specific point of time
    // Can be called only by contract owner
    function release(uint256 weekNumber) external onlyReceivers{
        Vesting storage vesting = vestingInfo[weekNumber];
        require(!vesting.released, VESTING_ALREADY_RELEASED);
        require(block.timestamp >= releaseTime(weekNumber), NOT_VESTED);

        uint256 amountTotal = vestingAmount(weekNumber);
        uint256 amount = amountTotal / 4; // how many tokens per one receiver

        if (amount > 0) {
            require(yelToken.balanceOf(address(this)) >= amount, INSUFFICIENT_BALANCE);
            vesting.amount = vesting.amount + amount;
            yelToken.safeTransfer(msg.sender, amount);
            totalTokensReleased += amount;
            if(vesting.amount == amountTotal) {
                vesting.released = true;
            }
            emit TokenVestingReleased(weekNumber, vesting.amount);
        }
        
    }
    
    // In a case when there are some YEL tokens left on a contract this function allows the contract owner to retrieve excess tokens
    function retrieveAccessTokens(uint256 _amount) external onlyOwner {
        require(
            block.timestamp >= releaseTime(53),
            "Can be executed by the owner only after 52 weeks.");
        require(_amount <= yelToken.balanceOf(address(this)), INSUFFICIENT_BALANCE);
        yelToken.safeTransfer(owner(), _amount);
    }
    
}