/**

 *Submitted for verification at Etherscan.io on 2018-09-02

*/



pragma solidity 0.4.24;

// produced by the Solididy File Flattener (c) David Appleton 2018

// contact : [email protected]

// released under Apache 2.0 licence

/*

// produced by the Solididy File Flattener (c) David Appleton 2018

// contact : [email protected]

// released under Apache 2.0 licence

*/

// produced by the Solididy File Flattener (c) David Appleton 2018

// contact : [email protected]

// released under Apache 2.0 licence









contract Token {

    /* This is a slight change to the ERC20 base standard.

    function totalSupply() constant returns (uint256 supply);

    is replaced with:

    uint256 public totalSupply;

    This automatically creates a getter function for the totalSupply.

    This is moved to the base contract since public getter functions are not

    currently recognised as an implementation of the matching abstract

    function by the compiler.

    */

    /// total amount of tokens

    uint256 public totalSupply;



    /// @param _owner The address from which the balance will be retrieved

    /// @return The balance

    function balanceOf(address _owner) constant public returns (uint256 balance);



    /// @notice send `_value` token to `_to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address _to, uint256 _value) public returns (bool success);



    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

    /// @param _from The address of the sender

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);



    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _value The amount of tokens to be approved for transfer

    /// @return Whether the approval was successful or not

    function approve(address _spender, uint256 _value) public returns (bool success);



    /// @param _owner The address of the account owning tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens allowed to spent

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract StandardToken is Token {



    function transfer(address _to, uint256 _value) public returns (bool success) {

        //Default assumes totalSupply can't be over max (2^256 - 1).

        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.

        //Replace the if with this one instead.

        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        require(balances[msg.sender] >= _value);

        balances[msg.sender] -= _value;

        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        //same as above. Replace this line with the following if you want to protect against wrapping uints.

        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        balances[_to] += _value;

        balances[_from] -= _value;

        allowed[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;

    }



    function balanceOf(address _owner) public constant returns (uint256 balance) {

        return balances[_owner];

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

      return allowed[_owner][_spender];

    }



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

}



contract MintAndBurnToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);

  event MintFinished();



  bool public mintingFinished = false;





  modifier canMint() {

    require(!mintingFinished);

    _;

  }



/* Public variables of the token */



    /*

    NOTE:

    The following variables are OPTIONAL vanities. One does not have to include them.

    They allow one to customise the token contract & in no way influences the core functionality.

    Some wallets/interfaces might not even bother to look at this information.

    */

    string public name;                   //fancy name: eg Simon Bucks

    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.

    string public symbol;                 //An identifier: eg SBX

    string public version = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.



    constructor(

        string _tokenName,

        uint8 _decimalUnits,

        string _tokenSymbol

        ) public {

        name = _tokenName;                                   // Set the name for display purposes

        decimals = _decimalUnits;                            // Amount of decimals for display purposes

        symbol = _tokenSymbol;                               // Set the symbol for display purposes

    }



  /**

   * @dev Function to mint tokens

   * @param _to The address that will receive the minted tokens.

   * @param _amount The amount of tokens to mint.

   * @return A boolean that indicates if the operation was successful.

   */

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

    totalSupply = SafeMath.add(_amount, totalSupply);

    balances[_to] = SafeMath.add(_amount,balances[_to]);

    emit Mint(_to, _amount);

    emit Transfer(address(0), _to, _amount);

    return true;

  }



  /**

   * @dev Function to stop minting new tokens.

   * @return True if the operation was successful.

   */

  function finishMinting() onlyOwner canMint public returns (bool) {

    mintingFinished = true;

    emit MintFinished();

    return true;

  }



  // -----------------------------------

  // BURN FUNCTIONS BELOW

  // https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/BurnableToken.sol

  // -----------------------------------



  event Burn(address indexed burner, uint256 value);



  /**

   * @dev Burns a specific amount of tokens.

   * @param _value The amount of token to be burned.

   */

  function burn(uint256 _value) onlyOwner public {

    _burn(msg.sender, _value);

  }



  function _burn(address _who, uint256 _value) internal {

    require(_value <= balances[_who]);

    // no need to require value <= totalSupply, since that would imply the

    // sender's balance is greater than the totalSupply, which *should* be an assertion failure



    balances[_who] = SafeMath.sub(balances[_who],_value);

    totalSupply = SafeMath.sub(totalSupply,_value);

    emit Burn(_who, _value);

    emit Transfer(_who, address(0), _value);

  }

}



contract HumanStandardToken is StandardToken {



    /* Public variables of the token */



    /*

    NOTE:

    The following variables are OPTIONAL vanities. One does not have to include them.

    They allow one to customise the token contract & in no way influences the core functionality.

    Some wallets/interfaces might not even bother to look at this information.

    */

    string public name;                   //fancy name: eg Simon Bucks

    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.

    string public symbol;                 //An identifier: eg SBX

    string public version = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.



    constructor(

        uint256 _initialAmount,

        string _tokenName,

        uint8 _decimalUnits,

        string _tokenSymbol

        ) public {

        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens

        totalSupply = _initialAmount;                        // Update total supply

        name = _tokenName;                                   // Set the name for display purposes

        decimals = _decimalUnits;                            // Amount of decimals for display purposes

        symbol = _tokenSymbol;                               // Set the symbol for display purposes

    }



    /* Approves and then calls the receiving contract */

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);



        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.

        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)

        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.

        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));

        return true;

    }

}





contract SpankBank {

    using BytesLib for bytes;

    using SafeMath for uint256;



    event SpankBankCreated(

        uint256 periodLength,

        uint256 maxPeriods,

        address spankAddress,

        uint256 initialBootySupply,

        string bootyTokenName,

        uint8 bootyDecimalUnits,

        string bootySymbol

    );



    event StakeEvent(

        address staker,

        uint256 period,

        uint256 spankPoints,

        uint256 spankAmount,

        uint256 stakePeriods,

        address delegateKey,

        address bootyBase

    );



    event SendFeesEvent (

        address sender,

        uint256 bootyAmount

    );



    event MintBootyEvent (

        uint256 targetBootySupply,

        uint256 totalBootySupply

    );



    event CheckInEvent (

        address staker,

        uint256 period,

        uint256 spankPoints,

        uint256 stakerEndingPeriod

    );



    event ClaimBootyEvent (

        address staker,

        uint256 period,

        uint256 bootyOwed

    );



    event WithdrawStakeEvent (

        address staker,

        uint256 totalSpankToWithdraw

    );



    event SplitStakeEvent (

        address staker,

        address newAddress,

        address newDelegateKey,

        address newBootyBase,

        uint256 spankAmount

    );



    event VoteToCloseEvent (

        address staker,

        uint256 period

    );



    event UpdateDelegateKeyEvent (

        address staker,

        address newDelegateKey

    );



    event UpdateBootyBaseEvent (

        address staker,

        address newBootyBase

    );



    event ReceiveApprovalEvent (

        address from,

        address tokenContract

    );



    /***********************************

    VARIABLES SET AT CONTRACT DEPLOYMENT

    ************************************/

    // GLOBAL CONSTANT VARIABLES

    uint256 public periodLength; // time length of each period in seconds

    uint256 public maxPeriods; // the maximum # of periods a staker can stake for

    uint256 public totalSpankStaked; // the total SPANK staked across all stakers

    bool public isClosed; // true if voteToClose has passed, allows early withdrawals



    // ERC-20 BASED TOKEN WITH SOME ADDED PROPERTIES FOR HUMAN READABILITY

    // https://github.com/ConsenSys/Tokens/blob/master/contracts/HumanStandardToken.sol

    HumanStandardToken public spankToken;

    MintAndBurnToken public bootyToken;



    // LOOKUP TABLE FOR SPANKPOINTS BY PERIOD

    // 1 -> 45%

    // 2 -> 50%

    // ...

    // 12 -> 100%

    mapping(uint256 => uint256) public pointsTable;



    /*************************************

    INTERAL ACCOUNTING

    **************************************/

    uint256 public currentPeriod = 0;



    struct Staker {

        uint256 spankStaked; // the amount of spank staked

        uint256 startingPeriod; // the period this staker started staking

        uint256 endingPeriod; // the period after which this stake expires

        mapping(uint256 => uint256) spankPoints; // the spankPoints per period

        mapping(uint256 => bool) didClaimBooty; // true if staker claimed BOOTY for that period

        mapping(uint256 => bool) votedToClose; // true if staker voted to close for that period

        address delegateKey; // address used to call checkIn and claimBooty

        address bootyBase; // destination address to receive BOOTY

    }



    mapping(address => Staker) public stakers;



    struct Period {

        uint256 bootyFees; // the amount of BOOTY collected in fees

        uint256 totalSpankPoints; // the total spankPoints of all stakers

        uint256 bootyMinted; // the amount of BOOTY minted

        bool mintingComplete; // true if BOOTY has already been minted for this period

        uint256 startTime; // the starting unix timestamp in seconds

        uint256 endTime; // the ending unix timestamp in seconds

        uint256 closingVotes; // the total votes to close this period

    }



    mapping(uint256 => Period) public periods;



    mapping(address => address) public stakerByDelegateKey;



    modifier SpankBankIsOpen() {

        require(isClosed == false);

        _;

    }



    constructor (

        uint256 _periodLength,

        uint256 _maxPeriods,

        address spankAddress,

        uint256 initialBootySupply,

        string bootyTokenName,

        uint8 bootyDecimalUnits,

        string bootySymbol

    )   public {

        periodLength = _periodLength;

        maxPeriods = _maxPeriods;

        spankToken = HumanStandardToken(spankAddress);

        bootyToken = new MintAndBurnToken(bootyTokenName, bootyDecimalUnits, bootySymbol);

        bootyToken.mint(this, initialBootySupply);



        uint256 startTime = now;



        periods[currentPeriod].startTime = startTime;

        periods[currentPeriod].endTime = SafeMath.add(startTime, periodLength);



        bootyToken.transfer(msg.sender, initialBootySupply);



        // initialize points table

        pointsTable[0] = 0;

        pointsTable[1] = 45;

        pointsTable[2] = 50;

        pointsTable[3] = 55;

        pointsTable[4] = 60;

        pointsTable[5] = 65;

        pointsTable[6] = 70;

        pointsTable[7] = 75;

        pointsTable[8] = 80;

        pointsTable[9] = 85;

        pointsTable[10] = 90;

        pointsTable[11] = 95;

        pointsTable[12] = 100;



        emit SpankBankCreated(_periodLength, _maxPeriods, spankAddress, initialBootySupply, bootyTokenName, bootyDecimalUnits, bootySymbol);

    }



    // Used to create a new staking position - verifies that the caller is not staking

    function stake(uint256 spankAmount, uint256 stakePeriods, address delegateKey, address bootyBase) SpankBankIsOpen public {

        doStake(msg.sender, spankAmount, stakePeriods, delegateKey, bootyBase);

    }



    function doStake(address stakerAddress, uint256 spankAmount, uint256 stakePeriods, address delegateKey, address bootyBase) internal {

        updatePeriod();

        require(stakePeriods > 0 && stakePeriods <= maxPeriods, "stake not between zero and maxPeriods"); // stake 1-12 (max) periods

        require(spankAmount > 0, "stake is 0"); // stake must be greater than 0



        // the staker must not have an active staking position

        require(stakers[stakerAddress].startingPeriod == 0, "staker already exists");



        // transfer SPANK to this contract - assumes sender has already "allowed" the spankAmount

        require(spankToken.transferFrom(stakerAddress, this, spankAmount));



        stakers[stakerAddress] = Staker(spankAmount, currentPeriod + 1, currentPeriod + stakePeriods, delegateKey, bootyBase);



        _updateNextPeriodPoints(stakerAddress, stakePeriods);



        totalSpankStaked = SafeMath.add(totalSpankStaked, spankAmount);



        require(delegateKey != address(0), "delegateKey does not exist");

        require(bootyBase != address(0), "bootyBase does not exist");

        require(stakerByDelegateKey[delegateKey] == address(0), "delegateKey already used");

        stakerByDelegateKey[delegateKey] = stakerAddress;



        emit StakeEvent(

            stakerAddress,

            currentPeriod + 1,

            stakers[stakerAddress].spankPoints[currentPeriod + 1],

            spankAmount,

            stakePeriods,

            delegateKey,

            bootyBase

        );

    }



    // Called during stake and checkIn, assumes those functions prevent duplicate calls

    // for the same staker.

    function _updateNextPeriodPoints(address stakerAddress, uint256 stakingPeriods) internal {

        Staker storage staker = stakers[stakerAddress];



        uint256 stakerPoints = SafeMath.div(SafeMath.mul(staker.spankStaked, pointsTable[stakingPeriods]), 100);



        // add staker spankpoints to total spankpoints for the next period

        uint256 totalPoints = periods[currentPeriod + 1].totalSpankPoints;

        totalPoints = SafeMath.add(totalPoints, stakerPoints);

        periods[currentPeriod + 1].totalSpankPoints = totalPoints;



        staker.spankPoints[currentPeriod + 1] = stakerPoints;

    }



    function receiveApproval(address from, uint256 amount, address tokenContract, bytes extraData) SpankBankIsOpen public returns (bool success) {

        address delegateKeyFromBytes = extraData.toAddress(12);

        address bootyBaseFromBytes = extraData.toAddress(44);

        uint256 periodFromBytes = extraData.toUint(64);



        emit ReceiveApprovalEvent(from, tokenContract);



        doStake(from, amount, periodFromBytes, delegateKeyFromBytes, bootyBaseFromBytes);

        return true;

    }



    function sendFees(uint256 bootyAmount) SpankBankIsOpen public {

        updatePeriod();



        require(bootyAmount > 0, "fee is zero"); // fees must be greater than 0

        require(bootyToken.transferFrom(msg.sender, this, bootyAmount));



        bootyToken.burn(bootyAmount);



        uint256 currentBootyFees = periods[currentPeriod].bootyFees;

        currentBootyFees = SafeMath.add(bootyAmount, currentBootyFees);

        periods[currentPeriod].bootyFees = currentBootyFees;



        emit SendFeesEvent(msg.sender, bootyAmount);

    }



    function mintBooty() SpankBankIsOpen public {

        updatePeriod();



        // can't mint BOOTY during period 0 - would result in integer underflow

        require(currentPeriod > 0, "current period is zero");



        Period storage period = periods[currentPeriod - 1];

        require(!period.mintingComplete, "minting already complete"); // cant mint BOOTY twice



        period.mintingComplete = true;



        uint256 targetBootySupply = SafeMath.mul(period.bootyFees, 20);

        uint256 totalBootySupply = bootyToken.totalSupply();



        if (targetBootySupply > totalBootySupply) {

            uint256 bootyMinted = targetBootySupply - totalBootySupply;

            bootyToken.mint(this, bootyMinted);

            period.bootyMinted = bootyMinted;

            emit MintBootyEvent(targetBootySupply, totalBootySupply);

        }

    }



    // This will check the current time and update the current period accordingly

    // - called from all write functions to ensure the period is always up to date before any writes

    // - can also be called externally, but there isn't a good reason for why you would want to

    // - the while loop protects against the edge case where we miss a period



    function updatePeriod() public {

        while (now >= periods[currentPeriod].endTime) {

            Period memory prevPeriod = periods[currentPeriod];

            currentPeriod += 1;

            periods[currentPeriod].startTime = prevPeriod.endTime;

            periods[currentPeriod].endTime = SafeMath.add(prevPeriod.endTime, periodLength);

        }

    }



    // In order to receive Booty, each staker will have to check-in every period.

    // This check-in will compute the spankPoints locally and globally for each staker.

    function checkIn(uint256 updatedEndingPeriod) SpankBankIsOpen public {

        updatePeriod();



        address stakerAddress =  stakerByDelegateKey[msg.sender];



        Staker storage staker = stakers[stakerAddress];



        require(staker.spankStaked > 0, "staker stake is zero");

        require(currentPeriod < staker.endingPeriod, "staker expired");

        require(staker.spankPoints[currentPeriod+1] == 0, "staker has points for next period");



        // If updatedEndingPeriod is 0, don't update the ending period

        if (updatedEndingPeriod > 0) {

            require(updatedEndingPeriod > staker.endingPeriod, "updatedEndingPeriod less than or equal to staker endingPeriod");

            require(updatedEndingPeriod <= currentPeriod + maxPeriods, "updatedEndingPeriod greater than currentPeriod and maxPeriods");

            staker.endingPeriod = updatedEndingPeriod;

        }



        uint256 stakePeriods = staker.endingPeriod - currentPeriod;



        _updateNextPeriodPoints(stakerAddress, stakePeriods);



        emit CheckInEvent(stakerAddress, currentPeriod + 1, staker.spankPoints[currentPeriod + 1], staker.endingPeriod);

    }



    function claimBooty(uint256 claimPeriod) public {

        updatePeriod();



        Period memory period = periods[claimPeriod];

        require(period.mintingComplete, "booty not minted");



        address stakerAddress = stakerByDelegateKey[msg.sender];



        Staker storage staker = stakers[stakerAddress];



        require(!staker.didClaimBooty[claimPeriod], "staker already claimed"); // can only claim booty once



        uint256 stakerSpankPoints = staker.spankPoints[claimPeriod];

        require(stakerSpankPoints > 0, "staker has no points"); // only stakers can claim



        staker.didClaimBooty[claimPeriod] = true;



        uint256 bootyMinted = period.bootyMinted;

        uint256 totalSpankPoints = period.totalSpankPoints;



        uint256 bootyOwed = SafeMath.div(SafeMath.mul(stakerSpankPoints, bootyMinted), totalSpankPoints);



        require(bootyToken.transfer(staker.bootyBase, bootyOwed));



        emit ClaimBootyEvent(stakerAddress, claimPeriod, bootyOwed);

    }



    function withdrawStake() public {

        updatePeriod();



        Staker storage staker = stakers[msg.sender];

        require(staker.spankStaked > 0, "staker has no stake");



        require(isClosed || currentPeriod > staker.endingPeriod, "currentPeriod less than endingPeriod or spankbank closed");



        uint256 spankToWithdraw = staker.spankStaked;



        totalSpankStaked = SafeMath.sub(totalSpankStaked, staker.spankStaked);

        staker.spankStaked = 0;



        spankToken.transfer(msg.sender, spankToWithdraw);



        emit WithdrawStakeEvent(msg.sender, spankToWithdraw);

    }



    function splitStake(address newAddress, address newDelegateKey, address newBootyBase, uint256 spankAmount) public {

        updatePeriod();



        require(newAddress != address(0), "newAddress is zero");

        require(newDelegateKey != address(0), "delegateKey is zero");

        require(newBootyBase != address(0), "bootyBase is zero");

        require(stakerByDelegateKey[newDelegateKey] == address(0), "delegateKey in use");



        require(spankAmount > 0, "spankAmount is zero");



        Staker storage staker = stakers[msg.sender];

        require(currentPeriod < staker.endingPeriod, "staker expired");

        require(spankAmount <= staker.spankStaked, "spankAmount greater than stake");

        require(staker.spankPoints[currentPeriod+1] == 0, "staker has points for next period");



        staker.spankStaked = SafeMath.sub(staker.spankStaked, spankAmount);



        stakers[newAddress] = Staker(spankAmount, staker.startingPeriod, staker.endingPeriod, newDelegateKey, newBootyBase);



        stakerByDelegateKey[newDelegateKey] = newAddress;



        emit SplitStakeEvent(msg.sender, newAddress, newDelegateKey, newBootyBase, spankAmount);

    }



    function voteToClose() public {

        updatePeriod();



        Staker storage staker = stakers[msg.sender];



        require(staker.spankStaked > 0, "stake is zero");

        require(currentPeriod < staker.endingPeriod , "staker expired");

        require(staker.votedToClose[currentPeriod] == false, "stake already voted");

        require(isClosed == false, "SpankBank already closed");



        uint256 closingVotes = periods[currentPeriod].closingVotes;

        closingVotes = SafeMath.add(closingVotes, staker.spankStaked);

        periods[currentPeriod].closingVotes = closingVotes;



        staker.votedToClose[currentPeriod] = true;



        uint256 closingTrigger = SafeMath.div(totalSpankStaked, 2);

        if (closingVotes > closingTrigger) {

            isClosed = true;

        }



        emit VoteToCloseEvent(msg.sender, currentPeriod);

    }



    function updateDelegateKey(address newDelegateKey) public {

        require(newDelegateKey != address(0), "delegateKey is zero");

        require(stakerByDelegateKey[newDelegateKey] == address(0), "delegateKey already exists");



        Staker storage staker = stakers[msg.sender];

        require(staker.startingPeriod > 0, "staker starting period is zero");



        stakerByDelegateKey[staker.delegateKey] = address(0);

        staker.delegateKey = newDelegateKey;

        stakerByDelegateKey[newDelegateKey] = msg.sender;



        emit UpdateDelegateKeyEvent(msg.sender, newDelegateKey);

    }



    function updateBootyBase(address newBootyBase) public {

        Staker storage staker = stakers[msg.sender];

        require(staker.startingPeriod > 0, "staker starting period is zero");



        staker.bootyBase = newBootyBase;



        emit UpdateBootyBaseEvent(msg.sender, newBootyBase);

    }



    function getSpankPoints(address stakerAddress, uint256 period) public view returns (uint256)  {

        return stakers[stakerAddress].spankPoints[period];

    }



    function getDidClaimBooty(address stakerAddress, uint256 period) public view returns (bool)  {

        return stakers[stakerAddress].didClaimBooty[period];

    }



    function getVote(address stakerAddress, uint period) public view returns (bool) {

        return stakers[stakerAddress].votedToClose[period];

    }



    function getStakerFromDelegateKey(address delegateAddress) public view returns (address) {

        return stakerByDelegateKey[delegateAddress];

    }

}