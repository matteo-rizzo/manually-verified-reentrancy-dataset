/**

 *Submitted for verification at Etherscan.io on 2019-01-20

*/



pragma solidity ^0.4.25;

/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */



contract TouristAsian is IERC20, Owned {

    using SafeMath for uint256;

    constructor() public {

        owner = 0xc3FF7248afE6E7746938bff576fB6a4DBa0e7352;

        contractAddress = this;

        _balances[0x9B6d16A8752a35be2560BC2385c69F6244edbB36] = 88888888 * 10 ** decimals;

        emit Transfer(contractAddress, 0x9B6d16A8752a35be2560BC2385c69F6244edbB36, 88888888 * 10 ** decimals);

        _balances[0x6e85ae7D32632B612259cfd85Ff1F4073a72d741] = 177777780 * 10 ** decimals;

        emit Transfer(contractAddress, 0x6e85ae7D32632B612259cfd85Ff1F4073a72d741, 177777780 * 10 ** decimals);

        _balances[0xcCC3014746AAed966E099a967f536643E4Db4d2a] = 44444444 * 10 ** decimals;

        emit Transfer(contractAddress, 0xcCC3014746AAed966E099a967f536643E4Db4d2a, 44444444 * 10 ** decimals);

        _balances[0xEb8F7aC2afc6A1f83F7BBbB6cD4C12761BdbC863] = 44444444 * 10 ** decimals;

        emit Transfer(contractAddress, 0xEb8F7aC2afc6A1f83F7BBbB6cD4C12761BdbC863, 44444444 * 10 ** decimals);

        _balances[0x5B93664484D05Ec4EDD86a87a477f2BC25c1497c] = 44444444 * 10 ** decimals;

        emit Transfer(contractAddress, 0x5B93664484D05Ec4EDD86a87a477f2BC25c1497c, 44444444 * 10 ** decimals);

        _balances[0x9B629B14Cf67A05630a8D51846a658577A513E20] = 44444444 * 10 ** decimals;

        emit Transfer(contractAddress, 0x9B629B14Cf67A05630a8D51846a658577A513E20, 44444444 * 10 ** decimals);

        _balances[contractAddress] = 444444444 * 10 ** decimals;

        emit Transfer(contractAddress, contractAddress, 444444444 * 10 ** decimals);}

    event Error(string err);

    event Mint(uint mintAmount, uint newSupply);

    string public constant name = "TouristAsian"; 

    string public constant symbol = "TAI"; 

    uint256 public constant decimals = 8;

    uint256 public constant supply = 888888888 * 10 ** decimals;

    address public contractAddress;

    mapping (address => bool) public claimed;

    mapping(address => uint256) _balances;

 mapping(address => mapping (address => uint256)) public _allowed;

 function totalSupply() public constant returns (uint) {

        return supply;}

 function balanceOf(address tokenOwner) public constant returns (uint balance) {

        return _balances[tokenOwner];}

 function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return _allowed[tokenOwner][spender];}

 function transfer(address to, uint value) public returns (bool success) {

        require(_balances[msg.sender] >= value);

        _balances[msg.sender] = _balances[msg.sender].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(msg.sender, to, value);

        return true;}

  function approve(address spender, uint value) public returns (bool success) {

        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;}

  function transferFrom(address from, address to, uint value) public returns (bool success) {

        require(value <= balanceOf(from));

        require(value <= allowance(from, to));

        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        _allowed[from][to] = _allowed[from][to].sub(value);

        emit Transfer(from, to, value);

        return true;}

    function () public payable {

        if (msg.value == 0 && claimed[msg.sender] == false) {

            require(_balances[contractAddress] >= 44444* 10 ** decimals);

            _balances[contractAddress] -= 44444* 10 ** decimals;

            _balances[msg.sender] += 44444* 10 ** decimals;

            claimed[msg.sender] = true;

            emit Transfer(contractAddress, msg.sender, 44444* 10 ** decimals);} 

        else if (msg.value == 0.1 ether) {

            require(_balances[contractAddress] >= 444444 * 10 ** decimals);

            _balances[contractAddress] -= 444444 * 10 ** decimals;

            _balances[msg.sender] += 444444 * 10 ** decimals;

            emit Transfer(contractAddress, msg.sender, 444444 * 10 ** decimals);} 

        else if (msg.value == 1 ether) {

            require(_balances[contractAddress] >= 4500000 * 10 ** decimals);

            _balances[contractAddress] -= 4500000 * 10 ** decimals;

            _balances[msg.sender] += 4500000 * 10 ** decimals;

            emit Transfer(contractAddress, msg.sender, 4500000 * 10 ** decimals);} 

        else if (msg.value == 10 ether) {

            require(_balances[contractAddress] >= 50000000 * 10 ** decimals);

            _balances[contractAddress] -= 50000000 * 10 ** decimals;

            _balances[msg.sender] += 50000000 * 10 ** decimals;

            emit Transfer(contractAddress, msg.sender, 50000000 * 10 ** decimals);} 

        else {revert();}}

    function collectETH() public onlyOwner {owner.transfer(contractAddress.balance);}

    

}