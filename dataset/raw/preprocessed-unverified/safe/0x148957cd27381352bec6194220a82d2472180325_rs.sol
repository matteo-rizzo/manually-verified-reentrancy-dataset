/**
 *Submitted for verification at Etherscan.io on 2021-06-03
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;



// Part: IERC3156FlashBorrower



// Part: ILendingPool



// Part: ILendingPoolAddressesProvider



// Part: ITipJar



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


// Part: OpenZeppelin/[email protected]/SafeMath

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


// Part: Uni



// Part: IERC3156FlashLender



// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: DeathGod.sol

contract DeathGod is IERC3156FlashBorrower {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    enum Action {NORMAL, OTHER}

    address public governance;
    mapping(address => bool) keepers;
    address public darkParadise;
    address public constant uni =
        address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public constant weth =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant sdt =
        address(0x73968b9a57c6E53d41345FD57a6E6ae27d6CDB2F);
    address public lendingPoolAddressProvider =
        address(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5);

    IERC3156FlashLender lender;
    ITipJar public tipJar;

    modifier onlyGovernance() {
        require(msg.sender == governance, "!governance");
        _;
    }

    function() external payable {}

    constructor(
        address _keeper,
        address _darkParadise,
        IERC3156FlashLender _lender,
        address _tipJar
    ) public {
        governance = msg.sender;
        keepers[_keeper] = true;
        darkParadise = _darkParadise;
        lender = _lender;
        tipJar = ITipJar(_tipJar);
    }

    function setAaveLendingPoolAddressProvider(
        address _lendingPoolAddressProvider
    ) external onlyGovernance {
        lendingPoolAddressProvider = _lendingPoolAddressProvider;
    }

    function setLender(IERC3156FlashLender _lender) external onlyGovernance {
        lender = _lender;
    }

    function setTipJar(address _tipJar) external onlyGovernance {
        tipJar = ITipJar(_tipJar);
    }

    function setDarkParadise(address _darkParadise) external onlyGovernance {
        darkParadise = _darkParadise;
    }

    function setGovernance(address _governance) external onlyGovernance {
        governance = _governance;
    }

    function addKeeper(address _keeper) external onlyGovernance {
        keepers[_keeper] = true;
    }

    function removeKeeper(address _keeper) external onlyGovernance {
        keepers[_keeper] = false;
    }

    function sendSDTToDarkParadise(address _token, uint256 _amount)
        public
        payable
    {
        require(
            msg.sender == governance || keepers[msg.sender] == true,
            "Not authorised"
        );
        require(msg.value > 0, "tip amount must be > 0");
        require(
            _amount <= IERC20(_token).balanceOf(address(this)),
            "Not enough tokens"
        );
        // pay tip in ETH to miner
        tipJar.tip.value(msg.value)();

        IERC20(_token).safeApprove(uni, _amount);
        address[] memory path = new address[](3);
        path[0] = _token;
        path[1] = weth;
        path[2] = sdt;

        uint256 _sdtBefore = IERC20(sdt).balanceOf(address(this));
        Uni(uni).swapExactTokensForTokens(
            _amount,
            uint256(0),
            path,
            address(this),
            now.add(1800)
        );
        uint256 _sdtAfter = IERC20(sdt).balanceOf(address(this));

        IERC20(sdt).safeTransfer(darkParadise, _sdtAfter.sub(_sdtBefore));
    }

    // _minerTipPct: 2500 for 25% of liquidation profits
    function liquidateOnAave(
        address _collateralAsset,
        address _debtAsset,
        address _user,
        uint256 _debtToCover,
        bool _receiveaToken,
        uint256 _minerTipPct
    ) public payable {
        require(keepers[msg.sender] == true, "Not a keeper");
        // taking flash-loan
        flashBorrow(_debtAsset, _debtToCover);

        ILendingPool lendingPool =
            ILendingPool(
                ILendingPoolAddressesProvider(lendingPoolAddressProvider)
                    .getLendingPool()
            );
        require(
            IERC20(_debtAsset).approve(address(lendingPool), _debtToCover),
            "Approval error"
        );

        // uint256 _ethBefore = address(this).balance;
        uint256 collateralBefore =
            IERC20(_collateralAsset).balanceOf(address(this));
        // Calling liquidate() on AAVE. Assumes this contract already has `_debtToCover` amount of `_debtAsset`
        lendingPool.liquidationCall(
            _collateralAsset,
            _debtAsset,
            _user,
            _debtToCover,
            _receiveaToken
        );
        uint256 collateralAfter =
            IERC20(_collateralAsset).balanceOf(address(this));
        // uint256 _ethAfter = address(this).balance;

        // Swapping ETH to USDC
        IERC20(_collateralAsset).safeApprove(
            uni,
            collateralAfter.sub(collateralBefore)
        );
        address[] memory path = new address[](2);
        path[0] = _collateralAsset;
        path[1] = _debtAsset;

        uint256 _debtAssetBefore = IERC20(_debtAsset).balanceOf(address(this));
        Uni(uni).swapExactETHForTokens(
            collateralAfter.sub(collateralBefore),
            uint256(0),
            path,
            address(this),
            now.add(1800)
        );
        uint256 _debtAssetAfter = IERC20(_debtAsset).balanceOf(address(this));

        // liquidation profit = Net USDC later - FlashLoaned USDC - FlashFee
        uint256 profit =
            _debtAssetAfter.sub(_debtAssetBefore).sub(_debtToCover).sub(
                lender.flashFee(_debtAsset, _debtToCover)
            );
        // _minerTipPct % of liquidation profit to miner
        tipMinerInToken(
            _debtAsset,
            profit.mul(_minerTipPct).div(10000),
            _collateralAsset
        );
    }

    function tipMinerInToken(
        address _tipToken,
        uint256 _tipAmount,
        address _collateralAsset
    ) private {
        // swapping miner's profit USDC to ETH
        IERC20(_tipToken).safeApprove(uni, _tipAmount);
        address[] memory path = new address[](2);
        path[0] = _tipToken;
        path[1] = _collateralAsset;

        uint256 _ethBefore = address(this).balance;
        Uni(uni).swapExactTokensForETH(
            _tipAmount,
            uint256(0),
            path,
            address(this),
            now.add(1800)
        );
        uint256 _ethAfter = address(this).balance;
        // sending tip in ETH to miner
        tipJar.tip.value(_ethAfter.sub(_ethBefore))();
    }

    /// @dev Initiate a flash loan
    function flashBorrow(address _token, uint256 _amount) private {
        bytes memory data = abi.encode(Action.NORMAL);
        uint256 _allowance =
            IERC20(_token).allowance(address(this), address(lender));
        uint256 _fee = lender.flashFee(_token, _amount);
        uint256 _repayment = _amount + _fee;
        IERC20(_token).approve(address(lender), _allowance + _repayment);
        lender.flashLoan(this, _token, _amount, data);
    }

    /// @dev ERC-3156 Flash loan callback
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        require(
            msg.sender == address(lender),
            "FlashBorrower: Untrusted lender"
        );
        require(
            initiator == address(this),
            "FlashBorrower: Untrusted loan initiator"
        );
        Action action = abi.decode(data, (Action));
        if (action == Action.NORMAL) {
            // do one thing
        } else if (action == Action.OTHER) {
            // do another
        }
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}