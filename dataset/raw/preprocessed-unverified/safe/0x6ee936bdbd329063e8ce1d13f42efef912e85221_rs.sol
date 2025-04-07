/**
 *Submitted for verification at Etherscan.io on 2021-04-19
*/

/**
 *Submitted for verification at Etherscan.io on 2020-08-18
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.10;


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



/**
 * @title A simple smart contract which only records everyoneâ€™s voting on each proposal.
 */
contract VoteBox {
    using SafeMath for uint256;

    // Meta data
    struct Meta {
        string link;
        uint256 beginBlock;
        uint256 endBlock;
    }

    // Vote content
    enum Content { INVALID, FOR, AGAINST }

    // Min MCB rate of totalSupply for creating a new proposal
    uint256 public constant MIN_PROPOSAL_RATE = 10**16; // 1% according to https://github.com/mcdexio/documents/blob/master/en/Mai-Protocol-v3.pdf

    // Min voting period in blocks. 1 day for 15s/block
    uint256 public constant MIN_PERIOD = 5760;

    // MCB address
    IERC20 public mcb;

    // All proposal meta data
    Meta[] public proposals;

    /**
     * @dev The new proposal is created
     */
    event Proposal(uint256 indexed id, string link, uint256 beginBlock, uint256 endBlock);

    /**
     * @dev Someone changes his/her vote on the proposal
     */
    event Vote(address indexed voter, uint256 indexed id, Content voteContent);

    /**
     * @dev    Constructor
     * @param  mcbAddress MCB address
     */
    constructor(address mcbAddress)
        public
    {
        mcb = IERC20(mcbAddress);
    }

    /**
     * @dev    Accessor to the total number of proposal
     */
    function totalProposals()
        external view returns (uint256)
    {
        return proposals.length;
    }

    /**
     * @dev    Create a new proposal, need a proposal privilege
     * @param  link       The forum link of the proposal
     * @param  beginBlock Voting is enabled between [begin block, end block]
     * @param  endBlock   Voting is enabled between [begin block, end block]
     */
    function propose(string calldata link, uint256 beginBlock, uint256 endBlock)
        external
    {
        uint256 minProposalMCB = mcb.totalSupply().mul(MIN_PROPOSAL_RATE).div(10**18);
        require(mcb.balanceOf(msg.sender) >= minProposalMCB, "proposal privilege required");
        require(bytes(link).length > 0, "empty link");
        require(block.number <= beginBlock, "old proposal");
        require(beginBlock.add(MIN_PERIOD) <= endBlock, "period is too short");
        proposals.push(Meta({
            link: link,
            beginBlock: beginBlock,
            endBlock: endBlock
        }));
        emit Proposal(proposals.length - 1, link, beginBlock, endBlock);
    }

    /**
     * @notice  Vote for/against the proposal with id
     * @param   id          Proposal id
     * @param   voteContent Vote content
     */
    function vote(uint256 id, Content voteContent)
        external
    {
        require(id < proposals.length, "invalid id");
        require(voteContent != Content.INVALID, "invalid content");
        require(proposals[id].beginBlock <= block.number, "< begin");
        require(block.number <= proposals[id].endBlock, "> end");
        emit Vote(msg.sender, id, voteContent);
    }
}