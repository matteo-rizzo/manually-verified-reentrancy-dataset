/**

 *Submitted for verification at Etherscan.io on 2018-11-18

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts\FreeDropper.sol







contract FreeDropper is Ownable {



    event DistributionCompleted(address indexed from, address indexed token, uint totalAmount);

    

    using SafeMath for uint;



    function drop(ERC20 _token, address[] _beneficiary, uint[] _amount, uint _totalAmount) external payable {

        require(_beneficiary.length == _amount.length, "beneficiary and amount length do not match");



        require(_token.allowance(msg.sender, address(this)) >= _totalAmount, "not enough allowance");

        uint distributedTokens;

        

        for(uint i = 0;i < _beneficiary.length;i++){

            

            require(_beneficiary[i] != address(0), "beneficiary address is 0x0");

            require(_token.transferFrom(msg.sender,_beneficiary[i],_amount[i]), "Transfer from failed");

            distributedTokens += _amount[i];

        }



        emit DistributionCompleted(msg.sender, address(_token), _totalAmount);

            

    }



    function withdrawTokens(ERC20 _erc20, address _receiver, uint _amount) public onlyOwner {

        require(_receiver != address(0x0), "receiver address is 0x0");

        _erc20.transfer(_receiver, _amount);

    }



    function withdrawETH(address _receiver, uint _amount) public onlyOwner {

        _receiver.transfer(_amount);

    }



}