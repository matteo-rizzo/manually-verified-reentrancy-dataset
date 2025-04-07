pragma solidity ^0.6.6;

abstract contract Context {
    function _msgSender() internal virtual view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this;
        return msg.data;
    }
}








contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    bool private _isTransferable = false;
    
    address private _crowdAddress;
    address private _racerAddress;
    address private _poolRewardAddress;


    constructor(string memory name, string memory symbol, uint256 amount) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        _totalSupply = amount * 10 ** uint256(_decimals);
        _balances[owner()] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        virtual
        override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
    

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_isTransferable || sender == owner());
        require(sender != _poolRewardAddress);

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _setPoolRewardAddress(
        address poolRewardAddress
    ) internal {
        _poolRewardAddress = poolRewardAddress;
    }

    function _setRacerAddress(
        address contractAddress
    ) internal {
        _racerAddress = contractAddress;
    }

    function _setCrowdAddress(
        address contractAddress
    ) internal {
        _crowdAddress = contractAddress;
    }
    
    function _purchase(
       address recipient, 
       uint256 amount
    ) internal {
        require(msg.sender == _crowdAddress);
        _transfer(owner(), recipient, amount);
    }
    
    function _transferReward(
       address recipient, 
       uint256 amount
    ) internal {
        require(msg.sender == _racerAddress);

        _beforeTokenTransfer(_poolRewardAddress, recipient, amount);

        _balances[_poolRewardAddress] = _balances[_poolRewardAddress].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(_poolRewardAddress, recipient, amount);
    }
    
    function _setTransferable(
        uint8 _value
    ) internal {
        if (_value == 0) {
            _isTransferable = false;
        }
        
        if (_value == 1) {
            _isTransferable = true;
        }
    }
}

contract TortoToken is ERC20("Tortoise.Finance", "TRTF", 1000000) {
    
    function transferReward(address recipient, uint256 amount)
    public
    returns (bool)
    {
        _transferReward(recipient, amount);
        return true;
    }

    function setPoolRewardAddress(address poolRewardAddress)
    public
    onlyOwner 
    returns (bool)
    {
        _setPoolRewardAddress(poolRewardAddress);
        return true;
    }
    
    function setRacerAddress(address contractAddress)
    public
    onlyOwner 
    returns (bool)
    {
        _setRacerAddress(contractAddress);
        return true;
    }
    
    function setCrowdAddress(address contractAddress)
    public
    onlyOwner 
    returns (bool)
    {
        _setCrowdAddress(contractAddress);
        return true;
    }
    
    function purchase(address recipient, uint256 amount)
    public
    returns (bool)
    {
        _purchase(recipient, amount);
        return true;
    }
    
    function setTransferable(uint8 _value) public 
    onlyOwner 
    virtual {
        _setTransferable(_value);
    }
}

// SPDX-License-Identifier: UNLICENSED