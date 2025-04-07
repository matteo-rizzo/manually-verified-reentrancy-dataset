/**
 *Submitted for verification at Etherscan.io on 2021-06-14
*/

pragma solidity ^0.8.4;
// SPDX-License-Identifier: Unlicensed






contract BAEAwards {

    mapping(bytes32 => bool) public hashmap;
    IERC20 baePay;
    address _owner;

    constructor(address _baePayAddress){
        baePay = IERC20(_baePayAddress);
        _owner = msg.sender;
    }

    function _verifyHash(bytes32 _hash, uint8 v, bytes32[2] memory rs) internal view returns (bool){
        return ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), v, rs[0], rs[1]) == _owner;
    }

    function changeOwnership(address _newOwner) external{
        require(msg.sender == _owner, "You Are Not The Owner");
        _owner = _newOwner;
    }

    function withdrawBAEPay(uint256 _amount) external{
        require(msg.sender == _owner, "You Are Not The Owner");
        baePay.transfer(msg.sender, _amount);
    }

    function claimBAEPay(uint256 _amount, string memory _nonce, uint8 _v, bytes32[2] memory _rs) external{
        bytes32 newHash = keccak256(abi.encodePacked(_amount, _nonce, msg.sender));
        require(!hashmap[newHash], "Key Already Used");
        require(_verifyHash(newHash, _v, _rs), "Invalid Key");
        hashmap[newHash] = true;
        baePay.transfer(msg.sender, _amount * 10 ** 4);
    }

}