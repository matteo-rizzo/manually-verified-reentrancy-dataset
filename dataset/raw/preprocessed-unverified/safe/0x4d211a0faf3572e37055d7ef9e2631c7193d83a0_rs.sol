/**
 *Submitted for verification at Etherscan.io on 2021-06-10
*/

pragma solidity ^0.5.17;


// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/lib/math/SafeMath.sol
// Adapted to use pragma ^0.5.17 and satisfy our linter rules
/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */


// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/lib/math/SafeMath64.sol
// Adapted to use pragma ^0.5.17 and satisfy our linter rules
/**
 * @title SafeMath64
 * @dev Math operations for uint64 with safety checks that revert on error
 */




/*
 * SPDX-License-Identifier:    MIT
 */
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _who) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
}

// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/SafeERC20.sol
// Adapted to use pragma ^0.5.17 and satisfy our linter rules


// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/Uint256Helpers.sol
// Adapted to use pragma ^0.5.17 and satisfy our linter rules


// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/TimeHelpers.sol
// Adapted to use pragma ^0.5.17 and satisfy our linter rules
contract TimeHelpers {
    using Uint256Helpers for uint256;

    /**
    * @dev Returns the current block number.
    *      Using a function rather than `block.number` allows us to easily mock the block number in
    *      tests.
    */
    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }

    /**
    * @dev Returns the current block number, converted to uint64.
    *      Using a function rather than `block.number` allows us to easily mock the block number in
    *      tests.
    */
    function getBlockNumber64() internal view returns (uint64) {
        return getBlockNumber().toUint64();
    }

    /**
    * @dev Returns the current timestamp.
    *      Using a function rather than `block.timestamp` allows us to easily mock it in
    *      tests.
    */
    function getTimestamp() internal view returns (uint256) {
        return block.timestamp; // solium-disable-line security/no-block-members
    }

    /**
    * @dev Returns the current timestamp, converted to uint64.
    *      Using a function rather than `block.timestamp` allows us to easily mock it in
    *      tests.
    */
    function getTimestamp64() internal view returns (uint64) {
        return getTimestamp().toUint64();
    }
}

/*
 * SPDX-License-Identifier:    MIT
 */


/*
 * SPDX-License-Identifier:    MIT
 */


// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/IsContract.sol
// Adapted to use pragma ^0.5.17 and satisfy our linter rules
contract IsContract {
    /*
    * NOTE: this should NEVER be used for authentication
    * (see pitfalls: https://github.com/fergarrui/ethereum-security/tree/master/contracts/extcodesize).
    *
    * This is only intended to be used as a sanity check that an address is actually a contract,
    * RATHER THAN an address not being a contract.
    */
    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }
}

contract ACL {
    string private constant ERROR_BAD_FREEZE = "ACL_BAD_FREEZE";
    string private constant ERROR_ROLE_ALREADY_FROZEN = "ACL_ROLE_ALREADY_FROZEN";
    string private constant ERROR_INVALID_BULK_INPUT = "ACL_INVALID_BULK_INPUT";

    enum BulkOp { Grant, Revoke, Freeze }

    address internal constant FREEZE_FLAG = address(1);
    address internal constant ANY_ADDR = address(-1);

    // List of all roles assigned to different addresses
    mapping (bytes32 => mapping (address => bool)) public roles;

    event Granted(bytes32 indexed id, address indexed who);
    event Revoked(bytes32 indexed id, address indexed who);
    event Frozen(bytes32 indexed id);

    /**
    * @dev Tell whether an address has a role assigned
    * @param _who Address being queried
    * @param _id ID of the role being checked
    * @return True if the requested address has assigned the given role, false otherwise
    */
    function hasRole(address _who, bytes32 _id) public view returns (bool) {
        return roles[_id][_who] || roles[_id][ANY_ADDR];
    }

    /**
    * @dev Tell whether a role is frozen
    * @param _id ID of the role being checked
    * @return True if the given role is frozen, false otherwise
    */
    function isRoleFrozen(bytes32 _id) public view returns (bool) {
        return roles[_id][FREEZE_FLAG];
    }

    /**
    * @dev Internal function to grant a role to a given address
    * @param _id ID of the role to be granted
    * @param _who Address to grant the role to
    */
    function _grant(bytes32 _id, address _who) internal {
        require(!isRoleFrozen(_id), ERROR_ROLE_ALREADY_FROZEN);
        require(_who != FREEZE_FLAG, ERROR_BAD_FREEZE);

        if (!hasRole(_who, _id)) {
            roles[_id][_who] = true;
            emit Granted(_id, _who);
        }
    }

    /**
    * @dev Internal function to revoke a role from a given address
    * @param _id ID of the role to be revoked
    * @param _who Address to revoke the role from
    */
    function _revoke(bytes32 _id, address _who) internal {
        require(!isRoleFrozen(_id), ERROR_ROLE_ALREADY_FROZEN);

        if (hasRole(_who, _id)) {
            roles[_id][_who] = false;
            emit Revoked(_id, _who);
        }
    }

    /**
    * @dev Internal function to freeze a role
    * @param _id ID of the role to be frozen
    */
    function _freeze(bytes32 _id) internal {
        require(!isRoleFrozen(_id), ERROR_ROLE_ALREADY_FROZEN);
        roles[_id][FREEZE_FLAG] = true;
        emit Frozen(_id);
    }

    /**
    * @dev Internal function to enact a bulk list of ACL operations
    */
    function _bulk(BulkOp[] memory _op, bytes32[] memory _id, address[] memory _who) internal {
        require(_op.length == _id.length && _op.length == _who.length, ERROR_INVALID_BULK_INPUT);

        for (uint256 i = 0; i < _op.length; i++) {
            BulkOp op = _op[i];
            if (op == BulkOp.Grant) {
                _grant(_id[i], _who[i]);
            } else if (op == BulkOp.Revoke) {
                _revoke(_id[i], _who[i]);
            } else if (op == BulkOp.Freeze) {
                _freeze(_id[i]);
            }
        }
    }
}

contract ModuleIds {
    // DisputeManager module ID - keccak256(abi.encodePacked("DISPUTE_MANAGER"))
    bytes32 internal constant MODULE_ID_DISPUTE_MANAGER = 0x14a6c70f0f6d449c014c7bbc9e68e31e79e8474fb03b7194df83109a2d888ae6;

    // GuardiansRegistry module ID - keccak256(abi.encodePacked("GUARDIANS_REGISTRY"))
    bytes32 internal constant MODULE_ID_GUARDIANS_REGISTRY = 0x8af7b7118de65da3b974a3fd4b0c702b66442f74b9dff6eaed1037254c0b79fe;

    // Voting module ID - keccak256(abi.encodePacked("VOTING"))
    bytes32 internal constant MODULE_ID_VOTING = 0x7cbb12e82a6d63ff16fe43977f43e3e2b247ecd4e62c0e340da8800a48c67346;

    // PaymentsBook module ID - keccak256(abi.encodePacked("PAYMENTS_BOOK"))
    bytes32 internal constant MODULE_ID_PAYMENTS_BOOK = 0xfa275b1417437a2a2ea8e91e9fe73c28eaf0a28532a250541da5ac0d1892b418;

    // Treasury module ID - keccak256(abi.encodePacked("TREASURY"))
    bytes32 internal constant MODULE_ID_TREASURY = 0x06aa03964db1f7257357ef09714a5f0ca3633723df419e97015e0c7a3e83edb7;
}





contract CourtClock is IClock, TimeHelpers {
    using SafeMath64 for uint64;

    string private constant ERROR_TERM_DOES_NOT_EXIST = "CLK_TERM_DOES_NOT_EXIST";
    string private constant ERROR_TERM_DURATION_TOO_LONG = "CLK_TERM_DURATION_TOO_LONG";
    string private constant ERROR_TERM_RANDOMNESS_NOT_YET = "CLK_TERM_RANDOMNESS_NOT_YET";
    string private constant ERROR_TERM_RANDOMNESS_UNAVAILABLE = "CLK_TERM_RANDOMNESS_UNAVAILABLE";
    string private constant ERROR_BAD_FIRST_TERM_START_TIME = "CLK_BAD_FIRST_TERM_START_TIME";
    string private constant ERROR_TOO_MANY_TRANSITIONS = "CLK_TOO_MANY_TRANSITIONS";
    string private constant ERROR_INVALID_TRANSITION_TERMS = "CLK_INVALID_TRANSITION_TERMS";
    string private constant ERROR_CANNOT_DELAY_STARTED_COURT = "CLK_CANNOT_DELAY_STARTED_PROT";
    string private constant ERROR_CANNOT_DELAY_PAST_START_TIME = "CLK_CANNOT_DELAY_PAST_START_TIME";

    // Maximum number of term transitions a callee may have to assume in order to call certain functions that require the Court being up-to-date
    uint64 internal constant MAX_AUTO_TERM_TRANSITIONS_ALLOWED = 1;

    // Max duration in seconds that a term can last
    uint64 internal constant MAX_TERM_DURATION = 365 days;

    // Max time until first term starts since contract is deployed
    uint64 internal constant MAX_FIRST_TERM_DELAY_PERIOD = 2 * MAX_TERM_DURATION;

    struct Term {
        uint64 startTime;              // Timestamp when the term started
        uint64 randomnessBN;           // Block number for entropy
        bytes32 randomness;            // Entropy from randomnessBN block hash
    }

    // Duration in seconds for each term of the Court
    uint64 private termDuration;

    // Last ensured term id
    uint64 private termId;

    // List of Court terms indexed by id
    mapping (uint64 => Term) private terms;

    event Heartbeat(uint64 previousTermId, uint64 currentTermId);
    event StartTimeDelayed(uint64 previousStartTime, uint64 currentStartTime);

    /**
    * @dev Ensure a certain term has already been processed
    * @param _termId Identification number of the term to be checked
    */
    modifier termExists(uint64 _termId) {
        require(_termId <= termId, ERROR_TERM_DOES_NOT_EXIST);
        _;
    }

    /**
    * @dev Constructor function
    * @param _termParams Array containing:
    *        0. _termDuration Duration in seconds per term
    *        1. _firstTermStartTime Timestamp in seconds when the court will open (to give time for guardian on-boarding)
    */
    constructor(uint64[2] memory _termParams) public {
        uint64 _termDuration = _termParams[0];
        uint64 _firstTermStartTime = _termParams[1];

        require(_termDuration < MAX_TERM_DURATION, ERROR_TERM_DURATION_TOO_LONG);
        require(_firstTermStartTime >= getTimestamp64() + _termDuration, ERROR_BAD_FIRST_TERM_START_TIME);
        require(_firstTermStartTime <= getTimestamp64() + MAX_FIRST_TERM_DELAY_PERIOD, ERROR_BAD_FIRST_TERM_START_TIME);

        termDuration = _termDuration;

        // No need for SafeMath: we already checked values above
        terms[0].startTime = _firstTermStartTime - _termDuration;
    }

    /**
    * @notice Ensure that the current term of the Court is up-to-date. If the Court is outdated by more than `MAX_AUTO_TERM_TRANSITIONS_ALLOWED`
    *         terms, the heartbeat function must be called manually instead.
    * @return Identification number of the current term
    */
    function ensureCurrentTerm() external returns (uint64) {
        return _ensureCurrentTerm();
    }

    /**
    * @notice Transition up to `_maxRequestedTransitions` terms
    * @param _maxRequestedTransitions Max number of term transitions allowed by the sender
    * @return Identification number of the term ID after executing the heartbeat transitions
    */
    function heartbeat(uint64 _maxRequestedTransitions) external returns (uint64) {
        return _heartbeat(_maxRequestedTransitions);
    }

    /**
    * @notice Ensure that a certain term has its randomness set. As we allow to draft disputes requested for previous terms, if there
    *      were mined more than 256 blocks for the current term, the blockhash of its randomness BN is no longer available, given
    *      round will be able to be drafted in the following term.
    * @return Randomness of the current term
    */
    function ensureCurrentTermRandomness() external returns (bytes32) {
        // If the randomness for the given term was already computed, return
        uint64 currentTermId = termId;
        Term storage term = terms[currentTermId];
        bytes32 termRandomness = term.randomness;
        if (termRandomness != bytes32(0)) {
            return termRandomness;
        }

        // Compute term randomness
        bytes32 newRandomness = _computeTermRandomness(currentTermId);
        require(newRandomness != bytes32(0), ERROR_TERM_RANDOMNESS_UNAVAILABLE);
        term.randomness = newRandomness;
        return newRandomness;
    }

    /**
    * @dev Tell the term duration of the Court
    * @return Duration in seconds of the Court term
    */
    function getTermDuration() external view returns (uint64) {
        return termDuration;
    }

    /**
    * @dev Tell the last ensured term identification number
    * @return Identification number of the last ensured term
    */
    function getLastEnsuredTermId() external view returns (uint64) {
        return _lastEnsuredTermId();
    }

    /**
    * @dev Tell the current term identification number. Note that there may be pending term transitions.
    * @return Identification number of the current term
    */
    function getCurrentTermId() external view returns (uint64) {
        return _currentTermId();
    }

    /**
    * @dev Tell the number of terms the Court should transition to be up-to-date
    * @return Number of terms the Court should transition to be up-to-date
    */
    function getNeededTermTransitions() external view returns (uint64) {
        return _neededTermTransitions();
    }

    /**
    * @dev Tell the information related to a term based on its ID. Note that if the term has not been reached, the
    *      information returned won't be computed yet. This function allows querying future terms that were not computed yet.
    * @param _termId ID of the term being queried
    * @return startTime Term start time
    * @return randomnessBN Block number used for randomness in the requested term
    * @return randomness Randomness computed for the requested term
    */
    function getTerm(uint64 _termId) external view returns (uint64 startTime, uint64 randomnessBN, bytes32 randomness) {
        Term storage term = terms[_termId];
        return (term.startTime, term.randomnessBN, term.randomness);
    }

    /**
    * @dev Tell the randomness of a term even if it wasn't computed yet
    * @param _termId Identification number of the term being queried
    * @return Randomness of the requested term
    */
    function getTermRandomness(uint64 _termId) external view termExists(_termId) returns (bytes32) {
        return _computeTermRandomness(_termId);
    }

    /**
    * @dev Internal function to ensure that the current term of the Court is up-to-date. If the Court is outdated by more than
    *      `MAX_AUTO_TERM_TRANSITIONS_ALLOWED` terms, the heartbeat function must be called manually.
    * @return Identification number of the resultant term ID after executing the corresponding transitions
    */
    function _ensureCurrentTerm() internal returns (uint64) {
        // Check the required number of transitions does not exceeds the max allowed number to be processed automatically
        uint64 requiredTransitions = _neededTermTransitions();
        require(requiredTransitions <= MAX_AUTO_TERM_TRANSITIONS_ALLOWED, ERROR_TOO_MANY_TRANSITIONS);

        // If there are no transitions pending, return the last ensured term id
        if (uint256(requiredTransitions) == 0) {
            return termId;
        }

        // Process transition if there is at least one pending
        return _heartbeat(requiredTransitions);
    }

    /**
    * @dev Internal function to transition the Court terms up to a requested number of terms
    * @param _maxRequestedTransitions Max number of term transitions allowed by the sender
    * @return Identification number of the resultant term ID after executing the requested transitions
    */
    function _heartbeat(uint64 _maxRequestedTransitions) internal returns (uint64) {
        // Transition the minimum number of terms between the amount requested and the amount actually needed
        uint64 neededTransitions = _neededTermTransitions();
        uint256 transitions = uint256(_maxRequestedTransitions < neededTransitions ? _maxRequestedTransitions : neededTransitions);
        require(transitions > 0, ERROR_INVALID_TRANSITION_TERMS);

        uint64 blockNumber = getBlockNumber64();
        uint64 previousTermId = termId;
        uint64 currentTermId = previousTermId;
        for (uint256 transition = 1; transition <= transitions; transition++) {
            // Term IDs are incremented by one based on the number of time periods since the Court started. Since time is represented in uint64,
            // even if we chose the minimum duration possible for a term (1 second), we can ensure terms will never reach 2^64 since time is
            // already assumed to fit in uint64.
            Term storage previousTerm = terms[currentTermId++];
            Term storage currentTerm = terms[currentTermId];
            _onTermTransitioned(currentTermId);

            // Set the start time of the new term. Note that we are using a constant term duration value to guarantee
            // equally long terms, regardless of heartbeats.
            currentTerm.startTime = previousTerm.startTime.add(termDuration);

            // In order to draft a random number of guardians in a term, we use a randomness factor for each term based on a
            // block number that is set once the term has started. Note that this information could not be known beforehand.
            currentTerm.randomnessBN = blockNumber + 1;
        }

        termId = currentTermId;
        emit Heartbeat(previousTermId, currentTermId);
        return currentTermId;
    }

    /**
    * @dev Internal function to delay the first term start time only if it wasn't reached yet
    * @param _newFirstTermStartTime New timestamp in seconds when the court will open
    */
    function _delayStartTime(uint64 _newFirstTermStartTime) internal {
        require(_currentTermId() == 0, ERROR_CANNOT_DELAY_STARTED_COURT);

        Term storage term = terms[0];
        uint64 currentFirstTermStartTime = term.startTime.add(termDuration);
        require(_newFirstTermStartTime > currentFirstTermStartTime, ERROR_CANNOT_DELAY_PAST_START_TIME);

        // No need for SafeMath: we already checked above that `_newFirstTermStartTime` > `currentFirstTermStartTime` >= `termDuration`
        term.startTime = _newFirstTermStartTime - termDuration;
        emit StartTimeDelayed(currentFirstTermStartTime, _newFirstTermStartTime);
    }

    /**
    * @dev Internal function to notify when a term has been transitioned. This function must be overridden to provide custom behavior.
    * @param _termId Identification number of the new current term that has been transitioned
    */
    function _onTermTransitioned(uint64 _termId) internal;

    /**
    * @dev Internal function to tell the last ensured term identification number
    * @return Identification number of the last ensured term
    */
    function _lastEnsuredTermId() internal view returns (uint64) {
        return termId;
    }

    /**
    * @dev Internal function to tell the current term identification number. Note that there may be pending term transitions.
    * @return Identification number of the current term
    */
    function _currentTermId() internal view returns (uint64) {
        return termId.add(_neededTermTransitions());
    }

    /**
    * @dev Internal function to tell the number of terms the Court should transition to be up-to-date
    * @return Number of terms the Court should transition to be up-to-date
    */
    function _neededTermTransitions() internal view returns (uint64) {
        // Note that the Court is always initialized providing a start time for the first-term in the future. If that's the case,
        // no term transitions are required.
        uint64 currentTermStartTime = terms[termId].startTime;
        if (getTimestamp64() < currentTermStartTime) {
            return uint64(0);
        }

        // No need for SafeMath: we already know that the start time of the current term is in the past
        return (getTimestamp64() - currentTermStartTime) / termDuration;
    }

    /**
    * @dev Internal function to compute the randomness that will be used to draft guardians for the given term. This
    *      function assumes the given term exists. To determine the randomness factor for a term we use the hash of a
    *      block number that is set once the term has started to ensure it cannot be known beforehand. Note that the
    *      hash function being used only works for the 256 most recent block numbers.
    * @param _termId Identification number of the term being queried
    * @return Randomness computed for the given term
    */
    function _computeTermRandomness(uint64 _termId) internal view returns (bytes32) {
        Term storage term = terms[_termId];
        require(getBlockNumber64() > term.randomnessBN, ERROR_TERM_RANDOMNESS_NOT_YET);
        return blockhash(term.randomnessBN);
    }
}



contract CourtConfigData {
    struct Config {
        FeesConfig fees;                        // Full fees-related config
        DisputesConfig disputes;                // Full disputes-related config
        uint256 minActiveBalance;               // Minimum amount of tokens guardians have to activate to participate in the Court
    }

    struct FeesConfig {
        IERC20 token;                           // ERC20 token to be used for the fees of the Court
        uint16 finalRoundReduction;             // Permyriad of fees reduction applied for final appeal round (‱ - 1/10,000)
        uint256 guardianFee;                    // Amount of tokens paid to draft a guardian to adjudicate a dispute
        uint256 draftFee;                       // Amount of tokens paid per round to cover the costs of drafting guardians
        uint256 settleFee;                      // Amount of tokens paid per round to cover the costs of slashing guardians
    }

    struct DisputesConfig {
        uint64 evidenceTerms;                   // Max submitting evidence period duration in terms
        uint64 commitTerms;                     // Committing period duration in terms
        uint64 revealTerms;                     // Revealing period duration in terms
        uint64 appealTerms;                     // Appealing period duration in terms
        uint64 appealConfirmTerms;              // Confirmation appeal period duration in terms
        uint16 penaltyPct;                      // Permyriad of min active tokens balance to be locked for each drafted guardian (‱ - 1/10,000)
        uint64 firstRoundGuardiansNumber;       // Number of guardians drafted on first round
        uint64 appealStepFactor;                // Factor in which the guardians number is increased on each appeal
        uint64 finalRoundLockTerms;             // Period a coherent guardian in the final round will remain locked
        uint256 maxRegularAppealRounds;         // Before the final appeal
        uint256 appealCollateralFactor;         // Permyriad multiple of dispute fees required to appeal a preliminary ruling (‱ - 1/10,000)
        uint256 appealConfirmCollateralFactor;  // Permyriad multiple of dispute fees required to confirm appeal (‱ - 1/10,000)
    }

    struct DraftConfig {
        IERC20 feeToken;                         // ERC20 token to be used for the fees of the Court
        uint16 penaltyPct;                      // Permyriad of min active tokens balance to be locked for each drafted guardian (‱ - 1/10,000)
        uint256 draftFee;                       // Amount of tokens paid per round to cover the costs of drafting guardians
    }
}

contract CourtConfig is IConfig, CourtConfigData {
    using SafeMath64 for uint64;
    using PctHelpers for uint256;

    string private constant ERROR_TOO_OLD_TERM = "CONF_TOO_OLD_TERM";
    string private constant ERROR_INVALID_PENALTY_PCT = "CONF_INVALID_PENALTY_PCT";
    string private constant ERROR_INVALID_FINAL_ROUND_REDUCTION_PCT = "CONF_INVALID_FINAL_ROUND_RED_PCT";
    string private constant ERROR_INVALID_MAX_APPEAL_ROUNDS = "CONF_INVALID_MAX_APPEAL_ROUNDS";
    string private constant ERROR_LARGE_ROUND_PHASE_DURATION = "CONF_LARGE_ROUND_PHASE_DURATION";
    string private constant ERROR_BAD_INITIAL_GUARDIANS_NUMBER = "CONF_BAD_INITIAL_GUARDIAN_NUMBER";
    string private constant ERROR_BAD_APPEAL_STEP_FACTOR = "CONF_BAD_APPEAL_STEP_FACTOR";
    string private constant ERROR_ZERO_COLLATERAL_FACTOR = "CONF_ZERO_COLLATERAL_FACTOR";
    string private constant ERROR_ZERO_MIN_ACTIVE_BALANCE = "CONF_ZERO_MIN_ACTIVE_BALANCE";

    // Max number of terms that each of the different adjudication states can last (if lasted 1h, this would be a year)
    uint64 internal constant MAX_ADJ_STATE_DURATION = 8670;

    // Cap the max number of regular appeal rounds
    uint256 internal constant MAX_REGULAR_APPEAL_ROUNDS_LIMIT = 10;

    // Future term ID in which a config change has been scheduled
    uint64 private configChangeTermId;

    // List of all the configs used in the Court
    Config[] private configs;

    // List of configs indexed by id
    mapping (uint64 => uint256) private configIdByTerm;

    event NewConfig(uint64 fromTermId, uint64 courtConfigId);

    /**
    * @dev Constructor function
    * @param _feeToken Address of the token contract that is used to pay for fees
    * @param _fees Array containing:
    *        0. guardianFee Amount of fee tokens that is paid per guardian per dispute
    *        1. draftFee Amount of fee tokens per guardian to cover the drafting cost
    *        2. settleFee Amount of fee tokens per guardian to cover round settlement cost
    * @param _roundStateDurations Array containing the durations in terms of the different phases of a dispute:
    *        0. evidenceTerms Max submitting evidence period duration in terms
    *        1. commitTerms Commit period duration in terms
    *        2. revealTerms Reveal period duration in terms
    *        3. appealTerms Appeal period duration in terms
    *        4. appealConfirmationTerms Appeal confirmation period duration in terms
    * @param _pcts Array containing:
    *        0. penaltyPct Permyriad of min active tokens balance to be locked for each drafted guardian (‱ - 1/10,000)
    *        1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)
    * @param _roundParams Array containing params for rounds:
    *        0. firstRoundGuardiansNumber Number of guardians to be drafted for the first round of disputes
    *        1. appealStepFactor Increasing factor for the number of guardians of each round of a dispute
    *        2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered
    *        3. finalRoundLockTerms Number of terms that a coherent guardian in a final round is disallowed to withdraw (to prevent 51% attacks)
    * @param _appealCollateralParams Array containing params for appeal collateral:
    *        0. appealCollateralFactor Multiple of dispute fees required to appeal a preliminary ruling
    *        1. appealConfirmCollateralFactor Multiple of dispute fees required to confirm appeal
    * @param _minActiveBalance Minimum amount of guardian tokens that can be activated
    */
    constructor(
        IERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance
    )
        public
    {
        // Leave config at index 0 empty for non-scheduled config changes
        configs.length = 1;
        _setConfig(
            0,
            0,
            _feeToken,
            _fees,
            _roundStateDurations,
            _pcts,
            _roundParams,
            _appealCollateralParams,
            _minActiveBalance
        );
    }

    /**
    * @dev Tell the full Court configuration parameters at a certain term
    * @param _termId Identification number of the term querying the Court config of
    * @return token Address of the token used to pay for fees
    * @return fees Array containing:
    *         0. guardianFee Amount of fee tokens that is paid per guardian per dispute
    *         1. draftFee Amount of fee tokens per guardian to cover the drafting cost
    *         2. settleFee Amount of fee tokens per guardian to cover round settlement cost
    * @return roundStateDurations Array containing the durations in terms of the different phases of a dispute:
    *         0. evidenceTerms Max submitting evidence period duration in terms
    *         1. commitTerms Commit period duration in terms
    *         2. revealTerms Reveal period duration in terms
    *         3. appealTerms Appeal period duration in terms
    *         4. appealConfirmationTerms Appeal confirmation period duration in terms
    * @return pcts Array containing:
    *         0. penaltyPct Permyriad of min active tokens balance to be locked for each drafted guardian (‱ - 1/10,000)
    *         1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)
    * @return roundParams Array containing params for rounds:
    *         0. firstRoundGuardiansNumber Number of guardians to be drafted for the first round of disputes
    *         1. appealStepFactor Increasing factor for the number of guardians of each round of a dispute
    *         2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered
    * @return appealCollateralParams Array containing params for appeal collateral:
    *         0. appealCollateralFactor Multiple of dispute fees required to appeal a preliminary ruling
    *         1. appealConfirmCollateralFactor Multiple of dispute fees required to confirm appeal
    * @return minActiveBalance Minimum amount of tokens guardians have to activate to participate in the Court
    */
    function getConfig(uint64 _termId) external view
        returns (
            IERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        );

    /**
    * @dev Tell the draft config at a certain term
    * @param _termId Identification number of the term querying the draft config of
    * @return feeToken Address of the token used to pay for fees
    * @return draftFee Amount of fee tokens per guardian to cover the drafting cost
    * @return penaltyPct Permyriad of min active tokens balance to be locked for each drafted guardian (‱ - 1/10,000)
    */
    function getDraftConfig(uint64 _termId) external view returns (IERC20 feeToken, uint256 draftFee, uint16 penaltyPct);

    /**
    * @dev Tell the min active balance config at a certain term
    * @param _termId Term querying the min active balance config of
    * @return Minimum amount of tokens guardians have to activate to participate in the Court
    */
    function getMinActiveBalance(uint64 _termId) external view returns (uint256);

    /**
    * @dev Tell the term identification number of the next scheduled config change
    * @return Term identification number of the next scheduled config change
    */
    function getConfigChangeTermId() external view returns (uint64) {
        return configChangeTermId;
    }

    /**
    * @dev Internal to make sure to set a config for the new term, it will copy the previous term config if none
    * @param _termId Identification number of the new current term that has been transitioned
    */
    function _ensureTermConfig(uint64 _termId) internal {
        // If the term being transitioned had no config change scheduled, keep the previous one
        uint256 currentConfigId = configIdByTerm[_termId];
        if (currentConfigId == 0) {
            uint256 previousConfigId = configIdByTerm[_termId.sub(1)];
            configIdByTerm[_termId] = previousConfigId;
        }
    }

    /**
    * @dev Assumes that sender it's allowed (either it's from governor or it's on init)
    * @param _termId Identification number of the current Court term
    * @param _fromTermId Identification number of the term in which the config will be effective at
    * @param _feeToken Address of the token contract that is used to pay for fees.
    * @param _fees Array containing:
    *        0. guardianFee Amount of fee tokens that is paid per guardian per dispute
    *        1. draftFee Amount of fee tokens per guardian to cover the drafting cost
    *        2. settleFee Amount of fee tokens per guardian to cover round settlement cost
    * @param _roundStateDurations Array containing the durations in terms of the different phases of a dispute:
    *        0. evidenceTerms Max submitting evidence period duration in terms
    *        1. commitTerms Commit period duration in terms
    *        2. revealTerms Reveal period duration in terms
    *        3. appealTerms Appeal period duration in terms
    *        4. appealConfirmationTerms Appeal confirmation period duration in terms
    * @param _pcts Array containing:
    *        0. penaltyPct Permyriad of min active tokens balance to be locked for each drafted guardian (‱ - 1/10,000)
    *        1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)
    * @param _roundParams Array containing params for rounds:
    *        0. firstRoundGuardiansNumber Number of guardians to be drafted for the first round of disputes
    *        1. appealStepFactor Increasing factor for the number of guardians of each round of a dispute
    *        2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered
    *        3. finalRoundLockTerms Number of terms that a coherent guardian in a final round is disallowed to withdraw (to prevent 51% attacks)
    * @param _appealCollateralParams Array containing params for appeal collateral:
    *        0. appealCollateralFactor Multiple of dispute fees required to appeal a preliminary ruling
    *        1. appealConfirmCollateralFactor Multiple of dispute fees required to confirm appeal
    * @param _minActiveBalance Minimum amount of guardian tokens that can be activated
    */
    function _setConfig(
        uint64 _termId,
        uint64 _fromTermId,
        IERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance
    )
        internal
    {
        // If the current term is not zero, changes must be scheduled at least after the current period.
        // No need to ensure delays for on-going disputes since these already use their creation term for that.
        require(_termId == 0 || _fromTermId > _termId, ERROR_TOO_OLD_TERM);

        // Make sure appeal collateral factors are greater than zero
        require(_appealCollateralParams[0] > 0 && _appealCollateralParams[1] > 0, ERROR_ZERO_COLLATERAL_FACTOR);

        // Make sure the given penalty and final round reduction pcts are not greater than 100%
        require(PctHelpers.isValid(_pcts[0]), ERROR_INVALID_PENALTY_PCT);
        require(PctHelpers.isValid(_pcts[1]), ERROR_INVALID_FINAL_ROUND_REDUCTION_PCT);

        // Disputes must request at least one guardian to be drafted initially
        require(_roundParams[0] > 0, ERROR_BAD_INITIAL_GUARDIANS_NUMBER);

        // Prevent that further rounds have zero guardians
        require(_roundParams[1] > 0, ERROR_BAD_APPEAL_STEP_FACTOR);

        // Make sure the max number of appeals allowed does not reach the limit
        uint256 _maxRegularAppealRounds = _roundParams[2];
        bool isMaxAppealRoundsValid = _maxRegularAppealRounds > 0 && _maxRegularAppealRounds <= MAX_REGULAR_APPEAL_ROUNDS_LIMIT;
        require(isMaxAppealRoundsValid, ERROR_INVALID_MAX_APPEAL_ROUNDS);

        // Make sure each adjudication round phase duration is valid
        for (uint i = 0; i < _roundStateDurations.length; i++) {
            require(_roundStateDurations[i] > 0 && _roundStateDurations[i] < MAX_ADJ_STATE_DURATION, ERROR_LARGE_ROUND_PHASE_DURATION);
        }

        // Make sure min active balance is not zero
        require(_minActiveBalance > 0, ERROR_ZERO_MIN_ACTIVE_BALANCE);

        // If there was a config change already scheduled, reset it (in that case we will overwrite last array item).
        // Otherwise, schedule a new config.
        if (configChangeTermId > _termId) {
            configIdByTerm[configChangeTermId] = 0;
        } else {
            configs.length++;
        }

        uint64 courtConfigId = uint64(configs.length - 1);
        Config storage config = configs[courtConfigId];

        config.fees = FeesConfig({
            token: _feeToken,
            guardianFee: _fees[0],
            draftFee: _fees[1],
            settleFee: _fees[2],
            finalRoundReduction: _pcts[1]
        });

        config.disputes = DisputesConfig({
            evidenceTerms: _roundStateDurations[0],
            commitTerms: _roundStateDurations[1],
            revealTerms: _roundStateDurations[2],
            appealTerms: _roundStateDurations[3],
            appealConfirmTerms: _roundStateDurations[4],
            penaltyPct: _pcts[0],
            firstRoundGuardiansNumber: _roundParams[0],
            appealStepFactor: _roundParams[1],
            maxRegularAppealRounds: _maxRegularAppealRounds,
            finalRoundLockTerms: _roundParams[3],
            appealCollateralFactor: _appealCollateralParams[0],
            appealConfirmCollateralFactor: _appealCollateralParams[1]
        });

        config.minActiveBalance = _minActiveBalance;

        configIdByTerm[_fromTermId] = courtConfigId;
        configChangeTermId = _fromTermId;

        emit NewConfig(_fromTermId, courtConfigId);
    }

    /**
    * @dev Internal function to get the Court config for a given term
    * @param _termId Identification number of the term querying the Court config of
    * @param _lastEnsuredTermId Identification number of the last ensured term of the Court
    * @return token Address of the token used to pay for fees
    * @return fees Array containing:
    *         0. guardianFee Amount of fee tokens that is paid per guardian per dispute
    *         1. draftFee Amount of fee tokens per guardian to cover the drafting cost
    *         2. settleFee Amount of fee tokens per guardian to cover round settlement cost
    * @return roundStateDurations Array containing the durations in terms of the different phases of a dispute:
    *         0. evidenceTerms Max submitting evidence period duration in terms
    *         1. commitTerms Commit period duration in terms
    *         2. revealTerms Reveal period duration in terms
    *         3. appealTerms Appeal period duration in terms
    *         4. appealConfirmationTerms Appeal confirmation period duration in terms
    * @return pcts Array containing:
    *         0. penaltyPct Permyriad of min active tokens balance to be locked for each drafted guardian (‱ - 1/10,000)
    *         1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)
    * @return roundParams Array containing params for rounds:
    *         0. firstRoundGuardiansNumber Number of guardians to be drafted for the first round of disputes
    *         1. appealStepFactor Increasing factor for the number of guardians of each round of a dispute
    *         2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered
    *         3. finalRoundLockTerms Number of terms that a coherent guardian in a final round is disallowed to withdraw (to prevent 51% attacks)
    * @return appealCollateralParams Array containing params for appeal collateral:
    *         0. appealCollateralFactor Multiple of dispute fees required to appeal a preliminary ruling
    *         1. appealConfirmCollateralFactor Multiple of dispute fees required to confirm appeal
    * @return minActiveBalance Minimum amount of guardian tokens that can be activated
    */
    function _getConfigAt(uint64 _termId, uint64 _lastEnsuredTermId) internal view
        returns (
            IERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        )
    {
        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);

        FeesConfig storage feesConfig = config.fees;
        feeToken = feesConfig.token;
        fees = [feesConfig.guardianFee, feesConfig.draftFee, feesConfig.settleFee];

        DisputesConfig storage disputesConfig = config.disputes;
        roundStateDurations = [
            disputesConfig.evidenceTerms,
            disputesConfig.commitTerms,
            disputesConfig.revealTerms,
            disputesConfig.appealTerms,
            disputesConfig.appealConfirmTerms
        ];
        pcts = [disputesConfig.penaltyPct, feesConfig.finalRoundReduction];
        roundParams = [
            disputesConfig.firstRoundGuardiansNumber,
            disputesConfig.appealStepFactor,
            uint64(disputesConfig.maxRegularAppealRounds),
            disputesConfig.finalRoundLockTerms
        ];
        appealCollateralParams = [disputesConfig.appealCollateralFactor, disputesConfig.appealConfirmCollateralFactor];

        minActiveBalance = config.minActiveBalance;
    }

    /**
    * @dev Tell the draft config at a certain term
    * @param _termId Identification number of the term querying the draft config of
    * @param _lastEnsuredTermId Identification number of the last ensured term of the Court
    * @return feeToken Address of the token used to pay for fees
    * @return draftFee Amount of fee tokens per guardian to cover the drafting cost
    * @return penaltyPct Permyriad of min active tokens balance to be locked for each drafted guardian (‱ - 1/10,000)
    */
    function _getDraftConfig(uint64 _termId,  uint64 _lastEnsuredTermId) internal view
        returns (IERC20 feeToken, uint256 draftFee, uint16 penaltyPct)
    {
        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);
        return (config.fees.token, config.fees.draftFee, config.disputes.penaltyPct);
    }

    /**
    * @dev Internal function to get the min active balance config for a given term
    * @param _termId Identification number of the term querying the min active balance config of
    * @param _lastEnsuredTermId Identification number of the last ensured term of the Court
    * @return Minimum amount of guardian tokens that can be activated at the given term
    */
    function _getMinActiveBalance(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (uint256) {
        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);
        return config.minActiveBalance;
    }

    /**
    * @dev Internal function to get the Court config for a given term
    * @param _termId Identification number of the term querying the min active balance config of
    * @param _lastEnsuredTermId Identification number of the last ensured term of the Court
    * @return Court config for the given term
    */
    function _getConfigFor(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (Config storage) {
        uint256 id = _getConfigIdFor(_termId, _lastEnsuredTermId);
        return configs[id];
    }

    /**
    * @dev Internal function to get the Court config ID for a given term
    * @param _termId Identification number of the term querying the Court config of
    * @param _lastEnsuredTermId Identification number of the last ensured term of the Court
    * @return Identification number of the config for the given terms
    */
    function _getConfigIdFor(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (uint256) {
        // If the given term is lower or equal to the last ensured Court term, it is safe to use a past Court config
        if (_termId <= _lastEnsuredTermId) {
            return configIdByTerm[_termId];
        }

        // If the given term is in the future but there is a config change scheduled before it, use the incoming config
        uint64 scheduledChangeTermId = configChangeTermId;
        if (scheduledChangeTermId <= _termId) {
            return configIdByTerm[scheduledChangeTermId];
        }

        // If no changes are scheduled, use the Court config of the last ensured term
        return configIdByTerm[_lastEnsuredTermId];
    }
}

/*
 * SPDX-License-Identifier:    MIT
 */


/*
 * SPDX-License-Identifier:    MIT
 */
/**
* @dev The Arbitrable instances actually don't require to follow any specific interface.
*      Note that this is actually optional, although it does allow the Court to at least have a way to identify a specific set of instances.
*/
contract IArbitrable {
    /**
    * @dev Emitted when an IArbitrable instance's dispute is ruled by an IArbitrator
    * @param arbitrator IArbitrator instance ruling the dispute
    * @param disputeId Identification number of the dispute being ruled by the arbitrator
    * @param ruling Ruling given by the arbitrator
    */
    event Ruled(IArbitrator indexed arbitrator, uint256 indexed disputeId, uint256 ruling);
}



contract Controller is IsContract, ModuleIds, CourtClock, CourtConfig, ACL {
    string private constant ERROR_SENDER_NOT_GOVERNOR = "CTR_SENDER_NOT_GOVERNOR";
    string private constant ERROR_INVALID_GOVERNOR_ADDRESS = "CTR_INVALID_GOVERNOR_ADDRESS";
    string private constant ERROR_MODULE_NOT_SET = "CTR_MODULE_NOT_SET";
    string private constant ERROR_MODULE_ALREADY_ENABLED = "CTR_MODULE_ALREADY_ENABLED";
    string private constant ERROR_MODULE_ALREADY_DISABLED = "CTR_MODULE_ALREADY_DISABLED";
    string private constant ERROR_DISPUTE_MANAGER_NOT_ACTIVE = "CTR_DISPUTE_MANAGER_NOT_ACTIVE";
    string private constant ERROR_CUSTOM_FUNCTION_NOT_SET = "CTR_CUSTOM_FUNCTION_NOT_SET";
    string private constant ERROR_IMPLEMENTATION_NOT_CONTRACT = "CTR_IMPLEMENTATION_NOT_CONTRACT";
    string private constant ERROR_INVALID_IMPLS_INPUT_LENGTH = "CTR_INVALID_IMPLS_INPUT_LENGTH";

    address private constant ZERO_ADDRESS = address(0);

    /**
    * @dev Governor of the whole system. Set of three addresses to recover funds, change configuration settings and setup modules
    */
    struct Governor {
        address funds;      // This address can be unset at any time. It is allowed to recover funds from the ControlledRecoverable modules
        address config;     // This address is meant not to be unset. It is allowed to change the different configurations of the whole system
        address modules;    // This address can be unset at any time. It is allowed to plug/unplug modules from the system
    }

    /**
    * @dev Module information
    */
    struct Module {
        bytes32 id;         // ID associated to a module
        bool disabled;      // Whether the module is disabled
    }

    // Governor addresses of the system
    Governor private governor;

    // List of current modules registered for the system indexed by ID
    mapping (bytes32 => address) internal currentModules;

    // List of all historical modules registered for the system indexed by address
    mapping (address => Module) internal allModules;

    // List of custom function targets indexed by signature
    mapping (bytes4 => address) internal customFunctions;

    event ModuleSet(bytes32 id, address addr);
    event ModuleEnabled(bytes32 id, address addr);
    event ModuleDisabled(bytes32 id, address addr);
    event CustomFunctionSet(bytes4 signature, address target);
    event FundsGovernorChanged(address previousGovernor, address currentGovernor);
    event ConfigGovernorChanged(address previousGovernor, address currentGovernor);
    event ModulesGovernorChanged(address previousGovernor, address currentGovernor);

    /**
    * @dev Ensure the msg.sender is the funds governor
    */
    modifier onlyFundsGovernor {
        require(msg.sender == governor.funds, ERROR_SENDER_NOT_GOVERNOR);
        _;
    }

    /**
    * @dev Ensure the msg.sender is the modules governor
    */
    modifier onlyConfigGovernor {
        require(msg.sender == governor.config, ERROR_SENDER_NOT_GOVERNOR);
        _;
    }

    /**
    * @dev Ensure the msg.sender is the modules governor
    */
    modifier onlyModulesGovernor {
        require(msg.sender == governor.modules, ERROR_SENDER_NOT_GOVERNOR);
        _;
    }

    /**
    * @dev Ensure the given dispute manager is active
    */
    modifier onlyActiveDisputeManager(IDisputeManager _disputeManager) {
        require(!_isModuleDisabled(address(_disputeManager)), ERROR_DISPUTE_MANAGER_NOT_ACTIVE);
        _;
    }

    /**
    * @dev Constructor function
    * @param _termParams Array containing:
    *        0. _termDuration Duration in seconds per term
    *        1. _firstTermStartTime Timestamp in seconds when the court will open (to give time for guardian on-boarding)
    * @param _governors Array containing:
    *        0. _fundsGovernor Address of the funds governor
    *        1. _configGovernor Address of the config governor
    *        2. _modulesGovernor Address of the modules governor
    * @param _feeToken Address of the token contract that is used to pay for fees
    * @param _fees Array containing:
    *        0. guardianFee Amount of fee tokens that is paid per guardian per dispute
    *        1. draftFee Amount of fee tokens per guardian to cover the drafting cost
    *        2. settleFee Amount of fee tokens per guardian to cover round settlement cost
    * @param _roundStateDurations Array containing the durations in terms of the different phases of a dispute:
    *        0. evidenceTerms Max submitting evidence period duration in terms
    *        1. commitTerms Commit period duration in terms
    *        2. revealTerms Reveal period duration in terms
    *        3. appealTerms Appeal period duration in terms
    *        4. appealConfirmationTerms Appeal confirmation period duration in terms
    * @param _pcts Array containing:
    *        0. penaltyPct Permyriad of min active tokens balance to be locked to each drafted guardians (‱ - 1/10,000)
    *        1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)
    * @param _roundParams Array containing params for rounds:
    *        0. firstRoundGuardiansNumber Number of guardians to be drafted for the first round of disputes
    *        1. appealStepFactor Increasing factor for the number of guardians of each round of a dispute
    *        2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered
    *        3. finalRoundLockTerms Number of terms that a coherent guardian in a final round is disallowed to withdraw (to prevent 51% attacks)
    * @param _appealCollateralParams Array containing params for appeal collateral:
    *        1. appealCollateralFactor Permyriad multiple of dispute fees required to appeal a preliminary ruling
    *        2. appealConfirmCollateralFactor Permyriad multiple of dispute fees required to confirm appeal
    * @param _minActiveBalance Minimum amount of guardian tokens that can be activated
    */
    constructor(
        uint64[2] memory _termParams,
        address[3] memory _governors,
        IERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance
    )
        public
        CourtClock(_termParams)
        CourtConfig(_feeToken, _fees, _roundStateDurations, _pcts, _roundParams, _appealCollateralParams, _minActiveBalance)
    {
        _setFundsGovernor(_governors[0]);
        _setConfigGovernor(_governors[1]);
        _setModulesGovernor(_governors[2]);
    }

    /**
    * @dev Fallback function allows to forward calls to a specific address in case it was previously registered
    *      Note the sender will be always the controller in case it is forwarded
    */
    function () external payable {
        address target = customFunctions[msg.sig];
        require(target != address(0), ERROR_CUSTOM_FUNCTION_NOT_SET);

        // solium-disable-next-line security/no-call-value
        (bool success,) = address(target).call.value(msg.value)(msg.data);
        assembly {
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

            let result := success
            switch result case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    /**
    * @notice Change Court configuration params
    * @param _fromTermId Identification number of the term in which the config will be effective at
    * @param _feeToken Address of the token contract that is used to pay for fees
    * @param _fees Array containing:
    *        0. guardianFee Amount of fee tokens that is paid per guardian per dispute
    *        1. draftFee Amount of fee tokens per guardian to cover the drafting cost
    *        2. settleFee Amount of fee tokens per guardian to cover round settlement cost
    * @param _roundStateDurations Array containing the durations in terms of the different phases of a dispute:
    *        0. evidenceTerms Max submitting evidence period duration in terms
    *        1. commitTerms Commit period duration in terms
    *        2. revealTerms Reveal period duration in terms
    *        3. appealTerms Appeal period duration in terms
    *        4. appealConfirmationTerms Appeal confirmation period duration in terms
    * @param _pcts Array containing:
    *        0. penaltyPct Permyriad of min active tokens balance to be locked to each drafted guardians (‱ - 1/10,000)
    *        1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)
    * @param _roundParams Array containing params for rounds:
    *        0. firstRoundGuardiansNumber Number of guardians to be drafted for the first round of disputes
    *        1. appealStepFactor Increasing factor for the number of guardians of each round of a dispute
    *        2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered
    *        3. finalRoundLockTerms Number of terms that a coherent guardian in a final round is disallowed to withdraw (to prevent 51% attacks)
    * @param _appealCollateralParams Array containing params for appeal collateral:
    *        1. appealCollateralFactor Permyriad multiple of dispute fees required to appeal a preliminary ruling
    *        2. appealConfirmCollateralFactor Permyriad multiple of dispute fees required to confirm appeal
    * @param _minActiveBalance Minimum amount of guardian tokens that can be activated
    */
    function setConfig(
        uint64 _fromTermId,
        IERC20 _feeToken,
        uint256[3] calldata _fees,
        uint64[5] calldata _roundStateDurations,
        uint16[2] calldata _pcts,
        uint64[4] calldata _roundParams,
        uint256[2] calldata _appealCollateralParams,
        uint256 _minActiveBalance
    )
        external
        onlyConfigGovernor
    {
        uint64 currentTermId = _ensureCurrentTerm();
        _setConfig(
            currentTermId,
            _fromTermId,
            _feeToken,
            _fees,
            _roundStateDurations,
            _pcts,
            _roundParams,
            _appealCollateralParams,
            _minActiveBalance
        );
    }

    /**
    * @notice Delay the Court start time to `_newFirstTermStartTime`
    * @param _newFirstTermStartTime New timestamp in seconds when the court will open
    */
    function delayStartTime(uint64 _newFirstTermStartTime) external onlyConfigGovernor {
        _delayStartTime(_newFirstTermStartTime);
    }

    /**
    * @notice Change funds governor address to `_newFundsGovernor`
    * @param _newFundsGovernor Address of the new funds governor to be set
    */
    function changeFundsGovernor(address _newFundsGovernor) external onlyFundsGovernor {
        require(_newFundsGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);
        _setFundsGovernor(_newFundsGovernor);
    }

    /**
    * @notice Change config governor address to `_newConfigGovernor`
    * @param _newConfigGovernor Address of the new config governor to be set
    */
    function changeConfigGovernor(address _newConfigGovernor) external onlyConfigGovernor {
        require(_newConfigGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);
        _setConfigGovernor(_newConfigGovernor);
    }

    /**
    * @notice Change modules governor address to `_newModulesGovernor`
    * @param _newModulesGovernor Address of the new governor to be set
    */
    function changeModulesGovernor(address _newModulesGovernor) external onlyModulesGovernor {
        require(_newModulesGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);
        _setModulesGovernor(_newModulesGovernor);
    }

    /**
    * @notice Remove the funds governor. Set the funds governor to the zero address.
    * @dev This action cannot be rolled back, once the funds governor has been unset, funds cannot be recovered from recoverable modules anymore
    */
    function ejectFundsGovernor() external onlyFundsGovernor {
        _setFundsGovernor(ZERO_ADDRESS);
    }

    /**
    * @notice Remove the modules governor. Set the modules governor to the zero address.
    * @dev This action cannot be rolled back, once the modules governor has been unset, system modules cannot be changed anymore
    */
    function ejectModulesGovernor() external onlyModulesGovernor {
        _setModulesGovernor(ZERO_ADDRESS);
    }

    /**
    * @notice Grant `_id` role to `_who`
    * @param _id ID of the role to be granted
    * @param _who Address to grant the role to
    */
    function grant(bytes32 _id, address _who) external onlyConfigGovernor {
        _grant(_id, _who);
    }

    /**
    * @notice Revoke `_id` role from `_who`
    * @param _id ID of the role to be revoked
    * @param _who Address to revoke the role from
    */
    function revoke(bytes32 _id, address _who) external onlyConfigGovernor {
        _revoke(_id, _who);
    }

    /**
    * @notice Freeze `_id` role
    * @param _id ID of the role to be frozen
    */
    function freeze(bytes32 _id) external onlyConfigGovernor {
        _freeze(_id);
    }

    /**
    * @notice Enact a bulk list of ACL operations
    */
    function bulk(BulkOp[] calldata _op, bytes32[] calldata _id, address[] calldata _who) external onlyConfigGovernor {
        _bulk(_op, _id, _who);
    }

    /**
    * @notice Set module `_id` to `_addr`
    * @param _id ID of the module to be set
    * @param _addr Address of the module to be set
    */
    function setModule(bytes32 _id, address _addr) external onlyModulesGovernor {
        _setModule(_id, _addr);
    }

    /**
    * @notice Set and link many modules at once
    * @param _newModuleIds List of IDs of the new modules to be set
    * @param _newModuleAddresses List of addresses of the new modules to be set
    * @param _newModuleLinks List of IDs of the modules that will be linked in the new modules being set
    * @param _currentModulesToBeSynced List of addresses of current modules to be re-linked to the new modules being set
    */
    function setModules(
        bytes32[] calldata _newModuleIds,
        address[] calldata _newModuleAddresses,
        bytes32[] calldata _newModuleLinks,
        address[] calldata _currentModulesToBeSynced
    )
        external
        onlyModulesGovernor
    {
        // We only care about the modules being set, links are optional
        require(_newModuleIds.length == _newModuleAddresses.length, ERROR_INVALID_IMPLS_INPUT_LENGTH);

        // First set the addresses of the new modules or the modules to be updated
        for (uint256 i = 0; i < _newModuleIds.length; i++) {
            _setModule(_newModuleIds[i], _newModuleAddresses[i]);
        }

        // Then sync the links of the new modules based on the list of IDs specified (ideally the IDs of their dependencies)
        _syncModuleLinks(_newModuleAddresses, _newModuleLinks);

        // Finally sync the links of the existing modules to be synced to the new modules being set
        _syncModuleLinks(_currentModulesToBeSynced, _newModuleIds);
    }

    /**
    * @notice Sync modules for a list of modules IDs based on their current implementation address
    * @param _modulesToBeSynced List of addresses of connected modules to be synced
    * @param _idsToBeSet List of IDs of the modules included in the sync
    */
    function syncModuleLinks(address[] calldata _modulesToBeSynced, bytes32[] calldata _idsToBeSet)
        external
        onlyModulesGovernor
    {
        require(_idsToBeSet.length > 0 && _modulesToBeSynced.length > 0, ERROR_INVALID_IMPLS_INPUT_LENGTH);
        _syncModuleLinks(_modulesToBeSynced, _idsToBeSet);
    }

    /**
    * @notice Disable module `_addr`
    * @dev Current modules can be disabled to allow pausing the court. However, these can be enabled back again, see `enableModule`
    * @param _addr Address of the module to be disabled
    */
    function disableModule(address _addr) external onlyModulesGovernor {
        Module storage module = allModules[_addr];
        _ensureModuleExists(module);
        require(!module.disabled, ERROR_MODULE_ALREADY_DISABLED);

        module.disabled = true;
        emit ModuleDisabled(module.id, _addr);
    }

    /**
    * @notice Enable module `_addr`
    * @param _addr Address of the module to be enabled
    */
    function enableModule(address _addr) external onlyModulesGovernor {
        Module storage module = allModules[_addr];
        _ensureModuleExists(module);
        require(module.disabled, ERROR_MODULE_ALREADY_ENABLED);

        module.disabled = false;
        emit ModuleEnabled(module.id, _addr);
    }

    /**
    * @notice Set custom function `_sig` for `_target`
    * @param _sig Signature of the function to be set
    * @param _target Address of the target implementation to be registered for the given signature
    */
    function setCustomFunction(bytes4 _sig, address _target) external onlyModulesGovernor {
        customFunctions[_sig] = _target;
        emit CustomFunctionSet(_sig, _target);
    }

    /**
    * @dev Tell the full Court configuration parameters at a certain term
    * @param _termId Identification number of the term querying the Court config of
    * @return token Address of the token used to pay for fees
    * @return fees Array containing:
    *         0. guardianFee Amount of fee tokens that is paid per guardian per dispute
    *         1. draftFee Amount of fee tokens per guardian to cover the drafting cost
    *         2. settleFee Amount of fee tokens per guardian to cover round settlement cost
    * @return roundStateDurations Array containing the durations in terms of the different phases of a dispute:
    *         0. evidenceTerms Max submitting evidence period duration in terms
    *         1. commitTerms Commit period duration in terms
    *         2. revealTerms Reveal period duration in terms
    *         3. appealTerms Appeal period duration in terms
    *         4. appealConfirmationTerms Appeal confirmation period duration in terms
    * @return pcts Array containing:
    *         0. penaltyPct Permyriad of min active tokens balance to be locked for each drafted guardian (‱ - 1/10,000)
    *         1. finalRoundReduction Permyriad of fee reduction for the last appeal round (‱ - 1/10,000)
    * @return roundParams Array containing params for rounds:
    *         0. firstRoundGuardiansNumber Number of guardians to be drafted for the first round of disputes
    *         1. appealStepFactor Increasing factor for the number of guardians of each round of a dispute
    *         2. maxRegularAppealRounds Number of regular appeal rounds before the final round is triggered
    *         3. finalRoundLockTerms Number of terms that a coherent guardian in a final round is disallowed to withdraw (to prevent 51% attacks)
    * @return appealCollateralParams Array containing params for appeal collateral:
    *         0. appealCollateralFactor Multiple of dispute fees required to appeal a preliminary ruling
    *         1. appealConfirmCollateralFactor Multiple of dispute fees required to confirm appeal
    */
    function getConfig(uint64 _termId) external view
        returns (
            IERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        )
    {
        uint64 lastEnsuredTermId = _lastEnsuredTermId();
        return _getConfigAt(_termId, lastEnsuredTermId);
    }

    /**
    * @dev Tell the draft config at a certain term
    * @param _termId Identification number of the term querying the draft config of
    * @return feeToken Address of the token used to pay for fees
    * @return draftFee Amount of fee tokens per guardian to cover the drafting cost
    * @return penaltyPct Permyriad of min active tokens balance to be locked for each drafted guardian (‱ - 1/10,000)
    */
    function getDraftConfig(uint64 _termId) external view returns (IERC20 feeToken, uint256 draftFee, uint16 penaltyPct) {
        uint64 lastEnsuredTermId = _lastEnsuredTermId();
        return _getDraftConfig(_termId, lastEnsuredTermId);
    }

    /**
    * @dev Tell the min active balance config at a certain term
    * @param _termId Identification number of the term querying the min active balance config of
    * @return Minimum amount of tokens guardians have to activate to participate in the Court
    */
    function getMinActiveBalance(uint64 _termId) external view returns (uint256) {
        uint64 lastEnsuredTermId = _lastEnsuredTermId();
        return _getMinActiveBalance(_termId, lastEnsuredTermId);
    }

    /**
    * @dev Tell the address of the funds governor
    * @return Address of the funds governor
    */
    function getFundsGovernor() external view returns (address) {
        return governor.funds;
    }

    /**
    * @dev Tell the address of the config governor
    * @return Address of the config governor
    */
    function getConfigGovernor() external view returns (address) {
        return governor.config;
    }

    /**
    * @dev Tell the address of the modules governor
    * @return Address of the modules governor
    */
    function getModulesGovernor() external view returns (address) {
        return governor.modules;
    }

    /**
    * @dev Tell if a given module is active
    * @param _id ID of the module to be checked
    * @param _addr Address of the module to be checked
    * @return True if the given module address has the requested ID and is enabled
    */
    function isActive(bytes32 _id, address _addr) external view returns (bool) {
        Module storage module = allModules[_addr];
        return module.id == _id && !module.disabled;
    }

    /**
    * @dev Tell the current ID and disable status of a module based on a given address
    * @param _addr Address of the requested module
    * @return id ID of the module being queried
    * @return disabled Whether the module has been disabled
    */
    function getModuleByAddress(address _addr) external view returns (bytes32 id, bool disabled) {
        Module storage module = allModules[_addr];
        id = module.id;
        disabled = module.disabled;
    }

    /**
    * @dev Tell the current address and disable status of a module based on a given ID
    * @param _id ID of the module being queried
    * @return addr Current address of the requested module
    * @return disabled Whether the module has been disabled
    */
    function getModule(bytes32 _id) external view returns (address addr, bool disabled) {
        return _getModule(_id);
    }

    /**
    * @dev Tell the information for the current DisputeManager module
    * @return addr Current address of the DisputeManager module
    * @return disabled Whether the module has been disabled
    */
    function getDisputeManager() external view returns (address addr, bool disabled) {
        return _getModule(MODULE_ID_DISPUTE_MANAGER);
    }

    /**
    * @dev Tell the information for  the current GuardiansRegistry module
    * @return addr Current address of the GuardiansRegistry module
    * @return disabled Whether the module has been disabled
    */
    function getGuardiansRegistry() external view returns (address addr, bool disabled) {
        return _getModule(MODULE_ID_GUARDIANS_REGISTRY);
    }

    /**
    * @dev Tell the information for the current Voting module
    * @return addr Current address of the Voting module
    * @return disabled Whether the module has been disabled
    */
    function getVoting() external view returns (address addr, bool disabled) {
        return _getModule(MODULE_ID_VOTING);
    }

    /**
    * @dev Tell the information for the current PaymentsBook module
    * @return addr Current address of the PaymentsBook module
    * @return disabled Whether the module has been disabled
    */
    function getPaymentsBook() external view returns (address addr, bool disabled) {
        return _getModule(MODULE_ID_PAYMENTS_BOOK);
    }

    /**
    * @dev Tell the information for the current Treasury module
    * @return addr Current address of the Treasury module
    * @return disabled Whether the module has been disabled
    */
    function getTreasury() external view returns (address addr, bool disabled) {
        return _getModule(MODULE_ID_TREASURY);
    }

    /**
    * @dev Tell the target registered for a custom function
    * @param _sig Signature of the function being queried
    * @return Address of the target where the function call will be forwarded
    */
    function getCustomFunction(bytes4 _sig) external view returns (address) {
        return customFunctions[_sig];
    }

    /**
    * @dev Internal function to set the address of the funds governor
    * @param _newFundsGovernor Address of the new config governor to be set
    */
    function _setFundsGovernor(address _newFundsGovernor) internal {
        emit FundsGovernorChanged(governor.funds, _newFundsGovernor);
        governor.funds = _newFundsGovernor;
    }

    /**
    * @dev Internal function to set the address of the config governor
    * @param _newConfigGovernor Address of the new config governor to be set
    */
    function _setConfigGovernor(address _newConfigGovernor) internal {
        emit ConfigGovernorChanged(governor.config, _newConfigGovernor);
        governor.config = _newConfigGovernor;
    }

    /**
    * @dev Internal function to set the address of the modules governor
    * @param _newModulesGovernor Address of the new modules governor to be set
    */
    function _setModulesGovernor(address _newModulesGovernor) internal {
        emit ModulesGovernorChanged(governor.modules, _newModulesGovernor);
        governor.modules = _newModulesGovernor;
    }

    /**
    * @dev Internal function to set an address as the current implementation for a module
    *      Note that the disabled condition is not affected, if the module was not set before it will be enabled by default
    * @param _id Id of the module to be set
    * @param _addr Address of the module to be set
    */
    function _setModule(bytes32 _id, address _addr) internal {
        require(isContract(_addr), ERROR_IMPLEMENTATION_NOT_CONTRACT);

        currentModules[_id] = _addr;
        allModules[_addr].id = _id;
        emit ModuleSet(_id, _addr);
    }

    /**
    * @dev Internal function to sync the modules for a list of modules IDs based on their current implementation address
    * @param _modulesToBeSynced List of addresses of connected modules to be synced
    * @param _idsToBeSet List of IDs of the modules to be linked
    */
    function _syncModuleLinks(address[] memory _modulesToBeSynced, bytes32[] memory _idsToBeSet) internal {
        address[] memory addressesToBeSet = new address[](_idsToBeSet.length);

        // Load the addresses associated with the requested module ids
        for (uint256 i = 0; i < _idsToBeSet.length; i++) {
            address moduleAddress = _getModuleAddress(_idsToBeSet[i]);
            Module storage module = allModules[moduleAddress];
            _ensureModuleExists(module);
            addressesToBeSet[i] = moduleAddress;
        }

        // Update the links of all the requested modules
        for (uint256 j = 0; j < _modulesToBeSynced.length; j++) {
            IModulesLinker(_modulesToBeSynced[j]).linkModules(_idsToBeSet, addressesToBeSet);
        }
    }

    /**
    * @dev Internal function to notify when a term has been transitioned
    * @param _termId Identification number of the new current term that has been transitioned
    */
    function _onTermTransitioned(uint64 _termId) internal {
        _ensureTermConfig(_termId);
    }

    /**
    * @dev Internal function to check if a module was set
    * @param _module Module to be checked
    */
    function _ensureModuleExists(Module storage _module) internal view {
        require(_module.id != bytes32(0), ERROR_MODULE_NOT_SET);
    }

    /**
    * @dev Internal function to tell the information for a module based on a given ID
    * @param _id ID of the module being queried
    * @return addr Current address of the requested module
    * @return disabled Whether the module has been disabled
    */
    function _getModule(bytes32 _id) internal view returns (address addr, bool disabled) {
        addr = _getModuleAddress(_id);
        disabled = _isModuleDisabled(addr);
    }

    /**
    * @dev Tell the current address for a module by ID
    * @param _id ID of the module being queried
    * @return Current address of the requested module
    */
    function _getModuleAddress(bytes32 _id) internal view returns (address) {
        return currentModules[_id];
    }

    /**
    * @dev Tell whether a module is disabled
    * @param _addr Address of the module being queried
    * @return True if the module is disabled, false otherwise
    */
    function _isModuleDisabled(address _addr) internal view returns (bool) {
        return allModules[_addr].disabled;
    }
}

contract ConfigConsumer is CourtConfigData {
    /**
    * @dev Internal function to fetch the address of the Config module from the controller
    * @return Address of the Config module
    */
    function _courtConfig() internal view returns (IConfig);

    /**
    * @dev Internal function to get the Court config for a certain term
    * @param _termId Identification number of the term querying the Court config of
    * @return Court config for the given term
    */
    function _getConfigAt(uint64 _termId) internal view returns (Config memory) {
        (IERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance) = _courtConfig().getConfig(_termId);

        Config memory config;

        config.fees = FeesConfig({
            token: _feeToken,
            guardianFee: _fees[0],
            draftFee: _fees[1],
            settleFee: _fees[2],
            finalRoundReduction: _pcts[1]
        });

        config.disputes = DisputesConfig({
            evidenceTerms: _roundStateDurations[0],
            commitTerms: _roundStateDurations[1],
            revealTerms: _roundStateDurations[2],
            appealTerms: _roundStateDurations[3],
            appealConfirmTerms: _roundStateDurations[4],
            penaltyPct: _pcts[0],
            firstRoundGuardiansNumber: _roundParams[0],
            appealStepFactor: _roundParams[1],
            maxRegularAppealRounds: _roundParams[2],
            finalRoundLockTerms: _roundParams[3],
            appealCollateralFactor: _appealCollateralParams[0],
            appealConfirmCollateralFactor: _appealCollateralParams[1]
        });

        config.minActiveBalance = _minActiveBalance;

        return config;
    }

    /**
    * @dev Internal function to get the draft config for a given term
    * @param _termId Identification number of the term querying the draft config of
    * @return Draft config for the given term
    */
    function _getDraftConfig(uint64 _termId) internal view returns (DraftConfig memory) {
        (IERC20 feeToken, uint256 draftFee, uint16 penaltyPct) = _courtConfig().getDraftConfig(_termId);
        return DraftConfig({ feeToken: feeToken, draftFee: draftFee, penaltyPct: penaltyPct });
    }

    /**
    * @dev Internal function to get the min active balance config for a given term
    * @param _termId Identification number of the term querying the min active balance config of
    * @return Minimum amount of guardian tokens that can be activated
    */
    function _getMinActiveBalance(uint64 _termId) internal view returns (uint256) {
        return _courtConfig().getMinActiveBalance(_termId);
    }
}

/*
 * SPDX-License-Identifier:    MIT
 */


/*
 * SPDX-License-Identifier:    MIT
 */


/*
 * SPDX-License-Identifier:    MIT
 */


contract Controlled is IModulesLinker, IsContract, ModuleIds, ConfigConsumer {
    string private constant ERROR_MODULE_NOT_SET = "CTD_MODULE_NOT_SET";
    string private constant ERROR_INVALID_MODULES_LINK_INPUT = "CTD_INVALID_MODULES_LINK_INPUT";
    string private constant ERROR_CONTROLLER_NOT_CONTRACT = "CTD_CONTROLLER_NOT_CONTRACT";
    string private constant ERROR_SENDER_NOT_ALLOWED = "CTD_SENDER_NOT_ALLOWED";
    string private constant ERROR_SENDER_NOT_CONTROLLER = "CTD_SENDER_NOT_CONTROLLER";
    string private constant ERROR_SENDER_NOT_CONFIG_GOVERNOR = "CTD_SENDER_NOT_CONFIG_GOVERNOR";
    string private constant ERROR_SENDER_NOT_ACTIVE_VOTING = "CTD_SENDER_NOT_ACTIVE_VOTING";
    string private constant ERROR_SENDER_NOT_ACTIVE_DISPUTE_MANAGER = "CTD_SEND_NOT_ACTIVE_DISPUTE_MGR";
    string private constant ERROR_SENDER_NOT_CURRENT_DISPUTE_MANAGER = "CTD_SEND_NOT_CURRENT_DISPUTE_MGR";

    // Address of the controller
    Controller public controller;

    // List of modules linked indexed by ID
    mapping (bytes32 => address) public linkedModules;

    event ModuleLinked(bytes32 id, address addr);

    /**
    * @dev Ensure the msg.sender is the controller's config governor
    */
    modifier onlyConfigGovernor {
        require(msg.sender == _configGovernor(), ERROR_SENDER_NOT_CONFIG_GOVERNOR);
        _;
    }

    /**
    * @dev Ensure the msg.sender is the controller
    */
    modifier onlyController() {
        require(msg.sender == address(controller), ERROR_SENDER_NOT_CONTROLLER);
        _;
    }

    /**
    * @dev Ensure the msg.sender is an active DisputeManager module
    */
    modifier onlyActiveDisputeManager() {
        require(controller.isActive(MODULE_ID_DISPUTE_MANAGER, msg.sender), ERROR_SENDER_NOT_ACTIVE_DISPUTE_MANAGER);
        _;
    }

    /**
    * @dev Ensure the msg.sender is the current DisputeManager module
    */
    modifier onlyCurrentDisputeManager() {
        (address addr, bool disabled) = controller.getDisputeManager();
        require(msg.sender == addr, ERROR_SENDER_NOT_CURRENT_DISPUTE_MANAGER);
        require(!disabled, ERROR_SENDER_NOT_ACTIVE_DISPUTE_MANAGER);
        _;
    }

    /**
    * @dev Ensure the msg.sender is an active Voting module
    */
    modifier onlyActiveVoting() {
        require(controller.isActive(MODULE_ID_VOTING, msg.sender), ERROR_SENDER_NOT_ACTIVE_VOTING);
        _;
    }

    /**
    * @dev This modifier will check that the sender is the user to act on behalf of or someone with the required permission
    * @param _user Address of the user to act on behalf of
    */
    modifier authenticateSender(address _user) {
        _authenticateSender(_user);
        _;
    }

    /**
    * @dev Constructor function
    * @param _controller Address of the controller
    */
    constructor(Controller _controller) public {
        require(isContract(address(_controller)), ERROR_CONTROLLER_NOT_CONTRACT);
        controller = _controller;
    }

    /**
    * @notice Update the implementation links of a list of modules
    * @dev The controller is expected to ensure the given addresses are correct modules
    * @param _ids List of IDs of the modules to be updated
    * @param _addresses List of module addresses to be updated
    */
    function linkModules(bytes32[] calldata _ids, address[] calldata _addresses) external onlyController {
        require(_ids.length == _addresses.length, ERROR_INVALID_MODULES_LINK_INPUT);

        for (uint256 i = 0; i < _ids.length; i++) {
            linkedModules[_ids[i]] = _addresses[i];
            emit ModuleLinked(_ids[i], _addresses[i]);
        }
    }

    /**
    * @dev Internal function to ensure the Court term is up-to-date, it will try to update it if not
    * @return Identification number of the current Court term
    */
    function _ensureCurrentTerm() internal returns (uint64) {
        return _clock().ensureCurrentTerm();
    }

    /**
    * @dev Internal function to fetch the last ensured term ID of the Court
    * @return Identification number of the last ensured term
    */
    function _getLastEnsuredTermId() internal view returns (uint64) {
        return _clock().getLastEnsuredTermId();
    }

    /**
    * @dev Internal function to tell the current term identification number
    * @return Identification number of the current term
    */
    function _getCurrentTermId() internal view returns (uint64) {
        return _clock().getCurrentTermId();
    }

    /**
    * @dev Internal function to fetch the controller's config governor
    * @return Address of the controller's config governor
    */
    function _configGovernor() internal view returns (address) {
        return controller.getConfigGovernor();
    }

    /**
    * @dev Internal function to fetch the address of the DisputeManager module
    * @return Address of the DisputeManager module
    */
    function _disputeManager() internal view returns (IDisputeManager) {
        return IDisputeManager(_getLinkedModule(MODULE_ID_DISPUTE_MANAGER));
    }

    /**
    * @dev Internal function to fetch the address of the GuardianRegistry module implementation
    * @return Address of the GuardianRegistry module implementation
    */
    function _guardiansRegistry() internal view returns (IGuardiansRegistry) {
        return IGuardiansRegistry(_getLinkedModule(MODULE_ID_GUARDIANS_REGISTRY));
    }

    /**
    * @dev Internal function to fetch the address of the Voting module implementation
    * @return Address of the Voting module implementation
    */
    function _voting() internal view returns (ICRVoting) {
        return ICRVoting(_getLinkedModule(MODULE_ID_VOTING));
    }

    /**
    * @dev Internal function to fetch the address of the PaymentsBook module implementation
    * @return Address of the PaymentsBook module implementation
    */
    function _paymentsBook() internal view returns (IPaymentsBook) {
        return IPaymentsBook(_getLinkedModule(MODULE_ID_PAYMENTS_BOOK));
    }

    /**
    * @dev Internal function to fetch the address of the Treasury module implementation
    * @return Address of the Treasury module implementation
    */
    function _treasury() internal view returns (ITreasury) {
        return ITreasury(_getLinkedModule(MODULE_ID_TREASURY));
    }

    /**
    * @dev Internal function to tell the address linked for a module based on a given ID
    * @param _id ID of the module being queried
    * @return Linked address of the requested module
    */
    function _getLinkedModule(bytes32 _id) internal view returns (address) {
        address module = linkedModules[_id];
        require(module != address(0), ERROR_MODULE_NOT_SET);
        return module;
    }

    /**
    * @dev Internal function to fetch the address of the Clock module from the controller
    * @return Address of the Clock module
    */
    function _clock() internal view returns (IClock) {
        return IClock(controller);
    }

    /**
    * @dev Internal function to fetch the address of the Config module from the controller
    * @return Address of the Config module
    */
    function _courtConfig() internal view returns (IConfig) {
        return IConfig(controller);
    }

    /**
    * @dev Ensure that the sender is the user to act on behalf of or someone with the required permission
    * @param _user Address of the user to act on behalf of
    */
    function _authenticateSender(address _user) internal view {
        require(_isSenderAllowed(_user), ERROR_SENDER_NOT_ALLOWED);
    }

    /**
    * @dev Tell whether the sender is the user to act on behalf of or someone with the required permission
    * @param _user Address of the user to act on behalf of
    * @return True if the sender is the user to act on behalf of or someone with the required permission, false otherwise
    */
    function _isSenderAllowed(address _user) internal view returns (bool) {
        return msg.sender == _user || _hasRole(msg.sender);
    }

    /**
    * @dev Tell whether an address holds the required permission to access the requested functionality
    * @param _addr Address being checked
    * @return True if the given address has the required permission to access the requested functionality, false otherwise
    */
    function _hasRole(address _addr) internal view returns (bool) {
        bytes32 roleId = keccak256(abi.encodePacked(address(this), msg.sig));
        return controller.hasRole(_addr, roleId);
    }
}

contract ControlledRecoverable is Controlled {
    using SafeERC20 for IERC20;

    string private constant ERROR_SENDER_NOT_FUNDS_GOVERNOR = "CTD_SENDER_NOT_FUNDS_GOVERNOR";
    string private constant ERROR_INSUFFICIENT_RECOVER_FUNDS = "CTD_INSUFFICIENT_RECOVER_FUNDS";
    string private constant ERROR_RECOVER_TOKEN_FUNDS_FAILED = "CTD_RECOVER_TOKEN_FUNDS_FAILED";

    event RecoverFunds(address token, address recipient, uint256 balance);

    /**
    * @dev Ensure the msg.sender is the controller's funds governor
    */
    modifier onlyFundsGovernor {
        require(msg.sender == controller.getFundsGovernor(), ERROR_SENDER_NOT_FUNDS_GOVERNOR);
        _;
    }

    /**
    * @notice Transfer all `_token` tokens to `_to`
    * @param _token Address of the token to be recovered
    * @param _to Address of the recipient that will be receive all the funds of the requested token
    */
    function recoverFunds(address _token, address payable _to) external payable onlyFundsGovernor {
        uint256 balance;

        if (_token == address(0)) {
            balance = address(this).balance;
            require(_to.send(balance), ERROR_RECOVER_TOKEN_FUNDS_FAILED);
        } else {
            balance = IERC20(_token).balanceOf(address(this));
            require(balance > 0, ERROR_INSUFFICIENT_RECOVER_FUNDS);
            // No need to verify _token to be a contract as we have already checked the balance
            require(IERC20(_token).safeTransfer(_to, balance), ERROR_RECOVER_TOKEN_FUNDS_FAILED);
        }

        emit RecoverFunds(_token, _to, balance);
    }
}

contract PaymentsBook is IPaymentsBook, ControlledRecoverable, TimeHelpers {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeMath64 for uint64;
    using PctHelpers for uint256;

    string private constant ERROR_COURT_HAS_NOT_STARTED = "PB_COURT_HAS_NOT_STARTED";
    string private constant ERROR_NON_PAST_PERIOD = "PB_NON_PAST_PERIOD";
    string private constant ERROR_PERIOD_DURATION_ZERO = "PB_PERIOD_DURATION_ZERO";
    string private constant ERROR_PERIOD_BALANCE_DETAILS_NOT_COMPUTED = "PB_PER_BAL_DETAILS_NOT_COMPUTED";
    string private constant ERROR_PAYMENT_AMOUNT_ZERO = "PB_PAYMENT_AMOUNT_ZERO";
    string private constant ERROR_ETH_DEPOSIT_TOKEN_MISMATCH = "PB_ETH_DEPOSIT_TOKEN_MISMATCH";
    string private constant ERROR_ETH_DEPOSIT_AMOUNT_MISMATCH = "PB_ETH_DEPOSIT_AMOUNT_MISMATCH";
    string private constant ERROR_ETH_TRANSFER_FAILED = "PB_ETH_TRANSFER_FAILED";
    string private constant ERROR_TOKEN_NOT_CONTRACT = "PB_TOKEN_NOT_CONTRACT";
    string private constant ERROR_TOKEN_DEPOSIT_FAILED = "PB_TOKEN_DEPOSIT_FAILED";
    string private constant ERROR_TOKEN_TRANSFER_FAILED = "PB_TOKEN_TRANSFER_FAILED";
    string private constant ERROR_GUARDIAN_SHARE_ALREADY_CLAIMED = "PB_GUARDIAN_SHARE_ALREADY_CLAIMED";
    string private constant ERROR_GOVERNOR_SHARE_ALREADY_CLAIMED = "PB_GOVERNOR_SHARE_ALREADY_CLAIMED";
    string private constant ERROR_OVERRATED_GOVERNOR_SHARE_PCT = "PB_OVERRATED_GOVERNOR_SHARE_PCT";

    // Term 0 is for guardians on-boarding
    uint64 internal constant START_TERM_ID = 1;

    struct Period {
        // Court term ID of a period used to fetch the total active balance of the guardians registry
        uint64 balanceCheckpoint;
        // Total amount of guardian tokens active in the Court at the corresponding period checkpoint
        uint256 totalActiveBalance;
        // List of collected amounts for the governor indexed by token address
        mapping (address => uint256) governorShares;
        // List of tokens claimed by the governor during a period, indexed by token addresses
        mapping (address => bool) claimedGovernor;
        // List of collected amounts for the guardians indexed by token address
        mapping (address => uint256) guardiansShares;
        // List of guardians that have claimed their share during a period, indexed by guardian and token addresses
        mapping (address => mapping (address => bool)) claimedGuardians;
    }

    // Duration of a payment period in Court terms
    uint64 public periodDuration;

    // Permyriad of collected payments that will be allocated to the governor of the Court (‱ - 1/10,000)
    uint16 public governorSharePct;

    // List of periods indexed by ID
    mapping (uint256 => Period) internal periods;

    event PaymentReceived(uint256 indexed periodId, address indexed payer, address indexed token, uint256 amount, bytes data);
    event GuardianShareClaimed(uint256 indexed periodId, address indexed guardian, address indexed token, uint256 amount);
    event GovernorShareClaimed(uint256 indexed periodId, address indexed token, uint256 amount);
    event GovernorSharePctChanged(uint16 previousGovernorSharePct, uint16 currentGovernorSharePct);

    /**
    * @dev Initialize court payments book
    * @param _controller Address of the controller
    * @param _periodDuration Duration of a payment period in Court terms
    * @param _governorSharePct Initial permyriad of collected payments that will be allocated to the governor of the Court (‱ - 1/10,000)
    */
    constructor(Controller _controller, uint64 _periodDuration, uint16 _governorSharePct) Controlled(_controller) public {
        require(_periodDuration > 0, ERROR_PERIOD_DURATION_ZERO);

        periodDuration = _periodDuration;
        _setGovernorSharePct(_governorSharePct);
    }

    /**
    * @notice Pay `@tokenAmount(_token, _amount)` for `_payer` (`_data`)
    * @param _token Address of the token being paid
    * @param _amount Amount of tokens being paid
    * @param _payer Address paying on behalf of
    * @param _data Optional data
    */
    function pay(address _token, uint256 _amount, address _payer, bytes calldata _data) external payable {
        (uint256 periodId, Period storage period) = _getCurrentPeriod();
        require(_amount > 0, ERROR_PAYMENT_AMOUNT_ZERO);

        // Update collected amount for the governor
        uint256 governorShare = _amount.pct(governorSharePct);
        period.governorShares[_token] = period.governorShares[_token].add(governorShare);

        // Update collected amount for the guardians
        uint256 guardiansShare = _amount.sub(governorShare);
        period.guardiansShares[_token] = period.guardiansShares[_token].add(guardiansShare);

        // Deposit funds from sender to this contract
        // ETH or token amount checks are handled in `_deposit()`
        _deposit(msg.sender, _token, _amount);
        emit PaymentReceived(periodId, _payer, _token, _amount, _data);
    }

    /**
    * @notice Claim guardian share for period #`_periodId` owed to `_guardian`
    * @dev It will ignore tokens that were already claimed without reverting
    * @param _periodId Identification number of the period being claimed
    * @param _guardian Address of the guardian claiming the shares for
    * @param _tokens List of token addresses to be claimed
    */
    function claimGuardianShare(uint256 _periodId, address payable _guardian, address[] calldata _tokens)
        external
        authenticateSender(_guardian)
    {
        require(_periodId < _getCurrentPeriodId(), ERROR_NON_PAST_PERIOD);

        Period storage period = periods[_periodId];
        (uint64 periodBalanceCheckpoint, uint256 totalActiveBalance) = _ensurePeriodBalanceDetails(period, _periodId);
        uint256 guardianActiveBalance = _getGuardianActiveBalance(_guardian, periodBalanceCheckpoint);

        // We assume the token contract is not malicious
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            require(!_hasGuardianClaimed(period, _guardian, token), ERROR_GUARDIAN_SHARE_ALREADY_CLAIMED);
            uint256 amount = _getGuardianShare(period, token, guardianActiveBalance, totalActiveBalance);
            _claimGuardianShare(period, _periodId, _guardian, token, amount);
        }
    }

    /**
    * @notice Transfer owed share to the governor for period #`_periodId`
    * @param _periodId Identification number of the period being claimed
    * @param _tokens List of token addresses to be claimed
    */
    function claimGovernorShare(uint256 _periodId, address[] calldata _tokens) external {
        require(_periodId < _getCurrentPeriodId(), ERROR_NON_PAST_PERIOD);

        Period storage period = periods[_periodId];
        address payable governor = address(uint160(_configGovernor()));

        // We assume the token contract is not malicious
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            require(!_hasGovernorClaimed(period, token), ERROR_GOVERNOR_SHARE_ALREADY_CLAIMED);
            _claimGovernorShare(period, _periodId, governor, token);
        }
    }

    /**
    * @notice Make sure that the balance details of a certain period have been computed
    * @param _periodId Identification number of the period being ensured
    * @return periodBalanceCheckpoint Court term ID used to fetch the total active balance of the guardians registry
    * @return totalActiveBalance Total amount of guardian tokens active in the Court at the corresponding used checkpoint
    */
    function ensurePeriodBalanceDetails(uint256 _periodId) external returns (uint64 periodBalanceCheckpoint, uint256 totalActiveBalance) {
        require(_periodId < _getCurrentPeriodId(), ERROR_NON_PAST_PERIOD);
        Period storage period = periods[_periodId];
        return _ensurePeriodBalanceDetails(period, _periodId);
    }

    /**
    * @notice Set new governor share to `_governorSharePct`‱ (1/10,000)
    * @param _governorSharePct New permyriad of collected payments that will be allocated to the governor of the Court (‱ - 1/10,000)
    */
    function setGovernorSharePct(uint16 _governorSharePct) external onlyConfigGovernor {
        _setGovernorSharePct(_governorSharePct);
    }

    /**
    * @dev Tell the identification number of the current period
    * @return Identification number of the current period
    */
    function getCurrentPeriodId() external view returns (uint256) {
        return _getCurrentPeriodId();
    }

    /**
    * @dev Get the share details of a payment period
    * @param _periodId Identification number of the period to be queried
    * @param _token Address of the token querying the share details for
    * @return guardiansShare Guardians share for the requested period and token
    * @return governorShare Governor share for the requested period and token
    */
    function getPeriodShares(uint256 _periodId, address _token)
        external
        view
        returns (uint256 guardiansShare, uint256 governorShare)
    {
        Period storage period = periods[_periodId];
        guardiansShare = period.guardiansShares[_token];
        governorShare = period.governorShares[_token];
    }

    /**
    * @dev Get the balance details of a payment period
    * @param _periodId Identification number of the period to be queried
    * @return balanceCheckpoint Court term ID of a period used to fetch the total active balance of the guardians registry
    * @return totalActiveBalance Total amount of guardian tokens active in the Court at the corresponding period checkpoint
    */
    function getPeriodBalanceDetails(uint256 _periodId)
        external
        view
        returns (uint64 balanceCheckpoint, uint256 totalActiveBalance)
    {
        Period storage period = periods[_periodId];
        balanceCheckpoint = period.balanceCheckpoint;
        totalActiveBalance = period.totalActiveBalance;
    }

    /**
    * @dev Tell the share corresponding to a guardian for a certain period
    * @param _periodId Identification number of the period being queried
    * @param _guardian Address of the guardian querying the share of
    * @param _tokens List of token addresses to be queried
    * @return List of token amounts corresponding to the guardian
    */
    function getGuardianShare(uint256 _periodId, address _guardian, address[] calldata _tokens)
        external
        view
        returns (uint256[] memory amounts)
    {
        require(_periodId < _getCurrentPeriodId(), ERROR_NON_PAST_PERIOD);

        Period storage period = periods[_periodId];
        uint256 totalActiveBalance = period.totalActiveBalance;
        require(totalActiveBalance != 0, ERROR_PERIOD_BALANCE_DETAILS_NOT_COMPUTED);

        amounts = new uint256[](_tokens.length);
        uint256 guardianActiveBalance = _getGuardianActiveBalance(_guardian, period.balanceCheckpoint);
        for (uint256 i = 0; i < _tokens.length; i++) {
            amounts[i] = _getGuardianShare(period, _tokens[i], guardianActiveBalance, totalActiveBalance);
        }
    }

    /**
    * @dev Tell if a given guardian has already claimed the owed share for a certain period
    * @param _periodId Identification number of the period being queried
    * @param _guardian Address of the guardian being queried
    * @param _tokens List of token addresses to be queried
    * @return List of claimed status for each requested token
    */
    function hasGuardianClaimed(uint256 _periodId, address _guardian, address[] calldata _tokens)
        external
        view
        returns (bool[] memory claimed)
    {
        Period storage period = periods[_periodId];

        claimed = new bool[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            claimed[i] = _hasGuardianClaimed(period, _guardian, _tokens[i]);
        }
    }

    /**
    * @dev Tell the share corresponding to the governor for a certain period
    * @param _periodId Identification number of the period being queried
    * @param _tokens List of token addresses to be queried
    * @return List of token amounts corresponding to the governor
    */
    function getGovernorShare(uint256 _periodId, address[] calldata _tokens) external view returns (uint256[] memory amounts) {
        Period storage period = periods[_periodId];

        amounts = new uint256[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            amounts[i] = _getGovernorShare(period, _tokens[i]);
        }
    }

    /**
    * @dev Tell if the governor has already claimed the owed share for a certain period
    * @param _periodId Identification number of the period being queried
    * @param _tokens List of token addresses to be queried
    * @return List of claimed status for each requested token
    */
    function hasGovernorClaimed(uint256 _periodId, address[] calldata _tokens)
        external
        view
        returns (bool[] memory claimed)
    {
        Period storage period = periods[_periodId];

        claimed = new bool[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            claimed[i] = _hasGovernorClaimed(period, _tokens[i]);
        }
    }

    /**
    * @dev Internal function to claim guardian share for a certain period
    * @param _period Period being claimed
    * @param _periodId Identification number of the period being claimed
    * @param _guardian Address of the guardian claiming their share
    * @param _token Address of the token being claimed
    * @param _amount Amount of tokens to be transferred to the guardian
    */
    function _claimGuardianShare(
        Period storage _period,
        uint256 _periodId,
        address payable _guardian,
        address _token,
        uint256 _amount
    )
        internal
    {
        _period.claimedGuardians[_guardian][_token] = true;
        if (_amount > 0) {
            _transfer(_guardian, _token, _amount);
            emit GuardianShareClaimed(_periodId, _guardian, _token, _amount);
        }
    }

    /**
    * @dev Internal function to transfer governor share for a certain period
    * @param _period Period being claimed
    * @param _periodId Identification number of the period being claimed
    * @param _token Address of the token to be claimed
    */
    function _claimGovernorShare(Period storage _period, uint256 _periodId, address payable _governor, address _token) internal {
        _period.claimedGovernor[_token] = true;
        uint256 amount = _getGovernorShare(_period, _token);
        if (amount > 0) {
            _transfer(_governor, _token, amount);
            emit GovernorShareClaimed(_periodId, _token, amount);
        }
    }

    /**
    * @dev Internal function to pull tokens into this contract
    * @param _from Owner of the deposited funds
    * @param _token Address of the token to deposit
    * @param _amount Amount to be deposited
    */
    function _deposit(address _from, address _token, uint256 _amount) internal {
        if (msg.value > 0) {
            require(_token == address(0), ERROR_ETH_DEPOSIT_TOKEN_MISMATCH);
            require(msg.value == _amount, ERROR_ETH_DEPOSIT_AMOUNT_MISMATCH);
        } else {
            require(isContract(_token), ERROR_TOKEN_NOT_CONTRACT);
            require(IERC20(_token).safeTransferFrom(_from, address(this), _amount), ERROR_TOKEN_DEPOSIT_FAILED);
        }
    }

    /**
    * @dev Internal function to transfer tokens
    * @param _to Recipient of the transfer
    * @param _token Address of the token to transfer
    * @param _amount Amount to be transferred
    */
    function _transfer(address payable _to, address _token, uint256 _amount) internal {
        if (_token == address(0)) {
            require(_to.send(_amount), ERROR_ETH_TRANSFER_FAILED);
        } else {
            require(IERC20(_token).safeTransfer(_to, _amount), ERROR_TOKEN_TRANSFER_FAILED);
        }
    }

    /**
    * @dev Internal function to make sure that the balance details of a certain period have been computed.
    *      This function assumes given ID and period correspond to each other, and that the period is in the past.
    * @param _periodId Identification number of the period being ensured
    * @param _period Period being ensured
    * @return Court term ID used to fetch the total active balance of the guardians registry
    * @return Total amount of guardian tokens active in the Court at the corresponding used checkpoint
    */
    function _ensurePeriodBalanceDetails(Period storage _period, uint256 _periodId) internal returns (uint64, uint256) {
        // Shortcut if the period balance details were already set
        uint256 totalActiveBalance = _period.totalActiveBalance;
        if (totalActiveBalance != 0) {
            return (_period.balanceCheckpoint, totalActiveBalance);
        }

        uint64 periodStartTermId = _getPeriodStartTermId(_periodId);
        uint64 nextPeriodStartTermId = _getPeriodStartTermId(_periodId.add(1));

        // Pick a random Court term during the next period of the requested one to get the total amount of guardian tokens active in the Court
        IClock clock = _clock();
        bytes32 randomness = clock.getTermRandomness(nextPeriodStartTermId);

        // The randomness factor for each Court term is computed using the the hash of a block number set during the initialization of the
        // term, to ensure it cannot be known beforehand. Note that the hash function being used only works for the 256 most recent block
        // numbers. Therefore, if that occurs we use the hash of the previous block number. This could be slightly beneficial for the first
        // guardian calling this function, but it's still impossible to predict during the requested period.
        if (randomness == bytes32(0)) {
            randomness = blockhash(getBlockNumber() - 1);
        }

        // Use randomness to choose a Court term of the requested period and query the total amount of guardian tokens active at that term
        IGuardiansRegistry guardiansRegistry = _guardiansRegistry();
        uint64 periodBalanceCheckpoint = periodStartTermId.add(uint64(uint256(randomness) % periodDuration));
        totalActiveBalance = guardiansRegistry.totalActiveBalanceAt(periodBalanceCheckpoint);

        _period.balanceCheckpoint = periodBalanceCheckpoint;
        _period.totalActiveBalance = totalActiveBalance;
        return (periodBalanceCheckpoint, totalActiveBalance);
    }

    /**
    * @dev Internal function to set a new governor share value
    * @param _governorSharePct New permyriad of collected payments that will be allocated to the governor of the Court (‱ - 1/10,000)
    */
    function _setGovernorSharePct(uint16 _governorSharePct) internal {
        // Check governor share is not greater than 10,000‱
        require(PctHelpers.isValid(_governorSharePct), ERROR_OVERRATED_GOVERNOR_SHARE_PCT);

        emit GovernorSharePctChanged(governorSharePct, _governorSharePct);
        governorSharePct = _governorSharePct;
    }

    /**
    * @dev Internal function to tell the identification number of the current period
    * @return Identification number of the current period
    */
    function _getCurrentPeriodId() internal view returns (uint256) {
        // Since the Court starts at term #1, and the first payment period is #0, then subtract one unit to the current term of the Court
        uint64 termId = _getCurrentTermId();
        require(termId > 0, ERROR_COURT_HAS_NOT_STARTED);

        // No need for SafeMath: we already checked that the term ID is at least 1
        uint64 periodId = (termId - START_TERM_ID) / periodDuration;
        return uint256(periodId);
    }

    /**
    * @dev Internal function to get the current period
    * @return periodId Identification number of the current period
    * @return period Current period instance
    */
    function _getCurrentPeriod() internal view returns (uint256 periodId, Period storage period) {
        periodId = _getCurrentPeriodId();
        period = periods[periodId];
    }

    /**
    * @dev Internal function to get the Court term in which a certain period starts
    * @param _periodId Identification number of the period querying the start term of
    * @return Court term where the given period starts
    */
    function _getPeriodStartTermId(uint256 _periodId) internal view returns (uint64) {
        // Periods are measured in Court terms
        // Since Court terms are represented in uint64, we are safe to use uint64 for period ids too
        return START_TERM_ID.add(uint64(_periodId).mul(periodDuration));
    }

    /**
    * @dev Internal function to tell the active balance of a guardian for a certain period
    * @param _guardian Address of the guardian querying the share of
    * @param _periodBalanceCheckpoint Checkpoint of the period being queried
    * @return Active balance for a guardian based on the period checkpoint
    */
    function _getGuardianActiveBalance(address _guardian, uint64 _periodBalanceCheckpoint) internal view returns (uint256) {
        IGuardiansRegistry guardiansRegistry = _guardiansRegistry();
        return guardiansRegistry.activeBalanceOfAt(_guardian, _periodBalanceCheckpoint);
    }

    /**
    * @dev Internal function to tell the share corresponding to a guardian for a certain period and token
    * @param _period Period being queried
    * @param _token Address of the token being queried
    * @param _guardianActiveBalance Active balance of a guardian at the corresponding period checkpoint
    * @param _totalActiveBalance Total amount of guardian tokens active in the Court at the corresponding period checkpoint
    * @return Share owed to the given guardian for the requested period and token
    */
    function _getGuardianShare(
        Period storage _period,
        address _token,
        uint256 _guardianActiveBalance,
        uint256 _totalActiveBalance
    )
        internal
        view
        returns (uint256)
    {
        if (_guardianActiveBalance == 0) {
            return 0;
        }

        // Note that we already checked the guardian active balance is greater than zero.
        // Then, the total active balance should be greater than zero.
        return _period.guardiansShares[_token].mul(_guardianActiveBalance) / _totalActiveBalance;
    }

    /**
    * @dev Tell if a guardian has already claimed the owed share for a certain period
    * @param _period Period being queried
    * @param _guardian Address of the guardian being queried
    * @param _token Address of the token to be queried
    * @return True if the guardian has already claimed their share
    */
    function _hasGuardianClaimed(Period storage _period, address _guardian, address _token) internal view returns (bool) {
        return _period.claimedGuardians[_guardian][_token];
    }

    /**
    * @dev Tell the share corresponding to a guardian for a certain period
    * @param _period Period being queried
    * @param _token Address of the token to be queried
    * @return Token amount corresponding to the governor
    */
    function _getGovernorShare(Period storage _period, address _token) internal view returns (uint256) {
        return _period.governorShares[_token];
    }

    /**
    * @dev Tell if the governor has already claimed the owed share for a certain period
    * @param _period Period being queried
    * @param _token Address of the token to be queried
    * @return True if the governor has already claimed their share
    */
    function _hasGovernorClaimed(Period storage _period, address _token) internal view returns (bool) {
        return _period.claimedGovernor[_token];
    }
}