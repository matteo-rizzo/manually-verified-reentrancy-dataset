/**
 *Submitted for verification at Etherscan.io on 2021-09-11
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;






contract POLN3DSeller is Ownable {
    
    address public nftAddress;
    IUniswap public uniswapRouter;
    address payable public sellingWallet;
    uint256 slippage = 2;
    
    mapping(uint => uint) public assets;
    
    constructor() {
        sellingWallet = payable(0xAD334543437EF71642Ee59285bAf2F4DAcBA613F);
        nftAddress = 0xB20217bf3d89667Fa15907971866acD6CcD570C8;
        uniswapRouter = IUniswap(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        assets[47] = 300442550295544894;

    }
    
    function getPrice(uint _assetType) public view returns (uint256) {
        return assets[_assetType];
    }
    
    function calcMaxSlippage(uint256 _amount) public view returns (uint256) {
        return (_amount - ((_amount * slippage) / 100));
    }

    function buyWithEth(uint256 assetType, uint256 assetDetails) public payable returns (bool) {
        IERC721 nft = IERC721(nftAddress);
        (, , uint64 _coinIndex, ) = nft.assetsByType(assetType);
        require(_coinIndex == 1 , "Invalid coin");
        require(assets[assetType] != 0, "Invalid asset");
        uint256 sellingPrice = getPrice(assets[assetType]);
        require(msg.value >= (calcMaxSlippage(sellingPrice)), 'Invalid amount');
        require(sellingWallet.send(msg.value));
        require(nft.mint(msg.sender, uint32(assetType), sellingPrice, uint32(assetDetails)), "Not possible to mint this type of asset");
        return true;
    }
    
    function setPrice(uint256 _assetId, uint256 _newPrice) public onlyOwner {
        assets[_assetId] = _newPrice;
    }
    
    function setSlippage(uint256 _slippage) public onlyOwner {
        slippage = _slippage;
    }

    
    
}