/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

pragma solidity ^0.7.6;





contract ZippieAccountERC20 {
  address private owner;

  constructor() {
    owner = msg.sender; // Zippie Wallet
  }

  /**
    * @dev Approve owner to send a specific ERC20 token (max 2^256)
    * @param token token to be approved
    */
  function flushETHandTokens(address token, address payable to) public {
    require(msg.sender == owner);
    IERC20(token).transfer(to, IERC20(token).balanceOf(address(this)));
    selfdestruct(to); // Sponsor (any available ETH will be sent here)
  }
  
  function flushETH(address payable to) public {
    require(msg.sender == owner);
    selfdestruct(to); // Sponsor (any available ETH will be sent here)
  }
}

contract ZippieAccountERC20Deployer {
    address payable public _owner;

    constructor (address payable owner) {
        _owner = owner;
    }
    
    function setOwner(address payable newOwner) public {
        require(msg.sender == _owner, 'A');
        _owner = newOwner;
    }
    
    function batchSweepETH(bytes32[] calldata _salt) public {
        require(msg.sender == _owner, 'A');
        
        uint i;
    
        for (i = 0; i < _salt.length; i++) {
            ZippieAccountERC20 account = new ZippieAccountERC20{salt: _salt[i]}();
            account.flushETH(_owner);
        }
    }
        
    function batchSweepETHandTokens(IERC20[] calldata tokens, bytes32[] calldata _salt) public {
        require(msg.sender == _owner, 'A');

        require(tokens.length == _salt.length, 'B');

        uint i;
        for (i = 0; i < tokens.length; i++) {
            ZippieAccountERC20 account = new ZippieAccountERC20{salt: _salt[i]}();
            account.flushETHandTokens(address(tokens[i]), _owner);
        }
    }
        
    function getAddress(bytes32 _salt) public view returns (address) {
        address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            _salt,
            keccak256(abi.encodePacked(
                type(ZippieAccountERC20).creationCode)  
            ))
        ))));
        return predictedAddress;
    }
}