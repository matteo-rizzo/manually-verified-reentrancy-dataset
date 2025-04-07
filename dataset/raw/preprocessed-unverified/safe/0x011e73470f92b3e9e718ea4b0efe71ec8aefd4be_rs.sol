/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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




// Long live and prosper...
contract DexnesPresaleAndLiquidityLock {

    using SafeMath for uint256;

    IUniswapV2Router02 internal constant UNISWAP = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    struct WhitelistInfo {
        uint256 whitelisted;
        uint256 boughtAmount;
    }

    uint256 public startTimestamp = 1605535200; // 11/16/2020 @ 2:00pm (UTC)
    uint256 public endTimestamp = startTimestamp.add(1 days); // ends after a day
    uint256 public lockDuration = 31 days; // liquidity locked for 31 days

    IERC20 public dnesToken = IERC20(address(0xD1706eAf3C60b69942F29b683D857e01428c459F)); // dexnes token
    address public dexnesCaptain = address(0xA34757fC1e8EAD538C4ef2Ef23286517A7a9d0a7); // staking contract

    uint256 public locked;
    uint256 public unlockTimestamp;

    uint256 public maxAllowed = 3 ether;
    uint256 public liquidityPercentage = 75;
    uint256 public weiRaised;

    address[] internal buyers;
    mapping(address => WhitelistInfo) public whitelist;

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function addToWhitelist(address[100] calldata _addresses) public {
        require(msg.sender == owner, "Caller is not owner");

        for (uint i = 0; i < _addresses.length; i++) {
            address addy = _addresses[i];
            if (addy != address(0)) {
                whitelist[addy] = WhitelistInfo(1, 0);
            }
        }
    }

    function unlockLiquidity(IERC20 _uniLpToken) public {
        require(locked == 1, "Liquidity is not yet locked");
        require(isClosed(), "Liqudity cannot be unlocked as the presale is not yet closed");
        require(block.timestamp >= unlockTimestamp, "Liqudity cannot be unlocked as the block timestamp is before the unlock timestamp");

        _uniLpToken.transfer(owner, _uniLpToken.balanceOf(address(this)));
    }

    // adds liquidity to uniswap (ratio is 1.5 eth = 1 dnes)
    // 75% of the raised eth will be put into liquidity pool
    // 25% of the raised eth will be used for marketing
    // unsold tokens will be sent to the mining pool
    function lockLiquidity() public {
        require(locked == 0, "Liquidity is already locked");
        require(isClosed(), "Presale is either still open or not yet opened");

        locked = 1;
        unlockTimestamp = block.timestamp.add(lockDuration);

        addLiquidity();
        distributeTokensToBuyers();

        payable(owner).transfer(address(this).balance);

        dnesToken.transfer(dexnesCaptain, dnesToken.balanceOf(address(this)));
    }

    function addLiquidity() internal {
        uint256 ethForLiquidity = weiRaised.mul(liquidityPercentage).div(100);
        uint256 tokenForLiquidity = ethForLiquidity.div(150).mul(100);

        dnesToken.approve(address(UNISWAP), tokenForLiquidity);

        UNISWAP.addLiquidityETH
        {value : ethForLiquidity}
        (
            address(dnesToken),
            tokenForLiquidity,
            0,
            0,
            address(this),
            block.timestamp + 100000000
        );
    }

    function distributeTokensToBuyers() internal {
        for (uint i = 0; i < buyers.length; i++) {
            address buyer = buyers[i];
            uint256 tokens = whitelist[buyer].boughtAmount;

            if (tokens > 0) {
                dnesToken.transfer(buyer, tokens);
            }
        }
    }

    function isOpen() public view returns (bool) {
        return !isClosed() && block.timestamp >= startTimestamp;
    }

    function isClosed() public view returns (bool) {
        return block.timestamp >= endTimestamp;
    }

    function buyTokens() payable public {
        require(isOpen(), "Presale is either already closed or not yet open");
        require(whitelist[msg.sender].whitelisted == 1, "Address is not included in the whitelist");
        require(dnesToken.balanceOf(address(this)) >= msg.value, "Contract does not have enough token balance");

        uint256 boughtAmount = whitelist[msg.sender].boughtAmount.add(msg.value);
        require(boughtAmount <= maxAllowed, "Whitelisted address can only buy a maximum of 3 ether");

        buyers.push(msg.sender);
        whitelist[msg.sender].boughtAmount = boughtAmount;
        weiRaised = weiRaised.add(msg.value);

        dnesToken.transfer(msg.sender, msg.value);
    }

    receive() external payable {
        buyTokens();
    }
}