/**
 *Submitted for verification at Etherscan.io on 2019-10-25
*/

pragma solidity ^0.5.11;



contract QBCF {

	BCF private bcf;

	constructor(address _BCF_address) public {
		bcf = BCF(_BCF_address);
	}

	function allInfoFor(address _customer) public view returns (uint256 ethereumBalance, uint256 totalSupply, uint256 buyPrice, uint256 sellPrice, uint256 customerBalance, uint256 customerDividends) {
		return (bcf.totalEthereumBalance(), bcf.totalSupply(), bcf.buyPrice(), bcf.sellPrice(), bcf.balanceOf(_customer), bcf.dividendsOf(_customer));
	}
}