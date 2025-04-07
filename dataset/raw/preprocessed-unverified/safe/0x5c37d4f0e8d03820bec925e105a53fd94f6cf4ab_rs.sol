/**
 *Submitted for verification at Etherscan.io on 2020-09-30
*/

// File: contracts/lib/SafeMath.sol

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;


/**
 * @title SafeMath
 * @author DODO Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */



// File: contracts/lib/DecimalMath.sol

/*

    Copyright 2020 DODO ZOO.

*/

/**
 * @title DecimalMath
 * @author DODO Breeder
 *
 * @notice Functions for fixed point number with 18 decimals
 */



// File: contracts/lib/Ownable.sol

/*

    Copyright 2020 DODO ZOO.

*/

/**
 * @title Ownable
 * @author DODO Breeder
 *
 * @notice Ownership related functions
 */



// File: contracts/intf/IERC20.sol

// This is a file copied from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// File: contracts/lib/SafeERC20.sol

/*

    Copyright 2020 DODO ZOO.
    This is a simplified version of OpenZepplin's SafeERC20 library

*/

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// File: contracts/token/LockedTokenVault.sol

/*

    Copyright 2020 DODO ZOO.

*/

/**
 * @title LockedTokenVault
 * @author DODO Breeder
 *
 * @notice Lock Token and release it linearly
 */

contract LockedTokenVault is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address _TOKEN_;

    mapping(address => uint256) internal originBalances;
    mapping(address => uint256) internal claimedBalances;

    uint256 public _UNDISTRIBUTED_AMOUNT_;
    uint256 public _START_RELEASE_TIME_;
    uint256 public _RELEASE_DURATION_;
    uint256 public _CLIFF_RATE_;

    bool public _DISTRIBUTE_FINISHED_;

    // ============ Modifiers ============

    event Claim(address indexed holder, uint256 origin, uint256 claimed, uint256 amount);

    // ============ Modifiers ============

    modifier beforeStartRelease() {
        require(block.timestamp < _START_RELEASE_TIME_, "RELEASE START");
        _;
    }

    modifier afterStartRelease() {
        require(block.timestamp >= _START_RELEASE_TIME_, "RELEASE NOT START");
        _;
    }

    modifier distributeNotFinished() {
        require(!_DISTRIBUTE_FINISHED_, "DISTRIBUTE FINISHED");
        _;
    }

    // ============ Init Functions ============

    constructor(
        address _token,
        uint256 _startReleaseTime,
        uint256 _releaseDuration,
        uint256 _cliffRate
    ) public {
        _TOKEN_ = _token;
        _START_RELEASE_TIME_ = _startReleaseTime;
        _RELEASE_DURATION_ = _releaseDuration;
        _CLIFF_RATE_ = _cliffRate;
    }

    function deposit(uint256 amount) external onlyOwner {
        _tokenTransferIn(_OWNER_, amount);
        _UNDISTRIBUTED_AMOUNT_ = _UNDISTRIBUTED_AMOUNT_.add(amount);
    }

    function withdraw(uint256 amount) external onlyOwner {
        _UNDISTRIBUTED_AMOUNT_ = _UNDISTRIBUTED_AMOUNT_.sub(amount);
        _tokenTransferOut(_OWNER_, amount);
    }

    function finishDistribute() external onlyOwner {
        _DISTRIBUTE_FINISHED_ = true;
    }

    // ============ For Owner ============

    function grant(address[] calldata holderList, uint256[] calldata amountList)
        external
        onlyOwner
    {
        require(holderList.length == amountList.length, "batch grant length not match");
        uint256 amount = 0;
        for (uint256 i = 0; i < holderList.length; ++i) {
            // for saving gas, no event for grant
            originBalances[holderList[i]] = originBalances[holderList[i]].add(amountList[i]);
            amount = amount.add(amountList[i]);
        }
        _UNDISTRIBUTED_AMOUNT_ = _UNDISTRIBUTED_AMOUNT_.sub(amount);
    }

    function recall(address holder) external onlyOwner distributeNotFinished {
        _UNDISTRIBUTED_AMOUNT_ = _UNDISTRIBUTED_AMOUNT_.add(originBalances[holder]).sub(
            claimedBalances[holder]
        );
        originBalances[holder] = 0;
        claimedBalances[holder] = 0;
    }

    // ============ For Holder ============

    function transferLockedToken(address to) external {
        originBalances[to] = originBalances[to].add(originBalances[msg.sender]);
        claimedBalances[to] = claimedBalances[to].add(claimedBalances[msg.sender]);

        originBalances[msg.sender] = 0;
        claimedBalances[msg.sender] = 0;
    }

    function claim() external {
        uint256 claimableToken = getClaimableBalance(msg.sender);
        _tokenTransferOut(msg.sender, claimableToken);
        claimedBalances[msg.sender] = claimedBalances[msg.sender].add(claimableToken);
        emit Claim(
            msg.sender,
            originBalances[msg.sender],
            claimedBalances[msg.sender],
            claimableToken
        );
    }

    // ============ View ============

    function isReleaseStart() external view returns (bool) {
        return block.timestamp >= _START_RELEASE_TIME_;
    }

    function getOriginBalance(address holder) external view returns (uint256) {
        return originBalances[holder];
    }

    function getClaimedBalance(address holder) external view returns (uint256) {
        return claimedBalances[holder];
    }

    function getClaimableBalance(address holder) public view returns (uint256) {
        uint256 remainingToken = getRemainingBalance(holder);
        return originBalances[holder].sub(remainingToken).sub(claimedBalances[holder]);
    }

    function getRemainingBalance(address holder) public view returns (uint256) {
        uint256 remainingRatio = getRemainingRatio(block.timestamp);
        return DecimalMath.mul(originBalances[holder], remainingRatio);
    }

    function getRemainingRatio(uint256 timestamp) public view returns (uint256) {
        if (timestamp < _START_RELEASE_TIME_) {
            return DecimalMath.ONE;
        }
        uint256 timePast = timestamp.sub(_START_RELEASE_TIME_);
        if (timePast < _RELEASE_DURATION_) {
            uint256 remainingTime = _RELEASE_DURATION_.sub(timePast);
            return DecimalMath.ONE.sub(_CLIFF_RATE_).mul(remainingTime).div(_RELEASE_DURATION_);
        } else {
            return 0;
        }
    }

    // ============ Internal Helper ============

    function _tokenTransferIn(address from, uint256 amount) internal {
        IERC20(_TOKEN_).safeTransferFrom(from, address(this), amount);
    }

    function _tokenTransferOut(address to, uint256 amount) internal {
        IERC20(_TOKEN_).safeTransfer(to, amount);
    }
}