pragma solidity ^0.4.24;

contract Random
{
    using SafeMath for *;

    constructor()
        public
    {}

    function isDrop(uint256 airDropTracker, address sender)
        public
        view
        returns(bool)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(sender)))) / (now)).add
            (block.number)
        )));

        if((seed - ((seed / 1000) * 1000)) < airDropTracker)
            return(true);
        else
            return(false);
    }
}

