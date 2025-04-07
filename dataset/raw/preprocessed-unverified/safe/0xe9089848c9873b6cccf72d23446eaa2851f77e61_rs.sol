/**
 *Submitted for verification at Etherscan.io on 2020-12-06
*/

pragma solidity ^0.5.16;
/**
  * @title ArtDeco Finance
  *
  * @notice ArtDeco NFT Relay: ERC-721 NFTs stored in contract for promote  
  * 
  */
  
/***
* 
* MIT License
* ===========
* 
*  Copyright (c) 2020 ArtDeco
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/
/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a {IERC721-safeTransferFrom}. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}




/**
 * @dev Collection of functions related to the address type
 */



contract Governance {

    address public _governance;

    constructor() public {
        _governance = tx.origin;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance)  public  onlyGovernance
    {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }


}








 

 



contract NftRelay is Governance{
    
    using SafeMath for uint256;
    using Address for address;
    
    address public _anft =  address(0x99a7e1188CE9a0b7514d084878DFb8A405D8529F);
    address public _apwr = address(0xb60F072494c7f1b5a8ba46bc735C71A83D940D1A);  
    address public _nftfactory = address(0xc826a85C5D0CEEBA726f63fB06B32a8Dad4C9e29);
    address private _randseed = address(0x75A7c0f3c7E59D0Aa323cc8832EaF2729Fe2127C);

    // A token
    address public _token =  address(0x77dF79539083DCd4a8898dbA296d899aFef20067); 
    address public _teamWallet = address(0x3b2b4f84cFE480289df651bE153c147fa417Fb8A);
    address public _nextRelayPool = address(0);
    address public _burnPool = 0x6666666666666666666666666666666666666666;
    
    uint256 private releaseDate;
    uint256 public _claimrate = 1.0 * 1e18;
    
    uint256 public _claimdays = 0 days;
    uint  private nonce = 0;
    
    uint256[] private _allNft;
    
    // Mapping from NFT-id to position in the allNft array
    mapping(uint256 => uint256) private _allNftIndex;

    // Mapping from airdrop receiver to boolean 
    mapping (address => bool) public hasClaimed;
    
    // Throws when msg.sender has already claimed the airdrop 
    modifier hasNotClaimed() {
        require(hasClaimed[msg.sender] == false);
        _;
    }
    
    // Throws when the 30 day airdrop period has passed 
    modifier canClaim() {
        require(releaseDate + _claimdays >= now);
        _;
    }
    
    event NFTReceived(address operator, address from, uint256 tokenId, bytes data);
    event TransferNFT(address to, uint count);
    
    constructor() public {
        // Set releaseDate
        releaseDate = now;
    }
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) 
    {
        _addNft( tokenId );
        emit NFTReceived(operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
    
    function setNftFactory( address newfactory ) external onlyGovernance {
        _nftfactory = newfactory;
    }

    function setnextRelayPool( address newrelaypool ) external onlyGovernance {
        _nextRelayPool = newrelaypool;
    }
    
    function setclaimDays( uint256 claimdays ) external onlyGovernance {
        _claimdays = claimdays;
    }
 
    function setuseToken( address token ) external onlyGovernance {
        _token = token;
    }

    function setclaimRate( uint256 claimrate ) external onlyGovernance {
        _claimrate = claimrate;
    }
    
    function getclaimRate() public view returns (uint256) {
        return _claimrate;
    }
    
    function IsClaimed( address account ) public view returns (bool) {
        return hasClaimed[account];
    }
    
    function mintNft( ) external 
    {
            NFTFactory _nftfactoryx =  NFTFactory(_nftfactory);
            _nftfactoryx.claimbyrelay( );
    }
    
    function claimNFTbytokens(  uint256 amount ) external hasNotClaimed()  canClaim()
    {
        
        require( amount >= _claimrate, "ARTTamount not enough");
        
        if( amount > 0 )
        {
            AToken _tokenx =  AToken(_token);
            _tokenx.transferFrom(msg.sender, address(this), amount );
        }
        
        RandomSeed _rc = RandomSeed(_randseed);
        uint randnum = _rc.random_get9999(msg.sender,nonce);  
        nonce = nonce + 1;
        
        uint256 total = _allNft.length;
        uint256 md = SafeMath.mod( randnum, total );
        uint id = nftByIndex(md);
        
        _removeNft( id );
        AnftToken _anftx =  AnftToken(_anft);
        _anftx.safeTransferFrom( address(this), msg.sender, id );
        
        ApwrToken _apwrx = ApwrToken(_apwr);
        _apwrx.transfer( msg.sender, 4* 1e15 );

        // Set boolean for hasClaimed
        hasClaimed[msg.sender] = true;
    }
 

    function claim() external hasNotClaimed()  canClaim()
    {
            require( _claimrate == 0, "No Free, to pay Atoken is needed");
            
            RandomSeed _rc = RandomSeed(_randseed);
            uint randnum = _rc.random_get9999(msg.sender,nonce);  
            nonce = nonce + 1;
            
            uint256 total = _allNft.length;
            uint256 md = SafeMath.mod( randnum, total );
            uint id = nftByIndex(md);
            
            _removeNft( id );
            AnftToken _anftx =  AnftToken(_anft);
            _anftx.safeTransferFrom( address(this), msg.sender, id );
    
            ApwrToken _apwrx = ApwrToken(_apwr);
            _apwrx.transfer( msg.sender, 1* 1e16 );
            
            // Set boolean for hasClaimed
            hasClaimed[msg.sender] = true;
    }
     
    
    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param nftId uint256 ID of the token to be removed from the tokens list
     */
     
    function _removeNft(uint256 nftId) private {

        uint256 lastNftIndex = _allNft.length.sub(1);
        uint256 NftIndex = _allNftIndex[nftId];

        uint256 lastNftId = _allNft[lastNftIndex];

        _allNft[NftIndex] = lastNftId; 
        _allNftIndex[lastNftId] = NftIndex; 

        _allNft.length--;
        _allNftIndex[nftId] = 0;
    }
        
    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addNft(uint256 tokenId) private {
        _allNftIndex[tokenId] = _allNft.length;
        _allNft.push(tokenId);
    }
    
    /**
     * @dev Gets the total amount of NFT stored by the contract.
     * @return uint256 representing the total amount of NFT
     */
    function totalNFTs() public view returns (uint256) {
        return _allNft.length;
    }

    /**
     * @dev Gets the total amount of ArtPower stored by the contract.
     * @return uint256 representing the total amount of APWR
     */
    function totalAPWR() public view returns (uint256) {
        ApwrToken _apwrx = ApwrToken(_apwr);
        return _apwrx.balanceOf(address(this));
    }

    /**
     * @dev Gets the token ID at a given index of all the NFT in this contract
     * Reverts if the index is greater or equal to the total number of NFT.
     * @param index uint256 representing the index to be accessed of the NFT list
     * @return uint256 token ID at the given index of the NFT list
     */
    function nftByIndex(uint256 index) public view returns (uint256) {
        require(index < totalNFTs(), "ERC721: global index out of bounds");
        return _allNft[index];
    }
 
    function MigrateNFT() external onlyGovernance 
    {
         uint count =  _allNft.length;
         uint id = 0;
         if( count >= 1 )
         {
            AnftToken _anftx =  AnftToken(_anft);
            id = _allNft[0];
            _removeNft( id );
            _anftx.safeTransferFrom( address(this), _nextRelayPool, id );

            ApwrToken _apwrx = ApwrToken(_apwr);
            _apwrx.transfer( _nextRelayPool, 1* 1e16 );
         }
         
         emit TransferNFT( _nextRelayPool, count );
    }
    
    // Transfer Atoken to _teamWallet
    function seizeAtoken() external  
    {
        AToken _tokenx =  AToken(_token);
        uint _currentBalance =  _tokenx.balanceOf(address(this));
        _tokenx.transfer(_teamWallet, _currentBalance );
    }
    
}