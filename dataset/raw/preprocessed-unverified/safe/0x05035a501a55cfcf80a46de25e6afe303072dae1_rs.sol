pragma solidity ^0.4.18;
// import from contract/src/lib/math/_.sol ======
// -- import from contract/src/lib/math/u256.sol ====== 

 
// import from contract/src/Solar/_.sol ======
// -- import from contract/src/Solar/iNewPrice.sol ====== 


contract NewPricePlanet is INewPrice { 
    using U256 for uint256; 

    function getNewPrice(uint origin, uint current) view public returns(uint) {
        if (current < 0.02 ether) {
            return current.mul(150).div(100);
        } else if (current < 0.5 ether) {
            return current.mul(135).div(100);
        } else if (current < 2 ether) {
            return current.mul(125).div(100);
        } else if (current < 50 ether) {
            return current.mul(117).div(100);
        } else if (current < 200 ether) {
            return current.mul(113).div(100);
        } else {
            return current.mul(110).div(100);
        } 
    }

    function isNewPrice() view public returns(bool) {
        return true;
    }
}