/**
 *Submitted for verification at Etherscan.io on 2021-10-04
*/

pragma solidity 0.8.4;



abstract contract LockerTypes {
    enum LockType {
        ERC20,
        LP
    }
    struct LockStorageRecord {
        LockType ltype;
        address token;
        uint256 amount;
        VestingRecord[] vestings;
    }
    struct VestingRecord {
        uint256 unlockTime;
        uint256 amountUnlock;
        bool isNFT;
    }
    struct RegistryShare {
        uint256 lockIndex;
        uint256 sharePercent;
        uint256 claimedAmount;
    }
}
contract PicipoLocker is LockerTypes {
    using SafeERC20 for IERC20;
    string constant name = "Lock & Registry v0.0.2";
    uint256 constant MAX_VESTING_RECORDS_PER_LOCK = 250;
    uint256 constant TOTAL_IN_PERCENT = 10000;
    LockStorageRecord[] lockerStorage;
    mapping(address => RegistryShare[]) public registry;
    mapping(uint256 => address[]) beneficiariesInLock;
    event NewLock(
        address indexed erc20,
        address indexed who,
        uint256 lockedAmount,
        uint256 lockId
    );
    function lockTokens(
        address _ERC20,
        uint256 _amount,
        uint256[] memory _unlockedFrom,
        uint256[] memory _unlockAmount,
        address[] memory _beneficiaries,
        uint256[] memory _beneficiariesShares
    ) external {
        require(_amount > 0, "Cant lock 0 amount");
        require(
            IERC20(_ERC20).allowance(msg.sender, address(this)) >= _amount,
            "Please approve first"
        );
        require(
            _getArraySum(_unlockAmount) == _amount,
            "Sum vesting records must be equal lock amount"
        );
        require(
            _unlockedFrom.length == _unlockAmount.length,
            "Length of periods and amounts arrays must be equal"
        );
        require(
            _beneficiaries.length == _beneficiariesShares.length,
            "Length of beneficiaries and shares arrays must be equal"
        );
        require(
            _getArraySum(_beneficiariesShares) == TOTAL_IN_PERCENT,
            "Sum of shares array must be equal to 100%"
        );
        VestingRecord[] memory v = new VestingRecord[](_unlockedFrom.length);
        for (uint256 i = 0; i < _unlockedFrom.length; i++) {
            v[i].unlockTime = _unlockedFrom[i];
            v[i].amountUnlock = _unlockAmount[i];
        }
        LockStorageRecord storage lock = lockerStorage.push();
        lock.ltype = LockType.ERC20;
        lock.token = _ERC20;
        lock.amount = _amount;
        for (uint256 i = 0; i < _unlockedFrom.length; i++) {
            lock.vestings.push(v[i]);
        }
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            RegistryShare[] storage shares = registry[_beneficiaries[i]];
            shares.push(
                RegistryShare({
                    lockIndex: lockerStorage.length - 1,
                    sharePercent: _beneficiariesShares[i],
                    claimedAmount: 0
                })
            );
            beneficiariesInLock[lockerStorage.length - 1].push(
                _beneficiaries[i]
            );
        }
        IERC20 token = IERC20(_ERC20);
        token.safeTransferFrom(msg.sender, address(this), _amount);
        emit NewLock(_ERC20, msg.sender, _amount, lockerStorage.length - 1);
    }
    function claimTokens(uint256 _lockIndex, uint256 _desiredAmount) external {
        require(_lockIndex < lockerStorage.length, "Lock record not saved yet");
        require(_desiredAmount > 0, "Cant claim zero");
        LockStorageRecord memory lock = lockerStorage[_lockIndex];
        (
            uint256 percentShares,
            uint256 wasClaimed
        ) = _getUserSharePercentAndClaimedAmount(msg.sender, _lockIndex);
        uint256 availableAmount = (_getAvailableAmountByLockIndex(_lockIndex) *
            percentShares) /
            TOTAL_IN_PERCENT -
            wasClaimed;
        require(_desiredAmount <= availableAmount, "Insufficient for now");
        availableAmount = _desiredAmount;
        _decreaseAvailableAmount(msg.sender, _lockIndex, availableAmount);
        IERC20 token = IERC20(lock.token);
        token.safeTransfer(msg.sender, availableAmount);
    }
    function getUserShares(address _user)
        external
        view
        returns (RegistryShare[] memory)
    {
        return _getUsersShares(_user);
    }
    function getUserBalances(address _user, uint256 _lockIndex)
        external
        view
        returns (uint256, uint256)
    {
        return _getUserBalances(_user, _lockIndex);
    }
    function getLockRecordByIndex(uint256 _index)
        external
        view
        returns (LockStorageRecord memory)
    {
        return _getLockRecordByIndex(_index);
    }
    function getLockCount() external view returns (uint256) {
        return lockerStorage.length;
    }
    function getArraySum(uint256[] memory _array)
        external
        pure
        returns (uint256)
    {
        return _getArraySum(_array);
    }
    function _decreaseAvailableAmount(
        address user,
        uint256 _lockIndex,
        uint256 _amount
    ) internal {
        RegistryShare[] storage shares = registry[user];
        for (uint256 i = 0; i < shares.length; i++) {
            if (shares[i].lockIndex == _lockIndex) {
                shares[i].claimedAmount += _amount;
                break;
            }
        }
    }
    function _getArraySum(uint256[] memory _array)
        internal
        pure
        returns (uint256)
    {
        uint256 res = 0;
        for (uint256 i = 0; i < _array.length; i++) {
            res += _array[i];
        }
        return res;
    }
    function _getAvailableAmountByLockIndex(uint256 _lockIndex)
        internal
        view
        returns (uint256)
    {
        VestingRecord[] memory v = lockerStorage[_lockIndex].vestings;
        uint256 res = 0;
        for (uint256 i = 0; i < v.length; i++) {
            if (v[i].unlockTime <= block.timestamp && !v[i].isNFT) {
                res += v[i].amountUnlock;
            }
        }
        return res;
    }
    function _getUserSharePercentAndClaimedAmount(
        address _user,
        uint256 _lockIndex
    ) internal view returns (uint256 percent, uint256 claimed) {
        RegistryShare[] memory shares = registry[_user];
        for (uint256 i = 0; i < shares.length; i++) {
            if (shares[i].lockIndex == _lockIndex) {
                percent += shares[i].sharePercent;
                claimed += shares[i].claimedAmount;
            }
        }
        return (percent, claimed);
    }
    function _getUsersShares(address _user)
        internal
        view
        returns (RegistryShare[] memory)
    {
        return registry[_user];
    }
    function _getUserBalances(address _user, uint256 _lockIndex)
        internal
        view
        returns (uint256, uint256)
    {
        (
            uint256 percentShares,
            uint256 wasClaimed
        ) = _getUserSharePercentAndClaimedAmount(_user, _lockIndex);
        uint256 totalBalance = (lockerStorage[_lockIndex].amount *
            percentShares) /
            TOTAL_IN_PERCENT -
            wasClaimed;
        uint256 available = (_getAvailableAmountByLockIndex(_lockIndex) *
            percentShares) /
            TOTAL_IN_PERCENT -
            wasClaimed;
        return (totalBalance, available);
    }
    function _getVestingsByLockIndex(uint256 _index)
        internal
        view
        returns (VestingRecord[] memory)
    {
        VestingRecord[] memory v = _getLockRecordByIndex(_index).vestings;
        return v;
    }
    function _getLockRecordByIndex(uint256 _index)
        internal
        view
        returns (LockStorageRecord memory)
    {
        return lockerStorage[_index];
    }
}