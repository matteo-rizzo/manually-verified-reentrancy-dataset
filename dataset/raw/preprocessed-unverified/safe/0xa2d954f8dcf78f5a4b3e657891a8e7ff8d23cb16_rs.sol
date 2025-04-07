/**

 *Submitted for verification at Etherscan.io on 2018-10-09

*/



pragma solidity ^0.4.25;







contract SafeMath {

    

    uint256 constant public MAX_UINT256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;



    function safeAdd(uint256 x, uint256 y) pure internal returns (uint256 z) {

        require(x <= MAX_UINT256 - y);

        return x + y;

    }



    function safeSub(uint256 x, uint256 y) pure internal returns (uint256 z) {

        require(x >= y);

        return x - y;

    }



    function safeMul(uint256 x, uint256 y) pure internal returns (uint256 z) {

        if (y == 0) {

            return 0;

        }

        require(x <= (MAX_UINT256 / y));

        return x * y;

    }

}







contract MintingContract is Owned, SafeMath{

    

    address public tokenAddress;

    uint256 public tokensAlreadyMinted;



    enum state { crowdsaleMinting, additionalMinting, disabled}

    state public mintingState; 



    uint256 public crowdsaleMintingCap;

    uint256 public tokenTotalSupply;

    

    constructor() public {

        tokensAlreadyMinted = 0;

        crowdsaleMintingCap = 22000000 * 10 ** 18;

        tokenTotalSupply = 44000000 * 10 ** 18;

    }



    function doCrowdsaleMinting(address _destination, uint _tokensToMint) public onlyOwner {

        require(mintingState == state.crowdsaleMinting);

        require(safeAdd(tokensAlreadyMinted, _tokensToMint) <= crowdsaleMintingCap);



        MintableTokenInterface(tokenAddress).mint(_destination, _tokensToMint);

        tokensAlreadyMinted = safeAdd(tokensAlreadyMinted, _tokensToMint);

    }

    function doAdditionalMinting(address _destination, uint _tokensToMint) public {

        require(mintingState == state.additionalMinting);

        require(safeAdd(tokensAlreadyMinted, _tokensToMint) <= tokenTotalSupply);



        MintableTokenInterface(tokenAddress).mint(_destination, _tokensToMint);

        tokensAlreadyMinted = safeAdd(tokensAlreadyMinted, _tokensToMint);

    }

    

    function finishCrowdsaleMinting() onlyOwner public {

        mintingState = state.additionalMinting;

    }

    

    function disableMinting() onlyOwner public {

        mintingState = state.disabled;

    }



    function setTokenAddress(address _tokenAddress) onlyOwner public {

        tokenAddress = _tokenAddress;

    }

    

 

}