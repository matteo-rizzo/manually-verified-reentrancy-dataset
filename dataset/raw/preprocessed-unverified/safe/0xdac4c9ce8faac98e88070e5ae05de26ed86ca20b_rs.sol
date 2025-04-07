/**
 *Submitted for verification at Etherscan.io on 2021-03-26
*/

pragma solidity = 0.5.16;





contract Management is Ownable {
    mapping(address => uint8) private _managers;
    uint internal _nonce;
    mapping(uint => Transaction) internal _pendingTransactions;
    uint[] internal _pendingTxIDs;

    uint internal constant MIN_SIGNATURES = 3;
    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'YouSwap: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    struct Transaction {
        uint8 state;
        address creator;
        uint8 teamId;
        address teamAccount;
        address newTeamAccount;
        address agent;
        address newAgent;
        uint8 signatureCount;
        mapping(address => uint8) signatures;
    }

    event TransactionCreated(
        address creator,
        uint8 teamId,
        address teamAccount,
        address newTeamAccount,
        address teamAgent,
        address newTeamAgent,
        uint transactionId
    );

    constructor() public {
        _managers[0xf3c5C84E69163bD60D49A90cC4d4b7f12bb592d2] = 1;
        _managers[0xD391FF3F474478aB9517aabD8cA22c599c6E6314] = 1;
        _managers[0x6A02a11035136FB3Ca55F163ed80Eae2CeE0057F] = 1;
    }

    modifier isManager{
        require(_managers[msg.sender] == 1, "CALLER_IS_NOT_A_MANAGER");
        _;
    }

    function addManager(address manager) external onlyOwner {
        _managers[manager] = 1;
    }

    function removeManager(address manager) external onlyOwner {
        _managers[manager] = 0;
    }

    function getPendingTxIDs() external view returns (uint[] memory){
        return _pendingTxIDs;
    }

    function getPendingTransaction(uint transactionId) external view returns
    (
        address creator,
        uint8 teamId,
        address teamAccount,
        address newTeamAccount,
        address teamAgent,
        address newTeamAgent,
        uint8 signatureCount){

        require(_pendingTransactions[transactionId].state == 1, 'YouSwap:NOT_EXIST');

        return (
        _pendingTransactions[transactionId].creator,
        _pendingTransactions[transactionId].teamId,
        _pendingTransactions[transactionId].teamAccount,
        _pendingTransactions[transactionId].newTeamAccount,
        _pendingTransactions[transactionId].agent,
        _pendingTransactions[transactionId].newAgent,
        _pendingTransactions[transactionId].signatureCount);
    }

    function deleteTransaction(uint transactionId) public isManager {
        require(_pendingTransactions[transactionId].state == 1, 'YouSwap:NOT_EXIST');
        uint8 replace = 0;
        for (uint i = 0; i < _pendingTxIDs.length; i++) {
            if (1 == replace) {
                _pendingTxIDs[i - 1] = _pendingTxIDs[i];
            }

            if (transactionId == _pendingTxIDs[i]) {
                replace = 1;
            }
        }
        delete _pendingTxIDs[_pendingTxIDs.length - 1];
        _pendingTxIDs.length--;

        delete _pendingTransactions[transactionId];
    }
}

contract TokenDispatch is Management {
    using SafeMath for uint256;

    struct Team {
        address account;
        address agent;
        uint256 reserved;
        uint256 claimed;
        uint8 claimedTimes;
        uint256 lastClaimedHeight;
        uint256 packageI;
        uint256 packageII;
        uint256 packageIII;
        uint256 packageIV;
        bool approved;
    }

    uint256 public constant startHeight = 12113920;
    uint256 public constant totalSupply = 4 * 10 ** 13;//30 million for startup team, 10 million for investment organizations
    uint256 public totalClaimed;
    uint256 public approved;
    uint8 private _teamId;
    mapping(uint8 => Team) private _teams;
    address private constant _youToken = 0x1d32916CFA6534D261AD53E2498AB95505bd2510;
    uint256 private constant _blocksOfMonth = 172800;//3600/15*24*30;

    event Claimed(
        address indexed recipient,
        uint8 teamId,
        uint256 amountOfYou
    );

    event ApproveTeam(
        uint8 teamId,
        address indexed account,
        address indexed agent,
        uint256 reserve
    );

    event TeamUpdated(
        uint8 teamId,
        address indexed oldAccount,
        address newAccount,
        address indexed oldAgent,
        address newAgent
    );

    constructor() public {
        totalClaimed = 0;
        approved = 0;
        _teamId = 0;
    }

    function approve(address account, address agent, uint256 reserve) public onlyOwner {
        require(approved.add(reserve) <= totalSupply, 'YouSwap: EXCEEDS_THE_TOTAL_SUPPLY_FOR_TEAM');
        _teamId ++;
        _teams[_teamId].approved = true;
        _teams[_teamId].account = account;
        _teams[_teamId].agent = agent;
        _teams[_teamId].reserved = reserve;

        _teams[_teamId].packageI = reserve.mul(12).div(100);
        _teams[_teamId].packageII = reserve.mul(27).div(100);
        _teams[_teamId].packageIII = reserve.mul(24).div(100);
        _teams[_teamId].packageIV = reserve.mul(37).div(100);

        _teams[_teamId].lastClaimedHeight = startHeight;
        approved = approved.add(reserve);

        emit ApproveTeam(_teamId, account, agent, reserve);
    }

    function teamOf(uint8 teamId) external view returns
    (
        address account,
        address agent,
        uint256 reserved,
        uint256 claimed,
        uint8 claimedTimes,
        uint256 lastClaimedHeight
    ) {
        require(_teams[teamId].approved, 'YouSwap: NOT_EXIST');
        return
        (
        _teams[teamId].account,
        _teams[teamId].agent,
        _teams[teamId].reserved,
        _teams[teamId].claimed,
        _teams[teamId].claimedTimes,
        _teams[teamId].lastClaimedHeight
        );
    }

    function nextClaimHeightOf(uint8 teamId) external view returns (uint256) {
        require(_teams[teamId].approved, 'YouSwap: NOT_EXIST');
        require(_teams[teamId].claimed < _teams[teamId].reserved, 'YouSwap: COMPLETED_ALREADY');
        return _teams[teamId].lastClaimedHeight.add(_blocksOfMonth);
    }

    function claimedOf(uint8 teamId) external view returns (uint256) {
        require(_teams[teamId].approved, 'YouSwap: NOT_EXIST');
        return _teams[teamId].claimed;
    }

    function balanceOf(uint8 teamId) external view returns (uint256) {
        require(_teams[teamId].approved, 'YouSwap: NOT_EXIST');
        return _teams[teamId].reserved.sub(_teams[teamId].claimed);
    }

    function updateTeam(uint8 teamId, address newAccount, address newAgent) isManager external returns (uint256) {
        require(_teams[teamId].approved, 'YouSwap: NOT_EXIST');
        uint transactionId = ++_nonce;
        Transaction storage transaction = _pendingTransactions[transactionId];
        require(transaction.state == 0, 'YouSwap: TRANSACTION_EXISTS');
        transaction.state = 1;
        transaction.creator = msg.sender;
        transaction.teamId = teamId;
        transaction.teamAccount = _teams[teamId].account;
        transaction.newTeamAccount = newAccount;
        transaction.agent = _teams[teamId].agent;
        transaction.newAgent = newAgent;
        transaction.signatureCount = 1;
        transaction.signatures[msg.sender] = 1;

        _pendingTxIDs.push(transactionId);

        emit TransactionCreated(msg.sender, teamId, _teams[teamId].account, newAccount, _teams[teamId].agent, newAgent, transactionId);

        return transactionId;
    }

    function claim(uint8 teamId) external lock {
        require(_teams[teamId].approved, 'YouSwap: TEAM_NOT_EXIST');
        require(block.number >= startHeight.add(_blocksOfMonth), 'YouSwap: TIME_IS_NOT_UP');
        require(_teams[teamId].agent == msg.sender || _teams[teamId].account == msg.sender, 'YouSwap: CALLER_IS_NOT_THE_OWNER_OR_AGENT');
        require(_teams[teamId].claimed < _teams[teamId].reserved, 'YouSwap: EXCEEDS_THE_RESERVED_AMOUNT');
        uint deltaBlocks = block.number.sub(_teams[teamId].lastClaimedHeight);
        require(deltaBlocks >= _blocksOfMonth, 'YouSwap: CLAIMED_THIS_MONTH');

        uint times = 0;
        uint256 canClaimThisTime = 0;
        if (block.number <= startHeight.add(_blocksOfMonth.mul(3))) {//The first stage of 3 months, normal claim state
            times = deltaBlocks.div(_blocksOfMonth);
            canClaimThisTime = _teams[teamId].packageI.div(3).mul(times);
            _teams[teamId].lastClaimedHeight = _teams[teamId].lastClaimedHeight.add(_blocksOfMonth * times);
        }
        else if (block.number <= startHeight.add(_blocksOfMonth.mul(12))) {//The second stage of 9 months(4~12month)
            if (_teams[teamId].lastClaimedHeight < startHeight.add(_blocksOfMonth.mul(3))) {//Claim-progress still in the first stage,then just finish this stage
                canClaimThisTime = _teams[teamId].packageI.sub(_teams[teamId].claimed);
                _teams[teamId].lastClaimedHeight = startHeight.add(_blocksOfMonth.mul(3));
            }
            else {//Claim-progress in the second stage(4~12month),normal claim state
                times = deltaBlocks.div(_blocksOfMonth);
                canClaimThisTime = _teams[teamId].packageII.div(9).mul(times);
                _teams[teamId].lastClaimedHeight = _teams[teamId].lastClaimedHeight.add(_blocksOfMonth.mul(times));
            }
        }
        else if (block.number <= startHeight.add(_blocksOfMonth.mul(24))) {//The third stage of 12 months(13~24)
            if (_teams[teamId].lastClaimedHeight < startHeight.add(_blocksOfMonth.mul(3))) {//Only finish the first stage
                canClaimThisTime = _teams[teamId].packageI.sub(_teams[teamId].claimed);
                _teams[teamId].lastClaimedHeight = startHeight.add(_blocksOfMonth.mul(3));
            }
            else if (_teams[teamId].lastClaimedHeight < startHeight.add(_blocksOfMonth.mul(12))) {//Only finish the second stage
                canClaimThisTime = _teams[teamId].packageII.add(_teams[teamId].packageI).sub(_teams[teamId].claimed);
                _teams[teamId].lastClaimedHeight = startHeight.add(_blocksOfMonth.mul(12));
            }
            else {
                times = deltaBlocks.div(_blocksOfMonth);
                canClaimThisTime = _teams[teamId].packageIII.div(12).mul(times);
                _teams[teamId].lastClaimedHeight = _teams[teamId].lastClaimedHeight.add(_blocksOfMonth.mul(times));
            }
        }
        else {//The fourth stage of 37 months
            if (_teams[teamId].lastClaimedHeight < startHeight.add(_blocksOfMonth.mul(3))) {
                canClaimThisTime = _teams[teamId].packageI.sub(_teams[teamId].claimed);
                _teams[teamId].lastClaimedHeight = startHeight.add(_blocksOfMonth.mul(3));
            }
            else if (_teams[teamId].lastClaimedHeight < startHeight.add(_blocksOfMonth.mul(12))) {
                canClaimThisTime = _teams[teamId].packageII.add(_teams[teamId].packageI).sub(_teams[teamId].claimed);
                _teams[teamId].lastClaimedHeight = startHeight.add(_blocksOfMonth.mul(12));
            }
            else if (_teams[teamId].lastClaimedHeight < startHeight.add(_blocksOfMonth.mul(24))) {
                canClaimThisTime = _teams[teamId].packageIII.add(_teams[teamId].packageII).add(_teams[teamId].packageI).sub(_teams[teamId].claimed);
                _teams[teamId].lastClaimedHeight = startHeight.add(_blocksOfMonth.mul(24));
            }
            else {
                times = deltaBlocks.div(_blocksOfMonth);
                canClaimThisTime = _teams[teamId].packageIV.div(37).mul(times);
                if (_teams[teamId].claimed.add(canClaimThisTime).add(10000) > _teams[teamId].reserved) {//The last month
                    canClaimThisTime = _teams[teamId].reserved.sub(_teams[teamId].claimed);
                }
                _teams[teamId].lastClaimedHeight = _teams[teamId].lastClaimedHeight.add(_blocksOfMonth.mul(times));
            }
        }

        _mintYou(_teams[teamId].account, canClaimThisTime);
        _teams[teamId].claimed = _teams[teamId].claimed.add(canClaimThisTime);

        totalClaimed = totalClaimed.add(canClaimThisTime);
        require(totalClaimed <= totalSupply, 'YouSwap: EXCEEDS_THE_UPPER_LIMIT');
        emit Claimed(_teams[teamId].account, teamId, canClaimThisTime);
    }

    function _mintYou(address recipient, uint256 amount) private {
        bytes4 methodId = bytes4(keccak256(bytes('mint(address,uint256)')));

        (bool success, bytes memory data) = _youToken.call(abi.encodeWithSelector(methodId, recipient, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'YouSwap: TRANSFER_FAILED');
    }

    function signTransaction(uint transactionId) external lock isManager {
        require(_pendingTransactions[transactionId].state == 1, 'YouSwap:NOT_EXIST');
        Transaction storage transaction = _pendingTransactions[transactionId];
        require(transaction.signatures[msg.sender] != 1, "YouSwap: SIGNED_ALREADY");
        transaction.signatures[msg.sender] = 1;
        transaction.signatureCount++;

        if (transaction.signatureCount >= MIN_SIGNATURES) {
            _teams[transaction.teamId].account = transaction.newTeamAccount;
            _teams[transaction.teamId].agent = transaction.newAgent;
            emit TeamUpdated(transaction.teamId, transaction.teamAccount, transaction.newTeamAccount, transaction.agent, transaction.newAgent);

            deleteTransaction(transactionId);
        }
    }
}