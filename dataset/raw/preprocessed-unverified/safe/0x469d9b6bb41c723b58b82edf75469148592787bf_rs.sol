/**

 *Submitted for verification at Etherscan.io on 2018-08-28

*/



pragma solidity ^0.4.24;



contract ERC20 {



    uint256 public totalSupply;



    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

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





/// @title Ownable

/// @dev The Ownable contract has an owner address, and provides basic

///      authorization control functions, this simplifies the implementation of

///      "user permissions".





/**

 * @title Destructible

 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.

 */

contract Destructible is Ownable {



    constructor() public payable { }



    /**

     * @dev Transfers the current balance to the owner and terminates the contract.

     */

    function destroy() onlyOwner public {

        selfdestruct(owner);

    }



    function destroyAndSend(address _recipient) onlyOwner public {

        selfdestruct(_recipient);

    }

}



contract LooisCornerstoneHolder is Ownable, Destructible {

    using SafeMath for uint256;

    using SafeERC20 for ERC20;



    ERC20 public token;

    bool public tokenInitialized;

    bool public stopInvest;

    uint256 public totalSupply;

    uint256 public restSupply;

    uint256 public releaseTime;

    uint8 public releasedRoundCount;



    // release percent of each round

    uint8 public firstRoundPercent;

    uint8 public secondRoundPercent;

    uint8 public thirdRoundPercent;

    uint8 public fourthRoundPercent;



    address[] public investors;

    mapping(address => uint256) public investorAmount;

    mapping(address => uint256) public releasedAmount;



    event Release(address indexed _investor, uint256 indexed _value);



    modifier onlyTokenInitialized() {

        require(tokenInitialized);

        _;

    }



    constructor(uint8 _firstRoundPercent, uint8 _secondRoundPercent, uint8 _thirdRoundPercent, uint8 _fourthRoundPercent) public {

        require(_firstRoundPercent + _secondRoundPercent + _thirdRoundPercent + _fourthRoundPercent == 100);



        firstRoundPercent = _firstRoundPercent;

        secondRoundPercent = _secondRoundPercent;

        thirdRoundPercent = _thirdRoundPercent;

        fourthRoundPercent = _fourthRoundPercent;

        tokenInitialized = false;

        stopInvest = false;

        releasedRoundCount = 0;

    }



    function initTokenAndReleaseTime(ERC20 _token, uint256 _releaseTime) onlyOwner public {

        require(!tokenInitialized);

        require(_releaseTime > block.timestamp);



        releaseTime = _releaseTime;

        token = _token;

        totalSupply = token.balanceOf(this);

        restSupply = totalSupply;

        tokenInitialized = true;

    }



    function isInvestor(address _investor) view internal returns (bool ok) {

        for (uint i = 0; i < investors.length; i++) {

            if (investors[i] == _investor) {

                return true;

            }

        }

        return false;

    }



    function addInvestor(address _investor, uint256 _value) onlyManager onlyTokenInitialized public {

        require(_investor != 0x0);

        require(_value > 0);

        require(!stopInvest);



        uint256 value = 10**18 * _value;

        if (!isInvestor(_investor)) {

            require(restSupply > value);



            investors.push(_investor);

        } else {

            require(restSupply + investorAmount[_investor] > value);



            restSupply = restSupply.add(investorAmount[_investor]);

        }

        restSupply = restSupply.sub(value);

        investorAmount[_investor] = value;

    }



    function removeInvestor(address _investor) onlyManager onlyTokenInitialized public {

        require(_investor != 0x0);

        require(!stopInvest);

        require(isInvestor(_investor));



        for (uint i = 0; i < investors.length; i++) {

            if (investors[i] == _investor) {

                investors[i] = investors[investors.length - 1];

                restSupply = restSupply.add(investorAmount[_investor]);

                investorAmount[_investor] = 0;

                break;

            }

        }

        investors.length -= 1;

    }



    function release() onlyManager onlyTokenInitialized public {

        require(releasedRoundCount <= 3);

        require(block.timestamp >= releaseTime);



        uint8 releasePercent;

        if (releasedRoundCount == 0) {

            releasePercent = firstRoundPercent;

        } else if (releasedRoundCount == 1) {

            releasePercent = secondRoundPercent;

        } else if (releasedRoundCount == 2) {

            releasePercent = thirdRoundPercent;

        } else {

            releasePercent = fourthRoundPercent;

        }



        for (uint8 i = 0; i < investors.length; i++) {

            address investor = investors[i];

            uint256 amount = investorAmount[investor];

            if (amount > 0) {

                uint256 releaseAmount = amount.div(100).mul(releasePercent);

                if (releasedAmount[investor].add(releaseAmount) > amount) {

                    releaseAmount = amount.sub(releasedAmount[investor]);

                }

                token.safeTransfer(investor, releaseAmount);

                releasedAmount[investor] = releasedAmount[investor].add(releaseAmount);

                emit Release(investor, releaseAmount);

            }

        }

        // Next release time is 30 days later.

        releaseTime = releaseTime.add(60 * 60 * 24 * 30);

        releasedRoundCount = releasedRoundCount + 1;

        stopInvest = true;

    }



    // if the balance of this contract is not empty, release all balance to the owner

    function releaseRestBalance() onlyOwner onlyTokenInitialized public {

        require(releasedRoundCount > 3);

        uint256 balance = token.balanceOf(this);

        require(balance > 0);



        token.safeTransfer(owner, balance);

        emit Release(owner, balance);

    }



    // if the balance of this contract is not empty, release all balance to a recipient

    function releaseRestBalanceAndSend(address _recipient) onlyOwner onlyTokenInitialized public {

        require(_recipient != 0x0);

        require(releasedRoundCount > 3);

        uint256 balance = token.balanceOf(this);

        require(balance > 0);



        token.safeTransfer(_recipient, balance);

        emit Release(_recipient, balance);

    }

}