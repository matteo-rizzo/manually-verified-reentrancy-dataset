/**
 *Submitted for verification at Etherscan.io on 2021-06-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;


/**
 * @dev Standard math utilities missing in the Solidity language.
 */





/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
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

    constructor () {
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


contract Governance is ReentrancyGuard {

	uint constant public governance_challenging_period = 10 days;
	uint constant public governance_freeze_period = 30 days;

	address public votingTokenAddress;
	address public governedContractAddress;

	mapping(address => uint) public balances;

	VotedValue[] public votedValues;
	mapping(string => VotedValue) public votedValuesMap;


	constructor(address _governedContractAddress, address _votingTokenAddress){
		init(_governedContractAddress, _votingTokenAddress);
	}

	function init(address _governedContractAddress, address _votingTokenAddress) public {
		require(governedContractAddress == address(0), "governance already initialized");
		governedContractAddress = _governedContractAddress;
		votingTokenAddress = _votingTokenAddress;
	}

	function addressBelongsToGovernance(address addr) public view returns (bool) {
		for (uint i = 0; i < votedValues.length; i++)
			if (address(votedValues[i]) == addr)
				return true;
		return false;
	}

	function isUntiedFromAllVotes(address addr) public view returns (bool) {
		for (uint i = 0; i < votedValues.length; i++)
			if (votedValues[i].hasVote(addr))
				return false;
		return true;
	}

	function addVotedValue(string memory name, VotedValue votedValue) external {
		require(msg.sender == governedContractAddress, "not authorized");
		votedValues.push(votedValue);
		votedValuesMap[name] = votedValue;
	}


	// deposit

	function deposit(uint amount) payable external {
		deposit(msg.sender, amount);
	}

	function deposit(address from, uint amount) nonReentrant payable public {
		require(from == msg.sender || addressBelongsToGovernance(msg.sender), "not allowed");
		if (votingTokenAddress == address(0))
			require(msg.value == amount, "wrong amount received");
		else {
			require(msg.value == 0, "don't send ETH");
			require(IERC20(votingTokenAddress).transferFrom(from, address(this), amount), "failed to pull gov deposit");
		}
		balances[from] += amount;
	}


	// withdrawal functions

	function withdraw() external {
		withdraw(balances[msg.sender]);
	}

	function withdraw(uint amount) nonReentrant public {
		require(amount > 0, "zero withdrawal requested");
		require(amount <= balances[msg.sender], "not enough balance");
		require(isUntiedFromAllVotes(msg.sender), "some votes not removed yet");
		balances[msg.sender] -= amount;
		if (votingTokenAddress == address(0))
			payable(msg.sender).transfer(amount);
		else
			require(IERC20(votingTokenAddress).transfer(msg.sender, amount), "failed to withdraw gov deposit");
	}
}


abstract contract VotedValue is ReentrancyGuard {
	Governance public governance;
	uint public challenging_period_start_ts;
	mapping(address => bool) public hasVote;

	constructor(Governance _governance){
		governance = _governance;
	}

	function checkVoteChangeLock() view public {
		require(challenging_period_start_ts + governance.governance_challenging_period() + governance.governance_freeze_period() < block.timestamp, "you cannot change your vote yet");
	}

	function checkChallengingPeriodExpiry() view public {
		require(block.timestamp > challenging_period_start_ts + governance.governance_challenging_period(), "challenging period not expired yet");
	}
}


contract VotedValueUint is VotedValue {

	function(uint) external validationCallback;
	function(uint) external commitCallback;

	uint public leader;
	uint public current_value;

	mapping(address => uint) public choices;
	mapping(uint => uint) public votesByValue;
	mapping(uint => mapping(address => uint)) public votesByValueAddress;

	constructor() VotedValue(Governance(address(0))) {}

	// constructor(Governance _governance, uint initial_value, function(uint) external _validationCallback, function(uint) external _commitCallback) VotedValue(_governance) {
	// 	leader = initial_value;
	// 	current_value = initial_value;
	// 	validationCallback = _validationCallback;
	// 	commitCallback = _commitCallback;
	// }

	function init(Governance _governance, uint initial_value, function(uint) external _validationCallback, function(uint) external _commitCallback) external {
		require(address(governance) == address(0), "already initialized");
		governance = _governance;
		leader = initial_value;
		current_value = initial_value;
		validationCallback = _validationCallback;
		commitCallback = _commitCallback;
	}

	function vote(uint value) nonReentrant external {
		_vote(value);
	}

	function voteAndDeposit(uint value, uint amount) nonReentrant payable external {
		governance.deposit{value: msg.value}(msg.sender, amount);
		_vote(value);
	}

	function _vote(uint value) private {
		validationCallback(value);
		uint prev_choice = choices[msg.sender];
		bool hadVote = hasVote[msg.sender];
		if (prev_choice == leader)
			checkVoteChangeLock();

		// first, remove votes from the previous choice
		if (hadVote)
			removeVote(prev_choice);

		// then, add them to the new choice
		uint balance = governance.balances(msg.sender);
		require(balance > 0, "no balance");
		votesByValue[value] += balance;
		votesByValueAddress[value][msg.sender] = balance;
		choices[msg.sender] = value;
		hasVote[msg.sender] = true;

		// check if the leader has just changed
		if (votesByValue[value] > votesByValue[leader]){
			leader = value;
			challenging_period_start_ts = block.timestamp;
		}
	}

	function unvote() external {
		if (!hasVote[msg.sender])
			return;
		uint prev_choice = choices[msg.sender];
		if (prev_choice == leader)
			checkVoteChangeLock();
		
		removeVote(prev_choice);
		delete choices[msg.sender];
		delete hasVote[msg.sender];
	}

	function removeVote(uint value) internal {
		votesByValue[value] -= votesByValueAddress[value][msg.sender];
		votesByValueAddress[value][msg.sender] = 0;
	}

	function commit() nonReentrant external {
		require(leader != current_value, "already equal to leader");
		checkChallengingPeriodExpiry();
		current_value = leader;
		commitCallback(leader);
	}
}



contract VotedValueUintArray is VotedValue {

	function(uint[] memory) external validationCallback;
	function(uint[] memory) external commitCallback;

	uint[] public leader;
	uint[] public current_value;

	mapping(address => uint[]) public choices;
	mapping(bytes32 => uint) public votesByValue;
	mapping(bytes32 => mapping(address => uint)) public votesByValueAddress;

	constructor() VotedValue(Governance(address(0))) {}

	// constructor(Governance _governance, uint[] memory initial_value, function(uint[] memory) external _validationCallback, function(uint[] memory) external _commitCallback) VotedValue(_governance) {
	// 	leader = initial_value;
	// 	current_value = initial_value;
	// 	validationCallback = _validationCallback;
	// 	commitCallback = _commitCallback;
	// }

	function init(Governance _governance, uint[] memory initial_value, function(uint[] memory) external _validationCallback, function(uint[] memory) external _commitCallback) external {
		require(address(governance) == address(0), "already initialized");
		governance = _governance;
		leader = initial_value;
		current_value = initial_value;
		validationCallback = _validationCallback;
		commitCallback = _commitCallback;
	}

	function equal(uint[] memory a1, uint[] memory a2) public pure returns (bool) {
		if (a1.length != a2.length)
			return false;
		for (uint i = 0; i < a1.length; i++)
			if (a1[i] != a2[i])
				return false;
		return true;
	}

	function getKey(uint[] memory a) public pure returns (bytes32){
		return keccak256(abi.encodePacked(a));
	}

	function vote(uint[] memory value) nonReentrant external {
		_vote(value);
	}

	function voteAndDeposit(uint[] memory value, uint amount) nonReentrant payable external {
		governance.deposit{value: msg.value}(msg.sender, amount);
		_vote(value);
	}

	function _vote(uint[] memory value) private {
		validationCallback(value);
		uint[] storage prev_choice = choices[msg.sender];
		bool hadVote = hasVote[msg.sender];
		if (equal(prev_choice, leader))
			checkVoteChangeLock();

		// remove one's vote from the previous choice first
		if (hadVote)
			removeVote(prev_choice);

		// then, add it to the new choice, if any
		bytes32 key = getKey(value);
		uint balance = governance.balances(msg.sender);
		require(balance > 0, "no balance");
		votesByValue[key] += balance;
		votesByValueAddress[key][msg.sender] = balance;
		choices[msg.sender] = value;
		hasVote[msg.sender] = true;

		// check if the leader has just changed
		if (votesByValue[key] > votesByValue[getKey(leader)]){
			leader = value;
			challenging_period_start_ts = block.timestamp;
		}
	}

	function unvote() external {
		if (!hasVote[msg.sender])
			return;
		uint[] storage prev_choice = choices[msg.sender];
		if (equal(prev_choice, leader))
			checkVoteChangeLock();
		
		removeVote(prev_choice);
		delete choices[msg.sender];
		delete hasVote[msg.sender];
	}

	function removeVote(uint[] memory value) internal {
		bytes32 key = getKey(value);
		votesByValue[key] -= votesByValueAddress[key][msg.sender];
		votesByValueAddress[key][msg.sender] = 0;
	}

	function commit() nonReentrant external {
		require(!equal(leader, current_value), "already equal to leader");
		checkChallengingPeriodExpiry();
		current_value = leader;
		commitCallback(leader);
	}
}



contract VotedValueAddress is VotedValue {

	function(address) external validationCallback;
	function(address) external commitCallback;

	address public leader;
	address public current_value;

	// mapping(who => value)
	mapping(address => address) public choices;

	// mapping(value => votes)
	mapping(address => uint) public votesByValue;

	// mapping(value => mapping(who => votes))
	mapping(address => mapping(address => uint)) public votesByValueAddress;

	constructor() VotedValue(Governance(address(0))) {}

	// constructor(Governance _governance, address initial_value, function(address) external _validationCallback, function(address) external _commitCallback) VotedValue(_governance) {
	// 	leader = initial_value;
	// 	current_value = initial_value;
	// 	validationCallback = _validationCallback;
	// 	commitCallback = _commitCallback;
	// }

	function init(Governance _governance, address initial_value, function(address) external _validationCallback, function(address) external _commitCallback) external {
		require(address(governance) == address(0), "already initialized");
		governance = _governance;
		leader = initial_value;
		current_value = initial_value;
		validationCallback = _validationCallback;
		commitCallback = _commitCallback;
	}

	function vote(address value) nonReentrant external {
		_vote(value);
	}

	function voteAndDeposit(address value, uint amount) nonReentrant payable external {
		governance.deposit{value: msg.value}(msg.sender, amount);
		_vote(value);
	}

	function _vote(address value) private {
		validationCallback(value);
		address prev_choice = choices[msg.sender];
		bool hadVote = hasVote[msg.sender];
		if (prev_choice == leader)
			checkVoteChangeLock();

		// first, remove votes from the previous choice
		if (hadVote)
			removeVote(prev_choice);

		// then, add them to the new choice
		uint balance = governance.balances(msg.sender);
		require(balance > 0, "no balance");
		votesByValue[value] += balance;
		votesByValueAddress[value][msg.sender] = balance;
		choices[msg.sender] = value;
		hasVote[msg.sender] = true;

		// check if the leader has just changed
		if (votesByValue[value] > votesByValue[leader]){
			leader = value;
			challenging_period_start_ts = block.timestamp;
		}
	}

	function unvote() external {
		if (!hasVote[msg.sender])
			return;
		address prev_choice = choices[msg.sender];
		if (prev_choice == leader)
			checkVoteChangeLock();
		
		removeVote(prev_choice);
		delete choices[msg.sender];
		delete hasVote[msg.sender];
	}

	function removeVote(address value) internal {
		votesByValue[value] -= votesByValueAddress[value][msg.sender];
		votesByValueAddress[value][msg.sender] = 0;
	}

	function commit() nonReentrant external {
		require(leader != current_value, "already equal to leader");
		checkChallengingPeriodExpiry();
		current_value = leader;
		commitCallback(leader);
	}
}


contract VotedValueFactory {

	address public votedValueUintMaster;
	address public votedValueUintArrayMaster;
	address public votedValueAddressMaster;

	constructor(address _votedValueUintMaster, address _votedValueUintArrayMaster, address _votedValueAddressMaster) {
		votedValueUintMaster = _votedValueUintMaster;
		votedValueUintArrayMaster = _votedValueUintArrayMaster;
		votedValueAddressMaster = _votedValueAddressMaster;
	}


	function createVotedValueUint(Governance governance, uint initial_value, function(uint) external validationCallback, function(uint) external commitCallback) external returns (VotedValueUint) {
		VotedValueUint vv = VotedValueUint(Clones.clone(votedValueUintMaster));
		vv.init(governance, initial_value, validationCallback, commitCallback);
		return vv;
	}

	function createVotedValueUintArray(Governance governance, uint[] memory initial_value, function(uint[] memory) external validationCallback, function(uint[] memory) external commitCallback) external returns (VotedValueUintArray) {
		VotedValueUintArray vv = VotedValueUintArray(Clones.clone(votedValueUintArrayMaster));
		vv.init(governance, initial_value, validationCallback, commitCallback);
		return vv;
	}

	function createVotedValueAddress(Governance governance, address initial_value, function(address) external validationCallback, function(address) external commitCallback) external returns (VotedValueAddress) {
		VotedValueAddress vv = VotedValueAddress(Clones.clone(votedValueAddressMaster));
		vv.init(governance, initial_value, validationCallback, commitCallback);
		return vv;
	}

}




contract GovernanceFactory {

	address public governanceMaster;

	constructor(address _governanceMaster) {
		governanceMaster = _governanceMaster;
	}

	function createGovernance(address governedContractAddress, address votingTokenAddress) external returns (Governance) {
		Governance governance = Governance(Clones.clone(governanceMaster));
		governance.init(governedContractAddress, votingTokenAddress);
		return governance;
	}

}





// The purpose of the library is to separate some of the code out of the Export/Import contracts and keep their sizes under the 24KiB limit









abstract contract Counterstake is ReentrancyGuard {

	event NewClaim(uint indexed claim_num, address author_address, string sender_address, address recipient_address, string txid, uint32 txts, uint amount, int reward, uint stake, string data, uint32 expiry_ts);
	event NewChallenge(uint indexed claim_num, address author_address, uint stake, CounterstakeLibrary.Side outcome, CounterstakeLibrary.Side current_outcome, uint yes_stake, uint no_stake, uint32 expiry_ts, uint challenging_target);
	event FinishedClaim(uint indexed claim_num, CounterstakeLibrary.Side outcome);

	Governance public governance;
	CounterstakeLibrary.Settings public settings;


	uint64 public last_claim_num;
	uint64[] public ongoing_claim_nums;
	mapping(uint => uint) public num2index;

	mapping(string => uint) public claim_nums;
	mapping(uint => CounterstakeLibrary.Claim) private claims;
	mapping(uint => mapping(CounterstakeLibrary.Side => mapping(address => uint))) public stakes;

	function getClaim(uint claim_num) external view returns (CounterstakeLibrary.Claim memory) {
		return claims[claim_num];
	}

	function getClaim(string memory claim_id) external view returns (CounterstakeLibrary.Claim memory) {
		return claims[claim_nums[claim_id]];
	}

	function getOngoingClaimNums() external view returns (uint64[] memory) {
		return ongoing_claim_nums;
	}


	constructor (address _tokenAddr, uint16 _counterstake_coef100, uint16 _ratio100, uint _large_threshold, uint[] memory _challenging_periods, uint[] memory _large_challenging_periods) {
		initCounterstake(_tokenAddr, _counterstake_coef100, _ratio100, _large_threshold, _challenging_periods, _large_challenging_periods);
	}

	function initCounterstake(address _tokenAddr, uint16 _counterstake_coef100, uint16 _ratio100, uint _large_threshold, uint[] memory _challenging_periods, uint[] memory _large_challenging_periods) public {
		require(address(governance) == address(0), "already initialized");
		settings = CounterstakeLibrary.Settings({
			tokenAddress: _tokenAddr,
			counterstake_coef100: _counterstake_coef100 > 100 ? _counterstake_coef100 : 150,
			ratio100: _ratio100 > 0 ? _ratio100 : 100,
			min_stake: 0,
			min_tx_age: 0,
			challenging_periods: _challenging_periods,
			large_challenging_periods: _large_challenging_periods,
			large_threshold: _large_threshold
		});
	}

	/*
	modifier onlyETH(){
		require(settings.tokenAddress == address(0), "ETH only");
		_;
	}

	modifier onlyERC20(){
		require(settings.tokenAddress != address(0), "ERC20 only");
		_;
	}*/

	modifier onlyVotedValueContract(){
		require(governance.addressBelongsToGovernance(msg.sender), "not from voted value contract");
		_;
	}

	// would be happy to call this from the constructor but unfortunately `this` is not set at that time yet
	function setupGovernance(GovernanceFactory governanceFactory, VotedValueFactory votedValueFactory) virtual public {
		require(address(governance) == address(0), "already initialized");
		governance = governanceFactory.createGovernance(address(this), settings.tokenAddress);

		governance.addVotedValue("ratio100", votedValueFactory.createVotedValueUint(governance, settings.ratio100, this.validateRatio, this.setRatio));
		governance.addVotedValue("counterstake_coef100", votedValueFactory.createVotedValueUint(governance, settings.counterstake_coef100, this.validateCounterstakeCoef, this.setCounterstakeCoef));
		governance.addVotedValue("min_stake", votedValueFactory.createVotedValueUint(governance, settings.min_stake, this.validateMinStake, this.setMinStake));
		governance.addVotedValue("min_tx_age", votedValueFactory.createVotedValueUint(governance, settings.min_tx_age, this.validateMinTxAge, this.setMinTxAge));
		governance.addVotedValue("large_threshold", votedValueFactory.createVotedValueUint(governance, settings.large_threshold, this.validateLargeThreshold, this.setLargeThreshold));
		governance.addVotedValue("challenging_periods", votedValueFactory.createVotedValueUintArray(governance, settings.challenging_periods, this.validateChallengingPeriods, this.setChallengingPeriods));
		governance.addVotedValue("large_challenging_periods", votedValueFactory.createVotedValueUintArray(governance, settings.large_challenging_periods, this.validateChallengingPeriods, this.setLargeChallengingPeriods));
	}

	function validateRatio(uint _ratio100) pure external {
		require(_ratio100 > 0 && _ratio100 < 64000, "bad ratio");
	}

	function setRatio(uint _ratio100) onlyVotedValueContract external {
		settings.ratio100 = uint16(_ratio100);
	}

	
	function validateCounterstakeCoef(uint _counterstake_coef100) pure external {
		require(_counterstake_coef100 > 100 && _counterstake_coef100 < 64000, "bad counterstake coef");
	}

	function setCounterstakeCoef(uint _counterstake_coef100) onlyVotedValueContract external {
		settings.counterstake_coef100 = uint16(_counterstake_coef100);
	}

	
	function validateMinStake(uint _min_stake) pure external {
		// anything goes
	}

	function setMinStake(uint _min_stake) onlyVotedValueContract external {
		settings.min_stake = _min_stake;
	}


	function validateMinTxAge(uint _min_tx_age) pure external {
		require(_min_tx_age < 4 weeks, "min tx age too large");
	}

	function setMinTxAge(uint _min_tx_age) onlyVotedValueContract external {
		settings.min_tx_age = uint32(_min_tx_age);
	}


	function validateLargeThreshold(uint _large_threshold) pure external {
		// anything goes
	}

	function setLargeThreshold(uint _large_threshold) onlyVotedValueContract external {
		settings.large_threshold = _large_threshold;
	}


	function validateChallengingPeriods(uint[] memory periods) pure external {
		CounterstakeLibrary.validateChallengingPeriods(periods);
	}

	function setChallengingPeriods(uint[] memory _challenging_periods) onlyVotedValueContract external {
		settings.challenging_periods = _challenging_periods;
	}

	function setLargeChallengingPeriods(uint[] memory _large_challenging_periods) onlyVotedValueContract external {
		settings.large_challenging_periods = _large_challenging_periods;
	}


	function getChallengingPeriod(uint16 period_number, bool bLarge) external view returns (uint) {
		return CounterstakeLibrary.getChallengingPeriod(settings, period_number, bLarge);
	}

	function getRequiredStake(uint amount) public view virtual returns (uint);

	function getMissingStake(uint claim_num, CounterstakeLibrary.Side stake_on) external view returns (uint) {
		CounterstakeLibrary.Claim storage c = claims[claim_num];
		require(c.yes_stake > 0, "no such claim");
		uint current_stake = (stake_on == CounterstakeLibrary.Side.yes) ? c.yes_stake : c.no_stake;
		return (c.current_outcome == CounterstakeLibrary.Side.yes ? c.yes_stake : c.no_stake) * settings.counterstake_coef100/100 - current_stake;
	}



	function claim(string memory txid, uint32 txts, uint amount, int reward, uint stake, string memory sender_address, address payable recipient_address, string memory data) nonReentrant payable external {
		if (recipient_address == address(0))
			recipient_address = payable(msg.sender);
		bool bThirdPartyClaiming = (recipient_address != payable(msg.sender) && reward >= 0);
		uint paid_amount;
		if (bThirdPartyClaiming) {
			require(amount > uint(reward), "reward too large");
			paid_amount = amount - uint(reward);
		}
		receiveMoneyInClaim(stake, paid_amount);
		uint required_stake = getRequiredStake(amount);
		CounterstakeLibrary.ClaimRequest memory req = CounterstakeLibrary.ClaimRequest({
			txid: txid,
			txts: txts,
			amount: amount,
			reward: reward,
			stake: stake,
			required_stake: required_stake,
			recipient_address: recipient_address,
			sender_address: sender_address,
			data: data
		});
		last_claim_num++;
		ongoing_claim_nums.push(last_claim_num);
		num2index[last_claim_num] = ongoing_claim_nums.length - 1;

		CounterstakeLibrary.claim(settings, claim_nums, claims, stakes, last_claim_num, req);
		
		if (bThirdPartyClaiming){
			sendToClaimRecipient(recipient_address, paid_amount);
			notifyPaymentRecipient(recipient_address, paid_amount, 0, last_claim_num);
		}
	}
	

	function challenge(string calldata claim_id, CounterstakeLibrary.Side stake_on, uint stake) payable external {
		challenge(claim_nums[claim_id], stake_on, stake);
	}

	function challenge(uint claim_num, CounterstakeLibrary.Side stake_on, uint stake) nonReentrant payable public {
		receiveStakeAsset(stake);
		CounterstakeLibrary.Claim storage c = claims[claim_num];
		require(c.amount > 0, "no such claim");
		CounterstakeLibrary.challenge(settings, c, stakes, claim_num, stake_on, stake);
	}

	function withdraw(string memory claim_id) external {
		withdraw(claim_nums[claim_id], payable(0));
	}

	function withdraw(uint claim_num) external {
		withdraw(claim_num, payable(0));
	}

	function withdraw(string memory claim_id, address payable to_address) external {
		withdraw(claim_nums[claim_id], to_address);
	}

	function withdraw(uint claim_num, address payable to_address) nonReentrant public {
		if (to_address == address(0))
			to_address = payable(msg.sender);
		require(claim_num > 0, "no such claim num");
		CounterstakeLibrary.Claim storage c = claims[claim_num];
		require(c.amount > 0, "no such claim");

		(bool finished, bool is_winning_claimant, uint won_stake) = CounterstakeLibrary.finish(c, stakes, claim_num, to_address);
		
		if (finished){
			uint index = num2index[claim_num];
			uint last_index = ongoing_claim_nums.length - 1;
			if (index != last_index){ // move the last element in place of our removed element
				require(index < last_index, "BUG index after last");
				uint64 claim_num_of_last_element = ongoing_claim_nums[last_index];
				num2index[claim_num_of_last_element] = index;
				ongoing_claim_nums[index] = claim_num_of_last_element;
			}
			ongoing_claim_nums.pop();
			delete num2index[claim_num];
		}

		uint claimed_amount_to_be_paid = is_winning_claimant ? c.amount : 0;
		sendWithdrawals(to_address, claimed_amount_to_be_paid, won_stake);
		notifyPaymentRecipient(to_address, claimed_amount_to_be_paid, won_stake, claim_num);
	}

	function notifyPaymentRecipient(address payable payment_recipient_address, uint net_claimed_amount, uint won_stake, uint claim_num) private {
		if (CounterstakeLibrary.isContract(payment_recipient_address)){
			CounterstakeLibrary.Claim storage c = claims[claim_num];
		//	CounterstakeReceiver(payment_recipient_address).onReceivedFromClaim(claim_num, is_winning_claimant ? claimed_amount : 0, won_stake);
			(bool res, ) = payment_recipient_address.call(abi.encodeWithSignature("onReceivedFromClaim(uint256,uint256,uint256,string,address,string)", claim_num, net_claimed_amount, won_stake, c.sender_address, c.recipient_address, c.data));
			if (!res){
				// ignore
			}
		}
	}

	function receiveStakeAsset(uint stake_asset_amount) internal {
		if (settings.tokenAddress == address(0))
			require(msg.value == stake_asset_amount, "wrong amount received");
		else {
			require(msg.value == 0, "don't send ETH");
			require(IERC20(settings.tokenAddress).transferFrom(msg.sender, address(this), stake_asset_amount), "failed to pull the token");
		}
	}

	function sendWithdrawals(address payable to_address, uint claimed_amount_to_be_paid, uint won_stake) internal virtual;
	
	function sendToClaimRecipient(address payable to_address, uint paid_amount) internal virtual;

	function receiveMoneyInClaim(uint stake, uint paid_amount) internal virtual;

}










/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string public name;
    string public symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }


    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overloaded;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}





contract Export is Counterstake {


	event NewExpatriation(address sender_address, uint amount, int reward, string foreign_address, string data);

	string public foreign_network;
	string public foreign_asset;

	constructor (string memory _foreign_network, string memory _foreign_asset, address _tokenAddr, uint16 _counterstake_coef100, uint16 _ratio100, uint _large_threshold, uint[] memory _challenging_periods, uint[] memory _large_challenging_periods)
	Counterstake(_tokenAddr, _counterstake_coef100, _ratio100, _large_threshold, _challenging_periods, _large_challenging_periods)
	{
		foreign_network = _foreign_network;
		foreign_asset = _foreign_asset;
	}

	function initExport(string memory _foreign_network, string memory _foreign_asset) public
	{
		require(address(governance) == address(0), "already initialized");
		foreign_network = _foreign_network;
		foreign_asset = _foreign_asset;
	}


	function transferToForeignChain(string memory foreign_address, string memory data, uint amount, int reward) payable nonReentrant external {
		receiveStakeAsset(amount);
		if (reward >= 0)
			require(uint(reward) < amount, "reward too big");
		emit NewExpatriation(msg.sender, amount, reward, foreign_address, data);
	}


	function getRequiredStake(uint amount) public view override returns (uint) {
		return Math.max(amount * settings.ratio100 / 100, settings.min_stake);
	}


	function sendWithdrawals(address payable to_address, uint paid_claimed_amount, uint won_stake) internal override {
		uint total = won_stake + paid_claimed_amount;
		if (settings.tokenAddress == address(0)) {
			to_address.transfer(total);
		}
		else {
			require(IERC20(settings.tokenAddress).transfer(to_address, total), "failed to send tokens");
		}
	}

	function receiveMoneyInClaim(uint stake, uint paid_amount) internal override {
		receiveStakeAsset(stake + paid_amount);
	}

	function sendToClaimRecipient(address payable to_address, uint paid_amount) internal override {
		if (settings.tokenAddress == address(0)) {
			to_address.transfer(paid_amount);
		}
		else {
			require(IERC20(settings.tokenAddress).transfer(to_address, paid_amount), "failed to send tokens");
		}
	}

}




interface IERC20WithSymbol is IERC20 {
	function symbol() external view returns (string memory);
}

contract Import is ERC20, Counterstake {


	event NewRepatriation(address sender_address, uint amount, uint reward, string home_address, string data);

	address public oracleAddress;

	// min price of imported asset in terms of stake asset, to protect against malicious oracles
	// The price is multiplied by 1e20
	uint public min_price20;

	string public home_network;
	string public home_asset;

	bytes32 private constant base_hash = keccak256(abi.encodePacked("base"));
	bytes32 private constant zx_hash = keccak256(abi.encodePacked("0x0000000000000000000000000000000000000000"));


	constructor (string memory _home_network, string memory _home_asset, string memory __name, string memory __symbol, address stakeTokenAddr, address oracleAddr, uint16 _counterstake_coef100, uint16 _ratio100, uint _large_threshold, uint[] memory _challenging_periods, uint[] memory _large_challenging_periods) 
	Counterstake(stakeTokenAddr, _counterstake_coef100, _ratio100, _large_threshold, _challenging_periods, _large_challenging_periods) 
	ERC20(__name, __symbol)
	{
		initImport(_home_network, _home_asset, __name, __symbol, oracleAddr);
	}

	function initImport(string memory _home_network, string memory _home_asset, string memory __name, string memory __symbol, address oracleAddr) public
	{
		require(address(governance) == address(0), "already initialized");
		oracleAddress = oracleAddr;
		home_network = _home_network;
		home_asset = _home_asset;
		name = __name;
		symbol = __symbol;
	}

	function setupGovernance(GovernanceFactory governanceFactory, VotedValueFactory votedValueFactory) override virtual public {
		super.setupGovernance(governanceFactory, votedValueFactory);
		governance.addVotedValue("oracleAddress", votedValueFactory.createVotedValueAddress(governance, oracleAddress, this.validateOracle, this.setOracle));
		governance.addVotedValue("min_price20", votedValueFactory.createVotedValueUint(governance, min_price20, this.validateMinPrice, this.setMinPrice));
	}

	function getOraclePrice(address oracleAddr) view private returns (uint, uint) {
		bytes32 home_asset_hash = keccak256(abi.encodePacked(home_asset));
		return IOracle(oracleAddr).getPrice(
			home_asset_hash == base_hash || home_asset_hash == zx_hash ? home_network : home_asset, 
			settings.tokenAddress == address(0) ? "_NATIVE_" : IERC20WithSymbol(settings.tokenAddress).symbol()
		);
	}

	function validateOracle(address oracleAddr) view external {
		require(CounterstakeLibrary.isContract(oracleAddr), "bad oracle");
		(uint num, uint den) = getOraclePrice(oracleAddr);
		require(num > 0 || den > 0, "no price from oracle");
	}

	function setOracle(address oracleAddr) onlyVotedValueContract external {
		oracleAddress = oracleAddr;
	}

	function validateMinPrice(uint _min_price20) pure external {
		// anything goes
	}

	function setMinPrice(uint _min_price20) onlyVotedValueContract external {
		min_price20 = _min_price20;
	}


	// repatriate
	function transferToHomeChain(string memory home_address, string memory data, uint amount, uint reward) external {
		_burn(msg.sender, amount);
		emit NewRepatriation(msg.sender, amount, reward, home_address, data);
	}

	function getRequiredStake(uint amount) public view override returns (uint) {
		(uint num, uint den) = getOraclePrice(oracleAddress);
		require(num > 0, "price num must be positive");
		require(den > 0, "price den must be positive");
		uint stake_in_image_asset = amount * settings.ratio100 / 100;
		return Math.max(Math.max(stake_in_image_asset * num / den, stake_in_image_asset * min_price20 / 1e20), settings.min_stake);
	}


	function sendWithdrawals(address payable to_address, uint paid_claimed_amount, uint won_stake) internal override {
		if (paid_claimed_amount > 0){
			_mint(to_address, paid_claimed_amount);
		}
		if (settings.tokenAddress == address(0))
			to_address.transfer(won_stake);
		else
			require(IERC20(settings.tokenAddress).transfer(to_address, won_stake), "failed to send the won stake");
	}

	function receiveMoneyInClaim(uint stake, uint paid_amount) internal override {
		if (paid_amount > 0)
			_burn(msg.sender, paid_amount);
		receiveStakeAsset(stake);
	}

	function sendToClaimRecipient(address payable to_address, uint paid_amount) internal override {
		_mint(to_address, paid_amount);
	}

}






contract ExportAssistant is ERC20, ReentrancyGuard, CounterstakeReceiver 
{

	address public bridgeAddress;
	address public tokenAddress;
	address public managerAddress;

	uint16 public management_fee10000;
	uint16 public success_fee10000;

	uint8 public exponent;
	
	uint public ts;
	int public profit;
	uint public mf;
	uint public balance_in_work;

	mapping(uint => uint) public balances_in_work;

	Governance public governance;


	event NewClaimFor(uint claim_num, address for_address, string txid, uint32 txts, uint amount, int reward, uint stake);
	event AssistantChallenge(uint claim_num, CounterstakeLibrary.Side outcome, uint stake);
    event NewManager(address previousManager, address newManager);


	modifier onlyETH(){
		require(tokenAddress == address(0), "ETH only");
		_;
	}

/*	modifier onlyERC20(){
		require(tokenAddress != address(0), "ERC20 only");
		_;
	}*/

	modifier onlyBridge(){
		require(msg.sender == bridgeAddress, "not from bridge");
		_;
	}

    modifier onlyManager() {
        require(msg.sender == managerAddress, "caller is not the manager");
        _;
    }


	constructor(address bridgeAddr, address managerAddr, uint16 _management_fee10000, uint16 _success_fee10000, uint8 _exponent, string memory name, string memory symbol) ERC20(name, symbol) {
		initExportAssistant(bridgeAddr, managerAddr, _management_fee10000, _success_fee10000, _exponent, name, symbol);
	}

	function initExportAssistant(address bridgeAddr, address managerAddr, uint16 _management_fee10000, uint16 _success_fee10000, uint8 _exponent, string memory _name, string memory _symbol) public {
		require(address(governance) == address(0), "already initialized");
		name = _name;
		symbol = _symbol;
		bridgeAddress = bridgeAddr;
		management_fee10000 = _management_fee10000;
		success_fee10000 = _success_fee10000;
		require(_exponent == 1 || _exponent == 2 || _exponent == 4, "only exponents 1, 2 and 4 are supported");
		exponent = _exponent;
		ts = block.timestamp;
		(address tokenAddr, , , , , ) = Export(bridgeAddr).settings();
		tokenAddress = tokenAddr;
		if (tokenAddr != address(0))
			IERC20(tokenAddr).approve(bridgeAddr, type(uint).max);
		managerAddress = (managerAddr != address(0)) ? managerAddr : msg.sender;
	}


	function getGrossBalance() internal view returns (uint) {
		uint bal = (tokenAddress == address(0)) ? address(this).balance : IERC20(tokenAddress).balanceOf(address(this));
		return bal + balance_in_work;
	}

	function updateMFAndGetBalances(uint just_received_amount, bool update) internal returns (uint gross_balance, int net_balance) {
		gross_balance = getGrossBalance() - just_received_amount;
		uint new_mf = mf + gross_balance * management_fee10000 * (block.timestamp - ts)/(360*24*3600)/1e4;
		net_balance = int(gross_balance) - int(new_mf) - max(profit * int16(success_fee10000)/1e4, 0);
		// to save gas, we don't update mf when the balance doesn't change
		if (update) {
			mf = new_mf;
			ts = block.timestamp;
		}
	}


	// reentrancy is probably not a risk unless a malicious token makes a reentrant call from its balanceOf, so nonReentrant can be removed to save 10K gas
	function claim(string memory txid, uint32 txts, uint amount, int reward, string memory sender_address, address payable recipient_address, string memory data) onlyManager nonReentrant external {
		require(reward >= 0, "negative reward");
		uint claim_num = Export(bridgeAddress).last_claim_num() + 1;
		uint required_stake = Export(bridgeAddress).getRequiredStake(amount);
		uint paid_amount = amount - uint(reward);
		uint total = required_stake + paid_amount;
		{ // stack too deep
			(, int net_balance) = updateMFAndGetBalances(0, false);
			require(total < uint(type(int).max), "total too large");
			require(net_balance > 0, "no net balance");
			require(total <= uint(net_balance), "not enough balance");
			balances_in_work[claim_num] = total;
			balance_in_work += total;
		}

		emit NewClaimFor(claim_num, recipient_address, txid, txts, amount, reward, required_stake);

		Export(bridgeAddress).claim{value: tokenAddress == address(0) ? total : 0}(txid, txts, amount, reward, required_stake, sender_address, recipient_address, data);
	}

	// like in claim() above, nonReentrant is probably unnecessary
	function challenge(uint claim_num, CounterstakeLibrary.Side stake_on, uint stake) onlyManager nonReentrant external {
		(, int net_balance) = updateMFAndGetBalances(0, false);
		require(net_balance > 0, "no net balance");

		uint missing_stake = Export(bridgeAddress).getMissingStake(claim_num, stake_on);
		if (stake == 0 || stake > missing_stake) // send the stake without excess as we can't account for it
			stake = missing_stake;

		require(stake <= uint(net_balance), "not enough balance");
		Export(bridgeAddress).challenge{value: tokenAddress == address(0) ? stake : 0}(claim_num, stake_on, stake);
		balances_in_work[claim_num] += stake;
		balance_in_work += stake;
		emit AssistantChallenge(claim_num, stake_on, stake);
	}

	receive() external payable onlyETH {
		// silently receive Ether from claims
	}

	function onReceivedFromClaim(uint claim_num, uint claimed_amount, uint won_stake, string memory, address, string memory) onlyBridge override external {
		uint total = claimed_amount + won_stake;
		updateMFAndGetBalances(total, true); // total is already added to our balance

		uint invested = balances_in_work[claim_num];
		require(invested > 0, "BUG: I didn't stake in this claim?");

		if (total >= invested){
			uint this_profit = total - invested;
			require(this_profit < uint(type(int).max), "this_profit too large");
			profit += int(this_profit);
		}
		else { // avoid negative values
			uint loss = invested - total;
			require(loss < uint(type(int).max), "loss too large");
			profit -= int(loss);
		}

		balance_in_work -= invested;
		delete balances_in_work[claim_num];
	}

	// Record a loss, called by anybody.
	// Should be called only if I staked on the losing side only.
	// If I staked on the winning side too, the above function should be called.
	function recordLoss(uint claim_num) nonReentrant external {
		updateMFAndGetBalances(0, true);

		uint invested = balances_in_work[claim_num];
		require(invested > 0, "this claim is already accounted for");
		
		CounterstakeLibrary.Claim memory c = Export(bridgeAddress).getClaim(claim_num);
		require(c.amount > 0, "no such claim");
		require(block.timestamp > c.expiry_ts, "not expired yet");
		CounterstakeLibrary.Side opposite_outcome = c.current_outcome == CounterstakeLibrary.Side.yes ? CounterstakeLibrary.Side.no : CounterstakeLibrary.Side.yes;
		
		uint my_winning_stake = Export(bridgeAddress).stakes(claim_num, c.current_outcome, address(this));
		require(my_winning_stake == 0, "have a winning stake in this claim");
		
		uint my_losing_stake = Export(bridgeAddress).stakes(claim_num, opposite_outcome, address(this));
		require(my_losing_stake > 0, "no losing stake in this claim");
		require(invested >= my_losing_stake, "lost more than invested?");

		require(invested < uint(type(int).max), "loss too large");
		profit -= int(invested);

		balance_in_work -= invested;
		delete balances_in_work[claim_num];
	}


	// share issue/redeem functions

	function buyShares(uint stake_asset_amount) payable nonReentrant external {
		if (tokenAddress == address(0))
			require(msg.value == stake_asset_amount, "wrong amount received");
		else {
			require(msg.value == 0, "don't send ETH");
			require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), stake_asset_amount), "failed to pull to buy shares");
		}
		(uint gross_balance, int net_balance) = updateMFAndGetBalances(stake_asset_amount, true);
		require((gross_balance == 0) == (totalSupply() == 0), "bad init state");
		uint shares_amount;
		if (totalSupply() == 0)
			shares_amount = stake_asset_amount / 10**(18 - decimals());
		else {
			require(net_balance > 0, "no net balance");
			uint new_shares_supply = totalSupply() * getShares(uint(net_balance) + stake_asset_amount) / getShares(uint(net_balance));
			shares_amount = new_shares_supply - totalSupply();
		}
		_mint(msg.sender, shares_amount);

		// this should overflow now, not when we try to redeem. We won't see the error message, will revert while trying to evaluate the expression
		require((gross_balance + stake_asset_amount) * totalSupply()**exponent > 0, "too many shares, would overflow");
	}

	function redeemShares(uint shares_amount) nonReentrant external {
		uint old_shares_supply = totalSupply();

		_burn(msg.sender, shares_amount);
		(, int net_balance) = updateMFAndGetBalances(0, true);
		require(net_balance > 0, "negative net balance");
		require(uint(net_balance) > balance_in_work, "negative risk-free net balance");

		uint stake_asset_amount = (uint(net_balance) - balance_in_work) * (old_shares_supply**exponent - (old_shares_supply - shares_amount)**exponent) / old_shares_supply**exponent;
		payStakeTokens(msg.sender, stake_asset_amount);
	}


	// manager functions

	function withdrawManagementFee() onlyManager nonReentrant external {
		updateMFAndGetBalances(0, true);
		payStakeTokens(msg.sender, mf);
		mf = 0;
	}

	function withdrawSuccessFee() onlyManager nonReentrant external {
		updateMFAndGetBalances(0, true);
		require(profit > 0, "no profit yet");
		uint sf = uint(profit) * success_fee10000/1e4;
		payStakeTokens(msg.sender, sf);
		profit = 0;
	}

	// zero address is allowed
    function assignNewManager(address newManager) onlyManager external {
		emit NewManager(managerAddress, newManager);
        managerAddress = newManager;
    }


	// governance functions

	modifier onlyVotedValueContract(){
		require(governance.addressBelongsToGovernance(msg.sender), "not from voted value contract");
		_;
	}

	// would be happy to call this from the constructor but unfortunately `this` is not set at that time yet
	function setupGovernance(GovernanceFactory governanceFactory, VotedValueFactory ) external {
		require(address(governance) == address(0), "already initialized");
		governance = governanceFactory.createGovernance(address(this), address(this));

	}



	// helper functions

	function payStakeTokens(address to, uint amount) internal {
		if (tokenAddress == address(0))
			payable(to).transfer(amount);
		else
			require(IERC20(tokenAddress).transfer(to, amount), "failed to transfer");
	}

	function getShares(uint balance) view internal returns (uint) {
		if (exponent == 1)
			return balance;
		if (exponent == 2)
			return sqrt(balance);
		if (exponent == 4)
			return sqrt(sqrt(balance));
		revert("bad exponent");
	}

	// for large exponents, we need more room to **exponent without overflow
	function decimals() public view override returns (uint8) {
		return exponent > 2 ? 9 : 18;
	}

	function max(int a, int b) internal pure returns (int) {
		return a > b ? a : b;
	}

	// babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
	function sqrt(uint y) internal pure returns (uint z) {
		if (y > 3) {
			z = y;
			uint x = y / 2 + 1;
			while (x < z) {
				z = x;
				x = (y / x + x) / 2;
			}
		} else if (y != 0) {
			z = 1;
		}
	}

}





contract ImportAssistant is ERC20, ReentrancyGuard, CounterstakeReceiver {

	struct UintBalance {
		uint stake;
		uint image;
	}

	struct IntBalance {
		int stake;
		int image;
	}

	address public bridgeAddress;
	address public tokenAddress;
	address public managerAddress;

	uint16 public management_fee10000;
	uint16 public success_fee10000;

	uint8 public exponent;
	
	uint16 public swap_fee10000;

	uint public ts;
	IntBalance public profit;
	UintBalance public mf;
	UintBalance public balance_in_work;

	mapping(uint => UintBalance) public balances_in_work;

	Governance public governance;


	event NewClaimFor(uint claim_num, address for_address, string txid, uint32 txts, uint amount, int reward, uint stake);
	event AssistantChallenge(uint claim_num, CounterstakeLibrary.Side outcome, uint stake);
    event NewManager(address previousManager, address newManager);


	modifier onlyETH(){
		require(tokenAddress == address(0), "ETH only");
		_;
	}

/*	modifier onlyERC20(){
		require(tokenAddress != address(0), "ERC20 only");
		_;
	}*/

	modifier onlyBridge(){
		require(msg.sender == bridgeAddress, "not from bridge");
		_;
	}

    modifier onlyManager() {
        require(msg.sender == managerAddress, "caller is not the manager");
        _;
    }


	constructor(address bridgeAddr, address managerAddr, uint16 _management_fee10000, uint16 _success_fee10000, uint16 _swap_fee10000, uint8 _exponent, string memory name, string memory symbol) ERC20(name, symbol) {
		initImportAssistant(bridgeAddr, managerAddr, _management_fee10000, _success_fee10000, _swap_fee10000, _exponent, name, symbol);
	}

	function initImportAssistant(address bridgeAddr, address managerAddr, uint16 _management_fee10000, uint16 _success_fee10000, uint16 _swap_fee10000, uint8 _exponent, string memory _name, string memory _symbol) public {
		require(address(governance) == address(0), "already initialized");
		name = _name;
		symbol = _symbol;
		bridgeAddress = bridgeAddr;
		management_fee10000 = _management_fee10000;
		success_fee10000 = _success_fee10000;
		swap_fee10000 = _swap_fee10000;
		require(_exponent == 1 || _exponent == 2 || _exponent == 4, "only exponents 1, 2 and 4 are supported");
		exponent = _exponent;
		ts = block.timestamp;
		(address tokenAddr, , , , , ) = Import(bridgeAddr).settings();
		tokenAddress = tokenAddr;
		if (tokenAddr != address(0))
			IERC20(tokenAddr).approve(bridgeAddr, type(uint).max);
		managerAddress = (managerAddr != address(0)) ? managerAddr : msg.sender;
	}


	function getGrossBalance() internal view returns (UintBalance memory bal) {
		uint stake_bal = (tokenAddress == address(0)) ? address(this).balance : IERC20(tokenAddress).balanceOf(address(this));
		uint image_bal = IERC20(bridgeAddress).balanceOf(address(this));
		bal.stake = stake_bal + balance_in_work.stake;
		bal.image = image_bal + balance_in_work.image;
	}

	function updateMFAndGetBalances(uint just_received_stake_amount, uint just_received_image_amount, bool update) internal returns (UintBalance memory gross_balance, IntBalance memory net_balance) {
		gross_balance = getGrossBalance();
		gross_balance.stake -= just_received_stake_amount;
		gross_balance.image -= just_received_image_amount;
		uint new_mf_stake = mf.stake + gross_balance.stake * management_fee10000 * (block.timestamp - ts)/(360*24*3600)/1e4;
		uint new_mf_image = mf.image + gross_balance.image * management_fee10000 * (block.timestamp - ts)/(360*24*3600)/1e4;
		net_balance.stake = int(gross_balance.stake) - int(new_mf_stake) - max(profit.stake * int16(success_fee10000)/1e4, 0);
		net_balance.image = int(gross_balance.image) - int(new_mf_image) - max(profit.image * int16(success_fee10000)/1e4, 0);
		// to save gas, we don't update mf when the balances don't change
		if (update) {
			mf.stake = new_mf_stake;
			mf.image = new_mf_image;
			ts = block.timestamp;
		}
	}

	

	function claim(string memory txid, uint32 txts, uint amount, int reward, string memory sender_address, address payable recipient_address, string memory data) onlyManager nonReentrant external {
		require(reward >= 0, "negative reward");
		uint claim_num = Import(bridgeAddress).last_claim_num() + 1;
		uint required_stake = Import(bridgeAddress).getRequiredStake(amount);
		uint paid_amount = amount - uint(reward);
		require(required_stake < uint(type(int).max), "required_stake too large");
		require(paid_amount < uint(type(int).max), "paid_amount too large");
		{ // stack too deep
			(, IntBalance memory net_balance) = updateMFAndGetBalances(0, 0, false);
			require(net_balance.stake > 0, "no net balance in stake asset");
			require(net_balance.image > 0, "no net balance in image asset");
			require(required_stake <= uint(net_balance.stake), "not enough balance in stake asset");
			require(paid_amount <= uint(net_balance.image), "not enough balance in image asset");
			balances_in_work[claim_num] = UintBalance({stake: required_stake, image: paid_amount});
			balance_in_work.stake += required_stake;
			balance_in_work.image += paid_amount;
		}

		emit NewClaimFor(claim_num, recipient_address, txid, txts, amount, reward, required_stake);

		Import(bridgeAddress).claim{value: tokenAddress == address(0) ? required_stake : 0}(txid, txts, amount, reward, required_stake, sender_address, recipient_address, data);
	}

	function challenge(uint claim_num, CounterstakeLibrary.Side stake_on, uint stake) onlyManager nonReentrant external {
		(, IntBalance memory net_balance) = updateMFAndGetBalances(0, 0, false);
		require(net_balance.stake > 0, "no net balance");

		uint missing_stake = Import(bridgeAddress).getMissingStake(claim_num, stake_on);
		if (stake == 0 || stake > missing_stake) // send the stake without excess as we can't account for it
			stake = missing_stake;

		require(stake <= uint(net_balance.stake), "not enough balance");
		Import(bridgeAddress).challenge{value: tokenAddress == address(0) ? stake : 0}(claim_num, stake_on, stake);
		balances_in_work[claim_num].stake += stake;
		balance_in_work.stake += stake;
		emit AssistantChallenge(claim_num, stake_on, stake);
	}

	receive() external payable onlyETH {
		// silently receive Ether from claims
	}

	function onReceivedFromClaim(uint claim_num, uint claimed_amount, uint won_stake, string memory, address, string memory) onlyBridge override external {
		updateMFAndGetBalances(won_stake, claimed_amount, true); // this is already added to our balance

		UintBalance storage invested = balances_in_work[claim_num];
		require(invested.stake > 0, "BUG: I didn't stake in this claim?");

		if (won_stake >= invested.stake){
			uint this_profit = won_stake - invested.stake;
			require(this_profit < uint(type(int).max), "stake profit too large");
			profit.stake += int(this_profit);
		}
		else { // avoid negative values
			uint loss = invested.stake - won_stake;
			require(loss < uint(type(int).max), "stake loss too large");
			profit.stake -= int(loss);
		}

		if (claimed_amount >= invested.image){
			uint this_profit = claimed_amount - invested.image;
			require(this_profit < uint(type(int).max), "image profit too large");
			profit.image += int(this_profit);
		}
		else { // avoid negative values
			uint loss = invested.image - claimed_amount;
			require(loss < uint(type(int).max), "image loss too large");
			profit.image -= int(loss);
		}

		balance_in_work.stake -= invested.stake;
		balance_in_work.image -= invested.image;
		delete balances_in_work[claim_num];
	}

	// Record a loss, called by anybody.
	// Should be called only if I staked on the losing side only.
	// If I staked on the winning side too, the above function should be called.
	function recordLoss(uint claim_num) nonReentrant external {
		updateMFAndGetBalances(0, 0, true);

		UintBalance storage invested = balances_in_work[claim_num];
		require(invested.stake > 0, "this claim is already accounted for");
		
		CounterstakeLibrary.Claim memory c = Import(bridgeAddress).getClaim(claim_num);
		require(c.amount > 0, "no such claim");
		require(block.timestamp > c.expiry_ts, "not expired yet");
		CounterstakeLibrary.Side opposite_outcome = c.current_outcome == CounterstakeLibrary.Side.yes ? CounterstakeLibrary.Side.no : CounterstakeLibrary.Side.yes;
		
		uint my_winning_stake = Import(bridgeAddress).stakes(claim_num, c.current_outcome, address(this));
		require(my_winning_stake == 0, "have a winning stake in this claim");
		
		uint my_losing_stake = Import(bridgeAddress).stakes(claim_num, opposite_outcome, address(this));
		require(my_losing_stake > 0, "no losing stake in this claim");
		require(invested.stake == my_losing_stake, "BUG: losing stake mismatch");

		require(invested.stake < uint(type(int).max), "stake loss too large");
		require(invested.image < uint(type(int).max), "image loss too large");
		profit.stake -= int(invested.stake);
		profit.image -= int(invested.image);

		balance_in_work.stake -= invested.stake;
		balance_in_work.image -= invested.image;
		delete balances_in_work[claim_num];
	}


	// share issue/redeem functions

	function buyShares(uint stake_asset_amount, uint image_asset_amount) payable nonReentrant external {
		if (tokenAddress == address(0))
			require(msg.value == stake_asset_amount, "wrong amount received");
		else {
			require(msg.value == 0, "don't send ETH");
			require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), stake_asset_amount), "failed to pull stake");
		}
		require(IERC20(bridgeAddress).transferFrom(msg.sender, address(this), image_asset_amount), "failed to pull image");

		(UintBalance memory gross_balance, IntBalance memory net_balance) = updateMFAndGetBalances(stake_asset_amount, image_asset_amount, true);
		require((gross_balance.stake == 0) == (totalSupply() == 0), "bad init state");
		uint shares_amount;
		if (totalSupply() == 0){ // initial issue
			require(stake_asset_amount > 0 && image_asset_amount > 0, "must supply both assets for initial issue");
			shares_amount = getShares(stake_asset_amount, image_asset_amount) / 10**(18 - decimals());
		}
		else {
			require(net_balance.stake > 0, "no stake net balance");
			require(net_balance.image > 0, "no image net balance");
			uint new_shares_supply = totalSupply() * getShares(uint(net_balance.stake) + stake_asset_amount, uint(net_balance.image) + image_asset_amount) / getShares(uint(net_balance.stake), uint(net_balance.image));
			shares_amount = new_shares_supply - totalSupply();
		}
		_mint(msg.sender, shares_amount);

		// this should overflow now, not when we try to redeem. We won't see the error message, will revert while trying to evaluate the expression
		require(Math.max(gross_balance.stake + stake_asset_amount, gross_balance.image + image_asset_amount) * totalSupply()**exponent > 0, "too many shares, would overflow");
	}

	function redeemShares(uint shares_amount) nonReentrant external {
		uint old_shares_supply = totalSupply();

		_burn(msg.sender, shares_amount);
		(, IntBalance memory net_balance) = updateMFAndGetBalances(0, 0, true);
		require(net_balance.stake > 0, "negative net balance in stake asset");
		require(net_balance.image > 0, "negative net balance in image asset");
		require(uint(net_balance.stake) > balance_in_work.stake, "negative risk-free net balance in stake asset");
		require(uint(net_balance.image) > balance_in_work.image, "negative risk-free net balance in image asset");
		
		uint stake_asset_amount = (uint(net_balance.stake) - balance_in_work.stake) * (old_shares_supply**exponent - (old_shares_supply - shares_amount)**exponent) / old_shares_supply**exponent;
		stake_asset_amount -= stake_asset_amount * swap_fee10000/10000;

		uint image_asset_amount = (uint(net_balance.image) - balance_in_work.image) * (old_shares_supply**exponent - (old_shares_supply - shares_amount)**exponent) / old_shares_supply**exponent;
		image_asset_amount -= image_asset_amount * swap_fee10000/10000;
		
		payStakeTokens(msg.sender, stake_asset_amount);
		payImageTokens(msg.sender, image_asset_amount);
	}


	// swapping finctions

	function swapImage2Stake(uint image_asset_amount) nonReentrant external {
		require(IERC20(bridgeAddress).transferFrom(msg.sender, address(this), image_asset_amount), "failed to pull image");

		(, IntBalance memory net_balance) = updateMFAndGetBalances(0, image_asset_amount, false);
		require(net_balance.stake > 0, "negative net balance in stake asset");
		require(net_balance.image > 0, "negative net balance in image asset");
		require(uint(net_balance.stake) > balance_in_work.stake, "negative risk-free net balance in stake asset");

		uint stake_asset_amount = (uint(net_balance.stake) - balance_in_work.stake) * image_asset_amount / (uint(net_balance.image) + image_asset_amount);
		stake_asset_amount -= stake_asset_amount * swap_fee10000/10000;

		payStakeTokens(msg.sender, stake_asset_amount);
	}

	function swapStake2Image(uint stake_asset_amount) payable nonReentrant external {
		if (tokenAddress == address(0))
			require(msg.value == stake_asset_amount, "wrong amount received");
		else {
			require(msg.value == 0, "don't send ETH");
			require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), stake_asset_amount), "failed to pull stake");
		}

		(, IntBalance memory net_balance) = updateMFAndGetBalances(stake_asset_amount, 0, false);
		require(net_balance.stake > 0, "negative net balance in stake asset");
		require(net_balance.image > 0, "negative net balance in image asset");
		require(uint(net_balance.image) > balance_in_work.image, "negative risk-free net balance in image asset");

		uint image_asset_amount = (uint(net_balance.image) - balance_in_work.image) * stake_asset_amount / (uint(net_balance.stake) + stake_asset_amount);
		image_asset_amount -= image_asset_amount * swap_fee10000/10000;

		payImageTokens(msg.sender, image_asset_amount);
	}


	// manager functions

	function withdrawManagementFee() onlyManager nonReentrant external {
		updateMFAndGetBalances(0, 0, true);
		payStakeTokens(msg.sender, mf.stake);
		payImageTokens(msg.sender, mf.image);
		mf.stake = 0;
		mf.image = 0;
	}

	function withdrawSuccessFee() onlyManager nonReentrant external {
		updateMFAndGetBalances(0, 0, true);
		if (profit.stake > 0) {
			uint sf = uint(profit.stake) * success_fee10000/1e4;
			payStakeTokens(msg.sender, sf);
			profit.stake = 0;
		}
		if (profit.image > 0) {
			uint sf = uint(profit.image) * success_fee10000/1e4;
			payImageTokens(msg.sender, sf);
			profit.image = 0;
		}
	}

	// zero address is allowed
    function assignNewManager(address newManager) onlyManager external {
		emit NewManager(managerAddress, newManager);
        managerAddress = newManager;
    }


	// governance functions

	modifier onlyVotedValueContract(){
		require(governance.addressBelongsToGovernance(msg.sender), "not from voted value contract");
		_;
	}

	// would be happy to call this from the constructor but unfortunately `this` is not set at that time yet
	function setupGovernance(GovernanceFactory governanceFactory, VotedValueFactory votedValueFactory) external {
		require(address(governance) == address(0), "already initialized");
		governance = governanceFactory.createGovernance(address(this), address(this));

		governance.addVotedValue("swap_fee10000", votedValueFactory.createVotedValueUint(governance, swap_fee10000, this.validateSwapFee, this.setSwapFee));
	}



	function validateSwapFee(uint _swap_fee10000) pure external {
		require(_swap_fee10000 < 10000, "bad swap fee");
	}

	function setSwapFee(uint _swap_fee10000) onlyVotedValueContract external {
		swap_fee10000 = uint16(_swap_fee10000);
	}


	// helper functions

	function payStakeTokens(address to, uint amount) internal {
		if (tokenAddress == address(0))
			payable(to).transfer(amount);
		else
			require(IERC20(tokenAddress).transfer(to, amount), "failed to transfer stake asset");
	}

	function payImageTokens(address to, uint amount) internal {
		require(IERC20(bridgeAddress).transfer(to, amount), "failed to transfer image asset");
	}

	function getShares(uint stake_balance, uint image_balance) view internal returns (uint) {
		uint gm = sqrt(stake_balance * image_balance);
		if (exponent == 1)
			return gm;
		if (exponent == 2)
			return sqrt(gm);
		if (exponent == 4)
			return sqrt(sqrt(gm));
		revert("bad exponent");
	}

	// for large exponents, we need more room to **exponent without overflow
	function decimals() public view override returns (uint8) {
		return exponent > 2 ? 9 : 18;
	}


	function max(int a, int b) internal pure returns (int) {
		return a > b ? a : b;
	}

	// babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
	function sqrt(uint y) internal pure returns (uint z) {
		if (y > 3) {
			z = y;
			uint x = y / 2 + 1;
			while (x < z) {
				z = x;
				x = (y / x + x) / 2;
			}
		} else if (y != 0) {
			z = 1;
		}
	}

}






contract AssistantFactory {

	event NewExportAssistant(address contractAddress, address bridgeAddress, address manager, string symbol);
	event NewImportAssistant(address contractAddress, address bridgeAddress, address manager, string symbol);

	address public exportAssistantFactory;
	address public importAssistantFactory;

	GovernanceFactory governanceFactory;
	VotedValueFactory votedValueFactory;

	constructor(address _exportAssistantFactory, address _importAssistantFactory, GovernanceFactory _governanceFactory, VotedValueFactory _votedValueFactory) {
		exportAssistantFactory = _exportAssistantFactory;
		importAssistantFactory = _importAssistantFactory;
		governanceFactory = _governanceFactory;
		votedValueFactory = _votedValueFactory;
	}

	function createExportAssistant(
		address bridgeAddr, address managerAddr, uint16 _management_fee10000, uint16 _success_fee10000, uint8 _exponent, string memory name, string memory symbol
	) external returns (ExportAssistant exportAssistant) {
		exportAssistant = ExportAssistant(payable(Clones.clone(exportAssistantFactory)));
		exportAssistant.initExportAssistant(bridgeAddr, managerAddr, _management_fee10000, _success_fee10000, _exponent, name, symbol);
		exportAssistant.setupGovernance(governanceFactory, votedValueFactory);
		emit NewExportAssistant(address(exportAssistant), bridgeAddr, managerAddr, symbol);
	}

	function createImportAssistant(
		address bridgeAddr, address managerAddr, uint16 _management_fee10000, uint16 _success_fee10000, uint16 _swap_fee10000, uint8 _exponent, string memory name, string memory symbol
	) external returns (ImportAssistant importAssistant) {
		importAssistant = ImportAssistant(payable(Clones.clone(importAssistantFactory)));
		importAssistant.initImportAssistant(bridgeAddr, managerAddr, _management_fee10000, _success_fee10000, _swap_fee10000, _exponent, name, symbol);
		importAssistant.setupGovernance(governanceFactory, votedValueFactory);
		emit NewImportAssistant(address(importAssistant), bridgeAddr, managerAddr, symbol);
	}


}