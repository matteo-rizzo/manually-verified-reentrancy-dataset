/**
 *Submitted for verification at Etherscan.io on 2021-04-27
*/

// File: contracts\lib\IERC20.sol

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.3;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts\interface\INestLedger.sol

/// @dev This interface defines the nest ledger methods


// File: contracts\interface\INestPriceFacade.sol

/// @dev This interface defines the methods for price call entry


// File: contracts\interface\INestRedeeming.sol

/// @dev This interface defines the methods for redeeming


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

// File: contracts\NestRedeeming.sol

/// @dev The contract is for redeeming nest token and getting ETH in return
contract NestRedeeming is NestBase, INestRedeeming {

    // /// @param nestTokenAddress Address of nest token contract
    // constructor(address nestTokenAddress) {
    //     NEST_TOKEN_ADDRESS = nestTokenAddress;
    // }

    /// @dev Governance information
    struct GovernanceInfo {
        address addr;
        uint96 flag;
    }

    /// @dev Redeeming information
    struct RedeemInfo {
        
        // Redeem quota consumed
        // block.number * quotaPerBlock - quota
        uint128 quota;

        // Redeem threshold by circulation of ntoken, when this value equal to config.activeThreshold, 
        // redeeming is enabled without checking the circulation of the ntoken
        // When config.activeThreshold modified, it will check whether repo is enabled again according to the circulation
        uint32 threshold;
    }

    // Configuration
    Config _config;

    // Redeeming ledger
    mapping(address=>RedeemInfo) _redeemLedger;

    address _nestLedgerAddress;
    address _nestPriceFacadeAddress;

    /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
    ///      super.update(nestGovernanceAddress) when overriding, and override method without onlyGovernance
    /// @param nestGovernanceAddress INestGovernance implementation contract address
    function update(address nestGovernanceAddress) override public {
        super.update(nestGovernanceAddress);

        (
            //address nestTokenAddress
            ,
            //address nestNodeAddress
            ,
            //address nestLedgerAddress
            _nestLedgerAddress, 
            //address nestMiningAddress
            ,
            //address ntokenMiningAddress
            ,
            //address nestPriceFacadeAddress
            _nestPriceFacadeAddress, 
            //address nestVoteAddress
            ,
            //address nestQueryAddress
            , 
            //address nnIncomeAddress
            ,
            //address nTokenControllerAddress
              
        ) = INestGovernance(nestGovernanceAddress).getBuiltinAddress();
    }

    /// @dev Modify configuration
    /// @param config Configuration object
    function setConfig(Config memory config) override external onlyGovernance {
        _config = config;
    }

    /// @dev Get configuration
    /// @return Configuration object
    function getConfig() override external view returns (Config memory) {
        return _config;
    }

    /// @dev Redeem ntokens for ethers
    /// @notice Ethfee will be charged
    /// @param ntokenAddress The address of ntoken
    /// @param amount The amount of ntoken
    /// @param paybackAddress As the charging fee may change, it is suggested that the caller pay more fees, and the excess fees will be returned through this address
    function redeem(address ntokenAddress, uint amount, address paybackAddress) override external payable {
        
        // 1. Load configuration
        Config memory config = _config;

        // 2. Check redeeming stat
        RedeemInfo storage redeemInfo = _redeemLedger[ntokenAddress];
        RedeemInfo memory ri = redeemInfo;
        if (ri.threshold != config.activeThreshold) {
            // Since nest has started redeeming and has a large circulation, we will not check its circulation separately here
            require(IERC20(ntokenAddress).totalSupply() >= uint(config.activeThreshold) * 10000 ether, "NestRedeeming:!totalSupply");
            redeemInfo.threshold = config.activeThreshold;
        }

        // 3. Query price
        (
            /* uint latestPriceBlockNumber */, 
            uint latestPriceValue,
            /* uint triggeredPriceBlockNumber */,
            /* uint triggeredPriceValue */,
            uint triggeredAvgPrice,
            /* uint triggeredSigma */
        ) = INestPriceFacade(_nestPriceFacadeAddress).latestPriceAndTriggeredPriceInfo { value: msg.value } (ntokenAddress, paybackAddress);

        // 4. Calculate the number of eth that can be exchanged for redeem
        uint value = amount * 1 ether / latestPriceValue;

        // 5. Calculate redeem quota
        (uint quota, uint scale) = _quotaOf(config, ri, ntokenAddress);
        redeemInfo.quota = uint128(scale - (quota - amount));

        // 6. Check the redeeming amount and price deviation
        // This check is not required
        // require(quota >= amount, "NestRedeeming:!amount");
        require(
            latestPriceValue * 10000 <= triggeredAvgPrice * (10000 + uint(config.priceDeviationLimit)) && 
            latestPriceValue * 10000 >= triggeredAvgPrice * (10000 - uint(config.priceDeviationLimit)), "NestRedeeming:!price");
        
        // 7. Ntoken transferred to redeem
        address nestLedgerAddress = _nestLedgerAddress;
        TransferHelper.safeTransferFrom(ntokenAddress, msg.sender, nestLedgerAddress, amount);
        
        // 8. Settlement
        // If a token is not a real token, it should also have no funds in the account book and cannot complete the settlement. 
        // Therefore, it is no longer necessary to check whether the token is a legal token
        INestLedger(nestLedgerAddress).pay(ntokenAddress, address(0), msg.sender, value);
    }

    /// @dev Get the current amount available for repurchase
    /// @param ntokenAddress The address of ntoken
    function quotaOf(address ntokenAddress) override public view returns (uint) {

        // 1. Load configuration
        Config memory config = _config;

        // 2. Check redeem state
        RedeemInfo storage redeemInfo = _redeemLedger[ntokenAddress];
        RedeemInfo memory ri = redeemInfo;
        if (ri.threshold != config.activeThreshold) {
            // Since nest has started redeeming and has a large circulation, we will not check its circulation separately here
            if (IERC20(ntokenAddress).totalSupply() < uint(config.activeThreshold) * 10000 ether) 
            {
                return 0;
            }
        }

        // 3. Calculate redeem quota
        (uint quota, ) = _quotaOf(config, ri, ntokenAddress);
        return quota;
    }

    // Calculate redeem quota
    function _quotaOf(Config memory config, RedeemInfo memory ri, address ntokenAddress) private view returns (uint quota, uint scale) {

        // Calculate redeem quota
        uint quotaPerBlock;
        uint quotaLimit;
        // nest config
        if (ntokenAddress == NEST_TOKEN_ADDRESS) {
            quotaPerBlock = uint(config.nestPerBlock);
            quotaLimit = uint(config.nestLimit);
        } 
        // ntoken config
        else {
            quotaPerBlock = uint(config.ntokenPerBlock);
            quotaLimit = uint(config.ntokenLimit);
        }
        // Calculate
        scale = block.number * quotaPerBlock * 1 ether;
        quota = scale - ri.quota;
        if (quota > quotaLimit * 1 ether) {
            quota = quotaLimit * 1 ether;
        }
    }
}