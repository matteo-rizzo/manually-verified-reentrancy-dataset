/**
 *Submitted for verification at Etherscan.io on 2021-04-30
*/

/**
 *Submitted for verification at Etherscan.io on 2021-04-28
*/

pragma solidity 0.6.0;







contract SeekReward {

    using SafeMath for uint256;

    // Investor details
    struct user {
        uint256 cycle;
        address upline;
        uint256 referrals;
        uint256 payouts;
        uint256 referalBonus;
        uint256 matchBonus;
        uint256 depositAmount;
        uint256 depositPayouts;
        uint40 depositTime;
        uint256 totalDeposits;
        uint256 totalStructure;
    }
    
    // Token instance
    IERC777 public token;

    // Mapping users details by address
    mapping(address => user)public users;

    // Contract status
    bool public lockStatus;
    // Admin1 address
    address public admin1;
    // Admin2 address
    address public admin2;
    // Total levels
    uint[]public Levels;
    // Total users count
    uint256 public totalUsers = 1;
    // Total deposit amount.
    uint256 public totalDeposited;
    // Total withdraw amount
    uint256 public totalWithdraw;

    // Matching bonus event
    event MatchBonus(address indexed from, address indexed to, uint value, uint time);
    // Withdraw event
    event Withdraw(address indexed from, uint value, uint time);
    // Deposit event
    event Deposit(address indexed from, address indexed refer, uint value, uint time);
    // Admin withdraw event
    event AdminEarnings(address indexed user, uint value, uint time);
    // User withdraw limt event
    event LimitReached(address indexed from, uint value, uint time);
   
    /**
     * @dev Initializes the contract setting the owners and token.
     */
    constructor(address  _owner1, address  _owner2, address _token) public {
        admin1 = _owner1;
        admin2 = _owner2;
        token = IERC777(_token);

        //Levels maximum amount
        Levels.push(6000e18);
        Levels.push(6000e18);
        Levels.push(6000e18);
        Levels.push(6000e18);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == admin1, "SeekReward: Only Owner");
        _;
    }

    /**
     * @dev Throws if lockStatus is true
     */
    modifier isLock() {
        require(lockStatus == false, "SeekReward: Contract Locked");
        _;
    }

    /**
     * @dev Throws if called by other contract
     */
    modifier isContractCheck(address _user) {
        require(!isContract(_user), "SeekReward: Invalid address");
        _;
    }

    function _setUpline(address _addr, address _upline) private {
        if (users[_addr].upline == address(0) && _upline != _addr && _addr != admin1 && 
           (users[_upline].depositTime > 0 || _upline == admin1)) {
            users[_addr].upline = _upline;
            users[_upline].referrals = users[_upline].referrals.add(1);
            totalUsers++;
            for (uint8 i = 0; i < 21; i++) { // For update total structure for uplines
                if (_upline == address(0)) break;
                users[_upline].totalStructure++;
                _upline = users[_upline].upline;
            }
        }
    }

    function _deposit(address _addr, uint256 _amount) private {
        require(users[_addr].upline != address(0) || _addr == admin1, "No upline");
        if (users[_addr].depositTime > 0) {
            users[_addr].cycle++;
            require(users[_addr].payouts >= this.maxPayoutOf(users[_addr].depositAmount),
            "SeekReward: Deposit already exists");
            require(_amount >= users[_addr].depositAmount && _amount <= Levels[users[_addr].cycle > Levels.length - 1 ?Levels.length - 1 : users[_addr].cycle], "SeekReward: Bad amount");
        }
        else {
            require(_amount >= 0.5e18 && _amount <= Levels[0], "SeekReward: Bad amount");
        }
        require(token.transferFrom(msg.sender, address(this), _amount), "Seekreward: transaction failed");

        users[_addr].payouts = 0;
        users[_addr].depositAmount = _amount;
        users[_addr].depositPayouts = 0;
        users[_addr].depositTime = uint40(block.timestamp);
        users[_addr].referalBonus = 0;
        users[_addr].matchBonus = 0;
        users[_addr].totalDeposits = users[_addr].totalDeposits.add(_amount);
        totalDeposited = totalDeposited.add(_amount);

        address upline = users[_addr].upline;
        address up = users[users[_addr].upline].upline;

        if (upline != address(0)) {
            token.transfer(upline, _amount.mul(10e18).div(100e18)); // 10% for direct referer
            users[upline].referalBonus = users[upline].referalBonus.add(_amount.mul(10e18).div(100e18));
        }
        if (up != address(0)) {
            token.transfer(up, _amount.mul(5e18).div(100e18)); // 5% for indirect referer
            users[up].referalBonus = users[up].referalBonus.add(_amount.mul(5e18).div(100e18));
        }

        uint adminFee = _amount.mul(5e18).div(100e18);
        token.transfer(admin1, adminFee.div(2)); // 2.5% admin1
        token.transfer(admin2, adminFee.div(2)); // 2.5% admin2
        adminFee = 0;
        emit Deposit(_addr, users[_addr].upline, _amount, block.timestamp);
    }

    /**
     * @dev deposit: User deposit with 1 seek token
     * 5% adminshare split into 2 accounts
     * @param _upline: Referal address
     * @param amount:1st deposit minimum 1 seek & maximum 150 for cycle 1
     * Next depsoit amount based on previous deposit amount and maximum amount based on cycles
     */
    function deposit(address _upline, uint amount) external isLock isContractCheck(msg.sender) {
        _setUpline(msg.sender, _upline);
        _deposit(msg.sender, amount);
    }
    
    function _matchBonus(address _user, uint _amount) private {
        address up = users[_user].upline;
        for (uint i = 1; i <= 21; i++) { // For matching bonus
            if (up == address(0)) break;
            if (i <= 3) {
                users[up].matchBonus = users[up].matchBonus.add(_amount); 
                emit MatchBonus(_user, up, _amount, block.timestamp);
            }
            else if (i <= 6) {
                if (users[up].referrals >= 2) {
                    users[up].matchBonus = users[up].matchBonus.add(_amount);
                    emit MatchBonus(_user, up, _amount, block.timestamp);
                }
            }
            else if (i <= 10) {
                if (users[up].referrals >= 4) {
                    users[up].matchBonus = users[up].matchBonus.add(_amount);
                    emit MatchBonus(_user, up, _amount, block.timestamp);
                }
            }
            else if (i <= 14) {
                if (users[up].referrals >= 8) {
                    users[up].matchBonus = users[up].matchBonus.add(_amount);
                    emit MatchBonus(_user, up, _amount, block.timestamp);
                }
            }
            else if (i <= 21) {
                if (users[up].referrals >= 16) {
                    users[up].matchBonus = users[up].matchBonus.add(_amount);
                    emit MatchBonus(_user, up, _amount, block.timestamp);
                }
            }
            up = users[up].upline;
        }
    }

    /**
     * @dev withdraw: User can get amount till maximum payout reach.
     * maximum payout based on(daily ROI,matchbonus)
     * maximum payout limit 210 percentage
     */
    function withdraw() external isLock {
        (uint256 to_payout, uint256 max_payout) = this.payoutOf(msg.sender);
        require(msg.sender != admin1, "SeekReward: only for users");
        require(users[msg.sender].payouts < max_payout, "SeekReward: Full payouts");
        // Deposit payout
        if (to_payout > 0) {
            if (users[msg.sender].payouts.add(to_payout) > max_payout) {
                to_payout = max_payout.sub(users[msg.sender].payouts);
            }
            users[msg.sender].depositPayouts = users[msg.sender].depositPayouts.add(to_payout);
            users[msg.sender].payouts = users[msg.sender].payouts.add(to_payout);
            _matchBonus(msg.sender, to_payout.mul(3e18).div(100e18));
        }
        // matching bonus
        if (users[msg.sender].payouts < max_payout && users[msg.sender].matchBonus > 0) {
            if (users[msg.sender].payouts.add(users[msg.sender].matchBonus) > max_payout) {
                users[msg.sender].matchBonus = max_payout.sub(users[msg.sender].payouts);
            }
            users[msg.sender].payouts = users[msg.sender].payouts.add(users[msg.sender].matchBonus);
            to_payout = to_payout.add(users[msg.sender].matchBonus);
            users[msg.sender].matchBonus = users[msg.sender].matchBonus.sub(users[msg.sender].matchBonus);
        }
        totalWithdraw = totalWithdraw.add(to_payout);
        token.transfer(msg.sender, to_payout); // Daily roi and matching bonus
        emit Withdraw(msg.sender, to_payout, block.timestamp);

        if (users[msg.sender].payouts >= max_payout) {
            emit LimitReached(msg.sender, users[msg.sender].payouts, block.timestamp);
        }
    }

    /**
     * @dev adminWithdraw: owner invokes the function
     * owner can get referbonus, matchbonus 
     */
    function adminWithdraw() external onlyOwner {
        uint amount;
        if (users[admin1].referalBonus > 0) {
            amount = amount.add(users[admin1].referalBonus);
            users[admin1].referalBonus = 0;
        }
        if (users[admin1].matchBonus > 0) {
            amount = amount.add(users[admin1].matchBonus);
            users[admin1].matchBonus = 0;
        }
        token.transfer(admin1, amount); //Referal bonus and matching bonus
        emit AdminEarnings(admin1, amount, block.timestamp);
    }

    /**
     * @dev maxPayoutOf: Amount calculate by 210 percentage
     */
    function maxPayoutOf(uint256 _amount) external pure returns(uint256) {
        return _amount.mul(210).div(100);
    }

    /**
     * @dev payoutOf: Users daily ROI and maximum payout will be show
     */
    function payoutOf(address _addr) external view returns(uint256 payout, uint256 max_payout) {
        max_payout = this.maxPayoutOf(users[_addr].depositAmount);
        if (users[_addr].depositPayouts < max_payout) {
            payout = ((users[_addr].depositAmount.mul(1e18).div(100e18)).mul((block.timestamp
            .sub(users[_addr].depositTime)).div(1 days))).sub(users[_addr].depositPayouts); // Daily roi
            if (users[_addr].depositPayouts.add(payout) > max_payout) {
                payout = max_payout.sub(users[_addr].depositPayouts);
            }
        }
    }

    /**
     * @dev userInfo: Returns upline,depositTime,depositAmount,payouts,match_bonus
     */
    function userInfo(address _addr) external view returns(address upline, uint40 deposit_time,
    uint256 deposit_amount, uint256 payouts, uint256 match_bonus) {
        return (users[_addr].upline, users[_addr].depositTime, users[_addr].depositAmount,
                users[_addr].payouts, users[_addr].matchBonus);
    }

    /**
     * @dev userInfoTotals: Returns users referrals count, totalDeposit, totalStructure
     */
    function userInfoTotals(address _addr) external view returns(uint256 referrals,
    uint256 total_deposits, uint256 total_structure) {
        return (users[_addr].referrals, users[_addr].totalDeposits, users[_addr].totalStructure);
    }

    /**
     * @dev contractInfo: Returns total users, totalDeposited, totalWithdraw
     */
    function contractInfo() external view returns(uint256 _total_users, uint256 _total_deposited,
    uint256 _total_withdraw) {
        return (totalUsers, totalDeposited, totalWithdraw);
    }

    /**
     * @dev contractLock: For contract status
     */
    function contractLock(bool _lockStatus) public onlyOwner returns(bool) {
        lockStatus = _lockStatus;
        return true;
    }

    /**
     * @dev failSafe: Returns transfer token
     */
    function failSafe(address _toUser, uint _amount) external onlyOwner returns(bool) {
        require(_toUser != address(0), "Invalid Address");
        require(token.balanceOf(address(this)) >= _amount, "SeekReward: insufficient amount");
        token.transfer(_toUser, _amount);
        return true;
    }

    /**
     * @dev isContract: Returns true if account is a contract
     */
    function isContract(address _account) public view returns(bool) {
        uint32 size;
        assembly {
            size:= extcodesize(_account)
        }
        if (size != 0)
            return true;
        return false;
    }
}