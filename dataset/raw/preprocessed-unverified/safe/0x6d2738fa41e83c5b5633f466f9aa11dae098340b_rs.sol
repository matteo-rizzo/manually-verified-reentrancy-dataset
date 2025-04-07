pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;








contract INXMMaster {
    address public tokenAddress;
    address public owner;
    uint public pauseTime;
    function masterInitialized() external view returns(bool);
    function isPause() external view returns(bool check);
    function isMember(address _add) external view returns(bool);
    function getLatestAddress(bytes2 _contractName) external view returns(address payable contractAddress);
}







contract TokenData {
    function lockTokenTimeAfterCoverExp() external returns (uint);
}



contract ClaimsData {
    function actualClaimLength() external view returns(uint);
}







contract yInsureView  {
    
    event ClaimRedeemed (
        address receiver,
        uint value,
        bytes4 currency
    );
    
    using SafeMath for uint;

    INXMMaster constant public nxMaster = INXMMaster(0x01BFd82675DBCc7762C84019cA518e701C0cD07e);
    yInsure constant public yIns = yInsure(0x181Aea6936B407514ebFC0754A37704eB8d98F91);
    
    enum CoverStatus {
        Active,
        ClaimAccepted,
        ClaimDenied,
        CoverExpired,
        ClaimSubmitted,
        Requested
    }
    
    enum ClaimStatus {
        PendingClaimAssessorVote, // 0
        PendingClaimAssessorVoteDenied, // 1
        PendingClaimAssessorVoteThresholdNotReachedAccept, // 2
        PendingClaimAssessorVoteThresholdNotReachedDeny, // 3
        PendingClaimAssessorConsensusNotReachedAccept, // 4
        PendingClaimAssessorConsensusNotReachedDeny, // 5
        FinalClaimAssessorVoteDenied, // 6
        FinalClaimAssessorVoteAccepted, // 7
        FinalClaimAssessorVoteDeniedMVAccepted, // 8
        FinalClaimAssessorVoteDeniedMVDenied, // 9
        FinalClaimAssessorVotAcceptedMVNoDecision, // 10
        FinalClaimAssessorVoteDeniedMVNoDecision, // 11
        ClaimAcceptedPayoutPending, // 12
        ClaimAcceptedNoPayout, // 13
        ClaimAcceptedPayoutDone // 14
    }
    
    function getMemberRoles() external view returns (address) {
        return nxMaster.getLatestAddress("MR");
    }
    
    function getCover(
        uint coverId
    ) public view returns (
        uint cid,
        uint8 status,
        uint sumAssured,
        uint16 coverPeriod,
        uint validUntil
    ) {
        QuotationData quotationData = QuotationData(nxMaster.getLatestAddress("QD"));
        return quotationData.getCoverDetailsByCoverID2(coverId);
    }
    
    function getscAddressOfCover(
        uint _coverId
    ) public view returns (
        uint coverId,
        address coverAddress
    ) {
        QuotationData quotationData = QuotationData(nxMaster.getLatestAddress("QD"));
        return quotationData.getscAddressOfCover(_coverId);
    }
    
    function getCurrencyAssetAddress(bytes4 currency) external view returns (address) {
        PoolData pd = PoolData(nxMaster.getLatestAddress("PD"));
        return pd.getCurrencyAssetAddress(currency);
    }
    
    function getLockTokenTimeAfterCoverExpiry() external returns (uint) {
        TokenData tokenData = TokenData(nxMaster.getLatestAddress("TD"));
        return tokenData.lockTokenTimeAfterCoverExp();
    }
    
    function getTokenAddress() external view returns (address) {
        return nxMaster.tokenAddress();
    }
    
    function payoutIsCompleted(uint claimId) public view returns (bool) {
        uint256 status;
        Claims claims = Claims(nxMaster.getLatestAddress("CL"));
        (, status, , , ) = claims.getClaimbyIndex(claimId);
        return status == uint(ClaimStatus.FinalClaimAssessorVoteAccepted)
            || status == uint(ClaimStatus.ClaimAcceptedPayoutDone);
    }
    
    uint public distributorFeePercentage;
    uint256 internal issuedTokensCount;
    
    struct Token {
        address coverContract;
        uint expirationTimestamp;
        bytes4 coverCurrency;
        uint coverAmount;
        uint expireTime;
        uint generationTime;
        uint coverId;
        bool claimInProgress;
        uint claimId;
        uint8 coverStatus;
        bool payoutCompleted;
    }
    
    function getToken(uint tokenId) public view returns (Token memory) {
        Token memory tkn;
        (
            tkn.expirationTimestamp, 
            tkn.coverCurrency, 
            tkn.coverAmount, 
            , 
            , 
            tkn.expireTime, 
            tkn.generationTime, 
            tkn.coverId, 
            tkn.claimInProgress, 
            tkn.claimId) = yIns.tokens(tokenId);
    }
    
    function tokens(uint tokenId) public view returns (Token memory) {
        Token memory tkn = getToken(tokenId);
        (, tkn.coverContract) = getscAddressOfCover(tkn.coverId);
        (, tkn.coverStatus, , , ) = getCover(tkn.coverId);
        tkn.payoutCompleted = payoutIsCompleted(tkn.claimId);
    }
}