/**

 *Submitted for verification at Etherscan.io on 2018-09-20

*/



pragma solidity ^0.4.24;



/*

    @title Provides support and utilities for contract ownership

*/





contract BatchTransfer is Ownable {



    /*

        @dev constructor



    */

    constructor () public Ownable(msg.sender) {}



    function batchTransfer(address[] _destinations, uint256[] _amounts) 

        public

        ownerOnly()

        {

            require(_destinations.length == _amounts.length);



            for (uint i = 0; i < _destinations.length; i++) {

                if (_destinations[i] != 0x0) {

                    _destinations[i].transfer(_amounts[i]);

                }

            }

        }



    function batchTransfer(address[] _destinations, uint256 _amount) 

        public

        ownerOnly()

        {

            require(_destinations.length > 0);



            for (uint i = 0; i < _destinations.length; i++) {

                if (_destinations[i] != 0x0) {

                    _destinations[i].transfer(_amount);

                }

            }

        }

        

    function transfer(address _destination, uint256 _amount)

        public

        ownerOnly()

        {

            require(_destination != 0x0 && _amount > 0);

            _destination.transfer(_amount);

        }



    function transferAllToOwner()

        public

        ownerOnly()

        {

            address(this).transfer(address(this).balance);

        }

        

    function() public payable { }

}