/**
 *Submitted for verification at Etherscan.io on 2021-06-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;


/**
 * @dev Standard math utilities missing in the Solidity language.
 */




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