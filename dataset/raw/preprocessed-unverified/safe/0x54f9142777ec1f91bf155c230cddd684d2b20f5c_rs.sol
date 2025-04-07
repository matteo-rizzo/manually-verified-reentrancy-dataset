/**
 *Submitted for verification at Etherscan.io on 2021-02-15
*/

// SPDX-License-Identifier: unlicensed

pragma solidity ^0.5.12;

contract Context {
    constructor() internal {}

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
    address payable public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address payable msgSender = _msgSender();
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
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address payable newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}





contract ReentrancyGuard {
    bool private _notEntered;

    constructor() internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}















contract CurveAddLiquidity is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    bool public stopped = false; 
    uint16 public goodwill;

    mapping(address => bool) public feeWhitelist;// if true, goodwill is not deducted
    uint16 affiliateSplit; // % share of goodwill (0-100 %)
    mapping(address => bool) public affiliates; // restrict affiliates
    mapping(address => mapping(address => uint256)) public affiliateBalance; // affiliate => token => amount
    mapping(address => uint256) public totalAffiliateBalance; // token => amount
    address private constant ETHAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    ICurveRegistry public curveReg;

    address private Aave = 0xDeBF20617708857ebe4F679508E7b7863a8A8EeE;

    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    constructor(
        ICurveRegistry _curveRegistry,
        uint16 _goodwill,
        uint16 _affiliateSplit
    ) public {
        curveReg = _curveRegistry;
        goodwill = _goodwill;
        affiliateSplit = _affiliateSplit;
    }

    event addLiquidity(address sender, address pool, uint256 crvTokens);

    function AddLiquidity(
        address _fromTokenAddress,
        address _toTokenAddress,
        address _swapAddress,
        uint256 _incomingTokenQty,
        uint256 _minPoolTokens,
        address _swapTarget,
        bytes calldata _swapCallData,
        address affiliate
    )
        external
        payable
        stopInEmergency
        nonReentrant
        returns (uint256 crvTokensBought)
    {
        uint256 toInvest = _pullTokens(
            _fromTokenAddress,
            _incomingTokenQty,
            affiliate
        );
        if (_fromTokenAddress == address(0)) {
            _fromTokenAddress = ETHAddress;
        }

        // perform addLiquidity
        crvTokensBought = _performAddLiquidity(
            _fromTokenAddress,
            _toTokenAddress,
            _swapAddress,
            toInvest,
            _swapTarget,
            _swapCallData
        );

        require(crvTokensBought > _minPoolTokens,"Received less than minPoolTokens");

        address poolTokenAddress = curveReg.getTokenAddress(_swapAddress);

        emit addLiquidity(msg.sender, poolTokenAddress, crvTokensBought);

        // transfer crvTokens to msg.sender
        IERC20(poolTokenAddress).transfer(msg.sender, crvTokensBought);
    }

    function _performAddLiquidity(
        address _fromTokenAddress,
        address _toTokenAddress,
        address _swapAddress,
        uint256 toInvest,
        address _swapTarget,
        bytes memory _swapCallData
    ) internal returns (uint256 crvTokensBought) {
        (bool isUnderlying, uint8 underlyingIndex) = curveReg.isUnderlyingToken(
            _swapAddress,
            _fromTokenAddress
        );

        if (isUnderlying) {
            crvTokensBought = _enterCurve(
                _swapAddress,
                toInvest,
                underlyingIndex
            );
        } else {
            //swap tokens using 0x swap
            uint256 tokensBought = _fillQuote(
                _fromTokenAddress,
                _toTokenAddress,
                toInvest,
                _swapTarget,
                _swapCallData
            );
            if (_toTokenAddress == address(0)) _toTokenAddress = ETHAddress;

            //get underlying token index
            (isUnderlying, underlyingIndex) = curveReg.isUnderlyingToken(
                _swapAddress,
                _toTokenAddress
            );

            if (isUnderlying) {
                crvTokensBought = _enterCurve(
                    _swapAddress,
                    tokensBought,
                    underlyingIndex
                );
            } else {
                (uint256 tokens, uint8 metaIndex) = _enterMetaPool(
                    _swapAddress,
                    _toTokenAddress,
                    tokensBought
                );

                crvTokensBought = _enterCurve(_swapAddress, tokens, metaIndex);
            }
        }
    }

    function _pullTokens(
        address token,
        uint256 amount,
        address affiliate
    ) internal returns (uint256) {
        uint256 totalGoodwillPortion;

        if (token == address(0)) {
            require(msg.value > 0, "No eth sent");

            // subtract goodwill
            totalGoodwillPortion = _subtractGoodwill(
                ETHAddress,
                msg.value,
                affiliate
            );

            return msg.value.sub(totalGoodwillPortion);
        }
        require(amount > 0, "Invalid token amount");
        require(msg.value == 0, "Eth sent with token");

        //transfer token
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        // subtract goodwill
        totalGoodwillPortion = _subtractGoodwill(token, amount, affiliate);

        return amount.sub(totalGoodwillPortion);
    }

    function _subtractGoodwill(
        address token,
        uint256 amount,
        address affiliate
    ) internal returns (uint256 totalGoodwillPortion) {
        bool whitelisted = feeWhitelist[msg.sender];
        if (!whitelisted && goodwill > 0) {
            totalGoodwillPortion = SafeMath.div(SafeMath.mul(amount, goodwill), 10000);

            if (affiliates[affiliate]) {
                uint256 affiliatePortion = totalGoodwillPortion.mul(affiliateSplit).div(100);
                affiliateBalance[affiliate][token] = affiliateBalance[affiliate][token].add(affiliatePortion);
                totalAffiliateBalance[token] = totalAffiliateBalance[token].add(affiliatePortion);  
            }
        }
    }

    function _enterMetaPool(
        address _swapAddress,
        address _toTokenAddress,
        uint256 swapTokens
    ) internal returns (uint256 tokensBought, uint8 index) {
        address[4] memory poolTokens = curveReg.getPoolTokens(_swapAddress);
        for (uint8 i = 0; i < 4; i++) {
            address intermediateSwapAddress = curveReg.metaPools(poolTokens[i]);
            if (intermediateSwapAddress != address(0)) {
                (, index) = curveReg.isUnderlyingToken(
                    intermediateSwapAddress,
                    _toTokenAddress
                );

                tokensBought = _enterCurve(
                    intermediateSwapAddress,
                    swapTokens,
                    index
                );

                return (tokensBought, i);
            }
        }
    }

    function _fillQuote(
        address _fromTokenAddress,
        address _toTokenAddress,
        uint256 _amount,
        address _swapTarget,
        bytes memory _swapCallData
    ) internal returns (uint256 amountBought) {
        uint256 valueToSend;

        if (_fromTokenAddress == _toTokenAddress) {
            return _amount;
        }

        if (_fromTokenAddress == ETHAddress) {
            valueToSend = _amount;
        } else {
            IERC20 fromToken = IERC20(_fromTokenAddress);

            require(fromToken.balanceOf(address(this)) >= _amount, "Insufficient Balance" );

            fromToken.safeApprove(address(_swapTarget), 0);
            fromToken.safeApprove(address(_swapTarget), _amount);
        }

        uint256 initialBalance = _toTokenAddress == address(0)
            ? address(this).balance
            : IERC20(_toTokenAddress).balanceOf(address(this));

        (bool success, ) = _swapTarget.call.value(valueToSend)(_swapCallData);
        require(success, "Error Swapping Tokens");

        amountBought = _toTokenAddress == address(0)
            ? (address(this).balance).sub(initialBalance)
            : IERC20(_toTokenAddress).balanceOf(address(this)).sub(initialBalance);
                

        require(amountBought > 0, "Swapped To Invalid Intermediate");
    }

    function _enterCurve(address _swapAddress, uint256 amount, uint8 index) internal returns (uint256 crvTokensBought) {
        address tokenAddress = curveReg.getTokenAddress(_swapAddress);
        uint256 initialBalance = IERC20(tokenAddress).balanceOf(address(this));
        address entryToken = curveReg.getPoolTokens(_swapAddress)[index];

        if (entryToken != ETHAddress) {
            IERC20(entryToken).safeIncreaseAllowance(address(_swapAddress), amount);
        }

        uint256 numTokens = curveReg.getNumTokens(_swapAddress);

        if (numTokens == 4) {
            uint256[4] memory amounts;
            amounts[index] = amount;
            ICurveSwap(_swapAddress).add_liquidity(amounts, 0);
        } else if (numTokens == 3) {
            uint256[3] memory amounts;
            amounts[index] = amount;
            if (_swapAddress == Aave) {
                ICurveSwap(_swapAddress).add_liquidity(amounts, 0, true);
            } else {
                ICurveSwap(_swapAddress).add_liquidity(amounts, 0);
            }
        } else {
            uint256[2] memory amounts;
            amounts[index] = amount;
            if (isETHUnderlying(_swapAddress)) {
                ICurveEthSwap(_swapAddress).add_liquidity.value(amount)(amounts,0 );
            } else {
                ICurveSwap(_swapAddress).add_liquidity(amounts, 0);
            }
        }
        crvTokensBought = (IERC20(tokenAddress).balanceOf(address(this))).sub(initialBalance);
    }

    function isETHUnderlying(address _swapAddress) internal view returns (bool){
        address[4] memory poolTokens = curveReg.getPoolTokens(_swapAddress);
        for (uint8 i = 0; i < 4; i++) {
            if (poolTokens[i] == ETHAddress) {
                return true;
            }
        }
        return false;
    }

    function updateAaveAddress(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Zero Address");
        Aave = _newAddress;
    }

    function set_new_goodwill(uint16 _new_goodwill) external onlyOwner {
        require(
            _new_goodwill >= 0 && _new_goodwill < 100,
            "GoodWill Value not allowed"
        );
        goodwill = _new_goodwill;
    }

    function set_feeWhitelist(address _address, bool status) external onlyOwner{
        feeWhitelist[_address] = status;
    }

    function updateCurveRegistry(ICurveRegistry newCurveRegistry) external onlyOwner {
        require(newCurveRegistry != curveReg, "Already using this Registry");
        curveReg = newCurveRegistry;
    }

    // - to Pause the contract
    function toggleContractActive() external onlyOwner {
        stopped = !stopped;
    }

    function set_new_affiliateSplit(uint16 _new_affiliateSplit) external onlyOwner {
        require(_new_affiliateSplit <= 100, "Affiliate Split Value not allowed");
        affiliateSplit = _new_affiliateSplit;
    }

    function set_affiliate(address _affiliate, bool _status) external onlyOwner{
        affiliates[_affiliate] = _status;
    }

    ///@notice Withdraw goodwill share, retaining affilliate share
    function ownerWithdraw(address[] calldata tokens) external onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 qty;

            if (tokens[i] == ETHAddress) {
                qty = address(this).balance.sub(totalAffiliateBalance[tokens[i]]);
                Address.sendValue(Address.toPayable(owner()), qty);
            } else {
                qty = IERC20(tokens[i]).balanceOf(address(this)).sub(totalAffiliateBalance[tokens[i]]);
                IERC20(tokens[i]).safeTransfer(owner(), qty);
            }
        }
    }

    ///@notice Withdraw affilliate share, retaining goodwill share
    function affilliateWithdraw(address[] calldata tokens) external {
        uint256 tokenBal;
        for (uint256 i = 0; i < tokens.length; i++) {
            tokenBal = affiliateBalance[msg.sender][tokens[i]];
            affiliateBalance[msg.sender][tokens[i]] = 0;
            totalAffiliateBalance[tokens[i]] = totalAffiliateBalance[tokens[i]].sub(tokenBal);
                
            if (tokens[i] == ETHAddress) {
                Address.sendValue(msg.sender, tokenBal);
            } else {
                IERC20(tokens[i]).safeTransfer(msg.sender, tokenBal);
            }
        }
    }

    function() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}