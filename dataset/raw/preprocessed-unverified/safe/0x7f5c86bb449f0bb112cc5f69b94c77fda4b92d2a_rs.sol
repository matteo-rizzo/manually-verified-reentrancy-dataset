pragma solidity ^0.4.23;



// ----------------------------------------------------------------------------

// @Project Korea Locate Election Event

// @Creator Block-Packer Crew *BP_Ryu*

// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------

// @Name SafeMath

// @Desc Math operations with safety checks that throw on error

// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol

// ----------------------------------------------------------------------------

/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */



// ----------------------------------------------------------------------------

// ERC Token Standard #20 Interface

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

// ----------------------------------------------------------------------------

contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}

// ----------------------------------------------------------------------------

// @Name Lockable

// @Desc Admin Lock

// ----------------------------------------------------------------------------

contract Lockable {

    bool public    m_bIsLock;

    address public m_aOwner;



    modifier IsOwner {

        require(m_aOwner == msg.sender);

        _;

    }



    modifier AllLock {

        require(!m_bIsLock);

        _;

    }



    constructor() public {

        m_bIsLock   = false;

        m_aOwner    = msg.sender;

    }

}

// ----------------------------------------------------------------------------

// @Name TokenBase

// @Desc ERC20-based token

// ----------------------------------------------------------------------------

contract TokenBase is ERC20Interface, Lockable {

    using SafeMath for uint;



    uint                                                _totalSupply;

    mapping(address => uint256)                         _balances;

    mapping(address => mapping(address => uint256))     _allowed;



    function totalSupply() public constant returns (uint) {

        return _totalSupply;

    }



    function balanceOf(address tokenOwner) public constant returns (uint balance) {

        return _balances[tokenOwner];

    }



    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return _allowed[tokenOwner][spender];

    }



    function transfer(address to, uint tokens) public returns (bool success) {

        return false;

    }



    function approve(address spender, uint tokens) public returns (bool success) {

        return false;

    }



    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        return false;

    }

}

// ----------------------------------------------------------------------------

// @Name KLEToken

// @Desc Token name     : 2018 지방선거 참여자

//       Token Symbol   : KLEV18

//                      (Korea Locate Election Voter 2018)

//

//       Token Name     : 2018 지방선거 홍보왕

//       Token Symbol   : KLEH18

//                      (Korea Locate Election Honorary 2018)

//

//       Token Name     : 2018 지방선거 후원자

//       Token Symbol   : KLES18

//                      (Korea Locate Election Sponsor 2018)

// ----------------------------------------------------------------------------

contract KLEToken is TokenBase {

    string  public   name;

    uint8   public   decimals;

    string  public   symbol;



    constructor (uint a_totalSupply, string a_tokenName, string a_tokenSymbol, uint8 a_decimals) public {

        m_aOwner = msg.sender;

        

        _totalSupply = a_totalSupply;

        _balances[msg.sender] = a_totalSupply;



        name = a_tokenName;

        symbol = a_tokenSymbol;

        decimals = a_decimals;

    }



    // Allocate tokens to the users

    function AllocateToken(address[] a_receiver)

    external

    IsOwner

    AllLock {

        uint receiverLength = a_receiver.length;

        

        for(uint ui = 0; ui < receiverLength; ui++){

            _balances[a_receiver[ui]]++;

        }

        

        _totalSupply = _totalSupply.add(receiverLength);

    }



    function EndEvent() 

    external

    IsOwner {

        m_bIsLock = true;

    }

}