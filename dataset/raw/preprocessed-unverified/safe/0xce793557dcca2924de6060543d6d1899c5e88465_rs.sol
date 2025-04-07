/**
 *Submitted for verification at Etherscan.io on 2019-06-28
*/

pragma solidity ^0.5.7;


























contract RefundableTokenOfferingUtility {
    using SafeMath for uint256;
    using SafeMath for uint64;

    PrimaryStorage   masterStorage;
    SecondaryStorage secondStorage;
    RefundPool       refundPool;
    Logger           eventLogger;

    address private main;

    constructor(
        address dAppMainContractAddr,
        address storageAddr,
        address secStorageAddr,
        address eventLoggerAddr,
        address payable refundPoolAddr
    )
        public
    {
        masterStorage = PrimaryStorage(storageAddr);
        secondStorage = SecondaryStorage(secStorageAddr);
        refundPool = RefundPool(refundPoolAddr);
        eventLogger = Logger(eventLoggerAddr);
        main = dAppMainContractAddr;
    }

    modifier onlyMain {
        if(msg.sender == main) {
            _;
        }
        else {
            revert("Only main ICO-Refund.com contract is allowed");
        }
    }
    function withdrawInsuranceFee(uint256 pid, address payable owner, uint256 insuranceId) external onlyMain {
        uint256 amount = masterStorage.getAmountAvailableForWithdraw(owner, pid);
        require(masterStorage.isCanceled(insuranceId) == true, "Insurance was canceled");
        require(amount > 0, "No funds available");
        refundPool.withdrawInsuranceFee(pid, owner, amount);
    }

    function withdraw(uint256 pid, address payable owner, uint256 insuranceId) external onlyMain {
        uint256 amount = masterStorage.getAmountAvailableForWithdraw(owner, pid);
        require(!masterStorage.isCanceled(insuranceId), "Insurance was canceled");
        require(amount > 0, "No refund amount available for withdrawal");
        refundPool.withdraw(pid, owner, amount);
    }

    function ownerWithdraw(address payable owner, address payable sendTo, uint256 pid)
        external
        onlyMain
        returns (bool)
    {
        uint8 currentProjectState = secondStorage.getProjectCurrentState(pid);
        require(currentProjectState == 1 || currentProjectState == 5 || currentProjectState == 6, "Not allowed");
        require(!secondStorage.getIsRefundInProgress(pid), "Refund in progress, not allowed");
        require(block.number > secondStorage.getFreezeStatePeriod(pid), "Project is in freeze state now");
        require(block.number > secondStorage.getPolicyBase(pid), "Base policy not expired");

        uint256 amount = secondStorage.getOwnerFunds(pid, owner);
        address payable payee;

        if (sendTo != address(0)) {
            payee = sendTo;
        } else {
            payee = owner;
        }

        if (block.number > secondStorage.getPolicyEndDate(pid)) {
            if (secondStorage.getProjectCurrentState(pid) != 6) {
                secondStorage.setProjectCurrentState(pid, 6);
            }
            require(amount > 0, "You have no owner funds for a withdraw");
            secondStorage.setOwnerFunds(pid, owner, 0);
            secondStorage.setOwnerContribution(
                pid,
                secondStorage.getOwnerContribution(pid).sub(amount)
            );
            refundPool.withdraw(pid, payee, amount);

            eventLogger.emitOwnerFundsRepaid(owner, pid, amount);
            return true;
        } else {
            require(!secondStorage.getOwnerBaseFundsRepaid(pid, owner), "Already repaid");
            amount = amount.div(2);
            secondStorage.setOwnerBaseFundsRepaid(pid, owner);
            secondStorage.setOwnerFunds(pid, owner, amount);
            secondStorage.setOwnerContribution(
                pid,
                secondStorage.getOwnerContribution(pid).sub(amount)
            );
            refundPool.withdraw(pid, payee, amount);

            eventLogger.emitOwnerBaseFundsRepaid(owner, pid, amount);
            return true;
        }
    }

    function withdrawDisputePayment(address payable payee, uint256 did)
        external
        onlyMain
    {
        require(block.number > masterStorage.getResultCountPeriod(did), "Not allowed");
        uint256 pid = masterStorage.getDisputeProjectId(did);

        if (payee == masterStorage.getDisputeCreator(did)) {
            require(secondStorage.getIsRefundInProgress(pid), "The project was not settled as failed");
        } else {
            bool isVoteRevealed = masterStorage.isVoteRevealed(did, payee);
            if (secondStorage.getIsRefundInProgress(pid)) {
                require(isVoteRevealed && masterStorage.getRevealedVote(did, payee), "Not allowed, vote do not match the general consensus");
            } else {
                require(isVoteRevealed && !masterStorage.getRevealedVote(did, payee), "Not allowed, vote do not match the general consensus");
            }
        }
        uint256 amount = masterStorage.getPayment(payee, did);
        require(amount > 0, "No funds to withdraw");
        masterStorage.setPayment(payee, did, 0);
        refundPool.withdraw(pid, payee, amount);
        eventLogger.emitDisputePayment(payee, did, amount);
    }

    function verifyEligibility(uint256 projectId)
        external
        view
        returns (uint256[8] memory invalidInsuranceId)
    {
        uint8 pjs = secondStorage.getProjectCurrentState(projectId);
        uint256 vfr = secondStorage.getReturnedRefundTokens(projectId);
        if ((pjs == 1 || pjs == 2) && (!secondStorage.getIsRefundInProgress(projectId) && vfr > 1)) {
            invalidInsuranceId = secondStorage.getInvalidInsurances(projectId);
            if (invalidInsuranceId[0] != 0) {
                return invalidInsuranceId;
            }
        }
        return invalidInsuranceId;
    }

    function getBadVoters(uint256 pid) external view returns(uint[8] memory invalidInsuranceId) {
        uint256 voteEnd = secondStorage.getVoteEnd(pid);
        uint256 freezeTime = secondStorage.getFreezeStatePeriod(pid);
        uint8 pjs = secondStorage.getProjectCurrentState(pid);
        bool isRefundInProgress = secondStorage.getIsRefundInProgress(pid);

        require (pjs == 1 && !isRefundInProgress, "Not allowed");
        if (freezeTime == 1 && voteEnd > 1 && block.number > voteEnd) {
            invalidInsuranceId = secondStorage.getIncorrectlyVoted(pid);
            if (invalidInsuranceId[0] != 0) {
                return invalidInsuranceId;
            }
        }
    }

    function cancelInvalid(uint256 pid, uint256[8] calldata invalidInsuranceId)
        external
        onlyMain
    {
        uint256 i;
        uint8 pjs = secondStorage.getProjectCurrentState(pid);
        uint256 voteEnd = secondStorage.getVoteEnd(pid);
        uint256 freezeTime = secondStorage.getFreezeStatePeriod(pid);
        uint256 vfr = secondStorage.getReturnedRefundTokens(pid);
        require(
            (pjs == 1 || pjs == 2) && (!secondStorage.getIsRefundInProgress(pid) && vfr > 1),
            "The project is not eligible for verification of insurance validity"
        );
        RefundController refundController = RefundController(secondStorage.getRefundControllerOfProject(pid));
        address owner;
        address tokenLitter;
        address tokenAddress = secondStorage.getProjectTokenAddress(pid);
        uint256 minAmountProjectTokens;
        ProjectToken tokenContract = ProjectToken(tokenAddress);

        while (i < invalidInsuranceId.length && invalidInsuranceId[i] != 0) {
            owner = masterStorage.getInsuranceOwner(invalidInsuranceId[i]);
            tokenLitter = secondStorage.getTokenLitter(pid, invalidInsuranceId[i]);
            minAmountProjectTokens = secondStorage.getMinAmountProjectTokens(pid, owner);
            require(
                (freezeTime == 1 && voteEnd > 1 && block.number > voteEnd &&
                !secondStorage.getIsInvestorsVoteFailed(pid) &&
                masterStorage.getVotedForARefund(invalidInsuranceId[i])) ||

                (freezeTime == 1 && voteEnd > 1 && block.number > voteEnd &&
                secondStorage.getIsInvestorsVoteFailed(pid) &&
                masterStorage.getVotedAfterFailedVoting(invalidInsuranceId[i])) ||

                (tokenContract.balanceOf(owner) < minAmountProjectTokens &&
                tokenContract.balanceOf(tokenLitter) < minAmountProjectTokens),
                "Canceling insurance is not allowed"
            );
            refundController.invalidateInsurance(invalidInsuranceId[i], pid);
            i++;
        }
    }

    function removeCanceled(
        uint256 pid,
        uint256[8] calldata invalidInsuranceId
    )
        external
        onlyMain
    {
        for (uint256 i = 0; invalidInsuranceId.length > i; i++) {
            if (invalidInsuranceId[i] != 0) {
                require(masterStorage.isCanceled(invalidInsuranceId[i]), "Insurance is not canceled");
                secondStorage.removeInsuranceIdFromProject(pid, invalidInsuranceId[i], 0);
                address insuranceOwner = masterStorage.getInsuranceOwner(invalidInsuranceId[i]);
                secondStorage.removeInvestorAddressFromProject(pid, insuranceOwner, 0);
            } else {
                break;
            }
        }
    }

    function voteMaintenance(uint256 startFrom, uint256 endBefore) external onlyMain {
        uint256 ncp = endBefore;
        address utilityControllerAddress;
        if (ncp == 0) ncp = secondStorage.getNumberOfCoveredProjects();

        for (uint256 i = startFrom; ncp > i; i++) {
            utilityControllerAddress = secondStorage.getUtilityControllerOfProject(i);
            if (utilityControllerAddress != address(this)) {
                UtilityController utilityController = UtilityController(utilityControllerAddress);
                utilityController.projectVoteMaintenance(i);
            } else {
                projectVoteMaintenance(i);
            }
        }
    }

    function projectVoteMaintenance(uint256 pid) public {
        uint8 pjs;
        uint256 pve;
        pjs = secondStorage.getProjectCurrentState(pid);
        pve = secondStorage.getVoteEnd(pid);
        if (pjs == 2 && block.number > pve) {
            RefundController refundController = RefundController(secondStorage.getRefundControllerOfProject(pid));
            refundController.finalizeVote(pid);
        }

        if (secondStorage.getIsInvestorsVoteFailed(pid)   &&
            !secondStorage.getIsRefundInProgress(pid)     &&
            pjs == 1 && !secondStorage.getIsDisputed(pid) &&
            secondStorage.getFreezeStatePeriod(pid) > 1   &&
            block.number > secondStorage.getFreezeStatePeriod(pid))
        {
            secondStorage.setFreezeStatePeriod(pid, 1);
        }
    }

    function managePolicies(uint256 startFrom, uint256 numberOfProjects) external onlyMain {
        uint256 ncp = numberOfProjects;
        address utilityControllerAddress;
        if (ncp == 0) ncp = secondStorage.getNumberOfCoveredProjects();

        for (uint i = startFrom; ncp > i; i++) {
            utilityControllerAddress = secondStorage.getUtilityControllerOfProject(i);
            if (utilityControllerAddress != address(this)) {
                UtilityController utilityController = UtilityController(utilityControllerAddress);
                utilityController.projectStateMaintenance(i);
            } else {
                projectStateMaintenance(i);
            }
        }
    }

    function projectStateMaintenance(uint256 pid) public {
        uint8 pjs;
        uint256 tfc;
        bool refundInProgress;
        bool isBasePolicyExpired;
        pjs = secondStorage.getProjectCurrentState(pid);
        tfc = secondStorage.getAmountOfFundsContributed(pid);
        refundInProgress = secondStorage.getIsRefundInProgress(pid);
        address payable modRsrc = masterStorage.getModerationResources();
        isBasePolicyExpired = secondStorage.getBasePolicyExpired(pid);

        pjs = secondStorage.getProjectCurrentState(pid);
        if (pjs == 1 && !refundInProgress && block.number > secondStorage.getPolicyEndDate(pid)) {
            secondStorage.setProjectCurrentState(pid, 6);
        }

        if (pjs == 1 && refundInProgress && block.number > secondStorage.getRefundStatePeriod(pid)) {
            secondStorage.setProjectCurrentState(pid, 4);
            secondStorage.setIsRefundInProgress(pid, false);
        }

        if (pjs == 0 && block.number > secondStorage.getCrowdsaleEndTime(pid).add(93558)) {
            secondStorage.setProjectCurrentState(pid, 1);
        }

        if ((tfc > 1 && pjs == 6 && block.number > secondStorage.getPolicyEndDate(pid).add(185142)) ||
            (tfc > 1 && pjs == 5))
        {
            if (isBasePolicyExpired) {
                refundPool.withdraw(pid, modRsrc, tfc.div(2));
            } else {
                refundPool.withdraw(pid, modRsrc, tfc);
            }
            secondStorage.setAmountOfFundsContributed(pid, 0);
        }

        if (pjs != 6 && pjs != 5 && pjs != 4 &&
            block.number > secondStorage.getPolicyBase(pid) && !isBasePolicyExpired)
        {
            uint256 ase = secondStorage.getTotalAmountSecuredEther(pid);
            secondStorage.setTotalAmountSecuredEther(pid, ase.div(2));
            refundPool.withdraw(pid, modRsrc, tfc.div(2));
            secondStorage.setBasePolicyExpired(pid);
        }
    }
}