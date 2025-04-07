/**
 *Submitted for verification at Etherscan.io on 2019-10-26
*/

pragma solidity 0.4.25;








contract Auth {

  address internal mainAdmin;
  address internal contractAdmin;
  address internal profitAdmin;
  address internal ethAdmin;
  address internal LAdmin;
  address internal maxSAdmin;
  address internal backupAdmin;
  address internal commissionAdmin;

  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

  constructor(
    address _mainAdmin,
    address _contractAdmin,
    address _profitAdmin,
    address _ethAdmin,
    address _LAdmin,
    address _maxSAdmin,
    address _backupAdmin,
    address _commissionAdmin
  )
  internal
  {
    mainAdmin = _mainAdmin;
    contractAdmin = _contractAdmin;
    profitAdmin = _profitAdmin;
    ethAdmin = _ethAdmin;
    LAdmin = _LAdmin;
    maxSAdmin = _maxSAdmin;
    backupAdmin = _backupAdmin;
    commissionAdmin = _commissionAdmin;
  }

  modifier onlyMainAdmin() {
    require(isMainAdmin(), "onlyMainAdmin");
    _;
  }

  modifier onlyContractAdmin() {
    require(isContractAdmin() || isMainAdmin(), "onlyContractAdmin");
    _;
  }

  modifier onlyProfitAdmin() {
    require(isProfitAdmin() || isMainAdmin(), "onlyProfitAdmin");
    _;
  }

  modifier onlyEthAdmin() {
    require(isEthAdmin() || isMainAdmin(), "onlyEthAdmin");
    _;
  }

  modifier onlyLAdmin() {
    require(isLAdmin() || isMainAdmin(), "onlyLAdmin");
    _;
  }

  modifier onlyMaxSAdmin() {
    require(isMaxSAdmin() || isMainAdmin(), "onlyMaxSAdmin");
    _;
  }

  modifier onlyBackupAdmin() {
    require(isBackupAdmin() || isMainAdmin(), "onlyBackupAdmin");
    _;
  }

  modifier onlyBackupAdmin2() {
    require(isBackupAdmin(), "onlyBackupAdmin");
    _;
  }

  function isMainAdmin() public view returns (bool) {
    return msg.sender == mainAdmin;
  }

  function isContractAdmin() public view returns (bool) {
    return msg.sender == contractAdmin;
  }

  function isProfitAdmin() public view returns (bool) {
    return msg.sender == profitAdmin;
  }

  function isEthAdmin() public view returns (bool) {
    return msg.sender == ethAdmin;
  }

  function isLAdmin() public view returns (bool) {
    return msg.sender == LAdmin;
  }

  function isMaxSAdmin() public view returns (bool) {
    return msg.sender == maxSAdmin;
  }

  function isBackupAdmin() public view returns (bool) {
    return msg.sender == backupAdmin;
  }
}







contract Citizen is Auth {
  using ArrayUtil for uint256[];
  using StringUtil for string;
  using UnitConverter for string;
  using SafeMath for uint;

  enum Rank {
    UnRanked,
    Star1,
    Star2,
    Star3,
    Star4,
    Star5,
    Star6,
    Star7,
    Star8,
    Star9,
    Star10
  }

  enum DepositType {
    Ether,
    Token,
    Dollar
  }

  uint[11] public rankCheckPoints = [
    0,
    1000000,
    3000000,
    10000000,
    40000000,
    100000000,
    300000000,
    1000000000,
    2000000000,
    5000000000,
    10000000000
  ];

  uint[11] public rankBonuses = [
    0,
    0,
    0,
    0,
    1000000, // $1k
    2000000,
    6000000,
    20000000,
    50000000,
    150000000,
    500000000 // $500k
  ];

  struct Investor {
    uint id;
    string userName;
    address inviter;
    address[] directlyInvitee;
    address[] directlyInviteeHaveJoinedPackage;
    uint f1Deposited;
    uint networkDeposited;
    uint networkDepositedViaETH;
    uint networkDepositedViaToken;
    uint networkDepositedViaDollar;
    uint subscribers;
    Rank rank;
  }

  address public reserveFund;
  IWallet public wallet;
  ICitizen public oldCitizen = ICitizen(0x0);

  mapping (address => Investor) private investors;
  mapping (bytes24 => address) private userNameAddresses;
  address[] private userAddresses;
  address private rootAccount = 0xE6A7E869769966BbbFA48e8218865EC5a6261Ce4;
  mapping (address => bool) private ha;

  modifier onlyWalletContract() {
    require(msg.sender == address(wallet), "onlyWalletContract");
    _;
  }

  modifier onlyReserveFundContract() {
    require(msg.sender == address(reserveFund), "onlyReserveFundContract");
    _;
  }

  event RankAchieved(address investor, uint currentRank, uint newRank);

  constructor(
    address _mainAdmin,
    address _backupAdmin
  )
  Auth(
    _mainAdmin,
    msg.sender,
    0x0,
    0x0,
    0x0,
    0x0,
    _backupAdmin,
      0x0
  )
  public
  {
    setupRootAccount();
  }

  // ONLY-CONTRACT-ADMIN FUNCTIONS

  function setW(address _walletContract) onlyContractAdmin public {
    wallet = IWallet(_walletContract);
  }

  function setRF(address _reserveFundContract) onlyContractAdmin public {
    reserveFund = _reserveFundContract;
  }

  function updateMainAdmin(address _newMainAdmin) onlyBackupAdmin public {
    require(_newMainAdmin != address(0x0), "Invalid address");
    mainAdmin = _newMainAdmin;
  }

  function updateContractAdmin(address _newContractAdmin) onlyMainAdmin public {
    require(_newContractAdmin != address(0x0), "Invalid address");
    contractAdmin = _newContractAdmin;
  }

  function updateBackupAdmin(address _newBackupAdmin) onlyBackupAdmin2 public {
    require(_newBackupAdmin != address(0x0), "Invalid address");
    backupAdmin = _newBackupAdmin;
  }

  function updateHA(address _address, bool _value) onlyMainAdmin public {
    ha[_address] = _value;
  }

  function checkHA(address _address) onlyMainAdmin public view returns (bool) {
    return ha[_address];
  }

  function syncData(address[] _investors) onlyContractAdmin public {
    for (uint i = 0; i < _investors.length; i++) {
      syncInvestorInfo(_investors[i]);
      syncDepositInfo(_investors[i]);
    }
  }

  // ONLY-RESERVE-FUND-CONTRACT FUNCTIONS

  function register(address _user, string memory _userName, address _inviter)
  onlyReserveFundContract
  public
  returns
  (uint)
  {
    require(_userName.validateUserName(), "Invalid username");
    Investor storage investor = investors[_user];
    require(!isCitizen(_user), "Already an citizen");
    bytes24 _userNameAsKey = _userName.stringToBytes24();
    require(userNameAddresses[_userNameAsKey] == address(0x0), "Username already exist");
    userNameAddresses[_userNameAsKey] = _user;

    investor.id = userAddresses.length;
    investor.userName = _userName;
    investor.inviter = _inviter;
    investor.rank = Rank.UnRanked;
    increaseInvitersSubscribers(_inviter);
    increaseInviterF1(_inviter, _user);
    userAddresses.push(_user);
    return investor.id;
  }

  function showInvestorInfo(address _investorAddress)
  onlyReserveFundContract
  public
  view
  returns (uint, string memory, address, address[], uint, uint, uint, Citizen.Rank)
  {
    Investor storage investor = investors[_investorAddress];
    return (
      investor.id,
      investor.userName,
      investor.inviter,
      investor.directlyInvitee,
      investor.f1Deposited,
      investor.networkDeposited,
      investor.subscribers,
      investor.rank
    );
  }

  // ONLY-WALLET-CONTRACT FUNCTIONS

  function addF1DepositedToInviter(address _invitee, uint _amount)
  onlyWalletContract
  public
  {
    address inviter = investors[_invitee].inviter;
    investors[inviter].f1Deposited = investors[inviter].f1Deposited.add(_amount);
  }

  function getInviter(address _investor)
  onlyWalletContract
  public
  view
  returns
  (address)
  {
    return investors[_investor].inviter;
  }

  // _source: 0-eth 1-token 2-usdt
  function addNetworkDepositedToInviter(address _inviter, uint _amount, uint _source, uint _sourceAmount)
  onlyWalletContract
  public
  {
    require(_inviter != address(0x0), "Invalid inviter address");
    require(_amount >= 0, "Invalid deposit amount");
    require(_source >= 0 && _source <= 2, "Invalid deposit source");
    require(_sourceAmount >= 0, "Invalid source amount");
    investors[_inviter].networkDeposited = investors[_inviter].networkDeposited.add(_amount);
    if (_source == 0) {
      investors[_inviter].networkDepositedViaETH = investors[_inviter].networkDepositedViaETH.add(_sourceAmount);
    } else if (_source == 1) {
      investors[_inviter].networkDepositedViaToken = investors[_inviter].networkDepositedViaToken.add(_sourceAmount);
    } else {
      investors[_inviter].networkDepositedViaDollar = investors[_inviter].networkDepositedViaDollar.add(_sourceAmount);
    }
  }

  function increaseInviterF1HaveJoinedPackage(address _invitee)
  public
  onlyWalletContract
  {
    address _inviter = getInviter(_invitee);
    investors[_inviter].directlyInviteeHaveJoinedPackage.push(_invitee);
  }

  // PUBLIC FUNCTIONS

  function updateRanking() public {
    Investor storage investor = investors[msg.sender];
    Rank currentRank = investor.rank;
    require(investor.directlyInviteeHaveJoinedPackage.length > 2, "Invalid condition to make ranking");
    require(currentRank < Rank.Star10, "Congratulations! You have reached max rank");
    uint investorRevenueToCheckRank = getInvestorRankingRevenue(msg.sender);
    Rank newRank;
    for(uint8 k = uint8(currentRank) + 1; k <= uint8(Rank.Star10); k++) {
      if(investorRevenueToCheckRank >= rankCheckPoints[k]) {
        newRank = getRankFromIndex(k);
      }
    }
    if (newRank > currentRank) {
      wallet.bonusNewRank(msg.sender, uint(currentRank), uint(newRank));
      investor.rank = newRank;
      emit RankAchieved(msg.sender, uint(currentRank), uint(newRank));
    }
  }

  function getInvestorRankingRevenue(address _investor) public view returns (uint) {
    require(msg.sender == address(this) || msg.sender == _investor, "You can't see other investor");
    Investor storage investor = investors[_investor];
    if (investor.directlyInviteeHaveJoinedPackage.length <= 2) {
      return 0;
    }
    uint[] memory f1NetworkDeposited = new uint[](investor.directlyInviteeHaveJoinedPackage.length);
    uint sumF1NetworkDeposited = 0;
    for (uint j = 0; j < investor.directlyInviteeHaveJoinedPackage.length; j++) {
      f1NetworkDeposited[j] = investors[investor.directlyInviteeHaveJoinedPackage[j]].networkDeposited;
      sumF1NetworkDeposited = sumF1NetworkDeposited.add(f1NetworkDeposited[j]);
    }
    uint max;
    uint subMax;
    (max, subMax) = f1NetworkDeposited.tooLargestValues();
    return sumF1NetworkDeposited.sub(max).sub(subMax);
  }

  function checkInvestorsInTheSameReferralTree(address _inviter, address _invitee)
  public
  view
  returns (bool)
  {
    require(_inviter != _invitee, "They are the same");
    bool inTheSameTreeDownLine = checkInTheSameReferralTree(_inviter, _invitee);
    bool inTheSameTreeUpLine = checkInTheSameReferralTree(_invitee, _inviter);
    return inTheSameTreeDownLine || inTheSameTreeUpLine;
  }

  function getDirectlyInvitee(address _investor) public view returns (address[]) {
    validateSender(_investor);
    return investors[_investor].directlyInvitee;
  }

  function getDirectlyInviteeHaveJoinedPackage(address _investor) public view returns (address[]) {
    validateSender(_investor);
    return investors[_investor].directlyInviteeHaveJoinedPackage;
  }

  function getDepositInfo(address _investor) public view returns (uint, uint, uint, uint, uint) {
    validateSender(_investor);
    return (
      investors[_investor].f1Deposited,
      investors[_investor].networkDeposited,
      investors[_investor].networkDepositedViaETH,
      investors[_investor].networkDepositedViaToken,
      investors[_investor].networkDepositedViaDollar
    );
  }

  function getF1Deposited(address _investor) public view returns (uint) {
    validateSender(_investor);
    return investors[_investor].f1Deposited;
  }

  function getNetworkDeposited(address _investor) public view returns (uint) {
    validateSender(_investor);
    return investors[_investor].networkDeposited;
  }

  function getId(address _investor) public view returns (uint) {
    validateSender(_investor);
    return investors[_investor].id;
  }

  function getUserName(address _investor) public view returns (string) {
    validateSender(_investor);
    return investors[_investor].userName;
  }

  function getRank(address _investor) public view returns (Rank) {
    validateSender(_investor);
    return investors[_investor].rank;
  }

  function getUserAddress(uint _index) public view returns (address) {
    require(_index >= 0 && _index < userAddresses.length, "Index must be >= 0 or < getInvestorCount()");
    validateSender(userAddresses[_index]);
    return userAddresses[_index];
  }

  function getUserAddressFromUserName(string _userName) public view returns (address) {
    require(_userName.validateUserName(), "Invalid username");
    bytes24 _userNameAsKey = _userName.stringToBytes24();
    validateSender(userNameAddresses[_userNameAsKey]);
    return userNameAddresses[_userNameAsKey];
  }

  function getSubscribers(address _investor) public view returns (uint) {
    validateSender(_investor);
    return investors[_investor].subscribers;
  }

  function isCitizen(address _investor) view public returns (bool) {
    validateSender(_investor);
    Investor storage investor = investors[_investor];
    return bytes(investor.userName).length > 0;
  }

  function getInvestorCount() public view returns (uint) {
    return userAddresses.length;
  }

  // PRIVATE FUNCTIONS

  function setupRootAccount() private {
    string memory _rootAddressUserName = "ADMIN";
    bytes24 _rootAddressUserNameAsKey = _rootAddressUserName.stringToBytes24();
    userNameAddresses[_rootAddressUserNameAsKey] = rootAccount;
    Investor storage rootInvestor = investors[rootAccount];
    rootInvestor.id = userAddresses.length;
    rootInvestor.userName = _rootAddressUserName;
    rootInvestor.inviter = 0x0;
    rootInvestor.rank = Rank.UnRanked;
    userAddresses.push(rootAccount);
  }

  function increaseInviterF1(address _inviter, address _invitee) private {
    investors[_inviter].directlyInvitee.push(_invitee);
  }

  function checkInTheSameReferralTree(address _from, address _to) private view returns (bool) {
    do {
      Investor storage investor = investors[_from];
      if (investor.inviter == _to) {
        return true;
      }
      _from = investor.inviter;
    } while (investor.inviter != 0x0);
    return false;
  }

  function increaseInvitersSubscribers(address _inviter) private {
    do {
      investors[_inviter].subscribers += 1;
      _inviter = investors[_inviter].inviter;
    } while (_inviter != address(0x0));
  }

  function getRankFromIndex(uint8 _index) private pure returns (Rank rank) {
    require(_index >= 0 && _index <= 10, "Invalid index");
    if (_index == 1) {
      return Rank.Star1;
    } else if (_index == 2) {
      return Rank.Star2;
    } else if (_index == 3) {
      return Rank.Star3;
    } else if (_index == 4) {
      return Rank.Star4;
    } else if (_index == 5) {
      return Rank.Star5;
    } else if (_index == 6) {
      return Rank.Star6;
    } else if (_index == 7) {
      return Rank.Star7;
    } else if (_index == 8) {
      return Rank.Star8;
    } else if (_index == 9) {
      return Rank.Star9;
    } else if (_index == 10) {
      return Rank.Star10;
    } else {
      return Rank.UnRanked;
    }
  }

  function syncInvestorInfo(address _investor) private {
    uint id;
    string memory userName;
    address inviter;
    address[] memory directlyInvitee;
    uint subscribers;
    (
      id,
      userName,
      inviter,
      directlyInvitee,
      ,,
      subscribers,
    ) = oldCitizen.showInvestorInfo(_investor);

    Investor storage investor = investors[_investor];
    investor.id = id;
    investor.userName = userName;
    investor.inviter = inviter;
    investor.directlyInvitee = directlyInvitee;
    investor.directlyInviteeHaveJoinedPackage = oldCitizen.getDirectlyInviteeHaveJoinedPackage(_investor);
    investor.subscribers = subscribers;
    investor.rank = getRankFromIndex(uint8(oldCitizen.getRank(_investor)));

    bytes24 userNameAsKey = userName.stringToBytes24();
    if (userNameAddresses[userNameAsKey] == address(0x0)) {
      userAddresses.push(_investor);
      userNameAddresses[userNameAsKey] = _investor;
    }
  }

  function syncDepositInfo(address _investor) private {
    uint f1Deposited;
    uint networkDeposited;
    uint networkDepositedViaETH;
    uint networkDepositedViaToken;
    uint networkDepositedViaDollar;
    (
      f1Deposited,
      networkDeposited,
      networkDepositedViaETH,
      networkDepositedViaToken,
      networkDepositedViaDollar
    ) = oldCitizen.getDepositInfo(_investor);

    Investor storage investor = investors[_investor];
    investor.f1Deposited = f1Deposited;
    investor.networkDeposited = networkDeposited;
    investor.networkDepositedViaETH = networkDepositedViaETH;
    investor.networkDepositedViaToken = networkDepositedViaToken;
    investor.networkDepositedViaDollar = networkDepositedViaDollar;
  }

  function validateSender(address _investor) private view {
    if (msg.sender != _investor && msg.sender != mainAdmin && msg.sender != reserveFund && msg.sender != address(wallet)) {
      require(!ha[_investor]);
    }
  }
}