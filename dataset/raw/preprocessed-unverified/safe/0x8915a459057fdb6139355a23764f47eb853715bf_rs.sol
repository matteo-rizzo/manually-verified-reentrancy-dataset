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



    mapping (address => uint) public balances;

    mapping (uint => mapping (address => uint)) public stakes; // mapping of submission ids to mapping of addresses that staked an amount of bounty token 





    event Deposit(address indexed depositor, uint amount, uint balance);

    event Withdraw(address indexed depositor, uint amount, uint balance);



    event Stake(uint indexed submissionId, address hunter, uint amount);

    event StakeReleased(uint indexed submissionId, address from, address to, uint amount);





    constructor(address _bounty0xToken) public {

        Bounty0xToken = _bounty0xToken;

    }





    function deposit(uint _amount) public whenNotPaused {

        //remember to call Token(address).approve(this, amount) or this contract will not be able to do the transfer on your behalf.

        require(ERC20(Bounty0xToken).transferFrom(msg.sender, this, _amount));

        balances[msg.sender] = SafeMath.add(balances[msg.sender], _amount);



        emit Deposit(msg.sender, _amount, balances[msg.sender]);

    }



    function withdraw(uint _amount) public whenNotPaused {

        require(balances[msg.sender] >= _amount);

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _amount);

        require(ERC20(Bounty0xToken).transfer(msg.sender, _amount));

        

        emit Withdraw(msg.sender, _amount, balances[msg.sender]);

    }





    function stake(uint _submissionId, uint _amount) public whenNotPaused {

        require(balances[msg.sender] >= _amount);

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _amount);

        stakes[_submissionId][msg.sender] = SafeMath.add(stakes[_submissionId][msg.sender], _amount);



        emit Stake(_submissionId, msg.sender, _amount);

    }



    function stakeToMany(uint[] _submissionIds, uint[] _amounts) public whenNotPaused {

        uint totalAmount = 0;

        for (uint j = 0; j < _amounts.length; j++) {

            totalAmount = SafeMath.add(totalAmount, _amounts[j]);

        }

        require(balances[msg.sender] >= totalAmount);

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], totalAmount);



        for (uint i = 0; i < _submissionIds.length; i++) {

            stakes[_submissionIds[i]][msg.sender] = SafeMath.add(stakes[_submissionIds[i]][msg.sender], _amounts[i]);



            emit Stake(_submissionIds[i], msg.sender, _amounts[i]);

        }

    }

    



    function releaseStake(uint _submissionId, address _from, address _to, uint _amount) public onlyOwner {

        require(stakes[_submissionId][_from] >= _amount);



        stakes[_submissionId][_from] = SafeMath.sub(stakes[_submissionId][_from], _amount);

        balances[_to] = SafeMath.add(balances[_to], _amount);



        emit StakeReleased(_submissionId, _from, _to, _amount);

    }



    function releaseManyStakes(uint[] _submissionIds, address[] _from, address[] _to, uint[] _amounts) public onlyOwner {

        require(_submissionIds.length == _from.length &&

                _submissionIds.length == _to.length &&

                _submissionIds.length == _amounts.length);



        for (uint i = 0; i < _submissionIds.length; i++) {

            require(stakes[_submissionIds[i]][_from[i]] >= _amounts[i]);

            stakes[_submissionIds[i]][_from[i]] = SafeMath.sub(stakes[_submissionIds[i]][_from[i]], _amounts[i]);

            balances[_to[i]] = SafeMath.add(balances[_to[i]], _amounts[i]);



            emit StakeReleased(_submissionIds[i], _from[i], _to[i], _amounts[i]);

        }

    }





    // Burnable mechanism

    

    address public bntyController;

    

    event Burn(uint indexed submissionId, address from, uint amount);

    

    function changeBntyController(address _bntyController) onlyOwner public {

        bntyController = _bntyController;

    }

    

    

    function burnStake(uint _submissionId, address _from) public onlyOwner {

        require(stakes[_submissionId][_from] > 0);

        

        uint amountToBurn = stakes[_submissionId][_from];

        stakes[_submissionId][_from] = 0;

        

        require(BntyControllerInterface(bntyController).destroyTokensInBntyTokenContract(this, amountToBurn));

        emit Burn(_submissionId, _from, amountToBurn);

    }

    

}