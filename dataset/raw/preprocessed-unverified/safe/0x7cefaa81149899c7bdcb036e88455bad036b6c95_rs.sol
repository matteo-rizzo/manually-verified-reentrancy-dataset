/**

 *Submitted for verification at Etherscan.io on 2018-12-24

*/



pragma solidity ^0.4.25;



// ----------------------------------------------------------------------------

// 'V30yrs'

// The one and only original 'Valtteri 30yrs 28.12.2018' token in existence.

//

// Congrats for getting old(-ish)! 

// And SMILE! You're now eternally in the ETH blockchain ;)

//

// /Simo

// ----------------------------------------------------------------------------



// An attempt to satisfy some services





// Yay, the actual token.

contract V30yrsToken is IERC20 {

    

    address private _owner = 0x1Ce111e1D3d45078De74a8C201aB2F619F130147;

    address private _preApprovedFor;

	 

    // Constructor

    constructor() public {

        emit Transfer(address(0),_owner, 1);

    }

    

    //Trivial getters

    function name() public view returns (string) {

	    return "Valtteri 30yrs 28.12.2018";

	}

    function symbol() public view returns (string) {

	    return "V30yrs";

	}

	function decimals() public view returns (uint8) {

	    return 0; // There are no pieces, just THE piece. 

	}

    function totalSupply() public view returns (uint256) {

        return 1; // See? There really is just this one.

    }

    function balanceOf(address owner) public view returns (uint256) {

        if (owner == _owner) 

            return 1;

		return 0;

    }

    

	// Transfer ownership.

    function transfer(address to, uint256 value) public returns (bool) {

		// Only owner can transfer. 0 transfer ok.

		require(msg.sender == _owner);

        require (value == 1 || value == 0);

		require(to != address(0));



		if (value == 1)

			_owner = to;

        

        emit Transfer(msg.sender, to, value);

    

        return true;

    }

    

    // Pre-approved transfer  

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        require(from == _owner); // Single coin, single owner

		require(to != address(0));

		require(value == 1 || value == 0);

		

		if (value == 1)

			_owner = to;

		

        emit Transfer(from, to, value);

        return true;

    }

    

	// Pre-approve

    function approve(address spender, uint256 value) public returns (bool) {

    	require(spender != address(0));

		require(value == 1 || value == 0);

	

		if (msg.sender == _owner && value == 1)

			_preApprovedFor = spender;

		else

			_preApprovedFor = address(0);

    

        emit Approval(msg.sender, spender, value);

        return true;

    }

	

    // Allowance

    function allowance(address owner, address spender) public view returns (uint256) {

		if (owner == _owner && spender == _preApprovedFor)

			return 1;

		return 0;

    }

    

    // Don't accept ETH

    function () public payable {

        revert();

    }



    // That special something

	function haiku() public pure returns (string) {

	    return "Valtteri my man,\ndo NOT shave that beard again.\nYou look like a chic.";

	}

	

}