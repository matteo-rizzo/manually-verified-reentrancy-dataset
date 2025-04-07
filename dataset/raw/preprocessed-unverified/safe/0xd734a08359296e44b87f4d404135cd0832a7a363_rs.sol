/**
 *Submitted for verification at Etherscan.io on 2021-03-04
*/

// File: contracts/lib/InitializableOwnable.sol

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

/**
 * @title Ownable
 * @author DODO Breeder
 *
 * @notice Ownership related functions
 */
contract InitializableOwnable {
    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;

    // ============ Events ============

    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ============ Modifiers ============

    modifier notInitialized() {
        require(!_INITIALIZED_, "DODO_INITIALIZED");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }

    // ============ Functions ============

    function initOwner(address newOwner) public notInitialized {
        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {
        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}

// File: contracts/lib/CloneFactory.sol



// introduction of proxy mode design: https://docs.openzeppelin.com/upgrades/2.8/
// minimum implementation of transparent proxy: https://eips.ethereum.org/EIPS/eip-1167

contract CloneFactory is ICloneFactory {
    function clone(address prototype) external override returns (address proxy) {
        bytes20 targetBytes = bytes20(prototype);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            proxy := create(0, clone, 0x37)
        }
        return proxy;
    }
}

// File: contracts/CrowdPooling/intf/ICP.sol




// File: contracts/lib/SafeMath.sol


/**
 * @title SafeMath
 * @author DODO Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */


// File: contracts/intf/IERC20.sol


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/lib/DecimalMath.sol



/**
 * @title DecimalMath
 * @author DODO Breeder
 *
 * @notice Functions for fixed point number with 18 decimals
 */


// File: contracts/Factory/UpCrowdPoolingFactory.sol


/**
 * @title UpCrowdPoolingFacotry
 * @author DODO Breeder
 *
 * @notice Create And Register vary price CP Pools 
 */
contract UpCrowdPoolingFactory is InitializableOwnable {
    using SafeMath for uint256;
    // ============ Templates ============

    address public immutable _CLONE_FACTORY_;
    address public immutable _DVM_FACTORY_;
    address public immutable _DEFAULT_MAINTAINER_;
    address public immutable _DEFAULT_MT_FEE_RATE_MODEL_;
    address public immutable _DEFAULT_PERMISSION_MANAGER_;
    address public _CP_TEMPLATE_;

    // ============ Settings =============

    uint256 public _FREEZE_DURATION_ =  30 days;
    uint256 public _CALM_DURATION_ = 0;
    uint256 public _VEST_DURATION_ = 0;
    uint256 public _K_ = 0;
    uint256 public _CLIFF_RATE_ = 10**18;


    // ============ Registry ============

    // base -> quote -> CP address list
    mapping(address => mapping(address => address[])) public _REGISTRY_;
    // creator -> CP address list
    mapping(address => address[]) public _USER_REGISTRY_;

    // ============ modifiers ===========

    modifier valueCheck(
        address cpAddress,
        address baseToken,
        uint256[] memory timeLine,
        uint256[] memory valueList)
    {
        require(timeLine[2] == _CALM_DURATION_, "CP_FACTORY : PHASE_CALM_DURATION_INVALID");
        require(timeLine[4] == _VEST_DURATION_, "CP_FACTORY : VEST_DURATION_INVALID");
        require(valueList[1] == _K_, "CP_FACTORY : K_INVALID");
        require(valueList[3] == _CLIFF_RATE_, "CP_FACTORY : CLIFF_RATE_INVALID");
        require(timeLine[3]>= _FREEZE_DURATION_, "CP_FACTORY : FREEZE_DURATION_INVALID");
        _;
    }

    // ============ Events ============

    event NewCP(
        address baseToken,
        address quoteToken,
        address creator,
        address cp
    );

    constructor(
        address cloneFactory,
        address cpTemplate,
        address dvmFactory,
        address defaultMaintainer,
        address defaultMtFeeRateModel,
        address defaultPermissionManager
    ) public {
        _CLONE_FACTORY_ = cloneFactory;
        _CP_TEMPLATE_ = cpTemplate;
        _DVM_FACTORY_ = dvmFactory;
        _DEFAULT_MAINTAINER_ = defaultMaintainer;
        _DEFAULT_MT_FEE_RATE_MODEL_ = defaultMtFeeRateModel;
        _DEFAULT_PERMISSION_MANAGER_ = defaultPermissionManager;
    }

    // ============ Functions ============

    function createCrowdPooling() external returns (address newCrowdPooling) {
        newCrowdPooling = ICloneFactory(_CLONE_FACTORY_).clone(_CP_TEMPLATE_);
    }

    function initCrowdPooling(
        address cpAddress,
        address creator,
        address baseToken,
        address quoteToken,
        uint256[] memory timeLine,
        uint256[] memory valueList,
        bool isOpenTWAP
    ) external valueCheck(cpAddress,baseToken,timeLine,valueList) {
        {
        address[] memory addressList = new address[](7);
        addressList[0] = creator;
        addressList[1] = _DEFAULT_MAINTAINER_;
        addressList[2] = baseToken;
        addressList[3] = quoteToken;
        addressList[4] = _DEFAULT_PERMISSION_MANAGER_;
        addressList[5] = _DEFAULT_MT_FEE_RATE_MODEL_;
        addressList[6] = _DVM_FACTORY_;

        if(valueList[0] == 0) valueList[0] = uint112(-1);

        ICP(cpAddress).init(
            addressList,
            timeLine,
            valueList,
            isOpenTWAP
        );
        }

        _REGISTRY_[baseToken][quoteToken].push(cpAddress);
        _USER_REGISTRY_[creator].push(cpAddress);

        emit NewCP(baseToken, quoteToken, creator, cpAddress);
    }

    // ============ View Functions ============

    function getCrowdPooling(address baseToken, address quoteToken)
        external
        view
        returns (address[] memory pools)
    {
        return _REGISTRY_[baseToken][quoteToken];
    }

    function getCrowdPoolingBidirection(address token0, address token1)
        external
        view
        returns (address[] memory baseToken0Pools, address[] memory baseToken1Pools)
    {
        return (_REGISTRY_[token0][token1], _REGISTRY_[token1][token0]);
    }

    function getCrowdPoolingByUser(address user)
        external
        view
        returns (address[] memory pools)
    {
        return _USER_REGISTRY_[user];
    }

    // ============ Owner Functions ============
    
    function updateCPTemplate(address _newCPTemplate) external onlyOwner {
        _CP_TEMPLATE_ = _newCPTemplate;
    }

    function setFreezeDuration(uint256 _newFreeDuration) public onlyOwner {
        _FREEZE_DURATION_ = _newFreeDuration;
    }

    function setCalmDuration(uint256 _newCalmDuration) public onlyOwner {
        _CALM_DURATION_ = _newCalmDuration;
    }

    function setVestDuration(uint256 _newVestDuration) public onlyOwner {
        _VEST_DURATION_ = _newVestDuration;
    }

    function setK(uint256 _newK) public onlyOwner {
        require(_newK <= 10**18, "CP_FACTORY : INVALID");
        _K_ = _newK;
    }

    function setCliffRate(uint256 _newCliffRate) public onlyOwner {
        require(_newCliffRate <= 10**18, "CP_FACTORY : INVALID");
        _CLIFF_RATE_ = _newCliffRate;
    }
}