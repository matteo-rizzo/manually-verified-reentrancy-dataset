pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







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

 * @title ERC20 Private Token Generation Program

 */

contract ChainBowPrivateSale is Pausable {



    using SafeMath for uint256;



    ERC20 public tokenContract;

    address public teamWallet;

    string public name;

    uint256 public rate = 5000;



    uint256 public totalSupply = 0;



    event Buy(address indexed sender, address indexed recipient, uint256 value, uint256 tokens);



    mapping(address => uint256) public records;



    constructor(address _tokenContract, address _teamWallet, string _name, uint _rate) public {

        require(_tokenContract != address(0));

        require(_teamWallet != address(0));

        tokenContract = ERC20(_tokenContract);

        teamWallet = _teamWallet;

        name = _name;

        rate = _rate;

    }





    function () payable public {

        buy(msg.sender);

    }



    function buy(address recipient) payable public whenNotPaused {

        require(msg.value >= 0.1 ether);



        uint256 tokens =  rate.mul(msg.value);



        tokenContract.transferFrom(teamWallet, msg.sender, tokens);



        records[recipient] = records[recipient].add(tokens);

        totalSupply = totalSupply.add(tokens);



        emit Buy(msg.sender, recipient, msg.value, tokens);



    }





    /**

     * change rate

     */

    function changeRate(uint256 _rate) public onlyOwner {

        rate = _rate;

    }



    /**

     * change team wallet

     */

    function changeTeamWallet(address _teamWallet) public onlyOwner {

        teamWallet = _teamWallet;

    }



    /**

     * withdraw ether

     */

    function withdrawEth() public onlyOwner {

        teamWallet.transfer(address(this).balance);

    }





    /**

     * withdraw foreign tokens

     */

    function withdrawForeignTokens(address _tokenContract) onlyOwner public returns (bool) {

        ERC20Basic token = ERC20Basic(_tokenContract);

        uint256 amount = token.balanceOf(address(this));

        return token.transfer(owner, amount);

    }



}