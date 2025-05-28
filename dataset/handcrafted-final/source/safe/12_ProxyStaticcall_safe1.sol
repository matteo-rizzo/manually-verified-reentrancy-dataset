contract Proxy {
    function forward(address target, address user) external view returns (uint256 result) {
        (bool success, bytes memory data) = target.staticcall(
            abi.encodeWithSignature("getBalance(address)", user)
        );

        if (!success) {
            assembly {
                let size := returndatasize()
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, size)
                revert(ptr, size)
            }
        }

        result = abi.decode(data, (uint256));
    }
}
