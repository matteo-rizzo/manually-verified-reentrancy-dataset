/**
 *Submitted for verification at Etherscan.io on 2020-12-08
*/

pragma solidity 0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */


contract Token {
    
    uint8 public decimals;

    function transfer(address _to, uint256 _value) public returns (bool success) {}
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {}

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {}

    function balanceOf(address account) external view returns (uint256) {}
}

contract MultiTransfer {
    using SafeMath for uint256;
    
    address public owner;
    uint public tokenSendFee; // in wei
    uint public ethSendFee; // in wei

    
    constructor() public payable{
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }
    
    function bulkSendEth(address[] addresses, uint256[] amounts) public payable returns(bool success){
        uint total = 0;
        for(uint8 i = 0; i < amounts.length; i++){
            total = total.add(amounts[i]);
        }
        
        //ensure that the ethreum is enough to complete the transaction
        uint requiredAmount = total.add(ethSendFee * 1 wei); //.add(total.div(100));
        require(msg.value >= (requiredAmount * 1 wei));
        
        //transfer to each address
        for (uint8 j = 0; j < addresses.length; j++) {
            addresses[j].transfer(amounts[j] * 1 wei);
        }
        
        //return change to the sender
        if(msg.value * 1 wei > requiredAmount * 1 wei){
            uint change = msg.value.sub(requiredAmount);
            msg.sender.transfer(change * 1 wei);
        }
        return true;
    }
    
    function getbalance(address addr) public constant returns (uint value){
        return addr.balance;
    }
    
    function deposit() payable public returns (bool){
        return true;
    }
    
    function withdrawEther(address addr, uint amount) public onlyOwner returns(bool success){
        addr.transfer(amount * 1 wei);
        return true;
    }
    
    function withdrawToken(Token tokenAddr, address _to, uint _amount) public onlyOwner returns(bool success){
        tokenAddr.transfer(_to, _amount );
        return true;
    }
    
    function bulkSendToken(Token tokenAddr, address[] addresses, uint256[] amounts) public payable returns(bool success){
        require(msg.value >= tokenSendFee);
        uint total = 0;
        address multisendContractAddress = this;
        for(uint8 i = 0; i < amounts.length; i++){
            total = total.add(amounts[i]);
        }

        require(total <= tokenAddr.balanceOf(msg.sender));
        
        // check if user has enough balance
        // require(total <= tokenAddr.allowance(msg.sender, multisendContractAddress));
        
        // transfer token to addresses
        for (uint8 j = 0; j < addresses.length; j++) {
            require(tokenAddr.transferFrom(msg.sender, addresses[j], amounts[j]));
        }

        return true;        
    }
    
    function setTokenFee(uint _tokenSendFee) public onlyOwner returns(bool success){
        tokenSendFee = _tokenSendFee;
        return true;
    }
    
    function setEthFee(uint _ethSendFee) public onlyOwner returns(bool success){
        ethSendFee = _ethSendFee;
        return true;
    }
    
    function destroy (address _to) public onlyOwner {
        selfdestruct(_to);
    }
}