library SafeMath {

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0);

        uint256 c = _a / _b;

        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

}

contract ReferStorage is Ownable {
    using SafeMath for uint;

    mapping(address => mapping(address => uint)) private referrerBalance;

    mapping(address => uint) public percentReferrer;

    mapping(address => uint) public balanceContract;

    mapping(address => bool) public whitelist;

    mapping(address => bool) private parentContract;

    modifier onlyOwnerOrWhitelist(){
        address _customerAddress = msg.sender;
        require(whitelist[_customerAddress] || isOwner());
        _;
    }

    modifier onlyParentContract {
        require(parentContract[msg.sender] || isOwner(), "onlyParentContract methods called by non - parent of contract.");
        _;
    }

    event ReferrerWithdraw(address indexed investor, uint256 amount);
    event ReferrerDeposit(address indexed investor, uint256 amount);
    event AddWhitelist(address indexed walletUser, address indexed admin);
    event PutAmountToFund(address indexed addressContract, uint amount, address indexed sender);
    event GetAmountFromFund(address indexed addressContract, uint amount, address indexed beneficiary, address indexed sender);

    constructor() public
    Ownable(msg.sender)
    {}

    function() external payable {
    }

    function viewReferrerBalance(address _contractAddress, address _referrer) public view returns (uint256) {
        return referrerBalance[_contractAddress][_referrer];
    }

    function getReferrerBalance(address _contractAddress) public {
        address payable referrer = msg.sender;
        uint amount = referrerBalance[_contractAddress][referrer];
        if (amount <= balanceContract[_contractAddress] && amount <= balanceAll()) {
            referrerBalance[_contractAddress][referrer] = referrerBalance[_contractAddress][referrer].sub(amount);
            _contractAddress.call.value(1)("");	
balanceContract[_contractAddress] = balanceContract[_contractAddress].sub(amount);
            referrer.transfer(amount);
            emit ReferrerWithdraw(referrer, amount);
        }
    }

    function setWhitelist(address _newUser, bool _status) onlyParentContract public {
        whitelist[_newUser] = _status;
        emit AddWhitelist(_newUser, msg.sender);
    }

    function setReferrerPercent(address _contractAddress, uint _newPercent) onlyParentContract public {
        require(_newPercent >= 0);
        percentReferrer[_contractAddress] = _newPercent;
    }

    function getReferrerPercent(address _contractAddress) public view returns(uint) {
        return percentReferrer[_contractAddress];
    }

    function balanceAll() public view returns (uint) {
        return address(this).balance;
    }

    function balanceByContract(address _contract) public view returns (uint) {
        return balanceContract[_contract];
    }

    function depositFunds(address _contract) onlyOwnerOrWhitelist payable public {
        require(_contract != address(0));
        uint amount = msg.value;
        if (amount > 0) {
            balanceContract[_contract] = balanceContract[_contract].add(amount);
            emit PutAmountToFund(_contract, amount, msg.sender);
        }
    }

    function withdrawFunds(uint _amount, address payable _beneficiary, address _contract) onlyParentContract public {
        require(_contract != address(0));
        require(balanceContract[_contract] >= _amount && balanceAll() >= _amount && _amount > 0);
        _contract.call.value(1)("");	
balanceContract[_contract] = balanceContract[_contract].sub(_amount);
        _beneficiary.transfer(_amount);
        emit GetAmountFromFund(_contract, _amount, _beneficiary, msg.sender);
    }

    function withdraw(uint _amount) onlyOwner public {
        require(balanceAll() >= _amount && _amount > 0);
        address payable contractOwner = owner();
        contractOwner.transfer(_amount);
        emit GetAmountFromFund(address(this), _amount, contractOwner, msg.sender);
    }

    function setParentContract(address _contract, bool _status) onlyOwner public {
        parentContract[_contract] = _status;
    }

    function checkReferralLink(address _contract, address payable _referral, uint256 _amount, bytes memory _referrer) onlyOwnerOrWhitelist public {
        if (_referrer.length == 20) {
            address referrer = bytesToAddress(_referrer);
            if (referrer != msg.sender && referrer != _referral ) {
                uint _referrerAmount = _amount.mul(percentReferrer[_contract]).div(1000);
                _addReferrerBalance(_contract, referrer, _referrerAmount);
            }
        }
    }

    function _addReferrerBalance(address _contract, address _referrer, uint _amount) internal {
        referrerBalance[_contract][_referrer] = referrerBalance[_contract][_referrer].add(_amount);
        emit ReferrerDeposit(_referrer, _amount);
    }

    function bytesToAddress(bytes memory source) internal pure returns (address) {
        uint result;
        uint mul = 1;
        for (uint i = 20; i > 0; i--) {
            result += uint8(source[i - 1]) * mul;
            mul = mul * 256;
        }
        return address(result);
    }
}
