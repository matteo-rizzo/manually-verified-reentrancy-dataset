/**
 *Submitted for verification at Etherscan.io on 2021-08-17
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;




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





// File contracts/interface/IENS.sol




// File contracts/distribution/interface/IDistributionStorage.sol





// File contracts/distribution/DistributionStorage.sol



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


// File contracts/lib/upgradable/interface/IBeacon.sol





// File contracts/lib/upgradable/BeaconStorage.sol


contract BeaconStorage {
    /// @notice Holds the address of the upgrade beacon
    address internal immutable beacon;

    constructor(address beacon_) {
        beacon = beacon_;
    }
}


// File contracts/lib/Pausable.sol




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


// File contracts/distribution/DistributionProxy.sol







/**
 * @title DistributionProxy
 * @author MirrorXYZ
 */
contract DistributionProxy is
    BeaconStorage,
    Governable,
    DistributionStorage,
    Pausable
{
    constructor(
        address beacon_,
        address owner_,
        address team_,
        address token_,
        bytes32 rootNode_,
        address ensRegistry_,
        address treasury_
    )
        BeaconStorage(beacon_)
        Governable(owner_)
        DistributionStorage(rootNode_, ensRegistry_)
        Pausable(true)
    {
        // Initialize the logic, supplying initialization calldata.
        team = team_;
        token = token_;
        treasury = treasury_;
    }

    fallback() external payable {
        address logic = IBeacon(beacon).logic();

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), logic, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    receive() external payable {}
}