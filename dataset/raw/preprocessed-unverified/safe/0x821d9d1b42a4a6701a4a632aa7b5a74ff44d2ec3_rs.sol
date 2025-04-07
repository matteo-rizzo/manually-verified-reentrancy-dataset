pragma solidity ^0.5.0;





contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}








contract yycrvVault is Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;
    
    uint256 public fees;   // in bps [var range: 0-10000]
    address public feeAddress;
    
    IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 tusd = IERC20(0x0000000000085d4780B73119b644AE5ecd22b376);
    
    IERC20 ycrv = IERC20(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);
    
    ICurveExchange yCurveExchange = ICurveExchange(0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3);
    
    address yycrv = 0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c;
    
    constructor(address _feeAdr) public {
        approveTokens();
        fees = 30;    // 0.3%
        feeAddress = _feeAdr;
    }
    
    function approveTokens() public {
        dai.safeApprove(address(yCurveExchange), uint256(-1));
        usdc.safeApprove(address(yCurveExchange), uint256(-1));
        usdt.safeApprove(address(yCurveExchange), uint256(-1));
        tusd.safeApprove(address(yCurveExchange), uint256(-1));
        
        ycrv.safeApprove(yycrv, uint256(-1));
        ycrv.safeApprove(address(yCurveExchange), uint256(-1));
    }
    
    // tokens: dai, usdc, usdt, tusd
    function deposit(
        uint256[4] calldata _tokenAmts
    ) external {
        if(_tokenAmts[0] > 0) {
            dai.safeTransferFrom(msg.sender, address(this), _tokenAmts[0]);
        }
        if(_tokenAmts[1] > 0) {
            usdc.safeTransferFrom(msg.sender, address(this), _tokenAmts[1]);
        }
        if(_tokenAmts[2] > 0) {
            usdt.safeTransferFrom(msg.sender, address(this), _tokenAmts[2]);
        }
        if(_tokenAmts[3] > 0) {
            tusd.safeTransferFrom(msg.sender, address(this), _tokenAmts[3]);
        }
        
        yCurveExchange.add_liquidity(
            _tokenAmts,
            0
        );
        uint256 ycrvBought = ycrv.balanceOf(address(this));
        
        uint256 feeAmt = ycrvBought.mul(fees).div(10000);
        ycrv.safeTransfer(
            feeAddress,
            feeAmt
        );
        
        IYVault(yycrv).deposit(ycrvBought.sub(feeAmt));
        uint256 yycrvBought = IERC20(yycrv).balanceOf(address(this));
        
        IERC20(yycrv).safeTransfer(
            msg.sender,
            yycrvBought
        );
    }
    
    // tokenId: 0-3 in order: dai, usdc, usdt, tusd
    function withdraw(
        uint256 _yycrvAmt,
        int128 _tokenId
    ) external {
        IERC20(yycrv).safeTransferFrom(
            msg.sender,
            address(this),
            _yycrvAmt
        );
        
        IYVault(yycrv).withdraw(_yycrvAmt);
        uint256 ycrvReceived = ycrv.balanceOf(address(this));
        
        uint256 feeAmt = ycrvReceived.mul(fees).div(10000);
        ycrv.safeTransfer(
            feeAddress,
            feeAmt
        );
        
        yCurveExchange.remove_liquidity_one_coin(
            ycrvReceived.sub(feeAmt),
            _tokenId,
            0,
            false
        );
        
        uint256 tokenReceived = IERC20(yCurveExchange.underlying_coins(_tokenId)).balanceOf(address(this));
        IERC20(yCurveExchange.underlying_coins(_tokenId)).safeTransfer(
            msg.sender,
            tokenReceived
        );
    }
    
    function updateFees(uint256 _fee) external onlyOwner {
        require(_fee >=0 && _fee < 10000, "Incorrect Fee Amount");
        fees = _fee;
    }
    function updateFeeAddress(address _addr) external onlyOwner {
        require(_addr != address(0), "Invalid Address");
        feeAddress = _addr;
    }
}