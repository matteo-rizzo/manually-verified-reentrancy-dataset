/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;






contract Resolver {
    struct ProposalState {
        uint forVotes;
        uint againstVotes;
        bool isFailed;
        bool isEnded;
        GoveranceInterface.ProposalState currentState;
    }

    struct GovernanceData {
        uint quorumVotes;
        uint proposalThreshold;
        uint votingDelay;
        uint votingPeriod;
        uint proposalMaxOperations;
        uint proposalCount;
        string name;
    }

    struct TokenData {
        // uint mintingAllowedAfter;
        // uint minimumTimeBetweenMints;
        // uint mintCap;
        uint totalSupply;
        string symbol;
        string name;
    }

    function getProposalStates(address govAddr, uint256[] memory ids) public view returns (ProposalState[] memory) {
        ProposalState[] memory proposalStates = new ProposalState[](ids.length);
        GoveranceInterface govContract = GoveranceInterface(govAddr);
        for (uint i = 0; i < ids.length; i++) {
            uint id = ids[i];
            GoveranceInterface.Proposal memory proposal = govContract.proposals(id);
            bool isEnded = proposal.endBlock <= block.number;
            bool isFailed = proposal.forVotes <= proposal.againstVotes || proposal.forVotes < govContract.quorumVotes();
            proposalStates[i] = ProposalState({
                forVotes: proposal.forVotes,
                againstVotes: proposal.againstVotes,
                isFailed: isEnded && isFailed,
                isEnded: isEnded,
                currentState: govContract.state(id)
            });
        }
        return proposalStates;
    }

    function getGovernanceData(address[] memory govAddress) public view returns (GovernanceData[] memory) {
        GovernanceData[] memory governanceDatas = new GovernanceData[](govAddress.length);
        for (uint i = 0; i < govAddress.length; i++) {
            GoveranceInterface govContract = GoveranceInterface(govAddress[i]);
            governanceDatas[i] = GovernanceData({
                quorumVotes: govContract.quorumVotes(),
                proposalThreshold: govContract.proposalThreshold(),
                votingDelay: govContract.votingDelay(),
                votingPeriod: govContract.votingPeriod(),
                proposalMaxOperations: govContract.proposalMaxOperations(),
                proposalCount: govContract.proposalCount(),
                name: govContract.name()
            });
        }
        return governanceDatas;
    }

    function getTokenData(address[] memory tokens) public view returns (TokenData[] memory) {
        TokenData[] memory tokenDatas = new TokenData[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            TokenInterface tokenContract = TokenInterface(tokens[i]);
            tokenDatas[i] = TokenData({
                // mintingAllowedAfter: tokenContract.mintingAllowedAfter(),
                // minimumTimeBetweenMints: tokenContract.minimumTimeBetweenMints(),
                // mintCap: tokenContract.mintCap(),
                totalSupply: tokenContract.totalSupply(),
                symbol: tokenContract.symbol(),
                name: tokenContract.name()
            });
        }
        return tokenDatas;
    }

    function getDaoData(address[] memory govAddress, address[] memory tokens) public view returns (GovernanceData[] memory, TokenData[] memory) {
        return (getGovernanceData(govAddress), getTokenData(tokens));
    }
}

contract AtlasGovResolver is Resolver {

    string public constant name = "Atlas-Governance-Resolver-v1.1";
    
}