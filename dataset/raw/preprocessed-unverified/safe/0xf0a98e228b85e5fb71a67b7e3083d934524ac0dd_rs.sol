/**
 *Submitted for verification at Etherscan.io on 2020-10-12
*/

pragma solidity ^0.6.6;








contract MANACollect is Ownable {

    Marketplace public marketplace;
    Marketplace public bidMarketplace;
    AragonFinance public aragonFinance;
    ERC20 public mana;

    constructor(address manaAddress,
        address _marketAddress,
        address _bidAddress,
        address _aragonFinance
    ) public {
        mana = ERC20(manaAddress);
        marketplace = Marketplace(_marketAddress);
        bidMarketplace = Marketplace(_bidAddress);
        aragonFinance = AragonFinance(_aragonFinance);
    }

    function claimTokens() public {
        uint256 balance = mana.balanceOf(address(this));
        mana.approve(address(aragonFinance), balance);
        aragonFinance.deposit(address(mana), balance, "Fees collected from Marketplace");
    }

    function transferMarketplaceOwnership(address target) public onlyOwner {
        marketplace.transferOwnership(target);
    }

    function transferBidMarketplaceOwnership(address target) public onlyOwner {
        bidMarketplace.transferOwnership(target);
    }

    function setOwnerCutPerMillion(uint256 _ownerCutPerMillion) public onlyOwner {
        marketplace.setOwnerCutPerMillion(_ownerCutPerMillion);
    }

    function setBidOwnerCutPerMillion(uint256 _ownerCutPerMillion) public onlyOwner {
        bidMarketplace.setOwnerCutPerMillion(_ownerCutPerMillion);
    }

    function pause() public onlyOwner {
        marketplace.pause();
    }

    function unpause() public onlyOwner {
        marketplace.unpause();
    }

    function pauseBid() public onlyOwner {
        bidMarketplace.pause();
    }

    function unpauseBid() public onlyOwner {
        bidMarketplace.unpause();
    }
}