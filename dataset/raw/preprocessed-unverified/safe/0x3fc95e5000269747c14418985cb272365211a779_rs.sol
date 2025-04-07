/**
 *Submitted for verification at Etherscan.io on 2020-12-07
*/

pragma solidity = 0.7.0;






interface Minter is ERC20 {
    event Mint(address indexed to, uint256 value, uint indexed period, uint userEthLocked, uint totalEthLocked);

    function governanceRouter() external view returns (GovernanceRouter);
    function mint(address to, uint period, uint128 userEthLocked, uint totalEthLocked) external returns (uint amount);
    function userTokensToClaim(address user) external view returns (uint amount);
    function periodTokens(uint period) external pure returns (uint128);
    function periodDecayK() external pure returns (uint decayK);
    function initialPeriodTokens() external pure returns (uint128);
}



interface WETH is ERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}





interface LiquidityPool is ERC20 {
    enum MintReason { DEPOSIT, PROTOCOL_FEE, INITIAL_LIQUIDITY }
    event Mint(address indexed to, uint256 value, MintReason reason);

    // ORDER_CLOSED reasons are all odd, other reasons are even
    // it allows to check ORDER_CLOSED reasons as (reason & ORDER_CLOSED) != 0
    enum BreakReason { 
        NONE,        ORDER_CLOSED, 
        ORDER_ADDED, ORDER_CLOSED_BY_STOP_LOSS, 
        SWAP,        ORDER_CLOSED_BY_REQUEST,
        MINT,        ORDER_CLOSED_BY_HISTORY_LIMIT,
        BURN,        ORDER_CLOSED_BY_GOVERNOR
    }

    function poolBalances() external view returns (
        uint balanceALocked,
        uint poolFlowSpeedA, // flow speed: (amountAIn * 2^32)/second

        uint balanceBLocked,
        uint poolFlowSpeedB, // flow speed: (amountBIn * 2^32)/second

        uint totalBalanceA,
        uint totalBalanceB,

        uint delayedSwapsIncome,
        uint rootKLastTotalSupply
    );

    function governanceRouter() external returns (GovernanceRouter);
    function minimumLiquidity() external returns (uint);
    function aIsWETH() external returns (bool);

    function mint(address to) external returns (uint liquidityOut);
    function burn(address to, bool extractETH) external returns (uint amountAOut, uint amountBOut);
    function swap(address to, bool extractETH, uint amountAOut, uint amountBOut, bytes calldata externalData) external returns (uint amountAIn, uint amountBIn);

    function tokenA() external view returns (ERC20);
    function tokenB() external view returns (ERC20);
}

interface DelayedExchangePool is LiquidityPool {
    event FlowBreakEvent( 
        address sender, 
        // total balance contains 128 bit of totalBalanceA and 128 bit of totalBalanceB
        uint totalBalance, 
        // contains 128 bits of rootKLast and 128 bits of totalSupply
        uint rootKLastTotalSupply, 
        uint indexed orderId,
        // breakHash is computed over all fields below
        
        bytes32 lastBreakHash,
        // availableBalance consists of 128 bits of availableBalanceA and 128 bits of availableBalanceB
        uint availableBalance, 
        // flowSpeed consists of 144 bits of poolFlowSpeedA and 112 higher bits of poolFlowSpeedB
        uint flowSpeed,
        // others consists of 32 lower bits of poolFlowSpeedB, 16 bit of notFee, 64 bit of time, 64 bit of orderId, 76 higher bits of packed and 4 bit of reason (BreakReason)
        uint others      
    );

    event OrderClaimedEvent(uint indexed orderId, address to);
    event OperatingInInvalidState(uint location, uint invalidStateReason);
    event GovernanceApplied(uint packedGovernance);
    
    function addOrder(
        address owner, uint orderFlags, uint prevByStopLoss, uint prevByTimeout, 
        uint stopLossAmount, uint period
    ) external returns (uint id);

    // availableBalance contains 128 bits of availableBalanceA and 128 bits of availableBalanceB
    // delayedSwapsIncome contains 128 bits of delayedSwapsIncomeA and 128 bits of delayedSwapsIncomeB
    function processDelayedOrders() external returns (uint availableBalance, uint delayedSwapsIncome, uint packed);

    function claimOrder (
        bytes32 previousBreakHash,
        // see LiquifyPoolRegister.claimOrder for breaks list details
        uint[] calldata breaksHistory
    ) external returns (address owner, uint amountAOut, uint amountBOut);

    function applyGovernance(uint packedGovernanceFields) external;
    function sync() external;
    function closeOrder(uint id) external;

    function poolQueue() external view returns (
        uint firstByTokenAStopLoss, uint lastByTokenAStopLoss, // linked list of orders sorted by (amountAIn/stopLossAmount) ascending
        uint firstByTokenBStopLoss, uint lastByTokenBStopLoss, // linked list of orders sorted by (amountBIn/stopLossAmount) ascending
    
        uint firstByTimeout, uint lastByTimeout // linked list of orders sorted by timeouts ascending
    );

    function lastBreakHash() external view returns (bytes32);

    function poolState() external view returns (
        bytes32 _prevBlockBreakHash,
        uint packed, // see Liquifi.PoolState for details
        uint notFee,

        uint lastBalanceUpdateTime,
        uint nextBreakTime,
        uint maxHistory,
        uint ordersToClaimCount,
        uint breaksCount
    );

    function findOrder(uint orderId) external view returns (        
        uint nextByTimeout, uint prevByTimeout,
        uint nextByStopLoss, uint prevByStopLoss,
        
        uint stopLossAmount,
        uint amountIn,
        uint period,
        
        address owner,
        uint timeout,
        uint flags
    );
}





contract LiquifiProposal {
    using Math for uint256;
    event ProposalVoted(address user, Vote vote, uint influence);

    ERC20 public immutable govToken;
    LiquifiInitialGovernor public immutable governor;

    enum Vote {
        NONE, YES, NO, ABSTAIN, NO_WITH_VETO
    }

    mapping(address => Vote) public voted;
    // 0 - hasn't voted
    // 1 - voted yes
    // 2 - voted no
    // 3 - voted abstain
    // 4 - voted noWithVeto

    string public description;
    uint public approvalsInfluence = 0;
    uint public againstInfluence = 0;
    uint public abstainInfluence = 0;
    uint public noWithVetoInfluence = 0;
    
    LiquifiDAO.ProposalStatus public result;
    
    uint public immutable started; //time when proposal was created
    uint public immutable totalInfluence;
    
    uint public immutable option;
    uint public immutable newValue;
    uint public immutable quorum;
    uint public immutable vetoPercentage;
    uint public immutable votingPeriod;
    uint public immutable threshold;
    address public immutable addr;
    address public immutable addr2;

    constructor(string memory _description, 
            uint _totalInfluence, 
            address _govToken, 
            uint _option, uint _newValue, 
            uint _quorum, uint _threshold, uint _vetoPercentage, uint _votingPeriod, 
            address _address, address _address2) {
        description = _description;
        started = block.timestamp;
        totalInfluence = _totalInfluence; 
        governor = LiquifiInitialGovernor(msg.sender);
        govToken = ERC20(_govToken);

        option = _option;
        newValue = _newValue;

        quorum = _quorum;
        threshold = _threshold;
        vetoPercentage = _vetoPercentage;
        votingPeriod = _votingPeriod;
        addr = _address;
        addr2 = _address2;
    }

    function vote(Vote _vote) public {
        address user = msg.sender;
        uint influence = govToken.balanceOf(user);
        (uint deposited,) = governor.deposits(user);
        influence = influence.add(deposited);
        vote(_vote, influence);
    }


    function vote(Vote _vote, uint influence) public {
        address user = msg.sender;
        require(voted[user] == Vote.NONE, "You have already voted!");

        voted[user] = _vote; // prevent reentrance

        require(influence > 0, "Proposal.vote: No governance tokens in wallet");
        governor.proposalVote(user, influence, endTime());

        if (checkIfEnded() != LiquifiDAO.ProposalStatus.IN_PROGRESS)
            return;
            
        if (_vote == Vote.YES) {
            approvalsInfluence += influence;
        } else if (_vote == Vote.NO) {
            againstInfluence += influence;
        } else if (_vote == Vote.ABSTAIN) {
            abstainInfluence += influence;
        } else if (_vote == Vote.NO_WITH_VETO) {
            noWithVetoInfluence += influence;
            againstInfluence += influence;
        }
        emit ProposalVoted(user, _vote, influence);
    }

    function endTime() public view returns (uint) {
        return started + 1 hours * votingPeriod;
    }

    function checkIfEnded() public returns (LiquifiDAO.ProposalStatus) {
        require(result == LiquifiDAO.ProposalStatus.IN_PROGRESS, "voting completed");
        
        if (block.timestamp > endTime()) {
            return finalize();
        } else {
            return LiquifiDAO.ProposalStatus.IN_PROGRESS;
        }
    }

    function finalize() public returns (LiquifiDAO.ProposalStatus) {
        require(block.timestamp > endTime(), "Proposal: Period hasn't passed");

        if ((totalInfluence != 0) 
            && (100 * (approvalsInfluence + againstInfluence + abstainInfluence) / totalInfluence < quorum )){
            result = LiquifiDAO.ProposalStatus.DECLINED;
            governor.proposalFinalization(result, 0, 0, address(0), address(0));
            return result;        
        }

        if ((approvalsInfluence + againstInfluence + abstainInfluence) != 0 &&
            (100 * noWithVetoInfluence / (approvalsInfluence + againstInfluence + abstainInfluence) >= vetoPercentage)) {
            result = LiquifiDAO.ProposalStatus.VETO;
            governor.proposalFinalization(result, 0, 0, address(0), address(0));
        }
        else if ((approvalsInfluence + againstInfluence) != 0 &&
            (100 * approvalsInfluence / (approvalsInfluence + againstInfluence) > threshold)) {
            result = LiquifiDAO.ProposalStatus.APPROVED;
            governor.proposalFinalization(result, option, newValue, addr, addr2);
        }
        else {
            result = LiquifiDAO.ProposalStatus.DECLINED;
            governor.proposalFinalization(result, 0, 0, address(0), address(0));
        }

        return result;
    }
}

// SPDX-License-Identifier: GPL-3.0
//import { Debug } from "./libraries/Debug.sol";
contract LiquifiInitialGovernor {
    using Math for uint256;

    event EmergencyLock(address sender, address pool);
    event ProposalCreated(address proposal);
    event ProposalFinalized(address proposal, LiquifiDAO.ProposalStatus proposalStatus);
    event DepositWithdrawn(address user, uint amount);

    struct CreatedProposals{
        uint amountDeposited;
        LiquifiDAO.ProposalStatus status;
        address creator;
    }

    struct Deposit {
        uint amount;
        uint unfreezeTime;
    }
    
    LiquifiProposal[] public deployedProposals;
    mapping(address => CreatedProposals) proposalInfo;
    mapping(/* user */address => Deposit) public deposits;
    address[] public userDepositsList;

    uint public immutable tokensRequiredToCreateProposal; 
    uint public constant quorum = 10; //percenrage
    uint public constant threshold = 50;
    uint public constant vetoPercentage = 33;
    uint public immutable votingPeriod; //hours

    ERC20 private immutable govToken;
    GovernanceRouter public immutable governanceRouter;

    constructor(address _governanceRouterAddress, uint _tokensRequiredToCreateProposal, uint _votingPeriod) {
        tokensRequiredToCreateProposal = _tokensRequiredToCreateProposal;
        votingPeriod = _votingPeriod;
        govToken = GovernanceRouter(_governanceRouterAddress).minter();
        governanceRouter = GovernanceRouter(_governanceRouterAddress);
        (address oldGovernor,) = GovernanceRouter(_governanceRouterAddress).governance();
        if (oldGovernor == address(0)) {
            GovernanceRouter(_governanceRouterAddress).setGovernor(address(this));
        }
    }

    function deposit(address user, uint amount, uint unfreezeTime) private {
        uint deposited = deposits[user].amount;
        if (deposited < amount) {
            uint remainingAmount = amount.subWithClip(deposited);
            require(govToken.transferFrom(user, address(this), remainingAmount), "LIQUIFI_GV: TRANSFER FAILED");
            deposits[user].amount = amount;
        }
        deposits[user].unfreezeTime = Math.max(deposits[user].unfreezeTime, unfreezeTime);
        userDepositsList.push(user);
    } 

    function withdraw() public {
        require(_withdraw(msg.sender, block.timestamp) > 0, "LIQUIFI_GV: WITHDRAW FAILED");
    }

    function _withdraw(address user, uint maxTime) private returns (uint) {
        uint amount = deposits[user].amount;
        if (amount == 0 || deposits[user].unfreezeTime >= maxTime) {
            return 0;
        }
        
        deposits[user].amount = 0;
        require(govToken.transfer(user, amount), "LIQUIFI_GV: TRANSFER FAILED");
        emit DepositWithdrawn(user, amount);
        return amount;
    }

    function withdrawAll() public {
        withdrawMultiple(0, userDepositsList.length);
    }

    function withdrawMultiple(uint fromIndex, uint toIndex) public {
        uint maxWithdrawTime = block.timestamp;
        (address currentGovernor,) = governanceRouter.governance();

        if (currentGovernor != address(this)) {
            maxWithdrawTime = type(uint).max;
        }
        
        for(uint userIndex = fromIndex; userIndex < toIndex; userIndex++) {
            _withdraw(userDepositsList[userIndex], maxWithdrawTime);
        }
    }

    function createProposal(string memory _proposal, uint _option, uint _newValue, address _address, address _address2) public {
        address creator = msg.sender;
        LiquifiProposal newProposal = new LiquifiProposal(_proposal, govToken.totalSupply(), address(govToken), _option, _newValue, quorum, threshold, vetoPercentage, votingPeriod, _address, _address2);
        
        uint tokensRequired = deposits[creator].amount.add(tokensRequiredToCreateProposal);
        deposit(creator, tokensRequired, newProposal.endTime());

        deployedProposals.push(newProposal);

        proposalInfo[address(newProposal)].amountDeposited = tokensRequiredToCreateProposal;
        proposalInfo[address(newProposal)].creator = creator;
        emit ProposalCreated(address(newProposal));
    }

    function emergencyLock(address pool) public returns (bool locked) {
        uint gasBefore = gasleft();
        try DelayedExchangePool(pool).processDelayedOrders() {
            return false;
        } catch (bytes memory /*lowLevelData*/) {
            uint gasAfter = gasleft();
            require((gasBefore - gasAfter) * 10 / gasBefore >= 1, "LIQUIFI: LOW GAS");
            lockPool(pool);
            if (knownPool(pool)) {
                emit EmergencyLock(msg.sender, pool);
            }
            return true;
        }
    }

    function getDeployedProposals() public view returns (LiquifiProposal[] memory) {
        return deployedProposals;
    }

    function proposalVote(address user, uint influence, uint unfreezeTime) public {
        address proposal = msg.sender;
        require(proposalInfo[proposal].amountDeposited > 0, "LIQUIFI_GV: BAD SENDER");
        require(proposalInfo[proposal].status == LiquifiDAO.ProposalStatus.IN_PROGRESS, "LIQUIFI_GV: PROPOSAL FINALIZED");

        deposit(user, influence, unfreezeTime);
    }

    function proposalFinalization(LiquifiDAO.ProposalStatus _proposalStatus, uint _option, uint /* _value */, address _address, address /* _address2 */) public {
        address proposal = msg.sender;
        require(proposalInfo[proposal].amountDeposited > 0, "LIQUIFI_GV: BAD SENDER");
        require(proposalInfo[proposal].status == LiquifiDAO.ProposalStatus.IN_PROGRESS, "LIQUIFI_GV: PROPOSAL FINALIZED");
        
        if (_proposalStatus == LiquifiDAO.ProposalStatus.APPROVED) {
            if (_option == 1) { 
                changeGovernor(_address); 
            }
        }

        proposalInfo[proposal].status = _proposalStatus;   
        emit ProposalFinalized(proposal, _proposalStatus);   
    }

    function changeGovernor(address _newGovernor) private {
        governanceRouter.setGovernor(_newGovernor);
    }

    function lockPool(address pool) internal {
        (,uint governancePacked,,,,,,) = DelayedExchangePool(pool).poolState();

        governancePacked = governancePacked | (1 << uint(Liquifi.Flag.POOL_LOCKED));
        governancePacked = governancePacked | (1 << uint(Liquifi.Flag.GOVERNANCE_OVERRIDEN));
        DelayedExchangePool(pool).applyGovernance(governancePacked);
    }

    function knownPool(address pool) private returns (bool) {
        address tokenA = address(DelayedExchangePool(pool).tokenA());
        address tokenB = address(DelayedExchangePool(pool).tokenB());
        return governanceRouter.poolFactory().findPool(tokenA, tokenB) == pool;
    }
}