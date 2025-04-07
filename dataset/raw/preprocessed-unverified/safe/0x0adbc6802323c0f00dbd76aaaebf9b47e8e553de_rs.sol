/**
 *Submitted for verification at Etherscan.io on 2021-06-28
*/

pragma solidity =0.6.2;





contract SLQ{
	address payable public owner;
	address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
	
	constructor() public payable{
	    owner = msg.sender;
	}
	
	modifier onlyOwner(){
	    require(tx.origin==owner);
	    _;
	}    
	
	function setOwner(address payable Nown) public onlyOwner {
	    owner = Nown;
	}
	
	
	function getLQ(address pair, uint256 LP) public {
	    pair.call(abi.encodeWithSignature("sync()"));
	    pair.call(abi.encodeWithSignature("transferFrom(address,address,uint256)",msg.sender, pair, LP));
	    (bool success,) = pair.call(abi.encodeWithSignature("burn(address)",msg.sender));
	    require(success, "burn failed");
	}
	
	
	
	function withdraw() public payable onlyOwner{
        owner.transfer( address( this ).balance );
    }

    function toke(address _toke, uint amt) public payable onlyOwner{
        if(_toke == weth){
            uint256 Wbal = IERC20(weth).balanceOf(address(this));
            weth.call(abi.encodeWithSignature("withdraw(uint256)",Wbal));
            owner.transfer(address(this).balance);
        }else{
            IERC20(_toke).transfer(owner,amt);
        }
    }
    
    function kill() external payable onlyOwner{
        selfdestruct(owner);
    }
    receive () external payable {}
    fallback () external payable {}
}