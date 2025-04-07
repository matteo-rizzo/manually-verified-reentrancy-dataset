/**
 *Submitted for verification at Etherscan.io on 2020-12-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;





interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}









contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract WETH9 {
    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  _balances;
    mapping (address => mapping (address => uint))  public  allowance;

    // fallback() external payable {
    //     deposit();
    // }

    function deposit() public payable {
        _balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint wad) public {
        require(_balances[msg.sender] >= wad, "");
        _balances[msg.sender] -= wad;
        msg.sender.transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    // function mint(address to, uint256 amount) public {
    //     _balances[to] += amount;
    // }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(_balances[src] >= wad, "");

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "");
            allowance[src][msg.sender] -= wad;
        }

        _balances[src] -= wad;
        _balances[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}

contract InstaStakeContract is Ownable {

    IUniswapV2Router02 public iUniswapV2Router02;
    IUniswapV2Factory public iUniswapV2factory;
    IUniswapV2Pair public iUniswapV2Pair;
    WETH9 public wethContract;
    address payable weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    using SafeMath for uint256;
    bool public isFastStaking = true;

    constructor(WETH9 _weth) public {
        wethContract = _weth;
        iUniswapV2Router02 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        iUniswapV2factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    }
    
    receive() external payable {
    }
    
    modifier isFastStakingEnable {
        require(isFastStaking == true);
        _;
    }

    function deposit(address _token, address[] memory _path) public payable isFastStakingEnable {
        wethContract.deposit{value : msg.value}();
        IERC20(weth).approve(address(iUniswapV2Router02), uint(-1));
        uint256[] memory amounts = iUniswapV2Router02.swapExactTokensForTokens(
            msg.value.div(2),
            0,
            _path,
            address(this),
            block.timestamp.add(3600)
        );
        address pair = iUniswapV2factory.getPair(weth, _token);
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(pair).getReserves();
        uint256 amountOut;
        if(IUniswapV2Pair(pair).token0() != address(weth)) {
            amountOut = UniswapV2Library.getAmountOut(amounts[1], reserve0, reserve1);
        } else {
            amountOut = UniswapV2Library.getAmountOut(amounts[1], reserve1, reserve0);
        }
        
        IERC20(weth).approve(address(iUniswapV2Router02), amountOut);
        IERC20(_token).approve(address(iUniswapV2Router02), amounts[1]);
        iUniswapV2Router02.addLiquidity(weth, _token, amountOut, amounts[1], 0, 0, msg.sender, block.timestamp.add(3600));
    }
    
    function setFastStakingEnable(bool _isFastStaking) public onlyOwner {
        isFastStaking = _isFastStaking;
    }
    
    function getExtras(address _token) public onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }
    
    function getExtrasEth() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
}