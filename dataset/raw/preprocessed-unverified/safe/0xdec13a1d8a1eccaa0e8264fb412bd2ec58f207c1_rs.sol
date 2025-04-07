/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

pragma solidity 0.6.11;
// SPDX-License-Identifier: BSD-3-Clause

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @dev Collection of functions related to the address type
 */







/**
 * @title Governance
 * @dev Governance smart contract for staking pools
 * Takes in DYP as votes
 * Allows addition and removal of votes during a proposal is open
 * Allows withdrawal of all dyp once the latest voted proposal of a user is closed
 * Has a QUORUM requirement for proposals to be executed
 * CONTRACT VARIABLES must be changed to appropriate values before live deployment
 */
contract Governance {
    using SafeMath for uint;
    using Address for address;
    // Contracts are not allowed to deposit, claim or withdraw
    modifier noContractsAllowed() {
        require(!(address(msg.sender).isContract()) && tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }
    
    // ============== CONTRACT VARIABLES ==============
    
    // voting token contract address
    address public constant TRUSTED_TOKEN_ADDRESS = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17;
    
    // minimum number of votes required for a result to be valid
    // 1 token = 1 vote
    uint public constant QUORUM = 50000e18;
    
    // minimum number of tokens required to initialize a proposal
    uint public constant MIN_BALANCE_TO_INIT_PROPOSAL = 10000e18;
    
    // duration since proposal creation till users can vote
    uint public constant VOTE_DURATION = 3 days;
    
    // duration after voting, since a proposal has passed
    // during which the proposed action may be executed
    uint public constant RESULT_EXECUTION_ALLOWANCE_PERIOD = 3 days;
    
    // ============ END CONTRACT VARIABLES ============
    
    enum Action {
        DISBURSE_OR_BURN,
        UPGRADE_GOVERNANCE
    }
    enum Option {
        ONE, // disburse | yes
        TWO // burn | no
    }
    
    // proposal id => action
    mapping (uint => Action) public actions;
    
    // proposal id => option one votes
    mapping (uint => uint) public optionOneVotes;
    
    // proposal id => option two votes
    mapping (uint => uint) public optionTwoVotes;
    
    // proposal id => staking pool
    mapping (uint => StakingPool) public stakingPools;
    
    // proposal id => newGovernance
    mapping (uint => address) public newGovernances;
    
    // proposal id => unix time for proposal start
    mapping (uint => uint) public proposalStartTime;
    
    // proposal id => bool
    mapping (uint => bool) public isProposalExecuted;
    
    // address user => total deposited DYP
    mapping (address => uint) public totalDepositedTokens;
    
    // address user => uint proposal id => uint vote amounts
    mapping (address => mapping (uint => uint)) public votesForProposalByAddress;
    
    // address user => uint proposal id => Option voted for option
    mapping (address => mapping (uint => Option)) public votedForOption;
    
    // address user => uint proposal id for the latest proposal the user voted on
    mapping (address => uint) public lastVotedProposalStartTime;
    
    // uint last proposal id
    // proposal ids start at 1
    uint public lastIndex = 0;
    
    // view function to get proposal details
    function getProposal(uint proposalId) external view returns (
        uint _proposalId, 
        Action _proposalAction,
        uint _optionOneVotes,
        uint _optionTwoVotes,
        StakingPool _stakingPool,
        address _newGovernance,
        uint _proposalStartTime,
        bool _isProposalExecuted
        ) {
        _proposalId = proposalId;
        _proposalAction = actions[proposalId];
        _optionOneVotes = optionOneVotes[proposalId];
        _optionTwoVotes = optionTwoVotes[proposalId];
        _stakingPool = stakingPools[proposalId];
        _newGovernance = newGovernances[proposalId];
        _proposalStartTime = proposalStartTime[proposalId];
        _isProposalExecuted = isProposalExecuted[proposalId];
    }
    
    // Any DYP holder with a minimum required DYP balance may initiate a proposal
    // to with the DISBURSE_OR_BURN action for a given staking pool
    function proposeDisburseOrBurn(StakingPool pool) external noContractsAllowed {
        require(Token(TRUSTED_TOKEN_ADDRESS).balanceOf(msg.sender) >= MIN_BALANCE_TO_INIT_PROPOSAL, "Insufficient Governance Token Balance");
        lastIndex = lastIndex.add(1);
        stakingPools[lastIndex] = pool;
        proposalStartTime[lastIndex] = now;
        actions[lastIndex] = Action.DISBURSE_OR_BURN;
    }
    
    // Any DYP holder with a minimum required DYP balance may initiate a proposal
    // to with the UPGRADE_GOVERNANCE action for a given staking pool
    function proposeUpgradeGovernance(StakingPool pool, address newGovernance) external noContractsAllowed {
        require(Token(TRUSTED_TOKEN_ADDRESS).balanceOf(msg.sender) >= MIN_BALANCE_TO_INIT_PROPOSAL, "Insufficient Governance Token Balance");
        lastIndex = lastIndex.add(1);
        stakingPools[lastIndex] = pool;
        newGovernances[lastIndex] = newGovernance;
        proposalStartTime[lastIndex] = now;
        actions[lastIndex] = Action.UPGRADE_GOVERNANCE;
    }
    
    // Any DYP holder may add votes for a particular open proposal, 
    // with options YES / NO | DISBURSE / BURN | ONE / TWO
    // with `amount` DYP, each DYP unit corresponds to one vote unit
    
    // If user has already voted for a proposal with an option,
    // user may not add votes with another option, 
    // they will need to add votes for the same option
    function addVotes(uint proposalId, Option option, uint amount) external noContractsAllowed {
        require(amount > 0, "Cannot add 0 votes!");
        require(isProposalOpen(proposalId), "Proposal is closed!");
        
        require(Token(TRUSTED_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), amount), "transferFrom failed!");
        
        // if user is voting for this proposal first time
        if (votesForProposalByAddress[msg.sender][proposalId] == 0) {
            votedForOption[msg.sender][proposalId] = option;
        } else {
            if (votedForOption[msg.sender][proposalId] != option) {
                revert("Cannot vote for both options!");
            }
        }
        
        if (option == Option.ONE) {
            optionOneVotes[proposalId] = optionOneVotes[proposalId].add(amount);
        } else {
            optionTwoVotes[proposalId] = optionTwoVotes[proposalId].add(amount);
        }
        totalDepositedTokens[msg.sender] = totalDepositedTokens[msg.sender].add(amount);
        votesForProposalByAddress[msg.sender][proposalId] = votesForProposalByAddress[msg.sender][proposalId].add(amount);
        
        if (lastVotedProposalStartTime[msg.sender] < proposalStartTime[proposalId]) {
            lastVotedProposalStartTime[msg.sender] = proposalStartTime[proposalId];
        }
    }
    
    // Any voter may remove their votes (DYP) from any proposal they voted for 
    // only when the proposal is open - removing votes refund DYP to user and deduct their votes
    function removeVotes(uint proposalId, uint amount) external noContractsAllowed {
        require(amount > 0, "Cannot remove 0 votes!");
        require(isProposalOpen(proposalId), "Proposal is closed!");
        
        require(amount <= votesForProposalByAddress[msg.sender][proposalId], "Cannot remove more tokens than deposited!");
        
        votesForProposalByAddress[msg.sender][proposalId] = votesForProposalByAddress[msg.sender][proposalId].sub(amount);
        totalDepositedTokens[msg.sender] = totalDepositedTokens[msg.sender].sub(amount);
        
        if (votedForOption[msg.sender][proposalId] == Option.ONE) {
            optionOneVotes[proposalId] = optionOneVotes[proposalId].sub(amount);
        } else {
            optionTwoVotes[proposalId] = optionTwoVotes[proposalId].sub(amount);
        }
        
        require(Token(TRUSTED_TOKEN_ADDRESS).transfer(msg.sender, amount), "transfer failed");
    }

    // After the latest proposal the user voted for, is closed for voting,
    // The user may remove all DYP they added to this contract
    function withdrawAllTokens() external noContractsAllowed {
        require(now > lastVotedProposalStartTime[msg.sender].add(VOTE_DURATION), "Tokens are still in voting!");
        require(Token(TRUSTED_TOKEN_ADDRESS).transfer(msg.sender, totalDepositedTokens[msg.sender]), "transfer failed!");
        totalDepositedTokens[msg.sender] = 0;
    }
    
    // After votes for a proposal are closed, the proposal may be executed by anyone
    // If QUORUM is not reached, transaction must revert
    // If winning option has more votes than losing option, winning action is executed
    // Else losing action is executed
    // Each proposal may be executed only once
    function executeProposal(uint proposalId) external noContractsAllowed {
        require(isProposalExecutible(proposalId), "Proposal Expired!");
        isProposalExecuted[proposalId] = true;
        
        Option winningOption;
        uint winningOptionVotes;
        
        if (optionOneVotes[proposalId] > optionTwoVotes[proposalId]) {
            winningOption = Option.ONE;
            winningOptionVotes = optionOneVotes[proposalId];
        } else {
            winningOption = Option.TWO;
            winningOptionVotes = optionTwoVotes[proposalId];
        }
        
        // no action will be taken if winningOptionVotes are less than QUORUM
        if (winningOptionVotes < QUORUM) {
            revert("QUORUM not reached!");
        }
        
        if (actions[proposalId] == Action.DISBURSE_OR_BURN) {
            if (winningOption == Option.ONE) {
                stakingPools[proposalId].disburseRewardTokens();
            } else {
                stakingPools[proposalId].burnRewardTokens();
            }
        } else if (actions[proposalId] == Action.UPGRADE_GOVERNANCE) {
            if (winningOption == Option.ONE) {
                stakingPools[proposalId].transferOwnership(newGovernances[proposalId]);
            }
        }
    }
    
    // view function to know whether voting for a particular proposal is open
    function isProposalOpen(uint proposalId) public view returns (bool) {
        if (now < proposalStartTime[proposalId].add(VOTE_DURATION)) {
            return true;
        }
        return false;
    }
    
    // View function to know whether voting for a proposal is closed AND 
    // The proposal is within the RESULT_EXECUTION_ALLOWANCE_PERIOD AND
    // Has not been executed yet
    function isProposalExecutible(uint proposalId) public view returns (bool) {
        if ((!isProposalOpen(proposalId)) && 
            (now < proposalStartTime[proposalId].add(VOTE_DURATION).add(RESULT_EXECUTION_ALLOWANCE_PERIOD)) &&
            !isProposalExecuted[proposalId]) {
                return true;
            }
        return false;
    }
    
}