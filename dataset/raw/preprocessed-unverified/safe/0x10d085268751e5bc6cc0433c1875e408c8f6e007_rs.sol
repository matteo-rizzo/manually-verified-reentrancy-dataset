/**

 *Submitted for verification at Etherscan.io on 2018-08-16

*/



pragma solidity ^0.4.24;



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

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */











/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title TokenVesting

 * @dev TokenVesting is a token holder contract that will allow a

 * beneficiary to extract the tokens after a given release time

 */

contract TokenVesting is Ownable {

    using SafeERC20 for ERC20Basic;

    using SafeMath for uint256;



    // ERC20 basic token contract being held

    ERC20Basic public token;



    struct VestingObj {

        uint256 token;

        uint256 releaseTime;

    }



    mapping (address  => VestingObj[]) public vestingObj;



    uint256 public totalTokenVested;



    event AddVesting ( address indexed _beneficiary, uint256 token, uint256 _vestingTime);

    event Release ( address indexed _beneficiary, uint256 token, uint256 _releaseTime);



    modifier checkZeroAddress(address _add) {

        require(_add != address(0));

        _;

    }



    constructor(ERC20Basic _token)

        public

        checkZeroAddress(_token)

    {

        token = _token;

    }



    function addVesting( address[] _beneficiary, uint256[] _token, uint256[] _vestingTime) 

        external 

        onlyOwner

    {

        require((_beneficiary.length == _token.length) && (_beneficiary.length == _vestingTime.length));

        

        for (uint i = 0; i < _beneficiary.length; i++) {

            require(_vestingTime[i] > now);

            require(checkZeroValue(_token[i]));

            require(uint256(getBalance()) >= totalTokenVested.add(_token[i]));

            vestingObj[_beneficiary[i]].push(VestingObj({

                token : _token[i],

                releaseTime : _vestingTime[i]

            }));

            totalTokenVested = totalTokenVested.add(_token[i]);

            emit AddVesting(_beneficiary[i], _token[i], _vestingTime[i]);

        }

    }



    /**

   * @notice Transfers tokens held by timelock to beneficiary.

   */

    function claim() external {

        uint256 transferTokenCount = 0;

        for (uint i = 0; i < vestingObj[msg.sender].length; i++) {

            if (now >= vestingObj[msg.sender][i].releaseTime) {

                transferTokenCount = transferTokenCount.add(vestingObj[msg.sender][i].token);

                delete vestingObj[msg.sender][i];

            }

        }

        require(transferTokenCount > 0);

        token.safeTransfer(msg.sender, transferTokenCount);

        emit Release(msg.sender, transferTokenCount, now);

    }



    function getBalance() public view returns (uint256) {

        return token.balanceOf(address(this));

    }

    

    function checkZeroValue(uint256 value) internal pure returns(bool){

        return value > 0;

    }

}