/**
 *Submitted for verification at Etherscan.io on 2021-04-06
*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;
















contract LockedTokenVault is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address _TOKEN_;

    mapping(address => uint256) internal originBalances;
    mapping(address => uint256) internal claimedBalances;
    mapping(address => uint256) internal startReleaseTime;
    mapping(address => uint256) internal releaseDuration;

    uint256 public _UNDISTRIBUTED_AMOUNT_;

    // ============ Events ============

    event Claim(address indexed holder, uint256 origin, uint256 claimed, uint256 amount);

    // ============ Init Functions ============

    constructor(
        address _token
    ) public {
        _TOKEN_ = _token;
    }

    function deposit(uint256 amount) external onlyOwner {
        _tokenTransferIn(_OWNER_, amount);
        _UNDISTRIBUTED_AMOUNT_ = _UNDISTRIBUTED_AMOUNT_.add(amount);
    }

    function withdraw(uint256 amount) external onlyOwner {
        _UNDISTRIBUTED_AMOUNT_ = _UNDISTRIBUTED_AMOUNT_.sub(amount);
        _tokenTransferOut(_OWNER_, amount);
    }

    // ============ For Owner ============

    function grant(address[] calldata holderList, uint256[] calldata amountList, uint256[] calldata startList, uint256[] calldata durationList)
    external
    onlyOwner
    {
        require(holderList.length == amountList.length, "batch grant length not match");
        require(holderList.length == startList.length, "batch grant length not match");
        require(holderList.length == durationList.length, "batch grant length not match");
        uint256 amount = 0;
        for (uint256 i = 0; i < holderList.length; ++i) {
            originBalances[holderList[i]] = originBalances[holderList[i]].add(amountList[i]);
            startReleaseTime[holderList[i]] = startList[i];
            releaseDuration[holderList[i]] = durationList[i];
            amount = amount.add(amountList[i]);
        }
        _UNDISTRIBUTED_AMOUNT_ = _UNDISTRIBUTED_AMOUNT_.sub(amount);
    }

    function recall(address holder) external onlyOwner {
        _UNDISTRIBUTED_AMOUNT_ = _UNDISTRIBUTED_AMOUNT_.add(originBalances[holder]).sub(
            claimedBalances[holder]
        );
        originBalances[holder] = 0;
        claimedBalances[holder] = 0;
        startReleaseTime[holder] = 0;
        releaseDuration[holder] = 0;
    }

    // ============ For Holder ============

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

    function isReleaseStart(address holder) external view returns (bool) {
        return block.timestamp >= startReleaseTime[holder];
    }

    function getStartReleaseTime(address holder) external view returns (uint256) {
        return startReleaseTime[holder];
    }

    function getReleaseDuration(address holder) external view returns (uint256) {
        return releaseDuration[holder];
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
        uint256 remainingRatio = getRemainingRatio(block.timestamp, holder);
        return DecimalMath.mul(originBalances[holder], remainingRatio);
    }

    function getRemainingRatio(uint256 timestamp, address holder) public view returns (uint256) {
        if (timestamp < startReleaseTime[holder]) {
            return DecimalMath.ONE;
        }
        uint256 timePast = timestamp.sub(startReleaseTime[holder]);
        if (timePast < releaseDuration[holder]) {
            uint256 remainingTime = releaseDuration[holder].sub(timePast);
            return DecimalMath.ONE.mul(remainingTime).div(releaseDuration[holder]);
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