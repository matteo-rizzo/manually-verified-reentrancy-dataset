/**
 *Submitted for verification at Etherscan.io on 2021-03-25
*/

/**
 *Submitted for verification at Etherscan.io on 2020-10-20
*/

pragma solidity >=0.6.2;
pragma experimental ABIEncoderV2;


/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
    constructor () internal {
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    bool private _notEntered;

    constructor() internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
    }

    function ReentrancyGuardInitialize() internal {
        _notEntered = true;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

/**
 * @title VersionedInitializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 *
 * @author Aave, inspired by the OpenZeppelin Initializable contract
 */
abstract contract VersionedInitializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    uint256 private lastInitializedRevision = 0;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        uint256 revision = getRevision();
        require(
            initializing ||
                isConstructor() ||
                revision > lastInitializedRevision,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            lastInitializedRevision = revision;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev returns the revision number of the contract.
    /// Needs to be defined in the inherited class as a constant.
    function getRevision() internal virtual pure returns (uint256);

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        uint256 cs;
        //solium-disable-next-line
        assembly {
            cs := extcodesize(address())
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[16] private ______gap;
}

// /**
//  *Submitted for verification at Etherscan.io on 2020-07-29
// */
// /*
//    ____            __   __        __   _
//   / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
//  _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
// /___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
//      /___/
// * Synthetix: YFIRewards.sol
// *
// * Docs: https://docs.synthetix.io/
// *
// *
// * MIT License
// * ===========
// *
// * Copyright (c) 2020 Synthetix
// *
// * Permission is hereby granted, free of charge, to any person obtaining a copy
// * of this software and associated documentation files (the "Software"), to deal
// * in the Software without restriction, including without limitation the rights
// * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// * copies of the Software, and to permit persons to whom the Software is
// * furnished to do so, subject to the following conditions:
// *
// * The above copyright notice and this permission notice shall be included in all
// * copies or substantial portions of the Software.
// *
// * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// */


contract FortubeGovernance is ReentrancyGuard, VersionedInitializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    event RegisterVoter(address voter, uint256 votes, uint256 totalVotes);
    event RevokeVoter(address voter, uint256 votes, uint256 totalVotes);
    event NewProposal(
        uint256 id,
        address creator,
        uint256 start,
        uint256 duration,
        address executor
    );
    event Vote(
        uint256 indexed id,
        address indexed voter,
        bool vote,
        uint256 weight
    );
    event ProposalFinished(
        uint256 indexed id,
        uint256 _for,
        uint256 _against,
        bool quorumReached
    );
    event Staked(address indexed user, bytes32 select, uint256 amount, uint256 supply);
    event Withdrawn(address indexed user, bytes32 receipt);

    struct Select {
        uint256 duration;
        uint256 exrate; //GFOR生成比率
        uint256 reward; //FOR的周期收益率
        uint256 __RESERVED__0;
        uint256 __RESERVED__1;
        uint256 __RESERVED__2;
    }

    struct Staking {
        address account;
        uint256 amount;
        uint256 start;
        uint256 duration;
        uint256 exrate;
        uint256 reward;
        // uint256 supply;
        uint256 __RESERVED__0;
        uint256 __RESERVED__1;
        uint256 __RESERVED__2;
    }

    struct Proposal {
        uint256 id;
        address proposer;
        mapping(address => uint256) forVotes;
        mapping(address => uint256) againstVotes;
        uint256 totalForVotes;
        uint256 totalAgainstVotes;
        uint256 start; // block start;
        uint256 end; // start + period
        address executor;
        string hash;
        uint256 totalVotesAvailable;
        uint256 quorum;
        uint256 quorumRequired;
        bool open;
    }

    //vote required

    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public votes;
    mapping(address => bool) public voters;
    mapping(address => uint256) public voteLock; // period that your sake it locked to keep it for voting
    uint256 public totalVotes;
    uint256 public proposalCount;

    uint256 public period; // voting period in blocks
    uint256 public lock; // vote lock in block
    uint256 public minimum;
    uint256 public quorum;

    //system required

    bool public breaker = false;

    address public governance;
    address public staketoken;
    address public rewarder; //奖励支付者

    //ERC20 required

    uint8 public decimals;
    string public name;
    string public symbol;

    uint256 private _totalSupply;
    uint256 private _totalStake;

    //stake required

    mapping(bytes32 => Select) private _selects; //锁仓选项
    mapping(address => uint256) private _stakes; //锁仓额度
    mapping(address => uint256) private _balances; //GFOR额度
    mapping(address => bytes32[]) private _receipts; //锁仓记录回执
    mapping(bytes32 => Staking) private _stakings; //锁仓记录

    uint256 private _stakeNonce = 0;

    //initializer required 

    function getRevision() internal override pure returns (uint256) {
        return uint256(0x1);
    }

    function initialize(
        address _governance,
        address _staketoken,
        address _rewarder
    ) public initializer {
        ReentrancyGuard.ReentrancyGuardInitialize();

        governance = _governance;
        staketoken = _staketoken;
        rewarder = _rewarder;

        decimals = 18;
        name = "ForTube Governance Token";
        symbol = "GFOR";
    }

    function totalStake() public view returns (uint256) {
        return _totalStake;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function stakeOf(address account) public view returns (uint256) {
        return _stakes[account];
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function receipts(address account) public view returns (bytes32[] memory) {
        return _receipts[account];
    }

    function staking(bytes32 receipt) public view returns (Staking memory) {
        return _stakings[receipt];
    }

    function getSelect(bytes32 select)
        public
        view
        returns (Select memory)
    {
        return _selects[select];
    }

    /* Fee collection for any other token */

    function seize(address _token, uint256 amount) external {
        require(msg.sender == governance, "!governance");
        require(_token != staketoken, "can not staketoken");
        IERC20(_token).safeTransfer(governance, amount);
    }

    /* Fees breaker, to protect withdraws if anything ever goes wrong */

    function setBreaker(bool _breaker) external {
        require(msg.sender == governance, "!governance");
        breaker = _breaker;
    }

    /* Modifications for proposals */

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setQuorum(uint256 _quorum) public {
        require(msg.sender == governance, "!governance");
        quorum = _quorum;
    }

    function setMinimum(uint256 _minimum) public {
        require(msg.sender == governance, "!governance");
        minimum = _minimum;
    }

    function setPeriod(uint256 _period) public {
        require(msg.sender == governance, "!governance");
        period = _period;
    }

    function setLock(uint256 _lock) public {
        require(msg.sender == governance, "!governance");
        lock = _lock;
    }
    
    function setRewarder(address _rewarder) public {
        require(msg.sender == governance, "!governance");
        rewarder = _rewarder;
    }
    //add stake arguments

    function addSelect(
        bytes32 select,
        uint256 duration,
        uint256 exrate,
        uint256 reward
    ) public {
        require(msg.sender == governance, "!governance");
        _selects[select].duration = duration;
        _selects[select].exrate = exrate;
        _selects[select].reward = reward;
    }

    // governance

    function propose(address executor, string memory hash) public {
        require(votesOf(msg.sender) > minimum, "<minimum");
        proposals[proposalCount++] = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            totalForVotes: 0,
            totalAgainstVotes: 0,
            start: block.number,
            end: period.add(block.number),
            executor: executor,
            hash: hash,
            totalVotesAvailable: totalVotes,
            quorum: 0,
            quorumRequired: quorum,
            open: true
        });

        emit NewProposal(
            proposalCount,
            msg.sender,
            block.number,
            period,
            executor
        );
        voteLock[msg.sender] = lock.add(block.number);
    }

    function execute(uint256 id) public {
        (uint256 _for, uint256 _against, uint256 _quorum) = getStats(id);
        require(proposals[id].quorumRequired < _quorum, "!quorum");
        require(proposals[id].end < block.number, "!end");
        if (proposals[id].open == true) {
            tallyVotes(id);
        }
        Executor(proposals[id].executor).execute(id, _for, _against, _quorum);
    }

    function getStats(uint256 id)
        public
        view
        returns (
            uint256 _for,
            uint256 _against,
            uint256 _quorum
        )
    {
        _for = proposals[id].totalForVotes;
        _against = proposals[id].totalAgainstVotes;

        uint256 _total = _for.add(_against);
        _for = _for.mul(10000).div(_total);
        _against = _against.mul(10000).div(_total);

        _quorum = _total.mul(10000).div(proposals[id].totalVotesAvailable);
    }

    function getVoterStats(uint256 id, address voter)
        public
        view
        returns (uint256, uint256)
    {
        return (
            proposals[id].forVotes[voter],
            proposals[id].againstVotes[voter]
        );
    }

    function tallyVotes(uint256 id) public {
        require(proposals[id].open == true, "!open");
        require(proposals[id].end < block.number, "!end");

        (uint256 _for, uint256 _against, ) = getStats(id);
        bool _quorum = false;
        if (proposals[id].quorum >= proposals[id].quorumRequired) {
            _quorum = true;
        }
        proposals[id].open = false;
        emit ProposalFinished(id, _for, _against, _quorum);
    }

    function votesOf(address voter) public view returns (uint256) {
        return votes[voter];
    }

    function register() public {
        require(voters[msg.sender] == false, "voter");
        voters[msg.sender] = true;
        votes[msg.sender] = balanceOf(msg.sender);
        totalVotes = totalVotes.add(votes[msg.sender]);
        emit RegisterVoter(msg.sender, votes[msg.sender], totalVotes);
    }

    function revoke() public {
        require(voters[msg.sender] == true, "!voter");
        voters[msg.sender] = false;
        if (totalVotes < votes[msg.sender]) {
            //edge case, should be impossible, but this is defi
            totalVotes = 0;
        } else {
            totalVotes = totalVotes.sub(votes[msg.sender]);
        }
        emit RevokeVoter(msg.sender, votes[msg.sender], totalVotes);
        votes[msg.sender] = 0;
    }

    function voteFor(uint256 id) public {
        require(proposals[id].start < block.number, "<start");
        require(proposals[id].end > block.number, ">end");

        uint256 _against = proposals[id].againstVotes[msg.sender];
        if (_against > 0) {
            proposals[id].totalAgainstVotes = proposals[id]
                .totalAgainstVotes
                .sub(_against);
            proposals[id].againstVotes[msg.sender] = 0;
        }

        uint256 vote = votesOf(msg.sender).sub(
            proposals[id].forVotes[msg.sender]
        );
        proposals[id].totalForVotes = proposals[id].totalForVotes.add(vote);
        proposals[id].forVotes[msg.sender] = votesOf(msg.sender);

        proposals[id].totalVotesAvailable = totalVotes;
        uint256 _votes = proposals[id].totalForVotes.add(
            proposals[id].totalAgainstVotes
        );
        proposals[id].quorum = _votes.mul(10000).div(totalVotes);

        voteLock[msg.sender] = lock.add(block.number);

        emit Vote(id, msg.sender, true, vote);
    }

    function voteAgainst(uint256 id) public {
        require(proposals[id].start < block.number, "<start");
        require(proposals[id].end > block.number, ">end");

        uint256 _for = proposals[id].forVotes[msg.sender];
        if (_for > 0) {
            proposals[id].totalForVotes = proposals[id].totalForVotes.sub(_for);
            proposals[id].forVotes[msg.sender] = 0;
        }

        uint256 vote = votesOf(msg.sender).sub(
            proposals[id].againstVotes[msg.sender]
        );
        proposals[id].totalAgainstVotes = proposals[id].totalAgainstVotes.add(
            vote
        );
        proposals[id].againstVotes[msg.sender] = votesOf(msg.sender);

        proposals[id].totalVotesAvailable = totalVotes;
        uint256 _votes = proposals[id].totalForVotes.add(
            proposals[id].totalAgainstVotes
        );
        proposals[id].quorum = _votes.mul(10000).div(totalVotes);

        voteLock[msg.sender] = lock.add(block.number);

        emit Vote(id, msg.sender, false, vote);
    }

    //stake / withdraw

    function stake(bytes32 select, uint256 amount) public {
        require(false, "stake was disable");
        require(amount > 0, "Cannot stake 0");
        uint256 supply = _onstake(select, amount);
        if (voters[msg.sender] == true) {
            votes[msg.sender] = votes[msg.sender].add(supply);
            totalVotes = totalVotes.add(supply);
        }
        emit Staked(msg.sender, select, amount, supply);
    }

    function withdraw(bytes32 receipt) public {
        uint256 supply = _onwithdraw(receipt);
        if (voters[msg.sender] == true) {
            votes[msg.sender] = votes[msg.sender].sub(supply);
            totalVotes = totalVotes.sub(supply);
        }
        if (breaker == false) {
            require(voteLock[msg.sender] < block.number, "!locked");
        }
        emit Withdrawn(msg.sender, receipt);
    }

    function _onstake(bytes32 select, uint256 amount)
        internal
        returns (uint256)
    {
        Staking memory staking = Staking(
            msg.sender,
            amount,
            now,
            _selects[select].duration,
            _selects[select].exrate,
            _selects[select].reward,
            0,
            0,
            0
        );
        bytes32 receipt = keccak256(abi.encode(_stakeNonce++, staking));
        _stakings[receipt] = staking;
        _receipts[msg.sender].push(receipt);
        _totalStake = _totalStake.add(amount);
        _stakes[msg.sender] = _stakes[msg.sender].add(amount);
        uint256 supply = amount.mul(_stakings[receipt].exrate).div(1e18);
        require(supply > 0, "!supply");
        _totalSupply = _totalSupply.add(supply);
        _balances[msg.sender] = _balances[msg.sender].add(supply);
        IERC20(staketoken).safeTransferFrom(msg.sender, address(this), amount);
        return supply;
    }

    //取回指定的锁仓到期的FOR
    function _onwithdraw(bytes32 receipt) internal returns (uint256) {
        uint256 at = _findReceipt(msg.sender, receipt);
        require(at != uint256(-1), "not found receipt");
        Staking memory _staking = _stakings[receipt];
        require(now > _staking.start.add(_staking.duration), "stake has not expired"); //到期

        uint256 amount = _staking.amount;
        _totalStake = _totalStake.sub(amount);
        _stakes[msg.sender] = _stakes[msg.sender].sub(amount);
        uint256 supply = amount.mul(_staking.exrate).div(1e18);
        require(supply > 0, "!supply");
        _totalSupply = _totalSupply.sub(supply);
        _balances[msg.sender] = _balances[msg.sender].sub(supply);

        uint256 last = _receipts[msg.sender].length - 1;
        _receipts[msg.sender][at] = _receipts[msg.sender][last];
        _receipts[msg.sender].pop();
        delete _stakings[receipt];

        IERC20(staketoken).safeTransfer(msg.sender, amount);
        if(_staking.reward != 0) {
            uint256 reward = amount.mul(_staking.reward).div(1e18);
            IERC20(staketoken).safeTransferFrom(rewarder, msg.sender, reward);
        }
        return supply;
    }

    function _findReceipt(address account, bytes32 receipt)
        internal
        view
        returns (uint256)
    {
        uint256 length = _receipts[account].length;
        for (uint256 i = 0; i < length; ++i) {
            if (receipt == _receipts[account][i]) {
                return i;
            }
        }
        return uint256(-1);
    }
}