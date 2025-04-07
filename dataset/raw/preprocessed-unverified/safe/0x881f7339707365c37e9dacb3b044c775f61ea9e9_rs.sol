/**
 *Submitted for verification at Etherscan.io on 2021-08-17
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;




// File contracts/lib/Ownable.sol





// File contracts/lib/interface/IGovernable.sol





// File contracts/lib/Governable.sol



contract Governable is Ownable, IGovernable {
    // ============ Mutable Storage ============

    // Mirror governance contract.
    address public override governor;

    // ============ Modifiers ============

    modifier onlyGovernance() {
        require(isOwner() || isGovernor(), "caller is not governance");
        _;
    }

    modifier onlyGovernor() {
        require(isGovernor(), "caller is not governor");
        _;
    }

    // ============ Constructor ============

    constructor(address owner_) Ownable(owner_) {}

    // ============ Administration ============

    function changeGovernor(address governor_) public override onlyGovernance {
        governor = governor_;
    }

    // ============ Utility Functions ============

    function isGovernor() public view override returns (bool) {
        return msg.sender == governor;
    }
}


// File contracts/distribution/interface/IDistributionLogic.sol





// File contracts/distribution/interface/IDistributionStorage.sol





// File contracts/governance/token/interface/IMirrorTokenLogic.sol


interface IMirrorTokenLogic is IGovernable {
    function version() external returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function mint(address to, uint256 amount) external;

    function setTreasuryConfig(address newTreasuryConfig) external;
}


// File contracts/governance/token/interface/IMirrorTokenStorage.sol





// File contracts/interface/IMirrorTreasury.sol





// File contracts/governance/MirrorGovernorV1.sol







contract MirrorGovernorV1 is Governable {
    // ============ Immutable Storage ============
    bytes32 immutable rootNode;
    IENS public immutable ensRegistry;

    // ============ Mutable Storage ============

    // The total number of proposals
    uint256 public proposalCount;
    // The total number of surveys.
    uint256 public surveyCount;
    // The maximum number of actions that can be included in a proposal
    uint256 public constant proposalMaxOperations = 10;
    // The minumum proposal block duration
    uint256 public minProposalDuration = 5760;
    // The minumum survey block duration
    uint256 public minSurveyDuration = 5760;
    // The latest proposal for each proposer.
    mapping(address => uint256) public latestProposalIds;
    // Record of all proposals.
    mapping(uint256 => Proposal) public proposals;
    // Mapping of all surveys.
    mapping(uint256 => Survey) public surveys;
    // Distribution model for voting power.
    address distributionModel;
    // Mirror gov token for voting power.
    address token;
    // Treasury for transfer proposals.
    address treasury;
    // The number of tokens received for voting.
    uint256 votingReward = 15;

    // ============ Enums ============

    enum ProposalState {
        Canceled,
        Active,
        Decided,
        Executed,
        Pending
    }

    enum SurveyState {
        Active,
        Decided
    }

    struct Call {
        address target;
        uint96 value;
        bytes data;
    }

    // ============ Structs ============

    struct Proposal {
        Call call;
        // Unique id for looking up a proposal
        uint256 id;
        // Creator of the proposal
        address proposer;
        // Flag marking whether the proposal has been canceled
        bool canceled;
        // Flag marking whether the proposal has been executed
        bool executed;
        // Voting begins at this block.
        uint256 startBlock;
        // Voting ends at this block.
        uint256 endBlock;
    }

    struct Survey {
        // Unique id for looking up a survey
        uint256 id;
        // Creator of the survey
        address creator;
        // Voting begins at this block.
        uint256 startBlock;
        // Voting ends at this block.
        uint256 endBlock;
    }

    // Mapping of votes.
    mapping(uint256 => mapping(address => bool)) votedOnSurvey;
    mapping(uint256 => mapping(address => bool)) votedOnProposal;

    // ============ Events ============

    // Proposal Events
    event ProposalCreated(uint256 id, address proposer, string description);
    event VoteCast(
        string label,
        address indexed voter,
        uint256 indexed proposalId,
        bool shouldExecute
    );
    event ProposalExecuted(uint256 id);
    event ProposalCanceled(uint256 id);

    // Survey Events
    event SurveyCreated(
        uint256 id,
        address creator,
        string description,
        uint256 duration
    );
    event SurveyResponse(
        uint256 indexed surveyId,
        string label,
        address indexed voter,
        string content
    );

    // Execution Events
    // event ExecuteTransaction(address indexed target, uint256 value, bytes data);

    // Admin events
    event ChangeDistributionModel(address oldModel, address newModel);
    event ChangeToken(address oldToken, address newToken);
    event ChangeTreasury(address oldTreasury, address newTreasury);
    event ChangeVotingReward(uint256 oldReward, uint256 newReward);

    // ============ Constructor ============

    constructor(
        address owner_,
        bytes32 rootNode_,
        address ensRegistry_,
        address token_,
        address distributionModel_
    ) Governable(owner_) {
        rootNode = rootNode_;
        ensRegistry = IENS(ensRegistry_);
        distributionModel = distributionModel_;
        token = token_;
    }

    // ============ Admin Configuration ============

    function changeDistributionModel(address distributionModel_)
        public
        onlyGovernance
    {
        emit ChangeDistributionModel(distributionModel, distributionModel_);
        distributionModel = distributionModel_;
    }

    function changeToken(address token_) public onlyGovernance {
        emit ChangeToken(token, token_);
        token = token_;
    }

    function changeTreasury(address treasury_) public onlyGovernance {
        emit ChangeTreasury(treasury, treasury_);
        treasury = treasury_;
    }

    function changeVotingReward(uint256 votingReward_) public onlyGovernance {
        emit ChangeVotingReward(votingReward, votingReward_);
        votingReward = votingReward_;
    }

    function changeProposalDuration(uint256 newProposalDuration)
        public
        onlyGovernance
    {
        minProposalDuration = newProposalDuration;
    }

    function changeSurveyDuration(uint256 newSurveyDuration)
        public
        onlyGovernance
    {
        minSurveyDuration = newSurveyDuration;
    }

    // ============ Surveys ============

    function createSurvey(
        string memory description,
        // How long should we be able to vote on this for?
        uint256 duration,
        string calldata creatorLabel
    ) public returns (uint256) {
        require(
            isMirrorDAO(creatorLabel, msg.sender),
            "must be registered to create"
        );
        require(duration >= minSurveyDuration, "survey duration is too short");

        surveyCount++;
        Survey memory newSurvey = Survey({
            id: surveyCount,
            creator: msg.sender,
            startBlock: block.number,
            endBlock: block.number + duration
        });

        surveys[newSurvey.id] = newSurvey;

        emit SurveyCreated(newSurvey.id, msg.sender, description, duration);
        return newSurvey.id;
    }

    function respond(
        uint256 surveyId,
        string calldata label,
        // "Intro to NFTs"
        string calldata voteContent
    ) external {
        require(isMirrorDAO(label, msg.sender), "needs to be a member");
        require(
            surveyState(surveyId) == SurveyState.Active,
            "survey must be active"
        );
        require(!votedOnSurvey[surveyId][msg.sender], "already voted");

        votedOnSurvey[surveyId][msg.sender] = true;
        emit SurveyResponse(surveyId, label, msg.sender, voteContent);
        _applyReward();
    }

    // ============ Proposals ============

    function assertSenderCanPropose(string calldata proposerLabel)
        internal
        view
    {
        require(
            isMirrorDAO(proposerLabel, msg.sender),
            "must be registered to create"
        );

        uint256 latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
            ProposalState proposersLatestProposalState = proposalState(
                latestProposalId
            );
            require(
                proposersLatestProposalState != ProposalState.Active,
                "one live proposal per proposer, found an already active proposal"
            );
            require(
                proposersLatestProposalState != ProposalState.Pending,
                "one live proposal per proposer, found an already pending proposal"
            );
        }
    }

    function initProposal(
        Proposal memory newProposal,
        string memory description
    ) internal returns (uint256) {
        proposalCount++;
        proposals[newProposal.id] = newProposal;
        latestProposalIds[newProposal.proposer] = newProposal.id;

        emit ProposalCreated(newProposal.id, msg.sender, description);
        return newProposal.id;
    }

    function propose(
        Call calldata call,
        string memory description,
        // How long should we be able to vote on this for?
        uint256 duration,
        string calldata proposerLabel
    ) public returns (uint256) {
        assertSenderCanPropose(proposerLabel);
        require(
            duration >= minProposalDuration,
            "proposal duration is too short"
        );

        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            call: call,
            canceled: false,
            executed: false,
            startBlock: block.number,
            endBlock: block.number + duration
        });

        return initProposal(newProposal, description);
    }

    // Transfers Mints Mirror Governance Tokens.
    function createMintProposal(
        address receiver,
        uint256 amount,
        string calldata description,
        uint256 duration,
        string calldata proposerLabel
    ) public {
        assertSenderCanPropose(proposerLabel);

        bytes memory data = abi.encodeWithSelector(
            IMirrorTokenLogic(token).mint.selector,
            receiver,
            amount
        );

        Call memory call = Call({target: token, value: 0, data: data});

        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            call: call,
            canceled: false,
            executed: false,
            startBlock: block.number,
            endBlock: block.number + duration
        });

        initProposal(newProposal, description);
    }

    // Transfers ETH from the Treasury.
    function createETHTransferProposal(
        address payable receiver,
        uint256 amount,
        string calldata description,
        uint256 duration,
        string calldata proposerLabel
    ) public {
        assertSenderCanPropose(proposerLabel);

        bytes memory data = abi.encodeWithSelector(
            IMirrorTreasury(treasury).transferFunds.selector,
            receiver,
            amount
        );

        Call memory call = Call({target: treasury, value: 0, data: data});

        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            call: call,
            canceled: false,
            executed: false,
            startBlock: block.number,
            endBlock: block.number + duration
        });

        initProposal(newProposal, description);
    }

    // Transfers ERC20s from the Treasury.
    function createERC20TransferProposal(
        address erc20Token,
        address receiver,
        uint256 amount,
        string calldata description,
        uint256 duration,
        string calldata proposerLabel
    ) public {
        assertSenderCanPropose(proposerLabel);

        bytes memory data = abi.encodeWithSelector(
            IMirrorTreasury(treasury).transferERC20.selector,
            erc20Token,
            receiver,
            amount
        );

        Call memory call = Call({target: treasury, value: 0, data: data});

        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            call: call,
            canceled: false,
            executed: false,
            startBlock: block.number,
            endBlock: block.number + duration
        });

        initProposal(newProposal, description);
    }

    function castVote(
        string calldata label,
        uint256 proposalId,
        bool shouldExecute
    ) external {
        require(isMirrorDAO(label, msg.sender), "needs to be a member");
        require(
            proposalState(proposalId) == ProposalState.Active,
            "proposal must be active"
        );
        require(!votedOnProposal[proposalId][msg.sender], "already voted");

        votedOnProposal[proposalId][msg.sender] = true;
        emit VoteCast(label, msg.sender, proposalId, shouldExecute);
        _applyReward();
    }

    // ============ Voting Power ============

    // Convenience function for returning a voter's voting poewr.
    function votingPower(address voter) public view returns (uint256) {
        if (IDistributionStorage(distributionModel).registered(voter) == 0) {
            return 0;
        }

        uint256 balance = IMirrorTokenStorage(token).balanceOf(voter);
        uint256 claimable = IDistributionLogic(distributionModel).claimable(
            voter
        );

        return balance + claimable;
    }

    // ============ Proposal Management ============

    // Can only be called by the owner.
    function executeProposal(uint256 proposalId) external payable onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        // Can be executed if voting is complete.
        require(
            proposalState(proposalId) == ProposalState.Decided,
            "proposal undecided"
        );
        // Once executed, we set this to executed.
        proposal.executed = true;
        _executeTransaction(proposal.call);
        emit ProposalExecuted(proposalId);
    }

    function cancel(uint256 proposalId) external {
        require(
            proposalState(proposalId) != ProposalState.Executed,
            "cancel: cannot cancel executed proposal"
        );

        Proposal storage proposal = proposals[proposalId];

        require(
            msg.sender == proposal.proposer || msg.sender == owner,
            "only proposer or gov owner can cancel"
        );

        proposal.canceled = true;

        emit ProposalCanceled(proposalId);
    }

    // ============ Utility Functions ============

    function isMirrorDAO(string calldata label, address claimant)
        public
        view
        returns (bool mirrorDAO)
    {
        bytes32 labelNode = keccak256(abi.encodePacked(label));
        bytes32 node = keccak256(abi.encodePacked(rootNode, labelNode));

        mirrorDAO = claimant == ensRegistry.owner(node);
    }

    function proposalState(uint256 proposalId)
        public
        view
        returns (ProposalState)
    {
        require(proposalCount >= proposalId, "invalid proposal id");
        Proposal storage proposal = proposals[proposalId];

        if (proposal.canceled) {
            // Cancelled by proposer or owner.
            return ProposalState.Canceled;
        } else if (proposal.executed) {
            // Successfully executed.
            return ProposalState.Executed;
        } else if (block.number <= proposal.endBlock) {
            // Still being voted on.
            return ProposalState.Active;
        } else {
            // At this point, it should either get executed or it didn't pass.
            return ProposalState.Decided;
        }
    }

    function surveyState(uint256 surveyId) public view returns (SurveyState) {
        require(surveyCount >= surveyId && surveyId > 0, "invalid survey id");

        if (block.number <= surveys[surveyId].endBlock) {
            // Still being voted on.
            return SurveyState.Active;
        } else {
            return SurveyState.Decided;
        }
    }

    // ============ Internal Functions ============

    function _executeTransaction(Call memory call) internal {
        (bool ok, ) = call.target.call{value: uint256(call.value)}(call.data);

        require(ok, "execute transaction failed");
    }

    // Applies the voting reward to the sender.
    function _applyReward() internal {
        IDistributionLogic(distributionModel).increaseAwards(
            msg.sender,
            votingReward
        );
    }
}