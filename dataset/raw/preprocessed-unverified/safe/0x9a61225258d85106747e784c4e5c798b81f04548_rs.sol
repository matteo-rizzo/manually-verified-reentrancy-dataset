/**

 *Submitted for verification at Etherscan.io on 2018-11-22

*/



pragma solidity ^0.4.23;





/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */













/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

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

  function pause() onlyOwner whenNotPaused public {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() onlyOwner whenPaused public {

    paused = false;

    emit Unpause();

  }

}













/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}







contract BntyControllerInterface {

    function destroyTokensInBntyTokenContract(address _owner, uint _amount) public returns (bool);

}









contract Bounty0xStaking is Ownable, Pausable {



    using SafeMath for uint256;



    address public Bounty0xToken;

    uint public lockTime;



    mapping (address => uint) public balances;

    mapping (uint => mapping (address => uint)) public stakes; // mapping of submission ids to mapping of addresses that staked an amount of bounty token

    mapping (address => uint) public huntersLockDateTime;

    mapping (address => uint) public huntersLockAmount;

    

    

    event Deposit(address indexed depositor, uint amount, uint balance);

    event Withdraw(address indexed depositor, uint amount, uint balance);

    event Stake(uint indexed submissionId, address indexed hunter, uint amount, uint balance);

    event StakeReleased(uint indexed submissionId, address indexed from, address indexed to, uint amount);

    event Lock(address indexed hunter, uint amount, uint endDateTime);

    event Unlock(address indexed hunter, uint amount);





    constructor(address _bounty0xToken) public {

        Bounty0xToken = _bounty0xToken;

        lockTime = 30 days;

    }

    



    function deposit(uint _amount) external whenNotPaused {

        require(_amount != 0);

        //remember to call Token(address).approve(this, amount) or this contract will not be able to do the transfer on your behalf.

        require(ERC20(Bounty0xToken).transferFrom(msg.sender, this, _amount));

        balances[msg.sender] = SafeMath.add(balances[msg.sender], _amount);



        emit Deposit(msg.sender, _amount, balances[msg.sender]);

    }

    

    function withdraw(uint _amount) external whenNotPaused {

        require(_amount != 0);

        require(balances[msg.sender] >= _amount);

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _amount);

        require(ERC20(Bounty0xToken).transfer(msg.sender, _amount));



        emit Withdraw(msg.sender, _amount, balances[msg.sender]);

    }

    

    

    function lock(uint _amount) external whenNotPaused {

        require(_amount != 0);

        require(balances[msg.sender] >= _amount);

        

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _amount);

        huntersLockAmount[msg.sender] = SafeMath.add(huntersLockAmount[msg.sender], _amount);

        huntersLockDateTime[msg.sender] = SafeMath.add(now, lockTime);

        

        emit Lock(msg.sender, huntersLockAmount[msg.sender], huntersLockDateTime[msg.sender]);

    }

    

    function depositAndLock(uint _amount) external whenNotPaused {

        require(_amount != 0);

        require(ERC20(Bounty0xToken).transferFrom(msg.sender, this, _amount));

        

        huntersLockAmount[msg.sender] = SafeMath.add(huntersLockAmount[msg.sender], _amount);

        huntersLockDateTime[msg.sender] = SafeMath.add(now, lockTime);

        

        emit Lock(msg.sender, huntersLockAmount[msg.sender], huntersLockDateTime[msg.sender]);

    }

    

    function unlock() external whenNotPaused {

        require(huntersLockDateTime[msg.sender] <= now);

        uint amountLocked = huntersLockAmount[msg.sender];

        require(amountLocked != 0);

        

        huntersLockAmount[msg.sender] = SafeMath.sub(huntersLockAmount[msg.sender], amountLocked);

        balances[msg.sender] = SafeMath.add(balances[msg.sender], amountLocked);

        

        emit Unlock(msg.sender, amountLocked);

    }





    function stake(uint _submissionId, uint _amount) external whenNotPaused {

        require(balances[msg.sender] >= _amount);

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _amount);

        stakes[_submissionId][msg.sender] = SafeMath.add(stakes[_submissionId][msg.sender], _amount);



        emit Stake(_submissionId, msg.sender, _amount, balances[msg.sender]);

    }



    function stakeToMany(uint[] _submissionIds, uint[] _amounts) external whenNotPaused {

        uint totalAmount = 0;

        for (uint j = 0; j < _amounts.length; j++) {

            totalAmount = SafeMath.add(totalAmount, _amounts[j]);

        }

        require(balances[msg.sender] >= totalAmount);

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], totalAmount);



        for (uint i = 0; i < _submissionIds.length; i++) {

            stakes[_submissionIds[i]][msg.sender] = SafeMath.add(stakes[_submissionIds[i]][msg.sender], _amounts[i]);



            emit Stake(_submissionIds[i], msg.sender, _amounts[i], balances[msg.sender]);

        }

    }





    function releaseStake(uint _submissionId, address _from, address _to) external onlyOwner {

        require(stakes[_submissionId][_from] != 0);



        balances[_to] = SafeMath.add(balances[_to], stakes[_submissionId][_from]);

        emit StakeReleased(_submissionId, _from, _to, stakes[_submissionId][_from]);

        

        stakes[_submissionId][_from] = 0;

    }



    function releaseManyStakes(uint[] _submissionIds, address[] _from, address[] _to) external onlyOwner {

        require(_submissionIds.length == _from.length &&

                _submissionIds.length == _to.length);



        for (uint i = 0; i < _submissionIds.length; i++) {

            require(_from[i] != address(0));

            require(_to[i] != address(0));

            require(stakes[_submissionIds[i]][_from[i]] != 0);

            

            balances[_to[i]] = SafeMath.add(balances[_to[i]], stakes[_submissionIds[i]][_from[i]]);

            emit StakeReleased(_submissionIds[i], _from[i], _to[i], stakes[_submissionIds[i]][_from[i]]);

            

            stakes[_submissionIds[i]][_from[i]] = 0;

        }

    }

    



    function changeLockTime(uint _periodInSeconds) external onlyOwner {

        lockTime = _periodInSeconds;

    }

    

    

    // Burnable mechanism



    address public bntyController;



    event Burn(uint indexed submissionId, address indexed from, uint amount);



    function changeBntyController(address _bntyController) external onlyOwner {

        bntyController = _bntyController;

    }





    function burnStake(uint _submissionId, address _from) external onlyOwner {

        require(stakes[_submissionId][_from] > 0);



        uint amountToBurn = stakes[_submissionId][_from];

        stakes[_submissionId][_from] = 0;



        require(BntyControllerInterface(bntyController).destroyTokensInBntyTokenContract(this, amountToBurn));

        emit Burn(_submissionId, _from, amountToBurn);

    }





    // in case of emergency

    function emergentWithdraw() external onlyOwner {

        require(ERC20(Bounty0xToken).transfer(msg.sender, address(this).balance));

    }

    

}