pragma solidity 0.4.23;

// File: node_modules\openzeppelin-solidity\contracts\math\SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


// File: contracts\Givinglog_back.sol

contract GivingLog {
    using SafeMath for uint128;

    event Give(address give, address take, uint128 amount, string ipfs);

    function logGive(address _to, string _ipfs) public payable{
        require(msg.value > 0);
        _to.transfer(uint128(msg.value));
        emit Give(msg.sender, _to, uint128(msg.value), _ipfs);
    }

}