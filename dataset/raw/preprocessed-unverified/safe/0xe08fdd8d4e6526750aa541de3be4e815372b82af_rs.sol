pragma solidity 0.5.17;



contract DropToken { // transfer msg.sender token to recipients per approved drop amount w/ msg.
    event DropTKN(bytes32 indexed message);
    
    function dropTKN(address[] calldata recipients, address tokenAddress, uint256 amount, bytes32 message) external {
        IToken token = IToken(tokenAddress);
        uint256 amounts = amount / recipients.length;
        for (uint256 i = 0; i < recipients.length; i++) {
	    token.transferFrom(msg.sender, recipients[i], amounts);}
	    emit DropTKN(message);
    }
}