/**
 *Submitted for verification at Etherscan.io on 2020-11-06
*/

// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------
// CHIP Utility Token
//
// Symbol        : CHIP
// Name          : CHIP Utility Token
// Initial supply: 100,000,000.000000
// Decimals      : 6
// ----------------------------------------------------------------------------
pragma solidity ^0.7.4;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and a
// fixed supply
// ----------------------------------------------------------------------------
contract CHIPToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public constant symbol = "CHIP";
    string public constant name = "CHIP Utility Token";
    uint public constant decimals = 6;
    uint totalSupplyAmount;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;

    address public serviceContractAddress;

    constructor() {
        totalSupplyAmount = 100000000 * 10**uint(decimals);
        emit Mint(totalSupplyAmount);

        balances[owner] = totalSupplyAmount;
        emit Transfer(address(0), owner, totalSupplyAmount);
    }

    // Fix for the ERC20 short address attack
    modifier onlyPayloadSize(uint _size) {
        require(msg.data.length == _size + 4, "Input length error");
        _;
    }

    // When new coins are minted after contract creation
    event Mint(uint _amount);


    // ----------------------------------------------------------------------------
    // Standard ERC20 implementations
    // ----------------------------------------------------------------------------
    // Read
    function totalSupply() public override view returns (uint) {
        return totalSupplyAmount.subSafe(balances[address(0)]);
    }
    function balanceOf(address _tokenOwner) public override view returns (uint) {
        return balances[_tokenOwner];
    }
    function allowance(address _tokenOwner, address _spender) public override view returns (uint) {
        return allowed[_tokenOwner][_spender];
    }

    // Write
    function transfer(address _to, uint _amount) public override onlyPayloadSize(2 * 32) returns (bool) {
        require(_to != address(this), "Can not transfer to this");
        if(serviceContractAddress != address(0)) require(_to != serviceContractAddress, "Address not allowed");

        balances[msg.sender] = balances[msg.sender].subSafe(_amount);
        balances[_to] = balances[_to].addSafe(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    function approve(address _spender, uint _amount) public override onlyPayloadSize(2 * 32) returns (bool) {
        require(_amount <= balances[msg.sender], "Insufficient balance");

        // To change the approve amount you first have to reduce the`
        // allowance to zero by calling `approve(_spender, 0)` if it is not
        // already 0 to mitigate the race condition described here:
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if(_amount > 0) require(allowed[msg.sender][_spender] == 0, "Zero allowance first");

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
    function transferFrom(address _tokenOwner, address _to, uint _amount) public override onlyPayloadSize(3 * 32) returns (bool) {
        require(_to != address(this), "Can not transfer to this");
        allowed[_tokenOwner][msg.sender] = allowed[_tokenOwner][msg.sender].subSafe(_amount);
        balances[_tokenOwner] = balances[_tokenOwner].subSafe(_amount);
        balances[_to] = balances[_to].addSafe(_amount);
        emit Transfer(_tokenOwner, _to, _amount);
        return true;
    }


    // ----------------------------------------------------------------------------
    // Other admin, common and courtesy functions
    // ----------------------------------------------------------------------------
    function approveAndCall(address _spender, uint _amount, bytes memory _data) public returns (bool) {
        // Prevent ERC20 short address attack
        // _data length is not fixed. These bytes are packed into 32 byte chunks
        uint length256;
        if(_data.length > 0) {
            length256 = _data.length / 32;
            if(32 * length256 < _data.length) length256++;
        }
        require(msg.data.length == (((4 + length256) * 32) + 4), "Input length error");
        require(_amount <= balances[msg.sender], "Insufficient balance");

        // To change the approve amount you first have to reduce the`
        // allowance to zero by calling `approve(_spender, 0)` if it is not
        // already 0 to mitigate the race condition described here:
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if(_amount > 0) require(allowed[msg.sender][_spender] == 0, "Zero allowance first");

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _amount, address(this), _data);
        return true;
    }
    function mint(uint _newTokens) public onlyOwner {
        totalSupplyAmount = totalSupplyAmount.addSafe(_newTokens);
        emit Mint(totalSupplyAmount);

        balances[owner] = balances[owner].addSafe(_newTokens);
        emit Transfer(address(0), owner, _newTokens);
    }
    function totalOutstanding() public view returns (uint) {
        // Outstanding token = total supply - contract owner - burned
        uint outOfCirculation;
        if(owner == address(0)) outOfCirculation = balances[address(0)];
        else outOfCirculation = balances[address(0)].addSafe(balances[owner]);
        return totalSupplyAmount.subSafe(outOfCirculation);
    }
    function setServiceContractAddress(address _setAddress) public onlyOwner onlyPayloadSize(1 * 32) {
        // Prevent lost coins in companion service contract when user accidentally calls transfer()
        serviceContractAddress = _setAddress;
    }
    // Retrieve any ERC20 tokens accidentally sent to this contract for owner
    function transferAnyERC20Token(address _fromTokenContract, uint _amount) public onlyOwner returns (bool success) {
        return ERC20Interface(_fromTokenContract).transfer(owner, _amount);
    }

}