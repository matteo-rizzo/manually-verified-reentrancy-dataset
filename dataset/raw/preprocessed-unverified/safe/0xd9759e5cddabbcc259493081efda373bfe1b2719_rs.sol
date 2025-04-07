pragma solidity 0.6.4;









contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

contract MiningReward is Initializable {
    using SafeMath for uint256;

    using SafeERC20 for IERC20;

    bool internal _notEntered;

    /// @notice 奖励代币地址
    address public rewardToken;

    /// @notice 管理员地址
    address public admin;

    /// @notice 预备管理员地址
    address public proposedAdmin;

    /// @notice 奖励设置时间
    uint256 public datetime;

    /// @notice 用户奖励信息
    /// @param amount 用户可提取的奖励数量
    struct Balance {
        uint256 amount;
    }

    /// @notice 提币管理员地址
    address public coinAdmin;

    /// @notice 预备提币管理员地址
    address public proposedCoinAdmin;

    /// @notice 用户地址 => 用户奖励余额信息
    mapping(address => Balance) public userBalance;

    /// @notice 事件：设置预备管理员
    /// @param admin 管理员地址
    /// @param proposedAdmin 预备管理员地址
    event ProposeAdmin(address admin, address proposedAdmin);

    /// @notice 事件：Claim Admin
    /// @param oldAdmin 旧管理员地址
    /// @param newAdmin 新管理员地址
    event ClaimAdmin(address oldAdmin, address newAdmin);

    /// @notice 事件：管理员取出奖励代币（指定数量）
    /// @param amount 数量
    event WithdrawRewardWithAmount(uint256 amount);

    /// @notice 事件：管理员取出奖励代币（全部取出）
    /// @param amount 数量
    event WithdrawReward(uint256 amount);

    /// @notice 事件：管理员取出奖励代币（指定接收地址，全部取出）
    /// @param addr 接收地址
    /// @param amount 数量
    event WithdrawRewardToAddress(address addr, uint256 amount);

    /// @notice 事件：管理员取出奖励代币（指定接收地址，指定数量）
    /// @param addr 接收地址
    /// @param amount 数量
    event WithdrawRewardToAddressWithAmount(address addr, uint256 amount);

    /// @notice 事件：用户取出奖励
    /// @param addr 用户地址
    /// @param amount 数量
    event ClaimReward(address addr, uint256 amount);

    /// @notice 事件：设置奖励代币
    /// @param oldToken 老地址
    /// @param newToken 新地址
    event SetRewardToken(address oldToken, address newToken);

    /// @notice 事件：批量设置用户奖励
    /// @param accounts 用户地址数组
    /// @param amounts 奖励数量数组
    /// @param datetime 时间戳
    event BatchSet(address[] accounts, uint256[] amounts, uint256 datetime);

    /// @notice 事件：单独设置用户的奖励数量（修正情况下使用）
    /// @param account 用户地址
    /// @param amount 奖励数量
    event Set(address account, uint256 amount);

    /// @notice 初始化函数
    /// @param _admin 管理员地址
    /// @param _rewardToken 奖励代币地址
    function initialize(address _admin, address _coinAdmin, address _rewardToken)
        public
        initializer
    {
        admin = _admin;
        coinAdmin = _coinAdmin;
        rewardToken = _rewardToken;
        _notEntered = true;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Admin required");
        _;
    }

    modifier onlyCoinAdmin {
        require(msg.sender == coinAdmin, "CoinAdmin required");
        _;
    }

    modifier nonReentrant() {
        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true;
    }

    /// @notice 设置奖励代币地址
    /// @param _rewardToken 奖励代币地址
    function setRewardToken(address _rewardToken) public onlyCoinAdmin {
        address oldToken = rewardToken;
        rewardToken = _rewardToken;

        emit SetRewardToken(oldToken, rewardToken);
    }

    /// @notice 设置预备管理员地址
    /// @param _proposedAdmin 预备管理员地址
    function proposeAdmin(address _proposedAdmin) public onlyAdmin {
        require(_proposedAdmin != address(0));
        proposedAdmin = _proposedAdmin;

        emit ProposeAdmin(admin, _proposedAdmin);
    }

    /// @notice 预备管理员 claim 权限
    function claimAdmin() public {
        require(msg.sender == proposedAdmin, "ProposedAdmin required");
        address oldAdmin = admin;
        admin = proposedAdmin;
        proposedAdmin = address(0);

        emit ClaimAdmin(oldAdmin, admin);
    }

    /// @notice 设置预备管理员地址
    /// @param _proposedCoinAdmin 预备管理员地址
    function proposeCoinAdmin(address _proposedCoinAdmin) public onlyCoinAdmin {
        require(_proposedCoinAdmin != address(0));
        proposedCoinAdmin = _proposedCoinAdmin;

        // emit ProposeAdmin(admin, _proposedCoinAdmin);
    }

    /// @notice 预备管理员 claim 权限
    function claimCoinAdmin() public {
        require(msg.sender == proposedCoinAdmin, "proposedCoinAdmin required");
        // address oldCoinAdmin = coinAdmin;
        coinAdmin = proposedCoinAdmin;
        proposedCoinAdmin = address(0);

        // emit ClaimAdmin(oldAdmin, admin);
    }

    /// @notice 管理员取出奖励代币的数量（可指定数量）
    /// @param amount 取出数量
    function withdrawRewardWithAmount(uint256 amount) public onlyCoinAdmin {
        require(
            IERC20(rewardToken).balanceOf(address(this)) > 0,
            "No reward left"
        );
        require(amount > 0, "Invalid amount");
        IERC20(rewardToken).safeTransfer(admin, amount);

        emit WithdrawRewardWithAmount(amount);
    }

    /// @notice 管理员取出奖励代币的数量（全部取出）
    function withdrawReward() public onlyCoinAdmin {
        require(
            IERC20(rewardToken).balanceOf(address(this)) > 0,
            "No reward left"
        );
        uint256 balance = checkRewardBalance();
        IERC20(rewardToken).safeTransfer(admin, balance);

        emit WithdrawReward(balance);
    }

    /// @notice 管理员取出奖励代币的数量（全部取出，指定接收地址）
    /// @param addr 接收代币地址
    function withdrawRewardToAddress(address addr) public onlyCoinAdmin {
        require(
            IERC20(rewardToken).balanceOf(address(this)) > 0,
            "No reward left"
        );
        uint256 balance = checkRewardBalance();
        IERC20(rewardToken).safeTransfer(addr, balance);

        emit WithdrawRewardToAddress(addr, balance);
    }

    /// @notice 管理员取出奖励代币的数量（全部取出，指定接收地址，指定数量）
    /// @param addr 接收代币地址
    /// @param amount 取出数量
    function withdrawRewardToAddressWithAmount(address addr, uint256 amount)
        public
        onlyCoinAdmin
    {
        require(
            IERC20(rewardToken).balanceOf(address(this)) > 0,
            "No reward left"
        );
        IERC20(rewardToken).safeTransfer(addr, amount);

        emit WithdrawRewardToAddressWithAmount(addr, amount);
    }

    /// @notice 批量设置用户的奖励数量
    /// @param accounts 用户地址数组
    /// @param amount 奖励数量数组
    /// @param _datetime 时间戳
    function batchSet(
        address[] calldata accounts,
        uint256[] calldata amount,
        uint256 _datetime
    ) external onlyAdmin {
        require(_datetime > datetime, "Invalid time");
        uint256 userCount = accounts.length;
        require(userCount == amount.length, "Invalid input");
        for (uint256 i = 0; i < userCount; ++i) {
            userBalance[accounts[i]].amount = userBalance[accounts[i]]
                .amount
                .add(amount[i]);
        }
        datetime = _datetime;

        emit BatchSet(accounts, amount, _datetime);
    }

    /// @notice 单独设置用户的奖励数量（修正情况下使用）
    /// @param account 用户地址
    /// @param amount 奖励数量
    function set(address account, uint256 amount) external onlyAdmin {
        userBalance[account].amount = amount;

        emit Set(account, amount);
    }

    /// @notice 用户取出自己的挖矿奖励
    function claimReward() public nonReentrant {
        uint256 claimAmount = userBalance[msg.sender].amount;
        require(claimAmount > 0, "No reward");
        require(
            checkRewardBalance() >= claimAmount,
            "Insufficient rewardToken"
        );
        userBalance[msg.sender].amount = 0;
        IERC20(rewardToken).safeTransfer(msg.sender, claimAmount);

        emit ClaimReward(msg.sender, claimAmount);
    }

    /// @notice 用户查看自己的可取资产
    function checkBalance(address account) public view returns (uint256) {
        return userBalance[account].amount;
    }

    /// @notice 查看当前奖励代币余额
    function checkRewardBalance() public view returns (uint256) {
        return IERC20(rewardToken).balanceOf(address(this));
    }
}