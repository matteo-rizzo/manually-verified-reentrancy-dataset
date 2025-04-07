pragma solidity ^0.4.18;

// @authors:
// Davy Van Roy <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c2a6a3b4bbecb4a3acecb0adbb82a5afa3abaeeca1adaf">[email&#160;protected]</a>>
// Quinten De Swaef <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="dcada9b5b2a8b9b2f2b8b9f2afabbdb9ba9cbbb1bdb5b0f2bfb3b1">[email&#160;protected]</a>>

contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;
}

/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



contract Controlled {
    /// @notice The address of the controller is the only address that can call
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() public { controller = msg.sender;}

    /// @notice Changes the controller of the contract
    /// @param _newController The new controller of the contract
    function changeController(address _newController) public onlyController {
        controller = _newController;
    }
}


/// @dev The token controller contract must implement these functions
contract TokenController {
    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) public payable returns(bool);

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount)
    public
    returns(bool);
}

/// @dev This contract is used to generate clone contracts from a contract.
///  In solidity this is the way to create a contract from a contract of the
///  same class
contract MiniMeTokenFactory {

    /// @notice Update the DApp by creating a new token with new functionalities
    ///  the msg.sender becomes the controller of this clone token
    /// @param _parentToken Address of the token being cloned
    /// @param _snapshotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    /// @return The address of the new token contract
    function createCloneToken(
    address _parentToken,
    uint _snapshotBlock,
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol,
    bool _transfersEnabled
    ) public returns (MiniMeToken)
    {
        MiniMeToken newToken = new MiniMeToken(
        this,
        _parentToken,
        _snapshotBlock,
        _tokenName,
        _decimalUnits,
        _tokenSymbol,
        _transfersEnabled
        );

        newToken.changeController(msg.sender);
        return newToken;
    }
}


/// @title MiniMeToken Contract
/// @author Jordi Baylina
/// @dev This token contract&#39;s goal is to make it easy for anyone to clone this
///  token using the token distribution at a given block, this will allow DAO&#39;s
///  and DApps to upgrade their features in a decentralized manner without
///  affecting the original token
/// @dev It is ERC20 compliant, but still needs to under go further testing.
/// @dev The actual token contract, the default controller is the msg.sender
///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract MiniMeToken is Controlled {

    string public name;                //The Token&#39;s name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = "1.0.0";

    /// @dev `Checkpoint` is the structure that attaches a block number to a
    ///  given value, the block number attached is the one that last changed the
    ///  value
    struct Checkpoint {

    // `fromBlock` is the block number that the value was generated from
    uint128 fromBlock;

    // `value` is the amount of tokens at a specific block number
    uint128 value;
    }

    // `parentToken` is the Token address that was cloned to produce this token;
    //  it will be 0x0 for a token that was not cloned
    MiniMeToken public parentToken;

    // `parentSnapShotBlock` is the block number from the Parent Token that was
    //  used to determine the initial distribution of the Clone Token
    uint public parentSnapShotBlock;

    // `creationBlock` is the block number that the Clone Token was created
    uint public creationBlock;

    // `balances` is the map that tracks the balance of each address, in this
    //  contract when the balance changes the block number that the change
    //  occurred is also included in the map
    mapping (address => Checkpoint[]) balances;

    // `allowed` tracks any extra transfer rights as in all ERC20 tokens
    mapping (address => mapping (address => uint256)) allowed;

    // Tracks the history of the `totalSupply` of the token
    Checkpoint[] totalSupplyHistory;

    // Flag that determines if the token is transferable or not.
    bool public transfersEnabled;

    // The factory used to create new clone tokens
    MiniMeTokenFactory public tokenFactory;

    ////////////////
    // Constructor
    ////////////////

    /// @notice Constructor to create a MiniMeToken
    /// @param _tokenFactory The address of the MiniMeTokenFactory contract that
    ///  will create the Clone token contracts, the token factory needs to be
    ///  deployed first
    /// @param _parentToken Address of the parent token, set to 0x0 if it is a
    ///  new token
    /// @param _parentSnapShotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token, set to 0 if it
    ///  is a new token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    function MiniMeToken(
    address _tokenFactory,
    address _parentToken,
    uint _parentSnapShotBlock,
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol,
    bool _transfersEnabled
    ) public
    {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }


    ///////////////////
    // ERC20 Methods
    ///////////////////

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);
        return doTransfer(msg.sender, _to, _amount);
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address _from, address _to, uint256 _amount)
    public returns (bool success)
    {
        // The controller of this contract can move tokens around at will,
        //  this is important to recognize! Confirm that you trust the
        //  controller of this contract, which in most situations should be
        //  another open source smart contract or 0x0
        if (msg.sender != controller) {
            require(transfersEnabled);

            // The standard ERC 20 transferFrom functionality
            if (allowed[_from][msg.sender] < _amount) {
                return false;
            }
            allowed[_from][msg.sender] -= _amount;
        }
        return doTransfer(_from, _to, _amount);
    }

    /// @dev This is the actual transfer function in the token contract, it can
    ///  only be called by other functions in this contract.
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function doTransfer(address _from, address _to, uint _amount
    ) internal returns(bool)
    {

        if (_amount == 0) {
            return true;
        }

        require(parentSnapShotBlock < block.number);

        // Do not allow transfer to 0x0 or the token contract itself
        require((_to != 0) && (_to != address(this)));

        // If the amount being transfered is more than the balance of the
        //  account the transfer returns false
        var previousBalanceFrom = balanceOfAt(_from, block.number);
        if (previousBalanceFrom < _amount) {
            return false;
        }

        // Alerts the token controller of the transfer
        if (isContract(controller)) {
            require(TokenController(controller).onTransfer(_from, _to, _amount));
        }

        // First update the balance array with the new value for the address
        //  sending the tokens
        updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

        // Then update the balance array with the new value for the address
        //  receiving the tokens
        var previousBalanceTo = balanceOfAt(_to, block.number);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(balances[_to], previousBalanceTo + _amount);

        // An event to make the transfer easy to find on the blockchain
        Transfer(_from, _to, _amount);

        return true;
    }

    /// @param _owner The address that&#39;s balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
        return doApprove(_spender, _amount);
    }

    function doApprove(address _spender, uint256 _amount) internal returns (bool success) {
        require(transfersEnabled);
        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
        }
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param _owner The address of the account that owns the token
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    ///  to spend
    function allowance(address _owner, address _spender
    ) public constant returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    /// @notice `msg.sender` approves `_spender` to send `_amount` tokens on
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    /// @param _spender The address of the contract able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the function call was successful
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) public returns (bool success)
    {
        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
        msg.sender,
        _amount,
        this,
        _extraData
        );

        return true;
    }

    /// @dev This function makes it easy to get the total number of tokens
    /// @return The total number of tokens
    function totalSupply() public constant returns (uint) {
        return totalSupplyAt(block.number);
    }


    ////////////////
    // Query balance and totalSupply in History
    ////////////////

    /// @dev Queries the balance of `_owner` at a specific `_blockNumber`
    /// @param _owner The address from which the balance will be retrieved
    /// @param _blockNumber The block number when the balance is queried
    /// @return The balance at `_blockNumber`
    function balanceOfAt(address _owner, uint _blockNumber) public constant
    returns (uint)
    {
        // These next few lines are used when the balance of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.balanceOfAt` be queried at the
        //  genesis block for that token as this contains initial balance of
        //  this token
        if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                // Has no parent
                return 0;
            }

            // This will return the expected balance during normal situations
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    /// @notice Total amount of tokens at a specific `_blockNumber`.
    /// @param _blockNumber The block number when the totalSupply is queried
    /// @return The total amount of tokens at `_blockNumber`
    function totalSupplyAt(uint _blockNumber) public constant returns(uint) {

        // These next few lines are used when the totalSupply of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.totalSupplyAt` be queried at the
        //  genesis block for this token as that contains totalSupply of this
        //  token at this block number.
        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

            // This will return the expected totalSupply during normal situations
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

    ////////////////
    // Clone Token Method
    ////////////////

    /// @notice Creates a new clone token with the initial distribution being
    ///  this token at `_snapshotBlock`
    /// @param _cloneTokenName Name of the clone token
    /// @param _cloneDecimalUnits Number of decimals of the smallest unit
    /// @param _cloneTokenSymbol Symbol of the clone token
    /// @param _snapshotBlock Block when the distribution of the parent token is
    ///  copied to set the initial distribution of the new clone token;
    ///  if the block is zero than the actual block, the current block is used
    /// @param _transfersEnabled True if transfers are allowed in the clone
    /// @return The address of the new MiniMeToken Contract
    function createCloneToken(
    string _cloneTokenName,
    uint8 _cloneDecimalUnits,
    string _cloneTokenSymbol,
    uint _snapshotBlock,
    bool _transfersEnabled
    ) public returns(address)
    {
        if (_snapshotBlock == 0) {
            _snapshotBlock = block.number;
        }

        MiniMeToken cloneToken = tokenFactory.createCloneToken(
        this,
        _snapshotBlock,
        _cloneTokenName,
        _cloneDecimalUnits,
        _cloneTokenSymbol,
        _transfersEnabled
        );

        cloneToken.changeController(msg.sender);

        // An event to make the token easy to find on the blockchain
        NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

    ////////////////
    // Generate and destroy tokens
    ////////////////

    /// @notice Generates `_amount` tokens that are assigned to `_owner`
    /// @param _owner The address that will be assigned the new tokens
    /// @param _amount The quantity of tokens generated
    /// @return True if the tokens are generated correctly
    function generateTokens(address _owner, uint _amount)
    public onlyController returns (bool)
    {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


    /// @notice Burns `_amount` tokens from `_owner`
    /// @param _owner The address that will lose the tokens
    /// @param _amount The quantity of tokens to burn
    /// @return True if the tokens are burned correctly
    function destroyTokens(address _owner, uint _amount
    ) onlyController public returns (bool)
    {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }

    ////////////////
    // Enable tokens transfers
    ////////////////


    /// @notice Enables token holders to transfer their tokens freely if true
    /// @param _transfersEnabled True if transfers are allowed in the clone
    function enableTransfers(bool _transfersEnabled) public onlyController {
        transfersEnabled = _transfersEnabled;
    }

    ////////////////
    // Internal helper functions to query and set a value in a snapshot array
    ////////////////

    /// @dev `getValueAt` retrieves the number of tokens at a given block number
    /// @param checkpoints The history of values being queried
    /// @param _block The block number to retrieve the value at
    /// @return The number of tokens being queried
    function getValueAt(Checkpoint[] storage checkpoints, uint _block)
    constant internal returns (uint)
    {
        if (checkpoints.length == 0) {
            return 0;
        }

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock) {
            return checkpoints[checkpoints.length-1].value;
        }

        if (_block < checkpoints[0].fromBlock) {
            return 0;
        }

        // Binary search of the value in the array
        uint min = 0;
        uint max = checkpoints.length - 1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    /// @dev `updateValueAtNow` used to update the `balances` map and the
    ///  `totalSupplyHistory`
    /// @param checkpoints The history of data being updated
    /// @param _value The new number of tokens
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal
    {
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length-1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
            oldCheckPoint.value = uint128(_value);
        }
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) {
            return false;
        }
        assembly {
        size := extcodesize(_addr)
        }
        return size>0;
    }

    /// @dev Helper function to return a min betwen the two uints
    function min(uint a, uint b) pure internal returns (uint) {
        return a < b ? a : b;
    }

    /// @notice The fallback function: If the contract&#39;s controller has not been
    ///  set to 0, then the `proxyPayment` method is called which relays the
    ///  ether and creates tokens as described in the token controller contract
    function () public payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }

    //////////
    // Safety Methods
    //////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }

    ////////////////
    // Events
    ////////////////
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
    address indexed _owner,
    address indexed _spender,
    uint256 _amount
    );

}




// FundRequest Token
//
// @authors:
// Davy Van Roy <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d7b3b6a1aef9a1b6b9f9a5b8ae97b0bab6bebbf9b4b8ba">[email&#160;protected]</a>>
// Quinten De Swaef <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c9b8bca0a7bdaca7e7adace7babea8acaf89aea4a8a0a5e7aaa6a4">[email&#160;protected]</a>>
//
// Security audit performed by LeastAuthority:
// https://github.com/FundRequest/audit-reports/raw/master/2018-02-06 - Least Authority - ICO Contracts Audit Report.pdf

contract FundRequestToken is MiniMeToken {

  function FundRequestToken(
    address _tokenFactory,
    address _parentToken, 
    uint _parentSnapShotBlock, 
    string _tokenName, 
    uint8 _decimalUnits, 
    string _tokenSymbol, 
    bool _transfersEnabled) 
    public 
    MiniMeToken(
      _tokenFactory,
      _parentToken, 
      _parentSnapShotBlock, 
      _tokenName, 
      _decimalUnits, 
      _tokenSymbol, 
      _transfersEnabled) 
  {
    //constructor
  }

  function safeApprove(address _spender, uint256 _currentValue, uint256 _amount) public returns (bool success) {
    require(allowed[msg.sender][_spender] == _currentValue);
    return doApprove(_spender, _amount);
  }

  function isFundRequestToken() public pure returns (bool) {
    return true;
  }
}







/*
 * Database Contract
 * Davy Van Roy
 * Quinten De Swaef
 */
contract FundRepository is Owned {

    using SafeMath for uint256;

    uint256 public totalNumberOfFunders;

    mapping (address => uint256) funders;

    uint256 public totalFunded;

    uint256 public requestsFunded;

    uint256 public totalBalance;

    mapping (bytes32 => mapping (string => Funding)) funds;

    mapping(address => bool) public callers;

    struct Funding {
        address[] funders;
        mapping (address => uint256) balances;
        uint256 totalBalance;
    }

    //modifiers
    modifier onlyCaller {
        require(callers[msg.sender]);
        _;
    }

    function FundRepository() {
        //constructor
    }

    function updateFunders(address _from, bytes32 _platform, string _platformId, uint256 _value) public onlyCaller {
        bool existing = funds[_platform][_platformId].balances[_from] > 0;
        if (!existing) {
            funds[_platform][_platformId].funders.push(_from);
        }
        if (funders[_from] <= 0) {
            totalNumberOfFunders = totalNumberOfFunders.add(1);
            funders[_from].add(_value);
        }
    }

    function updateBalances(address _from, bytes32 _platform, string _platformId, uint256 _value) public onlyCaller {
        if (funds[_platform][_platformId].totalBalance <= 0) {
            requestsFunded = requestsFunded.add(1);
        }
        funds[_platform][_platformId].balances[_from] = funds[_platform][_platformId].balances[_from].add(_value);
        funds[_platform][_platformId].totalBalance = funds[_platform][_platformId].totalBalance.add(_value);
        totalBalance = totalBalance.add(_value);
        totalFunded = totalFunded.add(_value);
    }

    function resolveFund(bytes32 platform, string platformId) public onlyCaller returns (uint) {
        var funding = funds[platform][platformId];
        var requestBalance = funding.totalBalance;
        totalBalance = totalBalance.sub(requestBalance);
        for (uint i = 0; i < funding.funders.length; i++) {
            var funder = funding.funders[i];
            delete (funding.balances[funder]);
        }
        delete (funds[platform][platformId]);
        return requestBalance;
    }

    //constants

    function getFundInfo(bytes32 _platform, string _platformId, address _funder) public view returns (uint256, uint256, uint256) {
        return (
        getFunderCount(_platform, _platformId),
        balance(_platform, _platformId),
        amountFunded(_platform, _platformId, _funder)
        );
    }

    function getFunderCount(bytes32 _platform, string _platformId) public view returns (uint){
        return funds[_platform][_platformId].funders.length;
    }

    function amountFunded(bytes32 _platform, string _platformId, address _funder) public view returns (uint256){
        return funds[_platform][_platformId].balances[_funder];
    }

    function balance(bytes32 _platform, string _platformId) view public returns (uint256) {
        return funds[_platform][_platformId].totalBalance;
    }

    //management of the repositories
    function updateCaller(address _caller, bool allowed) public onlyOwner {
        callers[_caller] = allowed;
    }
}





contract ClaimRepository is Owned {
    using SafeMath for uint256;

    mapping (bytes32 => mapping (string => Claim)) claims;

    mapping(address => bool) public callers;

    uint256 public totalBalanceClaimed;
    uint256 public totalClaims;


    //modifiers
    modifier onlyCaller {
        require(callers[msg.sender]);
        _;
    }

    struct Claim {
        address solverAddress;
        string solver;
        uint256 requestBalance;
    }

    function ClaimRepository() {
        //constructor
    }

    function addClaim(address _solverAddress, bytes32 _platform, string _platformId, string _solver, uint256 _requestBalance) public onlyCaller returns (bool) {
        claims[_platform][_platformId].solver = _solver;
        claims[_platform][_platformId].solverAddress = _solverAddress;
        claims[_platform][_platformId].requestBalance = _requestBalance;
        totalBalanceClaimed = totalBalanceClaimed.add(_requestBalance);
        totalClaims = totalClaims.add(1);
        return true;
    }

    //management of the repositories
    function updateCaller(address _caller, bool allowed) public onlyOwner {
        callers[_caller] = allowed;
    }
}

/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d4b5a6b5b7bcbabdb094babba0b0bba0fabab1a0">[email&#160;protected]</a>>
 *
 * @dev Functionality in this library is largely implemented using an
 *      abstraction called a &#39;slice&#39;. A slice represents a part of a string -
 *      anything from the entire string to a single character, or even no
 *      characters at all (a 0-length slice). Since a slice only has to specify
 *      an offset and a length, copying and manipulating slices is a lot less
 *      expensive than copying and manipulating the strings they reference.
 *
 *      To further reduce gas costs, most functions on slice that need to return
 *      a slice modify the original one instead of allocating a new one; for
 *      instance, `s.split(".")` will return the text up to the first &#39;.&#39;,
 *      modifying s to only contain the remainder of the string after the &#39;.&#39;.
 *      In situations where you do not want to modify the original slice, you
 *      can make a copy first with `.copy()`, for example:
 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since
 *      Solidity has no memory management, it will result in allocating many
 *      short-lived slices that are later discarded.
 *
 *      Functions that return two slices come in two versions: a non-allocating
 *      version that takes the second slice as an argument, modifying it in
 *      place, and an allocating version that allocates and returns the second
 *      slice; see `nextRune` for example.
 *
 *      Functions that have to copy string data will return strings rather than
 *      slices; these can be cast back to slices for further processing if
 *      required.
 *
 *      For convenience, some functions are provided with non-modifying
 *      variants that create a new slice and return both; for instance,
 *      `s.splitNew(&#39;.&#39;)` leaves s unmodified, and returns two values
 *      corresponding to the left and right parts of the string.
 */







/*
 * Main FundRequest Contract
 * Davy Van Roy
 * Quinten De Swaef
 */
contract FundRequestContract is Owned, ApproveAndCallFallBack {

    using SafeMath for uint256;
    using strings for *;

    event Funded(address indexed from, bytes32 platform, string platformId, uint256 value);

    event Claimed(address indexed solverAddress, bytes32 platform, string platformId, string solver, uint256 value);

    FundRequestToken public token;

    //repositories
    FundRepository public fundRepository;

    ClaimRepository public claimRepository;

    address public claimSignerAddress;

    modifier addressNotNull(address target) {
        require(target != address(0));
        _;
    }

    function FundRequestContract(
    address _tokenAddress,
    address _fundRepository,
    address _claimRepository
    ) public {
        setTokenAddress(_tokenAddress);
        setFundRepository(_fundRepository);
        setClaimRepository(_claimRepository);
    }

    //entrypoints
    function fund(bytes32 _platform, string _platformId, uint256 _value) public returns (bool success) {
        require(doFunding(_platform, _platformId, _value, msg.sender));
        return true;
    }

    function receiveApproval(address _from, uint _amount, address _token, bytes _data) public {
        require(_token == address(token));
        var sliced = string(_data).toSlice();
        var platform = sliced.split("|AAC|".toSlice());
        var platformId = sliced.split("|AAC|".toSlice());
        require(doFunding(platform.toBytes32(), platformId.toString(), _amount, _from));
    }

    function doFunding(bytes32 _platform, string _platformId, uint256 _value, address _funder) internal returns (bool success){
        require(_value > 0);
        require(token.transferFrom(_funder, address(this), _value));
        fundRepository.updateFunders(_funder, _platform, _platformId, _value);
        fundRepository.updateBalances(_funder, _platform, _platformId, _value);
        Funded(_funder, _platform, _platformId, _value);
        return true;
    }

    function claim(bytes32 platform, string platformId, string solver, address solverAddress, bytes32 r, bytes32 s, uint8 v) public returns (bool) {
        require(validClaim(platform, platformId, solver, solverAddress, r, s, v));
        uint requestBalance = fundRepository.resolveFund(platform, platformId);
        require(token.transfer(solverAddress, requestBalance));
        require(claimRepository.addClaim(solverAddress, platform, platformId, solver, requestBalance));
        Claimed(solverAddress, platform, platformId, solver, requestBalance);
        return true;
    }

    function validClaim(bytes32 platform, string platformId, string solver, address solverAddress, bytes32 r, bytes32 s, uint8 v) internal view returns (bool) {
        var h = sha3(createClaimMsg(platform, platformId, solver, solverAddress));
        address signerAddress = ecrecover(h, v, r, s);
        return claimSignerAddress == signerAddress;
    }

    function createClaimMsg(bytes32 platform, string platformId, string solver, address solverAddress) internal pure returns (string) {
        return strings.bytes32ToString(platform)
        .strConcat(prependUnderscore(platformId))
        .strConcat(prependUnderscore(solver))
        .strConcat(prependUnderscore(strings.addressToString(solverAddress)));
    }


    function prependUnderscore(string str) internal pure returns (string) {
        return "_".strConcat(str);
    }

    function setFundRepository(address _repositoryAddress) public onlyOwner {
        fundRepository = FundRepository(_repositoryAddress);
    }

    function setClaimRepository(address _claimRepository) public onlyOwner {
        claimRepository = ClaimRepository(_claimRepository);
    }

    function setTokenAddress(address _tokenAddress) addressNotNull(_tokenAddress) public onlyOwner {
        token = FundRequestToken(_tokenAddress);
        assert(token.isFundRequestToken());
    }

    function setClaimSignerAddress(address _claimSignerAddress) addressNotNull(_claimSignerAddress) public onlyOwner {
        claimSignerAddress = _claimSignerAddress;
    }
}