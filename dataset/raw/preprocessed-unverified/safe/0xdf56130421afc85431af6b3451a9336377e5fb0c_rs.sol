pragma solidity ^0.4.24;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract ERC20 {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}





contract BountyClaim is Ownable {

    mapping (address => uint256) public allowance;

    address _tokenAddress = 0x2A22e5cCA00a3D63308fa39f29202eB1b39eEf52;



    function() public payable {

        require(allowance[msg.sender] > 0);

        ERC20(_tokenAddress).transfer(msg.sender, allowance[msg.sender]);

        allowance[msg.sender] = 0;

    }



    function withdraw(uint256 amount) external onlyOwner {

        ERC20(_tokenAddress).transfer(msg.sender, amount);

    }



    function changeAllowances(address[] addresses, uint256[] values) external onlyOwner returns (uint256) {

        uint256 i = 0;

        while (i < addresses.length) {

            allowance[addresses[i]] = values[i];

            i += 1;

        }

        return(i);

    }

}