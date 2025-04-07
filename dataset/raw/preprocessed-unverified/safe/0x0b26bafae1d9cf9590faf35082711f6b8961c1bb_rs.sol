/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.7.4;





/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



/**
 * @title Auction
 */

contract Auction {
    using SafeMathLib for uint;

    struct Tranche {
        uint blockIssued;
        uint weiPerToken;
        uint totalTokens;
        uint currentTokens;
    }

    uint256 public poolBalance;
    address public management;
    uint256 public decayPerBlock;
    uint256 public lastTokensPerWei;
    uint256 public priceFloor;
    uint256 public trancheNumber = 1;
    uint256 public totalTokensOffered;
    uint256 public totalTokensSold = 0;

    uint256 public initialPrice = 0;
    uint256 public initialTrancheSize = 0;
    uint256 public minimumPrice = 0;
    uint256 public startBlock = 0;

    bytes32 public siteHash;

    address payable public safeAddress;
    IERC20 public token;
    IUniswapRouter public uniswap;
    Tranche public currentTranche;

    event PurchaseOccurred(address purchaser, uint weiSpent, uint tokensAcquired, uint tokensLeftInTranche, uint weiReturned, uint trancheNumber, uint timestamp);
    event LiquidityPushed(uint amountToken, uint amountETH, uint liquidity);

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'Auction: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier managementOnly() {
        require (msg.sender == management, 'Only management may call this');
        _;
    }

    constructor(address mgmt,
                address tokenAddr,
                address uniswapRouter,
                uint auctionStartBlock,
                uint tokensForSale,
                uint firstTranchePricePerToken,
                uint firstTrancheSize,
                uint initialDecay,
                uint minPrice,
                address payable safeAddr) {
        management = mgmt;
        token = IERC20(tokenAddr);
        uniswap = IUniswapRouter(uniswapRouter);
        startBlock = auctionStartBlock > 0 ? auctionStartBlock : block.number;
        totalTokensOffered = tokensForSale;
        initialPrice = firstTranchePricePerToken;
        initialTrancheSize = firstTrancheSize;
        currentTranche = Tranche(startBlock, firstTranchePricePerToken, firstTrancheSize, firstTrancheSize);
        decayPerBlock = initialDecay;
        safeAddress = safeAddr;
        minimumPrice = minPrice;
    }

    /**
     * @dev default function
     * gas ~
     */
    receive() external payable {
        buy(currentTranche.weiPerToken);
    }

    function withdrawTokens() public managementOnly {
        uint balance = token.balanceOf(address(this));
        token.transfer(management, balance);
    }

    function setSiteHash(bytes32 newHash) public managementOnly {
        siteHash = newHash;
    }

    function pushLiquidity() public managementOnly {
        uint tokenBalance = token.balanceOf(address(this));
        uint minToken = tokenBalance / 2;
        uint ethBalance = address(this).balance;
        uint deadline = block.timestamp + 1 hours;
        token.approve(address(uniswap), tokenBalance);
        // this will take all the eth and refund excess tokens
        (uint amountToken, uint amountETH, uint liquidity) = uniswap.addLiquidityETH{value: ethBalance}(address(token), tokenBalance, minToken, ethBalance, safeAddress, deadline);
        emit LiquidityPushed(amountToken, amountETH, liquidity);
    }

    function getBuyPrice() public view returns (uint) {
        if (block.number < currentTranche.blockIssued) {
            return 0;
        }
        // linear time decay
        uint distanceBlocks = block.number.minus(currentTranche.blockIssued);
        uint decay = decayPerBlock.times(distanceBlocks);
        uint proposedPrice;
        if (currentTranche.weiPerToken < decay.plus(minimumPrice)) {
            proposedPrice = minimumPrice;
        } else {
            proposedPrice = currentTranche.weiPerToken.minus(decay);
        }
        return proposedPrice;
    }

    /**
     * @dev Buy tokens
     * gas ~
     */
    function buy(uint maxPrice) public payable lock {
        require(msg.value > 0, 'Auction: must send ether to buy');
        require(block.number >= startBlock, 'Auction: not started yet');
        // buyPrice = wei / 1e18 tokens
        uint weiPerToken = getBuyPrice();

        require(weiPerToken <= maxPrice, 'Auction: price too high');
        // buyAmount = wei * tokens / wei = tokens
        uint buyAmountTokens = (msg.value * 1 ether) / weiPerToken;
        uint leftOverTokens = 0;
        uint weiReturned = 0;
        uint trancheNumReported = trancheNumber;

        // if they bought more than the tranche has...
        if (buyAmountTokens >= currentTranche.currentTokens) {
            // compute the excess amount of tokens
            uint excessTokens = buyAmountTokens - currentTranche.currentTokens;
            // weiReturned / msg.value = excessTokens / buyAmountTokens
            weiReturned = msg.value.times(excessTokens) / buyAmountTokens;
            // send the excess ether back
            // re-entrance blocked by the lock modifier
            msg.sender.transfer(weiReturned);
            // now they are only buying the remaining
            buyAmountTokens = currentTranche.currentTokens;

            // double the tokens offered
            uint nextTrancheTokens = currentTranche.totalTokens.times(2);
            uint tokensLeftInOffering = totalTokensOffered.minus(totalTokensSold).minus(buyAmountTokens);

            // if we are not offering enough tokens to cover the next tranche doubling, this is the last tranche
            if (nextTrancheTokens > tokensLeftInOffering) {
                nextTrancheTokens = tokensLeftInOffering;
            }

            // double the price per token
            currentTranche.weiPerToken = weiPerToken.times(2);

            // set the new tranche token amounts
            currentTranche.totalTokens = nextTrancheTokens;
            currentTranche.currentTokens = currentTranche.totalTokens;

            // double the decay per block and reset the block issued
            currentTranche.blockIssued = block.number;
            decayPerBlock = decayPerBlock.times(2);

            // increment tranche index
            trancheNumber = trancheNumber.plus(1);

        } else {
            currentTranche.currentTokens = currentTranche.currentTokens.minus(buyAmountTokens);
            leftOverTokens = currentTranche.currentTokens;
        }

        // send the tokens! re-entrance not possible here because of Token design, but will be possible with ERC-777
        token.transfer(msg.sender, buyAmountTokens);

        // bookkeeping: count the tokens sold
        totalTokensSold = totalTokensSold.plus(buyAmountTokens);
        emit PurchaseOccurred(msg.sender, msg.value.minus(weiReturned), buyAmountTokens, leftOverTokens, weiReturned, trancheNumReported, block.timestamp);
    }

}