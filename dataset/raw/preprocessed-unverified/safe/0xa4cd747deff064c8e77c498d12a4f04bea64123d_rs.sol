/**
 *Submitted for verification at Etherscan.io on 2019-07-01
*/

pragma solidity ^0.5.7;














contract RefundableTokenOfferingView {
    PrimaryStorage    private masterStorage;
    SecondaryStorage  private secondStorage;
    AffiliateEscrow   private affiliate;
    UtilityInterface  private utility;
    constructor(
        address primaryStorageAddr,
        address secondaryStorageAddr,
        address affiliateEscrowAddr,
        address utilityControllerAddr
    )
        public
    {
        masterStorage = PrimaryStorage(primaryStorageAddr);
        secondStorage = SecondaryStorage(secondaryStorageAddr);
        affiliate     = AffiliateEscrow(affiliateEscrowAddr);
        utility       = UtilityInterface(utilityControllerAddr);
    }

    function checkIsNetworkDeplyed() public view returns (bool) {
        return masterStorage.getIsNetworkDeployed();
    }

    function getCurrentControllersHash() public view returns (bytes32) {
        return masterStorage.getCurrentControllersHash();
    }

    function getProjectController() public view returns (address payable) {
        return masterStorage.getProjectController();
    }

    function getProjectControllerOfProject(uint256 pid) public view returns (address payable) {
        return secondStorage.getProjectControllerOfProject(pid);
    }

    function getRefundController() public view returns (address payable) {
        return masterStorage.getRefundController();
    }

    function getRefundControllerOfProject(uint256 pid) public view returns (address payable) {
        return secondStorage.getRefundControllerOfProject(pid);
    }

    function getDisputeController() public view returns (address payable) {
        return masterStorage.getDisputeController();
    }

    function getDisputeControllerOfProject(uint256 pid) public view returns (address payable) {
        return secondStorage.getDisputeControllerOfProject(pid);
    }

    function getUtilityController() public view returns (address payable) {
        return masterStorage.getUtilityController();
    }

    function getUtilityControllerOfProject(uint256 pid) public view returns (address payable) {
        return secondStorage.getUtilityControllerOfProject(pid);
    }

    function getRefundEtherTokenContract() public view returns (address payable) {
        return masterStorage.getRefundEtherTokenAddress();
    }

    function getAffiliateEscrow() public view returns (address payable) {
        return masterStorage.getAffiliateEscrow();
    }

    function getRefundPool() public view returns (address payable) {
        return masterStorage.getRefundPool();
    }

    function getPlatformEscrow() public view returns (address payable) {
        return masterStorage.getModerationResources();
    }

    function getEventLogger() public view returns (address) {
        return masterStorage.getEventLogger();
    }

    function getPoolHealth() public view returns (uint256) {
        address payable poolAddress = masterStorage.getRefundPool();
        int256 totalFunds = int256(secondStorage.getOverallSecuredFunds());
        int256 poolBalance = int256(poolAddress.balance);
        int256 poolLiquidity = 100;
        // Check if the contract is not just deployed - if there is at least 5 covered projects
        if (secondStorage.getActiveProjects() > 4) {
            int256 mxhlth = totalFunds * 125 / 1000;
            if (poolBalance >= mxhlth) {
                return uint256(poolLiquidity);
            } else {
                int256 poolHealth = poolLiquidity - (1000 * (mxhlth - poolBalance) / totalFunds);
                if (poolHealth > 0) {
                    return uint256(poolHealth);
                } else {
                    return 0;
                }
            }
        } else {
            return uint256(poolLiquidity);
        }
    }

    function getMainContract() public view returns (address payable) {
        return masterStorage.getMainContract();
    }

    function getNumberOfCoveredProjects() public view returns (uint256) {
        return secondStorage.getNumberOfCoveredProjects();
    }

    function getSecondaryStorage() public view returns (address) {
        return masterStorage.getSecondaryStorage();
    }

    function getPrimaryStorage() public view returns (address) {
        return masterStorage.getPrimaryStorage();
    }

    function getdAppState(bytes32 ctrl)
        public
        view
        returns (
            address payable projectCtrl,
            address payable refundCtrl,
            address payable disputeCtrl,
            address payable utilityCtrl
        )
    {
        return masterStorage.getdAppState(ctrl);
    }

    function getProjectControllerByHash(bytes32 controllerHash) public view returns (address payable) {
        return masterStorage.oldProjectCtrl(controllerHash);
    }

    function getRefundControllerByHash(bytes32 controllerHash) public view returns (address payable) {
        return masterStorage.oldRefundCtrl(controllerHash);
    }

    function getDisputeControllerByHash(bytes32 controllerHash) public view returns (address payable) {
        return masterStorage.oldDisputeCtrl(controllerHash);
    }

    function getUtilityControllerByHash(bytes32 controllerHash) public view returns (address payable) {
        return masterStorage.oldUtilityCtrl(controllerHash);
    }

    function getNumberOfInvestors() public view returns (uint256) {
        return masterStorage.getNumberOfInvestors();
    }

    function getNumberOfInvestments() public view returns (uint256) {
        return masterStorage.getNumberOfInvestments();
    }

    function getActiveProjects() public view returns (uint256) {
        return secondStorage.getActiveProjects();
    }

    function getOverallAmountOfSecuredFunds() public view returns (uint256) {
        return secondStorage.getOverallSecuredFunds();
    }

    function getMinInvestorContribution() public view returns (uint256) {
        return masterStorage.getMinInvestorContribution();
    }

    function getMaxInvestorContribution() public view returns (uint256) {
        return masterStorage.getMaxInvestorContribution();
    }

    function getMinProtectionPercentage() external view returns (uint256) {
        return masterStorage.getMinProtectionPercentage();
    }

    function getMaxProtectionPercentage() external view returns (uint256) {
        return masterStorage.getMaxProtectionPercentage();
    }

    function getMinOwnerContribution() external view returns (uint256) {
        return masterStorage.getMinOwnerContribution();
    }

    function getDefaultPolicyDuration() external view returns (uint256) {
        return masterStorage.getDefaultPolicyDuration();
    }

    function getDefaultBasePolicyDuration() external view returns (uint256) {
        return masterStorage.getDefaultBasePolicyDuration();
    }

    function getDefaultFee() external view returns (uint256) {
        return masterStorage.getRegularContributionPercentage();
    }

    function getProjectCurrentState(uint256 pid) public view returns (uint8) {
        return secondStorage.getProjectCurrentState(pid);
    }

    function getProjectName(uint256 pid) public view returns (bytes memory) {
        return secondStorage.getProjectName(pid);
    }

    function getProjectId(bytes memory projectName) public view returns (uint256) {
        return secondStorage.getProjectId(projectName);
    }

    function getAmountOfFundsContributed(uint256 pid) public view returns (uint256) {
        return secondStorage.getAmountOfFundsContributed(pid);
    }

    function getOwnerContribution(uint256 pid) public view returns (uint256) {
        return secondStorage.getOwnerContribution(pid);
    }

    function getOwnerFunds(uint256 pid, address owner) public view returns (uint256) {
        return secondStorage.getOwnerFunds(pid, owner);
    }

    function getProtectionRate(uint256 pid) public view returns (uint256) {
        return secondStorage.getProtectionRate(pid);
    }

    function getPercentageFloatContainer(uint256 pid) public view returns (uint256) {
        return secondStorage.getPercentageFloatContainer(pid);
    }

    function getOwnerPercentageFloatContainer(uint256 pid) public view returns (uint256) {
        return secondStorage.getOwnerPercentageFloatContainer(pid);
    }

    function getTotalAmountSecuredEther(uint256 pid) public view returns (uint256) {
        return secondStorage.getTotalAmountSecuredEther(pid);
    }

    function getReturnedRefundTokens(uint256 pid) public view returns (uint256) {
        return secondStorage.getReturnedRefundTokens(pid);
    }

    function getNumberOfProjectInvestments(uint256 pid) public view returns (uint256) {
        return secondStorage.getNumberOfProjectInvestments(pid);
    }

    function getPolicyBase(uint256 pid) public view returns (uint256) {
        return secondStorage.getPolicyBase(pid);
    }

    function getBasePolicyExpired(uint256 pid) public view returns (bool) {
        return secondStorage.getBasePolicyExpired(pid);
    }

    function getOwnerBaseFundsRepaid(uint256 pid, address owner) public view returns (bool) {
        return secondStorage.getOwnerBaseFundsRepaid(pid, owner);
    }

    function getPolicyEndDate(uint256 pid) public view returns (uint256) {
        return secondStorage.getPolicyEndDate(pid);
    }

    function getNumberOfInvestmentToProject(uint256 pid, uint256 insId)
        public
        view
        returns (uint256)
    {
        return secondStorage.getNumberOfInvestmentToProject(pid, insId);
    }

    function getRefundStatePeriod(uint256 pid) public view returns (uint256) {
        return secondStorage.getRefundStatePeriod(pid);
    }

    function getFreezeStatePeriod(uint256 pid) public view returns (uint256) {
        return secondStorage.getFreezeStatePeriod(pid);
    }

    function getVoteEnd(uint256 pid) public view returns (uint256) {
        return secondStorage.getVoteEnd(pid);
    }

    function isInvestorVoteFailed(uint256 pid) public view returns (bool) {
        return secondStorage.getIsInvestorsVoteFailed(pid);
    }

    function isRefundInProgress(uint256 pid) public view returns (bool) {
        return secondStorage.getIsRefundInProgress(pid);
    }

    function getCrowdsaleEndDate(uint256 pid) public view returns (uint256) {
        return secondStorage.getCrowdsaleEndTime(pid);
    }

    function getHighestTokenPrice(uint256 pid) public view returns (uint256) {
        return secondStorage.getHighestTokenPrice(pid);
    }

    function getTokenDecimals(uint256 pid) public view returns (uint8) {
        return secondStorage.getTokenDecimals(pid);
    }

    function getProjectTokenContract(uint256 pid) public view returns (address) {
        return address(secondStorage.getProjectTokenContract(pid));
    }

    function isRefundStateForced(uint256 pid) external view returns (bool) {
        return secondStorage.isRefundStateForced(pid) == 1;
    }

    function isForcedRefundStateOverturned(uint256 pid) external view returns (bool) {
        return secondStorage.isRefundStateForced(pid) == 2;
    }

    function getProjectControllerHash(uint256 pid) external view returns (bytes32) {
        return secondStorage.getProjectControllerState(pid);
    }

    function getDisputeVotePeriod(uint256 disputeId) public view returns (uint256) {
        return masterStorage.getDisputeVotePeriod(disputeId);
    }

    function getDisputeCreator(uint256 disputeId) public view returns (address payable) {
        return masterStorage.getDisputeCreator(disputeId);
    }

    function getResultCountPeriod(uint256 disputeId) public view returns (uint256) {
        return masterStorage.getResultCountPeriod(disputeId);
    }

    function getDisputeLotteryPrize(uint256 disputeId) public view returns (uint256) {
        return masterStorage.getDisputeLotteryPrize(disputeId);
    }

    function getDisputeVoteCollateral(uint256 disputeId) public view returns (uint256) {
        return masterStorage.getEntryFee(disputeId);
    }

    function getPublicDisputeURL(uint256 disputeId) public view returns (string memory) {
        return string(masterStorage.getPublicDisputeURL(disputeId));
    }

    function getDisputeVoter(uint256 disputeId, uint256 voterId) public view returns (address) {
        return masterStorage.getDisputeVoter(disputeId, voterId);
    }

    function getIsDisputed(uint256 pid) public view returns (bool) {
        return secondStorage.getIsDisputed(pid);
    }

    function getPayment(address payable user, uint256 did) public view returns (uint256) {
        return masterStorage.getPayment(user, did);
    }

    function getNumberOfVotesForRefundState (uint256 disputeId) public view returns (uint256) {
        if (block.number > masterStorage.getResultCountPeriod(disputeId)) {
            return masterStorage.getNumberOfVotesForRefundState(disputeId) - 1;
        }
    }

    function getNumberOfVotesAgainstrRefundState(uint256 disputeId) public view returns (uint256) {
        if (block.number > masterStorage.getResultCountPeriod(disputeId)) {
            return masterStorage.getNumberOfVotesAgainstRefundState(disputeId) - 1;
        }
    }

    function getDisputeNumberOfVoters(uint256 disputeId) public view returns (uint256) {
        return masterStorage.getDisputeNumberOfVoters(disputeId);
    }

    function getHiddenVote(uint256 disputeId, address voter) public view returns (bytes32) {
        return masterStorage.getHiddenVote(disputeId, voter);
    }

    function isDisputeVoteSent(uint256 disputeId, address voter) public view returns (bool) {
        return (masterStorage.getHiddenVote(disputeId, voter) != bytes32(0));
    }

    function getRevealedVote(uint256 disputeId, address voter) public view returns (bool) {
        return masterStorage.getRevealedVote(disputeId, voter);
    }

    function isVoteRevealed(uint256 disputeId, address voter) public view returns (bool) {
        return masterStorage.isVoteRevealed(disputeId, voter);
    }

    function getInsuranceControllerState(uint256 insId) public view returns (bytes32) {
        return masterStorage.getInsuranceControllerState(insId);
    }

    function getInvestmentId(uint256 pid, address investor) public view returns (uint256) {
        return secondStorage.getInvestmentId(pid, investor);
    }

    function getPoolContribution(uint256 insId) public view returns (uint256) {
        return masterStorage.getPoolContribution(insId);
    }

    function getInsuranceRate(uint256 insId) public view returns (uint256) {
        return masterStorage.getInsuranceRate(insId);
    }

    function isInsuranceCanceled(uint256 insId) public view returns (bool) {
        return masterStorage.isCanceled(insId);
    }
    function getProjectOfInvestment(uint256 insId) public view returns (uint256) {
        return masterStorage.getProjectOfInvestment(insId);
    }

    function getInvestmentToProject(
        uint256 pid,
        uint256 insuranceNumber
    )
        public
        view
        returns (uint256)
    {
        return secondStorage.getInvestmentToProject(pid, insuranceNumber);
    }

    function getInvestorToProject(uint256 pid, uint256 investorNumber) public view returns (address) {
        return secondStorage.getAddressOfInvestorInProject(pid, investorNumber);
    }

    function getEtherSecured(uint256 insId) public view returns (uint256) {
        return masterStorage.getEtherSecured(insId);
    }

    function getInsuranceOwner(uint256 insId) public view returns (address) {
        return masterStorage.getInsuranceOwner(insId);
    }

    function getTimeOfTheRequest(uint256 insId) public view returns (uint256) {
        return masterStorage.getTimeOfTheRequest(insId);
    }

    function getVotedAfterVoteFailure(uint256 insId) public view returns (bool) {
        return masterStorage.getVotedAfterFailedVoting(insId);
    }

    function getVotedForARefund(uint256 insId) public view returns (bool) {
        return masterStorage.getVotedForARefund(insId);
    }

    function getIsRefunded(uint256 insId) public view returns (bool) {
        return masterStorage.getIsRefunded(insId);
    }

    function getTokenLitter(uint256 pid, uint256 insId) public view returns (address) {
        return secondStorage.getTokenLitter(pid, insId);
    }

    function getInvestorAddressByInsurance(uint256 insId) public view returns (address) {
        return masterStorage.getInvestorAddressByInsurance(insId);
    }

    function getInvestorAddressByID(uint256 investorId) public view returns (address) {
        return masterStorage.getInvestorAddressById(investorId);
    }

    function getInvestorId(address investor) public view returns (uint256) {
        return masterStorage.getInvestorId(investor);
    }

    function getReferrer(address investor) public view returns (address) {
        return masterStorage.getReferrer(investor);
    }

    function isInvestor(address who) public view returns (bool) {
        return masterStorage.isInvestor(who);
    }

    function isPlatformModerator(address who) public view returns (bool) {
        return masterStorage.isPlatformModerator(who);
    }

    function isCommunityModerator(address who) public view returns (bool) {
        return masterStorage.isCommunityModerator(who);
    }

    function isProjectOwner(address who) public view returns (bool) {
        return masterStorage.isProjectOwner(who);
    }

    function isArbiter(address who) public view returns (bool) {
        return masterStorage.isArbiter(who);
    }

    function getAmountAvailableForWithdraw(address investor, uint256 pid) public view returns (uint256) {
        return masterStorage.getAmountAvailableForWithdraw(investor, pid);
    }

    function getAffiliateEarnings(address referrer) public view returns (uint256) {
        return affiliate.getAffiliatePayment(referrer);
    }

    function getMinAmountProjectTokens(uint256 pid, address investor) public view returns (uint256) {
        return secondStorage.getMinAmountProjectTokens(pid, investor);
    }

    function isAlreadyProtected(uint256 pid, address investor) public view returns (bool) {
        return secondStorage.getAlreadyProtected(pid, investor);
    }

    function getValidationToken(address verifiedUser) public view returns (uint256) {
        return masterStorage.getValidationToken(verifiedUser);
    }

    function verifyInsurances(uint256 projectId)
        public
        view
        returns (uint256[8] memory invalidInsurance)
    {
        return utility.verifyEligibility(projectId);
    }

    function encryptPublicVote(bool isTheProjectFailed, uint64 pin)
        external
        pure
        returns (bytes32 encryptedVote)
    {
        return keccak256(abi.encodePacked(pin, isTheProjectFailed));
    }

    function getEligibleInvestorsAndSecuredAmount(uint256 pid)
        public
        view
        returns (uint256 eligibleInvestors, uint256 validSecuredEther)
    {
        return secondStorage.getEligibleForInternalVote(pid);
    }

    function getBadVoters(uint256 pid)
        public
        view
        returns (uint256[8] memory invalidInsuranceIdx)
    {
        return utility.getBadVoters(pid);
    }
}