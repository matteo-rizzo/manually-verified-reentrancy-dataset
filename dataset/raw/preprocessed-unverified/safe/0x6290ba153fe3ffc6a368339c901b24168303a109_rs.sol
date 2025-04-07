/**

 *Submitted for verification at Etherscan.io on 2018-12-20

*/



pragma solidity 0.4.24;



// File: contracts/commons/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





// File: contracts/flavours/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions". It has two-stage ownership transfer.

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

     * @dev called by the owner to locke, triggers locked state

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



// File: contracts/interface/SNPCToken.sol







// File: contracts/base/BaseAirdrop.sol



contract BaseAirdrop is Lockable {

    using SafeMath for uint;



    SNPCToken public token;



    mapping(address => bool) public users;



    event AirdropToken(address indexed to, uint amount);



    constructor(address _token) public {

        require(_token != address(0));

        token = SNPCToken(_token);

    }



    function airdrop(uint8 v, bytes32 r, bytes32 s, uint amount) public;



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



// File: contracts/interface/ERC20Token.sol







// File: contracts/flavours/Withdrawal.sol



/**

 * @title Withdrawal

 * @dev The Withdrawal contract has an owner address, and provides method for withdraw funds and tokens, if any

 */

contract Withdrawal is Ownable {



    // withdraw funds, if any, only for owner

    function withdraw() public onlyOwner {

        owner.transfer(address(this).balance);

    }



    // withdraw stuck tokens, if any, only for owner

    function withdrawTokens(address _someToken) public onlyOwner {

        ERC20Token someToken = ERC20Token(_someToken);

        uint balance = someToken.balanceOf(address(this));

        someToken.transfer(owner, balance);

    }

}



// File: contracts/flavours/SelfDestructible.sol



/**

 * @title SelfDestructible

 * @dev The SelfDestructible contract has an owner address, and provides selfDestruct method

 * in case of deployment error.

 */

contract SelfDestructible is Ownable {



    function selfDestruct(uint8 v, bytes32 r, bytes32 s) public onlyOwner {

        if (ecrecover(prefixedHash(), v, r, s) != owner) {

            revert();

        }

        selfdestruct(owner);

    }



    function originalHash() internal view returns (bytes32) {

        return keccak256(abi.encodePacked(

                "Signed for Selfdestruct",

                address(this),

                msg.sender

            ));

    }



    function prefixedHash() internal view returns (bytes32) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";

        return keccak256(abi.encodePacked(prefix, originalHash()));

    }

}



// File: contracts/SNPCAirdrop.sol



/**

 * @title SNPC token airdrop contract.

 */

contract SNPCAirdrop is BaseAirdrop, Withdrawal, SelfDestructible {



    constructor(address _token) public BaseAirdrop(_token) {

        locked = true;

    }



    function getTokenOwnership() public onlyOwner {

        require(token.pendingOwner() == address(this));

        token.claimOwnership();

        require(token.owner() == address(this));

    }



    function releaseTokenOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));

        token.transferOwnership(newOwner);

        require(token.pendingOwner() == newOwner);

    }



    function airdrop(uint8 v, bytes32 r, bytes32 s, uint amount) public whenNotLocked {

        if (users[msg.sender] || ecrecover(prefixedHash(amount), v, r, s) != owner) {

            revert();

        }

        users[msg.sender] = true;

        token.assignReserved(msg.sender, uint8(0x2), amount);

        emit AirdropToken(msg.sender, amount);

    }



    // Disable direct payments

    function() external payable {

        revert();

    }

}