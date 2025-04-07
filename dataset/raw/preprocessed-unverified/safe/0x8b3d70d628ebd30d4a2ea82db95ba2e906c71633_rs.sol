/**

 *Submitted for verification at Etherscan.io on 2019-02-24

*/



/**

 * Copyright 2017¨C2019, bZeroX, LLC. All Rights Reserved.

 * Licensed under the Apache License, Version 2.0.

 */

 

pragma solidity 0.5.2;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract BZxOwnable is Ownable {



    address public bZxContractAddress;



    event BZxOwnershipTransferred(address indexed previousBZxContract, address indexed newBZxContract);



    // modifier reverts if bZxContractAddress isn't set

    modifier onlyBZx() {

        require(msg.sender == bZxContractAddress, "only bZx contracts can call this function");

        _;

    }



    /**

    * @dev Allows the current owner to transfer the bZx contract owner to a new contract address

    * @param newBZxContractAddress The bZx contract address to transfer ownership to.

    */

    function transferBZxOwnership(address newBZxContractAddress) public onlyOwner {

        require(newBZxContractAddress != address(0) && newBZxContractAddress != owner, "transferBZxOwnership::unauthorized");

        emit BZxOwnershipTransferred(bZxContractAddress, newBZxContractAddress);

        bZxContractAddress = newBZxContractAddress;

    }



    /**

    * @dev Allows the current owner to transfer control of the contract to a newOwner.

    * @param newOwner The address to transfer ownership to.

    * This overrides transferOwnership in Ownable to prevent setting the new owner the same as the bZxContract

    */

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0) && newOwner != bZxContractAddress, "transferOwnership::unauthorized");

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

    }

}







contract EIP20Wrapper {



    function eip20Transfer(

        address token,

        address to,

        uint256 value)

        internal

        returns (bool result) {



        NonCompliantEIP20(token).transfer(to, value);



        assembly {

            switch returndatasize()   

            case 0 {                        // non compliant ERC20

                result := not(0)            // result is true

            }

            case 32 {                       // compliant ERC20

                returndatacopy(0, 0, 32) 

                result := mload(0)          // result == returndata of external call

            }

            default {                       // not an not an ERC20 token

                revert(0, 0) 

            }

        }



        require(result, "eip20Transfer failed");

    }



    function eip20TransferFrom(

        address token,

        address from,

        address to,

        uint256 value)

        internal

        returns (bool result) {



        NonCompliantEIP20(token).transferFrom(from, to, value);



        assembly {

            switch returndatasize()   

            case 0 {                        // non compliant ERC20

                result := not(0)            // result is true

            }

            case 32 {                       // compliant ERC20

                returndatacopy(0, 0, 32) 

                result := mload(0)          // result == returndata of external call

            }

            default {                       // not an not an ERC20 token

                revert(0, 0) 

            }

        }



        require(result, "eip20TransferFrom failed");

    }



    function eip20Approve(

        address token,

        address spender,

        uint256 value)

        internal

        returns (bool result) {



        NonCompliantEIP20(token).approve(spender, value);



        assembly {

            switch returndatasize()   

            case 0 {                        // non compliant ERC20

                result := not(0)            // result is true

            }

            case 32 {                       // compliant ERC20

                returndatacopy(0, 0, 32) 

                result := mload(0)          // result == returndata of external call

            }

            default {                       // not an not an ERC20 token

                revert(0, 0) 

            }

        }



        require(result, "eip20Approve failed");

    }

}



contract BZxVault is EIP20Wrapper, BZxOwnable {



    // Only the bZx contract can directly deposit ether

    function() external payable onlyBZx {}



    function withdrawEther(

        address payable to,

        uint256 value)

        public

        onlyBZx

        returns (bool)

    {

        uint256 amount = value;

        if (amount > address(this).balance) {

            amount = address(this).balance;

        }



        return (to.send(amount));

    }



    function depositToken(

        address token,

        address from,

        uint256 tokenAmount)

        public

        onlyBZx

        returns (bool)

    {

        if (tokenAmount == 0) {

            return false;

        }



        eip20TransferFrom(

            token,

            from,

            address(this),

            tokenAmount);



        return true;

    }



    function withdrawToken(

        address token,

        address to,

        uint256 tokenAmount)

        public

        onlyBZx

        returns (bool)

    {

        if (tokenAmount == 0) {

            return false;

        }



        eip20Transfer(

            token,

            to,

            tokenAmount);



        return true;

    }



    function transferTokenFrom(

        address token,

        address from,

        address to,

        uint256 tokenAmount)

        public

        onlyBZx

        returns (bool)

    {

        if (tokenAmount == 0) {

            return false;

        }



        eip20TransferFrom(

            token,

            from,

            to,

            tokenAmount);



        return true;

    }

}