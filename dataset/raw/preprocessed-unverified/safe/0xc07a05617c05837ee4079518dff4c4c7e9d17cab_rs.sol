/**
 *Submitted for verification at Etherscan.io on 2020-06-10
*/

pragma solidity ^0.5.16;

// **INTERFACES**

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */








// DfWallet - logic of user's wallet for cTokens
contract DfWallet {

    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;

    // address public constant DF_FINANCE_OPEN = address(0xBA3EEeb0cf1584eE565F34fCaBa74d3e73268c0b);  // TODO: DfFinanceCompound address
    address public constant DF_FINANCE_OPEN = address(0x7eF7eBf6c5DA51A95109f31063B74ECf269b22bE);  // TODO: DfFinanceCompound address

    address public dfFinanceClose;

    // **MODIFIERS**

    modifier authUpgrade {
        require(dfFinanceClose == address(0) || msg.sender == dfFinanceClose, "Permission denied");
        _;
    }

    modifier authDeposit {
        require(msg.sender == DF_FINANCE_OPEN || msg.sender == dfFinanceClose, "Permission denied");
        _;
    }

    modifier authWithdraw {
        require(msg.sender == dfFinanceClose, "Permission denied");
        _;
    }

    // **PUBLIC SET function**

    function setDfFinanceClose(address _dfFinanceClose) public authUpgrade {
        require(_dfFinanceClose != address(0), "Address dfFinanceClose must not be zero");
        dfFinanceClose = _dfFinanceClose;
    }

    // **PUBLIC PAYABLE functions**

    // Example: _collToken = Eth, _borrowToken = USDC
    function deposit(
        address _collToken, address _cCollToken, uint _collAmount, address _borrowToken, address _cBorrowToken, uint _borrowAmount
    ) public payable authDeposit {
        // add _cCollToken to market
        enterMarketInternal(_cCollToken);

        // mint _cCollToken
        mintInternal(_collToken, _cCollToken, _collAmount);

        // borrow and withdraw _borrowToken
        if (_borrowToken != address(0)) {
            borrowInternal(_borrowToken, _cBorrowToken, _borrowAmount);
        }
    }

    // Example: _collToken = Eth, _borrowToken = USDC
    function withdraw(
        address _collToken, address _cCollToken, address _borrowToken, address _cBorrowToken
    ) public payable authWithdraw {
        // repayBorrow _cBorrowToken
        paybackInternal(_borrowToken, _cBorrowToken);

        // redeem _cCollToken
        redeemInternal(_collToken, _cCollToken);
    }

    // **INTERNAL functions**

    function approveCTokenInternal(address _tokenAddr, address _cTokenAddr) internal {
        if (_tokenAddr != ETH_ADDRESS) {
            if (IERC20(_tokenAddr).allowance(address(this), address(_cTokenAddr)) != uint256(-1)) {
                IERC20(_tokenAddr).approve(_cTokenAddr, uint(-1));
            }
        }
    }

    function enterMarketInternal(address _cTokenAddr) internal {
        address[] memory markets = new address[](1);
        markets[0] = _cTokenAddr;

        IComptroller(COMPTROLLER).enterMarkets(markets);
    }

    function mintInternal(address _tokenAddr, address _cTokenAddr, uint _amount) internal {
        // approve _cTokenAddr to pull the _tokenAddr tokens
        approveCTokenInternal(_tokenAddr, _cTokenAddr);

        if (_tokenAddr != ETH_ADDRESS) {
            require(ICToken(_cTokenAddr).mint(_amount) == 0);
        } else {
            ICEther(_cTokenAddr).mint.value(msg.value)(); // reverts on fail
        }
    }

    function borrowInternal(address _tokenAddr, address _cTokenAddr, uint _amount) internal {
        require(ICToken(_cTokenAddr).borrow(_amount) == 0);

        // withdraw funds to msg.sender (DfFinance contract)
        if (_tokenAddr != ETH_ADDRESS) {
            IERC20(_tokenAddr).transfer(msg.sender, IERC20(_tokenAddr).balanceOf(address(this)));
        } else {
            transferEthInternal(msg.sender, address(this).balance);
        }
    }

    function paybackInternal(address _tokenAddr, address _cTokenAddr) internal {
        // approve _cTokenAddr to pull the _tokenAddr tokens
        approveCTokenInternal(_tokenAddr, _cTokenAddr);

        if (_tokenAddr != ETH_ADDRESS) {
            uint amount = ICToken(_cTokenAddr).borrowBalanceCurrent(address(this));

            IERC20(_tokenAddr).transferFrom(msg.sender, address(this), amount);
            require(ICToken(_cTokenAddr).repayBorrow(amount) == 0);
        } else {
            ICEther(_cTokenAddr).repayBorrow.value(msg.value)();
            if (address(this).balance > 0) {
                transferEthInternal(msg.sender, address(this).balance);  // send back the extra eth
            }
        }
    }

    function redeemInternal(address _tokenAddr, address _cTokenAddr) internal {
        // converts all _cTokenAddr into the underlying asset (_tokenAddr)
        require(ICToken(_cTokenAddr).redeem(IERC20(_cTokenAddr).balanceOf(address(this))) == 0);

        // withdraw funds to msg.sender
        if (_tokenAddr != ETH_ADDRESS) {
            IERC20(_tokenAddr).transfer(msg.sender, IERC20(_tokenAddr).balanceOf(address(this)));
        } else {
            transferEthInternal(msg.sender, address(this).balance);
        }
    }

    function transferEthInternal(address _receiver, uint _amount) internal {
        address payable receiverPayable = address(uint160(_receiver));
        (bool result, ) = receiverPayable.call.value(_amount)("");
        require(result, "Transfer of ETH failed");
    }

    // **FALLBACK functions**
    function() external payable {}

}