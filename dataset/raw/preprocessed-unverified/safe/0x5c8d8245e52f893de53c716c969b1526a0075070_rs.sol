pragma solidity ^0.4.18;



contract ERC20Interface {

  function transferFrom(address _from, address _to, uint _value) public returns (bool){}

}







contract ENXAirDrop is Ownable {



  function airDrop ( address contractObj,

                    address   tokenRepo,

                    address[] airDropDesinationAddress,

                    uint[] amounts) public onlyOwner{



    for( uint i = 0 ; i < airDropDesinationAddress.length ; i++ ) {



        ERC20Interface(contractObj).transferFrom( tokenRepo, airDropDesinationAddress[i],amounts[i]);

    }

   }

}