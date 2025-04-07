/**
 *Submitted for verification at Etherscan.io on 2021-03-22
*/

/// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.12;

/// @dev brief interface for moloch dao v2 erc20 token txs


/// @dev brief interface for moloch dao v2 


/// @dev brief interface for sushi bar (`xSUSHI`) entry


/// @dev helper for address type


/// @dev helper for non-standard token


/// @dev helper for under/overflow check


/// @dev call wrapper for reentrancy check
contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

/// @dev low-level caller, ETH holder, separate bank for moloch dao v2 - based on raid guild `Minion`
contract SushiMinion is ReentrancyGuard {
    address immutable sushiToken; // internal sushi token contract reference
    IMOLOCH public moloch; // parent moloch contract reference 

    mapping(uint256 => Action) public actions; // proposalId => Action

    struct Action {
        uint256 value;
        address to;
        address proposer;
        bool executed;
        bytes data;
    }

    event ProposeAction(uint256 proposalId, address proposer);
    event ExecuteAction(uint256 proposalId, address executor);

    constructor(address _moloch, address _sushiToken, address _xSushiToken, address _aave) public {
        moloch = IMOLOCH(_moloch);
        sushiToken = _sushiToken;
        IERC20(_sushiToken).approve(_xSushiToken, uint256(-1)); // max approve sushi bar for sushi token staking into xSushi
        IERC20(_xSushiToken).approve(_aave, uint256(-1)); // max approve aave for deposit into aToken from underlying xSushi
    }

    function doWithdraw(address token, uint256 amount) external nonReentrant {
        moloch.withdrawBalance(token, amount); // withdraw funds from parent moloch into minion
    }

    function proposeAction(
        address actionTo,
        uint256 actionValue,
        bytes calldata actionData,
        string calldata details
    ) external nonReentrant returns (uint256) {
        // No calls to zero address allows us to check that proxy submitted
        // the proposal without getting the proposal struct from parent moloch
        require(actionTo != address(0), "invalid actionTo");

        uint256 proposalId = moloch.submitProposal(
            address(this),
            0,
            0,
            0,
            sushiToken,
            0,
            sushiToken,
            details
        );

        Action memory action = Action({
            value: actionValue,
            to: actionTo,
            proposer: msg.sender,
            executed: false,
            data: actionData
        });

        actions[proposalId] = action;

        emit ProposeAction(proposalId, msg.sender);
        return proposalId;
    }

    function executeAction(uint256 proposalId) external nonReentrant returns (bytes memory) {
        Action memory action = actions[proposalId];
        bool[6] memory flags = moloch.getProposalFlags(proposalId);

        require(action.to != address(0), "invalid proposalId");
        require(!action.executed, "action executed");
        require(address(this).balance >= action.value, "insufficient ETH");
        require(flags[2], "proposal not passed");

        // execute call
        actions[proposalId].executed = true;
        (bool success, bytes memory retData) = action.to.call{value: action.value}(action.data);
        require(success, "call failure");
        emit ExecuteAction(proposalId, msg.sender);
        return retData;
    }

    receive() external payable {}
}