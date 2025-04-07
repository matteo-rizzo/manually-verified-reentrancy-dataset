/**

 *Submitted for verification at Etherscan.io on 2019-02-26

*/



pragma solidity ^0.4.25;















contract MANABurner is Ownable {



    Marketplace public marketplace;

    BurnableERC20 public mana;



    constructor(address manaAddress, address marketAddress) public {

        mana = BurnableERC20(manaAddress);

        marketplace = Marketplace(marketAddress);

    }



    function burn() public {

        mana.burn(mana.balanceOf(this));

    }



    function transferMarketplaceOwnership(address target) public onlyOwner {

        marketplace.transferOwnership(target);

    }



    function setOwnerCutPerMillion(uint256 _ownerCutPerMillion) public onlyOwner {

        marketplace.setOwnerCutPerMillion(_ownerCutPerMillion);

    }



    function pause() public onlyOwner {

        marketplace.pause();

    }



    function unpause() public onlyOwner {

        marketplace.unpause();

    }

}