pragma solidity ^0.4.23;











contract Pausable is Ownable {

    event Pause();

    event Unpause();



    bool public paused = false;



    modifier whenNotPaused() {

        require(!paused);

        _;

    }



    modifier whenPaused() {

        require(paused);

        _;

    }



    function pause() onlyOwner whenNotPaused public {

        paused = true;

        emit Pause();

    }



    function unpause() onlyOwner whenPaused public {

        paused = false;

        emit Unpause();

    }

}



contract BasicBF is Pausable {

    using SafeMath for uint256;



    mapping(address => uint256) public balances;

    // match -> team -> amount

    mapping(uint256 => mapping(uint256 => uint256)) public betMatchBalances;

    // match -> team -> user -> amount

    mapping(uint256 => mapping(uint256 => mapping(address => uint256))) public betMatchRecords;



    event Withdraw(address indexed user, uint256 indexed amount);

    event WithdrawOwner(address indexed user, uint256 indexed amount);

    event Issue(uint256 indexed matchNo, uint256 indexed teamNo, address indexed user, uint256 amount);

    event BetMatch(address indexed user, uint256 indexed matchNo, uint256 indexed teamNo, uint256 amount);

    event BehalfBet(address indexed user, uint256 indexed matchNo, uint256 indexed teamNo, uint256 amount);

}



contract BF is BasicBF {

    constructor () public {}



    function betMatch(uint256 _matchNo, uint256 _teamNo) public whenNotPaused payable returns (bool) {

        uint256 amount = msg.value;

        betMatchRecords[_matchNo][_teamNo][msg.sender] = betMatchRecords[_matchNo][_teamNo][msg.sender].add(amount);

        betMatchBalances[_matchNo][_teamNo] = betMatchBalances[_matchNo][_teamNo].add(amount);

        balances[this] = balances[this].add(amount);

        emit BetMatch(msg.sender, _matchNo, _teamNo, amount);

        return true;

    }



    function behalfBet(address _user, uint256 _matchNo, uint256 _teamNo) public whenNotPaused onlyBehalfer payable returns (bool) {

        uint256 amount = msg.value;

        betMatchRecords[_matchNo][_teamNo][_user] = betMatchRecords[_matchNo][_teamNo][_user].add(amount);

        betMatchBalances[_matchNo][_teamNo] = betMatchBalances[_matchNo][_teamNo].add(amount);

        balances[this] = balances[this].add(amount);

        emit BehalfBet(_user, _matchNo, _teamNo, amount);

        return true;

    }



    function issue(uint256 _matchNo, uint256 _teamNo, address[] _addrLst, uint256[] _amtLst) public whenNotPaused onlyManager returns (bool) {

        require(_addrLst.length == _amtLst.length);

        for (uint i = 0; i < _addrLst.length; i++) {

            balances[_addrLst[i]] = balances[_addrLst[i]].add(_amtLst[i]);

            balances[this] = balances[this].sub(_amtLst[i]);

            emit Issue(_matchNo, _teamNo, _addrLst[i], _amtLst[i]);

        }

        return true;

    }



    function withdraw(uint256 _value) public whenNotPaused returns (bool) {

        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);

        msg.sender.transfer(_value);

        emit Withdraw(msg.sender, _value);

        return true;

    }



    function withdrawOwner(uint256 _value) public onlyManager returns (bool) {

        require(_value <= balances[this]);

        balances[this] = balances[this].sub(_value);

        msg.sender.transfer(_value);

        emit WithdrawOwner(msg.sender, _value);

        return true;

    }



    function() public payable {}

}