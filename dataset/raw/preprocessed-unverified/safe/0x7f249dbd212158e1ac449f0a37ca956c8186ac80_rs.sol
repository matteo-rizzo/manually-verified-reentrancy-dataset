/**
 *Submitted for verification at Etherscan.io on 2020-12-11
*/

// ███████╗░█████╗░██████╗░██████╗░███████╗██████╗░░░░███████╗██╗
// ╚════██║██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗░░░██╔════╝██║
// ░░███╔═╝███████║██████╔╝██████╔╝█████╗░░██████╔╝░░░█████╗░░██║
// ██╔══╝░░██╔══██║██╔═══╝░██╔═══╝░██╔══╝░░██╔══██╗░░░██╔══╝░░██║
// ███████╗██║░░██║██║░░░░░██║░░░░░███████╗██║░░██║██╗██║░░░░░██║
// ╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝░░░░░╚══════╝╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝
// Copyright (C) 2020 zapper

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//

///@author Zapper
///@notice this contract adds liquidity to Balancer liquidity pools in one transaction

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.5.5;









contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
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
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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





contract Balancer_ZapIn_General_V2_6 is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;
    bool public stopped = false;
    uint16 public goodwill;

    IBFactory BalancerFactory = IBFactory(
        0x9424B1412450D0f8Fc2255FAf6046b98213B76Bd
    );

    address payable
        public zgoodwillAddress = 0x3CE37278de6388532C3949ce4e886F365B14fB56;

    event Zapin(address userAddress, address balancerPool, uint256 LPTRec);

    constructor(uint16 _goodwill) public {
        goodwill = _goodwill;
    }

    // circuit breaker modifiers
    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    /**
    @notice This function is used to invest in given balancer pool using ETH/ERC20 Tokens
    @param _FromTokenContractAddress The token used for investment (address(0x00) if ether)
    @param _ToBalancerPoolAddress The address of balancer pool to zapin
    @param _toTokenContractAddress The token with which we are adding liquidity
    @param _amount The amount of ERC to invest
    @param _minPoolTokens for slippage
    @param _allowanceTarget indiacates the spender for swap
    @param _swapTarget indicates the execution target for swap.
    @param swapCallData indicates the callData for execution
    @return quantity of Balancer pool tokens acquired
     */
    function ZapIn(
        address _FromTokenContractAddress,
        address _ToBalancerPoolAddress,
        address _toTokenContractAddress,
        uint256 _amount,
        uint256 _minPoolTokens,
        address _allowanceTarget,
        address _swapTarget,
        bytes calldata swapCallData
    ) external payable nonReentrant stopInEmergency returns (uint256 LPTRec) {
        require(
            BalancerFactory.isBPool(_ToBalancerPoolAddress),
            "Invalid Balancer Pool"
        );

        require(
            IBPool(_ToBalancerPoolAddress).isBound(_toTokenContractAddress),
            "Token not bound"
        );
        uint256 valueToSend;

        if (_FromTokenContractAddress == address(0)) {
            require(msg.value > 0, "ERR: No ETH sent");
            //transfer eth to goodwill
            uint256 goodwillPortion = _transferGoodwill(address(0), msg.value);
            valueToSend = msg.value.sub(goodwillPortion);
        } else {
            require(_amount > 0, "ERR: No ERC sent");
            require(msg.value == 0, "ERR: ETH sent with tokens");

            IERC20(_FromTokenContractAddress).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );

            uint256 goodwillPortion = _transferGoodwill(
                _FromTokenContractAddress,
                _amount
            );
            valueToSend = _amount.sub(goodwillPortion);
        }

        LPTRec = _performZapIn(
            _FromTokenContractAddress,
            _ToBalancerPoolAddress,
            valueToSend,
            _toTokenContractAddress,
            _allowanceTarget,
            _swapTarget,
            swapCallData
        );

        require(LPTRec >= _minPoolTokens, "ERR: High Slippage");

        IERC20(_ToBalancerPoolAddress).safeTransfer(msg.sender, LPTRec);

        emit Zapin(msg.sender, _ToBalancerPoolAddress, LPTRec);

        return LPTRec;
    }

    /**
    @notice This function internally called by ZapIn() and EasyZapIn()
    @param _FromTokenContractAddress The token used for investment (address(0x00) if ether)
    @param _ToBalancerPoolAddress The address of balancer pool to zapin
    @param _amount The amount of ETH/ERC to invest
    @param _toTokenContractAddress The token with which we are adding liquidity
    @return Balancer pool tokens acquired
    **/
    function _performZapIn(
        address _FromTokenContractAddress,
        address _ToBalancerPoolAddress,
        uint256 _amount,
        address _toTokenContractAddress,
        address _allowanceTarget,
        address _swapTarget,
        bytes memory swapCallData
    ) internal returns (uint256 tokensBought) {
        // check if isBound()
        bool isBound = IBPool(_ToBalancerPoolAddress).isBound(
            _FromTokenContractAddress
        );

        uint256 balancerTokens;

        if (isBound) {
            balancerTokens = _enter2Balancer(
                _ToBalancerPoolAddress,
                _FromTokenContractAddress,
                _amount
            );
        } else {
            uint256 tokenBought = _fillQuote(
                _FromTokenContractAddress,
                _toTokenContractAddress,
                _amount,
                _allowanceTarget,
                _swapTarget,
                swapCallData
            );

            //get BPT
            balancerTokens = _enter2Balancer(
                _ToBalancerPoolAddress,
                _toTokenContractAddress,
                tokenBought
            );
        }

        return balancerTokens;
    }

    /**
    @notice this method is used to swap ETH/ERC20<>ERC20/ETH tokens
    @param _fromTokenAddress indicates the ETH/ERC20 token to zapIn with
    @param _bestPoolToken indicates the best pool token to which From tokens to swap
    @param _amount indicates the ETH/ERC20 amount to swap
    @param _allowanceTarget indiacates the spender for swap
    @param _swapTarget indicates the execution target for swap.
    @param swapCallData indicates the callData for execution
    @return amountBought tokens after 0x swap
    */
    function _fillQuote(
        address _fromTokenAddress,
        address _bestPoolToken,
        uint256 _amount,
        address _allowanceTarget,
        address _swapTarget,
        bytes memory swapCallData
    ) internal returns (uint256 amountBought) {
        uint256 valueToSend;

        if (_fromTokenAddress == address(0)) {
            valueToSend = _amount;
        } else {
            IERC20 fromToken = IERC20(_fromTokenAddress);

            require(
                fromToken.balanceOf(address(this)) >= _amount,
                "Insufficient Balance"
            );

            fromToken.safeApprove(address(_allowanceTarget), 0);
            fromToken.safeApprove(address(_allowanceTarget), _amount);
        }

        uint256 initialBalance = IERC20(_bestPoolToken).balanceOf(
            address(this)
        );

        (bool success, ) = _swapTarget.call.value(valueToSend)(swapCallData);
        require(success, "Error Swapping tokens");

        amountBought = IERC20(_bestPoolToken).balanceOf(address(this)).sub(
            initialBalance
        );

        require(amountBought > 0, "Swapped to Invalid Intermediate");
    }

    /**
    @notice This function is used to zapin to balancer pool
    @param _ToBalancerPoolAddress The address of balancer pool to zap in
    @param _FromTokenContractAddress The token used to zap in
    @param tokens2Trade The amount of tokens to invest
    @return The quantity of Balancer Pool tokens returned
     */
    function _enter2Balancer(
        address _ToBalancerPoolAddress,
        address _FromTokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 poolTokensOut) {
        require(
            IBPool(_ToBalancerPoolAddress).isBound(_FromTokenContractAddress),
            "Token not bound"
        );

        uint256 allowance = IERC20(_FromTokenContractAddress).allowance(
            address(this),
            _ToBalancerPoolAddress
        );

        if (allowance < tokens2Trade) {
            IERC20(_FromTokenContractAddress).safeApprove(
                _ToBalancerPoolAddress,
                tokens2Trade
            );
        }

        poolTokensOut = IBPool(_ToBalancerPoolAddress).joinswapExternAmountIn(
            _FromTokenContractAddress,
            tokens2Trade,
            1
        );

        require(poolTokensOut > 0, "Error in entering balancer pool");
    }

    /**
    @notice This function is used to calculate and transfer goodwill
    @param _tokenContractAddress Token in which goodwill is deducted
    @param tokens2Trade The total amount of tokens to be zapped in
    @return The quantity of goodwill deducted
     */

    function _transferGoodwill(
        address _tokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 goodwillPortion) {
        if (goodwill == 0) {
            return 0;
        }
        goodwillPortion = SafeMath.div(
            SafeMath.mul(tokens2Trade, goodwill),
            10000
        );

        if (_tokenContractAddress == address(0)) {
            Address.sendValue(zgoodwillAddress, goodwillPortion);
        } else {
            IERC20(_tokenContractAddress).safeTransfer(
                zgoodwillAddress,
                goodwillPortion
            );
        }
    }

    function set_new_goodwill(uint16 _new_goodwill) public onlyOwner {
        require(
            _new_goodwill >= 0 && _new_goodwill < 10000,
            "GoodWill Value not allowed"
        );
        goodwill = _new_goodwill;
    }

    function set_new_zgoodwillAddress(address payable _new_zgoodwillAddress)
        public
        onlyOwner
    {
        zgoodwillAddress = _new_zgoodwillAddress;
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        IERC20(address(_TokenAddress)).safeTransfer(owner(), qty);
    }

    // - to Pause the contract
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    // - to withdraw any ETH balance sitting in the contract
    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        address payable _to = owner().toPayable();
        _to.transfer(contractBalance);
    }

    function() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}