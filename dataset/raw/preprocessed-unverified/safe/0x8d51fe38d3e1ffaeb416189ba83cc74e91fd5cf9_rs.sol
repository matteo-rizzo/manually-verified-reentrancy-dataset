/**
 *Submitted for verification at Etherscan.io on 2021-01-18
*/

// Sources flattened with hardhat v2.0.6 https://hardhat.org

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

// File contracts/uniswapv2/libraries/TransferHelper.sol

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false



// File contracts/uniswapv2/libraries/SafeMath.sol



// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)




// File contracts/uniswapv2/interfaces/IUniswapV2ERC20.sol






// File contracts/uniswapv2/interfaces/IUniswapV2Pair.sol






// File contracts/SushiYieldToken.sol






contract SushiYieldToken {
    using SafeMathUniswap for uint256;
    using TransferHelper for address;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed sender, uint256 amount);
    event Burn(address indexed sender, uint256 amount, address indexed to);

    /**
     * @return address of YieldTokenFactory
     */
    address public factory;
    /**
     * @return address of lp token
     */
    address public lpToken;
    /**
     * @return data to be used when `mint`ing/`burn`ing
     */
    bytes public data;

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "locked");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() public {
        factory = msg.sender;

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function initialize(address _lpToken, bytes memory _data) external {
        require(msg.sender == factory, "forbidden");
        lpToken = _lpToken;
        data = _data;

        IUniswapV2Pair pair = IUniswapV2Pair(lpToken);
        string memory symbol0 = IUniswapV2ERC20(pair.token0()).symbol();
        string memory symbol1 = IUniswapV2ERC20(pair.token1()).symbol();
        name = string(abi.encodePacked(symbol0, "-", symbol1, " SushiSwap Yield Token"));
        symbol = string(abi.encodePacked(symbol0, "-", symbol1, " SYD"));
    }

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint256 value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "expired");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "invalid-signature");
        _approve(owner, spender, value);
    }

    function mint(address to) external lock returns (uint256 amount) {
        amount = IUniswapV2ERC20(lpToken).balanceOf(address(this));
        require(amount > 0, "insufficient-balance");

        (bool success,) = factory.delegatecall(abi.encodeWithSignature("deposit(bytes,uint256,address)", data, amount, to));
        require(success, "failed-to-deposit");

        _mint(to, amount);

        emit Mint(msg.sender, amount);
    }

    function burn(address to) external lock returns (uint256 amount) {
        amount = balanceOf[address(this)];
        require(amount > 0, "insufficient-balance");

        (bool success,) = factory.delegatecall(abi.encodeWithSignature("withdraw(bytes,uint256,address)", data, amount, to));
        require(success, "failed-to-withdraw");

        _burn(address(this), amount);

        emit Burn(msg.sender, amount, to);
    }
}


// File contracts/SousChef.sol








contract SousChef {
    using TransferHelper for address;
    using SafeMathUniswap for uint;

    event Deposited(address yieldToken, uint256 amount, address to);
    event Withdrawn(address yieldToken, uint256 amount, address to);

    address public factory;
    address public weth;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'expired');
        _;
    }

    constructor(address _yieldTokenFactory) public {
        factory = _yieldTokenFactory;
    }

    function depositMultipleWithPermit(
        uint256[] calldata pids,
        uint256[] calldata amounts,
        address to,
        uint256 deadline,
        uint8[] calldata v,
        bytes32[] calldata r,
        bytes32[] calldata s
    ) external ensure(deadline) {
        for (uint256 i = 0; i < pids.length; i++) {
            address yieldToken = _getYieldToken(pids[i]);
            _depositWithPermit(yieldToken, amounts[i], to, deadline, v[i], r[i], s[i]);
        }
    }

    function depositWithPermit(
        uint256 pid,
        uint256 amount,
        address to,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external ensure(deadline) {
        address yieldToken = _getYieldToken(pid);
        _depositWithPermit(yieldToken, amount, to, deadline, v, r, s);
    }

    function _depositWithPermit(
        address yieldToken,
        uint256 amount,
        address to,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        address lpToken = SushiYieldToken(yieldToken).lpToken();
        _permit(lpToken, amount, deadline, v, r, s);
        _deposit(yieldToken, amount, to);
    }

    function deposit(
        uint256 pid,
        uint256 amount,
        address to
    ) external {
        address yieldToken = _getYieldToken(pid);
        _deposit(yieldToken, amount, to);
    }

    function _deposit(
        address yieldToken,
        uint256 amount,
        address to
    ) internal {
        address lpToken = SushiYieldToken(yieldToken).lpToken();
        lpToken.safeTransferFrom(msg.sender, yieldToken, amount);
        SushiYieldToken(yieldToken).mint(to);

        emit Deposited(yieldToken, amount, to);
    }

    function withdrawMultipleWithPermit(
        uint256[] calldata pids,
        uint256[] calldata amounts,
        address to,
        uint256 deadline,
        uint8[] calldata v,
        bytes32[] calldata r,
        bytes32[] calldata s
    ) external ensure(deadline) {
        for (uint256 i = 0; i < pids.length; i++) {
            address yieldToken = _getYieldToken(pids[i]);
            _withdrawWithPermit(yieldToken, amounts[i], to, deadline, v[i], r[i], s[i]);
        }
    }

    function withdrawWithPermit(
        uint256 pid,
        uint256 amount,
        address to,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external ensure(deadline) {
        address yieldToken = _getYieldToken(pid);
        _withdrawWithPermit(yieldToken, amount, to, deadline, v, r, s);
    }

    function _withdrawWithPermit(
        address yieldToken,
        uint256 amount,
        address to,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        _permit(yieldToken, amount, deadline, v, r, s);
        _withdraw(yieldToken, amount, to);
    }

    function withdraw(
        uint256 pid,
        uint256 amount,
        address to
    ) external {
        address yieldToken = _getYieldToken(pid);
        _withdraw(yieldToken, amount, to);
    }

    function _withdraw(
        address yieldToken,
        uint256 amount,
        address to
    ) internal {
        yieldToken.safeTransferFrom(msg.sender, yieldToken, amount);
        SushiYieldToken(yieldToken).burn(to);

        emit Withdrawn(yieldToken, amount, to);
    }

    function _getYieldToken(uint256 pid) internal view returns (address) {
        address yieldToken = IYieldTokenFactory(factory).getYieldToken(pid);
        require(yieldToken != address(0), "invalid-pid");
        return yieldToken;
    }

    function _permit(address token, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) internal {
        IUniswapV2ERC20(token).permit(msg.sender, address(this), amount, deadline, v, r, s);
    }
}