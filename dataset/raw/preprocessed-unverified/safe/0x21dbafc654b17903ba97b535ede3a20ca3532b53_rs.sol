/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

// Dependency file: contracts/modules/ConfigNames.sol

// SPDX-License-Identifier: MIT
// pragma solidity >=0.5.16;



// Root file: contracts/AAAADeploy.sol

pragma solidity >=0.6.6;
pragma experimental ABIEncoderV2;

// import 'contracts/modules/ConfigNames.sol';



















contract AAAADeploy {
    address public owner;
    address public config;
    address public LPStrategyFactory;
    bool public LPStrategyCanMint;

    modifier onlyOwner() {
        require(msg.sender == owner, 'OWNER FORBIDDEN');
        _;
    }
 
    constructor() public {
        owner = msg.sender;
    }
    
    function setupConfig(address _config) onlyOwner external {
        require(_config != address(0), "ZERO ADDRESS");
        config = _config;
    }

    function changeDeveloper(address _developer) onlyOwner external {
        IConfig(config).changeDeveloper(_developer);
    }
    
    function setMasterchef(address _LPStrategyFactory, bool _LPStrategyCanMint) onlyOwner external {
        LPStrategyFactory = _LPStrategyFactory;
        LPStrategyCanMint = _LPStrategyCanMint;
    }

    function createPool(address _lendToken, address _collateralToken, uint _lpPoolpid) onlyOwner public {
        if(LPStrategyCanMint) {
            require(IConfig(config).isMintToken(_lendToken), 'REQUEST ADD MINT TOKEN FIRST');
        }
        address pool = IAAAAFactory(IConfig(config).factory()).createPool(_lendToken, _collateralToken);
        address strategy = ILPStrategyFactory(LPStrategyFactory).createStrategy(_collateralToken, pool, _lpPoolpid);
        IAAAAPlatform(IConfig(config).platform()).switchStrategy(_lendToken, _collateralToken, strategy);
    }

    function changeBallotByteHash(bytes32 _hash) onlyOwner external {
        IAAAAFactory(IConfig(config).factory()).changeBallotByteHash(_hash);
    }

    function addMintToken(address _token) onlyOwner external {
        IConfig(config).addMintToken(_token);
    }

    function changeMintPerBlock(uint _value) onlyOwner external {
        IConfig(config).setValue(ConfigNames.MINT_AMOUNT_PER_BLOCK, _value);
        IAAAAMint(IConfig(config).mint()).sync();
    }

    function setShareToken(address _shareToken) onlyOwner external {
        IAAAAShare(IConfig(config).share()).setShareToken(_shareToken);
    }

  }