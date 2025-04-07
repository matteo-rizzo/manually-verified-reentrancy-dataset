pragma solidity 0.4.24;







contract Vault is Ownable { 



    function () public payable {



    }



    function getBalance() public view returns (uint) {

        return address(this).balance;

    }



    function withdraw(uint amount) public onlyOwner {

        require(address(this).balance >= amount);

        owner.transfer(amount);

    }



    function withdrawAll() public onlyOwner {

        withdraw(address(this).balance);

    }

}