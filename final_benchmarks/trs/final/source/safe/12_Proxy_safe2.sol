contract Proxy {
    function forward(address msgSender, address target, bytes calldata callData) external payable {
        (bool success, ) = target.call{value:msg.value}(callData);
        uint256 ethBalance = address(this).balance;
        if (ethBalance != 0) {
            (success, ) = msgSender.call{value:ethBalance}("");
        }
        require(success, "eth refund failed");
    }
}
