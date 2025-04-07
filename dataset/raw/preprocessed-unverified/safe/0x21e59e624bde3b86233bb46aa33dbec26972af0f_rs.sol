/**
 *Submitted for verification at Etherscan.io on 2020-06-13
*/

pragma solidity 0.5.10;







contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}





contract SimbaStorageToken is ERC20, Ownable {

    string private _name = "SIMBA Storage Token";
    string private _symbol = "SST";
    uint8 private _decimals = 18;

    address private boss = 0x96f9ED1C9555060da2A04b6250154C9941c1BA5a;
    address private admin = 0x0D968ab967290731c75204A9713856f9954dfEc4;

    mapping (address => uint256) freezed;

    modifier notFreezed(address account) {
        require(block.timestamp >= freezed[account]);
        _;
    }

    modifier onlyOwnerAndBoss() {
        require(msg.sender == owner() || msg.sender == boss);
        _;
    }

    uint256 internal INITIAL_SUPPLY = 100000000  * (10 ** 18);

    constructor(address recipient) public {

        _mint(recipient, INITIAL_SUPPLY);

    }

    function _transfer(address sender, address recipient, uint256 amount) internal notFreezed(sender) {
        super._transfer(sender, recipient, amount);
    }

    function _freeze(address account, uint256 period) internal {
        require(account != address(0));
        freezed[account] = block.timestamp.add(period);
        emit OnFreezed(msg.sender, account, period, block.timestamp);
    }

    function freeze(address[] memory accounts, uint256[] memory periods) public onlyOwnerAndBoss {
        for (uint256 i = 0; i < accounts.length; i++) {
            _freeze(accounts[i], periods[i]);
        }
    }

    function freezeAndTransfer(address recipient, uint256 amount, uint256 period) public {
        require(msg.sender == boss || msg.sender == admin);

        _freeze(recipient, period);
        transfer(recipient, amount);
    }

    function deputeBoss(address newBoss) public onlyOwnerAndBoss {
        require(newBoss != address(0));
        emit OnBossDeputed(boss, newBoss, block.timestamp);
        boss = newBoss;
    }

    function deputeAdmin(address newAdmin) public onlyOwnerAndBoss {
        require(newAdmin != address(0));
        emit OnAdminDeputed(admin, newAdmin, block.timestamp);
        admin = newAdmin;
    }

    function approveAndCall(address spender, uint256 amount, bytes calldata extraData) external returns (bool) {
        require(approve(spender, amount));

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, amount, address(this), extraData);

        return true;
    }

    function withdrawERC20(address ERC20Token, address recipient) external {
        require(msg.sender == boss || msg.sender == admin);

        uint256 amount = IERC20(ERC20Token).balanceOf(address(this));
        require(amount > 0);
        IERC20(ERC20Token).transfer(recipient, amount);

    }

    function setName(string memory newName, string memory newSymbol) public onlyOwner {
        emit OnNameSet(_name, _symbol, newName, newSymbol, now);

        _name = newName;
        _symbol = newSymbol;
    }

    function releaseDate(address account) public view returns(uint256) {
        return freezed[account];
    }

    event OnFreezed (
        address indexed sender,
        address indexed account,
        uint256 period,
        uint256 timestamp
    );

    event OnBossDeputed (
        address indexed former,
        address indexed current,
        uint256 timestamp
    );

    event OnAdminDeputed (
        address indexed former,
        address indexed current,
        uint256 timestamp
    );

    event OnNameSet (
        string oldName,
        string oldSymbol,
        string newName,
        string newSymbol,
        uint256 timestamp
    );

}