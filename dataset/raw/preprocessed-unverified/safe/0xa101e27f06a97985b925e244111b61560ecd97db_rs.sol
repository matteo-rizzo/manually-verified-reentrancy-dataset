/**

 *Submitted for verification at Etherscan.io on 2018-09-14

*/



pragma solidity 0.4.24;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */







/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





/**

 * @title BITTOStandard

 * @dev the interface of BITTOStandard

 */

 

contract BITTOStandard {

    uint256 public stakeStartTime;

    uint256 public stakeMinAge;

    uint256 public stakeMaxAge;

    function mint() public returns (bool);

    function coinAge() constant public returns (uint256);

    function annualInterest() constant public returns (uint256);

    event Mint(address indexed _address, uint _reward);

}







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract BITTO is IERC20, BITTOStandard, Ownable {

    using SafeMath for uint256;



    string public name = "BITTO";

    string public symbol = "BITTO";

    uint public decimals = 18;



    uint public chainStartTime; //chain start time

    uint public chainStartBlockNumber; //chain start block number

    uint public stakeStartTime; //stake start time

    uint public stakeMinAge = 10 days; // minimum age for coin age: 10D

    uint public stakeMaxAge = 180 days; // stake age of full weight: 180D



    uint public totalSupply;

    uint public maxTotalSupply;

    uint public totalInitialSupply;



    uint constant MIN_STAKING = 5000;  // minium amount of token to stake

    uint constant STAKE_START_TIME = 1537228800;  // 2018.9.18

    uint constant STEP1_ENDTIME = 1552780800;  //  2019.3.17

    uint constant STEP2_ENDTIME = 1568332800;  // 2019.9.13

    uint constant STEP3_ENDTIME = 1583884800;  // 2020.3.11

    uint constant STEP4_ENDTIME = 1599436800; // 2020.9.7

    uint constant STEP5_ENDTIME = 1914969600; // 2030.9.7



    struct Period {

        uint start;

        uint end;

        uint interest;

    }



    mapping (uint => Period) periods;



    mapping(address => bool) public noPOSRewards;



    struct transferInStruct {

        uint128 amount;

        uint64 time;

    }



    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    mapping(address => transferInStruct[]) transferIns;



    event Burn(address indexed burner, uint256 value);



    /**

     * @dev Fix for the ERC20 short address attack.

     */

    modifier onlyPayloadSize(uint size) {

        require(msg.data.length >= size + 4);

        _;

    }



    modifier canPoSMint() {

        require(totalSupply < maxTotalSupply);

        _;

    }



    constructor() public {

        // 5 mil is reserved for POS rewards

        maxTotalSupply = 223 * 10**23; // 22.3 Mil.

        totalInitialSupply = 173 * 10**23; // 17.3 Mil. 10 mil = crowdsale, 7.3 team account



        chainStartTime = now;

        chainStartBlockNumber = block.number;



        balances[msg.sender] = totalInitialSupply;

        totalSupply = totalInitialSupply;



        // 4 periods for 2 years

        stakeStartTime = 1537228800;

        

        periods[0] = Period(STAKE_START_TIME, STEP1_ENDTIME, 65 * 10 ** 18);

        periods[1] = Period(STEP1_ENDTIME, STEP2_ENDTIME, 34 * 10 ** 18);

        periods[2] = Period(STEP2_ENDTIME, STEP3_ENDTIME, 20 * 10 ** 18);

        periods[3] = Period(STEP3_ENDTIME, STEP4_ENDTIME, 134 * 10 ** 16);

        periods[4] = Period(STEP4_ENDTIME, STEP5_ENDTIME, 134 * 10 ** 16);

    }



    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {

        if (msg.sender == _to)

            return mint();

        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        if (transferIns[msg.sender].length > 0)

            delete transferIns[msg.sender];

        uint64 _now = uint64(now);

        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),_now));

        transferIns[_to].push(transferInStruct(uint128(_value),_now));

        return true;

    }



    function totalSupply() public view returns (uint256) {

        return totalSupply;

    }



    function balanceOf(address _owner) constant public returns (uint256 balance) {

        return balances[_owner];

    }



    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public returns (bool) {

        require(_to != address(0));



        uint256 _allowance = allowed[_from][msg.sender];



        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met

        // require (_value <= _allowance);



        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = _allowance.sub(_value);

        emit Transfer(_from, _to, _value);

        if (transferIns[_from].length > 0)

            delete transferIns[_from];

        uint64 _now = uint64(now);

        transferIns[_from].push(transferInStruct(uint128(balances[_from]),_now));

        transferIns[_to].push(transferInStruct(uint128(_value),_now));

        return true;

    }



    function approve(address _spender, uint256 _value) public returns (bool) {

        require((_value == 0) || (allowed[msg.sender][_spender] == 0));



        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }



    function mint() canPoSMint public returns (bool) {

        // minimum stake of 5000 x is required to earn staking.

        if (balances[msg.sender] < MIN_STAKING.mul(1 ether))

            return false;

        if (transferIns[msg.sender].length <= 0)

            return false;



        uint reward = getProofOfStakeReward(msg.sender);

        if (reward <= 0)

            return false;

       

        totalSupply = totalSupply.add(reward);

        balances[msg.sender] = balances[msg.sender].add(reward);

        delete transferIns[msg.sender];

        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));



        emit Transfer(address(0), msg.sender, reward);

        emit Mint(msg.sender, reward);

        return true;

    }



    function getBlockNumber() view public returns (uint blockNumber) {

        blockNumber = block.number.sub(chainStartBlockNumber);

    }



    function coinAge() constant public returns (uint myCoinAge) {

        uint _now = now;

        myCoinAge = 0;

        for (uint i=0; i < getPeriodNumber(_now) + 1; i ++) {

            myCoinAge += getCoinAgeofPeriod(msg.sender, i, _now);

        }

    }



    function annualInterest() constant public returns (uint interest) {        

        uint _now = now;

        interest = periods[getPeriodNumber(_now)].interest;

    }



    function getProofOfStakeReward(address _address) public view returns (uint totalReward) {

        require((now >= stakeStartTime) && (stakeStartTime > 0));

        require(!noPOSRewards[_address]);



        uint _now = now;



        totalReward = 0;

        for (uint i=0; i < getPeriodNumber(_now) + 1; i ++) {

            totalReward += (getCoinAgeofPeriod(_address, i, _now)).mul(periods[i].interest).div(100).div(365);

        }

    }



    function getPeriodNumber(uint _now) public view returns (uint periodNumber) {

        for (uint i = 4; i >= 0; i --) {

            if( _now >= periods[i].start){

                return i;

            }

        }

    }



    function getCoinAgeofPeriod(address _address, uint _pid, uint _now) public view returns (uint _coinAge) {        

        if (transferIns[_address].length <= 0)

            return 0;



        if (_pid < 0 || _pid > 4)

            return 0;



        _coinAge = 0;

        uint nCoinSeconds;

        uint i;



        if (periods[_pid].start < _now && 

            periods[_pid].end >= _now) {

            // calculate the current period

            for (i = 0; i < transferIns[_address].length; i ++) {

                if (uint(periods[_pid].start) > uint(transferIns[_address][i].time) || 

                    uint(periods[_pid].end) <= uint(transferIns[_address][i].time))

                    continue;

                

                nCoinSeconds = _now.sub(uint(transferIns[_address][i].time));

                

                if (nCoinSeconds < stakeMinAge)

                    continue;



                if ( nCoinSeconds > stakeMaxAge )

                    nCoinSeconds = stakeMaxAge;    

                

                nCoinSeconds = nCoinSeconds.sub(stakeMinAge);

                _coinAge = _coinAge.add(uint(transferIns[_address][i].amount) * nCoinSeconds.div(1 days));

            }



        }else{

            // calculate for the ended preriods which user did not claimed

            for (i = 0; i < transferIns[_address].length; i++) {

                if (uint(periods[_pid].start) > uint(transferIns[_address][i].time) || 

                    uint(periods[_pid].end) <= uint(transferIns[_address][i].time))

                    continue;



                nCoinSeconds = (uint(periods[_pid].end)).sub(uint(transferIns[_address][i].time));

                

                if (nCoinSeconds < stakeMinAge)

                    continue;



                if ( nCoinSeconds > stakeMaxAge )

                    nCoinSeconds = stakeMaxAge;



                nCoinSeconds = nCoinSeconds.sub(stakeMinAge);

                _coinAge = _coinAge.add(uint(transferIns[_address][i].amount) * nCoinSeconds.div(1 days));

            }

        }



        _coinAge = _coinAge.div(1 ether);

    }



    function burn(uint256 _value) public {

        require(_value <= balances[msg.sender]);

        // no need to require value <= totalSupply, since that would imply the

        // sender's balance is greater than the totalSupply, which *should* be an assertion failure



        address burner = msg.sender;

        balances[burner] = balances[burner].sub(_value);

        delete transferIns[msg.sender];

        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));

        totalSupply = totalSupply.sub(_value);

        emit Burn(burner, _value);

    }



    /**

    * @dev Burns a specific amount of tokens.

    * @param _value The amount of token to be burned.

    */

    function ownerBurnToken(uint _value) public onlyOwner {

        require(_value > 0);



        balances[msg.sender] = balances[msg.sender].sub(_value);

        delete transferIns[msg.sender];

        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));



        totalSupply = totalSupply.sub(_value);

        totalInitialSupply = totalInitialSupply.sub(_value);

        maxTotalSupply = maxTotalSupply.sub(_value*10);



        emit Burn(msg.sender, _value);

    }



    /* Batch token transfer. Used by contract creator to distribute initial tokens to holders */

    function batchTransfer(address[] _recipients, uint[] _values) onlyOwner public returns (bool) {

        require(_recipients.length > 0 && _recipients.length == _values.length);



        uint total = 0;

        for (uint i = 0; i < _values.length; i++) {

            total = total.add(_values[i]);

        }

        require(total <= balances[msg.sender]);



        uint64 _now = uint64(now);

        for (uint j = 0; j < _recipients.length; j++) {

            balances[_recipients[j]] = balances[_recipients[j]].add(_values[j]);

            transferIns[_recipients[j]].push(transferInStruct(uint128(_values[j]),_now));

            emit Transfer(msg.sender, _recipients[j], _values[j]);

        }



        balances[msg.sender] = balances[msg.sender].sub(total);

        if (transferIns[msg.sender].length > 0)

            delete transferIns[msg.sender];

        if (balances[msg.sender] > 0)

            transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),_now));



        return true;

    }



    function disablePOSReward(address _account, bool _enabled) onlyOwner public {

        noPOSRewards[_account] = _enabled;

    }

}