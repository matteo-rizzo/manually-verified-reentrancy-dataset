/**

 *Submitted for verification at Etherscan.io on 2018-10-25

*/



pragma solidity ^0.4.25;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */



















/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;





  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() public onlyOwner whenNotPaused {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyOwner whenPaused {

    paused = false;

    emit Unpause();

  }

}











/**

 * @title Elliptic curve signature operations

 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d

 * TODO Remove this library once solidity supports passing a signature to ecrecover.

 * See https://github.com/ethereum/solidity/issues/864

 */











contract ETHDenverStaking is Ownable, Pausable {



    using ECRecovery for bytes32;



    event UserStake(address userUportAddress, address userMetamaskAddress, uint amountStaked);

    event UserRecoupStake(address userUportAddress, address userMetamaskAddress, uint amountStaked);



    // Debug events

    event debugBytes32(bytes32 _msg);

    event debugBytes(bytes _msg);

    event debugString(string _msg);

    event debugAddress(address _address);



    // ETHDenver will need to authorize staking and recouping.

    address public grantSigner;



    // End of the event, when staking can be sweeped

    uint public finishDate;



    // uPortAddress => walletAddress

    mapping (address => address) public userStakedAddress;



    // ETH amount staked by a given uPort address

    mapping (address => uint256) public stakedAmount;





    constructor(address _grantSigner, uint _finishDate) public {

        grantSigner = _grantSigner;

        finishDate = _finishDate;

    }



    // Public functions



    // function allow the staking for a participant

    function stake(address _userUportAddress, uint _expiryDate, bytes _signature) public payable whenNotPaused {

        bytes32 hashMessage = keccak256(abi.encodePacked(_userUportAddress, msg.value, _expiryDate));

        address signer = hashMessage.toEthSignedMessageHash().recover(_signature);



        require(signer == grantSigner, "Signature is not valid");

        require(block.timestamp < _expiryDate, "Grant is expired");

        require(userStakedAddress[_userUportAddress] == 0, "User has already staked!");



        userStakedAddress[_userUportAddress] = msg.sender;

        stakedAmount[_userUportAddress] = msg.value;



        emit UserStake(_userUportAddress, msg.sender, msg.value);

    }



    // function allow the staking for a participant

    function recoupStake(address _userUportAddress, uint _expiryDate, bytes _signature) public whenNotPaused {

        bytes32 hashMessage = keccak256(abi.encodePacked(_userUportAddress, _expiryDate));

        address signer = hashMessage.toEthSignedMessageHash().recover(_signature);



        require(signer == grantSigner, "Signature is not valid");

        require(block.timestamp < _expiryDate, "Grant is expired");

        require(userStakedAddress[_userUportAddress] != 0, "User has not staked!");



        address stakedBy = userStakedAddress[_userUportAddress];

        uint256 amount = stakedAmount[_userUportAddress];

        userStakedAddress[_userUportAddress] = address(0x0);

        stakedAmount[_userUportAddress] = 0;



        stakedBy.transfer(amount);



        emit UserRecoupStake(_userUportAddress, stakedBy, amount);

    }



    // Owner functions



    function setGrantSigner(address _signer) public onlyOwner {

        require(_signer != address(0x0), "address is null");

        grantSigner = _signer;

    }



    function sweepStakes() public onlyOwner {

        require(block.timestamp > finishDate, "EthDenver is not over yet!");

        owner.transfer(address(this).balance);

    }



}