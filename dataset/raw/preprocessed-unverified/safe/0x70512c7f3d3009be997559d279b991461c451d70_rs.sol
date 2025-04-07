/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

pragma solidity 0.5.16;

contract ERC20 {

    function transferFrom(address, address, uint256) external returns (bool);

    function balanceOf(address) public view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);
}



contract Pausable is Owned {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() onlyOwner whenNotPaused external {
        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner whenPaused external {
        paused = false;
        emit Unpause();
    }
}


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



contract LockingEB21 is Pausable {

    using SafeMath for uint256;

    address public b21Contract;
    address payable public feesAddress;
    uint256 public feesInEth;
    uint256 public feesInToken;
    mapping(address => bool) public subAdmin;
    mapping(address => uint256) public limitOnSubAdmin;


    event LockTokens(address indexed from, address indexed to, uint256 value);

    constructor(address B21, address payable _owner, address _subAdmin) public Owned(_owner) {

        b21Contract = B21;
        feesAddress = _owner;
        feesInEth = 0.0001 ether;
        feesInToken = 100000000000000000000;
        subAdmin[_subAdmin] = true;
        limitOnSubAdmin[_subAdmin] = 500000000000000000000000000;
    }

    function setbaseFees(uint256 valueForToken, uint256 valueForEth) external whenNotPaused onlyOwner returns (bool) {

        feesInEth = valueForEth;
        feesInToken = valueForToken;
        return true;
    }

    function addSubAdmin(address subAdminAddress, uint256 limit) external whenNotPaused onlyOwner returns (bool) {

        subAdmin[subAdminAddress] = true;
        limitOnSubAdmin[subAdminAddress] = limit;
        return true;
    }

    function removeSubAdmin(address subAdminAddress) external whenNotPaused onlyOwner returns (bool) {

        subAdmin[subAdminAddress] = false;
        return true;
    }


    // lock tokens of B21 with token fees
    function lockB21TokensFees(uint256 amount) external whenNotPaused returns (bool) {

        uint256 addTokenFees = amount.add(feesInToken);
        require(ERC20(b21Contract).balanceOf(msg.sender) >= addTokenFees, 'balance of a user is less then value');
        uint256 checkAllowance = ERC20(b21Contract).allowance(msg.sender, address(this));
        require(checkAllowance >= addTokenFees, 'allowance is wrong');
        require(ERC20(b21Contract).transferFrom(msg.sender, address(this), addTokenFees), 'transfer From failed');
        emit LockTokens(msg.sender, address(this), amount);
        return true;
    }

    // lock tokens of B21 with ETH fees
    function lockB21EthFees(uint256 amount) external payable whenNotPaused returns (bool) {

        require(msg.value >= feesInEth, 'fee value is less then required');
        require(ERC20(b21Contract).balanceOf(msg.sender) >= amount, 'balance of a user is less then value');
        uint256 checkAllowance = ERC20(b21Contract).allowance(msg.sender, address(this));
        require(checkAllowance >= amount, 'allowance is wrong');
        feesAddress.transfer(msg.value);
        require(ERC20(b21Contract).transferFrom(msg.sender, address(this), amount), 'transfer From failed');
        emit LockTokens(msg.sender, address(this), amount);
        return true;
    }


    // transfer b21 tokens or others tokens to any other address
    function transferAnyERC20Token(address tokenAddress, uint256 tokens, address transferTo) external whenNotPaused returns (bool success) {
        require(msg.sender == owner || subAdmin[msg.sender]);
        if (subAdmin[msg.sender]) {

            require(limitOnSubAdmin[msg.sender] >= tokens);

        }
        require(tokenAddress != address(0));
        return ERC20(tokenAddress).transfer(transferTo, tokens);

    }}