/**
 *Submitted for verification at Etherscan.io on 2019-06-28
*/

pragma solidity ^0.5.7;























/**
  *
  *  Refundable Token Offerings
  *  Project Controller
  *
  */

contract ProjectController {
    using SafeMath for uint256;
    using SafeMath for uint64;
    using SafeMath for uint8;

    PrimaryStorage   masterStorage;
    SecondaryStorage secondStorage;

    RefundPool refundPool;
    AffiliateEscrow affiliate;
    RefundEther refundEther;
    Logger eventLogger;

    address payable private main;
    address payable private modResources;

    constructor(
        address payable dAppMainContractAddr,
        address storageAddr,
        address secStorageAddr,
        address refundEtherAddr,
        address eventLoggerAddr,
        address payable modResourcesAddr,
        address payable refundPoolAddr,
        address payable affiliateEscrowAddr
    )
        public
    {
        masterStorage = PrimaryStorage(storageAddr);
        secondStorage = SecondaryStorage(secStorageAddr);
        refundPool = RefundPool(refundPoolAddr);
        affiliate = AffiliateEscrow(affiliateEscrowAddr);
        refundEther = RefundEther(refundEtherAddr);
        modResources = modResourcesAddr;
        eventLogger = Logger(eventLoggerAddr);
        main = dAppMainContractAddr;
    }

    modifier onlyMain {
        _isMain();
        _;
    }

    modifier onlyInsuranceOwner(uint256 insId) {
        require (msg.sender == masterStorage.getInsuranceOwner(insId), "Not allowed");
        _;
    }

    function newProject(
        bytes   calldata projectName,
        address tokenAddress,
        uint256 crowdsaleEnd,
        uint256 highestCrowdsalePrice,
        uint8   tokenDecimals
    )
        external
        payable
        onlyMain
    {
        uint256 pid = masterStorage.addProject();

        masterStorage.setControllerStateToProject(pid);
        secondStorage.setProjectId(pid);
        secondStorage.setInitialProtectionRate(pid);
        secondStorage.setPolicyBase(pid);
        secondStorage.setPolicyEnd(pid);

        secondStorage.setVotesForRefundState(pid, 1);
        secondStorage.setPercentageFloatContainer(pid, 1);
        secondStorage.setAmountOfFundsContributed(pid, 1);
        secondStorage.setTotalAmountSecuredEther(pid, 1);
        secondStorage.setReturnedRefundTokens(pid, 1);

        secondStorage.setOwnerContribution(pid, 1);
        secondStorage.setOwnerPercentageFloatContainer(pid, 1);
        secondStorage.setInsuranceIdToProject(pid, 0);
        secondStorage.setInvestorToProject(pid, address(0));

        secondStorage.setRefundStatePeriod(pid, 1);
        secondStorage.setFreezeStatePeriod(pid, 1);

        secondStorage.setProjectName(pid, projectName);
        secondStorage.setProjectTokenContract(pid, tokenAddress);
        secondStorage.setCrowdsaleEndTime(pid, crowdsaleEnd);
        secondStorage.setHighestTokenPrice(pid, highestCrowdsalePrice);
        secondStorage.setTokenDecimals(pid, tokenDecimals);

        if (msg.value != 0) {
            refundPool.deposit.value(msg.value)(pid);
        }
        eventLogger.emitNewProject(pid, projectName);
    }

    function newInsurance(
        address payable insOwner,
        uint256 pid,
        address referrer
    )
        external
        payable
        onlyMain
        returns (bool)
    {
        bytes32 cntrllrs = secondStorage.getProjectControllerState(pid);
        if (block.number > secondStorage.getCrowdsaleEndTime(pid).add(93558) && isOpen(pid)) {
            _closeProject(pid);
            insOwner.transfer(msg.value);
            return false;
        }
        uint256 ins = _newInsuranceInit(pid, insOwner, referrer, cntrllrs);
        _newInsuranceCalculations(pid, ins, insOwner, referrer);
        secondStorage.setTokenLitter(pid, ins, _createTokenLitter(insOwner, pid, ins));
        uint256 npc = _calcPoolContribution(bool(referrer != address(0)), referrer, msg.value);
        uint256 nfp = secondStorage.getAmountOfFundsContributed(pid).add(npc);
        masterStorage.setPoolContribution(ins, npc);
        secondStorage.setAmountOfFundsContributed(pid, nfp);

        secondStorage.setAlreadyProtected(pid, insOwner);
        secondStorage.setInsuranceIdToProject(pid, ins);
        secondStorage.setInvestorToProject(pid, insOwner);
        _newProtectionRate(pid, nfp);
        refundPool.insuranceDeposit.value(npc)(pid);

        eventLogger.emitNewInsurance(pid, insOwner, ins, msg.value);
    }

    function newOwnerContribution(
        uint256 pid,
        address ownerAddr
    )
        external
        payable
        onlyMain
    {
        require(pid < secondStorage.getNumberOfCoveredProjects(), "Invalid project ID");
        uint256 ifactp = secondStorage.getAmountOfFundsContributed(pid);
        uint256 mcnmpr = masterStorage.getMinOwnerContribution();
        if (ifactp < 88 ether) {
            mcnmpr;
        }

        if (ifactp >= 88 ether && ifactp < 288 ether) {
            mcnmpr = mcnmpr.mul(2).add(1);
        }

        if (ifactp >= 288 ether) {
            mcnmpr = mcnmpr.mul(4);
        }

        require(msg.value >= mcnmpr, "Owner contribution is below the minimum amount required");

        uint256 cpr = secondStorage.getProtectionRate(pid);
        uint256 pfc = secondStorage.getOwnerPercentageFloatContainer(pid);
        uint256 npr;
        uint256 rmn;
        secondStorage.setOwnerPercentageFloatContainer(pid, cpr.add(msg.value));
        mcnmpr = masterStorage.getMaxProtectionPercentage();
        if (cpr != mcnmpr) {
            (npr, rmn) = _increasePercentage(ifactp, mcnmpr, cpr, pfc.add(msg.value));
            if (cpr != npr) {
                secondStorage.setProtectionRate(pid, npr);
                secondStorage.setOwnerPercentageFloatContainer(pid, rmn);
            }
        }
        uint256 pcf = secondStorage.getOwnerContribution(pid);
        uint256 ncf = _calcOwnerContribution(msg.value, ifactp);
        secondStorage.setOwnerContribution(pid, pcf.add(ncf));

        uint256 prevOwnerFunds = secondStorage.getOwnerFunds(pid, ownerAddr);
        secondStorage.setOwnerFunds(pid, ownerAddr, prevOwnerFunds.add(ncf));
        if (!masterStorage.isProjectOwner(ownerAddr)) {
            masterStorage.setProjectOwner(ownerAddr);
        }
        refundPool.deposit.value(ncf)(pid);
        eventLogger.emitOwnerContribution(pid, ownerAddr, msg.value, npr);
    }

    function close(uint256 pid) public onlyMain {
        _closeProject(pid);
    }

    function setNewProjectTokenPrice(
        uint256 pid,
        uint256 newPrice,
        uint256 insuranceIndex
    )
        external
        onlyMain
        returns (uint256 numberOfChanges)
    {
        uint256 crrprc = secondStorage.getHighestTokenPrice(pid);
        require(crrprc <= newPrice, "New price is lower than the current one");
        uint256 tnprinv = secondStorage.getNumberOfProjectInvestments(pid);
        address investr;
        uint256 ethscrd;
        uint256 ttlainv;
        uint256 nwmntkn;

        if (tnprinv > 112) tnprinv = 112;
        uint256 i;

        if (insuranceIndex != 0) i = insuranceIndex; else i = 1;
        for (i; i < tnprinv; i++) {
            uint256 insId = secondStorage.getInvestmentToProject(pid, i);
            // Recalculate the minimum amount of tokens investor has to posses if the investment is not already canceled
            if (!masterStorage.isCanceled(insId)) {
                investr = masterStorage.getInsuranceOwner(insId);
                ethscrd = masterStorage.getEtherSecured(insId);
                ttlainv = ethscrd.mul(100).div(masterStorage.getInsuranceRate(insId));
                nwmntkn = ttlainv.div(newPrice) * 10 ** uint256(secondStorage.getTokenDecimals(pid));

                if (secondStorage.getMinAmountProjectTokens(pid, investr) > nwmntkn) {
                    secondStorage.setMinAmountProjectTokens(pid, nwmntkn, investr);
                    numberOfChanges++;
                }
            }
        }
        if (numberOfChanges == 0) {
            secondStorage.setHighestTokenPrice(pid, newPrice);
        }
        eventLogger.emitNewTokenPrice(pid, newPrice, numberOfChanges);
        return numberOfChanges;
    }

    function isOpen(uint256 projectId) public view returns (bool) {
        return secondStorage.getProjectCurrentState(projectId) == 0;
    }

    function _decreasePercentage(
        uint256 afc,
        uint256 mnp,
        uint256 crp,
        uint256 nfc
    )
        internal
        pure
        returns (uint256 ndp, uint256 rmn)
    {
        uint256 pfc = nfc;
        if (afc < 88 * 1 ether) {
            if (pfc >= 2 ether) {
                rmn = pfc.mod(2 ether);
                pfc = pfc.sub(rmn);
                ndp = crp.sub(pfc.div(2 ether));
                if (ndp > mnp) {
                    return (ndp, rmn);
                } else {
                    return (mnp, 1);
                }
            } else {
                return (crp, 1);
            }
        }

        if (afc >= 88 * 1 ether && afc < 288 ether) {
            if (pfc >= 5 ether) {
                rmn = pfc.mod(5 ether);
                pfc = pfc.sub(rmn);
                ndp = crp.sub(pfc.div(5 ether));
                if (ndp > mnp) {
                    return (ndp, rmn);
                } else {
                    return (mnp, 1);
                }
            } else {
                return (crp, 1);
            }
        }

        if (afc >= 288 ether) {
            if (pfc >= 10 ether) {
                rmn = pfc.mod(10 ether);
                pfc = pfc.sub(rmn);
                ndp = crp.sub(pfc.div(10 ether));
                if (ndp >= mnp) {
                    return (ndp, rmn);
                } else {
                    return (mnp, 1);
                }
            } else {
                return (crp, 1);
            }
        }
    }

    function _increasePercentage(
        uint256 afc,
        uint256 mxp,
        uint256 crp,
        uint256 nfc
    )
        internal
        pure
        returns (uint256 nip, uint256 rmn)
    {
        uint256 ofc = nfc;
        if (afc < 88 ether) {
            rmn = ofc.mod(3 ether);
            ofc = ofc.sub(rmn);
            nip = crp.add(ofc.div(3 ether));
            if (nip <= mxp) {
                return (nip, rmn);
            } else {
                return (mxp, ((nip.sub(mxp)) * 3).add(rmn));
            }
        }

        if (afc >= 88 ether && afc < 288 ether) {
            rmn = ofc.mod(7 ether);
            ofc = ofc.sub(rmn);
            nip = crp.add(ofc.div(7 ether));
            if (nip <= mxp) {
                return (nip, rmn);
            } else {
                return (mxp, ((nip.sub(mxp)) * 7).add(rmn));
            }
        }

        if (afc >= 288 ether) {
            rmn = ofc.mod(12 ether);
            ofc = ofc.sub(rmn);
            nip = crp.add(ofc.div(12 ether));
            if (nip <= mxp) {
                return (nip, rmn);
            } else {
                return (mxp, ((nip.sub(mxp)) * 12).add(rmn));
            }
        }
    }

    function _mintRefundEther(
        address investorAddress,
        uint256 projectId,
        uint256 rethAmount
    )
        internal
    {
        refundEther = RefundEther(masterStorage.getRefundEtherTokenAddress());
        refundEther.mint(investorAddress, rethAmount);
        refundEther.setAmountOfSecuredEther(investorAddress, projectId, rethAmount);
    }

    function _createTokenLitter(
        address investor,
        uint256 projectId,
        uint256 investmentId
    )
        internal
        pure
        returns (address)
    {
        bytes20 ntl = bytes20(keccak256(abi.encodePacked(investor, projectId, investmentId)));
        return address(ntl);
    }

    function _calcPoolContribution(
        bool isInvestorReferred,
        address referrer,
        uint amountContributed
    )
        internal
        returns (uint256 poolContribution)
    {
        uint256 platformResources;

        if (isInvestorReferred) {
            uint256 referralPayment = _calcAffiliatePayment(amountContributed);
            affiliate.deposit.value(referralPayment)(referrer);
            platformResources = amountContributed.div(10);
            poolContribution = amountContributed.sub(platformResources.add(referralPayment));
            address(modResources).transfer(platformResources);
        }
        else {
            platformResources = amountContributed.mul(30).div(100);
            poolContribution = amountContributed.sub(platformResources);
            address(modResources).transfer(platformResources);
        }
        return poolContribution;
    }

    function _calcOwnerContribution(
        uint256 owncntrbmn,
        uint256 tfndscntrb
    )   internal
        returns (uint256 nowncntrbm)
    {
        uint256 pltfmrsrcs;
        if (tfndscntrb < 88 ether) {
            pltfmrsrcs = owncntrbmn.sub((100 * owncntrbmn) / 150);
            nowncntrbm = owncntrbmn.sub(pltfmrsrcs);
            address(modResources).transfer(pltfmrsrcs);
        }
        if (tfndscntrb >= 88 ether && tfndscntrb < 288 ether) {
            pltfmrsrcs = owncntrbmn.sub((100 * owncntrbmn) / 135);
            nowncntrbm = owncntrbmn.sub(pltfmrsrcs);
            address(modResources).transfer(pltfmrsrcs);
        }
        if (tfndscntrb >= 288 ether) {
            pltfmrsrcs = owncntrbmn.sub((100 * owncntrbmn) / 120);
            nowncntrbm = owncntrbmn.sub(pltfmrsrcs);
            address(modResources).transfer(pltfmrsrcs);
        }
        return nowncntrbm;
    }

    function _calcAffiliatePayment(uint amountContributed)
        internal
        pure
        returns (uint256 referralPayment)
    {
        return referralPayment = amountContributed.div(5);
    }

    function _closeProject(uint256 pid) internal {
        require(isOpen(pid), "This project is already closed for new insurance requests");
        secondStorage.setProjectCurrentState(pid, 1);
    }

    function _newInsuranceInit(
        uint256 pid,
        address insOwner,
        address referrer,
        bytes32 cntrllrs
    )
        internal
        returns (uint256 insuranceId)
    {
        require(pid < secondStorage.getNumberOfCoveredProjects(), "Invalid project ID");
        require(
            msg.value >= masterStorage.getMinInvestorContribution() &&
            msg.value <= masterStorage.getMaxInvestorContribution(),
            "The amount you specified as pool contribution is below/above the allowed limits."
        );
        require(
            !secondStorage.getAlreadyProtected(pid, insOwner),
            "Only 1 secured investment per project is allowed"
        );
        if (!masterStorage.isInvestor(insOwner)) {

            masterStorage.setInvestorId(insOwner, masterStorage.addNewInvestor(insOwner) - 1);
            masterStorage.setInvestor(insOwner);

            if (referrer != address(0)) {
                masterStorage.setReferrer(insOwner, referrer);
            }
        }

        insuranceId = masterStorage.addInsurance();
        masterStorage.setControllerStateToInsurance(insuranceId, cntrllrs);
        masterStorage.setInsuranceId(insuranceId);
        masterStorage.setInsuranceProjectId(insuranceId, pid);
        masterStorage.setInsuranceOwner(insuranceId, insOwner);
        masterStorage.setTimeOfTheRequest(insuranceId);
        masterStorage.setInsuranceRate(insuranceId, secondStorage.getProtectionRate(pid));

        return insuranceId;
    }

    function _newInsuranceCalculations(
        uint256 pid,
        uint256 insuranceId,
        address insOwner,
        address referrer
    )
        internal
    {
        uint256 aei;
        uint256 mpt;
        uint256 ethsec;
        uint256 rcp = masterStorage.getRegularContributionPercentage();
        uint256 nse;
        if (referrer == address(0x0)) {
            aei = msg.value.mul(100).div(rcp);
            mpt = aei.div(secondStorage.getHighestTokenPrice(pid)) * 10 ** uint256(secondStorage.getTokenDecimals(pid));
            secondStorage.setMinAmountProjectTokens(pid, mpt, insOwner);
            ethsec = aei.mul(masterStorage.getInsuranceRate(insuranceId)) / 100;
            masterStorage.setEtherSecured(insuranceId, ethsec);
            nse = secondStorage.getTotalAmountSecuredEther(pid).add(ethsec);
            secondStorage.setTotalAmountSecuredEther(pid, nse);
        } else {
            aei = msg.value.mul(100) / (rcp - (rcp.div(10)));
            mpt = aei.div(secondStorage.getHighestTokenPrice(pid)) * 10 ** uint256(secondStorage.getTokenDecimals(pid));
            secondStorage.setMinAmountProjectTokens(pid, mpt, insOwner);
            ethsec = aei.mul(masterStorage.getInsuranceRate(insuranceId)).div(100);
            nse = secondStorage.getTotalAmountSecuredEther(pid).add(ethsec);
            masterStorage.setEtherSecured(insuranceId, ethsec);
            secondStorage.setTotalAmountSecuredEther(pid, nse);
        }
        _mintRefundEther(insOwner, pid, ethsec);
    }

    function _newProtectionRate(
        uint256 pid,
        uint256 naf
    )
        internal
    {
        uint256 ndp;
        uint256 rmn;
        uint256 prt  = secondStorage.getProtectionRate(pid);
        uint256 mpp  = masterStorage.getMinProtectionPercentage();
        uint256 pfc  = secondStorage.getPercentageFloatContainer(pid).add(msg.value);
        if (prt == mpp) {
            secondStorage.setPercentageFloatContainer(pid, 1);
        } else {
            secondStorage.setPercentageFloatContainer(pid, pfc);
            (ndp, rmn) = _decreasePercentage(naf, mpp, prt, pfc);
            secondStorage.setProtectionRate(pid, ndp);
            if (prt != ndp) {
                secondStorage.setPercentageFloatContainer(pid, rmn);
            }
        }
    }

    function _isMain() internal view {
        if (msg.sender != main) {
            revert("Only the main dApp contract is allowed");
        }
    }
}