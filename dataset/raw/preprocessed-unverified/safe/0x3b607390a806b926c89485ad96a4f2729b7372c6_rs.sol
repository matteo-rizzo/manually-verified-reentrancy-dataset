/**
 *Submitted for verification at Etherscan.io on 2020-12-06
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

contract PaperToken is ERC20("PAPER token", "PAPER"), AdminContract {
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



interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}



contract TokensManager is Ownable {
    using SafeMath for uint256;

    PaperToken public paper;

    uint256 public paperReward = 1e18;
    address internal router;
    

    address public developers;
    address public farmContract;

    uint256 public farmPart = 3; // default param
    uint256 public lpPart = 7; // default param

    uint256 internal approveAmount =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    mapping(address => bool) public approvedTokens;

    event AddNewToken(address token);

    function setApproveAmount(uint256 _newAmount) public onlyOwner {
        approveAmount = _newAmount;
    }

    function swap(
        uint256 _tokenAmount,
        uint256 _minAmount,
        address[] memory _path,
        address _recipient
    ) internal returns (uint256) {
        uint256[] memory amounts_ =
            IUniswapV2Router02(router).swapExactTokensForTokens(
                _tokenAmount,
                _minAmount,
                _path,
                _recipient,
                now + 1200
            );
        return amounts_[amounts_.length - 1];
    }

    function approveToken(address _token) public returns (bool) {
        IERC20(_token).approve(router, approveAmount);
        approvedTokens[_token] = true;
        emit AddNewToken(_token);
        return true;
    }

    function mintToken(address _sender) internal {
        paper.mintPaper(_sender, paperReward);
        paper.mintPaper(developers, paperReward.div(10));
    }

    function transferTokens(address _token, uint256 _tokenAmount) internal {
        IERC20(_token).transferFrom(
            msg.sender,
            address(this),
            _tokenAmount
        );
    }

    function getAmountOut(
        uint256 _tokenAmount,
        address[] memory _path
    ) public view returns (uint256) {
        uint256[] memory amountMinArray =
            IUniswapV2Router02(router).getAmountsOut(_tokenAmount, _path);

        return amountMinArray[amountMinArray.length - 1];
    }

    function setPaperReward(uint256 _newAmount) public onlyOwner {
        paperReward = _newAmount;
    }

    function setLPPart(uint256 _newAmount) public onlyOwner {
        lpPart = _newAmount;
    }

    function setFarmPart(uint256 _newAmount) public onlyOwner {
        farmPart = _newAmount;
    }

    function setFarmContract(address _newContract) public onlyOwner {
        farmContract = _newContract;
    }
}

contract RoundManager is TokensManager {
    uint256 public roundLimit = 1e18;
    uint256 public minBet = 2e17;
    uint256 public roundBalance;
    uint256 public accumulatedBalance;

    struct Bet {
        address player;
        uint256 bet;
    }

    Bet[] public bets;

    mapping(address => uint256) public betsHistory;

    event NewRound(uint256 limit, uint256 paperReward);
    event NewBet(address player, uint256 rate);
    event EndRound(address winner, uint256 prize);

    function setRoundLimit(uint256 _newAmount) public onlyOwner {
        roundLimit = _newAmount;
    }

    function setMinBet(uint256 _newAmount) public onlyOwner {
        minBet = _newAmount;
    }

    function getLastBet(address _player) public view returns (uint256 amount) {
        if (
            betsHistory[_player] < bets.length &&
            bets[betsHistory[_player]].player == _player
        ) {
            amount = bets[betsHistory[_player]].bet;
        }
        return 0;
    }

    function betsLength() public view returns (uint256) {
        return bets.length;
    }
}

contract Random {
    uint256 internal saltForRandom;

    function _rand() internal returns (uint256) {
        // This turns the input data into a 100-sided die
        // by dividing by ceil(2 ^ 256 / 100).
        saltForRandom +=
            (uint256(msg.sender) % 100) +
            uint256(uint256(uint256(blockhash(block.number - 1))) / 1157920892373161954235709850086879078532699846656405640394575840079131296399);

        return saltForRandom;
    }

    function _randRange(uint256 min, uint256 max) internal returns (uint256) {
        return
            (uint256(keccak256(abi.encodePacked(_rand()))) % (max - min + 1)) +
            min;
    }
}

contract Lottery is RoundManager, Random {
    address public immutable WETH;
    address public immutable paperLP;
    address[] public WETH2PAPER;

    constructor(
        address _router,
        address _developers,
        address _WETH,
        PaperToken _paper,
        address _farmContract,
        address _paperLP
    ) public {
        router = _router;
        developers = _developers;
        WETH = _WETH;
        paper = _paper;
        paperLP = _paperLP;
        farmContract = _farmContract;
        WETH2PAPER = new address[](2);
        WETH2PAPER[0] = _WETH;
        WETH2PAPER[1] = address(_paper);
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function makeBet(
        address _token,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address[] memory _path
    ) public {
        require(_path.length > 1 && _path[_path.length - 1] == WETH, "Wrong path");
        require(approvedTokens[_token] == true, "Approve new token first");
        require(_amountOutMin >= minBet, "Your bet is too small");

        transferTokens(_token, _amountIn);
        uint256 _swapWeTH =
            swap(
                _amountIn,
                _amountOutMin,
                _path,
                address(this)
            );

        roundBalance = roundBalance.add(_swapWeTH);
        accumulatedBalance = accumulatedBalance.add(_swapWeTH);
        addNewBet(_swapWeTH);
        mintToken(msg.sender);

        if (roundBalance >= roundLimit) {
            givePrize();
        }
    }

    function addNewBet(uint256 _amountETH) internal {
        betsHistory[msg.sender] = bets.length;
        bets.push(Bet({player: msg.sender, bet: _amountETH}));
        emit NewBet(msg.sender, _amountETH);
    }

    function givePrize() internal {
        uint256 prizeNumber = _randRange(1, roundLimit);
        address payable winner = payable(generateWinner(prizeNumber));

        uint256 userReward = allocatePaper();

        IWETH(WETH).withdraw(userReward);
        winner.transfer(userReward);

        // Clear round
        delete bets;
        roundBalance = 0;

        emit EndRound(winner, userReward);
        emit NewRound(roundLimit, paperReward);
    }

    function generateWinner(uint256 prizeNumber)
        internal
        view
        returns (address winner)
    {
        uint256 a = 0;
        for (uint256 i = 0; i < bets.length; i++) {
            if (prizeNumber > a && prizeNumber <= a.add(bets[i].bet)) {
                winner = bets[i].player;
                break;
            }
            a = a.add(bets[i].bet);
        }
    }

    function getAmountForRedeem(uint256 _amount, uint256 _part)
        internal
        pure
        returns (uint256)
    {
        return (_amount.mul(_part)).div(100);
    }

    function allocatePaper() internal returns (uint256) {
        uint256 amountToLP = getAmountForRedeem(roundBalance, lpPart);
        uint256 amountToFarm = getAmountForRedeem(roundBalance, farmPart);

        uint256 maxReturn =
            getAmountOut(
                amountToLP.add(amountToFarm),
                WETH2PAPER
            );

        if (maxReturn < amountToLP.add(amountToFarm)) {
            uint256 share = maxReturn.div(amountToLP.add(amountToFarm));
            amountToLP = amountToLP.mul(share);
            amountToFarm = amountToFarm.mul(share);
        }

        swap(
            amountToFarm,
            getAmountOut(amountToFarm, WETH2PAPER),
            WETH2PAPER,
            farmContract
        );

        IERC20(WETH).transferFrom(
            address(this),
            paperLP,
            amountToLP
        );
        IUniswapV2Pair(paperLP).sync();
        
        return roundBalance.sub(amountToLP.add(amountToFarm));
    }
}