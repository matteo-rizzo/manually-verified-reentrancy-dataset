/**

 *Submitted for verification at Etherscan.io on 2019-03-03

*/



pragma solidity 0.4.18;



// File: contracts/ERC20Interface.sol



// https://github.com/ethereum/EIPs/issues/20





// File: contracts/mockContracts/MockERC20.sol







// File: contracts/mockContracts/MiniMeWrapper.sol



contract MiniMeWrapper {

    MockERC20 public token;

    string public symbol = "TST";



    function MiniMeWrapper(MockERC20 _token, string _symbol) public {

        require(_token != MockERC20(0));



        token = _token;

        symbol = _symbol;

    }



    function symbol() public view returns(string) {

        return symbol;

    }



    function decimals() public view returns(uint digits) {

        return token.decimals();

    }



    function totalSupplyAt(uint _blockNumber) public constant returns(uint) {

        _blockNumber;

        return token.totalSupply();

    }



    function balanceOfAt(address _owner, uint _blockNumber) public constant returns (uint) {

        _blockNumber;

        return token.balanceOf(_owner);

    }

}