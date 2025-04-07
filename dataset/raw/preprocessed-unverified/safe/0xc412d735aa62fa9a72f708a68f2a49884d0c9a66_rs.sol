pragma solidity ^0.4.23;



contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}



contract MAPOMZ is Owned, ERC20Interface {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) public freezeBypassing;
    mapping(address => uint256) public lockupExpirations;
    string public constant symbol = "MAPOMZ";
    string public constant name = "Mapomz Token";
    uint8 public constant decimals = 0;
    uint256 public circulatingSupply = 0;
    bool public tradingLive = false;
    uint256 public totalSupply;

    constructor() public {
        totalSupply = 4000000000;
        balances[0x8300521eB07d67902553FC1040436739289cAc2f] = totalSupply / 100 * 25;
        balances[0xdf457b3c71315fda4be40c399296180af3cbd066] = totalSupply / 100 * 25;
        balances[0xeb574cD5A407Fefa5610fCde6Aec13D983BA527c] = totalSupply / 100 * 25;
        balances[0xE4FF99F4a0256ebE6AE99eA6D14CC7414eb91209] = totalSupply / 100 * 25;
    }


    function totalSupply() public view returns (uint256 supply) {
        return totalSupply;
    }

    /**
     * @notice Get the token balance of `owner`
     * @dev This function is part of the ERC20 standard
     * @param owner The wallet to get the balance of
     * @return {"balance": "The balance of `owner`"}
     */
    function balanceOf(
        address owner
    )
        public view returns (uint256 balance)
    {
        return balances[owner];
    }

    /**
     * @notice Transfers `amount` from msg.sender to `destination`
     * @dev This function is part of the ERC20 standard
     * @param destination The address that receives the tokens
     * @param amount Token amount to transfer
     * @return {"success": "If the operation completed successfuly"}
     */
    function transfer(
        address destination,
        uint256 amount
    )
        public returns (bool success)
    {
        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[destination] = balances[destination].add(amount);
        emit Transfer(msg.sender, destination, amount);
        return true;
    }

    /**
     * @notice Transfer tokens from an address to another one
     * through an allowance made before
     * @dev This function is part of the ERC20 standard
     * @param from The address that sends the tokens
     * @param to The address that receives the tokens
     * @param tokenAmount Token amount to transfer
     * @return {"success": "If the operation completed successfuly"}
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenAmount
    )
        public returns (bool success)
    {
        balances[from] = balances[from].sub(tokenAmount);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokenAmount);
        balances[to] = balances[to].add(tokenAmount);
        emit Transfer(from, to, tokenAmount);
        return true;
    }

    /**
     * @notice Approve an address to send `tokenAmount` tokens to `msg.sender` (make an allowance)
     * @dev This function is part of the ERC20 standard
     * @param spender The allowed address
     * @param tokenAmount The maximum amount allowed to spend
     * @return {"success": "If the operation completed successfuly"}
     */
    function approve(
        address spender,
        uint256 tokenAmount
    )
        public returns (bool success)
    {
        allowed[msg.sender][spender] = tokenAmount;
        emit Approval(msg.sender, spender, tokenAmount);
        return true;
    }

    /**
     * @notice Get the remaining allowance for a spender on a given address
     * @dev This function is part of the ERC20 standard
     * @param tokenOwner The address that owns the tokens
     * @param spender The spender
     * @return {"remaining": "The amount of tokens remaining in the allowance"}
     */
    function allowance(
        address tokenOwner,
        address spender
    )
        public view returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }
}