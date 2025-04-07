pragma solidity ^0.4.24;


contract Feeless {
    address internal msgSender;
    mapping(address => uint256) public nonces;
    modifier feeless {
        if (msgSender == address(0)) {
            msgSender = msg.sender;
            _;
            msgSender = address(0);
        } else {
            _;
        }
    }
    function performFeelessTransaction(address sender, address target, bytes data, uint256 nonce, bytes sig) public payable {
        require(this == target);
        
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hash = keccak256(prefix, keccak256(target, data, nonce));
        msgSender = ECRecovery.recover(hash, sig);
        require(msgSender == sender);
        require(nonces[msgSender]++ == nonce);
        
        require(target.call.value(msg.value)(data));
        msgSender = address(0);
    }
}
contract ERC20Basic {
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
contract AbstractFee is ERC20Basic, Feeless {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    function transfer(address _to, uint256 _value) public feeless returns (bool) {
        balances[msgSender] = balances[msgSender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msgSender, _to, _value);
        return true;
    }
}