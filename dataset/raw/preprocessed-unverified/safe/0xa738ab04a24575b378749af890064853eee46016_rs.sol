pragma solidity 0.6.8;





// https://en.wikipedia.org/wiki/Cura_Annonae
contract CuraAnnonae {
  using SafeMath for uint256;

  // variables.
  ERC20 public YFMSToken;
  address public owner;
  uint256 public numberOfVaults;
  uint256 public rewardsBalance;
  uint256 public lastRewardUpdate = 0;
  uint256 public currentDailyReward;

  // mappings.
  mapping(string => mapping(address => uint256)) internal vaults_data; // { VaultName: { UserAddress: value }}

  constructor(address _wallet) public {
    owner = msg.sender;
    YFMSToken = ERC20(_wallet);
  }

  // view the number of tokens left to distribute.
  function getRewardsBalance() public view returns (uint256) {
    return YFMSToken.balanceOf(address(this));
  }

  // view the current daily reward for all vaults.
  function getDailyReward() public view returns (uint256) {
    return currentDailyReward;
  }

  function getNumberOfVaults() public view returns (uint256) {
    return numberOfVaults;
  }

  // get user balance in specific vault.
  function getUserBalanceInVault(string memory _vault, address _user) public view returns (uint256) {
    require(vaults_data[_vault][_user] >= 0);
    return vaults_data[_vault][_user];
  }

  // calculate the daily reward for all vaults.
  function updateDailyReward() public {
    require(msg.sender == owner);
    require(now.sub(lastRewardUpdate) >= 1 days || lastRewardUpdate == 0);
    lastRewardUpdate = now;
    currentDailyReward = YFMSToken.balanceOf(address(this)) / 10000 * 40;
  }

  // staking rewards distributed
  // called from vaults.
  function updateVaultData(string memory vault, address who, address user, uint256 value) public {
    require(msg.sender == who);
    require(value > 0);
    vaults_data[vault][user] = vaults_data[vault][user].add(value);
  }

  // add a vault.
  function addVault(string memory name) public {
    require(msg.sender == owner);
    // initialize new vault.
    vaults_data[name][msg.sender] = 0; 
    // increment number of vaults.
    numberOfVaults = numberOfVaults.add(1);
  }

  // enables users to stake stable coins/ YFMS from their respective vaults.
  // called from vaults.
  function stake(string memory _vault, address _receiver, uint256 _amount, address vault) public returns (bool) {
    require(msg.sender == vault); // require that the vault is calling the contract.
    // update mapping.
    vaults_data[_vault][_receiver] = vaults_data[_vault][_receiver].add(_amount);
    return true;
  }

  // enables users to unstake staked coins at a 2.5% cost (tokens will be burned).
  // called from vaults.
  function unstake(string memory _vault, address _receiver, address vault) public {
    require(msg.sender == vault); // require that the vault is calling the contract.
    // remove staked balance.
    vaults_data[_vault][_receiver] = 0;
  }

  function distributeRewardsToVault(address vault) public {
    require(msg.sender == owner);
    require(currentDailyReward > 0);
    // perhaps an additional require to ensure this vault hasn't already received rewards today.
    // determine how many tokens to send to vault.
    uint256 rewards = currentDailyReward.div(numberOfVaults);
    YFMSToken.transfer(vault, rewards);
  }
}