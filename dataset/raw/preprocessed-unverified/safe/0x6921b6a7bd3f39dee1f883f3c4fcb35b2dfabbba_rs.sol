/**
 *Submitted for verification at Etherscan.io on 2020-11-09
*/

// Keep4r Jobs V1 Beta ðŸš€
// This fork of keep3r decouples the coin from the protocol, 
// disables governance bypassing, and has configurable bonding times.
// 
// More information @ 
// - https://docs.kp4r.network/Jobs.html
// Find a list of featured jobs @
// - https://kp4r.network/#/jobs

pragma solidity ^0.6.6;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol
// Subject to the MIT license.


contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}











contract KeeperV1Jobs is ReentrancyGuard {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    /// @notice Keep3r Helper to set max prices for the ecosystem
    IKeep3rV1Helper public KPRH;

    IERC20 public kp4r;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint chainId,address verifyingContract)");
    bytes32 public immutable DOMAINSEPARATOR;

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint nonce,uint expiry)");

    /// @notice The EIP-712 typehash for the permit struct used by the contract
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint value,uint nonce,uint deadline)");

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    /// @notice Submit a job
    event SubmitJob(address indexed job, address indexed liquidity, address indexed provider, uint block, uint credit);

    /// @notice Apply credit to a job
    event ApplyCredit(address indexed job, address indexed liquidity, address indexed provider, uint block, uint credit);

    /// @notice Remove credit for a job
    event RemoveJob(address indexed job, address indexed liquidity, address indexed provider, uint block, uint credit);

    /// @notice Unbond credit for a job
    event UnbondJob(address indexed job, address indexed liquidity, address indexed provider, uint block, uint credit);

    /// @notice Added a Job
    event JobAdded(address indexed job, uint block, address governance);

    /// @notice Removed a job
    event JobRemoved(address indexed job, uint block, address governance);

    /// @notice Worked a job
    event KeeperWorked(address indexed credit, address indexed job, address indexed keeper, uint block);

    /// @notice Keeper bonding
    event KeeperBonding(address indexed keeper, uint block, uint active, uint bond);

    /// @notice Keeper bonded
    event KeeperBonded(address indexed keeper, uint block, uint activated, uint bond);

    /// @notice Keeper unbonding
    event KeeperUnbonding(address indexed keeper, uint block, uint deactive, uint bond);

    /// @notice Keeper unbound
    event KeeperUnbound(address indexed keeper, uint block, uint deactivated, uint bond);

    /// @notice Keeper slashed
    event KeeperSlashed(address indexed keeper, address indexed slasher, uint block, uint slash);

    /// @notice Keeper disputed
    event KeeperDispute(address indexed keeper, uint block);

    /// @notice Keeper resolved
    event KeeperResolved(address indexed keeper, uint block);

    event AddCredit(address indexed credit, address indexed job, address indexed creditor, uint block, uint amount);

    /// @notice 1 day to bond to become a keeper
    uint public BOND = 1 days;
    /// @notice 14 days to unbond to remove funds from being a keeper
    uint public UNBOND = 14 days;

    /// @notice direct liquidity fee 0.3%
    uint public FEE = 30;
    uint public BASE = 10000;

    /// @notice address used for ETH transfers
    address constant public ETH = address(0xE);

    /// @notice tracks all current bondings (time)
    mapping(address => mapping(address => uint)) public bondings;
    /// @notice tracks all current unbondings (time)
    mapping(address => mapping(address => uint)) public unbondings;
    /// @notice allows for partial unbonding
    mapping(address => mapping(address => uint)) public partialUnbonding;
    /// @notice tracks all current pending bonds (amount)
    mapping(address => mapping(address => uint)) public pendingbonds;
    /// @notice tracks how much a keeper has bonded
    mapping(address => mapping(address => uint)) public bonds;
    /// @notice tracks underlying votes (that don't have bond)
    mapping(address => uint) public votes;

    /// @notice total bonded (totalSupply for bonds)
    uint public totalBonded = 0;
    /// @notice tracks when a keeper was first registered
    mapping(address => uint) public firstSeen;

    /// @notice tracks if a keeper has a pending dispute
    mapping(address => bool) public disputes;

    /// @notice tracks last job performed for a keeper
    mapping(address => uint) public lastJob;
    /// @notice tracks the total job executions for a keeper
    mapping(address => uint) public workCompleted;
    /// @notice list of all jobs registered for the keeper system
    mapping(address => bool) public jobs;
    /// @notice the current credit available for a job
    mapping(address => mapping(address => uint)) public credits;

    /// @notice the balances for the liquidity providers
    mapping(address => mapping(address => mapping(address => uint))) public liquidityProvided;
    /// @notice liquidity unbonding days
    mapping(address => mapping(address => mapping(address => uint))) public liquidityUnbonding;
    /// @notice liquidity unbonding amounts
    mapping(address => mapping(address => mapping(address => uint))) public liquidityAmountsUnbonding;
    /// @notice job proposal delay
    mapping(address => uint) public jobProposalDelay;
    /// @notice liquidity apply date
    mapping(address => mapping(address => mapping(address => uint))) public liquidityApplied;
    /// @notice liquidity amount to apply
    mapping(address => mapping(address => mapping(address => uint))) public liquidityAmount;

    /// @notice list of all current keepers
    mapping(address => bool) public keepers;
    /// @notice blacklist of keepers not allowed to participate
    mapping(address => bool) public blacklist;

    /// @notice traversable array of keepers to make external management easier
    address[] public keeperList;
    /// @notice traversable array of jobs to make external management easier
    address[] public jobList;

    /// @notice governance address for the governance contract
    address public governance;
    address public pendingGovernance;

    /// @notice the liquidity token supplied by users paying for jobs
    mapping(address => bool) public liquidityAccepted;

    address[] public liquidityPairs;

    uint internal _gasUsed;

    constructor(address _kp4r) public {
        // Set governance for this token
        kp4r = IERC20(_kp4r);
        governance = msg.sender;
        DOMAINSEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes("Keep4r")), _getChainId(), address(this)));
    }

    /**
     * @notice Add ETH credit to a job to be paid out for work
     * @param job the job being credited
     */
    function addCreditETH(address job) external payable {
        require(jobs[job], "addCreditETH: !job");
        uint _fee = msg.value.mul(FEE).div(BASE);
        credits[job][ETH] = credits[job][ETH].add(msg.value.sub(_fee));
        payable(governance).transfer(_fee);

        emit AddCredit(ETH, job, msg.sender, block.number, msg.value);
    }

    /**
     * @notice Add credit to a job to be paid out for work
     * @param credit the credit being assigned to the job
     * @param job the job being credited
     * @param amount the amount of credit being added to the job
     */
    function addCredit(address credit, address job, uint amount) external nonReentrant {
        require(jobs[job], "addCreditETH: !job");

        uint _before = IERC20(credit).balanceOf(address(this));
        IERC20(credit).safeTransferFrom(msg.sender, address(this), amount);
        uint _received = IERC20(credit).balanceOf(address(this)).sub(_before);
        uint _fee = _received.mul(FEE).div(BASE);
        credits[job][credit] = credits[job][credit].add(_received.sub(_fee));
        IERC20(credit).safeTransfer(governance, _fee);

        emit AddCredit(credit, job, msg.sender, block.number, _received);
    }

    /**
     * @notice Displays all accepted liquidity pairs
     */
    function pairs() external view returns (address[] memory) {
        return liquidityPairs;
    }

    /**
     * @notice Implemented by jobs to show that a keeper performed work
     * @param keeper address of the keeper that performed the work
     */
    function worked(address keeper) external {
        workReceipt(keeper, KPRH.getQuoteLimit(_gasUsed.sub(gasleft())));
    }

    /**
     * @notice Implemented by jobs to show that a keeper performed work
     * @param keeper address of the keeper that performed the work
     * @param amount the reward that should be allocated
     */
    function workReceipt(address keeper, uint amount) public {
        require(jobs[msg.sender], "workReceipt: !job");
        require(amount <= KPRH.getQuoteLimit(_gasUsed.sub(gasleft())), "workReceipt: max limit");
        credits[msg.sender][address(this)] = credits[msg.sender][address(this)].sub(amount, "workReceipt: insuffient funds");
        lastJob[keeper] = now;
        _bond(address(this), keeper, amount);
        workCompleted[keeper] = workCompleted[keeper].add(amount);
        emit KeeperWorked(address(this), msg.sender, keeper, block.number);
    }

    /**
     * @notice Implemented by jobs to show that a keeper performed work
     * @param credit the asset being awarded to the keeper
     * @param keeper address of the keeper that performed the work
     * @param amount the reward that should be allocated
     */
    function receipt(address credit, address keeper, uint amount) external {
        require(jobs[msg.sender], "receipt: !job");
        credits[msg.sender][credit] = credits[msg.sender][credit].sub(amount, "workReceipt: insuffient funds");
        lastJob[keeper] = now;
        IERC20(credit).safeTransfer(keeper, amount);
        emit KeeperWorked(credit, msg.sender, keeper, block.number);
    }

    /**
     * @notice Implemented by jobs to show that a keeper performed work
     * @param keeper address of the keeper that performed the work
     * @param amount the amount of ETH sent to the keeper
     */
    function receiptETH(address keeper, uint amount) external {
        require(jobs[msg.sender], "receipt: !job");
        credits[msg.sender][ETH] = credits[msg.sender][ETH].sub(amount, "workReceipt: insuffient funds");
        lastJob[keeper] = now;
        payable(keeper).transfer(amount);
        emit KeeperWorked(ETH, msg.sender, keeper, block.number);
    }

    function _bond(address bonding, address _from, uint _amount) internal {
        bonds[_from][bonding] = bonds[_from][bonding].add(_amount);
        if (bonding == address(this)) {
            totalBonded = totalBonded.add(_amount);
            // _moveDelegates(address(0), delegates[_from], _amount);
        }
    }

    function _unbond(address bonding, address _from, uint _amount) internal {
        bonds[_from][bonding] = bonds[_from][bonding].sub(_amount);
        if (bonding == address(this)) {
            totalBonded = totalBonded.sub(_amount);
            // _moveDelegates(delegates[_from], address(0), _amount);
        }

    }

    /**
     * @notice Allows governance to add new job systems
     * @param job address of the contract for which work should be performed
     */
    function addJob(address job) external {
        require(msg.sender == governance, "addJob: !gov");
        require(!jobs[job], "addJob: job known");
        jobs[job] = true;
        jobList.push(job);
        emit JobAdded(job, block.number, msg.sender);
    }

    /**
     * @notice Full listing of all jobs ever added
     * @return array blob
     */
    function getJobs() external view returns (address[] memory) {
        return jobList;
    }

    /**
     * @notice Allows governance to remove a job from the systems
     * @param job address of the contract for which work should be performed
     */
    function removeJob(address job) external {
        require(msg.sender == governance, "removeJob: !gov");
        jobs[job] = false;
        emit JobRemoved(job, block.number, msg.sender);
    }

    /**
     * @notice Allows governance to change the Keep3rHelper for max spend
     * @param _kprh new helper address to set
     */
    function setKeep3rHelper(address _kprh) external {
        require(msg.sender == governance, "setKeep3rHelper: !gov");
       
        KPRH = IKeep3rV1Helper(_kprh);
    }

    /**
     * @notice Allows governance to change governance (for future upgradability)
     * @param _governance new governance address to set
     */
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "setGovernance: !gov");
        pendingGovernance = _governance;
    }

    /**
     * @notice Allows pendingGovernance to accept their role as governance (protection pattern)
     */
    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "acceptGovernance: !pendingGov");
        governance = pendingGovernance;
    }

    /**
     * @notice confirms if the current keeper is registered, can be used for general (non critical) functions
     * @param keeper the keeper being investigated
     * @return true/false if the address is a keeper
     */
    function isKeeper(address keeper) external returns (bool) {
        _gasUsed = gasleft();
        return keepers[keeper];
    }

    /**
     * @notice confirms if the current keeper is registered and has a minimum bond, should be used for protected functions
     * @param keeper the keeper being investigated
     * @param minBond the minimum requirement for the asset provided in bond
     * @param earned the total funds earned in the keepers lifetime
     * @param age the age of the keeper in the system
     * @return true/false if the address is a keeper and has more than the bond
     */
    function isMinKeeper(address keeper, uint minBond, uint earned, uint age) external returns (bool) {
        _gasUsed = gasleft();
        return keepers[keeper]
                && bonds[keeper][address(this)].add(votes[keeper]) >= minBond
                && workCompleted[keeper] >= earned
                && now.sub(firstSeen[keeper]) >= age;
    }

    /**
     * @notice confirms if the current keeper is registered and has a minimum bond, should be used for protected functions
     * @param keeper the keeper being investigated
     * @param bond the bound asset being evaluated
     * @param minBond the minimum requirement for the asset provided in bond
     * @param earned the total funds earned in the keepers lifetime
     * @param age the age of the keeper in the system
     * @return true/false if the address is a keeper and has more than the bond
     */
    function isBondedKeeper(address keeper, address bond, uint minBond, uint earned, uint age) external returns (bool) {
        _gasUsed = gasleft();
        return keepers[keeper]
                && bonds[keeper][bond] >= minBond
                && workCompleted[keeper] >= earned
                && now.sub(firstSeen[keeper]) >= age;
    }

    /**
     * @notice begin the bonding process for a new keeper
     * @param bonding the asset being bound
     * @param amount the amount of bonding asset being bound
     */
    function bond(address bonding, uint amount) external nonReentrant {
        require(!blacklist[msg.sender], "bond: blacklisted");
        require(bonding != address(this), "cannot bond this");
        bondings[msg.sender][bonding] = now.add(BOND);
       
        uint _before = IERC20(bonding).balanceOf(address(this));
        IERC20(bonding).safeTransferFrom(msg.sender, address(this), amount);
        amount = IERC20(bonding).balanceOf(address(this)).sub(_before);
        
        pendingbonds[msg.sender][bonding] = pendingbonds[msg.sender][bonding].add(amount);
        emit KeeperBonding(msg.sender, block.number, bondings[msg.sender][bonding], amount);
    }

    /**
     * @notice get full list of keepers in the system
     */
    function getKeepers() external view returns (address[] memory) {
        return keeperList;
    }

    /**
     * @notice allows a keeper to activate/register themselves after bonding
     * @param bonding the asset being activated as bond collateral
     */
    function activate(address bonding) external {
        require(!blacklist[msg.sender], "activate: blacklisted");
        require(bondings[msg.sender][bonding] != 0 && bondings[msg.sender][bonding] < now, "connect yet activate bonding");
        if (firstSeen[msg.sender] == 0) {
          firstSeen[msg.sender] = now;
          keeperList.push(msg.sender);
          lastJob[msg.sender] = now;
        }
        keepers[msg.sender] = true;
        _bond(bonding, msg.sender, pendingbonds[msg.sender][bonding]);
        pendingbonds[msg.sender][bonding] = 0;
        emit KeeperBonded(msg.sender, block.number, block.timestamp, bonds[msg.sender][bonding]);
    }

    /**
     * @notice begin the unbonding process to stop being a keeper
     * @param bonding the asset being unbound
     * @param amount allows for partial unbonding
     */
    function unbond(address bonding, uint amount) external {
        unbondings[msg.sender][bonding] = now.add(UNBOND);
        _unbond(bonding, msg.sender, amount);
        partialUnbonding[msg.sender][bonding] = partialUnbonding[msg.sender][bonding].add(amount);
        emit KeeperUnbonding(msg.sender, block.number, unbondings[msg.sender][bonding], amount);
    }

    /**
     * @notice withdraw funds after unbonding has finished
     * @param bonding the asset to withdraw from the bonding pool
     */
    function withdraw(address bonding) external nonReentrant {
        require(unbondings[msg.sender][bonding] != 0 && unbondings[msg.sender][bonding] < now, "withdraw: unbonding");
        require(!disputes[msg.sender], "withdraw: disputes");

        IERC20(bonding).safeTransfer(msg.sender, partialUnbonding[msg.sender][bonding]);
        emit KeeperUnbound(msg.sender, block.number, block.timestamp, partialUnbonding[msg.sender][bonding]);
        partialUnbonding[msg.sender][bonding] = 0;
    }

    /**
     * @notice allows governance to create a dispute for a given keeper
     * @param keeper the address in dispute
     */
    function dispute(address keeper) external {
        require(msg.sender == governance, "dispute: !gov");
        disputes[keeper] = true;
        emit KeeperDispute(keeper, block.number);
    }

    /**
     * @notice allows governance to slash a keeper based on a dispute
     * @param bonded the asset being slashed
     * @param keeper the address being slashed
     * @param amount the amount being slashed
     */
    function slash(address bonded, address keeper, uint amount) public nonReentrant {
        require(msg.sender == governance, "slash: !gov");
        IERC20(bonded).safeTransfer(governance, amount);
        _unbond(bonded, keeper, amount);
        disputes[keeper] = false;
        emit KeeperSlashed(keeper, msg.sender, block.number, amount);
    }

    /**
     * @notice blacklists a keeper from participating in the network
     * @param keeper the address being slashed
     */
    function revoke(address keeper) external {
        require(msg.sender == governance, "slash: !gov");
        keepers[keeper] = false;
        blacklist[keeper] = true;
        slash(address(this), keeper, bonds[keeper][address(this)]);
    }

    /**
     * @notice allows governance to resolve a dispute on a keeper
     * @param keeper the address cleared
     */
    function resolve(address keeper) external {
        require(msg.sender == governance, "resolve: !gov");
        disputes[keeper] = false;
        emit KeeperResolved(keeper, block.number);
    }
    
    function setBondingTimes(uint256 _BOND, uint256 _UNBOND) public {
         require(msg.sender == governance, "setBondingTimes: !gov");
         require(_UNBOND < 21 days, "unbond time too long");
         UNBOND = _UNBOND;
         BOND = _BOND;
    }
    
    function setFees(uint256 _FEE) public {
        require(msg.sender == governance, "setFee: !gov");
        require(_FEE < 500, "fee to big");
        FEE = _FEE;
    }



    function _getChainId() internal pure returns (uint) {
        uint chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}