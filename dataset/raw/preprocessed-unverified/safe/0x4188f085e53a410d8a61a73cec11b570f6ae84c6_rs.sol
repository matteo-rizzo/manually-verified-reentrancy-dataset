/**
 *Submitted for verification at Etherscan.io on 2021-06-29
*/

pragma solidity ^0.8.0;




/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor ()  {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


contract LoveVote is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public proposalValue = 500000 * 10 ** 18;

    IERC20 votorToken;

    mapping(address => bool) public directors;

    struct Votor {
        address account;
        uint256 voteCountTotal;
    }

    mapping(address => Votor) public votorMap;
    mapping(address => mapping(uint256 => uint256[5])) public userForProposalOptionAndCounts;

    //Proposer
    struct chairperson {
        address account;
        uint256 lastProposalBlockNumber;
    }

    mapping(address => chairperson) public chairpersonMap;

    struct Proposal {
        bool IsMajorProposal;
        address Chairperson;
        bytes32 Name;
        uint256 OptionsTotalCounts;
        bool IsEffective;
        bool IsVotingEnd;
        uint256 StartTime;
        uint256 EndTime;
        uint8 WinOption;
    }

    mapping(uint256 => mapping(uint8 => bytes32)) public ProposalOptions;

    Proposal[] public Proposals;

    mapping(uint256 => mapping(uint8 => uint256)) public ProposalsOptionsCounts;
    mapping(uint256 => mapping(address => uint256[5])) public votorOptionAndCounts;

    modifier validateByPid(uint256 _pid) {
        require(_pid < Proposals.length, "The proposal does not exist!");
        _;
    }

    event VoteEvent(address user, uint256 _pid, uint8 Option, uint256 _votes);
    event GetVotor(address user, uint256 _pid, uint8 Option, uint256 account);
    event ProposalEvent(address chairpersonUser, bytes32 _name, bytes32 _AOptions, bytes32 _BOptions, bytes32 _COptions,
        bytes32 _DOptions, bytes32 _FOptions, bool _isMajorProposal);
        
    event ProposalStop(uint256 _pid,address msgsender);
    event ProposaleCalculation(uint256 _pid, bool isMandatorySettlement,address msgsender);

    constructor(IERC20 _votorToken){
        require(address(_votorToken) !=address(0),"_votorToken is zero value! ");
        directors[msg.sender] = true;
        votorToken = _votorToken;
    }

    function addDirector(address _director) external onlyOwner {
        directors[_director] = true;
    }

    function delDirector(address _director) external onlyOwner {
        directors[_director] = false;
    }

    function setProposalValue(uint256 number) external {
        require(directors[msg.sender], "Permission denied!");
        proposalValue = number;
    }

    function getProposalLen() external view returns (uint256){
        return Proposals.length;
    }

    function vote(uint256 _pid, uint8 _options, uint256 _votes) external validateByPid(_pid) {
        require(_options < 5, "The option does not exist!");
        require(_votes >= 1 * 10 ** 18, "At least one vote at a time!");
        Proposal storage thisProposal = Proposals[_pid];
        require(thisProposal.IsEffective, "The proposal is invalid!");
        require(!thisProposal.IsVotingEnd, "The proposal is over!");
        require(thisProposal.EndTime >= block.timestamp, "The proposal is over!");
        thisProposal.OptionsTotalCounts = thisProposal.OptionsTotalCounts.add(_votes);
        ProposalsOptionsCounts[_pid][_options] = ProposalsOptionsCounts[_pid][_options].add(_votes);
        votorToken.safeTransferFrom(msg.sender, address(this), _votes);
        Votor storage user = votorMap[msg.sender];
        user.account = msg.sender;
        user.voteCountTotal = user.voteCountTotal.add(_votes);
        votorOptionAndCounts[_pid][msg.sender][_options] = votorOptionAndCounts[_pid][msg.sender][_options].add(_votes);
        userForProposalOptionAndCounts[msg.sender][_pid][_options] = userForProposalOptionAndCounts[msg.sender][_pid][_options].add(_votes);
        emit VoteEvent(msg.sender, _pid, _options, _votes);
    }

    function getVoted(uint256 _pid) external validateByPid(_pid) {
        Proposal storage thisProposal = Proposals[_pid];
        Votor storage user = votorMap[msg.sender];
        require(!thisProposal.IsEffective || thisProposal.IsVotingEnd, "It can't be redeemed yet!");
        for (uint8 i = 0; i < 5; i++) {
            if (userForProposalOptionAndCounts[msg.sender][_pid][i] > 0) {
                votorToken.safeTransfer(msg.sender, userForProposalOptionAndCounts[msg.sender][_pid][i]);
                user.voteCountTotal = user.voteCountTotal.sub(userForProposalOptionAndCounts[msg.sender][_pid][i]);
                userForProposalOptionAndCounts[msg.sender][_pid][i] = 0;
                emit GetVotor(msg.sender, _pid, i, userForProposalOptionAndCounts[msg.sender][_pid][i]);
            }
        }
    }

    function proposal(bytes32 _name, bytes32 _AOptions, bytes32 _BOptions, bytes32 _COptions, bytes32 _DOptions,
        bytes32 _FOptions, bool _isMajorProposal, uint256 _endDay) external returns (bool){
        require(votorToken.balanceOf(msg.sender) > proposalValue, "Insufficient balance!");
        require(block.number.sub(chairpersonMap[msg.sender].lastProposalBlockNumber) > 129600, "Permission denied");

        uint256 _endTime = block.timestamp + _endDay.mul(86400);
        if (block.number.sub(chairpersonMap[msg.sender].lastProposalBlockNumber) > 129600) {
            Proposals.push(Proposal({
            IsMajorProposal : _isMajorProposal,
            Chairperson : msg.sender,
            Name : _name,
            OptionsTotalCounts : 0,
            StartTime : block.timestamp,
            EndTime : _endTime,
            IsEffective : true,
            IsVotingEnd : false,
            WinOption : 6
            }));
            ProposalOptions[Proposals.length - 1][0] = _AOptions;
            ProposalOptions[Proposals.length - 1][1] = _BOptions;
            ProposalOptions[Proposals.length - 1][2] = _COptions;
            ProposalOptions[Proposals.length - 1][3] = _DOptions;
            ProposalOptions[Proposals.length - 1][4] = _FOptions;
            chairpersonMap[msg.sender] = chairperson({
            account : msg.sender,
            lastProposalBlockNumber : block.number
            });

            emit ProposalEvent(msg.sender, _name, _AOptions, _BOptions, _COptions, _DOptions, _FOptions, _isMajorProposal);
            return true;
        } else {
            return false;
        }

    }

    function IsProposalEnd(uint256 endblock) external view returns (bool isEnd){
        if (endblock <= block.number) {
            return true;
        }
    }

    function proposalStop(uint256 _pid) external validateByPid(_pid) {
        Proposal storage thisProposal = Proposals[_pid];
        require(thisProposal.Chairperson == msg.sender || directors[msg.sender], "Permission denied!");
        thisProposal.IsEffective = false;
        emit ProposalStop(_pid,msg.sender);
    }

    function proposaleCalculation(uint256 _pid, bool isMandatorySettlement) external validateByPid(_pid) {
        Proposal storage thisProposal = Proposals[_pid];
        require(thisProposal.IsEffective, "The proposal is invalid!");
        require(!thisProposal.IsVotingEnd, "The proposal is over!");
        if (!isMandatorySettlement) {
            require(thisProposal.EndTime < block.timestamp, "Voting time is not yet up!");
        }
        require(thisProposal.Chairperson == msg.sender || directors[msg.sender], "Permission denied!");

        if (thisProposal.IsMajorProposal) {
            uint256 winerVotes = thisProposal.OptionsTotalCounts.div(2);
            for (uint8 i = 0; i < 5; i++) {
                if (ProposalsOptionsCounts[_pid][i] > winerVotes) {
                    thisProposal.WinOption = i;
                }
            }
        } else {
            uint256 winerVotes = ProposalsOptionsCounts[_pid][0];
            for (uint8 i = 1; i < 5; i++) {
                if (ProposalsOptionsCounts[_pid][i] > winerVotes) {
                    winerVotes = ProposalsOptionsCounts[_pid][i];
                    thisProposal.WinOption = i;
                }
            }
        }
        thisProposal.EndTime = block.timestamp;
        thisProposal.IsVotingEnd = true;
        emit ProposaleCalculation(_pid,isMandatorySettlement,msg.sender);
    }

}