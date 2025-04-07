/**
 *Submitted for verification at Etherscan.io on 2021-03-30
*/

pragma solidity >=0.7.5;

// SPDX-License-Identifier: BSD-3-Clause

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract YFTEFarming_TetherswapLP is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    event RewardsTransferred(address holder, uint256 amount);
    event RewardsDisbursed(uint256 amount);

    // Tetherswap ETH/YFTE LP token contract address
    address public immutable LPtokenAddress;
    //YFTether token address
    address public immutable tokenAddress;
    uint256 public immutable withdrawFeePercentX100;

    uint256 public disburseAmount = 20e18;
    uint256 public disburseDuration = 30 days;

    uint256 public disbursePercentX100 = 10000;

    uint256 public lastDisburseTime;

    constructor(
        address _lpTokenAddress,
        address _tokenAddress,
        uint256 _feePercentX100
    ) {
        LPtokenAddress = _lpTokenAddress;
        tokenAddress = _tokenAddress;
        withdrawFeePercentX100 = _feePercentX100;
        lastDisburseTime = block.timestamp;
    }

    uint256 public totalClaimedRewards = 0;

    EnumerableSet.AddressSet private holders;

    mapping(address => uint256) public depositedTokens;
    mapping(address => uint256) public depositTime;
    mapping(address => uint256) public lastClaimedTime;
    mapping(address => uint256) public totalEarnedTokens;
    mapping(address => uint256) public lastDivPoints;

    uint256 public totalTokensDisbursed = 0;
    uint256 public contractBalance = 0;

    uint256 public totalDivPoints = 0;
    uint256 public totalTokens = 0;

    uint256 internal pointMultiplier = 1e18;

    function addContractBalance(uint256 amount) public onlyOwner {
        require(
            Token(tokenAddress).transferFrom(msg.sender, address(this), amount),
            "Cannot add balance!"
        );
        contractBalance = contractBalance.add(amount);
    }

    function updateAccount(address account) private {
        uint256 pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            require(
                Token(tokenAddress).transfer(account, pendingDivs),
                "Could not transfer tokens."
            );
            totalEarnedTokens[account] = totalEarnedTokens[account].add(
                pendingDivs
            );
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
        lastClaimedTime[account] = block.timestamp;
        lastDivPoints[account] = totalDivPoints;
    }

    function getPendingDivs(address _holder) public view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;

        uint256 newDivPoints = totalDivPoints.sub(lastDivPoints[_holder]);

        uint256 depositedAmount = depositedTokens[_holder];

        uint256 pendingDivs =
            depositedAmount.mul(newDivPoints).div(pointMultiplier);

        return pendingDivs;
    }

    function getNumberOfHolders() public view returns (uint256) {
        return holders.length();
    }

    function deposit(uint256 amountToDeposit) public {
        require(amountToDeposit > 0, "Cannot deposit 0 Tokens");

        updateAccount(msg.sender);

        require(
            Token(LPtokenAddress).transferFrom(
                msg.sender,
                address(this),
                amountToDeposit
            ),
            "Insufficient Token Allowance"
        );

        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(
            amountToDeposit
        );
        totalTokens = totalTokens.add(amountToDeposit);

        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            depositTime[msg.sender] = block.timestamp;
        }
    }

    function withdraw(uint256 amountToWithdraw) public {
        require(
            depositedTokens[msg.sender] >= amountToWithdraw,
            "Invalid amount to withdraw"
        );

        updateAccount(msg.sender);

        uint256 fee = amountToWithdraw.mul(withdrawFeePercentX100).div(1e4);
        uint256 amountAfterFee = amountToWithdraw.sub(fee);

        require(
            Token(LPtokenAddress).transfer(owner, fee),
            "Could not transfer fee!"
        );

        require(
            Token(LPtokenAddress).transfer(msg.sender, amountAfterFee),
            "Could not transfer tokens."
        );

        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(
            amountToWithdraw
        );
        totalTokens = totalTokens.sub(amountToWithdraw);

        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }

    function emergencyWithdraw(uint256 amountToWithdraw) public {
        require(
            depositedTokens[msg.sender] >= amountToWithdraw,
            "Invalid amount to withdraw"
        );

        lastClaimedTime[msg.sender] = block.timestamp;
        lastDivPoints[msg.sender] = totalDivPoints;

        uint256 fee = amountToWithdraw.mul(withdrawFeePercentX100).div(1e4);
        uint256 amountAfterFee = amountToWithdraw.sub(fee);

        require(
            Token(LPtokenAddress).transfer(owner, fee),
            "Could not transfer fee!"
        );

        require(
            Token(LPtokenAddress).transfer(msg.sender, amountAfterFee),
            "Could not transfer tokens."
        );

        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(
            amountToWithdraw
        );
        totalTokens = totalTokens.sub(amountToWithdraw);

        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }

    function claim() public {
        updateAccount(msg.sender);
    }

    function distributeDivs(uint256 amount) private {
        if (totalTokens == 0) return;
        totalDivPoints = totalDivPoints.add(
            amount.mul(pointMultiplier).div(totalTokens)
        );
        emit RewardsDisbursed(amount);
    }

    function disburseTokens() public onlyOwner {
        uint256 amount = getPendingDisbursement();

        // uint contractBalance = Token(tokenAddress).balanceOf(address(this));

        if (contractBalance < amount) {
            amount = contractBalance;
        }
        if (amount == 0) return;
        distributeDivs(amount);
        contractBalance = contractBalance.sub(amount);
        lastDisburseTime = block.timestamp;
    }

    function getPendingDisbursement() public view returns (uint256) {
        uint256 timeDiff = block.timestamp.sub(lastDisburseTime);
        uint256 pendingDisburse =
            disburseAmount
                .mul(disbursePercentX100)
                .mul(timeDiff)
                .div(disburseDuration)
                .div(10000);
        return pendingDisburse;
    }

    function getDepositorsList(uint256 startIndex, uint256 endIndex)
        public
        view
        returns (
            address[] memory stakers,
            uint256[] memory stakingTimestamps,
            uint256[] memory lastClaimedTimeStamps,
            uint256[] memory stakedTokens
        )
    {
        require(startIndex < endIndex);

        uint256 length = endIndex.sub(startIndex);
        address[] memory _stakers = new address[](length);
        uint256[] memory _stakingTimestamps = new uint256[](length);
        uint256[] memory _lastClaimedTimeStamps = new uint256[](length);
        uint256[] memory _stakedTokens = new uint256[](length);

        for (uint256 i = startIndex; i < endIndex; i = i.add(1)) {
            address staker = holders.at(i);
            uint256 listIndex = i.sub(startIndex);
            _stakers[listIndex] = staker;
            _stakingTimestamps[listIndex] = depositTime[staker];
            _lastClaimedTimeStamps[listIndex] = lastClaimedTime[staker];
            _stakedTokens[listIndex] = depositedTokens[staker];
        }

        return (
            _stakers,
            _stakingTimestamps,
            _lastClaimedTimeStamps,
            _stakedTokens
        );
    }

    /* function to allow owner to claim *other* ERC20 tokens sent to this contract.
        Owner cannot recover unclaimed tokens (they are burnt)
    */
    function transferAnyERC20Tokens(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        // require(_tokenAddr != tokenAddress && _tokenAddr != LPtokenAddress, "Cannot send out reward tokens or LP tokens!");

        require(
            _tokenAddr != LPtokenAddress,
            "Admin cannot transfer out LP tokens from this vault!"
        );
        require(
            _tokenAddr != tokenAddress,
            "Admin cannot Transfer out Reward Tokens from this vault!"
        );

        Token(_tokenAddr).transfer(_to, _amount);
    }

    function setDisburse(uint256 _disburseAmount, uint256 _disburseDuration)
        external
        onlyOwner
    {
        require(_disburseAmount > 0, "Invalid disburse amount");
        require(_disburseDuration > 0, "Invalid disburse period");
        disburseAmount = _disburseAmount;
        disburseDuration = _disburseDuration;
    }
}