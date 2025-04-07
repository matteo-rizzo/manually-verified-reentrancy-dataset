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

// File: contracts\interface\INNIncome.sol

/// @dev This interface defines the methods for NNIncome


// File: contracts\NNIncome.sol

/// @dev NestNode mining contract
contract NNIncome is NestBase, INNIncome {

    // /// @param nestNodeAddress Address of nest node contract
    // /// @param nestTokenAddress Address of nest token contract
    // /// @param nestGenesisBlock Genesis block number of nest
    // constructor(address nestNodeAddress, address nestTokenAddress, uint nestGenesisBlock) {
        
    //     NEST_NODE_ADDRESS = nestNodeAddress;
    //     NEST_TOKEN_ADDRESS = nestTokenAddress;
    //     NEST_GENESIS_BLOCK = nestGenesisBlock;

    //     _blockCursor = block.number;
    // }

    // /// @dev To support open-zeppelin/upgrades
    // /// @param nestGovernanceAddress INestGovernance implementation contract address
    // function initialize(address nestGovernanceAddress) override public {
    //     super.initialize(nestGovernanceAddress);
    // }

    /// @dev Reset the blockCursor
    /// @param blockCursor blockCursor value
    function setBlockCursor(uint blockCursor) override external onlyGovernance {
        _blockCursor = blockCursor;
    }

    // Total supply of nest node
    uint constant NEST_NODE_TOTALSUPPLY = 1500;

    // Address of nest node contract
    address constant NEST_NODE_ADDRESS = 0xC028E81e11F374f7c1A3bE6b8D2a815fa3E96E6e;

    // Generated nest
    uint _generatedNest;
    
    // Latest block number of operationed
    uint _blockCursor;

    // Personal ledger
    mapping(address=>uint) _infoMapping;

    //---------transaction---------

    /// @dev Nest node transfer settlement. This method is triggered during nest node transfer and must be called by nest node contract
    /// @param from Transfer from address
    /// @param to Transfer to address
    function nodeCount(address from, address to) external {
        settle(from, to);
    }

    /// @dev Nest node transfer settlement. This method is triggered during nest node transfer and must be called by nest node contract
    /// @param from Transfer from address
    /// @param to Transfer to address
    function settle(address from, address to) override public {

        require(msg.sender == NEST_NODE_ADDRESS, "NNIncome:!nestNode");
        
        // Check balance
        IERC20 nn = IERC20(NEST_NODE_ADDRESS);
        uint balanceFrom = nn.balanceOf(from);
        require(balanceFrom > 0, "NNIncome:!balance");

        // Calculation of ore drawing increment
        uint generatedNest = _generatedNest = _generatedNest + increment();

        // Update latest block number of operationed
        _blockCursor = block.number;

        mapping(address=>uint) storage infoMapping = _infoMapping;
        // Calculation mining amount for (from)
        uint thisAmountFrom = (generatedNest - infoMapping[from]) * balanceFrom / NEST_NODE_TOTALSUPPLY;
        infoMapping[from] = generatedNest;

        if (thisAmountFrom > 0) {
            require(IERC20(NEST_TOKEN_ADDRESS).transfer(from, thisAmountFrom), "NNIncome:!transfer from");
        }

        // Calculation mining amount for (to)
        uint balanceTo = nn.balanceOf(to);
        if (balanceTo > 0) {
            uint thisAmountTo = (generatedNest - infoMapping[to]) * balanceTo / NEST_NODE_TOTALSUPPLY;
            infoMapping[to] = generatedNest;

            if (thisAmountTo > 0) {
                require(IERC20(NEST_TOKEN_ADDRESS).transfer(to, thisAmountTo), "NNIncome:!transfer to");
            }
        } else {
            infoMapping[to] = generatedNest;
        }
    }

    /// @dev Claim nest
    function claim() override external noContract {
        
        // Check balance
        IERC20 nn = IERC20(NEST_NODE_ADDRESS);
        uint balance = nn.balanceOf(msg.sender);
        require(balance > 0, "NNIncome:!balance");

        // Calculation of ore drawing increment
        uint generatedNest = _generatedNest = _generatedNest + increment();

        // Update latest block number of operationed
        _blockCursor = block.number;

        // Calculation for current mining
        uint thisAmount = (generatedNest - _infoMapping[msg.sender]) * balance / NEST_NODE_TOTALSUPPLY;

        _infoMapping[msg.sender] = generatedNest;

        require(IERC20(NEST_TOKEN_ADDRESS).transfer(msg.sender, thisAmount), "NNIncome:!transfer");
    }

    //---------view----------------

    /// @dev Calculation of ore drawing increment
    /// @return Ore drawing increment
    function increment() override public view returns (uint) {
        //return _redution(block.number - NEST_GENESIS_BLOCK) * (block.number - _blockCursor) * 15 ether / 100;
        return _redution(block.number - NEST_GENESIS_BLOCK) * (block.number - _blockCursor) * 0.15 ether;
    }

    /// @dev Query the current available nest
    /// @param owner Destination address
    /// @return Number of nest currently available
    function earned(address owner) override external view returns (uint) {
        uint balance = IERC20(NEST_NODE_ADDRESS).balanceOf(owner);
        return (_generatedNest + increment() - _infoMapping[owner]) * balance / NEST_NODE_TOTALSUPPLY;
    }

    /// @dev Get generatedNest value
    /// @return GeneratedNest value
    function getGeneratedNest() override external view returns (uint) {
        return _generatedNest;
    }

    /// @dev Get blockCursor value
    /// @return blockCursor value
    function getBlockCursor() override external view returns (uint) {
        return _blockCursor;
    }

    // Nest ore drawing attenuation interval. 2400000 blocks, about one year
    uint constant NEST_REDUCTION_SPAN = 2400000;
    // The decay limit of nest ore drawing becomes stable after exceeding this interval. 24 million blocks, about 10 years
    uint constant NEST_REDUCTION_LIMIT = 24000000; // NEST_REDUCTION_SPAN * 10;
    // Attenuation gradient array, each attenuation step value occupies 16 bits. The attenuation value is an integer
    uint constant NEST_REDUCTION_STEPS = 0x280035004300530068008300A300CC010001400190;
        // 0
        // | (uint(400 / uint(1)) << (16 * 0))
        // | (uint(400 * 8 / uint(10)) << (16 * 1))
        // | (uint(400 * 8 * 8 / uint(10 * 10)) << (16 * 2))
        // | (uint(400 * 8 * 8 * 8 / uint(10 * 10 * 10)) << (16 * 3))
        // | (uint(400 * 8 * 8 * 8 * 8 / uint(10 * 10 * 10 * 10)) << (16 * 4))
        // | (uint(400 * 8 * 8 * 8 * 8 * 8 / uint(10 * 10 * 10 * 10 * 10)) << (16 * 5))
        // | (uint(400 * 8 * 8 * 8 * 8 * 8 * 8 / uint(10 * 10 * 10 * 10 * 10 * 10)) << (16 * 6))
        // | (uint(400 * 8 * 8 * 8 * 8 * 8 * 8 * 8 / uint(10 * 10 * 10 * 10 * 10 * 10 * 10)) << (16 * 7))
        // | (uint(400 * 8 * 8 * 8 * 8 * 8 * 8 * 8 * 8 / uint(10 * 10 * 10 * 10 * 10 * 10 * 10 * 10)) << (16 * 8))
        // | (uint(400 * 8 * 8 * 8 * 8 * 8 * 8 * 8 * 8 * 8 / uint(10 * 10 * 10 * 10 * 10 * 10 * 10 * 10 * 10)) << (16 * 9))
        // //| (uint(400 * 8 * 8 * 8 * 8 * 8 * 8 * 8 * 8 * 8 * 8 / uint(10 * 10 * 10 * 10 * 10 * 10 * 10 * 10 * 10 * 10)) << (16 * 10));
        // | (uint(40) << (16 * 10));

    // Calculation of attenuation gradient
    function _redution(uint delta) private pure returns (uint) {
        
        if (delta < NEST_REDUCTION_LIMIT) {
            return (NEST_REDUCTION_STEPS >> ((delta / NEST_REDUCTION_SPAN) << 4)) & 0xFFFF;
        }
        return (NEST_REDUCTION_STEPS >> 160) & 0xFFFF;
    }
}