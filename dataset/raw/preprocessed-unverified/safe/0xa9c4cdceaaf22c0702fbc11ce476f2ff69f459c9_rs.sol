/**
 *Submitted for verification at Etherscan.io on 2021-03-08
*/

pragma solidity ^0.8.0;

// Author: 0xKiwi.





contract NFTAtomicSwap {
    uint256 public constant NAME_COST = 1830 ether;
    IERC721 public constant WAIFUSION = IERC721(0x2216d47494E516d8206B70FCa8585820eD3C4946);
    IERC20 public constant WET = IERC20(0x76280AF9D18a868a0aF3dcA95b57DDE816c1aaf2);

    uint256 name_nonce = 2**60-1;
    address owner;
    
    constructor() {
        owner = msg.sender;
        WET.approve(address(WAIFUSION), 2**255);
    }
    
    function atomicNameTransfer(uint256 inNFT, uint256 outNFT) external {
        WET.transferFrom(msg.sender, address(this), NAME_COST * 2);
        WAIFUSION.transferFrom(msg.sender, address(this), inNFT);
        WAIFUSION.transferFrom(msg.sender, address(this), outNFT);
        string memory oldName = WAIFUSION.tokenNameByIndex(inNFT);
        WAIFUSION.changeName(inNFT, uint2str(name_nonce));
        WAIFUSION.changeName(outNFT, oldName);
        WAIFUSION.transferFrom(address(this), msg.sender, inNFT);
        WAIFUSION.transferFrom(address(this), msg.sender, outNFT);
        name_nonce++;
    }
    
    function atomicNameSwap(uint256 inNFT, uint256 outNFT) external {
        WET.transferFrom(msg.sender, address(this), NAME_COST * 3);
        WAIFUSION.transferFrom(msg.sender, address(this), inNFT);
        WAIFUSION.transferFrom(msg.sender, address(this), outNFT);
        string memory inOldName = WAIFUSION.tokenNameByIndex(inNFT);
        string memory outOldName = WAIFUSION.tokenNameByIndex(outNFT);
        WAIFUSION.changeName(outNFT, uint2str(name_nonce));
        WAIFUSION.changeName(outNFT, outOldName);
        WAIFUSION.changeName(outNFT, inOldName);
        WAIFUSION.transferFrom(address(this), msg.sender, inNFT);
        WAIFUSION.transferFrom(address(this), msg.sender, outNFT);
        name_nonce++;
    }
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
    
    function setNameNonce(uint256 newNonce) external {
        require(msg.sender == owner);
        name_nonce = newNonce;
    } 
}