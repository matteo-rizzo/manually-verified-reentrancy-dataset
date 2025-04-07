/**
 *Submitted for verification at Etherscan.io on 2021-08-12
*/

/*
 * Munch contract to update our tokenomics.
 *
 * This contract is meant to be used as the charity wallet on
 * the base Munch contract.
 * Since the original contract relies on transfer() to send the ETH,
 * we can't have this contract automatically forward the funds to wallets
 * as the gas fees are higher than what transfer() supports.
 * We are therefore introducing a public function which can be called to trigger
 * the sending of funds to charity and marketing.
 *
 * Visit https://munchproject.io for more details.
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}





contract MunchTokenomicsV2 is Ownable {
    using SafeMath for uint256;

    address payable public charityWalletAddress;
    address payable public marketingWalletAddress;

    uint256 marketingPercentage; // integer value from 0 to 100

    constructor(address payable charityWallet, address payable marketingWallet)
        public
    {
        charityWalletAddress = charityWallet;
        marketingWalletAddress = marketingWallet;
    }

    function setCharityWalletAddress(address payable charity)
        external
        onlyOwner
    {
        charityWalletAddress = charity;
    }

    function setMarketingWalletAddress(address payable marketing)
        external
        onlyOwner
    {
        marketingWalletAddress = marketing;
    }

    function setMarketingPercentage(uint256 percentage) external onlyOwner {
        require(percentage >= 0 && percentage <= 100, "Invalid percentage");
        marketingPercentage = percentage;
    }

    function distributeFunds() public {
        if (address(this).balance > 0) {
            uint256 balance = address(this).balance;
            uint256 marketingShare = balance
                .mul(marketingPercentage)
                .div(100);
            uint256 charityShare = balance.sub(marketingShare);

            (bool successC, ) = charityWalletAddress.call{value: charityShare}("");
            (bool successM, ) = marketingWalletAddress.call{value: marketingShare}("");
            require(successC && successM, "Transfer failed.");
        }
    }

    receive() external payable {}

    // Allow owner to withdraw tokens sent by mistake to the contract
    function withdrawToken(address token)
        external
        onlyOwner
    {
        IERC20 tokenContract = IERC20(token);
        tokenContract.transfer(msg.sender, tokenContract.balanceOf(address(this)));
    }
}