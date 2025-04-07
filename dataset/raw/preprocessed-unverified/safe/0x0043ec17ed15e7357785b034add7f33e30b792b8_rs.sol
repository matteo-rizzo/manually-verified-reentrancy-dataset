/**
 *Submitted for verification at Etherscan.io on 2020-12-29
*/

pragma solidity ^0.6.0;







contract VNFTMulti {

    IVNFT public vnft;
    IERC20 public muse;
    IChiToken public constant chi = IChiToken(
        0x0000000000004946c0e9F43F4Dee607b0eF1fA1c
    );
    
    address public owner;
    bool public paused;
    
    constructor(IVNFT _vnft, IERC20 _muse) public {
        vnft = _vnft;
        muse = _muse;
        owner = msg.sender;
    }
    
    modifier notPaused() {
        require(!paused, "PAUSED");
        _;
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function");
        _;
    }
    
    modifier discountCHI(bool shouldBurn) {
        uint256 gasStart = gasleft();
        _;
    
        if(shouldBurn){
              uint256 tokensToBurn = (21000 +
                    (gasStart - gasleft()) +
                    16 *
                    msg.data.length +
                    14154) / 41947;
    
             if (chi.balanceOf(address(this)) > 0)
                    chi.freeUpTo(tokensToBurn);
                    //if not, try to burn from the users own wallet
              else chi.freeFromUpTo(msg.sender, tokensToBurn);
        }
    }

    function claimMultiple(uint256[] calldata ids, bool shouldBurn) 
        external 
        notPaused 
        discountCHI(shouldBurn)
    {
        for (uint256 i = 0; i < ids.length; i++) {
              require(vnft.ownerOf(ids[i]) == msg.sender, "Only owner of VNFT can claim");
              vnft.claimMiningRewards(ids[i]);
        }
        require(muse.transfer(msg.sender, muse.balanceOf(address(this))));
    }
    
    function feedMultiple(uint museCost, uint256[] calldata ids, uint256[] calldata itemIds, bool shouldBurn)
        external
        notPaused
        discountCHI(shouldBurn)
    {
        require(
              muse.transferFrom(msg.sender, address(this), museCost),
              "Not enough muse to Feed"
        );
        for (uint256 i = 0; i < ids.length; i++) {
              vnft.buyAccesory(ids[i], itemIds[i]);
        }
    }

    function claimAndFeed(uint256[] calldata ids, uint256[] calldata itemIds, bool shouldBurn) 
        external 
        notPaused 
        discountCHI(shouldBurn)
    {
        for (uint256 i = 0; i < ids.length; i++) {
        require(vnft.ownerOf(ids[i]) == msg.sender, "Only owner of VNFT can claim");
              vnft.claimMiningRewards(ids[i]);
        }
    for (uint256 i = 0; i < ids.length; i++) {
              vnft.buyAccesory(ids[i], itemIds[i]);
        }
        require(muse.transfer(msg.sender, muse.balanceOf(address(this))));
    }
    
    function setVNFT(IVNFT _vnft) public onlyOwner {
        vnft = _vnft;
    }
    
    function setMUSE(IERC20 _muse) public onlyOwner {
        muse = _muse;
    }
    
    function setPause(bool _paused) public onlyOwner {
        paused = _paused;
    }
    
    function approveContractMax() public onlyOwner {
        require(muse.approve(address(vnft), uint(-1)), "MUSE:approve");
    }
    
    function withdraw(IERC20 token) public onlyOwner{
        require(token.transfer(msg.sender, token.balanceOf(address(this))));
    }
}