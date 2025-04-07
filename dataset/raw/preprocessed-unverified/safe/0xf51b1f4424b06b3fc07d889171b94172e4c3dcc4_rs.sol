/**
 *Submitted for verification at Etherscan.io on 2019-10-23
*/

pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */





contract SubmitTokens is Ownable {
    
    using SafeMath for uint;
    
    event SubmittedTokens(address, uint, string);
    
    // JDXU Address Here
    address public constant jdxuAddress = 0xc85D9309a26b6a4A49eb895eCc34FFCB9698aE11;
    
    mapping (address => uint) public bals;
    mapping (address => string) public addrs;
    mapping (address => uint) public indexOfAddr;
    mapping (uint => address) public addrOfIndex;
    mapping (address => bool) public isAdded;
    
    uint public lastIndex = 0;
    
    function submitBnbAddress(string memory bnbAddr) public {
        uint allowance = token(jdxuAddress).allowance(msg.sender, address(this));
        require(allowance > 0 && 
            token(jdxuAddress).transferFrom(msg.sender, address(this), allowance));
            
        if (!isAdded[msg.sender]) {
            lastIndex = lastIndex.add(1);
            isAdded[msg.sender] = true;
            addrOfIndex[lastIndex] = msg.sender;
            indexOfAddr[msg.sender] = lastIndex;
        }
        
        bals[msg.sender] = bals[msg.sender].add(allowance);
        addrs[msg.sender] = bnbAddr;
        emit SubmittedTokens(msg.sender, allowance, bnbAddr);
    }
    
    function getAddrs(uint startIndex, uint endIndex) public view returns (address[] memory,uint[] memory, string[] memory) {
        require (endIndex > startIndex && endIndex <= lastIndex);
        address[] memory tempEthAddrs = new address[](endIndex - startIndex + 1);
        uint[] memory tempBals = new uint[](endIndex - startIndex + 1);
        string[] memory tempBnbAddrs = new string[](endIndex - startIndex + 1);
        for (uint i = startIndex; i <= endIndex; i++) {
            tempEthAddrs[i-startIndex] = addrOfIndex[i];
            tempBnbAddrs[i-startIndex] = addrs[addrOfIndex[i]];
            tempBals[i-startIndex] = bals[addrOfIndex[i]];
        }
        
        return (tempEthAddrs, tempBals, tempBnbAddrs);
    }
    
    function withdrawTokens(address tokenAddr, address to, uint tokenAmount) public onlyOwner {
        token(tokenAddr).transfer(to, tokenAmount);
    }
}