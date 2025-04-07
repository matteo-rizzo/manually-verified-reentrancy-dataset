/**
 *Submitted for verification at Etherscan.io on 2019-09-02
*/

pragma solidity ^0.5.2;


// File: openzeppelin-solidity/contracts/math/SafeMath.sol


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


// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */


// File: openzeppelin-solidity/contracts/utils/Address.sol


/**
 * @dev Collection of functions related to the address type,
 */


// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: openzeppelin-solidity/contracts/access/Roles.sol


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


// File: contracts/access/roles/OwnerRole.sol



contract OwnerRole {
    using Roles for Roles.Role;

    event OwnerAdded(address indexed account);
    event OwnerRemoved(address indexed account);

    Roles.Role private _owners;

    constructor () internal {
        _addOwner(msg.sender);
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "OwnerRole: caller does not have the Owner role");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return _owners.has(account);
    }

    function addOwner(address account) public onlyOwner {
        //if (!isOwner(account)) {
        _addOwner(account);
        //}
    }

    function renounceOwner() public {
        _removeOwner(msg.sender);
    }

    function _addOwner(address account) internal {
        _owners.add(account);
        emit OwnerAdded(account);
    }

    function _removeOwner(address account) internal {
        _owners.remove(account);
        emit OwnerRemoved(account);
    }
}

// File: contracts/TokenVesting.sol






/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract TokenVesting is OwnerRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private token;
    uint256 private tokensToVest = 0;
    uint256 private vestingId = 0;

    string private constant INSUFFICIENT_BALANCE = "Insufficient balance";
    string private constant INVALID_VESTING_ID = "Invalid vesting id";
    string private constant VESTING_ALREADY_RELEASED = "Vesting already released";
    string private constant INVALID_BENEFICIARY = "Invalid beneficiary address";
    string private constant NOT_VESTED = "Tokens have not vested yet";

    struct Vesting {
        uint256 releaseTime;
        uint256 amount;
        address beneficiary;
        bool released;
    }
    mapping(uint256 => Vesting) public vestings;

    event TokenVestingReleased(uint256 indexed vestingId, address indexed beneficiary, uint256 amount);
    event TokenVestingAdded(uint256 indexed vestingId, address indexed beneficiary, uint256 amount);
    event TokenVestingRemoved(uint256 indexed vestingId, address indexed beneficiary, uint256 amount);

    constructor(IERC20 _token, address _beneficiary, uint256 _day) public {
        require(address(_token) != address(0x0), "Token address is not valid");
        token = _token;
        addVestingPlan(_beneficiary, _day);
    }

    function getToken() public view returns (IERC20) {
        return token;
    }

    function beneficiary(uint256 _vestingId) public view returns (address) {
        return vestings[_vestingId].beneficiary;
    }

    function releaseTime(uint256 _vestingId) public view returns (uint256) {
        return vestings[_vestingId].releaseTime;
    }

    function vestingAmount(uint256 _vestingId) public view returns (uint256) {
        return vestings[_vestingId].amount;
    }

    function removeVesting(uint256 _vestingId) public onlyOwner {
        Vesting storage vesting = vestings[_vestingId];
        require(vesting.beneficiary != address(0x0), INVALID_VESTING_ID);
        require(!vesting.released, VESTING_ALREADY_RELEASED);
        vesting.released = true;
        tokensToVest = tokensToVest.sub(vesting.amount);
        emit TokenVestingRemoved(_vestingId, vesting.beneficiary, vesting.amount);
    }

    function addVesting(address _beneficiary, uint256 _releaseTime, uint256 _amount) public onlyOwner {
        require(_beneficiary != address(0x0), INVALID_BENEFICIARY);
        tokensToVest = tokensToVest.add(_amount);
        vestingId = vestingId.add(1);
        vestings[vestingId] = Vesting({
            beneficiary: _beneficiary,
            releaseTime: _releaseTime,
            amount: _amount,
            released: false
        });
        emit TokenVestingAdded(vestingId, _beneficiary, _amount);
    }

    function release(uint256 _vestingId) public {
        Vesting storage vesting = vestings[_vestingId];
        require(vesting.beneficiary != address(0x0), INVALID_VESTING_ID);
        require(!vesting.released, VESTING_ALREADY_RELEASED);
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= vesting.releaseTime, NOT_VESTED);

        require(token.balanceOf(address(this)) >= vesting.amount, INSUFFICIENT_BALANCE);
        vesting.released = true;
        tokensToVest = tokensToVest.sub(vesting.amount);
        token.safeTransfer(vesting.beneficiary, vesting.amount);
        emit TokenVestingReleased(_vestingId, vesting.beneficiary, vesting.amount);
    }

    function retrieveExcessTokens(uint256 _amount) public onlyOwner {
        require(_amount <= token.balanceOf(address(this)).sub(tokensToVest), INSUFFICIENT_BALANCE);
        token.safeTransfer(msg.sender, _amount);
    }

    function addVestingPlan(address _beneficiary, uint256 _day) private onlyOwner {
        uint256 SCALING_FACTOR = 10 ** 18;
        uint256 day = _day;
        addVesting(_beneficiary, now + 0, 3230085552 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 30 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 61 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 91 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 122 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 153 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 183 * day, 1088418885 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 214 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 244 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 275 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 306 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 335 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 366 * day, 1218304816 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 396 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 427 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 457 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 488 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 519 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 549 * day, 1218304816 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 580 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 610 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 641 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 672 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 700 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 731 * day, 1084971483 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 761 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 792 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 822 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 853 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 884 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 914 * day, 618304816 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 945 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 975 * day, 25000000 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 1096 * day, 593304816 * SCALING_FACTOR);
        addVesting(_beneficiary, now + 1279 * day, 273304816 * SCALING_FACTOR);
    }
}