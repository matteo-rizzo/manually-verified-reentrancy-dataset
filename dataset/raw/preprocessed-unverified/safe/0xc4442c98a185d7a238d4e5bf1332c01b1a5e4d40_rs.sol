/**
 *Submitted for verification at Etherscan.io on 2019-06-28
*/

pragma solidity ^0.5.7;


















contract DisputeController {
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
            revert("Only main contract is allowed");
        }
    }

    function createNewDispute (
        address payable caller,
        uint256 pid,
        bytes calldata publicDisputeUrl
    )
        external
        payable
        onlyMain
        returns (bool)
    {
        uint256 did;
        require(secondStorage.getProjectCurrentState(pid) == 1, "Vote not allowed in the current project state");
        bool isInv = masterStorage.isInvestor(caller);
        bool isMod = masterStorage.isPlatformModerator(caller) || masterStorage.isCommunityModerator(caller);
        bool isOwn = masterStorage.isProjectOwner(caller);
        bool isRefundInProgress = secondStorage.getIsRefundInProgress(pid);
        if (!isInv && !isMod && !isOwn) revert("Only investors, supporters and moderators can invoke a dispute");
        if (isInv && isOwn) revert("Not allowed for accounts that are both investors and supporters to a project");

        uint256 cuf = secondStorage.getOwnerFunds(pid, caller);
        if (isOwn && !isMod && cuf > 1) {
            require(isRefundInProgress, "Not allowed - not in a refund state");
            uint256 opc = secondStorage.getOwnerContribution(pid).add(msg.value);
            uint256 poolContributions = secondStorage.getAmountOfFundsContributed(pid);

            if (opc < poolContributions.mul(5).div(100)) {
                revert("The owner funds + the ether sent with this call is less than the dispute lottery prize");
            } else {
                did = _addDispute(caller, pid, publicDisputeUrl, isRefundInProgress);
                secondStorage.setOwnerContribution(pid, opc);
                secondStorage.setOwnerFunds(pid, caller, cuf.add(msg.value));
                if (msg.value > 0) refundPool.deposit.value(msg.value)(pid);
            }
            return true;
        }
        if (isMod) {
            require(isRefundInProgress, "The project is not in a refund state set by an internal vote");
            did = _addDispute(caller, pid, publicDisputeUrl, isRefundInProgress);
            return true;
        }
        if (isInv && !isMod && !isOwn && !secondStorage.getIsDisputed(pid)) {
            require(
                secondStorage.getAlreadyProtected(pid, caller) &&
                secondStorage.getIsInvestorsVoteFailed(pid), "Not allowed"
            );
            require(msg.value >= 1 ether, "Not enough collateral amount");
            did = _addDispute(caller, pid, publicDisputeUrl, isRefundInProgress);
            masterStorage.setPayment(caller, did, msg.value);
            refundPool.deposit.value(msg.value)(pid);
            return true;
        }
        return false;
    }

    function addPublicVote(address payable voter, uint256 did, bytes32 hiddenVote)
        external
        payable
        onlyMain
        returns (bool)
    {
        uint256 votingPeriod = masterStorage.getDisputeVotePeriod(did);
        uint256 pid = masterStorage.getDisputeProjectId(did);
        if (masterStorage.isProjectOwner(voter) ||
            masterStorage.isPlatformModerator(voter) ||
            secondStorage.getAlreadyProtected(pid, voter)) {
            revert("Not allowed");
        }

        if (secondStorage.getProjectCurrentState(pid) != 3 ||
            votingPeriod < block.number ||
            masterStorage.getHiddenVote(did, voter) != bytes32(0)) {
            revert ("Not allowed");
        }

        uint256 validationGasCost;
        address payable modResources = masterStorage.getModerationResources();

        if (masterStorage.getValidationToken(voter) == 0) {
            validationGasCost = 1100000000000000;
            require(msg.value >= masterStorage.getEntryFee(did).add(validationGasCost), "Insufficient voting collateral amount");
            modResources.transfer(validationGasCost);
        } else {
            require(msg.value >= masterStorage.getEntryFee(did), "Insufficient voting collateral amount");
        }

        bytes32 encryptedVote = keccak256(abi.encodePacked(did, voter, hiddenVote));
        masterStorage.addHiddenVote(did, voter, encryptedVote);
        masterStorage.setPayment(voter, did, msg.value.sub(validationGasCost));
        refundPool.deposit.value(msg.value.sub(validationGasCost))(pid);
    }

    function decryptVote(address voter, uint256 did, bool isProjectFailed, uint64 pin)
        external
        onlyMain
        returns (bool)
    {
        uint256 pid = masterStorage.getDisputeProjectId(did);
        uint256 revealPeriod = masterStorage.getResultCountPeriod(did);
        require(secondStorage.getProjectCurrentState(pid) == 3, "Not in a dispute");
        require(block.number > masterStorage.getDisputeVotePeriod(did), "Voting period is not over");
        require(masterStorage.getValidationToken(voter) != 0, "Your account is not verified");

        if (revealPeriod < block.number) {
            finalizeDispute(did);
            return false;
        }

        bytes32 voteHash = keccak256(abi.encodePacked(pin, isProjectFailed));
        bytes32 encryptedVote = keccak256(abi.encodePacked(did, voter, voteHash));

        if (masterStorage.getHiddenVote(did, voter) != encryptedVote) {
            revert("Revealed vote doesn't match with the encrypted one");
        } else {
            uint256 rpb = uint64(address(refundPool).balance);
            if (isProjectFailed) {
                masterStorage.setNumberOfVotesForRefundState(did);
            } else {
                masterStorage.setNumberOfVotesAgainstRefundState(did);
            }
            if (masterStorage.getRandomNumberBaseLength(did) < 112) {
                masterStorage.addToRandomNumberBase(did, pin ^ rpb);
            }
            masterStorage.addRevealedVote(did, voter, isProjectFailed);
            masterStorage.addDisputeVoter(did, voter);
            return true;
        }
    }

    function finalizeDispute(uint256 did) public onlyMain returns (bool) {
        uint256 pid = masterStorage.getDisputeProjectId(did);
        require(secondStorage.getProjectCurrentState(pid) == 3, "Not in a dispute");
        require(block.number > masterStorage.getResultCountPeriod(did), "Vote counting is not finished");
        uint256 nov = masterStorage.getDisputeNumberOfVoters(did);

        if (!_extendDispute(did, pid, nov)) return false;
        uint256 votesAgainstFailure = masterStorage.getNumberOfVotesAgainstRefundState(did);
        uint256 votesForFailure = masterStorage.getNumberOfVotesForRefundState(did);
        bool forcedRefundState = (secondStorage.isRefundStateForced(pid) == 1);
        if (votesAgainstFailure >= votesForFailure ) {
            if (secondStorage.getIsRefundInProgress(pid) && secondStorage.getIsInvestorsVoteFailed(pid) && !forcedRefundState) {
                secondStorage.setProjectCurrentState(pid, 5);
                secondStorage.setRefundStatePeriod(pid, block.number);
            }
            if (secondStorage.getIsInvestorsVoteFailed(pid) && !secondStorage.getIsRefundInProgress(pid)) {
                secondStorage.setFreezeStatePeriod(pid, 1);
                secondStorage.setProjectCurrentState(pid, 1);
                secondStorage.setIsDisputed(pid);
            }
            if (secondStorage.getIsRefundInProgress(pid) && forcedRefundState) {
                secondStorage.setRefundStatePeriod(pid, block.number);
                secondStorage.setProjectCurrentState(pid, 1);
            }
            if (!secondStorage.getIsInvestorsVoteFailed(pid) && !forcedRefundState) {
                secondStorage.setIsInvestorsVoteFailed(pid, true);
                secondStorage.setReturnedRefundTokens(pid, 1);
                secondStorage.setVotesForRefundState(pid, 1);
            }
            if (secondStorage.getIsRefundInProgress(pid)) {
                secondStorage.setIsRefundInProgress(pid, false);
            }
            if (forcedRefundState) {
                secondStorage.setForcedRefundState(pid, 2);
            }
            eventLogger.emitDisputeFinished(did, pid, votesAgainstFailure, votesForFailure, _pickPrizeWinner(did, false, nov));
            return true;
        } else {
            if (!secondStorage.getIsRefundInProgress(pid) &&
                secondStorage.getIsInvestorsVoteFailed(pid) && !forcedRefundState) {
                secondStorage.setIsInvestorsVoteFailed(pid, false);
            }
            if (!secondStorage.getIsRefundInProgress(pid)) {
                secondStorage.setIsRefundInProgress(pid, true);
                secondStorage.setRefundStatePeriod(pid, block.number.add(233894));
            }

            secondStorage.setFreezeStatePeriod(pid, 1);
            secondStorage.setIsDisputed(pid);
            secondStorage.setProjectCurrentState(pid, 1);
            eventLogger.emitDisputeFinished(did, pid, votesAgainstFailure, votesForFailure, _pickPrizeWinner(did, true, nov));
            return true;
        }
    }

    function _pickPrizeWinner(
        uint256 did,
        bool disputeConsensus,
        uint256 numberOfVoters
    )
        internal
        returns (address payable)
    {
        uint256 nov = numberOfVoters;
        uint256 ewi = masterStorage.randomNumberGenerator(did).mod(nov);
        address payable ewa = masterStorage.getDisputeVoter(did, ewi);

        if (masterStorage.getRevealedVote(did, ewa) == disputeConsensus) {
            _setPrizeAmount(did, ewa);
        }

        if (masterStorage.getRevealedVote(did, ewa) == !disputeConsensus) {
            if (nov > ewi.add(1)) {
                ewi++;
                ewa = masterStorage.getDisputeVoter(did, ewi);
                while (masterStorage.getRevealedVote(did, ewa) == !disputeConsensus && ewi.add(1) < nov) {
                    ewi++;
                    ewa = masterStorage.getDisputeVoter(did, ewi);
                }
                if (masterStorage.getRevealedVote(did, ewa) == !disputeConsensus) {
                    ewi = 0;

                    while (masterStorage.getRevealedVote(did, ewa) == !disputeConsensus && ewi.add(1) < nov) {
                        ewi++;
                        ewa = masterStorage.getDisputeVoter(did, ewi);
                    }
                    _setPrizeAmount(did, ewa);
                } else {
                    _setPrizeAmount(did, ewa);
                }
            } else {
                ewi = 0;
                while (masterStorage.getRevealedVote(did, ewa) == !disputeConsensus && ewi.add(1) < nov) {
                    ewi++;
                    ewa = masterStorage.getDisputeVoter(did, ewi);
                }
                _setPrizeAmount(did, ewa);
            }
        }
        return ewa;
    }

    function _addDispute(
        address payable caller,
        uint256 pid,
        bytes memory publicDisputeUrl,
        bool isRefundInProgress
    )
        internal
        returns (uint256 did)
    {
        uint256 fsp = secondStorage.getFreezeStatePeriod(pid);
        require (block.number < fsp, "Not allowed, not in a freezetime");

        did = masterStorage.addDispute();
        masterStorage.setDisputeControllerOfProject(did, secondStorage.getDisputeControllerOfProject(pid));
        masterStorage.addDisputeIds(did, pid);
        masterStorage.setDisputeVotePeriod(did, block.number.add(70169));
        masterStorage.setResultCountPeriod(did, block.number.add(98888));
        masterStorage.setPublicDisputeURL(did, publicDisputeUrl);

        masterStorage.setNumberOfVotesForRefundState(did);
        masterStorage.setNumberOfVotesAgainstRefundState(did);

        uint256 poolContributions = secondStorage.getAmountOfFundsContributed(pid);
        uint256 disputePrize = poolContributions.mul(5).div(100);
        masterStorage.setDisputeLotteryPrize(did, disputePrize);
        masterStorage.setEntryFee(did, 24 finney);

        secondStorage.setFreezeStatePeriod(pid, fsp.add(98888));
        secondStorage.setProjectCurrentState(pid, 3);
        masterStorage.setDisputeCreator(did, caller);

        if (isRefundInProgress) {
            uint256 rsp = secondStorage.getRefundStatePeriod(pid);
            secondStorage.setRefundStatePeriod(pid,rsp.add(98888));
        }
        eventLogger.emitNewDispute(caller, did, pid, publicDisputeUrl);
        return did;
    }

    function _setPrizeAmount(uint256 did, address payable prizeWinner) internal {
        uint256 amount = masterStorage.getDisputeLotteryPrize(did);
        masterStorage.setDisputeLotteryPrize(did, 0);
        require(amount > 1, "Not allowed");
        masterStorage.setPayment(prizeWinner, did, masterStorage.getPayment(prizeWinner, did).add(amount));
    }

    function _extendDispute(uint256 did, uint256 pid, uint256 numberOfVotes) internal returns (bool) {
        if (numberOfVotes < 112) {
            _setExtendedTimers(did, pid);
            return false;
        }
        return true;
    }

    function _setExtendedTimers(uint256 did, uint256 pid) internal {
        if (secondStorage.getPolicyEndDate(pid) > block.number) {
            if (secondStorage.getIsRefundInProgress(pid)) {
                secondStorage.setRefundStatePeriod(pid, secondStorage.getRefundStatePeriod(pid).add(98888));
            }
            secondStorage.setFreezeStatePeriod(pid, secondStorage.getFreezeStatePeriod(pid).add(98888));
            masterStorage.setDisputeVotePeriod(did, block.number.add(70169));
            masterStorage.setResultCountPeriod(did, block.number.add(98888));
        } else {
            secondStorage.setProjectCurrentState(pid, 6);
        }
    }
}