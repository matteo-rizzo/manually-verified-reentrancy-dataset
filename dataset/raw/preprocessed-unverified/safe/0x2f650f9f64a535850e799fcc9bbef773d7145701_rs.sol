/**
 *Submitted for verification at Etherscan.io on 2020-10-07
*/

pragma solidity ^0.5.0;





contract IDCOREVote {
    using SafeMath for uint256;

    uint8 public constant MAX_VOTERS_PER_ITEM = 50;

    uint16 public constant MIN_VOTING_VALUE = 50; // 50% (x0.5 times)
    uint16 public constant MAX_VOTING_VALUE = 200; // 200% (x2 times)

    mapping(address => mapping(uint256 => uint8)) public numVoters; // poolAddress -> votingItem (periodFinish) -> numVoters (the number of voters in this round)
    mapping(address => mapping(uint256 => address[MAX_VOTERS_PER_ITEM])) public voters; // poolAddress -> votingItem (periodFinish) -> voters (array)
    mapping(address => mapping(uint256 => mapping(address => bool))) public isInTopVoters; // poolAddress -> votingItem (periodFinish) -> isInTopVoters (map: voter -> in_top (true/false))
    mapping(address => mapping(uint256 => mapping(address => uint16))) public voter2VotingValue; // poolAddress -> votingItem (periodFinish) -> voter2VotingValue (map: voter -> voting value)

    event Voted(address poolAddress, address indexed user, uint256 votingItem, uint16 votingValue);

    function isVotable(address poolAddress, address account, uint256 votingItem) public view returns (bool) {
        // already voted
        if (voter2VotingValue[poolAddress][votingItem][account] > 0) return false;

        DCORERewards rewards = DCORERewards(poolAddress);
        // hasn't any staking power
        if (rewards.stakingPower(account) == 0) return false;

        // number of voters is under limit still
        if (numVoters[poolAddress][votingItem] < MAX_VOTERS_PER_ITEM) return true;
        for (uint8 i = 0; i < numVoters[poolAddress][votingItem]; i++) {
            if (rewards.stakingPower(voters[poolAddress][votingItem][i]) < rewards.stakingPower(account)) return true; // there is some voters has lower staking power
        }

        return false;
    }

    function averageVotingValue(address poolAddress, uint256 votingItem) public view returns (uint16) {
        if (numVoters[poolAddress][votingItem] == 0) return 0; // no votes
        uint256 totalStakingPower = 0;
        uint256 totalWeightVotingValue = 0;
        DCORERewards rewards = DCORERewards(poolAddress);
        for (uint8 i = 0; i < numVoters[poolAddress][votingItem]; i++) {
            address voter = voters[poolAddress][votingItem][i];
            totalStakingPower = totalStakingPower.add(rewards.stakingPower(voter));
            totalWeightVotingValue = totalWeightVotingValue.add(rewards.stakingPower(voter).mul(voter2VotingValue[poolAddress][votingItem][voter]));
        }
        return (uint16) (totalWeightVotingValue.div(totalStakingPower));
    }

    function vote(address poolAddress, uint256 votingItem, uint16 votingValue) public {
        require(votingValue >= MIN_VOTING_VALUE, "votingValue is smaller than MIN_VOTING_VALUE");
        require(votingValue <= MAX_VOTING_VALUE, "votingValue is greater than MAX_VOTING_VALUE");
        if (!isInTopVoters[poolAddress][votingItem][msg.sender]) {
            require(isVotable(poolAddress, msg.sender, votingItem), "This account is not votable");
            uint8 voterIndex = MAX_VOTERS_PER_ITEM;
            if (numVoters[poolAddress][votingItem] < MAX_VOTERS_PER_ITEM) {
                voterIndex = numVoters[poolAddress][votingItem];
            } else {
                DCORERewards rewards = DCORERewards(poolAddress);
                uint256 minStakingPower = rewards.stakingPower(msg.sender);
                for (uint8 i = 0; i < numVoters[poolAddress][votingItem]; i++) {
                    if (rewards.stakingPower(voters[poolAddress][votingItem][i]) < minStakingPower) {
                        voterIndex = i;
                        minStakingPower = rewards.stakingPower(voters[poolAddress][votingItem][i]);
                    }
                }
            }
            if (voterIndex < MAX_VOTERS_PER_ITEM) {
                if (voterIndex < numVoters[poolAddress][votingItem]) {
                    isInTopVoters[poolAddress][votingItem][voters[poolAddress][votingItem][voterIndex]] = false; // remove lower power previous voter
                } else {
                    ++numVoters[poolAddress][votingItem];
                }
                isInTopVoters[poolAddress][votingItem][msg.sender] = true;
                voters[poolAddress][votingItem][voterIndex] = msg.sender;
            }
        }
        voter2VotingValue[poolAddress][votingItem][msg.sender] = votingValue;
        emit Voted(poolAddress, msg.sender, votingItem, votingValue);
    }
}