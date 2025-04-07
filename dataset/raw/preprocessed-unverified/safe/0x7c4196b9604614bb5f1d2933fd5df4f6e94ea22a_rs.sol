pragma solidity ^0.7.0;
//SPDX-License-Identifier: UNLICENSED
// access to brad@icon.gold PW Whistler69. 
// web site is www.icon.gold
// outside contact address is reservations@icon.gold




contract Token {
    
    using SafeMath for uint;
    string internal _symbol;
    string internal _name;
    uint internal _totalSupply = 1000;
    uint public _buyPrice;
    mapping (address => uint) internal balances;
    address payable owner;
    address payable admin;

    constructor() {
        _symbol = 'GOLD';
        _name = 'AUREAL';
        _totalSupply = 1E9;
        owner = 0x2457c84d4e5769D76aF958Fec89aAc944F8E96D1;
        admin = 0x5DB93d0f6bcDaEe7EF5812fa9e38E2A7C5eEeEAf;
        balances[owner] = _totalSupply;
         _addMinter(owner);


    }
    
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    mapping (address => bool) public _minters;

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters[account];
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters[account] = true;
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters[account] = false;
        emit MinterRemoved(account);
    }
    /**
     * @dev See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the {MinterRole}.
     */
    function mint( uint256 amount) view public onlyMinter returns (bool) {
        _totalSupply.add(amount);
        balances[msg.sender].add(amount);
        return true;
    }
    
    function name() public view returns (string memory) {
        return _name;
    }
    
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function buyPrice(uint256 price) public{
        require(msg.sender == owner);
        _buyPrice = price;
    }
    
    function buy(uint256 numberOfTokens) public payable returns(bool){
        require(msg.value == numberOfTokens * _buyPrice );
        balances[owner] = balances[owner].sub(numberOfTokens);
        balances[msg.sender] = balances[msg.sender].add(numberOfTokens);
        
    }
    
    function transfer(address _to, uint _value, bytes memory _data) public returns (bool success){
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[admin] = balances[admin].add(_value.div(100));
        balances[_to] = balances[_to].add((_value.div(100)).mul(99));
        if(isContract(_to)) {
            IERC223Recipient receiver = IERC223Recipient(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    function transfer(address _to, uint _value) public returns (bool success){
        bytes memory empty = hex"00000000";
        balances[msg.sender] = balances[msg.sender].sub(_value);
         balances[owner] = balances[owner].add(_value.div(100));
        balances[_to] = balances[_to].add((_value.div(100)).mul(99));
        if(isContract(_to)) {
            IERC223Recipient receiver = IERC223Recipient(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        emit Transfer(msg.sender, _to, _value, empty);
        return true;
    }
    
    function adminTransfer() public returns(bool){
        owner.transfer(address(this).balance);
    }
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }
    function isContract(address _addr) public view returns (bool) {
        uint codeSize;
        assembly {
            codeSize := extcodesize(_addr)
        }
        return codeSize > 0;
    }
    
event Transfer(address indexed from, address indexed to, uint value, bytes data);    
    
}

