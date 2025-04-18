contract ArbitraryCaller {
    function sendCall(
        address msgSender,
        address target,
        bytes calldata callData
    ) external payable {
        (bool success, ) = target.call.value(msg.value)(callData);
        uint256 size;
        uint256 ptr;
        assembly {
            size := returndatasize()
            ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

            if eq(success, 0) {
                revert(ptr, size)
            }
        }

        uint256 ethBalance = address(this).balance;
        if (ethBalance != 0) {
            (success, ) = msgSender.call.value(ethBalance)("");
        }
        require(success, "eth refund failed");

        assembly {
            return(ptr, size)
        }
    }
}
