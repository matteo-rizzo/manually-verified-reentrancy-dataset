/**

 *Submitted for verification at Etherscan.io on 2018-09-27

*/



pragma solidity ^0.4.24;



// File: contracts/library/SafeMath.sol



/**

 * @title SafeMath v0.1.9

 * @dev Math operations with safety checks that throw on error

 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor

 * - added sqrt

 * - added sq

 * - added pwr 

 * - changed asserts to requires with error log outputs

 * - removed div, its useless

 */





// File: contracts/library/TimeUtils.sol







// File: contracts/interface/DRSCoinInterface.sol







// File: contracts/DRSCoin.sol



contract DRSCoin {

    using SafeMath for uint256;

    using TimeUtils for uint;



    struct MonthInfo {

        uint256 ethIncome;

        uint256 totalTokenSupply;

    }



    string constant tokenName = "DRSCoin";

    string constant tokenSymbol = "DRS";

    uint8 constant decimalUnits = 18;



    uint256 public constant tokenExchangeInitRate = 500; // 500 tokens per 1 ETH initial

    uint256 public constant tokenExchangeLeastRate = 10; // 10 tokens per 1 ETH at least

    uint256 public constant tokenReduceValue = 5000000;

    uint256 public constant coinReduceRate = 90;



    uint256 constant private proposingPeriod = 2 days;

    // uint256 constant private proposingPeriod = 2 seconds;



    string public name;

    string public symbol;

    uint8 public decimals;



    uint256 public totalSupply = 0;

    uint256 public tokenReduceAmount;

    uint256 public tokenExchangeRate; // DRSCoin / eth

    uint256 public nextReduceSupply;  // next DRSCoin reduction supply



    address public owner;



    mapping(address => bool) restrictedAddresses;



    mapping(address => uint256) public balanceOf;



    mapping(address => mapping(address => uint256)) public allowance;



    mapping(address => uint32) public lastRefundMonth;



    mapping(address => uint256) public refundEth;  //record the user profit



    mapping(uint32 => MonthInfo) monthInfos;



    mapping(address => bool) allowedGameAddress;



    mapping(address => uint256) proposedGames;



    /* This generates a public event on the blockchain that will notify clients */

    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed _owner, address indexed _spender, uint256 _value);



    event Mint(address indexed _to, uint256 _value);



    // event Info(uint256 _value);



    /* This notifies clients about the amount burnt */

    event Burn(address indexed from, uint256 value);



    event Profit(address indexed from, uint256 year, uint256 month, uint256 value);



    event Withdraw(address indexed from, uint256 value);



    modifier onlyOwner {

        assert(owner == msg.sender);

        _;

    }



    modifier onlyAllowedGameAddress {

        require(allowedGameAddress[msg.sender], "only allowed games permit to call");

        _;

    }



    /* Initializes contract with initial supply tokens to the creator of the contract */

    constructor() public

    {

        name = tokenName;                                   // Set the name for display purposes

        symbol = tokenSymbol;                               // Set the symbol for display purposes

        decimals = decimalUnits;                            // Amount of decimals for display purposes



        tokenReduceAmount = tokenReduceValue.mul(uint256(10) ** uint256(decimals));

        tokenExchangeRate = tokenExchangeInitRate;          // Set initial token exchange rate

        nextReduceSupply = tokenReduceAmount;               // Set next token reduction supply



        owner = msg.sender;

    }



    // _startMonth included

    // _nowMonth excluded

    function settleEth(address _addr, uint32 _startMonth, uint32 _nowMonth) internal {

        require(_nowMonth >= _startMonth);



        // _startMonth == 0 means new address

        if(_startMonth == 0) {

            lastRefundMonth[_addr] = _nowMonth;

            return;

        }



        if(_nowMonth == _startMonth) {

            lastRefundMonth[_addr] = _nowMonth;

            return;

        }



        uint256 _balance = balanceOf[_addr];

        if(_balance == 0) {

            lastRefundMonth[_addr] = _nowMonth;

            return;

        }



        uint256 _unpaidPerfit = getUnpaidPerfit(_startMonth, _nowMonth, _balance);

        refundEth[_addr] = refundEth[_addr].add(_unpaidPerfit);



        lastRefundMonth[_addr] = _nowMonth;

        return;

    }



    function getCurrentMonth() internal view returns(uint32) {

        (uint16 _year, uint8 _month) = now.parseTimestampToYM();

        return _year * 12 + _month - 1;

    }



    function transfer(address _to, uint256 _value) public returns(bool success) {

        require(_value > 0);

        require(balanceOf[msg.sender] >= _value);              // Check if the sender has enough

        require(balanceOf[_to] + _value >= balanceOf[_to]);    // Check for overflows

        require(!restrictedAddresses[msg.sender]);

        require(!restrictedAddresses[_to]);



        uint32 _nowMonth = getCurrentMonth();



        // settle msg.sender's eth

        settleEth(msg.sender, lastRefundMonth[msg.sender], _nowMonth);



        // settle _to's eth

        settleEth(_to, lastRefundMonth[_to], _nowMonth);



        // transfer token

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);   // Subtract from the sender

        balanceOf[_to] = balanceOf[_to].add(_value);                 // Add the same to the recipient

        emit Transfer(msg.sender, _to, _value);                      // Notify anyone listening that this transfer took place

        return true;

    }



    function approve(address _spender, uint256 _value) public returns(bool success) {

        allowance[msg.sender][_spender] = _value;                 // Set allowance

        emit Approval(msg.sender, _spender, _value);              // Raise Approval event

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) {

        require(balanceOf[_from] >= _value);                  // Check if the sender has enough

        require(balanceOf[_to] + _value >= balanceOf[_to]);   // Check for overflows

        require(_value <= allowance[_from][msg.sender]);      // Check allowance

        require(!restrictedAddresses[_from]);

        require(!restrictedAddresses[msg.sender]);

        require(!restrictedAddresses[_to]);



        uint32 _nowMonth = getCurrentMonth();



        // settle _from's eth

        settleEth(_from, lastRefundMonth[_from], _nowMonth);



        // settle _to's eth

        settleEth(_to, lastRefundMonth[_to], _nowMonth);



        // transfer token

        balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the sender

        balanceOf[_to] = balanceOf[_to].add(_value);        // Add the same to the recipient

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }



    function getUnpaidPerfit(uint32 _startMonth, uint32 _endMonth, uint256 _tokenAmount) internal view returns(uint256)

    {

        require(_startMonth > 0);

        require(_endMonth >= _startMonth);



        if(_startMonth == _endMonth) {

            return 0;

        }



        if(_tokenAmount == 0) {

            return 0;

        }



        uint256 _profit = 0;



        uint256 _income;

        uint256 _totalSupply;

        for(uint32 j = _startMonth; j < _endMonth; j++) {

            _income = monthInfos[j].ethIncome;

            _totalSupply = monthInfos[j].totalTokenSupply;

            if(_income > 0 && _totalSupply > 0) {

                _profit = _profit.add(_income.mul(_tokenAmount).div(_totalSupply));

            }

        }



        return _profit;

    }



    function totalSupply() constant public returns(uint256) {

        return totalSupply;

    }



    function tokenExchangeRate() constant public returns(uint256) {

        return tokenExchangeRate;

    }



    function nextReduceSupply() constant public returns(uint256) {

        return nextReduceSupply;

    }



    function balanceOf(address _owner) constant public returns(uint256) {

        return balanceOf[_owner];

    }



    function allowance(address _owner, address _spender) constant public returns(uint256) {

        return allowance[_owner][_spender];

    }



    function() public payable {

        revert();

    }



    /* Owner can add new restricted address or removes one */

    function editRestrictedAddress(address _newRestrictedAddress) public onlyOwner {

        restrictedAddresses[_newRestrictedAddress] = !restrictedAddresses[_newRestrictedAddress];

    }



    function isRestrictedAddress(address _querryAddress) constant public returns(bool) {

        return restrictedAddresses[_querryAddress];

    }



    function getMintAmount(uint256 _eth) private view returns(uint256 _amount, uint256 _nextReduceSupply, uint256 _tokenExchangeRate) {

        _nextReduceSupply = nextReduceSupply;

        _tokenExchangeRate = tokenExchangeRate;



        _amount = 0;

        uint256 _part = _nextReduceSupply.sub(totalSupply);  // calculate how many DRSCoin can mint in this period

        while(_part <= _eth.mul(_tokenExchangeRate)) {

            _eth = _eth.sub(_part.div(_tokenExchangeRate));  // sub eth amount

            _amount = _amount.add(_part);                    // add DRSCoin mint in this small part



            _part = tokenReduceAmount;

            _nextReduceSupply = _nextReduceSupply.add(tokenReduceAmount);



            if(_tokenExchangeRate > tokenExchangeLeastRate) {

                _tokenExchangeRate = _tokenExchangeRate.mul(coinReduceRate).div(100);

                if(_tokenExchangeRate < tokenExchangeLeastRate) {

                    _tokenExchangeRate = tokenExchangeLeastRate;

                }

            }

        }



        _amount = _amount.add(_eth.mul(_tokenExchangeRate));



        return (_amount, _nextReduceSupply, _tokenExchangeRate);

    }



    function mint(address _to, uint256 _eth) external onlyAllowedGameAddress {

        require(_eth > 0);



        (uint256 _amount, uint256 _nextReduceSupply, uint256 _tokenExchangeRate) = getMintAmount(_eth);



        require(_amount > 0);

        require(totalSupply + _amount > totalSupply);

        require(balanceOf[_to] + _amount > balanceOf[_to]);     // Check for overflows



        uint32 _nowMonth = getCurrentMonth();



        // settle _to's eth

        settleEth(_to, lastRefundMonth[_to], _nowMonth);



        totalSupply = _amount.add(totalSupply);                 // Update total supply

        balanceOf[_to] = _amount.add(balanceOf[_to]);           // Set minted coins to target



        // add current month's totalTokenSupply

        monthInfos[_nowMonth].totalTokenSupply = totalSupply;



        if(_nextReduceSupply != nextReduceSupply) {

            nextReduceSupply = _nextReduceSupply;

        }

        if(_tokenExchangeRate != tokenExchangeRate) {

            tokenExchangeRate = _tokenExchangeRate;

        }



        emit Mint(_to, _amount);                                // Create Mint event

        emit Transfer(0x0, _to, _amount);                       // Create Transfer event from 0x

    }



    function burn(uint256 _value) public returns(bool success) {

        require(balanceOf[msg.sender] >= _value);            // Check if the sender has enough

        require(_value > 0);



        uint32 _nowMonth = getCurrentMonth();



        // settle msg.sender's eth

        settleEth(msg.sender, lastRefundMonth[msg.sender], _nowMonth);



        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);            // Subtract from the sender

        totalSupply = totalSupply.sub(_value);                                // Updates totalSupply



        // update current month's totalTokenSupply

        monthInfos[_nowMonth].totalTokenSupply = totalSupply;



        emit Burn(msg.sender, _value);

        return true;

    }



    function addGame(address gameAddress) public onlyOwner {

        require(!allowedGameAddress[gameAddress], "game already in allow list");

        require(proposedGames[gameAddress] > 0, "game must be in proposed list first");

        require(now > proposedGames[gameAddress].add(proposingPeriod), "game must be debated for 2 days");



        // add gameAddress to allowedGameAddress

        allowedGameAddress[gameAddress] = true;



        // delete gameAddress from proposedGames

        proposedGames[gameAddress] = 0;

    }



    function proposeGame(address gameAddress) public onlyOwner {

        require(!allowedGameAddress[gameAddress], "game already in allow list");

        require(proposedGames[gameAddress] == 0, "game already in proposed list");



        // add gameAddress to proposedGames

        proposedGames[gameAddress] = now;

    }



    function deleteGame (address gameAddress) public onlyOwner {

        require(allowedGameAddress[gameAddress] || proposedGames[gameAddress] > 0, "game must in allow list or proposed list");



        // delete gameAddress from allowedGameAddress

        allowedGameAddress[gameAddress] = false;



        // delete gameAddress from proposedGames

        proposedGames[gameAddress] = 0;

    }



    function gameCountdown(address gameAddress) public view returns(uint256) {

        require(proposedGames[gameAddress] > 0, "game not in proposed list");



        uint256 proposedTime = proposedGames[gameAddress];



        if(now < proposedTime.add(proposingPeriod)) {

            return proposedTime.add(proposingPeriod).sub(now);

        } else {

            return 0;

        }

    }



    function profitEth() external payable onlyAllowedGameAddress {

        (uint16 _year, uint8 _month) = now.parseTimestampToYM();

        uint32 _nowMonth = _year * 12 + _month - 1;



        uint256 _ethIncome = monthInfos[_nowMonth].ethIncome.add(msg.value);



        monthInfos[_nowMonth].ethIncome = _ethIncome;



        if(monthInfos[_nowMonth].totalTokenSupply == 0) {

            monthInfos[_nowMonth].totalTokenSupply = totalSupply;

        }



        emit Profit(msg.sender, _year, _month, _ethIncome);

    }



    function withdraw() public {

        require(!restrictedAddresses[msg.sender]);  // check if msg.sender is restricted



        uint32 _nowMonth = getCurrentMonth();



        uint32 _startMonth = lastRefundMonth[msg.sender];

        require(_startMonth > 0);



        settleEth(msg.sender, _startMonth, _nowMonth);



        uint256 _profit = refundEth[msg.sender];

        require(_profit > 0);



        refundEth[msg.sender] = 0;

        msg.sender.transfer(_profit);



        emit Withdraw(msg.sender, _profit);

    }



    function getEthPerfit(address _addr) public view returns(uint256) {

        uint32 _nowMonth = getCurrentMonth();



        uint32 _startMonth = lastRefundMonth[_addr];

        // new user

        if(_startMonth == 0) {

            return 0;

        }



        uint256 _tokenAmount = balanceOf[_addr];



        uint256 _perfit = refundEth[_addr];



        if(_startMonth < _nowMonth && _tokenAmount > 0) {

            uint256 _unpaidPerfit = getUnpaidPerfit(_startMonth, _nowMonth, _tokenAmount);

            _perfit = _perfit.add(_unpaidPerfit);

        }



        return _perfit;

    }

}



// contract DRSCoinTestContract {

//     DRSCoinInterface public drsCoin;



//     constructor(address _drsCoin) public {

//         drsCoin = DRSCoinInterface(_drsCoin);

//     }



//     function mintDRSCoin(address _addr, uint256 _amount) public {

//         drsCoin.mint(_addr, _amount);

//     }

// }