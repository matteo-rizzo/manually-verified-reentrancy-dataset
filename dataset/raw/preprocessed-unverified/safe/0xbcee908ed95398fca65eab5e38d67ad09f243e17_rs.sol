pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


// File: contracts/ext/ERC1003Token.sol

contract ERC1003Caller is Ownable {
    function makeCall(address _target, bytes _data) external payable onlyOwner returns (bool) {
        // solium-disable-next-line security/no-call-value
        return _target.call.value(msg.value)(_data);
    }
}