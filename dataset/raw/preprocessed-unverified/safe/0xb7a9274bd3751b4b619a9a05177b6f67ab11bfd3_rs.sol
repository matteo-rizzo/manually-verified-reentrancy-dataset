/**
 *Submitted for verification at Etherscan.io on 2021-03-31
*/

// SPDX-License-Identifier: MIT

/*
MIT License
Copyright (c) 2020 Hydro Money
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

pragma solidity 0.6.12;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */


/**
 * @title ERC20 interface
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



/**
 * @title Hydro ERC20-BEP20 Swap Contract
 */
contract HydroTokenSwap is Ownable {
    using SafeMath for uint256;
    uint256 public contractTotalAmountSwapped;

    address constant Hydro_ADDRESS= 0x946112efaB61C3636CBD52DE2E1392D7A75A6f01;
    address Main_ADDRESS= 0x4aE8bfB81205837DE1437De26D02E5ca87694714;
    bool public isActive;
    
    struct User {
      address userAdd;
      uint256 totalAmountSwapped;
    }
    
    //a mapping to keep the details of users
    mapping(address => User) public userDetails;

    //main event that is emitted after a successful deposit
    event SwapDeposit(address indexed depositor, uint256 outputAmount);
    
    //check if the contract is open to swaps
    function isSwapActive() public view returns (bool) {
      return isActive;
    }
    
    //make sure contract is open to swaps
    modifier hasActiveSwap {
        require(isSwapActive(), "Swapping is currently paused");
        _;
    }



    /**
     * @dev Allows the user to deposit some amount of Hydro tokens. Records user/swap data and emits a SwapDeposit event.
     * @param amount Amount of input tokens to be swapped.
     */
    function swap( uint256 amount) external hasActiveSwap {
        
        require(amount > 0, "Input amount must be positive.");
        uint256 outputAmount = amount;
        require(outputAmount > 0, "Amount too small.");
        require(IERC20(Hydro_ADDRESS).transferFrom(msg.sender, Main_ADDRESS, amount), "Transferring Hydro tokens from user failed");
        userDetails[msg.sender].totalAmountSwapped+=amount;
        userDetails[msg.sender].userAdd=msg.sender;
        contractTotalAmountSwapped+=amount;
        emit SwapDeposit(msg.sender,amount);
        
    }
    
    function totalAmountSwappedInContract(address _user) public view returns(uint256){
        return userDetails[_user].totalAmountSwapped;
    }
    
    function grossAmountSwapped() public view returns(uint256){
        return contractTotalAmountSwapped;
    }
    
    //allow the owner to activate the escrow contract
    function openEscrow() public onlyOwner hasActiveSwap returns(bool){
        isActive=true;
    }
    
     //allow the owner to deactivate the escrow contract
    function closeEscrow() public onlyOwner returns(bool){
        isActive=false;
    }

  //allow owner to rescue any tokens sent to the contract

    function transferOut(address _token) public onlyOwner returns(bool){
        IERC20 token= IERC20(_token); 
        uint256 balance= token.balanceOf(address(this));
        require(token.transfer(msg.sender,balance),"HydroSwap: Token Transfer error");
    return true;
    }
    
 
      /**
    
    !!!!!!!!!!!!!!!!!!
    !!!!!CAUTION!!!!!!
    !!!!!!!!!!!!!!!!!!
    
    **/
    //allow owner to change central wallet
    
    function changeCentralWallet(address _newWallet) public onlyOwner returns(bool){
        require(_newWallet!=address(0),"Error: Burn address not supported");
        Main_ADDRESS=_newWallet;
        return true;
    }
  
}