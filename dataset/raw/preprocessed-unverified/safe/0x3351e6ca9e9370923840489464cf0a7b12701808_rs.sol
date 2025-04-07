pragma solidity ^0.4.19;

// the call we make


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract KittyBirther is Ownable {
    KittyCoreI constant kittyCore = KittyCoreI(0x06012c8cf97BEaD5deAe237070F9587f8E7A266d);

    function KittyBirther() public {}

    function withdraw() public onlyOwner {
        owner.transfer(this.balance);
    }

    function birth(uint blockNumber, uint64[] kittyIds) public {
        if (blockNumber < block.number) {
            return;
        }

        if (kittyIds.length == 0) {
            return;
        }

        for (uint i = 0; i < kittyIds.length; i ++) {
            kittyCore.giveBirth(kittyIds[i]);
        }
    }
}