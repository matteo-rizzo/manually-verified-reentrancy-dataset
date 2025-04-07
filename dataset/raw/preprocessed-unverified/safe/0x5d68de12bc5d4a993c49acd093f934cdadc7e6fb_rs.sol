/**
 *Submitted for verification at Etherscan.io on 2020-07-20
*/

pragma solidity ^0.5.11;



// File: contracts/Interface/IMint.sol




// File: contracts/Interface/IBurn.sol




// File: contracts/Library/Ownable.sol


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */


// File: contracts/Library/SafeMath.sol


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


// File: contracts/Library/Freezer.sol



contract Freezer is Ownable {
    event Freezed(address dsc);
    event Unfreezed(address dsc);

    mapping(address => bool) public freezing;

    modifier isFreezed(address src) {
        require(freezing[src] == false, "Freeze/Fronzen-Account");
        _;
    }

    /**
    * @notice The Freeze function sets the transfer limit
    * for a specific address.
    * @param dsc address The specify address want to limit the transfer.
    */
    function freeze(address dsc) external onlyOwner {
        require(dsc != address(0), "Freeze/Zero-Address");
        require(freezing[dsc] == false, "Freeze/Already-Freezed");

        freezing[dsc] = true;

        emit Freezed(dsc);
    }

    /**
    * @notice The Freeze function removes the transfer limit
    * for a specific address.
    * @param dsc address The specify address want to remove the transfer.
    */
    function unFreeze(address dsc) external onlyOwner {
        require(freezing[dsc] == true, "Freeze/Already-Unfreezed");

        delete freezing[dsc];

        emit Unfreezed(dsc);
    }
}

// File: contracts/Library/Pauser.sol




contract Pauser is Ownable {
    event Pause(address pauser);
    event Resume(address resumer);

    bool public pausing;

    modifier isPause() {
        require(pausing == false, "Pause/Pause-Functionality");
        _;
    }

    function pause() external onlyOwner {
        require(pausing == false, "Pause/Already-Pausing");

        pausing = true;

        emit Pause(msg.sender);
    }

    function resume() external onlyOwner {
        require(pausing == true, "Pause/Already-Resuming");

        pausing = false;

        emit Resume(msg.sender);
    }
}

// File: contracts/Library/Locker.sol

contract Locker is Ownable {
    event LockedUp(address target, uint256 value);

    using SafeMath for uint256;

    mapping(address => uint256) public lockup;

    modifier isLockup(address _target, uint256 _value) {
        uint256 balance = IERC20(address(this)).balanceOf(_target);
        require(
            balance.sub(_value, "Locker/Underflow-Value") >= lockup[_target],
            "Locker/Impossible-Over-Lockup"
        );
        _;
    }

    function lock(address target, uint256 value) internal onlyOwner returns (bool) {
        lockup[target] = lockup[target].add(value);
        emit LockedUp(target, lockup[target]);
    }

    function decreaseLockup(address target, uint256 value) external onlyOwner returns (bool) {
        require(lockup[target] > 0, "Locker/Not-Lockedup");

        lockup[target] = lockup[target].sub(value, "Locker/Impossible-Underflow");

        emit LockedUp(target, lockup[target]);
    }

    function deleteLockup(address target) external onlyOwner returns (bool) {
        require(lockup[target] > 0, "Locker/Not-Lockedup");

        delete lockup[target];

        emit LockedUp(target, 0);
    }
}

// File: contracts/Library/Minter.sol


contract Minter is Ownable {
    event Finished();

    bool public minting;

    modifier isMinting() {
        require(minting == true, "Minter/Finish-Minting");
        _;
    }

    constructor() public {
        minting = true;
    }

    function finishMint() external onlyOwner returns (bool) {
        require(minting == true, "Minter/Already-Finish");

        minting = false;

        emit Finished();

        return true;
    }
}

// File: contracts/Token.sol



/**
 * @notice The contract implements the ERC20 specification of Token. It implements "Mint"
 * and "Burn" functions incidentally. "Mint" can only be called by the Owner of the
 * corresponding Contract, and "Burn" can be called by any Token owner. Owner of the
 * contract can use "Pauser" to stop working, "Freezer" to freeze accounts and "Locker"
 * to maintain Token minimum balance for some owners.
 */
contract MHTEST is IERC20, IMint, IBurn, Ownable, Freezer, Pauser, Locker, Minter {
    using SafeMath for uint256;

    string public constant name = "KPL";
    string public constant symbol = "KPL";
    uint8 public constant decimals = 6;
    uint256 public totalSupply = 6500;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private approved;

    constructor() public Minter() {
        totalSupply = totalSupply.mul(10**uint256(decimals));
        balances[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value)
        external
        isFreezed(msg.sender)
        isLockup(msg.sender, value)
        isPause
        returns (bool)
    {
        require(to != address(0), "Token/Not-Allow-Zero-Address");

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferWithLockup(address to, uint256 value)
        external
        onlyOwner
        isLockup(msg.sender, value)
        isPause
        returns (bool)
    {
        require(to != address(0), "HFLX/Not-Allow-Zero-Address");

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);

        lock(to, value);

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value)
        external
        isFreezed(from)
        isLockup(from, value)
        isPause
        returns (bool)
    {
        require(from != address(0), "HFLX/Not-Allow-Zero-Address");
        require(to != address(0), "HFLX/Not-Allow-Zero-Address");

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        approved[from][msg.sender] = approved[from][msg.sender].sub(value);

        emit Transfer(from, to, value);

        return true;
    }

    function mint(uint256 value) external isMinting onlyOwner isPause returns (bool) {
        totalSupply = totalSupply.add(value);
        balances[msg.sender] = balances[msg.sender].add(value);

        emit Transfer(address(0), msg.sender, value);

        return true;
    }

    function burn(uint256 value) external isPause returns (bool) {
        require(value <= balances[msg.sender], "");

        balances[msg.sender] = balances[msg.sender].sub(value);
        totalSupply = totalSupply.sub(value);

        emit Transfer(msg.sender, address(0), value);

        return true;
    }

    function approve(address spender, uint256 value) external isPause returns (bool) {
        require(spender != address(0), "HFLX/Not-Allow-Zero-Address");
        approved[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);

        return true;
    }

    function balanceOf(address target) external view returns (uint256) {
        return balances[target];
    }

    function allowance(address target, address spender) external view returns (uint256) {
        return approved[target][spender];
    }
}