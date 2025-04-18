contract EightHoursToken {

    event Transfer (address indexed _from, address indexed _to, uint _tokens);

    event Approval (

        address indexed _tokenOwner, 

        address indexed _spender, 

        uint _tokens

    );

    uint totalEHrT = (10 ** 10) * (10**18);    

    mapping (address => uint) ehrtBalances;

    mapping (address => mapping (address => uint)) allowances;

    constructor() public {

        ehrtBalances[msg.sender] = totalEHrT;

    }

    modifier sufficientFunds(address tokenOwner, uint tokens) {

        require (ehrtBalances[tokenOwner] >= tokens, "Insufficient balance");

        _;

    }

    function transfer(address _to, uint _tokens) 

        public

        sufficientFunds(msg.sender, _tokens)

        returns(bool) 

    {

        ehrtBalances[msg.sender] -= _tokens;

        if (_to != address(0)) {

            ehrtBalances[_to] += _tokens;

        }

        else {

            totalEHrT -= _tokens;

        }

        emit Transfer(msg.sender, _to, _tokens);

        return true;

    }

    function transferFrom(address _from, address _to, uint _tokens) 

        public

        sufficientFunds(_from, _tokens)

        returns(bool) 

    {

        require (

            allowances[_from][msg.sender] >= _tokens, 

            "Insufficient allowance"

        );

        allowances[_from][msg.sender] -= _tokens;

        ehrtBalances[_from] -= _tokens;

        if (_to != address(0)) {

            ehrtBalances[_to] += _tokens;

        }

        else {

            totalEHrT -= _tokens;

        }

        emit Transfer(_from, _to, _tokens);

        return true;

    }

    function approve(address _spender, uint _tokens) external returns(bool) {

        allowances[msg.sender][_spender] = _tokens;

        emit Approval(msg.sender, _spender, _tokens);

        return true;

    }

    function totalSupply() external view returns (uint) { return totalEHrT; }

    function balanceOf(address _tokenOwner) public view returns(uint) {

        return ehrtBalances[_tokenOwner];

    }

    function allowance(

        address _tokenOwner, 

        address _spender

    ) public view returns (uint) {

        return allowances[_tokenOwner][_spender];

    }

    function name() external pure returns (string memory) { 

        return "Eight Hours Token"; 

    }

    function symbol() external pure returns (string memory) { return "EHrT"; }

    function decimals() external pure returns (uint8) { return 18; }

}
