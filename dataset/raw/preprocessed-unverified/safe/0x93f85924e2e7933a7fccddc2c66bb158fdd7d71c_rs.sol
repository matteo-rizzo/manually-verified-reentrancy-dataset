/**

 *Submitted for verification at Etherscan.io on 2019-02-06

*/



pragma solidity ^0.5.3;















/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */









contract ERC20_Interface {

    

    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);   

    

}







contract PaidSelfDrop is Ownable {

    

    using SafeMath for uint;

    using AddressMakePayable for address;

    

    ERC20_Interface public constant SHNZ2 = ERC20_Interface(0x7c70c1093653Ca3aa47aC5D8F934125A0Aaa1645);

    

    uint public price = 17e13; 

    uint public dropAmount = 2000e18;

    



    

    function() external payable {

        require(msg.value >= price);

        if(msg.value > price) {

            msg.sender.transfer(msg.value.sub(price));

        }

        SHNZ2.transfer(msg.sender,dropAmount);

        address(_owner).makePayable().transfer(price);

    }

    

    function changePrice(uint _newPrice) public onlyOwner {

        require(_newPrice > 0 && _newPrice != price);

        price = _newPrice;

    }

    

    function withdrawSHNZ2(uint _amount) public onlyOwner {

        SHNZ2.transfer(owner(), _amount);

    }

}