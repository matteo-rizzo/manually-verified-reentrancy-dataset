/**
 *Submitted for verification at Etherscan.io on 2021-09-15
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



// Part: IComp



// Part: IGovernorDelegate



// Part: IVoteController



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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


// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: Vote.sol

contract Vote {
    using SafeERC20 for IERC20;

    address public governance;
    address public pendingGovernance;
    address public voteController;
    uint8   public support;

    constructor(address _voteController, uint8 _support) public {
        governance = msg.sender;
        voteController = _voteController;
        support = _support;
    }

    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "!pendingGovernance");
        governance = msg.sender;
        pendingGovernance = address(0);
    }
    function setPendingGovernance(address _pendingGovernance) external {
        require(msg.sender == governance, "!governance");
        pendingGovernance = _pendingGovernance;
    }
    function setVoteController(address _voteController) external {
        require(msg.sender == governance, "!governance");
        voteController = _voteController;
    }

    function delegate(address _comp) external {
        IComp(_comp).delegate(address(this));
    }

    function returnToken(address _comp, address _receiver) external returns (uint256 _amount) {
        require(msg.sender == voteController || msg.sender == governance, "!voteController");
        _amount = IERC20(_comp).balanceOf(address(this));
        IERC20(_comp).safeTransfer(_receiver, _amount);
    }

    function castVote(address _comp, uint256 _proposalId) external {
        require(msg.sender == voteController || msg.sender == governance, "!voteController");
        address governor = IVoteController(voteController).governors(_comp);
        require(governor != address(0), "!governor");
        IGovernorDelegate(governor).castVote(_proposalId, support);
    }

    function propose(address _comp, address[] memory targets, uint256[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) external returns (uint256){
        require(msg.sender == voteController || msg.sender == governance, "!voteController");
        address governor = IVoteController(voteController).governors(_comp);
        require(governor != address(0), "!governor");
        return IGovernorDelegate(governor).propose(targets, values, signatures, calldatas, description);
    }

    function proposalThreshold(address _comp) public view returns (uint256){
        address governor = IVoteController(voteController).governors(_comp);
        require(governor != address(0), "!governor");
        return IGovernorDelegate(governor).proposalThreshold();
    }

    function state(address _comp, uint256 _proposalId) public view returns (uint8){
        address governor = IVoteController(voteController).governors(_comp);
        require(governor != address(0), "!governor");
        return IGovernorDelegate(governor).state(_proposalId);
    }

    function proposals(address _comp, uint256 _proposalId) public view returns (uint256 _id, address _proposer,
        uint256 _eta, uint256 _startBlock, uint256 _endBlock, uint256 _forVotes, uint256 _againstVotes,
        uint256 _abstainVotes, bool _canceled, bool _executed){
        address governor = IVoteController(voteController).governors(_comp);
        require(governor != address(0), "!governor");
        return IGovernorDelegate(governor).proposals(_proposalId);
    }
}