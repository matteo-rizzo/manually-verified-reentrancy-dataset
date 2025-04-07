/**
 *Submitted for verification at Etherscan.io on 2021-09-25
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

// File: contracts/intf/IERC20.sol


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/lib/SafeMath.sol



/**
 * @title SafeMath
 * @author DODO Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */


// File: contracts/GeneralizedFragment/impl/BuyoutModel.sol







contract BuyoutModel is InitializableOwnable {
    using SafeMath for uint256;

    uint256 public _MIN_FRAG_ = 100; //0.1
    uint256 public _MAX_FRAG_ = 1000; //1
    int public _BUYOUT_FEE_ = 0;

    struct FragInfo {
        uint256 minFrag;
        uint256 maxFrag;
        address buyoutAddr;
        bool isSet;
    }

    mapping(address => FragInfo) frags;

    function addFragInfo(address fragAddr, uint256 minFrag, uint256 maxFrag, address buyoutAddr) external onlyOwner {
        FragInfo memory fragInfo =  FragInfo({
            minFrag: minFrag,
            maxFrag: maxFrag,
            buyoutAddr: buyoutAddr,
            isSet: true
        });
        frags[fragAddr] = fragInfo;
    }

    function setFragInfo(address fragAddr, uint256 minFrag, uint256 maxFrag, address buyoutAddr) external onlyOwner {
        frags[fragAddr].minFrag = minFrag;
        frags[fragAddr].maxFrag = maxFrag;
        frags[fragAddr].buyoutAddr = buyoutAddr;
    }

    function setGlobalParam(uint256 minFrag, uint256 maxFrag, uint256 buyoutFee) external onlyOwner {
        require(minFrag <= 1000 && maxFrag <= 1000, "PARAM_INVALID");
        _MIN_FRAG_ = minFrag;
        _MAX_FRAG_ = maxFrag;
        _BUYOUT_FEE_ = int(buyoutFee);
    }

    function getBuyoutStatus(address fragAddr, address user) external view returns (int) {
        FragInfo memory fragInfo = frags[fragAddr];
        
        uint256 userBalance = IERC20(fragAddr).balanceOf(user);
        uint256 totalSupply = IERC20(fragAddr).totalSupply();
        uint256 minFrag = _MIN_FRAG_;
        uint256 maxFrag = _MAX_FRAG_;

        if(fragInfo.isSet) {
            address buyoutAddr = fragInfo.buyoutAddr;
            if(buyoutAddr != address(0)) {
                bool isQualified = IBuyout(buyoutAddr).getBuyoutQualification(user);
                if(isQualified) {
                    return _BUYOUT_FEE_;
                }else {
                    return -1;
                }
            }

            minFrag = fragInfo.minFrag;
            maxFrag = fragInfo.maxFrag;
        }

        if(userBalance >= totalSupply.mul(minFrag).div(1000) && userBalance <= totalSupply.mul(maxFrag).div(1000)) {
            return _BUYOUT_FEE_;
        }else {
            return -1;
        }
    }
}