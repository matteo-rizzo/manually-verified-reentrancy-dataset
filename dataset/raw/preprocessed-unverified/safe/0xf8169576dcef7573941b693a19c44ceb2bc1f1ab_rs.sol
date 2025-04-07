/* Discussion:
 * https://test.dfohub.eth?ensd=test.dfohub.eth
 */
/* Description:
 * New Staking Transfer Functionality
 */
pragma solidity ^0.7.1;

contract StakingTransferFunctionality {

    string private _metadataLink;

    constructor(string memory metadataLink) {
        _metadataLink = metadataLink;
    }

    function getMetadataLink() public view returns(string memory) {
        return _metadataLink;
    }

    function onStart(address, address) public {
        IMVDProxy proxy = IMVDProxy(msg.sender);
        IStateHolder stateHolder = IStateHolder(proxy.getStateHolderAddress());
        stateHolder.setBool(_toStateHolderKey("staking.transfer.authorized", _toString(0x792BF16B9C6CaD4c180C0031F32c39EB51d6A290)), true);
        stateHolder.setUint256("staking.0x792bf16b9c6cad4c180c0031f32c39eb51d6a290.tiers[0].minCap", 100000000000000000000);
        stateHolder.setUint256("staking.0x792bf16b9c6cad4c180c0031f32c39eb51d6a290.tiers[0].hardCap", 100000000000000000000000);
        stateHolder.setUint256("staking.0x792bf16b9c6cad4c180c0031f32c39eb51d6a290.tiers.length", 1);
    }

    function onStop(address) public {
    }

    function stakingTransfer(address sender, uint256, uint256 value, address receiver) public {
        IMVDProxy proxy = IMVDProxy(msg.sender);

        require(IStateHolder(proxy.getStateHolderAddress()).getBool(_toStateHolderKey("staking.transfer.authorized", _toString(sender))), "Unauthorized action!");

        proxy.transfer(receiver, value, proxy.getToken());
    }

    function _toStateHolderKey(string memory a, string memory b) private pure returns(string memory) {
        return _toLowerCase(string(abi.encodePacked(a, ".", b)));
    }

    function _toString(address _addr) private pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    }

    function _toLowerCase(string memory str) private pure returns(string memory) {
        bytes memory bStr = bytes(str);
        for (uint i = 0; i < bStr.length; i++) {
            bStr[i] = bStr[i] >= 0x41 && bStr[i] <= 0x5A ? bytes1(uint8(bStr[i]) + 0x20) : bStr[i];
        }
        return string(bStr);
    }
}







