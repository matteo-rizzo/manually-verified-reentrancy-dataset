/**

 *Submitted for verification at Etherscan.io on 2018-12-28

*/



pragma solidity ^0.4.25;











contract ERC223ReceivingContract {

    function tokenFallback(address from, uint value, bytes data) public;

}



contract UNIGENEBIO is IERC20, IERC223 {

    using SafeMath for uint256;

    

    mapping (address => uint256) private _balances;

    

    mapping (address => mapping (address => uint256)) private _allowed;

    

    uint256 private constant _totalSupply = 10000000000e18;

    

    string public constant symbol = "UGB";

    string public constant name = "UNIGENE BIO";

    uint8 public constant decimals = 18;

  

    constructor() public {

        _balances[msg.sender] = _totalSupply;

    }



    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }

    

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }

    

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];

    }

    

    function transfer(address to, uint value, bytes data) public returns (bool){

        require(

            _balances[msg.sender] >= value

            && value > 0

        );



        _balances[msg.sender] = _balances[msg.sender].sub(value);

        _balances[to] = _balances[to].add(value);

        // Check to see if receiver is contract

        if(isContract(to)) {

            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);

            receiver.tokenFallback(msg.sender, value, data);

        }

        emit Transfer(msg.sender, to, value);

        return true;

    }

    

    // Overridden Backwards compatible transfer method without _data param

    function transfer(address to, uint value) public returns (bool) {

        bytes memory empty;

        require(

            _balances[msg.sender] >= value

            && value > 0

        );



        _balances[msg.sender] = _balances[msg.sender].sub(value);

        _balances[to] = _balances[to].add(value);

        // Check to see if receiver is contract

        if(isContract(to)) {

            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);

            receiver.tokenFallback(msg.sender, value, empty);

        }

        emit Transfer(msg.sender, to, value);

        return true;

    }



    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));

        

        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    function isContract(address from) private constant returns (bool) {

        uint256 codeSize;

        assembly {

            codeSize := extcodesize(from)

        }

        return codeSize > 0;

    }



    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        require(value <= _balances[from]);

        require(value <= _allowed[from][msg.sender]);

        require(to != address(0));

        

        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit Transfer(from, to, value);

        return true;

    }

}



