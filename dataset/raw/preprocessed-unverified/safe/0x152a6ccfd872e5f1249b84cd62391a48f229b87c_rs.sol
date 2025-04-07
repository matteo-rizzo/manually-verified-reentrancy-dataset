/**
 *Submitted for verification at Etherscan.io on 2021-04-24
*/

pragma solidity 0.6.2;
// SPDX-License-Identifier: MIT

// FSW Token Vesting


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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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





// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
/**
 * @dev Collection of functions related to the address type
 */






/**
 * @title FSW TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract FSWTokenVesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private tokenAddress;
    uint256 private tokensToVest = 0;
    uint256 private vestingId = 0;
    
    address public beneficiaryAddress;

    string private constant INSUFFICIENT_BALANCE = "Insufficient balance";
    string private constant INVALID_VESTING_ID = "Invalid vesting id";
    string private constant VESTING_ALREADY_RELEASED = "Vesting already released";
    string private constant INVALID_BENEFICIARY = "Invalid beneficiary address";
    string private constant NOT_VESTED = "Tokens have not vested yet";

    struct Vesting {
        uint256 releaseTime;
        uint256 amount;
        bool released;
    }
    mapping(uint256 => Vesting) public vestings;

    event TokenVestingReleased(uint256 indexed vestingId, address indexed beneficiary, uint256 amount);
    event TokenVestingAdded(uint256 indexed vestingId, address indexed beneficiary, uint256 amount);
    event TokenVestingRemoved(uint256 indexed vestingId, address indexed beneficiary, uint256 amount);

    constructor(IERC20 _token) public {
        require(address(_token) != address(0x0), "FSW token address is not valid");
        tokenAddress = _token;
        beneficiaryAddress = msg.sender;
        
        uint256 SCALING_FACTOR = 10 ** 18; // decimals
        uint256 day = 1 days;
        
        addVesting(now + 10, 2500000*SCALING_FACTOR); // Sep 2020 (1)
        addVesting(now + 10, 2500000*SCALING_FACTOR); // Oct 2020 (2)
        addVesting(now + 10, 2500000*SCALING_FACTOR); // Nov 2020 (3)
        addVesting(now + 10, 2500000*SCALING_FACTOR); // Dec 2020 (4)
        addVesting(now + 10, 2500000*SCALING_FACTOR); // Jan 2020 (5)
        addVesting(now + 10, 2500000*SCALING_FACTOR); // Feb 2020 (6)
        addVesting(now + 10, 2500000*SCALING_FACTOR); // Mar 2020 (7)
        addVesting(now + 10, 2500000*SCALING_FACTOR); // Apr 2020 (8)
        
        addVesting(now + 30 * day, 2500000*SCALING_FACTOR); // May 2020 (9)
        addVesting(now + 60 * day,  2500000*SCALING_FACTOR); // Jun 2020 (10)
        addVesting(now + 90 * day,  2500000*SCALING_FACTOR); // Jul 2020 (11)
        addVesting(now + 120 * day, 2500000*SCALING_FACTOR); // Aug 2020 (12)
        addVesting(now + 150 * day, 2500000*SCALING_FACTOR); // Sep 2020 (13)
        addVesting(now + 180 * day, 2500000*SCALING_FACTOR); // Oct 2020 (14)
        addVesting(now + 210 * day, 2500000*SCALING_FACTOR); // Nov 2020 (15)
        addVesting(now + 240 * day, 2500000*SCALING_FACTOR); // Dec 2020 (16)
        addVesting(now + 270 * day, 2500000*SCALING_FACTOR); // Jan 2021 (17)
        addVesting(now + 300 * day, 2500000*SCALING_FACTOR); // Feb 2021 (18)
        addVesting(now + 330 * day, 2500000*SCALING_FACTOR); // Mar 2021 (19)
        addVesting(now + 360 * day, 2500000*SCALING_FACTOR); // Apr 2021 (20)
        addVesting(now + 390 * day, 2500000*SCALING_FACTOR); // May 2021 (21)
        addVesting(now + 420 * day, 2500000*SCALING_FACTOR); // Jun 2021 (22)
        addVesting(now + 450 * day, 2500000*SCALING_FACTOR); // Jul 2021 (23)
        addVesting(now + 480 * day, 2500000*SCALING_FACTOR); // Aug 2021 (24)
    }
    
    
    function tokensFromLockupContract(address _lockup, uint _amount) external {
        uint256 SCALING_FACTOR = 10 ** 18; // decimals
        
        Ilockup(_lockup).withdraw(address(tokenAddress), address(this), _amount*SCALING_FACTOR);
    }
    
    function updateBeneficiaryAddress(address newAddr) external {
        require(newAddr != address(0x0), INVALID_BENEFICIARY);
        require(beneficiaryAddress == msg.sender, "No Access");
        beneficiaryAddress = newAddr;
    }

    /**
     * @dev Token address for vesting contract
     * @return Token contract address
     */
    function token() public view returns (IERC20) {
        return tokenAddress;
    }

    /**
     * @dev Function to check beneficiary of a vesting
     * @return Beneficiary's address
     */
    function beneficiary() public view returns (address) {
        return beneficiaryAddress;
    }

    /**
     * @dev Function to check Release Time of a vesting
     * @param _vestingId  vesting Id
     * @return Release Time in unix timestamp
     */
    function releaseTime(uint256 _vestingId) public view returns (uint256) {
        return vestings[_vestingId].releaseTime;
    }

    /**
     * @dev Function to check token amount of a vesting
     * @param _vestingId  vesting Id
     * @return Number of tokens for a vesting
     */
    function vestingAmount(uint256 _vestingId) public view returns (uint256) {
        return vestings[_vestingId].amount;
    }

    /**
     * @notice Function to remove a vesting by owner of vesting contract
     * @param _vestingId  vesting Id
     */
    function removeVesting(uint256 _vestingId) public onlyOwner {
        Vesting storage vesting = vestings[_vestingId];
        require(beneficiaryAddress != address(0x0), INVALID_VESTING_ID);
        require(!vesting.released , VESTING_ALREADY_RELEASED);
        vesting.released = true;
        tokensToVest = tokensToVest.sub(vesting.amount);
        emit TokenVestingRemoved(_vestingId, beneficiaryAddress, vesting.amount);
    }

    /**
     * @notice Function to add a vesting
     * Since this is onlyOwner protected, tokens are assumed to be transferred to the vesting contract
     * @param _releaseTime  Time for release
     * @param _amount       Amount of vesting
     */
    function addVesting(uint256 _releaseTime, uint256 _amount) public onlyOwner {
        require(beneficiaryAddress != address(0x0), INVALID_BENEFICIARY);
        require(_releaseTime > now, "Invalid release time");
        require(_amount != 0, "Amount must be greater then 0");
        tokensToVest = tokensToVest.add(_amount);
        vestingId = vestingId.add(1);
        vestings[vestingId] = Vesting({
            releaseTime: _releaseTime,
            amount: _amount,
            released: false
        });
        emit TokenVestingAdded(vestingId, beneficiaryAddress, _amount);
    }

    /**
     * @notice Function to release tokens of a vesting id
     * @param _vestingId  vesting Id
     */
    function release(uint256 _vestingId) public {
        Vesting storage vesting = vestings[_vestingId];
        require(beneficiaryAddress != address(0x0), INVALID_VESTING_ID);
        require(!vesting.released , VESTING_ALREADY_RELEASED);
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= vesting.releaseTime, NOT_VESTED);

        require(tokenAddress.balanceOf(address(this)) >= vesting.amount, INSUFFICIENT_BALANCE);
        vesting.released = true;
        tokensToVest = tokensToVest.sub(vesting.amount);
        tokenAddress.safeTransfer(beneficiaryAddress, vesting.amount);
        emit TokenVestingReleased(_vestingId, beneficiaryAddress, vesting.amount);
    }

    /**
     * @dev Function to remove any extra tokens, i.e cancelation of a vesting
     * @param _amount Amount to retrieve
     */
    function retrieveExcessTokens(uint256 _amount) public onlyOwner {
        require(_amount <= tokenAddress.balanceOf(address(this)).sub(tokensToVest), INSUFFICIENT_BALANCE);
        tokenAddress.safeTransfer(owner(), _amount);
    }
}