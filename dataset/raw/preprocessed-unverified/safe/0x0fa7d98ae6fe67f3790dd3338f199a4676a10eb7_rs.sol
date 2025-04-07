/**

 *Submitted for verification at Etherscan.io on 2018-12-02

*/



pragma solidity ^0.4.25;

















contract Erc20Contract {

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

}



/**

 * @title Destructible

 * @dev Base token_accessor that can be destroyed by owner. All funds in token_accessor will be sent to the owner.

 */

contract Destructible is Ownable {



    constructor() public payable { }



    /**

     * @dev Transfers the current balance to the owner and terminates the token_accessor.

     */

    function destroy() onlyGodOwner public {

        selfdestruct(godOwner);

    }



    function destroyAndSend(address _recipient) onlyGodOwner public {

        selfdestruct(_recipient);

    }

}





contract Airdrop is Ownable, Destructible {

    using SafeMath for uint256;



    event Transfer(address indexed _from, address indexed _to, uint256 value);



    constructor() public payable {}



    function() public payable{}



    function deposit() public payable {}



    function batchTransferToken(address _tokenAddr, address[] _toList, uint256[] _values) onlyOwner public {

        require(_toList.length >= 1 && _toList.length == _values.length);

        Erc20Contract erc20 = Erc20Contract(_tokenAddr);

        uint256 i = 0;

        while (i < _toList.length) {

            erc20.transfer(_toList[i], _values[i]);

            i += 1;

        }

    }



    function transferToken(address _tokenAddr, address _to, uint256 _value) onlyOwner public {

        require(_tokenAddr != address(0x0) && _to != address(0x0) && _value > 0);

        Erc20Contract erc20 = Erc20Contract(_tokenAddr);

        erc20.transfer(_to,_value);

    }



    function balance(address _tokenAddr) public view returns (uint256){

        Erc20Contract token = Erc20Contract(_tokenAddr);

        return token.balanceOf(msg.sender);

    }



    function withdrawETH(uint256 _value) onlyOwner public{

        msg.sender.transfer(_value);

    }



    function batchTransferETH(address[] _toList, uint256[] _values) payable onlyOwner public {

        require(_toList.length >= 1 && _toList.length == _values.length);

        uint256 i = 0;

        while (i < _toList.length) {

            _toList[i].transfer(_values[i]);

            i += 1;

        }

    }



    function transferETHs(address[] _toList, uint256 _value) payable onlyOwner public {

        require(_toList.length >= 1 && _value > 0);

        uint256 i = 0;

        while (i < _toList.length) {

            _toList[i].transfer(_value);

            i += 1;

        }

    }

}