/**
 *Submitted for verification at Etherscan.io on 2021-08-12
*/

/**
 *Submitted for verification at Etherscan.io on 2021-01-21
 */

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;









abstract contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    string internal _name;

    string internal _symbol;

    uint8 internal _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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
        _transfer(Context._msgSender(), recipient, amount);
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
        _approve(Context._msgSender(), spender, amount);
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
            Context._msgSender(),
            _allowances[sender][Context._msgSender()].sub(
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
            Context._msgSender(),
            spender,
            _allowances[Context._msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            Context._msgSender(),
            spender,
            _allowances[Context._msgSender()][spender].sub(
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

    function _mint(address account_, uint256 ammount_) internal virtual {
        require(account_ != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(this), account_, ammount_);
        _totalSupply = _totalSupply.add(ammount_);
        _balances[account_] = _balances[account_].add(ammount_);
        emit Transfer(address(this), account_, ammount_);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

abstract contract Divine is ERC20, Ownable {
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) ERC20(name_, symbol_, decimals_) {}
}

contract PreAsgardToken is Divine {
    using SafeMath for uint256;

    bool public requireSellerApproval;
    bool public allowMinting;

    mapping(address => bool) public isApprovedSeller;

    constructor(
        address memberOne,
        address memberTwo,
        address memberThree,
        address memberFour,
        address memberFive,
        address memberSix
    ) Divine("PreAsgard", "pASG", 18) {
        requireSellerApproval = true;
        allowMinting = true;
        _addApprovedSeller(address(this));
        _addApprovedSeller(msg.sender);
        _mint(memberOne, 550000000 * 1e18); // DAO
        _mint(memberTwo, 60000000 * 1e18);
        _mint(memberThree, 60000000 * 1e18);
        _mint(memberFour, 30000000 * 1e18);
        _mint(memberFive, 35000000 * 1e18);
        _mint(memberSix, 265000000 * 1e18);
    }

    function allowOpenTrading() external onlyOwner returns (bool) {
        requireSellerApproval = false;
        return requireSellerApproval;
    }

    function disableMinting() external onlyOwner returns (bool) {
        allowMinting = false;
        return allowMinting;
    }

    function _addApprovedSeller(address approvedSeller_) internal {
        isApprovedSeller[approvedSeller_] = true;
    }

    function addApprovedSeller(address approvedSeller_)
        external
        onlyOwner
        returns (bool)
    {
        _addApprovedSeller(approvedSeller_);
        return isApprovedSeller[approvedSeller_];
    }

    function addApprovedSellers(address[] calldata approvedSellers_)
        external
        onlyOwner
        returns (bool)
    {
        for (
            uint256 iteration_;
            approvedSellers_.length > iteration_;
            iteration_++
        ) {
            _addApprovedSeller(approvedSellers_[iteration_]);
        }
        return true;
    }

    function _removeApprovedSeller(address disapprovedSeller_) internal {
        isApprovedSeller[disapprovedSeller_] = false;
    }

    function removeApprovedSeller(address disapprovedSeller_)
        external
        onlyOwner
        returns (bool)
    {
        _removeApprovedSeller(disapprovedSeller_);
        return isApprovedSeller[disapprovedSeller_];
    }

    function removeApprovedSellers(address[] calldata disapprovedSellers_)
        external
        onlyOwner
        returns (bool)
    {
        for (
            uint256 iteration_;
            disapprovedSellers_.length > iteration_;
            iteration_++
        ) {
            _removeApprovedSeller(disapprovedSellers_[iteration_]);
        }
        return true;
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 amount_
    ) internal override {
        require(
            (_balances[to_] > 0 || isApprovedSeller[from_] == true),
            "Account not approved to transfer pASG."
        );
    }

    function mint(address recipient_, uint256 amount_)
        public
        virtual
        onlyOwner
    {
        require(allowMinting, "Minting has been disabled.");
        _mint(recipient_, amount_);
    }

    function burn(uint256 amount_) public virtual {
        _burn(msg.sender, amount_);
    }

    function burnFrom(address account_, uint256 amount_) public virtual {
        _burnFrom(account_, amount_);
    }

    function _burnFrom(address account_, uint256 amount_) internal virtual {
        uint256 decreasedAllowance_ = allowance(account_, msg.sender).sub(
            amount_,
            "ERC20: burn amount exceeds allowance"
        );
        _approve(account_, msg.sender, decreasedAllowance_);
        _burn(account_, amount_);
    }
}