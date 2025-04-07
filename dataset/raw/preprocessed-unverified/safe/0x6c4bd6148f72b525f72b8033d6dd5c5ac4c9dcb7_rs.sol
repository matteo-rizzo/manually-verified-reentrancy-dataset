/**
 *Submitted for verification at Etherscan.io on 2021-04-27
*/

// File: contracts\lib\IERC20.sol

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.3;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts\lib\TransferHelper.sol

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false


// File: contracts\interface\INTokenController.sol

///@dev This interface defines the methods for ntoken management


// File: contracts\interface\INToken.sol

/// @dev ntoken interface


// File: contracts\interface\INestMapping.sol

/// @dev The interface defines methods for nest builtin contract address mapping


// File: contracts\interface\INestGovernance.sol

/// @dev This interface defines the governance methods
interface INestGovernance is INestMapping {

    /// @dev Set governance authority
    /// @param addr Destination address
    /// @param flag Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    /// @dev Get governance rights
    /// @param addr Destination address
    /// @return Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    /// @dev Check whether the target address has governance rights for the given target
    /// @param addr Destination address
    /// @param flag Permission weight. The permission of the target address must be greater than this weight to pass the check
    /// @return True indicates permission
    function checkGovernance(address addr, uint flag) external view returns (bool);
}

// File: contracts\interface\INestLedger.sol

/// @dev This interface defines the nest ledger methods


// File: contracts\NestBase.sol

/// @dev Base contract of nest
contract NestBase {

    // Address of nest token contract
    address constant NEST_TOKEN_ADDRESS = 0x04abEdA201850aC0124161F037Efd70c74ddC74C;

    // Genesis block number of nest
    // NEST token contract is created at block height 6913517. However, because the mining algorithm of nest1.0
    // is different from that at present, a new mining algorithm is adopted from nest2.0. The new algorithm
    // includes the attenuation logic according to the block. Therefore, it is necessary to trace the block
    // where the nest begins to decay. According to the circulation when nest2.0 is online, the new mining
    // algorithm is used to deduce and convert the nest, and the new algorithm is used to mine the nest2.0
    // on-line flow, the actual block is 5120000
    uint constant NEST_GENESIS_BLOCK = 5120000;

    /// @dev To support open-zeppelin/upgrades
    /// @param nestGovernanceAddress INestGovernance implementation contract address
    function initialize(address nestGovernanceAddress) virtual public {
        require(_governance == address(0), 'NEST:!initialize');
        _governance = nestGovernanceAddress;
    }

    /// @dev INestGovernance implementation contract address
    address public _governance;

    /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
    ///      super.update(nestGovernanceAddress) when overriding, and override method without onlyGovernance
    /// @param nestGovernanceAddress INestGovernance implementation contract address
    function update(address nestGovernanceAddress) virtual public {

        address governance = _governance;
        require(governance == msg.sender || INestGovernance(governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _governance = nestGovernanceAddress;
    }

    /// @dev Migrate funds from current contract to NestLedger
    /// @param tokenAddress Destination token address.(0 means eth)
    /// @param value Migrate amount
    function migrate(address tokenAddress, uint value) external onlyGovernance {

        address to = INestGovernance(_governance).getNestLedgerAddress();
        if (tokenAddress == address(0)) {
            INestLedger(to).addETHReward { value: value } (address(0));
        } else {
            TransferHelper.safeTransfer(tokenAddress, to, value);
        }
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(INestGovernance(_governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _;
    }

    modifier noContract() {
        require(msg.sender == tx.origin, "NEST:!contract");
        _;
    }
}

// File: contracts\NToken.sol

// The contract is based on Nest_NToken from Nest Protocol v3.0. Considering compatibility, the interface
// keeps the same. 
/// @dev ntoken contract
contract NToken is NestBase, INToken {

    /// @notice Constructor
    /// @dev Given the address of NestPool, NToken can get other contracts by calling addrOfxxx()
    /// @param _name The name of NToken
    /// @param _symbol The symbol of NToken
    constructor (string memory _name, string memory _symbol) {

        GENESIS_BLOCK_NUMBER = block.number;
        name = _name;                                                               
        symbol = _symbol;
        _state = block.number;
    }

    // INestMining implementation contract address
    address _ntokenMiningAddress;
    
    // token information: name
    string public name;

    // token information: symbol
    string public symbol;

    // token information: decimals
    uint8 constant public decimals = 18;

    // token stateï¼Œhigh 128 bits represent _totalSupply, low 128 bits represent lastestMintAtHeight
    uint256 _state;
    
    // Balances ledger
    mapping (address=>uint) private _balances;

    // Approve ledger
    mapping (address=>mapping(address=>uint)) private _allowed;

    // ntoken genesis block number
    uint256 immutable public GENESIS_BLOCK_NUMBER;

    /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
    ///      super.update(nestGovernanceAddress) when overriding, and override method without onlyGovernance
    /// @param nestGovernanceAddress INestGovernance implementation contract address
    function update(address nestGovernanceAddress) override public {
        super.update(nestGovernanceAddress);
        _ntokenMiningAddress = INestGovernance(nestGovernanceAddress).getNTokenMiningAddress();
    }

    /// @dev Mint 
    /// @param value The amount of NToken to add
    function increaseTotal(uint256 value) override public {

        require(msg.sender == _ntokenMiningAddress, "NToken:!Auth");
        
        // Increases balance for target address
        _balances[msg.sender] += value;

        // Increases total supply
        uint totalSupply_ = (_state >> 128) + value;
        require(totalSupply_ < 0x100000000000000000000000000000000, "NToken:!totalSupply");
        // Total supply and lastest mint height share one storage unit
        _state = (totalSupply_ << 128) | block.number;
    }
        
    /// @notice The view of variables about minting 
    /// @dev The naming follows Nestv3.0
    /// @return createBlock The block number where the contract was created
    /// @return recentlyUsedBlock The block number where the last minting went
    function checkBlockInfo() 
        override public view 
        returns(uint256 createBlock, uint256 recentlyUsedBlock) 
    {
        return (GENESIS_BLOCK_NUMBER, _state & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    }

    /// @dev The ABI keeps unchanged with old NTokens, so as to support token-and-ntoken-mining
    /// @return The address of bidder
    function checkBidder() override public view returns(address) {
        return _ntokenMiningAddress;
    }

    /// @notice The view of totalSupply
    /// @return The total supply of ntoken
    function totalSupply() override public view returns (uint256) {
        // The high 128 bits means total supply
        return _state >> 128;
    }

    /// @dev The view of balances
    /// @param owner The address of an account
    /// @return The balance of the account
    function balanceOf(address owner) override public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) override public view returns (uint256) 
    {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) override public returns (bool) 
    {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) override public returns (bool) 
    {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) override public returns (bool) 
    {
        mapping(address=>uint) storage allowed = _allowed[from];
        allowed[msg.sender] -= value;
        _transfer(from, to, value);
        emit Approval(from, msg.sender, allowed[msg.sender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) 
    {
        require(spender != address(0));

        mapping(address=>uint) storage allowed = _allowed[msg.sender];
        allowed[spender] += addedValue;
        emit Approval(msg.sender, spender, allowed[spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) 
    {
        require(spender != address(0));

        mapping(address=>uint) storage allowed = _allowed[msg.sender];
        allowed[spender] -= subtractedValue;
        emit Approval(msg.sender, spender, allowed[spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        _balances[from] -= value;
        _balances[to] += value;
        emit Transfer(from, to, value);
    }
}

// File: contracts\NTokenController.sol

/// @dev NToken Controller, management for ntoken
contract NTokenController is NestBase, INTokenController {

    // /// @param nestTokenAddress Address of nest token contract
    // constructor(address nestTokenAddress)
    // {
    //     NEST_TOKEN_ADDRESS = nestTokenAddress;
    // }

    // Configuration
    Config _config;

    // ntoken information array
    NTokenTag[] _nTokenTagList;

    // A mapping for all ntoken
    mapping(address=>uint) public _nTokenTags;

    /* ========== Governance ========== */

    /// @dev Modify configuration
    /// @param config Configuration object
    function setConfig(Config memory config) override external onlyGovernance {
        require(uint(config.state) <= 1, "NTokenController:!value");
        _config = config;
    }

    /// @dev Get configuration
    /// @return Configuration object
    function getConfig() override external view returns (Config memory) {
        return _config;
    }

    /// @dev Set the token mapping
    /// @param tokenAddress Destination token address
    /// @param ntokenAddress Destination ntoken address
    /// @param state status for this map
    function setNTokenMapping(address tokenAddress, address ntokenAddress, uint state) override external onlyGovernance {
        
        uint index = _nTokenTags[tokenAddress];
        if (index == 0) {

            _nTokenTagList.push(NTokenTag(
                // address ntokenAddress;
                ntokenAddress,
                // uint96 nestFee;
                uint96(0),
                // address tokenAddress;
                tokenAddress,
                // uint40 index;
                uint40(_nTokenTagList.length),
                // uint48 startTime;
                uint48(block.timestamp),
                // uint8 state;  
                uint8(state)
            ));
            _nTokenTags[tokenAddress] = _nTokenTags[ntokenAddress] = _nTokenTagList.length;
        } else {

            NTokenTag memory tag = _nTokenTagList[index - 1];
            tag.ntokenAddress = ntokenAddress;
            tag.tokenAddress = tokenAddress;
            tag.index = uint40(index - 1);
            tag.startTime = uint48(block.timestamp);
            tag.state = uint8(state);

            _nTokenTagList[index - 1] = tag;
            _nTokenTags[tokenAddress] = _nTokenTags[ntokenAddress] = index;
        }
    }

    /// @dev Get token address from ntoken address
    /// @param ntokenAddress Destination ntoken address
    /// @return token address
    function getTokenAddress(address ntokenAddress) override external view returns (address) {

        uint index = _nTokenTags[ntokenAddress];
        if (index > 0) {
            return _nTokenTagList[index - 1].tokenAddress;
        }
        return address(0);
    }

    /// @dev Get ntoken address from token address
    /// @param tokenAddress Destination token address
    /// @return ntoken address
    function getNTokenAddress(address tokenAddress) override public view returns (address) {

        uint index = _nTokenTags[tokenAddress];
        if (index > 0) {
            return _nTokenTagList[index - 1].ntokenAddress;
        }
        return address(0);
    }

    /* ========== ntoken management ========== */
    
    /// @dev Bad tokens should be banned 
    function disable(address tokenAddress) override external onlyGovernance
    {
        // When tokenAddress does not exist, _nTokenTags[tokenAddress] - 1 will overflow error
        _nTokenTagList[_nTokenTags[tokenAddress] - 1].state = 0;
        emit NTokenDisabled(tokenAddress);
    }

    /// @dev enable ntoken
    function enable(address tokenAddress) override external onlyGovernance
    {
        // When tokenAddress does not exist, _nTokenTags[tokenAddress] - 1 will overflow error
        _nTokenTagList[_nTokenTags[tokenAddress] - 1].state = 1;
        emit NTokenEnabled(tokenAddress);
    }

    /// @notice Open a NToken for a token by anyone (contracts aren't allowed)
    /// @dev Create and map the (Token, NToken) pair in NestPool
    /// @param tokenAddress The address of token contract
    function open(address tokenAddress) override external noContract
    {
        Config memory config = _config;
        require(config.state == 1, "NTokenController:!state");

        // Check token mapping
        require(getNTokenAddress(tokenAddress) == address(0), "NTokenController:!exists");

        // Check token state
        uint index = _nTokenTags[tokenAddress];
        require(index == 0 || _nTokenTagList[index - 1].state == 0, "NTokenController:!active");

        uint ntokenCounter = _nTokenTagList.length;

        // Create ntoken contract
        string memory sn = getAddressStr(ntokenCounter);
        NToken ntoken = new NToken(strConcat("NToken", sn), strConcat("N", sn));

        address governance = _governance;
        ntoken.initialize(address(this));
        ntoken.update(governance);

        // Is token valid ?
        TransferHelper.safeTransferFrom(tokenAddress, msg.sender, address(this), 1);
        require(IERC20(tokenAddress).balanceOf(address(this)) >= 1, "NTokenController:!transfer");
        TransferHelper.safeTransfer(tokenAddress, msg.sender, 1);

        // Pay nest
        IERC20(NEST_TOKEN_ADDRESS).transferFrom(msg.sender, governance, uint(config.openFeeNestAmount));

        // TODO: Consider how to migrate the existing token information
        _nTokenTags[tokenAddress] = _nTokenTags[address(ntoken)] = ntokenCounter + 1;
        _nTokenTagList.push(NTokenTag(
            // address ntokenAddress;
            address(ntoken),
            // uint96 nestFee;
            config.openFeeNestAmount,
            // address tokenAddress;
            tokenAddress,
            // uint40 index;
            uint40(_nTokenTagList.length),
            // uint48 startTime;
            uint48(block.timestamp),
            // uint8 state;  
            1
        ));

        emit NTokenOpened(tokenAddress, address(ntoken), msg.sender);
    }

    /* ========== VIEWS ========== */

    /// @dev Get ntoken information
    /// @param tokenAddress Destination token address
    /// @return ntoken information
    function getNTokenTag(address tokenAddress) override external view returns (NTokenTag memory) 
    {
        return _nTokenTagList[_nTokenTags[tokenAddress] - 1];
    }

    /// @dev Get opened ntoken count
    /// @return ntoken count
    function getNTokenCount() override external view returns (uint) {
        return _nTokenTagList.length;
    }

    /// @dev List ntoken information by page
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return ntoken information by page
    function list(uint offset, uint count, uint order) override external view returns (NTokenTag[] memory) {
        
        NTokenTag[] storage nTokenTagList = _nTokenTagList;
        NTokenTag[] memory result = new NTokenTag[](count);
        uint length = nTokenTagList.length;
        uint i = 0;

        // Reverse order
        if (order == 0) {

            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                result[i++] = nTokenTagList[--index];
            }
        } 
        // Positive order
        else {
            
            uint index = offset;
            uint end = index + count;
            if (end > length) {
                end = length;
            }
            while (index < end) {
                result[i++] = nTokenTagList[index++];
            }
        }

        return result;
    }

    /* ========== HELPERS ========== */

    /// @dev from NESTv3.0
    function strConcat(string memory _a, string memory _b) public pure returns (string memory)
    {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) {
            bret[k++] = _ba[i];
        } 
        for (uint i = 0; i < _bb.length; i++) {
            bret[k++] = _bb[i];
        } 
        return string(ret);
    } 
    
    /// @dev Convert number into a string, if less than 4 digits, make up 0 in front, from NestV3.0
    function getAddressStr(uint256 iv) public pure returns (string memory) 
    {
        bytes memory buf = new bytes(64);
        uint256 index = 0;
        do {
            buf[index++] = bytes1(uint8(iv % 10 + 48));
            iv /= 10;
        } while (iv > 0 || index < 4);
        bytes memory str = new bytes(index);
        for(uint256 i = 0; i < index; ++i) {
            str[i] = buf[index - i - 1];
        }
        return string(str);
    }
}