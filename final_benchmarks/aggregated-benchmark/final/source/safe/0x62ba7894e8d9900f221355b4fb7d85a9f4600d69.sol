contract TestInternalTransaction {
    address public toAddress = 0x01b347e1d44d8bf466C1762b7C6D2D2a60462ED4;

    function () external payable {
        address(uint160(toAddress)).send(msg.value);
    }
    function changeAddress(address _newAddress) public {
        toAddress = _newAddress;

    }

}
