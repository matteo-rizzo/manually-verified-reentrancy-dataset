/**

 *Submitted for verification at Etherscan.io on 2018-09-26

*/



pragma solidity 0.4.24;



// File: contracts/commons/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts/flavours/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/flavours/Lockable.sol



/**

 * @title Lockable

 * @dev Base contract which allows children to

 *      implement main operations locking mechanism.

 */

contract Lockable is Ownable {

    event Lock();

    event Unlock();



    bool public locked = false;



    /**

     * @dev Modifier to make a function callable

    *       only when the contract is not locked.

     */

    modifier whenNotLocked() {

        require(!locked);

        _;

    }



    /**

     * @dev Modifier to make a function callable

     *      only when the contract is locked.

     */

    modifier whenLocked() {

        require(locked);

        _;

    }



    /**

     * @dev called by the owner to lock, triggers locked state

     */

    function lock() public onlyOwner whenNotLocked {

        locked = true;

        emit Lock();

    }



    /**

     * @dev called by the owner

     *      to unlock, returns to unlocked state

     */

    function unlock() public onlyOwner whenLocked {

        locked = false;

        emit Unlock();

    }

}



// File: contracts/base/ERC20Token.sol







// File: contracts/base/BaseAirdrop.sol



contract BaseAirdrop is Lockable {

    using SafeMath for uint;



    ERC20Token public token;



    address public tokenHolder;



    mapping(address => bool) public users;



    event AirdropToken(address indexed to, uint amount);



    constructor(address _token, address _tokenHolder) public {

        require(_token != address(0) && _tokenHolder != address(0));

        token = ERC20Token(_token);

        tokenHolder = _tokenHolder;

    }



    function airdrop(uint8 v, bytes32 r, bytes32 s, uint amount) public whenNotLocked {

        if (users[msg.sender] || ecrecover(prefixedHash(amount), v, r, s) != owner) {

            revert();

        }

        users[msg.sender] = true;

        token.transferFrom(tokenHolder, msg.sender, amount);

        emit AirdropToken(msg.sender, amount);

    }



    function getAirdropStatus(address user) public constant returns (bool success) {

        return users[user];

    }



    function originalHash(uint amount) internal view returns (bytes32) {

        return keccak256(abi.encodePacked(

                "Signed for Airdrop",

                address(this),

                address(token),

                msg.sender,

                amount

            ));

    }



    function prefixedHash(uint amount) internal view returns (bytes32) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";

        return keccak256(abi.encodePacked(prefix, originalHash(amount)));

    }

}



// File: contracts/BITOXAirdrop.sol



/**

 * @title BITOX token airdrop contract.

 */

contract BITOXAirdrop is BaseAirdrop {



    constructor(address _token, address _tokenHolder) public BaseAirdrop(_token, _tokenHolder) {

        locked = true;

    }



    // Disable direct payments

    function() external payable {

        revert();

    }



    // withdraw funds only for owner

    function withdraw() public onlyOwner {

        owner.transfer(address(this).balance);

    }



    // withdraw stuck tokens only for owner

    function withdrawTokens(address _someToken) public onlyOwner {

        ERC20Token someToken = ERC20Token(_someToken);

        uint balance = someToken.balanceOf(this);

        someToken.transfer(owner, balance);

    }

}