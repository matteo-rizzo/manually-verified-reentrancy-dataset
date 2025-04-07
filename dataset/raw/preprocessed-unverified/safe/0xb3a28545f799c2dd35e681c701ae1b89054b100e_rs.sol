/**
 *Submitted for verification at Etherscan.io on 2020-10-16
*/

// UUUUUUUU     UUUUUUUUNNNNNNNN        NNNNNNNNIIIIIIIIIIFFFFFFFFFFFFFFFFFFFFFF      AAA               RRRRRRRRRRRRRRRRR   MMMMMMMM               MMMMMMMM
// U::::::U     U::::::UN:::::::N       N::::::NI::::::::IF::::::::::::::::::::F     A:::A              R::::::::::::::::R  M:::::::M             M:::::::M
// U::::::U     U::::::UN::::::::N      N::::::NI::::::::IF::::::::::::::::::::F    A:::::A             R::::::RRRRRR:::::R M::::::::M           M::::::::M
// UU:::::U     U:::::UUN:::::::::N     N::::::NII::::::IIFF::::::FFFFFFFFF::::F   A:::::::A            RR:::::R     R:::::RM:::::::::M         M:::::::::M
//  U:::::U     U:::::U N::::::::::N    N::::::N  I::::I    F:::::F       FFFFFF  A:::::::::A             R::::R     R:::::RM::::::::::M       M::::::::::M
//  U:::::D     D:::::U N:::::::::::N   N::::::N  I::::I    F:::::F              A:::::A:::::A            R::::R     R:::::RM:::::::::::M     M:::::::::::M
//  U:::::D     D:::::U N:::::::N::::N  N::::::N  I::::I    F::::::FFFFFFFFFF   A:::::A A:::::A           R::::RRRRRR:::::R M:::::::M::::M   M::::M:::::::M
//  U:::::D     D:::::U N::::::N N::::N N::::::N  I::::I    F:::::::::::::::F  A:::::A   A:::::A          R:::::::::::::RR  M::::::M M::::M M::::M M::::::M
//  U:::::D     D:::::U N::::::N  N::::N:::::::N  I::::I    F:::::::::::::::F A:::::A     A:::::A         R::::RRRRRR:::::R M::::::M  M::::M::::M  M::::::M
//  U:::::D     D:::::U N::::::N   N:::::::::::N  I::::I    F::::::FFFFFFFFFFA:::::AAAAAAAAA:::::A        R::::R     R:::::RM::::::M   M:::::::M   M::::::M
//  U:::::D     D:::::U N::::::N    N::::::::::N  I::::I    F:::::F         A:::::::::::::::::::::A       R::::R     R:::::RM::::::M    M:::::M    M::::::M
//  U::::::U   U::::::U N::::::N     N:::::::::N  I::::I    F:::::F        A:::::AAAAAAAAAAAAA:::::A      R::::R     R:::::RM::::::M     MMMMM     M::::::M
//  U:::::::UUU:::::::U N::::::N      N::::::::NII::::::IIFF:::::::FF     A:::::A             A:::::A   RR:::::R     R:::::RM::::::M               M::::::M
//   UU:::::::::::::UU  N::::::N       N:::::::NI::::::::IF::::::::FF    A:::::A               A:::::A  R::::::R     R:::::RM::::::M               M::::::M
//     UU:::::::::UU    N::::::N        N::::::NI::::::::IF::::::::FF   A:::::A                 A:::::A R::::::R     R:::::RM::::::M               M::::::M
//       UUUUUUUUU      NNNNNNNN         NNNNNNNIIIIIIIIIIFFFFFFFFFFF  AAAAAAA                   AAAAAAARRRRRRRR     RRRRRRRMMMMMMMM               MMMMMMMM
//
// FARM CONTRACT 
// unifarm.io - 
// t.me/unifarm_official

pragma solidity 0.5.17;





contract ERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowed;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 internal _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return A uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param owner address The address which owns the funds.
    * @param spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token to a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to be spent.
    */
    function approve(address spender, uint256 value) public returns (bool) {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
    * @dev Transfer tokens from one address to another.
    * Note that while this function emits an Approval event, this is not required as per the specification,
    * and other compliant implementations may not emit the event.
    * @param from address The address which you want to send tokens from
    * @param to address The address which you want to transfer to
    * @param value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        if (from != msg.sender && _allowed[from][msg.sender] != uint256(-1))
            _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

}

contract ERC20Mintable is ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    function _mint(address to, uint256 amount) internal {
        _balances[to] = _balances[to].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        _balances[from] = _balances[from].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(from, address(0), amount);
    }
}

contract Unifarm is ERC20Mintable, Ownable {
    using SafeMath for uint256;
    
    mapping (address => bool) public isMinter;

    constructor() public {
        name = "UNIFARM.IO";
        symbol = "UNF";
        decimals = 18;
    }

    function setMinter(address minter, bool flag) external onlyOwner {
        isMinter[minter] = flag;
    }

    function mint(address to, uint256 amount) external {
        require(isMinter[msg.sender], "Not Minter");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        if (from != msg.sender && _allowed[from][msg.sender] != uint256(-1))
            _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(amount);
        require(_balances[from] >= amount, "insufficient-balance");
        _burn(from, amount);
    }
    
}






contract Farm is Ownable {
    using SafeMath for uint256;

    Unifarm public unifarm; //white unifarm
    IUniswapV2Pair public cUnifarm; //colored unifarm
    ERC20 public token; //token
    uint256 public today;
    uint256 public spawnRate;
    uint256 public withdrawRate;
    uint256 public timeLock;

    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;
    mapping(address => uint256) public depositTimeStamp;

    constructor(uint256 _spawnRate, uint256 _withdrawRate, uint256 _timeLock, address _unifarm, address _cUnifarm, address _token) public {
        today = now / 1 days;
        spawnRate = _spawnRate;
        withdrawRate = _withdrawRate;
        timeLock = _timeLock;
        unifarm = Unifarm(_unifarm);
        cUnifarm = IUniswapV2Pair(_cUnifarm);
        token = ERC20(_token);
    }

    function setParams(uint256 _spawnRate, uint256 _withdrawRate, uint256 _timeLock) external onlyOwner {
        require(_spawnRate <= 0.1e18);
        require(_withdrawRate >= 0.85e18 && _withdrawRate <= 1e18);
        require(_timeLock <= 15 days);
        spawnRate = _spawnRate;
        withdrawRate = _withdrawRate;
        timeLock = _timeLock;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function totalValue() public view returns(uint256) {
        return cUnifarm.balanceOf(address(this));
    }

    function deposit(uint256 amount) external returns (uint256 share) {
        if(totalSupply() > 0) 
            share = totalSupply().mul(amount).div(totalValue());
        else
            share = amount;
        _balances[msg.sender] = _balances[msg.sender].add(share);
        depositTimeStamp[msg.sender] = now;
        _totalSupply = _totalSupply.add(share);
        require(cUnifarm.transferFrom(msg.sender, address(this), amount));
    }

    function withdraw(address to, uint256 share) external returns (uint256 amount) {
        require(depositTimeStamp[msg.sender].add(timeLock) <= now, "locked");
        amount = share.mul(totalValue()).div(totalSupply());
        if(share < _totalSupply)
            amount = amount.mul(withdrawRate).div(1e18);
        _balances[msg.sender] = _balances[msg.sender].sub(share);
        _totalSupply = _totalSupply.sub(share);
        require(cUnifarm.transfer(to, amount));
    }

    function rescueToken(ERC20 _token, uint256 _amount) onlyOwner public {
        require(_token != ERC20(address(cUnifarm)));
        _token.transfer(msg.sender, _amount);
    }

    function breed() external {
        require(now / 1 days > today);
        today += 1;

        uint256 unifarmPairAmount = unifarm.balanceOf(address(cUnifarm));
        uint256 tokenPairAmount = token.balanceOf(address(cUnifarm));
        uint256 newUnifarm = unifarmPairAmount.mul(spawnRate).div(1e18);
        uint256 amount = UniswapV2Library.getAmountOut(newUnifarm, unifarmPairAmount, tokenPairAmount);

        unifarm.mint(address(cUnifarm), newUnifarm);
        if(address(unifarm) < address(token))
            cUnifarm.swap(0, amount, address(this), "");
        else
            cUnifarm.swap(amount, 0, address(this), "");
        token.transfer(address(cUnifarm), amount);
        unifarm.mint(address(cUnifarm), newUnifarm);
        cUnifarm.mint(address(this));
    }
}