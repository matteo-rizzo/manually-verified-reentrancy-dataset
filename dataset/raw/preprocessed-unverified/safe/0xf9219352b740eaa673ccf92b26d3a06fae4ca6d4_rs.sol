pragma solidity ^0.4.21;



contract Market_Price is Ownable{
    uint256 usdEth;
    uint256 usdBtc;

    function getUSDEth() public view returns(uint256){
        return usdEth;
    }

    function setUSDEth(uint256 _usdEth) onlyOwner public {
        usdEth = _usdEth;
    }

    function getUSDBtc() public view returns(uint256){
        return usdBtc;
    }

    function setUSDBtc(uint256 _usdBtc) onlyOwner public {
        usdBtc = _usdBtc;
    }
}