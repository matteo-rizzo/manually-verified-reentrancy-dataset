/**

 *Submitted for verification at Etherscan.io on 2019-03-21

*/



pragma solidity ^0.4.24;



/*

*   gibmireinbier - Full Stack Blockchain Developer

*   0xA4a799086aE18D7db6C4b57f496B081b44888888

*   [emailÂ protected]

*/



contract Reward {

    using SafeMath for uint256;



    event NewReward(address indexed _lucker, uint256[5] _info);

    

    modifier onlyOwner() {

        require(msg.sender == address(lotteryContract), "This is just log for lottery contract");

        _;

    }



    modifier claimable() {

        require(

            rest > 1 && 

            block.number > lastBlock &&

            lastRoundClaim[msg.sender] < lastRoundId,

            "out of stock in this round, block or already claimed");

        _;

    }



/*     

    enum RewardType {

        Minor, 0

        Major, 1

        Grand, 2

        Bounty 3

        SBounty 4 // smal bounty

    } 

*/



    struct Rewards {

        address lucker;

        uint256 time;

        uint256 rId;

        uint256 value;

        uint256 winNumber;

        uint256 rewardType;

    }



    Rewards[] public rewardList;

    // reward array by address

    mapping( address => uint256[]) public pReward;

    // reward sum by address

    mapping( address => uint256) public pRewardedSum;

    // reward sum by address, round

    mapping( address => mapping(uint256 => uint256)) public pRewardedSumPerRound;

    // reward sum by round

    mapping( uint256 => uint256) public rRewardedSum;

    // reward sum all round, all addresses

    uint256 public rewardedSum;

    

    // last claimed round by address to check timeout

    // timeout balance will be pushed to dividends

    mapping(address => uint256) lastRoundClaim;



    LotteryInterface lotteryContract;



    //////////////////////////////////////////////////////////

    

    // rest times for sBounty, small bountys free for all (round-players) after each round

    uint256 public rest = 0;

    // last block that sBounty claimed, to prevent 2 time claimed in same block

    uint256 public lastBlock = 0;

    // sBounty will be saved in logs of last round

    // new round will be started after sBountys pushed

    uint256 public lastRoundId;



    constructor (address _devTeam)

        public

    {

        // register address in network

        DevTeamInterface(_devTeam).setRewardAddress(address(this));

    }



    // _contract = [f2mAddress, bankAddress, citizenAddress, lotteryAddress, rewardAddress, whitelistAddress];

    function joinNetwork(address[6] _contract)

        public

    {

        require((address(lotteryContract) == 0x0),"already setup");

        lotteryContract = LotteryInterface(_contract[3]);

    }



    // sBounty program

    // rules :

    // 1. accept only calls from lottery contract

    // 2. one claim per block

    // 3. one claim per address (reset each round)



    function getSBounty()

        public

        view

        returns(uint256, uint256, uint256)

    {

        uint256 sBountyAmount = rest < 2 ? 0 : address(this).balance / (rest-1);

        return (rest, sBountyAmount, lastRoundId);

    }



    // pushed from lottery contract only

    function resetCounter(uint256 _curRoundId) 

        public 

        onlyOwner() 

    {

        rest = 8;

        lastBlock = block.number;

        lastRoundId = _curRoundId;

    }



    function claim()

        public

        claimable()

    {

        address _sender = msg.sender;

        lastBlock = block.number;

        lastRoundClaim[_sender] = lastRoundId;

        rest = rest - 1;

        uint256 claimAmount = lotteryContract.sBountyClaim(_sender);

        mintRewardCore(

            _sender,

            lastRoundId,

            0,

            0,

            0,

            claimAmount,

            4

        );

    }



    // rewards sealed by lottery contract

    function mintReward(

        address _lucker,

        uint256 _curRoundId,

        uint256 _winNr,

        uint256 _tNumberFrom,

        uint256 _tNumberTo,

        uint256 _value,

        uint256 _rewardType)

        public

        onlyOwner()

    {

        mintRewardCore(

            _lucker,

            _curRoundId,

            _winNr,

            _tNumberFrom,

            _tNumberTo,

            _value,

            _rewardType);

    }



    // reward logs generator

    function mintRewardCore(

        address _lucker,

        uint256 _curRoundId,

        uint256 _winNr,

        uint256 _tNumberFrom,

        uint256 _tNumberTo,

        uint256 _value,

        uint256 _rewardType)

        private

    {

        Rewards memory _reward;

        _reward.lucker = _lucker;

        _reward.time = block.timestamp;

        _reward.rId = _curRoundId;

        _reward.value = _value;



        // get winning number if rewardType is not bounty or sBounty

        // seed = rewardList.length to be sure that seed changed after

        // every reward minting

        if (_winNr > 0) {

            _reward.winNumber = _winNr;

        } else 

        if (_rewardType < 3)

            _reward.winNumber = getWinNumberBySlot(_tNumberFrom, _tNumberTo);



        _reward.rewardType = _rewardType;

        rewardList.push(_reward);

        pReward[_lucker].push(rewardList.length - 1);

        // reward sum logs

        pRewardedSum[_lucker] += _value;

        rRewardedSum[_curRoundId] += _value;

        rewardedSum += _value;

        pRewardedSumPerRound[_lucker][_curRoundId] += _value;

        emit NewReward(_reward.lucker, [_reward.time, _reward.rId, _reward.value, _reward.winNumber, uint256(_reward.rewardType)]);

    }



    function getWinNumberBySlot(uint256 _tNumberFrom, uint256 _tNumberTo)

        public

        view

        returns(uint256)

    {

        //uint256 _seed = uint256(keccak256(rewardList.length));

        uint256 _seed = rewardList.length * block.number + block.timestamp;

        // get random number in range (1, _to - _from + 1)

        uint256 _winNr = Helper.getRandom(_seed, _tNumberTo + 1 - _tNumberFrom);

        return _tNumberFrom + _winNr - 1;

    }



    function getPRewardLength(address _sender)

        public

        view

        returns(uint256)

    {

        return pReward[_sender].length;

    }



    function getRewardListLength()

        public

        view

        returns(uint256)

    {

        return rewardList.length;

    }



    function getPRewardId(address _sender, uint256 i)

        public

        view

        returns(uint256)

    {

        return pReward[_sender][i];

    }



    function getPRewardedSumByRound(uint256 _rId, address _buyer)

        public

        view

        returns(uint256)

    {

        return pRewardedSumPerRound[_buyer][_rId];

    }



    function getRewardedSumByRound(uint256 _rId)

        public

        view

        returns(uint256)

    {

        return rRewardedSum[_rId];

    }



    function getRewardInfo(uint256 _id)

        public

        view

        returns(

            address,

            uint256,

            uint256,

            uint256,

            uint256,

            uint256

        )

    {

        Rewards memory _reward = rewardList[_id];

        return (

            _reward.lucker,

            _reward.winNumber,

            _reward.time,

            _reward.rId,

            _reward.value,

            _reward.rewardType

        );

    }

}

















/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

