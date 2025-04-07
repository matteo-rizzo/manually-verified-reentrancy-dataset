/**

 *Submitted for verification at Etherscan.io on 2018-11-02

*/



pragma solidity 0.4.25;















contract InterfaceContracts is Ownable {

    InterfaceContracts public _internalMod;

    

    function setModifierContract (address _t) onlyOwner public {

        _internalMod = InterfaceContracts(_t);

    }



    modifier onlyMiningContract() {

      require(msg.sender == _internalMod._contract_miner(), "Wrong sender");

          _;

      }



    modifier onlyTokenContract() {

      require(msg.sender == _internalMod._contract_token(), "Wrong sender");

      _;

    }

    

    modifier onlyMasternodeContract() {

      require(msg.sender == _internalMod._contract_masternode(), "Wrong sender");

      _;

    }

    

    modifier onlyVotingOrOwner() {

      require(msg.sender == _internalMod._contract_voting() || msg.sender == owner, "Wrong sender");

      _;

    }

    

    modifier onlyVotingContract() {

      require(msg.sender == _internalMod._contract_voting() || msg.sender == owner, "Wrong sender");

      _;

    }

      

    function _contract_voting () public view returns (address) {

        return _internalMod._contract_voting();

    }

    

    function _contract_masternode () public view returns (address) {

        return _internalMod._contract_masternode();

    }

    

    function _contract_token () public view returns (address) {

        return _internalMod._contract_token();

    }

    

    function _contract_miner () public view returns (address) {

        return _internalMod._contract_miner();

    }

}















contract AbstractERC918 is EIP918Interface {



    // generate a new challenge number after a new reward is minted

    bytes32 public challengeNumber;



    // the current mining difficulty

    uint public difficulty;



    // cumulative counter of the total minted tokens

    uint public tokensMinted;



    // track read only minting statistics

    struct Statistics {

        address lastRewardTo;

        uint lastRewardAmount;

        uint lastRewardEthBlockNumber;

        uint lastRewardTimestamp;

    }



    Statistics public statistics;



    /*

     * Externally facing mint function that is called by miners to validate challenge digests, calculate reward,

     * populate statistics, mutate epoch variables and adjust the solution difficulty as required. Once complete,

     * a Mint event is emitted before returning a success indicator.

     **/

    function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success);





    /*

     * Internal interface function _hash. Overide in implementation to define hashing algorithm and

     * validation

     **/

    function _hash(uint256 nonce, bytes32 challenge_digest) internal returns (bytes32 digest);



    /*

     * Internal interface function _reward. Overide in implementation to calculate and return reward

     * amount

     **/

    function _reward() internal returns (uint);



    /*

     * Internal interface function _newEpoch. Overide in implementation to define a cutpoint for mutating

     * mining variables in preparation for the next epoch

     **/

    function _newEpoch(uint256 nonce) internal returns (uint);



    /*

     * Internal interface function _adjustDifficulty. Overide in implementation to adjust the difficulty

     * of the mining as required

     **/

    function _adjustDifficulty() internal returns (uint);



}



contract CaelumAbstractMiner is InterfaceContracts, AbstractERC918 {

    /**

     * CaelumMiner contract.

     *

     * We need to make sure the contract is 100% compatible when using the EIP918Interface.

     * This contract is an abstract Caelum miner contract.

     *

     * Function 'mint', and '_reward' are overriden in the CaelumMiner contract.

     * Function '_reward_masternode' is added and needs to be overriden in the CaelumMiner contract.

     */



    using SafeMath for uint;

    using ExtendedMath for uint;



    uint256 public totalSupply = 2100000000000000;



    uint public latestDifficultyPeriodStarted;

    uint public epochCount;

    uint public baseMiningReward = 50;

    uint public blocksPerReadjustment = 512;

    uint public _MINIMUM_TARGET = 2 ** 16;

    uint public _MAXIMUM_TARGET = 2 ** 234;

    uint public rewardEra = 0;



    uint public maxSupplyForEra;

    uint public MAX_REWARD_ERA = 39;

    uint public MINING_RATE_FACTOR = 60; //mint the token 60 times less often than ether



    uint public MAX_ADJUSTMENT_PERCENT = 100;

    uint public TARGET_DIVISOR = 2000;

    uint public QUOTIENT_LIMIT = TARGET_DIVISOR.div(2);

    mapping(bytes32 => bytes32) solutionForChallenge;

    mapping(address => mapping(address => uint)) allowed;



    bytes32 public challengeNumber;

    uint public difficulty;

    uint public tokensMinted;



    Statistics public statistics;



    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

    event RewardMasternode(address candidate, uint amount);



    constructor() public {

        tokensMinted = 0;

        maxSupplyForEra = totalSupply.div(2);

        difficulty = _MAXIMUM_TARGET;

        latestDifficultyPeriodStarted = block.number;

        _newEpoch(0);

    }



    function _newEpoch(uint256 nonce) internal returns(uint) {

        if (tokensMinted.add(getMiningReward()) > maxSupplyForEra && rewardEra < MAX_REWARD_ERA) {

            rewardEra = rewardEra + 1;

        }

        maxSupplyForEra = totalSupply - totalSupply.div(2 ** (rewardEra + 1));

        epochCount = epochCount.add(1);

        challengeNumber = blockhash(block.number - 1);

        return (epochCount);

    }



    function mint(uint256 nonce, bytes32 challenge_digest) public returns(bool success);



    function _hash(uint256 nonce, bytes32 challenge_digest) internal returns(bytes32 digest) {

        digest = keccak256(challengeNumber, msg.sender, nonce);

        if (digest != challenge_digest) revert();

        if (uint256(digest) > difficulty) revert();

        bytes32 solution = solutionForChallenge[challengeNumber];

        solutionForChallenge[challengeNumber] = digest;

        if (solution != 0x0) revert(); //prevent the same answer from awarding twice

    }



    function _reward() internal returns(uint);



    function _reward_masternode() internal returns(uint);



    function _adjustDifficulty() internal returns(uint) {

        //every so often, readjust difficulty. Dont readjust when deploying

        if (epochCount % blocksPerReadjustment != 0) {

            return difficulty;

        }



        uint ethBlocksSinceLastDifficultyPeriod = block.number - latestDifficultyPeriodStarted;

        //assume 360 ethereum blocks per hour

        //we want miners to spend 10 minutes to mine each 'block', about 60 ethereum blocks = one 0xbitcoin epoch

        uint epochsMined = blocksPerReadjustment;

        uint targetEthBlocksPerDiffPeriod = epochsMined * MINING_RATE_FACTOR;

        //if there were less eth blocks passed in time than expected

        if (ethBlocksSinceLastDifficultyPeriod < targetEthBlocksPerDiffPeriod) {

            uint excess_block_pct = (targetEthBlocksPerDiffPeriod.mul(MAX_ADJUSTMENT_PERCENT)).div(ethBlocksSinceLastDifficultyPeriod);

            uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(QUOTIENT_LIMIT);

            // If there were 5% more blocks mined than expected then this is 5.  If there were 100% more blocks mined than expected then this is 100.

            //make it harder

            difficulty = difficulty.sub(difficulty.div(TARGET_DIVISOR).mul(excess_block_pct_extra)); //by up to 50 %

        } else {

            uint shortage_block_pct = (ethBlocksSinceLastDifficultyPeriod.mul(MAX_ADJUSTMENT_PERCENT)).div(targetEthBlocksPerDiffPeriod);

            uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(QUOTIENT_LIMIT); //always between 0 and 1000

            //make it easier

            difficulty = difficulty.add(difficulty.div(TARGET_DIVISOR).mul(shortage_block_pct_extra)); //by up to 50 %

        }

        latestDifficultyPeriodStarted = block.number;

        if (difficulty < _MINIMUM_TARGET) //very difficult

        {

            difficulty = _MINIMUM_TARGET;

        }

        if (difficulty > _MAXIMUM_TARGET) //very easy

        {

            difficulty = _MAXIMUM_TARGET;

        }

    }



    function getChallengeNumber() public view returns(bytes32) {

        return challengeNumber;

    }



    function getMiningDifficulty() public view returns(uint) {

        return _MAXIMUM_TARGET.div(difficulty);

    }



    function getMiningTarget() public view returns(uint) {

        return difficulty;

    }



    function getMiningReward() public view returns(uint) {

        return (baseMiningReward * 1e8).div(2 ** rewardEra);

    }



    function getMintDigest(

        uint256 nonce,

        bytes32 challenge_digest,

        bytes32 challenge_number

    )

    public view returns(bytes32 digesttest) {

        bytes32 digest = keccak256(challenge_number, msg.sender, nonce);

        return digest;

    }



    function checkMintSolution(

        uint256 nonce,

        bytes32 challenge_digest,

        bytes32 challenge_number,

        uint testTarget

    )

    public view returns(bool success) {

        bytes32 digest = keccak256(challenge_number, msg.sender, nonce);

        if (uint256(digest) > testTarget) revert();

        return (digest == challenge_digest);

    }

}



contract CaelumMiner is CaelumAbstractMiner {



    ICaelumToken public tokenInterface;

    ICaelumMasternode public masternodeInterface;

    bool public ACTIVE_STATE = false;

    uint swapStartedBlock = now;

    uint public gasPriceLimit = 999;



    /**

     * @dev Allows the owner to set a gas limit on submitting solutions.

     * courtesy of KiwiToken.

     * See https://github.com/liberation-online/MineableToken for more details why.

     */



    modifier checkGasPrice(uint txnGasPrice) {

        require(txnGasPrice <= gasPriceLimit * 1000000000, "Gas above gwei limit!");

        _;

    }



    event GasPriceSet(uint8 _gasPrice);



    function setGasPriceLimit(uint8 _gasPrice) onlyOwner public {

        require(_gasPrice > 0);

        gasPriceLimit = _gasPrice;



        emit GasPriceSet(_gasPrice); //emit event

    }



    function setTokenContract() internal {

        tokenInterface = ICaelumToken(_contract_token());

    }



    function setMasternodeContract() internal {

        masternodeInterface = ICaelumMasternode(_contract_masternode());

    }



    /**

     * Override; For some reason, truffle testing does not recognize function.

     */

    function setModifierContract (address _contract) onlyOwner public {

        require (now <= swapStartedBlock + 10 days);

        _internalMod = InterfaceContracts(_contract);

        setMasternodeContract();

        setTokenContract();

    }



    /**

    * @dev Move the voting away from token. All votes will be made from the voting

    */

    function VoteModifierContract (address _contract) onlyVotingContract external {

        //_internalMod = CaelumModifierAbstract(_contract);

        _internalMod = InterfaceContracts(_contract);

        setMasternodeContract();

        setTokenContract();

    }



    function mint(uint256 nonce, bytes32 challenge_digest) checkGasPrice(tx.gasprice) public returns(bool success) {

        require(ACTIVE_STATE);



        _hash(nonce, challenge_digest);



        masternodeInterface._externalArrangeFlow();



        uint rewardAmount = _reward();

        uint rewardMasternode = _reward_masternode();



        tokensMinted += rewardAmount.add(rewardMasternode);



        uint epochCounter = _newEpoch(nonce);



        _adjustDifficulty();



        statistics = Statistics(msg.sender, rewardAmount, block.number, now);



        emit Mint(msg.sender, rewardAmount, epochCounter, challengeNumber);



        return true;

    }



    function _reward() internal returns(uint) {



        uint _pow = masternodeInterface.rewardsProofOfWork();



        tokenInterface.rewardExternal(msg.sender, 1 * 1e8);



        return _pow;

    }



    function _reward_masternode() internal returns(uint) {



        uint _mnReward = masternodeInterface.rewardsMasternode();

        if (masternodeInterface.masternodeIDcounter() == 0) return 0;



        address _mnCandidate = masternodeInterface.getUserFromID(masternodeInterface.masternodeCandidate()); // userByIndex[masternodeCandidate].accountOwner;

        if (_mnCandidate == 0x0) return 0;



        tokenInterface.rewardExternal(_mnCandidate, _mnReward);



        emit RewardMasternode(_mnCandidate, _mnReward);



        return _mnReward;

    }



    /**

     * @dev Fetch data from the actual reward. We do this to prevent pools payout out

     * the global reward instead of the calculated ones.

     * By default, pools fetch the `getMiningReward()` value and will payout this amount.

     */

    function getMiningRewardForPool() public view returns(uint) {

        return masternodeInterface.rewardsProofOfWork();

    }



    function getMiningReward() public view returns(uint) {

        return (baseMiningReward * 1e8).div(2 ** rewardEra);

    }



    function contractProgress() public view returns

        (

            uint epoch,

            uint candidate,

            uint round,

            uint miningepoch,

            uint globalreward,

            uint powreward,

            uint masternodereward,

            uint usercounter

        ) {

            return ICaelumMasternode(_contract_masternode()).contractProgress();



        }



    /**

     * @dev Call this function prior to mining to copy all old contract values.

     * This included minted tokens, difficulty, etc..

     */



    function getDataFromContract(address _previous_contract) onlyOwner public {

        require(ACTIVE_STATE == false);

        require(_contract_token() != 0);

        require(_contract_masternode() != 0);



        CaelumAbstractMiner prev = CaelumAbstractMiner(_previous_contract);

        difficulty = prev.difficulty();

        rewardEra = prev.rewardEra();

        MINING_RATE_FACTOR = prev.MINING_RATE_FACTOR();

        maxSupplyForEra = prev.maxSupplyForEra();

        tokensMinted = prev.tokensMinted();

        epochCount = prev.epochCount();



        ACTIVE_STATE = true;

    }

    

    function balanceOf(address _owner) public view returns(uint256) {

        return tokenInterface.balanceOf(_owner);

    }

}