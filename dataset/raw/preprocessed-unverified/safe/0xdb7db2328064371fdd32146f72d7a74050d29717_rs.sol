/**
 *Submitted for verification at Etherscan.io on 2021-03-08
*/

pragma solidity ^0.8.0;

// Author: 0xKiwi.





contract NFTAtomicSwap {
    uint256 public constant NAME_COST = 1830 ether;
    IERC721 public constant WAIFUSION = IERC721(0x2216d47494E516d8206B70FCa8585820eD3C4946);
    IERC20 public constant WET = IERC20(0x76280AF9D18a868a0aF3dcA95b57DDE816c1aaf2);

    address owner;
    
    constructor() {
        owner = msg.sender;
        WET.approve(address(WAIFUSION), 2**255);
    }
    
    function atomicNameTransfer(uint256 inNFT, uint256 outNFT, string memory tempName) external {
        WET.transferFrom(msg.sender, address(this), NAME_COST * 2);
        WAIFUSION.transferFrom(msg.sender, address(this), inNFT);
        WAIFUSION.transferFrom(msg.sender, address(this), outNFT);
        string memory oldName = WAIFUSION.tokenNameByIndex(inNFT);
        WAIFUSION.changeName(inNFT, tempName);
        WAIFUSION.changeName(outNFT, oldName);
        WAIFUSION.transferFrom(address(this), msg.sender, inNFT);
        WAIFUSION.transferFrom(address(this), msg.sender, outNFT);
    }
    
    function atomicNameSwap(uint256 inNFT, uint256 outNFT, string memory tempName) external {
        WET.transferFrom(msg.sender, address(this), NAME_COST * 3);
        WAIFUSION.transferFrom(msg.sender, address(this), inNFT);
        WAIFUSION.transferFrom(msg.sender, address(this), outNFT);
        string memory inOldName = WAIFUSION.tokenNameByIndex(inNFT);
        string memory outOldName = WAIFUSION.tokenNameByIndex(outNFT);
        WAIFUSION.changeName(outNFT, tempName);
        WAIFUSION.changeName(inNFT, outOldName);
        WAIFUSION.changeName(outNFT, inOldName);
        WAIFUSION.transferFrom(address(this), msg.sender, inNFT);
        WAIFUSION.transferFrom(address(this), msg.sender, outNFT);
    }
}