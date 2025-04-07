/**

 *Submitted for verification at Etherscan.io on 2018-12-14

*/



pragma solidity ^0.4.25;







contract WWGClanCoupon is ERC721 {

    using SafeMath for uint256;

    

    // Clan contract not finalized/deployed yet, so buyers get an ERC-721 coupon 

    // which will be burnt in exchange for real clan token in next few weeks 

    

    address preLaunchMinter;

    address wwgClanContract;

    

    uint256 numClans;

    address owner; // Minor management

    

    event ClanMinted(address to, uint256 clanId);

    

    // ERC721 stuff

    mapping (uint256 => address) public tokenOwner;

    mapping (uint256 => address) public tokenApprovals;

    mapping (address => uint256[]) public ownedTokens;

    mapping(uint256 => uint256) public ownedTokensIndex;

    

    constructor() public {

        owner = msg.sender;

    }

    

    function setCouponMinter(address prelaunchContract) external {

        require(msg.sender == owner);

        require(preLaunchMinter == address(0));

        preLaunchMinter = prelaunchContract;

    }

    

    function setClanContract(address clanContract) external {

        require(msg.sender == owner);

        wwgClanContract = address(clanContract);

    }

    

    function mintClan(uint256 clanId, address clanOwner) external {

        require(msg.sender == address(preLaunchMinter));

        require(tokenOwner[clanId] == address(0));



        numClans++;

        addTokenTo(clanOwner, clanId);

        emit Transfer(address(0), clanOwner, clanId);

    }

    

    // Finalized clan contract has control to redeem, so will burn this coupon upon doing so

    function burnCoupon(address clanOwner, uint256 tokenId) external {

        require (msg.sender == wwgClanContract);

        removeTokenFrom(clanOwner, tokenId);

        numClans = numClans.sub(1);

        

        emit ClanMinted(clanOwner, tokenId);

    }

    

    function balanceOf(address player) public view returns (uint256) {

        return ownedTokens[player].length;

    }

    

    function ownerOf(uint256 clanId) external view returns (address) {

        return tokenOwner[clanId];

    }

    

    function totalSupply() external view returns (uint256) {

        return numClans;

    }

    

    function exists(uint256 clanId) public view returns (bool) {

        return tokenOwner[clanId] != address(0);

    }

    

    function approve(address to, uint256 clanId) external {

        tokenApprovals[clanId] = to;

        emit Approval(msg.sender, to, clanId);

    }



    function getApproved(uint256 clanId) external view returns (address operator) {

        return tokenApprovals[clanId];

    }

    

    function tokensOf(address player) external view returns (uint256[] tokens) {

         return ownedTokens[player];

    }

    

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(tokenApprovals[tokenId] == msg.sender || tokenOwner[tokenId] == msg.sender);



        removeTokenFrom(from, tokenId);

        addTokenTo(to, tokenId);



        delete tokenApprovals[tokenId]; // Clear approval

        emit Transfer(from, to, tokenId);

    }



    function removeTokenFrom(address from, uint256 tokenId) internal {

        require(tokenOwner[tokenId] == from);

        tokenOwner[tokenId] = address(0);

        delete tokenApprovals[tokenId]; // Clear approval



        uint256 tokenIndex = ownedTokensIndex[tokenId];

        uint256 lastTokenIndex = ownedTokens[from].length.sub(1);

        uint256 lastToken = ownedTokens[from][lastTokenIndex];



        ownedTokens[from][tokenIndex] = lastToken;

        ownedTokens[from][lastTokenIndex] = 0;



        ownedTokens[from].length--;

        ownedTokensIndex[tokenId] = 0;

        ownedTokensIndex[lastToken] = tokenIndex;

    }



    function addTokenTo(address to, uint256 tokenId) internal {

        require(balanceOf(to) == 0); // Can only own one clan (thus coupon to keep things simple)

        tokenOwner[tokenId] = to;



        ownedTokensIndex[tokenId] = ownedTokens[to].length;

        ownedTokens[to].push(tokenId);

    }



}





