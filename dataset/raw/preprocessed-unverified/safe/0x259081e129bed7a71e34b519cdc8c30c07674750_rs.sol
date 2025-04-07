pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract addressKeeper is Ownable {
    address public tokenAddress;
    address public boardAddress;
    address public teamAddress;
    function setTokenAdd(address addr) onlyOwner public {
        tokenAddress = addr;
    }
    function setBoardAdd(address addr) onlyOwner public {
        boardAddress = addr;
    }
    function setTeamAdd(address addr) onlyOwner public {
        teamAddress = addr;
    }
}

contract MoatFund is addressKeeper {

    // wei per MTC
    // 1 ETH = 5000 MTC
    // 1 MTC = 200000000000000 wei
    uint256 public mtcRate; // in wei
    bool public mintBool;
    uint256 public minInvest; // minimum investment in wei

    uint256 public redeemRate;     // When redeeming, 1MTC=fixed ETH
    bool public redeemBool;

    uint256 public ethRaised;       // ETH deposited in owner's address
    uint256 public ethRedeemed;     // ETH transferred from owner's address

    // function to start minting MTC
    function startMint(uint256 _rate, bool canMint, uint256 _minWeiInvest) onlyOwner public {
        minInvest = _minWeiInvest;
        mtcRate = _rate;
        mintBool = canMint;
    }

    // function to redeem ETH from MTC
    function startRedeem(uint256 _rate, bool canRedeem) onlyOwner public {
        redeemRate = _rate;
        redeemBool = canRedeem;
    }

    function () public payable {
        transferToken();
    }

    // function called from MoatFund.sol
    function transferToken() public payable {
        if (msg.sender != owner &&
            msg.sender != tokenAddress &&
            msg.sender != boardAddress) {
                require(mintBool);
                require(msg.value >= minInvest);

                uint256 MTCToken = (msg.value / mtcRate);
                uint256 teamToken = (MTCToken / 20);

                ethRaised += msg.value;

                token tokenTransfer = token(tokenAddress);
                tokenTransfer.transfer(msg.sender, MTCToken);
                tokenTransfer.transfer(teamAddress, teamToken);
        }
    }

    // calculate value of MTC that can be redeemed from the ETH
    function redeem(uint256 _mtcTokens) public {
        if (msg.sender != owner) {
            require(redeemBool);

            token tokenBalance = token(tokenAddress);
            tokenBalance.redeemToken(_mtcTokens, msg.sender);

            uint256 weiVal = (_mtcTokens * redeemRate);
            ethRedeemed += weiVal;                                  // adds the value of transferred ETH to the redeemed ETH till now
            // it need to stay last for reentery attack purpose
            msg.sender.transfer(weiVal);                            // transfer the amount of ETH
        }
    }

    function sendETHtoBoard(uint _wei) onlyOwner public {
        boardAddress.transfer(_wei);
    }

    function collectERC20(address tokenAddress, uint256 amount) onlyOwner public {
        token tokenTransfer = token(tokenAddress);
        tokenTransfer.transfer(owner, amount);
    }

}