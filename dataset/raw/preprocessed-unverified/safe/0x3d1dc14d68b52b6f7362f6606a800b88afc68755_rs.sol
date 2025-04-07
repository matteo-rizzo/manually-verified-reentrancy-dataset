/**
 *Submitted for verification at Etherscan.io on 2020-11-23
*/

// SPDX-License-Identifier: MIT
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&/                   ,&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&%*,,,,,,,,,,,,,,,,,,,*&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&(,..................#&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*,,                 .%&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*,,                 .%&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#,                 .%&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#,                 .%&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#,                 ,%&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#,... .............,&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#,.................,&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#,.................,&&&&&&&&&&&&&
// &&&&&&&&&&&&&#*,,......                ......,*(#(///////////////#%&&&&&&&&&&&&&
// &&&&&&&&&&&&%*,,..                            .,*(,,,,,,,,*#&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&/**,,,,..........................,,*/,,,,.,%&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&/****,,,,....................,,,,*/,,...,%&&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&#//****,,,,,,,,,,,,,,,,,,,,,,,**/,,,,,,*&&&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&#(////*****,,,,,,,,,,,,****/*,,,,,,,*&&&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&%(////**************//,,,,,,,,,,*&&&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&%/**,,...........,**,..........,&&&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&#**,.           .,**,.......   .%&&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&/,..            ..**,......     (&&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&%*,.             ..**....        .%&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&(,,.             ..**.            /&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&/,..             .,**.            .%&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&%(/*,,,,...,,,,,,,*(#%%%%%%%%%%%%%%&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}







contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
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
    view
    virtual
    override
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

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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

contract AdminContract is Ownable {
    mapping(address => bool) public governanceContracts;

    event GovernanceContractAdded(address addr);
    event GovernanceContractRemoved(address addr);

    modifier onlyGovernance() {
        require(governanceContracts[msg.sender], "Isn't governance address");
        _;
    }

    function addAddress(address addr) public onlyOwner returns (bool success) {
        if (!governanceContracts[addr]) {
            governanceContracts[addr] = true;
            emit GovernanceContractAdded(addr);
            success = true;
        }
    }

    function removeAddress(address addr)
    public
    onlyOwner
    returns (bool success)
    {
        if (governanceContracts[addr]) {
            governanceContracts[addr] = false;
            emit GovernanceContractRemoved(addr);
            success = true;
        }
    }
}

contract PaperToken is ERC20("Paper", "Paper"), AdminContract {
    uint256 private maxSupplyPaper = 69000 * 1e18;

    function mintPaper(address _to, uint256 _amount)
    public
    virtual
    onlyGovernance
    returns (bool)
    {
        require(
            totalSupply().add(_amount) <= maxSupplyPaper,
            "Emission limit exceeded"
        );
        _mint(_to, _amount);
        return true;
    }

    function maxSupply() public view returns (uint256) {
        return maxSupplyPaper;
    }
}



contract FarmContract is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public paperWethLP;
    PaperToken public paper;

    struct Farmer {
        uint256 amount;
        uint256 loss;
    }

    mapping(address => Farmer) public users;

    uint256 public debt;

    event Deposit(address indexed user, uint256 amount);
    event Harvest(address indexed user, uint256 amount);

    constructor(PaperToken _paper, IERC20 _paperLpToken) public {
        paper = _paper;
        paperWethLP = _paperLpToken;
    }

    function deposit(uint256 _amount) public {
        harvest();

        if (paperWethLP.balanceOf(address(this)) > 0) {
            // (paperBalance + debt) * (totalLP + amount) / totalLP - paperBalance
            debt = paper
            .balanceOf(address(this))
            .add(debt)
            .mul(paperWethLP.balanceOf(address(this)).add(_amount))
            .div(paperWethLP.balanceOf(address(this)))
            .sub(paper.balanceOf(address(this)));
        } else {
            debt = 0;
        }

        paperWethLP.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        users[msg.sender].amount = users[msg.sender].amount.add(_amount);

        if (paperWethLP.balanceOf(address(this)) > 0) {
            // (paperBalance + debt) * user.amount / totalLP
            users[msg.sender].loss = paper
            .balanceOf(address(this))
            .add(debt)
            .mul(users[msg.sender].amount)
            .div(paperWethLP.balanceOf(address(this)));
        } else {
            users[msg.sender].loss = 0;
        }
    }

    function withdraw(uint256 _amount) public {
        require(
            paper.totalSupply() == paper.maxSupply(),
            "Withdrawals will be available after PAPER max supply is reached"
        );
        require(
            users[msg.sender].amount >= _amount,
            "You don't have enough LP tokens"
        );
        require(paperWethLP.balanceOf(address(this)) > 0, "No tokens left");

        harvest();
        // (paperBlance + debt) * (totalLP - amount) / totalLP - paperBalance
        debt = paper
        .balanceOf(address(this))
        .add(debt)
        .mul(paperWethLP.balanceOf(address(this)).sub(_amount))
        .div(paperWethLP.balanceOf(address(this)));

        if (debt > paper.balanceOf(address(this))) {
            debt = debt.sub(paper.balanceOf(address(this)));
        } else {
            debt = 0;
        }

        paperWethLP.safeTransfer(address(msg.sender), _amount);

        if (users[msg.sender].amount > _amount) {
            users[msg.sender].amount = users[msg.sender].amount.sub(_amount);
        } else {
            users[msg.sender].amount = 0;
        }

        if (paperWethLP.balanceOf(address(this)) > 0) {
            // (paperBalance + debt) * user.amount / totalLP
            users[msg.sender].loss = paper
            .balanceOf(address(this))
            .add(debt)
            .mul(users[msg.sender].amount)
            .div(paperWethLP.balanceOf(address(this)));
        } else {
            users[msg.sender].loss = 0;
        }
    }

    function harvest() public {
        if (
            !(users[msg.sender].amount > 0 &&
        paperWethLP.balanceOf(address(this)) > 0)
        ) {
            return;
        }
        // (paperBalance + debt) * user.balance / totalLPbalance
        uint256 p =
        paper
        .balanceOf(address(this))
        .add(debt)
        .mul(users[msg.sender].amount)
        .div(paperWethLP.balanceOf(address(this)));

        if (p > users[msg.sender].loss) {
            uint256 pending = p.sub(users[msg.sender].loss);
            paper.transfer(msg.sender, pending);
            debt = debt.add(pending);
            users[msg.sender].loss = p;
        }
    }

    function getPending(address _user) public view returns (uint256) {
        if (
            users[_user].amount > 0 && paperWethLP.balanceOf(address(this)) > 0
        ) {
            // (paperBalance + debt) * user.balance / totalLPbalance - user.loss
            return
            paper
            .balanceOf(address(this))
            .add(debt)
            .mul(users[_user].amount)
            .div(paperWethLP.balanceOf(address(this)))
            .sub(users[_user].loss);
        }
        return 0;
    }

    function getTotalLP() public view returns (uint256) {
        return paperWethLP.balanceOf(address(this));
    }

    function getUser(address _user)
    public
    view
    returns (uint256 balance, uint256 loss)
    {
        balance = users[_user].amount;
        loss = users[_user].loss;
    }
}