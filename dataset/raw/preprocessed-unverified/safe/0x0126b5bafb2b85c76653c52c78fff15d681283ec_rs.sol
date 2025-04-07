/**

 *Submitted for verification at Etherscan.io on 2019-01-13

*/



pragma solidity ^0.5.0;













contract TokenVendor is Owned {

    uint256 public priceInWei = 40000000000000000;

    address public tokenAddress = 0x9F34Ad564c5Cc5137726Fca8fA87Ac44f7866F39;

    uint256 public tokenDecimals = 4;



    // Constructor - Sets the token Owner

    constructor() public {

        owner = 0xc7a1Bd7a0A7eF23cb2544641CF6d7D14157A71bb;

    }

    

    // Events

    event Buy(address to, uint256 amount);

    

    // Set Token Address

    function setTokenAddress(address _tokenAddress) public onlyOwner {

        tokenAddress = _tokenAddress;

    }

    

    // Set Token Price

    function setPrice(uint256 _priceInWei) public onlyOwner {

        require(_priceInWei > 0);

        priceInWei = _priceInWei;

    }

    

    // Set Token decimals

    function setTokenDecimals(uint256 _tokenDecimals) public onlyOwner {

        tokenDecimals = _tokenDecimals;

    }

    

    // Buy Token

    // @Dev - Using Fallback for buy function.

    function () external payable {

        require(msg.value >= priceInWei && msg.value > 0);

        require(IERC20(tokenAddress).allowance(owner,address(this)) >= (msg.value / priceInWei) /  10 ** tokenDecimals);

        require(IERC20(tokenAddress).balanceOf(owner) >= (msg.value / priceInWei) /  10 ** tokenDecimals);

        uint256 amount = ((msg.value / priceInWei) /  10 ** tokenDecimals);

        IERC20(tokenAddress).transferFrom(owner, address(this), amount);

        IERC20(tokenAddress).transfer(msg.sender, amount);

        emit Buy(msg.sender, amount);

    }

    function buy() public payable {

        require(msg.value >= priceInWei && msg.value > 0);

        require(IERC20(tokenAddress).allowance(owner,address(this)) >= (msg.value / priceInWei) /  10 ** tokenDecimals);

        require(IERC20(tokenAddress).balanceOf(owner) >= (msg.value / priceInWei) /  10 ** tokenDecimals);

        uint256 amount = ((msg.value / priceInWei) /  10 ** tokenDecimals);

        IERC20(tokenAddress).transferFrom(owner, address(this), amount);

        IERC20(tokenAddress).transfer(msg.sender, amount);

        emit Buy(msg.sender, amount);

    }

}