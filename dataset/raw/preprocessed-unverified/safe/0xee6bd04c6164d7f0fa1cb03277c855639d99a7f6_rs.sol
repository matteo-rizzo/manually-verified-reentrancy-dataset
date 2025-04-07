/**

 *Submitted for verification at Etherscan.io on 2019-01-11

*/



pragma solidity 0.5.2;



// File: ../mch-dailyaction/contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.1/contracts/cryptography/ECDSA.sol



/**

 * @title Elliptic curve signature operations

 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d

 * TODO Remove this library once solidity supports passing a signature to ecrecover.

 * See https://github.com/ethereum/solidity/issues/864

 */







// File: ../mch-dailyaction/contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.1/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: ../mch-dailyaction/contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.1/contracts/access/Roles.sol



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */





// File: ../mch-dailyaction/contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.1/contracts/access/roles/PauserRole.sol



contract PauserRole {

    using Roles for Roles.Role;



    event PauserAdded(address indexed account);

    event PauserRemoved(address indexed account);



    Roles.Role private _pausers;



    constructor () internal {

        _addPauser(msg.sender);

    }



    modifier onlyPauser() {

        require(isPauser(msg.sender));

        _;

    }



    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);

    }



    function addPauser(address account) public onlyPauser {

        _addPauser(account);

    }



    function renouncePauser() public {

        _removePauser(msg.sender);

    }



    function _addPauser(address account) internal {

        _pausers.add(account);

        emit PauserAdded(account);

    }



    function _removePauser(address account) internal {

        _pausers.remove(account);

        emit PauserRemoved(account);

    }

}



// File: ../mch-dailyaction/contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.1/contracts/lifecycle/Pausable.sol



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is PauserRole {

    event Paused(address account);

    event Unpaused(address account);



    bool private _paused;



    constructor () internal {

        _paused = false;

    }



    /**

     * @return true if the contract is paused, false otherwise.

     */

    function paused() public view returns (bool) {

        return _paused;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is not paused.

     */

    modifier whenNotPaused() {

        require(!_paused);

        _;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is paused.

     */

    modifier whenPaused() {

        require(_paused);

        _;

    }



    /**

     * @dev called by the owner to pause, triggers stopped state

     */

    function pause() public onlyPauser whenNotPaused {

        _paused = true;

        emit Paused(msg.sender);

    }



    /**

     * @dev called by the owner to unpause, returns to normal state

     */

    function unpause() public onlyPauser whenPaused {

        _paused = false;

        emit Unpaused(msg.sender);

    }

}



// File: ../mch-dailyaction/contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.1/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





// File: ../mch-dailyaction/contracts/DailyAction.sol



contract DailyAction is Ownable, Pausable {

    using SafeMath for uint256;



    uint256 public term;

    address public validater;

    mapping(address => mapping(address => uint256)) public counter;

    mapping(address => uint256) public latestActionTime;



    event Action(

        address indexed user,

        address indexed referrer,

        uint256 at

    );

    

    constructor() public {

        term = 86400 - 600;

    }

    

    function withdrawEther() external onlyOwner() {

        msg.sender.transfer(address(this).balance);

    }



    function setValidater(address _varidater) external onlyOwner() {

        validater = _varidater;

    }



    function updateTerm(uint256 _term) external onlyOwner() {

        term = _term;

    }



    function requestDailyActionReward(bytes calldata _signature, address _referrer) external whenNotPaused() {

        require(!isInTerm(msg.sender), "this sender got daily reward within term");

        uint256 count = getCount(msg.sender);

        require(validateSig(_signature, count), "invalid signature");

        emit Action(

            msg.sender,

            _referrer,

            block.timestamp

        );

        setCount(msg.sender, count + 1);

        latestActionTime[msg.sender] = block.timestamp;

    }



    function isInTerm(address _sender) public view returns (bool) {

        if (latestActionTime[_sender] == 0) {

            return false;

        } else if (block.timestamp >= latestActionTime[_sender].add(term)) {

            return false;

        }

        return true;

    }



    function getCount(address _sender) public view returns (uint256) {

        if (counter[validater][_sender] == 0) {

            return 1;

        }

        return counter[validater][_sender];

    }



    function setCount(address _sender, uint256 _count) private {

        counter[validater][_sender] = _count;

    }



    function validateSig(bytes memory _signature, uint256 _count) private view returns (bool) {

        require(validater != address(0));

        uint256 hash = uint256(msg.sender) * _count;

        address signer = ECDSA.recover(ECDSA.toEthSignedMessageHash(bytes32(hash)), _signature);

        return (signer == validater);

    }



    /* function getAddress(bytes32 hash, bytes memory signature) public pure returns (address) { */

    /*     return ECDSA.recover(ECDSA.toEthSignedMessageHash(hash), signature); */

    /* } */



}