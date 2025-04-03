// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import {BeaconStorage} from "../lib/upgradable/BeaconStorage.sol";
import {Governable} from "../lib/Governable.sol";
import {IBeacon} from "../lib/upgradable/interface/IBeacon.sol";
import {DistributionStorage} from "./DistributionStorage.sol";
import {IDistributionLogic} from "./interface/IDistributionLogic.sol";
import {IMirrorTokenLogic} from "../governance/token/interface/IMirrorTokenLogic.sol";
import {Pausable} from "../lib/Pausable.sol";

contract DistributionLogic is
    BeaconStorage,
    Governable,
    DistributionStorage,
    Pausable,
    IDistributionLogic
{
    /// @notice Logic version
    uint256 public constant override version = 0;

    // ============ Structs ============

    struct Registrable {
        address member;
        string label;
        uint256 blockNumber;
    }

    // ============ Events ============

    event Registered(address account, string label);

    event Epoch(uint256 startBlock, uint256 claimablePerBlock);

    // ============ Modifiers ============

    modifier onlyTreasury() {
        require(msg.sender == treasury, "only treasury can distribute");
        _;
    }

    modifier onlyRegistered(address account) {
        require(registered[account] != 0, "must be registered to claim");
        _;
    }

    modifier notBanned(address account) {
        require(!banned[account], "account banned");
        _;
    }

    // ============ Configuration ============
    /**
     * @dev The owner will be the owner of the logic contract, not the proxy.
     */
    constructor(
        address beacon,
        address owner_,
        bytes32 rootNode_,
        address ensRegistry_
    )
        BeaconStorage(beacon)
        Governable(owner_)
        DistributionStorage(rootNode_, ensRegistry_)
        Pausable(true)
    {}

    // ============ Configuration ============

    /*
        These should all be `onlyGovernance`
    */

    function changeRegistrationReward(uint256 registrationReward_)
        public
        onlyGovernance
    {
        registrationReward = registrationReward_;
    }

    function changeTreasury(address treasury_) public onlyGovernance {
        treasury = treasury_;
    }

    function changeTeamRatio(uint256 teamRatio_) public onlyGovernance {
        teamRatio = teamRatio_;
    }

    function changeTeam(address team_) public onlyGovernance {
        team = team_;
    }

    function changeContributionFactor(uint256 contributionsFactor_)
        public
        onlyGovernance
    {
        contributionsFactor = contributionsFactor_;
    }

    function createEpoch(DistributionEpoch memory epoch) public onlyGovernance {
        if (numEpochs > 0) {
            DistributionEpoch memory currentEpoch = epochs[numEpochs - 1];
            require(
                epoch.startBlock > currentEpoch.startBlock,
                "epoch startBlock must be ahead of current epoch"
            );
        }

        epochs.push(epoch);
        numEpochs += 1;

        emit Epoch(epoch.startBlock, epoch.claimablePerBlock);
    }

    function ban(address account) public onlyGovernance {
        banned[account] = true;
    }

    function unban(address account) public onlyGovernance {
        banned[account] = false;
    }

    /// @notice pause reward claims
    function pause() public onlyGovernance {
        _pause();
    }

    /// @notice unpause reward claims
    function unpause() public onlyGovernance {
        _unpause();
    }

    function getLogic() public view returns (address proxyLogic) {
        proxyLogic = IBeacon(beacon).logic();
    }

    // ============ Rewards Modifiers ============

    function distribute(address tributary, uint256 contribution)
        public
        override
        onlyTreasury
    {
        contributions[tributary] += contribution;
    }

    // Governance can give a single member an adjusted reward.
    function increaseAwards(address member, uint256 amount)
        public
        override
        onlyGovernance
    {
        awards[member] += amount;
    }

    // ============ Claimable Views ============

    // All members receive gov tokens over time, according to epochs.
    function drip(address member)
        public
        view
        returns (uint256 membershipReward)
    {
        // Add membership drip.
        for (uint256 i; i < numEpochs; i++) {
            membershipReward += _claimablePerEpoch(member, i);
        }
    }

    function claimable(address member) public view override returns (uint256) {
        return
            drip(member) +
            awards[member] +
            (contributions[member] * contributionsFactor) -
            claimed[member];
    }

    // ============ Claim Execution ============

    function claim(address account)
        public
        override
        whenNotPaused
        notBanned(account)
        onlyRegistered(account)
    {
        uint256 payout = claimable(account);
        claimed[account] += payout;

        // Mint the payout, don't allocate.
        // Also mint the team some tokens,
        uint256 teamTokens = (teamRatio * payout) / (100 - teamRatio);

        _mint(team, teamTokens);
        _mint(account, payout);

        lastClaimed[account] = block.number;
    }

    function migrate(address from, address to) public notBanned(from) {
        require(msg.sender == from && msg.sender != to, "cannot migrate");

        // migrate registration
        registered[to] = registered[from];
        registered[from] = 0;

        // migrate contributions
        contributions[to] = contributions[from];
        contributions[from] = 0;

        // migrate claimed amount
        claimed[to] = claimed[from];
        claimed[from] = 0;

        // migrate last claimed
        lastClaimed[to] = lastClaimed[from];
        lastClaimed[from] = 0;

        // migrate awards
        awards[to] = awards[from];
        awards[from] = 0;
    }

    // ============ Registration ============

    /*
        Members must register to start receiving the drip,
        and to receive the registration reward.
     */

    function register(address member, string calldata label) public {
        _registerMember(member, label, block.number);
    }

    // Allows governance to back-date registration timestamp.
    function setRegistration(Registrable calldata registration)
        public
        onlyGovernance
    {
        _registerMember(
            registration.member,
            registration.label,
            registration.blockNumber
        );
    }

    // Allows governance to set registration for multiple members.
    function setBulkRegistration(Registrable[] calldata registrations)
        public
        onlyGovernance
    {
        for (uint256 i = 0; i < registrations.length; i++) {
            _registerMember(
                registrations[i].member,
                registrations[i].label,
                registrations[i].blockNumber
            );
        }
    }

    // ============ Utility Functions ============

    function isMirrorDAO(address member, string calldata label)
        public
        view
        returns (bool mirrorDAO)
    {
        bytes32 labelNode = keccak256(abi.encodePacked(label));
        bytes32 node = keccak256(abi.encodePacked(rootNode, labelNode));
        mirrorDAO = member == ensRegistry.owner(node);
    }

    // ============ Internal Functions ============

    function _mint(address to, uint256 amount) internal {
        IMirrorTokenLogic(token).mint(to, amount);
    }

    function _registerMember(
        address member,
        string calldata label,
        uint256 blockNumber
    ) internal {
        require(isMirrorDAO(member, label), "must be a MirrorDAO to register");
        require(registered[member] == 0, "member already registered");

        registered[member] = blockNumber;
        awards[member] += registrationReward;
        registeredMembers += 1;
        emit Registered(member, label);
    }

    function _claimablePerEpoch(address member, uint256 epochIndex)
        internal
        view
        returns (uint256)
    {
        DistributionEpoch memory epoch = epochs[epochIndex];

        uint256 startBlock = max(registered[member], epoch.startBlock);

        uint256 endBlock;
        if (numEpochs > epochIndex + 1) {
            endBlock = epochs[epochIndex + 1].startBlock;
        } else {
            endBlock = block.number;
        }

        if (
            registered[member] > 0 &&
            registered[member] < endBlock &&
            lastClaimed[member] < endBlock
        ) {
            return epoch.claimablePerBlock * (endBlock - startBlock);
        }

        return 0;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a >= b) {
            return a;
        } else {
            return b;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

contract BeaconStorage {
    /// @notice Holds the address of the upgrade beacon
    address internal immutable beacon;

    constructor(address beacon_) {
        beacon = beacon_;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import {Ownable} from "../lib/Ownable.sol";
import {IGovernable} from "../lib/interface/IGovernable.sol";

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

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;



// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import {IENS} from "../interface/IENS.sol";
import {IDistributionStorage} from "./interface/IDistributionStorage.sol";

/**
 * @title DistributionStorage
 * @author MirrorXYZ
 */
contract DistributionStorage is IDistributionStorage {
    // ============ Immutable Storage ============

    // The node of the root name (e.g. namehash(mirror.xyz))
    bytes32 public immutable rootNode;
    /**
     * The address of the public ENS registry.
     * @dev Dependency-injectable for testing purposes, but otherwise this is the
     * canonical ENS registry at 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e.
     */
    IENS public immutable ensRegistry;

    // ============ Mutable Storage ============

    // The address for Mirror team and investors.
    address team;
    // The address of the governance token that this contract is allowed to mint.
    address token;
    // The address that is allowed to distribute.
    address treasury;
    // The amount that has been contributed to the treasury.
    mapping(address => uint256) public contributions;
    mapping(address => uint256) public awards;
    // The number of rewards that are created per 1 ETH contribution to the treasury.
    uint256 contributionsFactor = 1000;
    // The amount that has been claimed per address.
    mapping(address => uint256) public claimed;
    // The block number that an address last claimed
    mapping(address => uint256) public lastClaimed;
    // The block number that an address registered
    mapping(address => uint256) public override registered;
    // Banned accounts
    mapping(address => bool) public banned;
    // The percentage of tokens issued that are taken by the Mirror team.
    uint256 teamRatio = 40;
    uint256 public registrationReward = 100 * 1e18;
    uint256 public registeredMembers;

    struct DistributionEpoch {
        uint256 startBlock;
        uint256 claimablePerBlock;
    }

    DistributionEpoch[] public epochs;
    uint256 numEpochs = 0;

    constructor(bytes32 rootNode_, address ensRegistry_) {
        rootNode = rootNode_;
        ensRegistry = IENS(ensRegistry_);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;



// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;
import {IGovernable} from "../../../lib/interface/IGovernable.sol";

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

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;



contract Pausable is IPausable {
    bool public override paused;

    // Modifiers

    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Pausable: not paused");
        _;
    }

    /// @notice Initializes the contract in unpaused state.
    constructor(bool paused_) {
        paused = paused_;
    }

    // ============ Internal Functions ============

    function _pause() internal whenNotPaused {
        paused = true;

        emit Paused(msg.sender);
    }

    function _unpause() internal whenPaused {
        paused = false;

        emit Unpaused(msg.sender);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;



// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;



//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;



// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;



{
  "optimizer": {
    "enabled": true,
    "runs": 2000
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}