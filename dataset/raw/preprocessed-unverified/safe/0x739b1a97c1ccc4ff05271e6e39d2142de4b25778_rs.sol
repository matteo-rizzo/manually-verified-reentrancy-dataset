/**
 * Copyright 2017-2020, bZeroX, LLC <https://bzx.network/>. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "unauthorized");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Collection of functions related to the address type
 */


contract IERC20 {
    string public name;
    uint8 public decimals;
    string public symbol;
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function approve(address _spender, uint256 _value) public returns (bool);
    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Library for managing loan sets
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * Include with `using EnumerableBytes32Set for EnumerableBytes32Set.Bytes32Set;`.
 *
 */


contract StakingState is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableBytes32Set for EnumerableBytes32Set.Bytes32Set;

    uint256 public constant initialCirculatingSupply = 1030000000e18 - 889389933e18;
    address internal constant ZERO_ADDRESS = address(0);

    address public BZRX;
    address public vBZRX;
    address public LPToken;

    address public implementation;

    bool public isInit;
    bool public isActive;

    mapping(address => uint256) internal _totalSupplyPerToken;                      // token => value
    mapping(address => mapping(address => uint256)) internal _balancesPerToken;     // token => account => value
    mapping(address => mapping(address => uint256)) internal _checkpointPerToken;   // token => account => value

    mapping(address => address) public delegate;                                    // user => delegate
    mapping(address => mapping(address => uint256)) public repStakedPerToken;       // token => user => value
    mapping(address => bool) public reps;                                           // user => isActive

    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;                      // user => value
    mapping(address => uint256) public rewards;                                     // user => value

    EnumerableBytes32Set.Bytes32Set internal repStakedSet;

    uint256 public lastUpdateTime;
    uint256 public periodFinish;
    uint256 public rewardRate;
}

contract StakingInterim is StakingState {

    struct RepStakedTokens {
        address wallet;
        bool isActive;
        uint256 BZRX;
        uint256 vBZRX;
        uint256 LPToken;
    }

    event Staked(
        address indexed user,
        address indexed token,
        address indexed delegate,
        uint256 amount
    );

    event DelegateChanged(
        address indexed user,
        address indexed oldDelegate,
        address indexed newDelegate
    );

    event RewardAdded(
        uint256 indexed reward,
        uint256 duration
    );

    modifier checkActive() {
        require(isActive, "not active");
        _;
    }
 
    function init(
        address _BZRX,
        address _vBZRX,
        address _LPToken,
        bool _isActive)
        external
        onlyOwner
    {
        require(!isInit, "already init");
        
        BZRX = _BZRX;
        vBZRX = _vBZRX;
        LPToken = _LPToken;

        isActive = _isActive;

        isInit = true;
    }

    function setActive(
        bool _isActive)
        public
        onlyOwner
    {
        require(isInit, "not init");
        isActive = _isActive;
    }

    function rescueToken(
        IERC20 token,
        address receiver,
        uint256 amount)
        external
        onlyOwner
        returns (uint256 withdrawAmount)
    {
        withdrawAmount = token.balanceOf(address(this));
        if (withdrawAmount > amount) {
            withdrawAmount = amount;
        }
        if (withdrawAmount != 0) {
            token.safeTransfer(
                receiver,
                withdrawAmount
            );
        }
    }

    function stake(
        address[] memory tokens,
        uint256[] memory values)
        public
    {
        stakeWithDelegate(
            tokens,
            values,
            ZERO_ADDRESS
        );
    }

    function stakeWithDelegate(
        address[] memory tokens,
        uint256[] memory values,
        address delegateToSet)
        public
        checkActive
        updateReward(msg.sender)
    {
        require(tokens.length == values.length, "count mismatch");

        address currentDelegate = _setDelegate(delegateToSet);

        address token;
        uint256 stakeAmount;
        for (uint256 i = 0; i < tokens.length; i++) {
            token = tokens[i];
            stakeAmount = values[i];

            if (stakeAmount == 0) {
                continue;
            }

            require(token == BZRX || token == vBZRX || token == LPToken, "invalid token");
            require(stakeAmount <= stakeableByAsset(token, msg.sender), "insufficient balance");

            _balancesPerToken[token][msg.sender] = _balancesPerToken[token][msg.sender].add(stakeAmount);
            _totalSupplyPerToken[token] = _totalSupplyPerToken[token].add(stakeAmount);

            emit Staked(
                msg.sender,
                token,
                currentDelegate,
                stakeAmount
            );

            repStakedPerToken[currentDelegate][token] = repStakedPerToken[currentDelegate][token]
                .add(stakeAmount);
        }
    }

    function setRepActive(
        bool _isActive)
        public
    {
        reps[msg.sender] = _isActive;
        if (_isActive) {
            repStakedSet.addAddress(msg.sender);
        }
    }

    function getRepVotes(
        uint256 start,
        uint256 count)
        external
        view
        returns (RepStakedTokens[] memory repStakedArr)
    {
        uint256 end = start.add(count).min256(repStakedSet.length());
        if (start >= end) {
            return repStakedArr;
        }
        count = end-start;

        uint256 idx = count;
        address wallet;
        repStakedArr = new RepStakedTokens[](idx);
        for (uint256 i = --end; i >= start; i--) {
            wallet = repStakedSet.getAddress(i);
            repStakedArr[count-(idx--)] = RepStakedTokens({
                wallet: wallet,
                isActive: reps[wallet],
                BZRX: repStakedPerToken[wallet][BZRX],
                vBZRX: repStakedPerToken[wallet][vBZRX],
                LPToken: repStakedPerToken[wallet][LPToken]
            });

            if (i == 0) {
                break;
            }
        }

        if (idx != 0) {
            count -= idx;
            assembly {
                mstore(repStakedArr, count)
            }
        }
    }

    function lastTimeRewardApplicable()
        public
        view
        returns (uint256)
    {
        return periodFinish
            .min256(_getTimestamp());
    }

    modifier updateReward(address account) {
        uint256 _rewardsPerToken = rewardsPerToken();
        rewardPerTokenStored = _rewardsPerToken;

        lastUpdateTime = lastTimeRewardApplicable();

        if (account != address(0)) {
            rewards[account] = _earned(account, _rewardsPerToken);
            userRewardPerTokenPaid[account] = _rewardsPerToken;
        }

        _;
    }

    function rewardsPerToken()
        public
        view
        returns (uint256)
    {
        uint256 totalSupplyBZRX = totalSupplyByAssetNormed(BZRX);
        uint256 totalSupplyVBZRX = totalSupplyByAssetNormed(vBZRX);
        uint256 totalSupplyLPToken = totalSupplyByAssetNormed(LPToken);

        uint256 totalTokens = totalSupplyBZRX
            .add(totalSupplyVBZRX)
            .add(totalSupplyLPToken);

        if (totalTokens == 0) {
            return rewardPerTokenStored;
        }

        return rewardPerTokenStored.add(
            lastTimeRewardApplicable()
                .sub(lastUpdateTime)
                .mul(rewardRate)
                .mul(1e18)
                .div(totalTokens)
        );
    }

    function earned(
        address account)
        public
        view
        returns (uint256)
    {
        return _earned(
            account,
            rewardsPerToken()
        );
    }

    function _earned(
        address account,
        uint256 _rewardsPerToken)
        internal
        view
        returns (uint256)
    {
        uint256 bzrxBalance = balanceOfByAssetNormed(BZRX, account);
        uint256 vbzrxBalance = balanceOfByAssetNormed(vBZRX, account);
        uint256 lptokenBalance = balanceOfByAssetNormed(LPToken, account);

        uint256 totalTokens = bzrxBalance
            .add(vbzrxBalance)
            .add(lptokenBalance);

        return totalTokens
            .mul(_rewardsPerToken.sub(userRewardPerTokenPaid[account]))
            .div(1e18)
            .add(rewards[account]);
    }

    function notifyRewardAmount(
        uint256 reward,
        uint256 duration)
        external
        onlyOwner
        updateReward(address(0))
    {
        require(isInit, "not init");
        require(duration > 1 days && duration < 365 days / 12, "duration outside range");

        if (periodFinish != 0) {
            if (_getTimestamp() >= periodFinish) {
                rewardRate = reward
                    .div(duration);
            } else {
                uint256 remaining = periodFinish
                    .sub(_getTimestamp());
                uint256 leftover = remaining
                    .mul(rewardRate);
                rewardRate = reward
                    .add(leftover)
                    .div(duration);
            }

            lastUpdateTime = _getTimestamp();
            periodFinish = _getTimestamp()
                .add(duration);
        } else {
            rewardRate = reward
                .div(duration);
            lastUpdateTime = _getTimestamp();
            periodFinish = _getTimestamp()
                .add(duration);
        }

        emit RewardAdded(
            reward,
            duration
        );
    }

    function stakeableByAsset(
        address token,
        address account)
        public
        view
        returns (uint256)
    {
        uint256 walletBalance = IERC20(token).balanceOf(account);
        uint256 stakedBalance = balanceOfByAsset(
            token,
            account
        );

        return walletBalance > stakedBalance ?
            walletBalance - stakedBalance :
            0;
    }

    function balanceOfByAsset(
        address token,
        address account)
        public
        view
        returns (uint256)
    {
        return _balancesPerToken[token][account];
    }

    function balanceOfByAssetNormed(
        address token,
        address account)
        public
        view
        returns (uint256)
    {
        if (token == LPToken) {
            // normalizes the LPToken balance
            uint256 lptokenBalance = totalSupplyByAsset(LPToken);
            if (lptokenBalance != 0) {
                return totalSupplyByAssetNormed(LPToken)
                    .mul(balanceOfByAsset(LPToken, account))
                    .div(lptokenBalance);
            }
        } else {
            return balanceOfByAsset(token, account);
        }
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return totalSupplyByAsset(BZRX)
            .add(totalSupplyByAsset(vBZRX))
            .add(totalSupplyByAsset(LPToken));
    }

    function totalSupplyNormed()
        public
        view
        returns (uint256)
    {
        return totalSupplyByAssetNormed(BZRX)
            .add(totalSupplyByAssetNormed(vBZRX))
            .add(totalSupplyByAssetNormed(LPToken));
    }

    function totalSupplyByAsset(
        address token)
        public
        view
        returns (uint256)
    {
        return _totalSupplyPerToken[token];
    }

    function totalSupplyByAssetNormed(
        address token)
        public
        view
        returns (uint256)
    {
        if (token == LPToken) {
            uint256 circulatingSupply = initialCirculatingSupply; // + VBZRX.totalVested();
            
            // staked LP tokens are assumed to represent the total unstaked supply (circulated supply - staked BZRX)
            return totalSupplyByAsset(LPToken) != 0 ?
                circulatingSupply - totalSupplyByAsset(BZRX) :
                0;
        } else {
            return totalSupplyByAsset(token);
        }
    }

    function _setDelegate(
        address delegateToSet)
        internal
        returns (address currentDelegate)
    {
        currentDelegate = delegate[msg.sender];
        if (currentDelegate != ZERO_ADDRESS) {
            require(delegateToSet == ZERO_ADDRESS || delegateToSet == currentDelegate, "delegate already set");
        } else {
            if (delegateToSet == ZERO_ADDRESS) {
                delegateToSet = msg.sender;
            }
            delegate[msg.sender] = delegateToSet;

            emit DelegateChanged(
                msg.sender,
                currentDelegate,
                delegateToSet
            );

            currentDelegate = delegateToSet;
        }
    }

    function _getTimestamp()
        internal
        view
        returns (uint256)
    {
        return block.timestamp;
    }
}