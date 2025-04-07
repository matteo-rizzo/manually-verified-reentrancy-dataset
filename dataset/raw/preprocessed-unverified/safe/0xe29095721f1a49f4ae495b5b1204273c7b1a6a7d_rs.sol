// ███████╗░█████╗░██████╗░██████╗░███████╗██████╗░░░░███████╗██╗
// ╚════██║██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗░░░██╔════╝██║
// ░░███╔═╝███████║██████╔╝██████╔╝█████╗░░██████╔╝░░░█████╗░░██║
// ██╔══╝░░██╔══██║██╔═══╝░██╔═══╝░██╔══╝░░██╔══██╗░░░██╔══╝░░██║
// ███████╗██║░░██║██║░░░░░██║░░░░░███████╗██║░░██║██╗██║░░░░░██║
// ╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝░░░░░╚══════╝╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝
// Copyright (C) 2020 zapper, nodar, suhail, seb, sumit, apoorv

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
///@notice This contract moves liquidity between UniswapV2 and Balancer pools.

pragma solidity ^0.5.0;





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

















contract Balancer_UniswapV2_Pipe_V1_3 is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;
    bool public stopped = false;

    IUniswapV2Factory
        private constant UniSwapV2FactoryAddress = IUniswapV2Factory(
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    );

    IBalancerZapOut public balancerZapOut;
    IUniswapV2ZapIn public uniswapV2ZapIn;
    IBalancerZapIn public balancerZapIn;
    IUniswapV2ZapOut public uniswapV2ZapOut;

    constructor(
        address _balancerZapIn,
        address _balancerZapOut,
        address _uniswapV2ZapIn,
        address _uniswapV2ZapOut
    ) public {
        balancerZapIn = IBalancerZapIn(_balancerZapIn);
        balancerZapOut = IBalancerZapOut(_balancerZapOut);
        uniswapV2ZapIn = IUniswapV2ZapIn(_uniswapV2ZapIn);
        uniswapV2ZapOut = IUniswapV2ZapOut(_uniswapV2ZapOut);
    }

    // circuit breaker modifiers
    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function PipeBalancerUniV2(
        address _FromBalancerPoolAddress,
        uint256 _IncomingBPT,
        address _toUniswapPoolAddress,
        address _toWhomToIssue,
        uint256 _minUniV2Tokens
    ) public nonReentrant stopInEmergency returns (uint256) {
        // Get BPT
        IERC20(_FromBalancerPoolAddress).transferFrom(
            msg.sender,
            address(this),
            _IncomingBPT
        );
        // Approve BalUnZap
        IERC20(_FromBalancerPoolAddress).approve(
            address(balancerZapOut),
            _IncomingBPT
        );

        // Get pair addresses from UniV2Pair
        address token0 = IUniswapV2Pair(_toUniswapPoolAddress).token0();
        address token1 = IUniswapV2Pair(_toUniswapPoolAddress).token1();

        address zapOutToToken = address(0);
        if (IBPool(_FromBalancerPoolAddress).isBound(token0)) {
            zapOutToToken = token0;
        } else if (IBPool(_FromBalancerPoolAddress).isBound(token1)) {
            zapOutToToken = token1;
        }

        // ZapOut from Balancer
        uint256 zappedOutAmt = balancerZapOut.EasyZapOut(
            zapOutToToken,
            _FromBalancerPoolAddress,
            _IncomingBPT,
            0
        );

        uint256 LPTBought;
        if (zapOutToToken == address(0)) {
            // use ETH to ZapIn to UNIV2
            LPTBought = uniswapV2ZapIn.ZapIn.value(zappedOutAmt)(
                _toWhomToIssue,
                address(0),
                token0,
                token1,
                0,
                _minUniV2Tokens
            );
        } else {
            IERC20(zapOutToToken).approve(
                address(uniswapV2ZapIn),
                IERC20(zapOutToToken).balanceOf(address(this))
            );
            LPTBought = uniswapV2ZapIn.ZapIn.value(0)(
                _toWhomToIssue,
                zapOutToToken,
                token0,
                token1,
                zappedOutAmt,
                _minUniV2Tokens
            );
        }

        return LPTBought;
    }

    function PipeUniV2Balancer(
        address _FromUniswapPoolAddress,
        uint256 _IncomingLPT,
        address _ToBalancerPoolAddress,
        address _toWhomToIssue,
        uint256 _minBPTokens
    ) public nonReentrant stopInEmergency returns (uint256) {
        // Get LPT
        IERC20(_FromUniswapPoolAddress).transferFrom(
            msg.sender,
            address(this),
            _IncomingLPT
        );

        // Approve UniUnZap
        IERC20(_FromUniswapPoolAddress).approve(
            address(uniswapV2ZapOut),
            _IncomingLPT
        );

        // Get pair addresses from UniV2Pair
        address token0 = IUniswapV2Pair(_FromUniswapPoolAddress).token0();
        address token1 = IUniswapV2Pair(_FromUniswapPoolAddress).token1();

        address zapOutToToken = address(0);
        if (IBPool(_ToBalancerPoolAddress).isBound(token0)) {
            zapOutToToken = token0;
        } else if (IBPool(_ToBalancerPoolAddress).isBound(token1)) {
            zapOutToToken = token1;
        }

        // ZapOut from Uni
        uint256 tokensRec = uniswapV2ZapOut.ZapOut(
            zapOutToToken,
            _FromUniswapPoolAddress,
            _IncomingLPT,
            0
        );

        // ZapIn to Balancer
        uint256 BPTBought;
        if (zapOutToToken == address(0)) {
            // use ETH to ZapIn to Balancer
            BPTBought = balancerZapIn.EasyZapIn.value(tokensRec)(
                address(0),
                _ToBalancerPoolAddress,
                0,
                _minBPTokens
            );
        } else {
            IERC20(zapOutToToken).approve(address(balancerZapIn), tokensRec);
            BPTBought = balancerZapIn.EasyZapIn.value(0)(
                zapOutToToken,
                _ToBalancerPoolAddress,
                tokensRec,
                _minBPTokens
            );
        }

        IERC20(_ToBalancerPoolAddress).transfer(_toWhomToIssue, BPTBought);

        return BPTBought;
    }

    // Zap Contract Setters
    function setbalancerZapIn(address _balancerZapIn) public onlyOwner {
        balancerZapIn = IBalancerZapIn(_balancerZapIn);
    }

    function setBalancerZapOut(address _balancerZapOut) public onlyOwner {
        balancerZapOut = IBalancerZapOut(_balancerZapOut);
    }

    function setUniswapV2ZapIn(address _uniswapV2ZapIn) public onlyOwner {
        uniswapV2ZapIn = IUniswapV2ZapIn(_uniswapV2ZapIn);
    }

    function setUniswapV2ZapOut(address _uniswapV2ZapOut) public onlyOwner {
        uniswapV2ZapOut = IUniswapV2ZapOut(_uniswapV2ZapOut);
    }

    // fallback to receive ETH
    function() external payable {}

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.transfer(owner(), qty);
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
}