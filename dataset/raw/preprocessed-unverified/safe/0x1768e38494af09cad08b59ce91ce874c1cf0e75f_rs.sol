/**

 *Submitted for verification at Etherscan.io on 2018-09-07

*/



pragma solidity 0.4.24;



// File: zeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: zeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts/ZTXInterface.sol



contract ZTXInterface {

    function transferOwnership(address _newOwner) public;

    function mint(address _to, uint256 amount) public returns (bool);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function unpause() public;

}



// File: contracts/airdropper/AirDropperCore.sol



/**

 * @title AirDropperCore

 * @author Gustavo Guimaraes - <[email protected]>

 * @dev Contract for the ZTX airdrop

 */

contract AirDropperCore is Ownable {

    using SafeMath for uint256;



    mapping (address => bool) public claimedAirdropTokens;



    uint256 public numOfCitizensWhoReceivedDrops;

    uint256 public tokenAmountPerUser;

    uint256 public airdropReceiversLimit;



    ZTXInterface public ztx;



    event TokenDrop(address indexed receiver, uint256 amount);



    /**

     * @dev Constructor for the airdrop contract

     * @param _airdropReceiversLimit Cap of airdrop receivers

     * @param _tokenAmountPerUser Number of tokens done per user

     * @param _ztx ZTX contract address

     */

    constructor(uint256 _airdropReceiversLimit, uint256 _tokenAmountPerUser, ZTXInterface _ztx) public {

        require(

            _airdropReceiversLimit != 0 &&

            _tokenAmountPerUser != 0 &&

            _ztx != address(0),

            "constructor params cannot be empty"

        );

        airdropReceiversLimit = _airdropReceiversLimit;

        tokenAmountPerUser = _tokenAmountPerUser;

        ztx = ZTXInterface(_ztx);

    }



    function triggerAirDrops(address[] recipients)

        external

        onlyOwner

    {

        for (uint256 i = 0; i < recipients.length; i++) {

            triggerAirDrop(recipients[i]);

        }

    }



    /**

     * @dev Distributes tokens to recipient addresses

     * @param recipient address to receive airdropped token

     */

    function triggerAirDrop(address recipient)

        public

        onlyOwner

    {

        numOfCitizensWhoReceivedDrops = numOfCitizensWhoReceivedDrops.add(1);



        require(

            numOfCitizensWhoReceivedDrops <= airdropReceiversLimit &&

            !claimedAirdropTokens[recipient],

            "Cannot give more tokens than airdropShare and cannot airdrop to an address that already receive tokens"

        );



        claimedAirdropTokens[recipient] = true;



        // eligible citizens for airdrop receive tokenAmountPerUser in ZTX

        sendTokensToUser(recipient, tokenAmountPerUser);

        emit TokenDrop(recipient, tokenAmountPerUser);

    }



    /**

     * @dev Can be overridden to add sendTokensToUser logic. The overriding function

     * should call super.sendTokensToUser() to ensure the chain is

     * executed entirely.

     * @param recipient Address to receive airdropped tokens

     * @param tokenAmount Number of rokens to receive

     */

    function sendTokensToUser(address recipient, uint256 tokenAmount) internal {

    }

}



// File: contracts/airdropper/MintableAirDropper.sol



/**

 * @title MintableAirDropper

 * @author Gustavo Guimaraes - <[email protected]>

 * @dev Airdrop contract that mints ZTX tokens

 */

contract MintableAirDropper is AirDropperCore {

    /**

     * @dev Constructor for the airdrop contract.

     * NOTE: airdrop must be the token owner in order to mint ZTX tokens

     * @param _airdropReceiversLimit Cap of airdrop receivers

     * @param _tokenAmountPerUser Number of tokens done per user

     * @param _ztx ZTX contract address

     */

    constructor

        (

            uint256 _airdropReceiversLimit,

            uint256 _tokenAmountPerUser,

            ZTXInterface _ztx

        )

        public

        AirDropperCore(_airdropReceiversLimit, _tokenAmountPerUser, _ztx)

    {}



    /**

     * @dev override sendTokensToUser logic

     * @param recipient Address to receive airdropped tokens

     * @param tokenAmount Number of rokens to receive

     */

    function sendTokensToUser(address recipient, uint256 tokenAmount) internal {

        ztx.mint(recipient, tokenAmount);

        super.sendTokensToUser(recipient, tokenAmount);

    }



    /**

     * @dev Self-destructs contract

     */

    function kill(address newZuluOwner) external onlyOwner {

        require(

            numOfCitizensWhoReceivedDrops >= airdropReceiversLimit,

            "only able to kill contract when numOfCitizensWhoReceivedDrops equals or is higher than airdropReceiversLimit"

        );



        ztx.unpause();

        ztx.transferOwnership(newZuluOwner);

        selfdestruct(owner);

    }

}