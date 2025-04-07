/**
 *Submitted for verification at Etherscan.io on 2020-06-30
*/

pragma solidity ^0.5.17;





contract TokenERC20 is Ownable {
    bytes32 public standard;
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    bool public allowTransactions;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    function transfer(address _to, uint256 _value) public;
    function approve(address _spender, uint256 _value) public;
    function transferFrom(address _from, address _to, uint256 _value) public;
}




contract PayTalexnet is Ownable {
    using ECRecovery for bytes32;
    
    mapping(bytes32 => bool) public payList;

    event Trade(uint8 _vendor, bytes32 _tradeID);
    event Pay(uint8 _vendor, address _coin, uint256 _value, bytes32 _tradeID);
    event Multisended(address _token, uint256 _total);
    event Withdraw(address _to, address _token, uint256 _value);
    
    /**
     * Pay functions
    */
    function pay(uint8 _vendor, bytes32 _tradeID, uint256 _value, bytes calldata _sign) 
    payable external
    {
        require(msg.value > 0);
        require(msg.value == _value);
        bytes32 _hashPay = keccak256(abi.encodePacked(_vendor, _tradeID, _value));
        
        verifySign(_hashPay, _sign, _tradeID);
        payList[_tradeID] = true;
    
        emit Pay(_vendor, address(0x0), _value, _tradeID);
    }

    function payAltCoin(uint8 _vendor, address _coin, bytes32 _tradeID, uint256 _value, bytes calldata _sign) 
    external
    {
        bytes32 _hashPay = keccak256(abi.encodePacked(_vendor, _coin, _tradeID, _value));
        verifySign(_hashPay, _sign, _tradeID);
        payList[_tradeID] = true;
        
        require(safeTransferFrom(_coin, msg.sender, address(this), _value));
        emit Pay(_vendor, _coin, _value, _tradeID);
    }

    function verifySign(bytes32 _hashSwap, bytes memory _sign, bytes32 _tradeID) 
    private view
    {
        require(_hashSwap.recover(_sign) == signerAddress);
        require(!payList[_tradeID]);
    }
    
    /**
     * withdraw functions
    */
    function withdraw(address _token, address payable _to, uint256 _amount) 
    external onlyOwner
    {
        if (_token == address(0x0)) {
            _to.transfer(_amount);
        } else {
            require(safeTransfer(_token, _to, _amount));
        }
        emit Withdraw(_to, _token, _amount);
    }
    
    function multiTransfer(address _token, address payable[] calldata _addresses, uint256[] calldata _amounts)
    external onlyOwner
    {
        uint256 total = 0;
        uint8 i = 0;
        if (_token == address(0x0)) {
            for (i; i < _addresses.length; i++) {
                _addresses[i].transfer(_amounts[i]);
                total += _amounts[i];
            }
        } else {
            for (i; i < _addresses.length; i++) {
                require(safeTransfer(_token, _addresses[i], _amounts[i]));
                total += _amounts[i];
            }
        }
        
        emit Multisended(_token, total);
    }
    
    /**
     * secondary functions
    */
    function safeTransfer(address token, address to , uint value) private returns (bool result) 
    {
        TokenERC20(token).transfer(to,value);

        assembly {
            switch returndatasize()   
                case 0 {
                    result := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    result := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        require(result);
    }
    
    function safeTransferFrom(address token, address _from, address to, uint value) private returns (bool result) 
    {
        TokenERC20(token).transferFrom(_from, to, value);

        assembly {
            switch returndatasize()   
                case 0 {
                    result := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32) 
                    result := mload(0)
                }
                default {
                    revert(0, 0) 
                }
        }
        require(result);
    }
}