/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity ^0.5.8;


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */



/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */



contract IssuerRole {
    using Roles for Roles.Role;

    event IssuerAdded(address indexed account);
    event IssuerRemoved(address indexed account);

    Roles.Role private _issuers;

    constructor () internal {
        _addIssuer(msg.sender);
    }

    modifier onlyIssuer() {
        require(isIssuer(msg.sender));
        _;
    }

    function isIssuer(address account) public view returns (bool) {
        return _issuers.has(account);
    }

    function addIssuer(address account) public onlyIssuer {
        _addIssuer(account);
    }

    function renounceIssuer() public {
        _removeIssuer(msg.sender);
    }

    function _addIssuer(address account) internal {
        _issuers.add(account);
        emit IssuerAdded(account);
    }

    function _removeIssuer(address account) internal {
        _issuers.remove(account);
        emit IssuerRemoved(account);
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */



/**
 * @title interface for unsafe ERC20
 * @dev Unsafe ERC20 does not return when transfer, approve, transferFrom
 */



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



/**
 * @title Token bank
 */
contract TokenBank is IssuerRole, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // this token bank contract will use this binded ERC20 token
    IERC20 public bindedToken;

    // use deposited[user] to get the deposited ERC20 tokens
    mapping(address => uint256) public deposited;

    event Deposited(
        address indexed depositor,
        address indexed receiver,
        uint256 amount,
        uint256 balance
    );

    event Withdrawn(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 balance
    );

    event InterestIssued(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    /**
     * @param token binded ERC20 token
     */
    constructor(address token) public {
        bindedToken = IERC20(token);
    }

    /**
     * @notice deposit ERC20 token to receiver address
     * @param receiver address of who will receive the deposited tokens
     * @param amount amount of ERC20 token to deposit
     */
    function depositTo(address receiver, uint256 amount) external {
        deposited[receiver] = deposited[receiver].add(amount);
        emit Deposited(msg.sender, receiver, amount, deposited[receiver]);
        bindedToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @notice withdraw tokens from token bank to specific receiver
     * @param to withdrawn token transfer to this address
     * @param amount amount of ERC20 token to withdraw
     */
    function withdrawTo(address to, uint256 amount) external {
        deposited[msg.sender] = deposited[msg.sender].sub(amount);
        emit Withdrawn(msg.sender, to, amount, deposited[msg.sender]);
        bindedToken.safeTransfer(to, amount);
    }

    /**
     * @notice bulk issue interests to users
     * @dev addrs[0] receives nums[0] as its interest
     * @param safe whether the paid token is a safe ERC20
     * @param paidToken use the ERC20 token to pay interests
     * @param fromWallet interests will pay from this wallet account
     * @param interests an array of interests
     * @param receivers an array of interest receivers
     */
    function bulkIssueInterests(
        bool safe,
        address paidToken,
        address fromWallet,
        uint256[] calldata interests,
        address[] calldata receivers
    )
        external
        onlyIssuer
    {
        require(
            interests.length == receivers.length,
            "Failed to bulk issue interests due to illegal arguments."
        );

        if (safe) {
            IERC20 token = IERC20(paidToken);
            // issue interests to all receivers
            for (uint256 i = 0; i < receivers.length; i = i.add(1)) {
                emit InterestIssued(
                    paidToken,
                    fromWallet,
                    receivers[i],
                    interests[i]
                );
                token.safeTransferFrom(fromWallet, receivers[i], interests[i]);
            }
        } else {
            IUnsafeERC20 token = IUnsafeERC20(paidToken);
            // issue interests to all receivers
            for (uint256 i = 0; i < receivers.length; i = i.add(1)) {
                emit InterestIssued(
                    paidToken,
                    fromWallet,
                    receivers[i],
                    interests[i]
                );
                token.transferFrom(fromWallet, receivers[i], interests[i]);
            }
        }
    }
}