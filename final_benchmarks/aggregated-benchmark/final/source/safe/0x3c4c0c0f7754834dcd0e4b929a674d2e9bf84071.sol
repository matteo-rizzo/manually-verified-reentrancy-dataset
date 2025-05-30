interface ISynthetix {
    function burnSynthsToTargetOnBehalf(address burnForAddress) external;
    function issueMaxSynthsOnBehalf(address issueForAddress) external;
    function remainingIssuableSynths(address issuer) external returns (uint256);
}

interface IFeePool {
    function claimOnBehalf(address claimingForAddress) external;
    function isFeesClaimable(address account) external returns (bool);
}

contract SNXClaimerZap {
    address synthetixProxy = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
    address feePoolProxy = 0xb440DD674e1243644791a4AdfE3A2AbB0A92d309;

    ISynthetix synthetix = ISynthetix(synthetixProxy);
    IFeePool feePool = IFeePool(feePoolProxy);

    function burnClaimMintSNX(address delegator) public returns (uint256) {

        if (!feePool.isFeesClaimable(delegator)) {
            synthetix.burnSynthsToTargetOnBehalf(delegator);
        }

        feePool.claimOnBehalf(delegator);

        if (synthetix.remainingIssuableSynths(delegator) > 0) {
            synthetix.issueMaxSynthsOnBehalf(delegator);
        }

        emit SNXClaimerZappedForAccount(delegator);
    }

    event SNXClaimerZappedForAccount(address delegator);
}
