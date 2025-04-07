/**

 *Submitted for verification at Etherscan.io on 2018-11-06

*/



pragma solidity ^0.4.24;



contract TeamDreamHub {

    using SafeMath for uint256;

    

//==============================================================================

//     _| _ _|_ _    _ _ _|_    _   .

//    (_|(_| | (_|  _\(/_ | |_||_)  .

//=============================|================================================    

	address private owner;

	uint256 maxShareHolder = 100;

    mapping(uint256 => ShareHolder) public shareHolderTable;	



	struct ShareHolder {

        address targetAddr;  // target address

        uint256 ratio; 		 // profit ¡ë

    }	

//==============================================================================

//     _ _  _  __|_ _    __|_ _  _  .

//    (_(_)| |_\ | | |_|(_ | (_)|   .  (initial data setup upon contract deploy)

//==============================================================================    

    constructor()

        public

    {

		owner = msg.sender;

    }

//==============================================================================

//     _ _  _  _|. |`. _  _ _  .

//    | | |(_)(_||~|~|(/_| _\  .  (these are safety checks)

//==============================================================================    

    /**

     * @dev prevents contracts from interacting with fomo3d 

     */

    modifier isHuman() {

        address _addr = msg.sender;

		require (_addr == tx.origin);

		

        uint256 _codeLength;

        

        assembly {_codeLength := extcodesize(_addr)}

        require(_codeLength == 0, "sorry humans only");

        _;

    }    

	

	modifier onlyOwner() {

		require (msg.sender == owner);

		_;

	}



	

//==============================================================================

//     _    |_ |. _   |`    _  __|_. _  _  _  .

//    |_)|_||_)||(_  ~|~|_|| |(_ | |(_)| |_\  .  (use these to interact with contract)

//====|=========================================================================



    /**

     * @dev fallback function

     */

    function()      

		isHuman()

        public

        payable

    {

		// if use this through SC, will fail because gas not enough.

		distribute(msg.value);

    }

	

    function deposit()

        external

        payable

    {

		distribute(msg.value);

    }

	

	function distribute(uint256 _totalInput)

        private

    {		

		uint256 _toBeDistribute = _totalInput;

		

		uint256 fund;

		address targetAddress;

		for (uint i = 0 ; i < maxShareHolder; i++) {			

			targetAddress = shareHolderTable[i].targetAddr;

			if(targetAddress != address(0))

			{

				fund = _totalInput.mul(shareHolderTable[i].ratio) / 100;			

				targetAddress.transfer(fund);

				_toBeDistribute = _toBeDistribute.sub(fund);

			}

			else

				break;

		}		

        

		//remainder to contract owner

		owner.transfer(_toBeDistribute);	

    }

	

	

	//setup the target addresses abd ratio (sum = 100%)

    function updateEntry(uint256 tableIdx, address _targetAddress, uint256 _ratio)

        onlyOwner()

        public

    {

		require (tableIdx < maxShareHolder);

		require (_targetAddress != address(0));

		require (_ratio <= 100);

		

		uint256 totalShare = 0;		

		for (uint i = 0 ; i < maxShareHolder; i++) {

			if(i != tableIdx)

				totalShare += shareHolderTable[i].ratio;

			else

				totalShare += _ratio;

			

			if(totalShare > 100) // if larger than 100%, should REJECT

				revert('totalShare is larger than 100.');

		}

		

		shareHolderTable[tableIdx] = ShareHolder(_targetAddress,_ratio);        

    }	

	

	//function removeEntry(uint256 tableIdx)

    //    onlyOwner()

    //    public

    //{

	//	require (tableIdx < maxShareHolder);

	//			

    //    shareHolderTable[tableIdx] = ShareHolder(address(0),0);

    //}		

}



//==============================================================================

// ¨X¨T¨[©°©¤©´©°©´©°©°©Ð©´©Ð©¤©´©°©¤©´©°©¤©´©°©Ð©´  ¨X¨T¨[©°©¤©´©°©Ð©´©°©¤©´ 

// ¨U  ©¦ ©¦©¦©¦©¦ ©¦ ©À©Ð©¼©À©¤©È©¦   ©¦   ¨U  ©¦ ©¦ ©¦©¦©À©È  

// ¨^¨T¨a©¸©¤©¼©¼©¸©¼ ©Ø ©Ø©¸©¤©Ø ©Ø©¸©¤©¼ ©Ø   ¨^¨T¨a©¸©¤©¼©¤©Ø©¼©¸©¤©¼ 

//==============================================================================

/**

 * @title SafeMath v0.1.9

 * @dev Math operations with safety checks that throw on error

 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor

 * - added sqrt

 * - added sq

 * - added pwr 

 * - changed asserts to requires with error log outputs

 * - removed div, its useless

 */

