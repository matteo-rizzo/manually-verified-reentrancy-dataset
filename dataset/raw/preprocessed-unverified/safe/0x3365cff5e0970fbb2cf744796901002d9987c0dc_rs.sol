/**
 *Submitted for verification at Etherscan.io on 2020-07-05
*/

pragma solidity ^0.5.11;






contract Destructible is Ownable {

  constructor() public payable { }

  
  function destroy() public onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address payable _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }
}





contract DeploymentManager is Destructible {
    struct DeployedContract {
        address deployer;
        address contractAddress;
    }

    modifier isAllowedUser() {
        require(
            allowedUsers[msg.sender] == true,
            "You are not allowed to deploy a campaign."
        );
        _;
    }

    Deployer erc20Deployer;
    

    mapping(address => bool) public allowedUsers;
    mapping(address => DeployedContract[]) public deployedContracts;
    mapping(address => uint256) public contractsCount;

    constructor(address _erc20Deployer) public {
        erc20Deployer = Deployer(_erc20Deployer);
        allowedUsers[msg.sender] = true;
    }

    event NewFundingContract(
        address indexed deployedAddress,
        address indexed deployer
    );

    function updateERC20Deployer(address _erc20Deployer) external onlyOwner {
        erc20Deployer = Deployer(_erc20Deployer);
    }

    function updateAllowedUserPermission(address _user, bool _isAllowed)
        external
        onlyOwner
    {
        require(_user != address(0), "User must be a valid address");
        allowedUsers[_user] = _isAllowed;
    }

    function deploy(
        uint256 _numberOfPlannedPayouts,
        uint256 _withdrawPeriod,
        uint256 _campaignEndTime,
        uint256 _amountPerPayment,
        address payable __owner,
        address _tokenAddress
    ) external isAllowedUser {
        if (_tokenAddress == address(0)) {
            revert("Can only deploy ERC20 Funding Campaign Contract");
        }

        FundingContract c = erc20Deployer.deploy(
            _numberOfPlannedPayouts,
            _withdrawPeriod,
            _campaignEndTime,
            _amountPerPayment,
            __owner,
            _tokenAddress,
            msg.sender
        );
        deployedContracts[msg.sender].push(
            DeployedContract(msg.sender, address(c))
        );
        contractsCount[msg.sender] += 1;
        emit NewFundingContract(address(c), msg.sender);
    }

    function withdrawFromAllContracts() public {
        DeployedContract[] storage contracts = deployedContracts[msg.sender];
        uint256 totalContracts = contracts.length;
        require(totalContracts > 0, "No contract deployed");

        for (uint256 index = 0; index < contracts.length; index++) {
            FundingContract fundingContract = FundingContract(
                contracts[index].contractAddress
            );
            fundingContract.withdraw();
        }
    }
}

contract FundingManagerContract is Ownable {
    event SplitSharedFunds(
        address[] indexed addresses,
        uint256 indexed totalSpent
    );

    struct FundingLevel {
        address campaign;
        uint256 requiredBalance;
    }

    address public deploymentManager;
    address public tokenAddress;

    constructor(address _deploymentManager, address _tokenAddress) public {
        owner = msg.sender;
        deploymentManager = _deploymentManager;
        tokenAddress = _tokenAddress;
    }

    function updateDeploymentManager(address _deploymentManager)
        external
        onlyOwner
    {
        require(_deploymentManager != address(0), "AddressNotNull");
        deploymentManager = _deploymentManager;
    }

    function payoutToCampaigns() external {
        DeploymentManager manager = DeploymentManager(deploymentManager);
        uint256 campaignsCount = manager.contractsCount(msg.sender);
        require(campaignsCount > 0, "NoContracts");
        IERC20 token = IERC20(tokenAddress);

        for (uint256 index = 0; index < campaignsCount; index += 1) {
            (, address currentContractAddress) = getCampaign(index);
            FundingContract campaign = FundingContract(currentContractAddress);
            uint256 campaignBalance = token.balanceOf(currentContractAddress);
            if (
                campaign.canWithdraw() &&
                !campaign.cancelled() &&
                campaignBalance > 0 &&
                campaign.totalNumberOfPayoutsLeft() > 0
            ) {
                campaign.withdraw();
            }
        }
    }

    function splitShareCampaigns(
        uint256 _campaignTopLimit,
        address[] calldata _campaigns
    ) external {
        uint256 campaignsCount = _campaigns.length;
        require(campaignsCount > 0, "NoContracts");

        IERC20 token = IERC20(tokenAddress);

        FundingLevel[25] memory fundings;
        uint256 counter = 0;
        uint256 totalBalanceNeed;
        for (uint256 index = 0; index < campaignsCount; index += 1) {
            address currentContractAddress = _campaigns[index];
            uint256 balanceOfContract = token.balanceOf(currentContractAddress);
            if (
                currentContractAddress != address(0) &&
                _campaignTopLimit > balanceOfContract
            ) {
                FundingContract campaign = FundingContract(
                    currentContractAddress
                );
                if (
                    !campaign.cancelled() &&
                    campaign.totalNumberOfPayoutsLeft() > 0
                ) {
                    fundings[counter] = FundingLevel(
                        currentContractAddress,
                        _campaignTopLimit - balanceOfContract
                    );
                    counter += 1;
                    totalBalanceNeed += _campaignTopLimit - balanceOfContract;
                }
            }
        }
        uint256 totalBalanceInContract = token.balanceOf(address(this));
        require(totalBalanceInContract > 0, "NoMoneyLeft");
        uint256 spentAmount = 0;
        for (
            uint256 fundingIndex = 0;
            fundingIndex < counter;
            fundingIndex += 1
        ) {
            FundingLevel memory level = fundings[fundingIndex];
            uint256 amountToPay = (totalBalanceInContract *
                level.requiredBalance) / totalBalanceNeed;
            if (amountToPay > level.requiredBalance) {
                amountToPay = level.requiredBalance;
            }
            token.transfer(fundings[fundingIndex].campaign, amountToPay);
            spentAmount += amountToPay;
        }
        emit SplitSharedFunds(_campaigns, spentAmount);
    }

    function destroyAndSend() external onlyOwner {
        destroyAndSend(tokenAddress);
    }

    function sendTokens(address _tokenAddress, address _toAddress)
        public
        onlyOwner
    {
        IERC20 token = IERC20(_tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "InsufficientBalance");
        token.transfer(_toAddress, balance);
    }

    function destroyAndSend(address _tokenAddress) public onlyOwner {
        sendTokens(_tokenAddress, owner);
        selfdestruct(owner);
    }

    function getCampaign(uint256 num)
        public
        view
        returns (address deployer, address currentContractAddress)
    {
        DeploymentManager manager = DeploymentManager(deploymentManager);
        return (manager.deployedContracts(msg.sender, num));
    }
}