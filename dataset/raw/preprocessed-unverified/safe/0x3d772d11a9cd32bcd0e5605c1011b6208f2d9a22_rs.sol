/**
 *Submitted for verification at Etherscan.io on 2019-11-01
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-30
*/

pragma solidity ^0.4.26;





contract TokenERC20 is Ownable {
    bytes32 public standard;
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    bool public allowTransactions;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    function transfer(address _to, uint256 _value) returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}


/**
 * @title Eliptic curve signature operations
 *
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 */



contract StreamityTariff is Ownable {
    using ECRecovery for bytes32;
    
    uint8 constant public EMPTY = 0x0;

    TokenERC20 public streamityContractAddress;

    mapping(bytes32 => Deal) public stmTransfers;

    function StreamityTariff(address streamityContract) public {
        require(streamityContract != 0x0);
        streamityContractAddress = TokenERC20(streamityContract);
    }

    struct Deal {
        uint256 value;
    }

    event BuyTariff(bytes32 _tradeID);

    function payAltCoin(bytes32 _tradeID, uint256 _value, bytes _sign) 
    external 
    {
        bytes32 _hashDeal = keccak256(_tradeID, _value);
        verifyDeal(_hashDeal, _sign);
        bool result = streamityContractAddress.transferFrom(msg.sender, address(this), _value);
        require(result == true);
        startDeal(_hashDeal, _value, _tradeID);
    }

    function verifyDeal(bytes32 _hashDeal, bytes _sign) private view {
        require(_hashDeal.recover(_sign) == owner);
        require(stmTransfers[_hashDeal].value == EMPTY); 
    }

    function startDeal(bytes32 _hashDeal, uint256 _value, bytes32 _tradeID) 
    private
    {
        Deal storage userDeals = stmTransfers[_hashDeal];
        userDeals.value = _value; 
        emit BuyTariff(_tradeID);
    }

    function withdrawCommisionToAddressAltCoin(address _to, uint256 _amount) external onlyOwner {
        streamityContractAddress.transfer(_to, _amount);
    }

    function setStreamityContractAddress(address newAddress) 
    external onlyOwner 
    {
        streamityContractAddress = TokenERC20(newAddress);
    }
}