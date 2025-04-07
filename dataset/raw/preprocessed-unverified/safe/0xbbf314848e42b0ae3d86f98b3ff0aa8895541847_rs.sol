/**
 *Submitted for verification at Etherscan.io on 2019-12-26
*/

/**
 *Submitted for verification at Etherscan.io on 2019-05-22
*/

/**
 * Source Code first verified at https://etherscan.io on Saturday, April 20, 2019
 (UTC) */

pragma solidity 0.5.2;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */


// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */


// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/HGTokenTokenAirdropVesting.sol

/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract HGTokenAirdropVesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private HGToken;
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

    constructor(IERC20 _token) public {
        require(address(_token) != address(0x0), "HG token address is not valid");
        HGToken = _token;

        uint256 SCALING_FACTOR = 10 ** 18;
        uint256 day = 1 seconds;

        addVesting(0x18b0c9A0F972dBB09F34C8ade1820B62DdDdEF76, now + 10 * day, 10000 * SCALING_FACTOR);
    }

    function token() public view returns (IERC20) {
        return HGToken;
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
        require(!vesting.released , VESTING_ALREADY_RELEASED);
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
        require(!vesting.released , VESTING_ALREADY_RELEASED);
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= vesting.releaseTime, NOT_VESTED);

        require(HGToken.balanceOf(address(this)) >= vesting.amount, INSUFFICIENT_BALANCE);
        vesting.released = true;
        tokensToVest = tokensToVest.sub(vesting.amount);
        HGToken.safeTransfer(vesting.beneficiary, vesting.amount);
        emit TokenVestingReleased(_vestingId, vesting.beneficiary, vesting.amount);
    }

    function retrieveExcessTokens(uint256 _amount) public onlyOwner {
        require(_amount <= HGToken.balanceOf(address(this)).sub(tokensToVest), INSUFFICIENT_BALANCE);
        HGToken.safeTransfer(owner(), _amount);
    }
}