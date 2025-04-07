/**
 *Submitted for verification at Etherscan.io on 2021-04-27
*/

// File: contracts\lib\IERC20.sol

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.3;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts\interface\INestMining.sol

/// @dev This interface defines the mining methods for nest


// File: contracts\interface\INestVote.sol

/// @dev This interface defines the methods for voting


// File: contracts\interface\IVotePropose.sol

/// @dev Interface to be implemented for voting contract


// File: contracts\interface\INestMapping.sol

/// @dev The interface defines methods for nest builtin contract address mapping


// File: contracts\interface\INestGovernance.sol

/// @dev This interface defines the governance methods
interface INestGovernance is INestMapping {

    /// @dev Set governance authority
    /// @param addr Destination address
    /// @param flag Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    /// @dev Get governance rights
    /// @param addr Destination address
    /// @return Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    /// @dev Check whether the target address has governance rights for the given target
    /// @param addr Destination address
    /// @param flag Permission weight. The permission of the target address must be greater than this weight to pass the check
    /// @return True indicates permission
    function checkGovernance(address addr, uint flag) external view returns (bool);
}

// File: contracts\interface\IProxyAdmin.sol

/// @dev This interface defines the ProxyAdmin methods


// File: contracts\lib\TransferHelper.sol

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false


// File: contracts\interface\INestLedger.sol

/// @dev This interface defines the nest ledger methods


// File: contracts\NestBase.sol

/// @dev Base contract of nest
contract NestBase {

    // Address of nest token contract
    address constant NEST_TOKEN_ADDRESS = 0x04abEdA201850aC0124161F037Efd70c74ddC74C;

    // Genesis block number of nest
    // NEST token contract is created at block height 6913517. However, because the mining algorithm of nest1.0
    // is different from that at present, a new mining algorithm is adopted from nest2.0. The new algorithm
    // includes the attenuation logic according to the block. Therefore, it is necessary to trace the block
    // where the nest begins to decay. According to the circulation when nest2.0 is online, the new mining
    // algorithm is used to deduce and convert the nest, and the new algorithm is used to mine the nest2.0
    // on-line flow, the actual block is 5120000
    uint constant NEST_GENESIS_BLOCK = 5120000;

    /// @dev To support open-zeppelin/upgrades
    /// @param nestGovernanceAddress INestGovernance implementation contract address
    function initialize(address nestGovernanceAddress) virtual public {
        require(_governance == address(0), 'NEST:!initialize');
        _governance = nestGovernanceAddress;
    }

    /// @dev INestGovernance implementation contract address
    address public _governance;

    /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
    ///      super.update(nestGovernanceAddress) when overriding, and override method without onlyGovernance
    /// @param nestGovernanceAddress INestGovernance implementation contract address
    function update(address nestGovernanceAddress) virtual public {

        address governance = _governance;
        require(governance == msg.sender || INestGovernance(governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _governance = nestGovernanceAddress;
    }

    /// @dev Migrate funds from current contract to NestLedger
    /// @param tokenAddress Destination token address.(0 means eth)
    /// @param value Migrate amount
    function migrate(address tokenAddress, uint value) external onlyGovernance {

        address to = INestGovernance(_governance).getNestLedgerAddress();
        if (tokenAddress == address(0)) {
            INestLedger(to).addETHReward { value: value } (address(0));
        } else {
            TransferHelper.safeTransfer(tokenAddress, to, value);
        }
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(INestGovernance(_governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _;
    }

    modifier noContract() {
        require(msg.sender == tx.origin, "NEST:!contract");
        _;
    }
}

// File: contracts\NestVote.sol

/// @dev nest voting contract, implemented the voting logic
contract NestVote is NestBase, INestVote {
    
    // constructor() { }

    /// @dev Structure is used to represent a storage location. Storage variable can be used to avoid indexing from mapping many times
    struct UINT {
        uint value;
    }

    /// @dev Proposal information
    struct Proposal {

        // The immutable field and the variable field are stored separately
        /* ========== Immutable field ========== */

        // Brief of this proposal
        string brief;

        // The contract address which will be executed when the proposal is approved. (Must implemented IVotePropose)
        address contractAddress;

        // Voting start time
        uint48 startTime;

        // Voting stop time
        uint48 stopTime;

        // Proposer
        address proposer;

        // Staked nest amount
        uint96 staked;

        /* ========== Mutable field ========== */

        // Gained value
        // The maximum value of uint96 can be expressed as 79228162514264337593543950335, which is more than the total 
        // number of nest 10000000000 ether. Therefore, uint96 can be used to express the total number of votes
        uint96 gainValue;

        // The state of this proposal. 0: proposed | 1: accepted | 2: cancelled
        uint32 state;

        // The executor of this proposal
        address executor;

        // The execution time (if any, such as block number or time stamp) is placed in the contract and is limited by the contract itself
    }
    
    // Configuration
    Config _config;

    // Array for proposals
    Proposal[] public _proposalList;

    // Staked ledger
    mapping(uint =>mapping(address =>UINT)) public _stakedLedger;
    
    address _nestLedgerAddress;
    //address _nestTokenAddress;
    address _nestMiningAddress;
    address _nnIncomeAddress;

    uint32 constant PROPOSAL_STATE_PROPOSED = 0;
    uint32 constant PROPOSAL_STATE_ACCEPTED = 1;
    uint32 constant PROPOSAL_STATE_CANCELLED = 2;

    uint constant NEST_TOTAL_SUPPLY = 10000000000 ether;

    /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
    ///      super.update(nestGovernanceAddress) when overriding, and override method without onlyGovernance
    /// @param nestGovernanceAddress INestGovernance implementation contract address
    function update(address nestGovernanceAddress) override public {
        super.update(nestGovernanceAddress);

        (
            //address nestTokenAddress
            ,//_nestTokenAddress, 
            //address nestNodeAddress
            ,
            //address nestLedgerAddress
            _nestLedgerAddress, 
            //address nestMiningAddress
            _nestMiningAddress, 
            //address ntokenMiningAddress
            ,
            //address nestPriceFacadeAddress
            ,
            //address nestVoteAddress
            ,
            //address nestQueryAddress
            ,
            //address nnIncomeAddress
            _nnIncomeAddress, 
            //address nTokenControllerAddress
              
        ) = INestGovernance(nestGovernanceAddress).getBuiltinAddress();
    }

    /// @dev Modify configuration
    /// @param config Configuration object
    function setConfig(Config memory config) override external onlyGovernance {
        require(uint(config.acceptance) <= 10000, "NestVote:!value");
        _config = config;
    }

    /// @dev Get configuration
    /// @return Configuration object
    function getConfig() override external view returns (Config memory) {
        return _config;
    }

    /* ========== VOTE ========== */
    
    /// @dev Initiate a voting proposal
    /// @param contractAddress The contract address which will be executed when the proposal is approved. (Must implemented IVotePropose)
    /// @param brief Brief of this propose
    function propose(address contractAddress, string memory brief) override external noContract
    {
        // The target address cannot already have governance permission to prevent the governance permission from being covered
        require(!INestGovernance(_governance).checkGovernance(contractAddress, 0), "NestVote:!governance");
     
        Config memory config = _config;
        uint index = _proposalList.length;

        // Create voting structure
        _proposalList.push(Proposal(
        
            // Brief of this propose
            //string brief;
            brief,

            // The contract address which will be executed when the proposal is approved. (Must implemented IVotePropose)
            //address contractAddress;
            contractAddress,

            // Voting start time
            //uint48 startTime;
            uint48(block.timestamp),

            // Voting stop time
            //uint48 stopTime;
            uint48(block.timestamp + uint(config.voteDuration)),

            // Proposer
            //address proposer;
            msg.sender,

            config.proposalStaking,

            uint96(0), 
            
            PROPOSAL_STATE_PROPOSED, 

            address(0)
        ));

        // Stake nest
        IERC20(NEST_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), uint(config.proposalStaking));

        emit NIPSubmitted(msg.sender, contractAddress, index);
    }

    /// @dev vote
    /// @param index Index of proposal
    /// @param value Amount of nest to vote
    function vote(uint index, uint value) override external noContract
    {
        // 1. Load the proposal
        Proposal memory p = _proposalList[index];

        // 2. Check
        // Check time region
        // Note: stop time is not include stopTime
        require(block.timestamp >= uint(p.startTime) && block.timestamp < uint(p.stopTime), "NestVote:!time");
        require(p.state == PROPOSAL_STATE_PROPOSED, "NestVote:!state");

        // 3. Update voting ledger
        UINT storage balance = _stakedLedger[index][msg.sender];
        balance.value += value;

        // 4. Update voting information
        _proposalList[index].gainValue = uint96(uint(p.gainValue) + value);

        // 5. Stake nest
        IERC20(NEST_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), value);

        emit NIPVote(msg.sender, index, value);
    }

    /// @dev Withdraw the nest of the vote. If the target vote is in the voting state, the corresponding number of votes will be cancelled
    /// @param index Index of the proposal
    function withdraw(uint index) override external noContract
    {
        // 1. Update voting ledger
        UINT storage balance = _stakedLedger[index][msg.sender];
        uint balanceValue = balance.value;
        balance.value = 0;

        // 2. In the proposal state, the number of votes obtained needs to be updated
        if (_proposalList[index].state == PROPOSAL_STATE_PROPOSED) {
            _proposalList[index].gainValue = uint96(uint(_proposalList[index].gainValue) - balanceValue);
        }

        // 3. Return staked nest
        IERC20(NEST_TOKEN_ADDRESS).transfer(msg.sender, balanceValue);
    }

    /// @dev Execute the proposal
    /// @param index Index of the proposal
    function execute(uint index) override external noContract
    {
        Config memory config = _config;

        // 1. Load proposal
        Proposal memory p = _proposalList[index];

        // 2. Check status
        require(p.state == PROPOSAL_STATE_PROPOSED, "NestVote:!state");
        require(block.timestamp < uint(p.stopTime), "NestVote:!time");
        // The target address cannot already have governance permission to prevent the governance permission from being covered
        address governance = _governance;
        require(!INestGovernance(governance).checkGovernance(p.contractAddress, 0), "NestVote:!governance");

        // 3. Check the gaine rate
        IERC20 nest = IERC20(NEST_TOKEN_ADDRESS);

        // Calculate the circulation of nest
        uint nestCirculation = _getNestCirculation(nest);
        require(uint(p.gainValue) * 10000 >= nestCirculation * uint(config.acceptance), "NestVote:!gainValue");

        // 3. Temporarily grant execution permission
        INestGovernance(governance).setGovernance(p.contractAddress, 1);

        // 4. Execute
        _proposalList[index].state = PROPOSAL_STATE_ACCEPTED;
        _proposalList[index].executor = msg.sender;
        IVotePropose(p.contractAddress).run();

        // 5. Delete execution permission
        INestGovernance(governance).setGovernance(p.contractAddress, 0);
        
        // Return nest
        nest.transfer(p.proposer, uint(p.staked));

        emit NIPExecute(msg.sender, index);
    }

    /// @dev Cancel the proposal
    /// @param index Index of the proposal
    function cancel(uint index) override external noContract {

        // 1. Load proposal
        Proposal memory p = _proposalList[index];

        // 2. Check state
        require(p.state == PROPOSAL_STATE_PROPOSED, "NestVote:!state");
        require(block.timestamp >= uint(p.stopTime), "NestVote:!time");

        // 3. Update status
        _proposalList[index].state = PROPOSAL_STATE_CANCELLED;

        // 4. Return staked nest
        IERC20(NEST_TOKEN_ADDRESS).transfer(p.proposer, uint(p.staked));
    }

    // Convert PriceSheet to PriceSheetView
    //function _toPriceSheetView(PriceSheet memory sheet, uint index) private view returns (PriceSheetView memory) {
    function _toProposalView(Proposal memory proposal, uint index, uint nestCirculation) private pure returns (ProposalView memory) {

        return ProposalView(
            // Index of the proposal
            index,
            // Brief of proposal
            //string brief;
            proposal.brief,
            // The contract address which will be executed when the proposal is approved. (Must implemented IVotePropose)
            //address contractAddress;
            proposal.contractAddress,
            // Voting start time
            //uint48 startTime;
            proposal.startTime,
            // Voting stop time
            //uint48 stopTime;
            proposal.stopTime,
            // Proposer
            //address proposer;
            proposal.proposer,
            // Staked nest amount
            //uint96 staked;
            proposal.staked,
            // Gained value
            // The maximum value of uint96 can be expressed as 79228162514264337593543950335, which is more than the total 
            // number of nest 10000000000 ether. Therefore, uint96 can be used to express the total number of votes
            //uint96 gainValue;
            proposal.gainValue,
            // The state of this proposal
            //uint32 state;  // 0: proposed | 1: accepted | 2: cancelled
            proposal.state,
            // The executor of this proposal
            //address executor;
            proposal.executor,

            // Circulation of nest
            uint96(nestCirculation)
        );
    }

    /// @dev Get proposal information
    /// @param index Index of the proposal
    /// @return Proposal information
    function getProposeInfo(uint index) override external view returns (ProposalView memory) {
        return _toProposalView(_proposalList[index], index, getNestCirculation());
    }

    /// @dev Get the cumulative number of voting proposals
    /// @return The cumulative number of voting proposals
    function getProposeCount() override external view returns (uint) {
        return _proposalList.length;
    }

    /// @dev List proposals by page
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return List of price proposals
    function list(uint offset, uint count, uint order) override external view returns (ProposalView[] memory) {
        
        Proposal[] storage proposalList = _proposalList;
        ProposalView[] memory result = new ProposalView[](count);
        uint nestCirculation = getNestCirculation();
        uint length = proposalList.length;
        uint i = 0;

        // Reverse order
        if (order == 0) {

            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                --index;
                result[i++] = _toProposalView(proposalList[index], index, nestCirculation);
            }
        } 
        // Positive sequence
        else {
            
            uint index = offset;
            uint end = index + count;
            if (end > length) {
                end = length;
            }
            while (index < end) {
                result[i++] = _toProposalView(proposalList[index], index, nestCirculation);
                ++index;
            }
        }

        return result;
    }

    // Get Circulation of nest
    function _getNestCirculation(IERC20 nest) private view returns (uint) {

        return NEST_TOTAL_SUPPLY 
            - nest.balanceOf(_nestMiningAddress)
            - nest.balanceOf(_nnIncomeAddress)
            - nest.balanceOf(_nestLedgerAddress)
            - nest.balanceOf(address(0x1));
    }

    /// @dev Get Circulation of nest
    /// @return Circulation of nest
    function getNestCirculation() override public view returns (uint) {
        return _getNestCirculation(IERC20(NEST_TOKEN_ADDRESS));
    }

    /// @dev Upgrades a proxy to the newest implementation of a contract
    /// @param proxyAdmin The address of ProxyAdmin
    /// @param proxy Proxy to be upgraded
    /// @param implementation the address of the Implementation
    function upgradeProxy(address proxyAdmin, address proxy, address implementation) override external onlyGovernance {
        IProxyAdmin(proxyAdmin).upgrade(proxy, implementation);
    }

    /// @dev Transfers ownership of the contract to a new account (`newOwner`)
    ///      Can only be called by the current owner
    /// @param proxyAdmin The address of ProxyAdmin
    /// @param newOwner The address of new owner
    function transferUpgradeAuthority(address proxyAdmin, address newOwner) override external onlyGovernance {
        IProxyAdmin(proxyAdmin).transferOwnership(newOwner);
    }
}