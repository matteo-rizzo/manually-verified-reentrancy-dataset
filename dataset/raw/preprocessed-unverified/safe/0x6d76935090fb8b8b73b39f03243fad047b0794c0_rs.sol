/**
 *Submitted for verification at Etherscan.io on 2021-04-27
*/

// File: contracts\interface\INestMapping.sol

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.3;

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

// File: contracts\lib\IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts\interface\INestQuery.sol

/// @dev This interface defines the methods for price query


// File: contracts\lib\TransferHelper.sol

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false


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

// File: contracts\NestMapping.sol

/// @dev The contract is for nest builtin contract address mapping
abstract contract NestMapping is NestBase, INestMapping {

    // constructor() { }

    /// @dev Address of nest token contract
    address _nestTokenAddress;

    /// @dev Address of nest node contract
    address _nestNodeAddress;

    /// @dev INestLedger implementation contract address
    address _nestLedgerAddress;

    /// @dev INestMining implementation contract address for nest
    address _nestMiningAddress;

    /// @dev INestMining implementation contract address for ntoken
    address _ntokenMiningAddress;

    /// @dev INestPriceFacade implementation contract address
    address _nestPriceFacadeAddress;

    /// @dev INestVote implementation contract address
    address _nestVoteAddress;

    /// @dev INestQuery implementation contract address
    address _nestQueryAddress;

    /// @dev NNIncome contract address
    address _nnIncomeAddress;

    /// @dev INTokenController implementation contract address
    address _nTokenControllerAddress;
    
    /// @dev Address registered in the system
    mapping(string=>address) _registeredAddress;

    /// @dev Set the built-in contract address of the system
    /// @param nestTokenAddress Address of nest token contract
    /// @param nestNodeAddress Address of nest node contract
    /// @param nestLedgerAddress INestLedger implementation contract address
    /// @param nestMiningAddress INestMining implementation contract address for nest
    /// @param ntokenMiningAddress INestMining implementation contract address for ntoken
    /// @param nestPriceFacadeAddress INestPriceFacade implementation contract address
    /// @param nestVoteAddress INestVote implementation contract address
    /// @param nestQueryAddress INestQuery implementation contract address
    /// @param nnIncomeAddress NNIncome contract address
    /// @param nTokenControllerAddress INTokenController implementation contract address
    function setBuiltinAddress(
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    ) override external onlyGovernance {
        
        if (nestTokenAddress != address(0)) {
            _nestTokenAddress = nestTokenAddress;
        }
        if (nestNodeAddress != address(0)) {
            _nestNodeAddress = nestNodeAddress;
        }
        if (nestLedgerAddress != address(0)) {
            _nestLedgerAddress = nestLedgerAddress;
        }
        if (nestMiningAddress != address(0)) {
            _nestMiningAddress = nestMiningAddress;
        }
        if (ntokenMiningAddress != address(0)) {
            _ntokenMiningAddress = ntokenMiningAddress;
        }
        if (nestPriceFacadeAddress != address(0)) {
            _nestPriceFacadeAddress = nestPriceFacadeAddress;
        }
        if (nestVoteAddress != address(0)) {
            _nestVoteAddress = nestVoteAddress;
        }
        if (nestQueryAddress != address(0)) {
            _nestQueryAddress = nestQueryAddress;
        }
        if (nnIncomeAddress != address(0)) {
            _nnIncomeAddress = nnIncomeAddress;
        }
        if (nTokenControllerAddress != address(0)) {
            _nTokenControllerAddress = nTokenControllerAddress;
        }
    }

    /// @dev Get the built-in contract address of the system
    /// @return nestTokenAddress Address of nest token contract
    /// @return nestNodeAddress Address of nest node contract
    /// @return nestLedgerAddress INestLedger implementation contract address
    /// @return nestMiningAddress INestMining implementation contract address for nest
    /// @return ntokenMiningAddress INestMining implementation contract address for ntoken
    /// @return nestPriceFacadeAddress INestPriceFacade implementation contract address
    /// @return nestVoteAddress INestVote implementation contract address
    /// @return nestQueryAddress INestQuery implementation contract address
    /// @return nnIncomeAddress NNIncome contract address
    /// @return nTokenControllerAddress INTokenController implementation contract address
    function getBuiltinAddress() override external view returns (
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    ) {
        return (
            _nestTokenAddress,
            _nestNodeAddress,
            _nestLedgerAddress,
            _nestMiningAddress,
            _ntokenMiningAddress,
            _nestPriceFacadeAddress,
            _nestVoteAddress,
            _nestQueryAddress,
            _nnIncomeAddress,
            _nTokenControllerAddress
        );
    }

    /// @dev Get address of nest token contract
    /// @return Address of nest token contract
    function getNestTokenAddress() override external view returns (address) { return _nestTokenAddress; }

    /// @dev Get address of nest node contract
    /// @return Address of nest node contract
    function getNestNodeAddress() override external view returns (address) { return _nestNodeAddress; }

    /// @dev Get INestLedger implementation contract address
    /// @return INestLedger implementation contract address
    function getNestLedgerAddress() override external view returns (address) { return _nestLedgerAddress; }

    /// @dev Get INestMining implementation contract address for nest
    /// @return INestMining implementation contract address for nest
    function getNestMiningAddress() override external view returns (address) { return _nestMiningAddress; }

    /// @dev Get INestMining implementation contract address for ntoken
    /// @return INestMining implementation contract address for ntoken
    function getNTokenMiningAddress() override external view returns (address) { return _ntokenMiningAddress; }

    /// @dev Get INestPriceFacade implementation contract address
    /// @return INestPriceFacade implementation contract address
    function getNestPriceFacadeAddress() override external view returns (address) { return _nestPriceFacadeAddress; }

    /// @dev Get INestVote implementation contract address
    /// @return INestVote implementation contract address
    function getNestVoteAddress() override external view returns (address) { return _nestVoteAddress; }

    /// @dev Get INestQuery implementation contract address
    /// @return INestQuery implementation contract address
    function getNestQueryAddress() override external view returns (address) { return _nestQueryAddress; }

    /// @dev Get NNIncome contract address
    /// @return NNIncome contract address
    function getNnIncomeAddress() override external view returns (address) { return _nnIncomeAddress; }

    /// @dev Get INTokenController implementation contract address
    /// @return INTokenController implementation contract address
    function getNTokenControllerAddress() override external view returns (address) { return _nTokenControllerAddress; }

    /// @dev Registered address. The address registered here is the address accepted by nest system
    /// @param key The key
    /// @param addr Destination address. 0 means to delete the registration information
    function registerAddress(string memory key, address addr) override external onlyGovernance {
        _registeredAddress[key] = addr;
    }

    /// @dev Get registered address
    /// @param key The key
    /// @return Destination address. 0 means empty
    function checkAddress(string memory key) override external view returns (address) {
        return _registeredAddress[key];
    }
}

// File: contracts\NestGovernance.sol

/// @dev Nest governance contract
contract NestGovernance is NestMapping, INestGovernance {

    // constructor() {
    //     _governance = address(this);
    //     _governanceMapping[msg.sender] = GovernanceInfo(msg.sender, uint96(0xFFFFFFFFFFFFFFFFFFFFFFFF));
    // }

    /// @dev To support open-zeppelin/upgrades
    /// @param nestGovernanceAddress INestGovernance implementation contract address
    function initialize(address nestGovernanceAddress) override public {

        // While initialize NestGovernance, nestGovernanceAddress is address(this),
        // So must let nestGovernanceAddress to 0
        require(nestGovernanceAddress == address(0), "NestGovernance:!address");

        // nestGovernanceAddress is address(this)
        super.initialize(address(this));

        // Add msg.sender to governance
        _governanceMapping[msg.sender] = GovernanceInfo(msg.sender, uint96(0xFFFFFFFFFFFFFFFFFFFFFFFF));
    }

    /// @dev Structure of governance address information
    struct GovernanceInfo {
        address addr;
        uint96 flag;
    }

    /// @dev Governance address information
    mapping(address=>GovernanceInfo) _governanceMapping;

    /// @dev Set governance authority
    /// @param addr Destination address
    /// @param flag Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) override external onlyGovernance {
        
        if (flag > 0) {
            _governanceMapping[addr] = GovernanceInfo(addr, uint96(flag));
        } else {
            _governanceMapping[addr] = GovernanceInfo(address(0), uint96(0));
        }
    }

    /// @dev Get governance rights
    /// @param addr Destination address
    /// @return Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) override external view returns (uint) {
        return _governanceMapping[addr].flag;
    }

    /// @dev Check whether the target address has governance rights for the given target
    /// @param addr Destination address
    /// @param flag Permission weight. The permission of the target address must be greater than this weight to pass the check
    /// @return True indicates permission
    function checkGovernance(address addr, uint flag) override public view returns (bool) {
        return _governanceMapping[addr].flag > flag;
    }

    /// @dev This method is for ntoken in created in nest3.0
    /// @param addr Destination address
    /// @return True indicates permission
    function checkOwners(address addr) external view returns (bool) {
        return checkGovernance(addr, 0);
    }
}