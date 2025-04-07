/**

 *Submitted for verification at Etherscan.io on 2019-01-11

*/



pragma solidity ^0.4.24;















/*

    TokenStore

*/

contract TokenStore is ITokenStore, Ownable {

    using SafeMath for uint256;

    

    address private _tokenLogic;

    uint256 private _totalSupply;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    

    constructor(uint256 totalSupply, address holder) public {

        _totalSupply = totalSupply;

        _balances[holder] = totalSupply;

    }

    

    // token logic

    event ChangeTokenLogic(address newTokenLogic);

    

    modifier onlyTokenLogic() {

        require(msg.sender == _tokenLogic, "this method MUST be called by the security's logic address");

        _;

    }

    

    function tokenLogic() public view returns (address) {

        return _tokenLogic;

    }

    

    function setTokenLogic(ITokenLogic newTokenLogic) public onlyOwner {

        _tokenLogic = newTokenLogic;

        emit ChangeTokenLogic(newTokenLogic);

    }

    

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }

    

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];

    }

    

    function allowance(address owner, address spender) public view returns(uint256) {

        return _allowed[owner][spender];

    }

    

    function transfer(address src, address dest, uint256 amount) public onlyTokenLogic {

        _balances[src] = _balances[src].sub(amount);

        _balances[dest] = _balances[dest].add(amount);

    }

    

    function approve(address owner, address spender, uint256 amount) public onlyTokenLogic {

        _allowed[owner][spender] = amount;

    }

    

    function mint(address dest, uint256 amount) public onlyTokenLogic {

        _balances[dest] = _balances[dest].add(amount);

        _totalSupply = _totalSupply.add(amount);

    }

    

    function burn(address dest, uint256 amount) public onlyTokenLogic {

        _balances[dest] = _balances[dest].sub(amount);

        _totalSupply = _totalSupply.sub(amount);

    }

}



/*

    TokenLogic

*/

