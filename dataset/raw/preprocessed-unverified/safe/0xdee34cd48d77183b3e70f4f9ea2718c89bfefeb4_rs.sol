/**

 *Submitted for verification at Etherscan.io on 2019-02-04

*/



pragma solidity ^0.5.2;



// File: contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.2/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.2/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: contracts/lib/github.com/contract-library/contract-library-0.0.4/contracts/ownership/Withdrawable.sol



contract Withdrawable is Ownable {

  function withdrawEther() external onlyOwner {

    msg.sender.transfer(address(this).balance);

  }



  function withdrawToken(IERC20 _token) external onlyOwner {

    require(_token.transfer(msg.sender, _token.balanceOf(address(this))));

  }

}



// File: contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.2/contracts/access/Roles.sol



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */





// File: contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.2/contracts/access/roles/PauserRole.sol



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



// File: contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.2/contracts/lifecycle/Pausable.sol



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



// File: contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.2/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





// File: contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.2/contracts/utils/ReentrancyGuard.sol



/**

 * @title Helps contracts guard against reentrancy attacks.

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>

 * @dev If you mark a function `nonReentrant`, you should also

 * mark it `external`.

 */

contract ReentrancyGuard {

    /// @dev counter to allow mutex lock with only one SSTORE operation

    uint256 private _guardCounter;



    constructor () internal {

        // The counter starts at one to prevent changing it from zero to a non-zero

        // value, which is a more expensive operation.

        _guardCounter = 1;

    }



    /**

     * @dev Prevents a contract from calling itself, directly or indirectly.

     * Calling a `nonReentrant` function from another `nonReentrant`

     * function is not supported. It is possible to prevent this from happening

     * by making the `nonReentrant` function external, and make it call a

     * `private` function that does the actual work.

     */

    modifier nonReentrant() {

        _guardCounter += 1;

        uint256 localCounter = _guardCounter;

        _;

        require(localCounter == _guardCounter);

    }

}



// File: contracts/lib/github.com/contract-library/contract-library-0.0.4/contracts/DJTBase.sol



contract DJTBase is Withdrawable, Pausable, ReentrancyGuard {

    using SafeMath for uint256;

}



// File: contracts/lib/github.com/contract-library/contract-library-0.0.4/contracts/access/roles/OperatorRole.sol



contract OperatorRole {

    using Roles for Roles.Role;



    event OperatorAdded(address indexed account);

    event OperatorRemoved(address indexed account);



    Roles.Role private operators;



    constructor() public {

        operators.add(msg.sender);

    }



    modifier onlyOperator() {

        require(isOperator(msg.sender));

        _;

    }

    

    function isOperator(address account) public view returns (bool) {

        return operators.has(account);

    }



    function addOperator(address account) public onlyOperator() {

        operators.add(account);

        emit OperatorAdded(account);

    }



    function removeOperator(address account) public onlyOperator() {

        operators.remove(account);

        emit OperatorRemoved(account);

    }



}



// File: contracts/lib/github.com/OpenZeppelin/openzeppelin-solidity-2.1.2/contracts/cryptography/ECDSA.sol



/**

 * @title Elliptic curve signature operations

 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d

 * TODO Remove this library once solidity supports passing a signature to ecrecover.

 * See https://github.com/ethereum/solidity/issues/864

 */







// File: contracts/MCHPrime.sol



contract MCHPrime is OperatorRole, DJTBase {





	uint128 public primeFee;

	uint256 public primeTerm;

	uint256 public allowedUpdateBuffer;

	mapping(address => uint256) public addressToExpiredAt;



	address public validater;

  

	event PrimeFeeUpdated(

		uint128 PrimeFeeUpdated

	);



	event PrimeTermAdded(

		address user,

		uint256 expiredAt,

		uint256 at

	);



	event PrimeTermUpdated(

		uint256 primeTerm

	);



	event AllowedUpdateBufferUpdated(

		uint256 allowedUpdateBuffer

	);



	event ExpiredAtUpdated(

		address user,

		uint256 expiredAt,

		uint256 at

	);



	constructor() public {

		primeFee = 0.1 ether;

		primeTerm = 30 days;

		allowedUpdateBuffer = 5 days;

	}



	function setValidater(address _varidater) external onlyOwner() {

		validater = _varidater;

	}



	function updatePrimeFee(uint128 _newPrimeFee) external onlyOwner() {

		primeFee = _newPrimeFee;

		emit PrimeFeeUpdated(

			primeFee

		);

	}



	function updatePrimeTerm(uint256 _newPrimeTerm) external onlyOwner() {

		primeTerm = _newPrimeTerm;

		emit PrimeTermUpdated(

			primeTerm

		);

	}



	function updateAllowedUpdateBuffer(uint256 _newAllowedUpdateBuffer) external onlyOwner() {

		allowedUpdateBuffer = _newAllowedUpdateBuffer;

		emit AllowedUpdateBufferUpdated(

			allowedUpdateBuffer

		);

	}



	function updateExpiredAt(address _user, uint256 _expiredAt) external onlyOperator() {

		addressToExpiredAt[_user] = _expiredAt;

		emit ExpiredAtUpdated(

			_user,

			_expiredAt,

			block.timestamp

		);

	}



	function buyPrimeRights(bytes calldata _signature) external whenNotPaused() payable {

		require(msg.value == primeFee, "not enough eth");

		require(canUpdateNow(msg.sender), "unable to update");

		require(validateSig(_signature, bytes32(uint256(msg.sender))), "invalid signature");



		uint256 _now = block.timestamp;

		uint256 expiredAt = addressToExpiredAt[msg.sender];

		if (expiredAt <= _now) {

			addressToExpiredAt[msg.sender] = _now.add(primeTerm);

		} else if(expiredAt <= _now.add(allowedUpdateBuffer)) {

			addressToExpiredAt[msg.sender] = expiredAt.add(primeTerm);

		}



		emit PrimeTermAdded(

			msg.sender,

			addressToExpiredAt[msg.sender],

			_now

		);

	}



	function canUpdateNow(address _user) public view returns (bool) {

		uint256 _now = block.timestamp;

		uint256 expiredAt = addressToExpiredAt[_user];

		// expired user or new user

		if (expiredAt <= _now) {

			return true;

		}

		// user who are able to extend their PrimeTerm

		if (expiredAt <= _now.add(allowedUpdateBuffer)) {

			return true;

		}

		return false;

	}



	function validateSig(bytes memory _signature, bytes32 _message) private view returns (bool) {

		require(validater != address(0));

		address signer = ECDSA.recover(ECDSA.toEthSignedMessageHash(_message), _signature);

		return (signer == validater);

	}



}