abstract contract RoundStorage {

    uint256 public fee;

    uint256 public amount;

    uint public roundTime;

    struct Round {

        bool finalized;

        uint startTime;
        uint endTime;
        uint256 fee;
        uint256 amount;
    }

    Round[] public rounds;
}

contract Round is RoundStorage {
    event Bet(uint256 indexed round, address indexed player, uint256 indexed amount);
    event RoundStarted(uint256 indexed round);
    event RoundEnded(uint256 indexed round);

    function getCurrentRoundNumber() public view returns(uint256) {
        if (rounds.length > 0) {
            return rounds.length - 1;
        }

        return 0;
    }

    function getCurrentRound() public view returns (uint256 number, uint start, uint end, uint256 betAmount) {
        uint256 currentRoundNumber = getCurrentRoundNumber();
        return (
            currentRoundNumber,
            rounds[currentRoundNumber].startTime,
            rounds[currentRoundNumber].endTime,
            rounds[currentRoundNumber].amount
        );
    }

    function updateRoundFirstDeposit() internal {
        uint256 currentRound = getCurrentRoundNumber();
        if (rounds[currentRound].endTime == 0) {
            rounds[currentRound].endTime = now + roundTime;
        }
    }

    function roundOver() internal view returns(bool) {
        uint256 currentRound = getCurrentRoundNumber();
        if (rounds[currentRound].endTime == 0) {
            return false;
        } else {
            return rounds[currentRound].endTime < now;
        }
    }

    function newRound() internal {
        rounds.push(Round({
            finalized: false,
            startTime: now,
            endTime: 0, 
            fee: fee,
            amount: amount
        }));

        emit RoundStarted(getCurrentRoundNumber());
    }
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract BalanceStorage {
    mapping(address => uint256) public balances;
}

contract Balance is BalanceStorage {
    using SafeMath for uint256;

    function claim() public {
        TransferHelper.safeTransferETH(msg.sender, balances[msg.sender]);
        balances[msg.sender] = 0;
    }

    function addBalance(address _user, uint256 _amount) internal {
        balances[_user] = balances[_user].add(_amount);
    }
}

abstract contract Maintainer {
    address public maintainer;

    modifier onlyMaintainer() {
        require(msg.sender == maintainer, "ERROR: permission denied, only maintainer");
        _;
    }

    function setMaintainer(address _maintainer) external virtual;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract RunningMan is Ownable, Round, Balance, Maintainer {
    using SafeMath for uint256;
    uint256 public winPercent;

    enum State {
        UNDEFINED, WIN, LOSE, REFUND
    }

    struct Player {
        address payable addr;
        uint256 balance;
        State state;
    }

    mapping(uint256 => Player[]) public players;

    constructor(
        uint256 _fee,
        uint256 _winPercent,
        uint256 _amount,
        uint256 _roundTime,
        address _maintainer
    ) public {
        fee = _fee;
        amount = _amount;
        roundTime = _roundTime;
        winPercent = _winPercent;
        maintainer = _maintainer;

        newRound();
    }

    function getCurrentRoundBalance() public view returns(uint256 balance) {
        uint256 currentRound = getCurrentRoundNumber();

        uint256 total;
        for (uint256 i=0; i<players[currentRound].length; i++) {
            total = total.add(players[currentRound][i].balance);
        }
        return total;
    }

    function getPlayer(uint256 _round, address payable _player) public view returns(uint256 playerBet, State playerState) {
        for (uint256 i=0; i<players[_round].length; i++) {
            if (players[_round][i].addr == _player) {
                return (players[_round][i].balance, players[_round][i].state);
            }
        }

        return (0, State.UNDEFINED);
    }

    function getRoundPlayers(uint256 _round) public view returns(uint256) {
        return players[_round].length;
    }

    function getBalance(uint256 _round, address payable _player) public view returns(uint256) {
        if (_round <= rounds.length - 1) {
            for (uint256 i=0; i<players[_round].length; i++) {
                if (players[_round][i].addr == _player) {
                    return players[_round][i].balance;
                }
            }
        }
        return 0;
    }

    function bet() public payable {
        uint256 currentRound = getCurrentRoundNumber();
        require(msg.value == rounds[currentRound].amount, "ERROR: amount not allowed");
        if (rounds[currentRound].endTime !=0 )
            require(rounds[currentRound].endTime >= now, "ERROR: round is over");

        bool isBet;
        for (uint256 i=0; i<players[currentRound].length; i++) {
            if (players[currentRound][i].addr == msg.sender) {
                isBet = true;
            }
        }

        require(isBet == false, "ERROR: already bet");

        if (!isBet) {
            players[currentRound].push(Player({
                addr: msg.sender,
                balance: msg.value,
                state: State.UNDEFINED
            }));

            updateRoundFirstDeposit();
            emit Bet(currentRound, msg.sender, msg.value);
        }
    }

    function _open() internal {
        newRound();
    }

    function _end() internal {
        uint256 currentRound = getCurrentRoundNumber();
        _calculate(currentRound);
        rounds[currentRound].finalized = true;

        emit RoundEnded(currentRound);
    }

    function _calculate(uint256 _round) internal {
        uint256 onePercent = 100*(10**6);
        uint256 numberOfWinners = players[_round].length.mul(winPercent).div(onePercent);

        if (numberOfWinners <= 0) {

            for (uint256 i=0 ;i<players[_round].length; i++) {
                TransferHelper.safeTransferETH(players[_round][i].addr, players[_round][i].balance);
                players[_round][i].state = State.REFUND;
            }
        } else {
            uint256 totalReward;
            for (uint256 i=0; i<players[_round].length; i++) {
                totalReward = totalReward.add(players[_round][i].balance);
                if (i < numberOfWinners) {
                    players[_round][i].state = State.WIN;
                } else {
                    players[_round][i].state = State.LOSE;
                }
            }

            uint256 feeAmount = totalReward.mul(fee).div(100).div(10**6);
            TransferHelper.safeTransferETH(owner(), feeAmount);
            totalReward = totalReward.sub(feeAmount);

            uint256 winAmount = totalReward.div(numberOfWinners);
            for (uint256 i=0; i<numberOfWinners; i++) {
                players[_round][i].balance = winAmount;
                addBalance(players[_round][i].addr, winAmount);
                totalReward = totalReward.sub(winAmount);
            }

            if (totalReward > 0) {
                TransferHelper.safeTransferETH(owner(), totalReward);
            }
        }
    }

    function setRules(uint256 _fee, uint256 _amount, uint256 _roundTime, uint256 _winPercent) public onlyOwner {
        fee = _fee;
        amount = _amount;
        roundTime = _roundTime;
        winPercent = _winPercent;
    }

    function setMaintainer(address _maintainer) public override onlyOwner {
        maintainer = _maintainer;
    }

    function reset() public onlyMaintainer {
        require(roundOver(), "ERROR: round is not over");
        _end();
        _open();
    }
}
