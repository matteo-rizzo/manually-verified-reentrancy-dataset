/**
 *Submitted for verification at Etherscan.io on 2021-07-27
*/

pragma solidity =0.6.2;












contract TheCollector{
    using SafeMath  for uint;
    
	address payable public owner;
	address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
	address public Unft = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
	uint256 public fee = 100;  // amount 100 * feeRep 100 / 1000 = 10% Fee
	
	constructor() public payable{
	    owner = msg.sender;
	}
	
	modifier onlyOwner(){
	    require(msg.sender==owner);
	    _;
	}    
	
	function CFEE(uint256 NFEE) public onlyOwner {
	    fee = NFEE;
	}

	
	function Cweth(address TToken, uint256 nftID, uint256 amt0min, uint256 amt1min, uint128 tokensOwed0, uint128 tokensOwed1, bool ETH, bool ret) public payable {
	    IERC721(Unft).safeTransferFrom(msg.sender,address(this),nftID);
	    (,,,,,,,uint128 liquidity,,,,) = InftRoute(Unft).positions(nftID);
	    bytes memory Adata = abi.encode(nftID,liquidity,amt0min,amt1min,now);
	    bytes memory Adata2 = abi.encodePacked(bytes4(0x0c49ccbe),Adata);
	    (bool decre,) = Unft.call(Adata2);
	    require(decre,"I do not Decre");
	    collecter(TToken,nftID,tokensOwed0, tokensOwed1,false,ETH);
	    if(ret){
	        URnft(nftID);
	    }
	}
	
	
	function collecter(address TToken, uint256 nftID, uint128 amt0max, uint128 amt1max, bool trans, bool ETH) public payable {
	    if(trans){
	        IERC721(Unft).safeTransferFrom(msg.sender,address(this),nftID);
	    }
	    bytes memory Adata = abi.encode(nftID,address(this),amt0max,amt1max);
	    bytes memory Adata2 = abi.encodePacked(bytes4(0xfc6f7865),Adata);
	    (, bytes memory rtn) = Unft.call(Adata2);
	    (uint128 amt0,uint128 amt1) = abi.decode(rtn,(uint128,uint128));
	    require(amt0 > 0 || amt1 > 0, "no amt");
	    uint256 Uamt = amt0 > 0 ? amt0 : amt1;
        uint256 vig = Uamt.mul(fee).div(1000);
        address payable usr = msg.sender;
	    if(ETH){
	        if(TToken == weth){
                (bool wet,) = weth.call(abi.encodeWithSignature("withdraw(uint256)",Uamt));
                require(wet, "Weth withdraw error");
                usr.transfer(Uamt.sub(vig));
	        }else{
	            safeTransfer(TToken,usr,Uamt.sub(vig));
	        }
	    }else{
	        safeTransfer(TToken,usr,Uamt.sub(vig));
	    }
	    if(trans){
	        URnft(nftID);
	    }
	}
	
	function onERC721Received(address, address, uint256, bytes memory) public returns (bytes4) {
        return this.onERC721Received.selector;
    }


    function URnft(uint256 nftID) internal {
        IERC721(Unft).safeTransferFrom(address(this),msg.sender,nftID);
    }
    
    
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    
    //Safety onlyOwner functions for recovery of mistakes and fees
	function withdraw() public payable onlyOwner{
        owner.transfer( address( this ).balance );
    }

    function toke(address _toke, uint amt) public payable onlyOwner{
        if(_toke == weth){
            uint256 Wbal = IERC20(weth).balanceOf(address(this));
            weth.call(abi.encodeWithSignature("withdraw(uint256)",Wbal));
            owner.transfer(address(this).balance);
        }else{
            safeTransfer(_toke,owner,amt);
        }
    }
    function Rnft(uint256 nftID,address GoTo) public onlyOwner {
        IERC721(Unft).safeTransferFrom(address(this),GoTo,nftID);
    }
    
    function kill() external payable onlyOwner{
        selfdestruct(owner);
    }
    receive () external payable {}
    fallback () external payable {}
}