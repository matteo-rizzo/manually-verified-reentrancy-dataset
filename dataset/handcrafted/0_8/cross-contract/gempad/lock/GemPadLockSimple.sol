// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/IGempadLockSimple.sol";
import "../interfaces/IUniswapV3Factory.sol";
import "../interfaces/INonfungiblePositionManager.sol";
import "./FullMath.sol";

contract GempadLockSimple is IGempadLockSimple {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;

    struct Project {
        address owner;
        EnumerableSet.AddressSet lpLockedTokens; //V3 pool addresses
    }

    struct Lock {
        uint256 id;
        address token; //if LP v3, it is a pool address
        address owner;
        uint256 amount;
        uint40 lockDate;
        uint40 unlockDate; // unlock date for normal locks
        uint256 unlockedAmount;
        address nftManager;
        uint256 nftId;
    }

    struct CumulativeLockInfo {
        address projectToken;
        address factory;
        uint256 amount;
    }

    Lock[] private _locks;
    mapping(address => EnumerableSet.UintSet) private _userLpLockIds;
    mapping(address => EnumerableSet.UintSet) private _userNormalLockIds;

    EnumerableSet.AddressSet private _lpLockedTokens; //if v3, pool addresses
    EnumerableSet.AddressSet private _normalLockedTokens;

    mapping(address => CumulativeLockInfo) public cumulativeLockInfo;
    mapping(address => EnumerableSet.UintSet) private _tokenToLockIds;
    mapping(address => bool) public isExcludedFromFee;
    mapping(address => Project) private projects;
    mapping(address => bool) public isAvailableNFT;

    modifier validLock(uint256 lockId) {
        require(lockId < _locks.length, "Invalid lock ID");
        _;
    }

    modifier validNFT(address nft) {
        require(isAvailableNFT[nft], "Invalid NFT");
        _;
    }

    modifier isLockOwner(uint256 lockId) {
        Lock storage userLock = _locks[lockId];
        require(
            userLock.owner == msg.sender,
            "You are not the owner of this lock"
        );
        _;
    }

    modifier validLockLPv3(uint256 lockId) {
        Lock storage userLock = _locks[lockId];
        require(userLock.nftManager != address(0), "No V3 LP lock");
        _;
    }

    function multipleLock(
        address[] calldata owners,
        address token,
        bool isLpToken,
        uint256[] calldata amounts,
        uint40 unlockDate,
        string memory description,
        string memory metaData,
        address projectToken,
        address referrer
    ) external payable override returns (uint256[] memory) {
        // _payFee(projectToken, false, isLpToken);
        return
            _multipleLock(
                owners,
                amounts,
                token,
                isLpToken,
                unlockDate,
                projectToken,
                referrer
            );
    }

    function _multipleLock(
        address[] calldata owners,
        uint256[] calldata amounts,
        address token,
        bool isLpToken,
        uint40 tgeDate,
        address projectToken,
        address referrer
    ) internal returns (uint256[] memory) {
        {
            require(owners.length == amounts.length, "Length mismatch");
            require(
                tgeDate > block.timestamp,
                "TGE date should be set in the future"
            );
            require(token != address(0), "Invalid token");
        }
        {
            uint256 sumAmount = _sumAmount(amounts);
            _safeTransferFromEnsureExactAmount(
                token,
                msg.sender,
                address(this),
                sumAmount
            );
        }
        uint256 count = owners.length;
        uint256[] memory ids = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            ids[i] = _createLock(
                owners[i],
                token,
                isLpToken,
                amounts[i],
                tgeDate, // TGE date
                projectToken
            );
        }

        return ids;
    }

    function _safeTransferFromEnsureExactAmount(
        address token,
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        uint256 oldRecipientBalance = IERC20(token).balanceOf(recipient);
        IERC20(token).safeTransferFrom(sender, recipient, amount);
        uint256 newRecipientBalance = IERC20(token).balanceOf(recipient);
        require(
            newRecipientBalance - oldRecipientBalance == amount,
            "Not enough token transferred"
        );
    }

    function _sumAmount(
        uint256[] calldata amounts
    ) internal pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            if (amounts[i] == 0) {
                revert("The amount cannot be zero");
            }
            sum += amounts[i];
        }
        return sum;
    }

    function _createLock(
        address owner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint40 tgeDate,
        address projectToken
    ) internal returns (uint256 id) {
        if (isLpToken) {
            // NOT NEEDED IN THIS EXAMPLE
        } else {
            require(
                token == projectToken,
                "This token is not the project token"
            );
            id = _lockNormalToken(
                owner,
                token,
                amount,
                tgeDate
            );
        }
        return id;
    }

    function _lockNormalToken(
        address owner,
        address token,
        uint256 amount,
        uint40 tgeDate
    ) private returns (uint256 id) {
        id = _registerLock(
            owner,
            token,
            amount,
            tgeDate
        );
        _userNormalLockIds[owner].add(id);
        _normalLockedTokens.add(token);

        CumulativeLockInfo storage tokenInfo = cumulativeLockInfo[token];
        if (tokenInfo.projectToken == address(0)) {
            tokenInfo.projectToken = token;
            tokenInfo.factory = address(0);
        }
        tokenInfo.amount = tokenInfo.amount + amount;

        _tokenToLockIds[token].add(id);

        Project storage project = projects[token];
        if (project.owner == address(0)) {
            project.owner = msg.sender;
        }
    }

    function _registerLock(
        address owner,
        address token,
        uint256 amount,
        uint40 tgeDate
    ) private returns (uint256 id) {
        id = _locks.length;
        Lock memory newLock = Lock({
            id: id,
            token: token,
            owner: owner,
            amount: amount,
            lockDate: uint40(block.timestamp),
            unlockDate: tgeDate,
            unlockedAmount: 0,
            nftManager: address(0),
            nftId: 0
        });
        _locks.push(newLock);
    }

    function lockLpV3(
        address _owner,
        address nftManager,
        uint256 nftId,
        uint40 unlockDate,
        string memory description,
        string memory metaData,
        address projectToken,
        address referrer
    ) external payable override validNFT(nftManager) returns (uint256 id) {
        // _payFee(projectToken, false, true);
        {
            require(nftManager != address(0), "Invalid V3 LP manager");
            require(
                unlockDate > block.timestamp,
                "Unlock date should be in the future"
            );
        }

        (
            ,
            ,
            address token0,
            address token1,
            uint24 fee_,
            ,
            ,
            uint128 liquidity,
            ,
            ,
            ,

        ) = INonfungiblePositionManager(nftManager).positions(nftId);
        require(
            projectToken == token0 || projectToken == token1,
            "Invalid project token"
        );
        address factory = INonfungiblePositionManager(nftManager).factory();
        address token = IUniswapV3Factory(factory).getPool(
            token0,
            token1,
            fee_
        );
        require(factory != address(0) && token != address(0), "Invalid V3 LP");
        id = _locks.length;
        Lock memory newLock = Lock({
            id: id,
            token: token,
            owner: _owner,
            amount: liquidity,
            lockDate: uint40(block.timestamp),
            unlockDate: unlockDate,
            unlockedAmount: 0,
            nftManager: nftManager,
            nftId: nftId
        });
        _locks.push(newLock);
        _userLpLockIds[_owner].add(id);
        _lpLockedTokens.add(token);

        CumulativeLockInfo storage tokenInfo = cumulativeLockInfo[token];
        if (tokenInfo.projectToken == address(0)) {
            tokenInfo.projectToken = projectToken;
            tokenInfo.factory = factory;
        } else {
            projectToken = tokenInfo.projectToken;
        }
        tokenInfo.amount = tokenInfo.amount + liquidity;

        _tokenToLockIds[token].add(id);
        Project storage project = projects[projectToken];
        if (project.owner == address(0)) {
            project.owner = msg.sender;
        }
        project.lpLockedTokens.add(token);

        INonfungiblePositionManager(nftManager).safeTransferFrom(
            msg.sender,
            address(this),
            nftId
        );

        return id;
    }

    function unlock(
        uint256 lockId
    ) external override validLock(lockId) isLockOwner(lockId) {
        Lock storage userLock = _locks[lockId];
        _normalUnlock(userLock, false);
    }

    function _normalUnlock(Lock storage userLock, bool _noRevert) internal {
        if (_noRevert) {
            if (block.timestamp < userLock.unlockDate) return;
            if (userLock.unlockedAmount != 0) return;
        } else {
            require(
                block.timestamp >= userLock.unlockDate,
                "The lock is not unlocked yet"
            );
            require(userLock.unlockedAmount == 0, "Nothing to unlock");
        }
        uint256 unlockAmount = userLock.amount;
        CumulativeLockInfo storage tokenInfo = cumulativeLockInfo[
            userLock.token
        ];
        bool isLpToken = tokenInfo.factory != address(0);
        if (isLpToken) {
            _userLpLockIds[msg.sender].remove(userLock.id);
        }
        if (tokenInfo.amount <= unlockAmount) {
            tokenInfo.amount = 0;
        } else {
            tokenInfo.amount = tokenInfo.amount - unlockAmount;
        }
        if (tokenInfo.amount == 0) {
            if (isLpToken) {
                _lpLockedTokens.remove(userLock.token);
                projects[tokenInfo.projectToken].lpLockedTokens.remove(
                    userLock.token
                );
            }
        }
        _tokenToLockIds[userLock.token].remove(userLock.id);
        userLock.unlockedAmount = unlockAmount;
        if (userLock.nftManager != address(0)) {
            INonfungiblePositionManager(userLock.nftManager).safeTransferFrom(
                address(this),
                msg.sender,
                userLock.nftId
            );
        }

    }

    function collectFees(
        uint256 lockId
    )
        external
        isLockOwner(lockId)
        validLockLPv3(lockId)
        returns (uint256 amount0, uint256 amount1)
    {
        Lock storage userLock = _locks[lockId];
        // set amount0Max and amount1Max to uint256.max to collect all fees
        // alternatively can set recipient to msg.sender and avoid another transaction in `sendToOwner`
        INonfungiblePositionManager.CollectParams
            memory params = INonfungiblePositionManager.CollectParams({
                tokenId: userLock.nftId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            });
        // send collected feed back to owner
        (
            ,
            ,
            address token0,
            address token1,
            ,
            ,
            ,
            ,
            ,
            ,
            ,

        ) = INonfungiblePositionManager(userLock.nftManager).positions(
                userLock.nftId
            );
        uint256 originalAmount0 = IERC20(token0).balanceOf(address(this));
        uint256 originalAmount1 = IERC20(token1).balanceOf(address(this));
        INonfungiblePositionManager(userLock.nftManager).collect(params);
        amount0 = IERC20(token0).balanceOf(address(this)) - originalAmount0;
        amount1 = IERC20(token1).balanceOf(address(this)) - originalAmount1;
        IERC20(token0).safeTransfer(userLock.owner, amount0);
        IERC20(token1).safeTransfer(userLock.owner, amount1);
    }
}