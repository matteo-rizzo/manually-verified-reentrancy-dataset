/**

 *Submitted for verification at Etherscan.io on 2018-10-01

*/



pragma solidity 0.4.25;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title Authorizable

 * @dev The Authorizable contract has authorized addresses, and provides basic authorization control

 * functions, this simplifies the implementation of "multiple user permissions".

 */

contract Authorizable is Ownable {

    

    mapping(address => bool) public authorized;

    event AuthorizationSet(address indexed addressAuthorized, bool indexed authorization);



    /**

     * @dev The Authorizable constructor sets the first `authorized` of the contract to the sender

     * account.

     */

    constructor() public {

        authorize(msg.sender);

    }



    /**

     * @dev Throws if called by any account other than the authorized.

     */

    modifier onlyAuthorized() {

        require(authorized[msg.sender]);

        _;

    }



    /**

     * @dev Allows 

     * @param _address The address to change authorization.

     */

    function authorize(address _address) public onlyOwner {

        require(!authorized[_address]);

        emit AuthorizationSet(_address, true);

        authorized[_address] = true;

    }

    /**

     * @dev Disallows

     * @param _address The address to change authorization.

     */

    function deauthorize(address _address) public onlyOwner {

        require(authorized[_address]);

        emit AuthorizationSet(_address, false);

        authorized[_address] = false;

    }

}



contract ZmineRandom is Authorizable {

    

    uint256 public counter = 0;

    mapping(uint256 => uint256) public randomResultMap;

    mapping(uint256 => uint256[]) public randomInputMap;

    

 

    function random(uint256 min, uint256 max, uint256 lotto) public onlyAuthorized  {

        

		require(min > 0);

        require(max > min);

         

        counter++;

        uint256 result = ((uint256(keccak256(abi.encodePacked(lotto))) 

                        + uint256(keccak256(abi.encodePacked(counter))) 

                        + uint256(keccak256(abi.encodePacked(block.difficulty)))

                        + uint256(keccak256(abi.encodePacked(block.number - 1)))

                    ) % (max-min+1)) - min;

        

        uint256[] memory array = new uint256[](5);

        array[0] = min;

        array[1] = max;

        array[2] = lotto;

        array[3] = block.difficulty;

        array[4] = block.number;

        randomInputMap[counter] = array;

         

        randomResultMap[counter] = result;

    }



    function checkHash(uint256 n) public pure returns (uint256){

        return uint256(keccak256(abi.encodePacked(n)));

    }

}