/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

pragma solidity ^0.5.10;



contract IERC223ReceivingContract {

    /// @dev Standard ERC223 function that will handle incoming token transfers.
    /// @param _from  Token sender address.
    /// @param _value Amount of tokens.
    /// @param _data  Transaction metadata.
    function tokenFallback(address _from, uint _value, bytes memory _data) public;

}

contract IDetherToken {
    function mintingFinished() view public returns(bool);
    function name() view public returns(string memory);
    function approve(address _spender, uint256 _value) public returns(bool);
    function totalSupply() view public returns(uint256);
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool);
    function decimals() view public returns(uint8);
    function mint(address _to, uint256 _amount) public returns(bool);
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns(bool);
    function balanceOf(address _owner) view public returns(uint256 balance);
    function finishMinting() public returns(bool);
    function owner() view public returns(address);
    function symbol() view public returns(string memory);
    function transfer(address _to, uint256 _value) public returns(bool);
    function transfer(address _to, uint256 _value, bytes memory _data) public returns(bool);
    function increaseApproval(address _spender, uint256 _addedValue) public returns(bool);
    function allowance(address _owner, address _spender) view public returns(uint256);
    function transferOwnership(address newOwner) public;
}



contract TaxCollector is IERC223ReceivingContract, Ownable {

    // Address where collected taxes are sent to
    address public taxRecipient;
    bool public unchangeable;
    IDetherToken public dth;
    // Daily tax rate (there are no floats in solidity)
    event ReceivedTaxes(address indexed tokenFrom, uint taxes, address indexed from);

    constructor (address _dth, address _taxRecipient) public {
        dth = IDetherToken(_dth);
        taxRecipient = _taxRecipient;
    }

    function unchangeableRecipient()
      onlyOwner
      external
    {
        unchangeable = true;
    }

    function changeRecipient(address _newRecipient)
      external 
      onlyOwner
    {
        require(!unchangeable, 'Impossible to change the recipient');
        taxRecipient = _newRecipient;
    }

    function collect()
      public
    {
        uint balance = dth.balanceOf(address(this));
        dth.transfer(taxRecipient, balance);
    }

    function tokenFallback(address _from, uint _value, bytes memory _data) 
      public
    {
      emit ReceivedTaxes(msg.sender, _value, _from);
    }
}