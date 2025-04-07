/**

 *Submitted for verification at Etherscan.io on 2018-10-01

*/



pragma solidity ^0.4.18;



contract DelegateERC20 {

  function delegateTotalSupply() public view returns (uint256);

  function delegateBalanceOf(address who) public view returns (uint256);

  function delegateTransfer(address to, uint256 value, address origSender) public returns (bool);

  function delegateAllowance(address owner, address spender) public view returns (uint256);

  function delegateTransferFrom(address from, address to, uint256 value, address origSender) public returns (bool);

  function delegateApprove(address spender, uint256 value, address origSender) public returns (bool);

  function delegateIncreaseApproval(address spender, uint addedValue, address origSender) public returns (bool);

  function delegateDecreaseApproval(address spender, uint subtractedValue, address origSender) public returns (bool);

}



contract Pausable is Ownable {

  event Pause();

  event Unpause();

  function pause() public;

  function unpause() public;

}

contract CanReclaimToken is Ownable {

  function reclaimToken(ERC20Basic token) external;

}

contract Claimable is Ownable {

  function transferOwnership(address newOwner) public;

  function claimOwnership() public;

}

contract AddressList is Claimable {

    event ChangeWhiteList(address indexed to, bool onList);

    function changeList(address _to, bool _onList) public;

}

contract HasNoContracts is Ownable {

  function reclaimContract(address contractAddr) external;

}

contract HasNoEther is Ownable {

  function() external;

  function reclaimEther() external;

}

contract HasNoTokens is CanReclaimToken {

  function tokenFallback(address from_, uint256 value_, bytes data_) external;

}

contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {

}

contract AllowanceSheet is Claimable {

    function addAllowance(address tokenHolder, address spender, uint256 value) public;

    function subAllowance(address tokenHolder, address spender, uint256 value) public;

    function setAllowance(address tokenHolder, address spender, uint256 value) public;

}

contract BalanceSheet is Claimable {

    function addBalance(address addr, uint256 value) public;

    function subBalance(address addr, uint256 value) public;

    function setBalance(address addr, uint256 value) public;

}

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}

contract BasicToken is ERC20Basic, Claimable {

  function setBalanceSheet(address sheet) external;

  function totalSupply() public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function transferAllArgsNoAllowance(address _from, address _to, uint256 _value) internal;

  function balanceOf(address _owner) public view returns (uint256 balance);

}

contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  function burn(uint256 _value) public;

}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract StandardToken is ERC20, BasicToken {

  function setAllowanceSheet(address sheet) external;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

  function transferAllArgsYesAllowance(address _from, address _to, uint256 _value, address spender) internal;

  function approve(address _spender, uint256 _value) public returns (bool);

  function approveAllArgs(address _spender, uint256 _value, address _tokenHolder) internal;

  function allowance(address _owner, address _spender) public view returns (uint256);

  function increaseApproval(address _spender, uint _addedValue) public returns (bool);

  function increaseApprovalAllArgs(address _spender, uint _addedValue, address tokenHolder) internal;

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool);

  function decreaseApprovalAllArgs(address _spender, uint _subtractedValue, address tokenHolder) internal;

}

contract CanDelegate is StandardToken {

    event DelegatedTo(address indexed newContract);

    function delegateToNewContract(DelegateERC20 newContract) public;

    function transfer(address to, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function balanceOf(address who) public view returns (uint256);

    function approve(address spender, uint256 value) public returns (bool);

    function allowance(address _owner, address spender) public view returns (uint256);

    function totalSupply() public view returns (uint256);

    function increaseApproval(address spender, uint addedValue) public returns (bool);

    function decreaseApproval(address spender, uint subtractedValue) public returns (bool);

}

contract StandardDelegate is StandardToken, DelegateERC20 {

    function setDelegatedFrom(address addr) public;

    function delegateTotalSupply() public view returns (uint256);

    function delegateBalanceOf(address who) public view returns (uint256);

    function delegateTransfer(address to, uint256 value, address origSender) public returns (bool);

    function delegateAllowance(address owner, address spender) public view returns (uint256);

    function delegateTransferFrom(address from, address to, uint256 value, address origSender) public returns (bool);

    function delegateApprove(address spender, uint256 value, address origSender) public returns (bool);

    function delegateIncreaseApproval(address spender, uint addedValue, address origSender) public returns (bool);

    function delegateDecreaseApproval(address spender, uint subtractedValue, address origSender) public returns (bool);

}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);

  function increaseApproval(address _spender, uint _addedValue) public returns (bool success);

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success);

}

contract TrueUSD is StandardDelegate, PausableToken, BurnableToken, NoOwner, CanDelegate {

    event ChangeBurnBoundsEvent(uint256 newMin, uint256 newMax);

    event Mint(address indexed to, uint256 amount);

    event WipedAccount(address indexed account, uint256 balance);

    function setLists(AddressList _canReceiveMintWhiteList, AddressList _canBurnWhiteList, AddressList _blackList, AddressList _noFeesList) public;

    function changeName(string _name, string _symbol) public;

    function burn(uint256 _value) public;

    function mint(address _to, uint256 _amount) public;

    function changeBurnBounds(uint newMin, uint newMax) public;

    function transferAllArgsNoAllowance(address _from, address _to, uint256 _value) internal;

    function wipeBlacklistedAccount(address account) public;

    function payStakingFee(address payer, uint256 value, uint80 numerator, uint80 denominator, uint256 flatRate, address otherParticipant) private returns (uint256);

    function changeStakingFees(uint80 _transferFeeNumerator, uint80 _transferFeeDenominator, uint80 _mintFeeNumerator, uint80 _mintFeeDenominator, uint256 _mintFeeFlat, uint80 _burnFeeNumerator, uint80 _burnFeeDenominator, uint256 _burnFeeFlat) public;

    function changeStaker(address newStaker) public;

}







/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





/**

 * @title Cash311

 * @dev The main contract of the project.

 */

  /**

    * @title Cash311

    * @dev https://311.cash/;

    */

    contract Cash311 {

        // Connecting SafeMath for safe calculations.

          // §±§à§Õ§Ü§Ý§ð§é§Ñ§Ö§ä §Ò§Ú§Ò§Ý§Ú§à§ä§Ö§Ü§å §Ò§Ö§Ù§à§á§Ñ§ã§ß§í§ç §Ó§í§é§Ú§ã§Ý§Ö§ß§Ú§Û §Ü §Ü§à§ß§ä§â§Ñ§Ü§ä§å.

        using NewSafeMath for uint;



        // A variable for address of the owner;

          // §±§Ö§â§Ö§Þ§Ö§ß§ß§Ñ§ñ §Õ§Ý§ñ §ç§â§Ñ§ß§Ö§ß§Ú§ñ §Ñ§Õ§â§Ö§ã§Ñ §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ;

        address owner;



        // A variable for address of the ERC20 token;

          // §±§Ö§â§Ö§Þ§Ö§ß§ß§Ñ§ñ §Õ§Ý§ñ §ç§â§Ñ§ß§Ö§ß§Ú§ñ §Ñ§Õ§â§Ö§ã§Ñ §ä§à§Ü§Ö§ß§Ñ ERC20;

        TrueUSD public token = TrueUSD(0x8dd5fbce2f6a956c3022ba3663759011dd51e73e);



        // A variable for decimals of the token;

          // §±§Ö§â§Ö§Þ§Ö§ß§ß§Ñ§ñ §Õ§Ý§ñ §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§Ñ §Ù§ß§Ñ§Ü§à§Ó §á§à§ã§Ý§Ö §Ù§Ñ§á§ñ§ä§à§Û §å §ä§à§Ü§Ö§ß§Ñ;

        uint private decimals = 10**16;



        // A variable for storing deposits of investors.

          // §±§Ö§â§Ö§Þ§Ö§ß§ß§Ñ§ñ §Õ§Ý§ñ §ç§â§Ñ§ß§Ö§ß§Ú§ñ §Ù§Ñ§á§Ú§ã§Ö§Û §à §ã§å§Þ§Þ§Ö §Ú§ß§Ó§Ö§ã§ä§Ú§è§Ú§Û §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó.

        mapping (address => uint) deposit;

        uint deposits;



        // A variable for storing amount of withdrawn money of investors.

          // §±§Ö§â§Ö§Þ§Ö§ß§ß§Ñ§ñ §Õ§Ý§ñ §ç§â§Ñ§ß§Ö§ß§Ú§ñ §Ù§Ñ§á§Ú§ã§Ö§Û §à §ã§å§Þ§Þ§Ö §ã§ß§ñ§ä§í§ç §ã§â§Ö§Õ§ã§ä§Ó.

        mapping (address => uint) withdrawn;



        // A variable for storing reference point to count available money to withdraw.

          // §±§Ö§â§Ö§Þ§Ö§ß§ß§Ñ§ñ §Õ§Ý§ñ §ç§â§Ñ§ß§Ö§ß§Ú§ñ §Ó§â§Ö§Þ§Ö§ß§Ú §à§ä§é§Ö§ä§Ñ §Õ§Ý§ñ §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó.

        mapping (address => uint) lastTimeWithdraw;





        // RefSystem

        mapping (address => uint) referals1;

        mapping (address => uint) referals2;

        mapping (address => uint) referals3;

        mapping (address => uint) referals1m;

        mapping (address => uint) referals2m;

        mapping (address => uint) referals3m;

        mapping (address => address) referers;

        mapping (address => bool) refIsSet;

        mapping (address => uint) refBonus;





        // A constructor function for the contract. It used single time as contract is deployed.

          // §¦§Õ§Ú§ß§à§â§Ñ§Ù§à§Ó§Ñ§ñ §æ§å§ß§Ü§è§Ú§ñ §Ó§í§Ù§í§Ó§Ñ§Ö§Þ§Ñ§ñ §á§â§Ú §Õ§Ö§á§Ý§à§Ö §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ.

        function Cash311() public {

            // Sets an owner for the contract;

              // §µ§ã§ä§Ñ§ß§Ñ§Ó§Ý§Ú§Ó§Ñ§Ö§ä §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ;

            owner = msg.sender;

        }



        // A function for transferring ownership of the contract (available only for the owner).

          // §¶§å§ß§Ü§è§Ú§ñ §Õ§Ý§ñ §á§Ö§â§Ö§ß§à§ã§Ñ §á§â§Ñ§Ó§Ñ §Ó§Ý§Ñ§Õ§Ö§ß§Ú§ñ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ (§Õ§à§ã§ä§å§á§ß§Ñ §ä§à§Ý§î§Ü§à §Õ§Ý§ñ §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ñ).

        function transferOwnership(address _newOwner) external {

            require(msg.sender == owner);

            require(_newOwner != address(0));

            owner = _newOwner;

        }



        // RefSystem

        function bytesToAddress1(bytes source) internal pure returns(address parsedReferer) {

            assembly {

                parsedReferer := mload(add(source,0x14))

            }

            return parsedReferer;

        }



        // A function for getting key info for investors.

          // §¶§å§ß§Ü§è§Ú§ñ §Õ§Ý§ñ §Ó§í§Ù§à§Ó§Ñ §Ü§Ý§ð§é§Ö§Ó§à§Û §Ú§ß§æ§à§â§Þ§Ñ§è§Ú§Ú §Õ§Ý§ñ §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ.

        function getInfo(address _address) public view returns(uint Deposit, uint Withdrawn, uint AmountToWithdraw, uint Bonuses) {



            // 1) Amount of invested tokens;

              // 1) §³§å§Þ§Þ§Ñ §Ó§Ý§à§Ø§Ö§ß§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó;

            Deposit = deposit[_address].div(decimals);

            // 2) Amount of withdrawn tokens;

              // 3) §³§å§Þ§Þ§Ñ §ã§ß§ñ§ä§í§ç §ã§â§Ö§Õ§ã§ä§Ó;

            Withdrawn = withdrawn[_address].div(decimals);

            // 3) Amount of tokens which is available to withdraw;

            // Formula without SafeMath: ((Current Time - Reference Point) - ((Current Time - Reference Point) % 1 period)) * (Deposit * 0.0311) / decimals / 1 period

              // 4) §³§å§Þ§Þ§Ñ §ä§à§Ü§Ö§ß§à§Ó §Õ§à§ã§ä§å§á§ß§í§ç §Ü §Ó§í§Ó§à§Õ§å;

              // §¶§à§â§Þ§å§Ý§Ñ §Ò§Ö§Ù §Ò§Ú§Ò§Ý§Ú§à§ä§Ö§Ü§Ú §Ò§Ö§Ù§à§á§Ñ§ã§ß§í§ç §Ó§í§é§Ú§ã§Ý§Ö§ß§Ú§Û: ((§´§Ö§Ü§å§ë§Ö§Ö §Ó§â§Ö§Þ§ñ - §°§ä§é§Ö§ä§ß§à§Ö §Ó§â§Ö§Þ§ñ) - ((§´§Ö§Ü§å§ë§Ö§Ö §Ó§â§Ö§Þ§ñ - §°§ä§é§Ö§ä§ß§à§Ö §Ó§â§Ö§Þ§ñ) % 1 period)) * (§³§å§Þ§Þ§Ñ §Õ§Ö§á§à§Ù§Ú§ä§Ñ * 0.0311) / decimals / 1 period

            uint _a = (block.timestamp.sub(lastTimeWithdraw[_address]).sub((block.timestamp.sub(lastTimeWithdraw[_address])).mod(1 days))).mul(deposit[_address].mul(311).div(10000)).div(1 days);

            AmountToWithdraw = _a.div(decimals);

            // RefSystem

            Bonuses = refBonus[_address].div(decimals);

        }



        // RefSystem

        function getRefInfo(address _address) public view returns(uint Referals1, uint Referals1m, uint Referals2, uint Referals2m, uint Referals3, uint Referals3m) {

            Referals1 = referals1[_address];

            Referals1m = referals1m[_address].div(decimals);

            Referals2 = referals2[_address];

            Referals2m = referals2m[_address].div(decimals);

            Referals3 = referals3[_address];

            Referals3m = referals3m[_address].div(decimals);

        }



        function getNumber() public view returns(uint) {

            return deposits;

        }



        function getTime(address _address) public view returns(uint Hours, uint Minutes) {

            Hours = (lastTimeWithdraw[_address] % 1 days) / 1 hours;

            Minutes = (lastTimeWithdraw[_address] % 1 days) % 1 hours / 1 minutes;

        }









        // A "fallback" function. It is automatically being called when anybody sends ETH to the contract. Even if the amount of ETH is ecual to 0;

          // §¶§å§ß§Ü§è§Ú§ñ §Ñ§Ó§ä§à§Þ§Ñ§ä§Ú§é§Ö§ã§Ü§Ú §Ó§í§Ù§í§Ó§Ñ§Ö§Þ§Ñ§ñ §á§â§Ú §á§à§Ý§å§é§Ö§ß§Ú§Ú ETH §Ü§à§ß§ä§â§Ñ§Ü§ä§à§Þ (§Õ§Ñ§Ø§Ö §Ö§ã§Ý§Ú §Ò§í§Ý§à §à§ä§á§â§Ñ§Ó§Ý§Ö§ß§à 0 §ï§æ§Ú§â§à§Ó);

        function() external payable {



            // If investor accidentally sent ETH then function send it back;

              // §¦§ã§Ý§Ú §Ú§ß§Ó§Ö§ã§ä§à§â§à§Þ §Ò§í§Ý §à§ä§á§â§Ñ§Ó§Ý§Ö§ß ETH §ä§à §ã§â§Ö§Õ§ã§ä§Ó§Ñ §Ó§à§Ù§Ó§â§Ñ§ë§Ñ§ð§ä§ã§ñ §à§ä§á§â§Ñ§Ó§Ú§ä§Ö§Ý§ð;

            msg.sender.transfer(msg.value);

            // If the value of sent ETH is equal to 0 then function executes special algorithm:

            // 1) Gets amount of intended deposit (approved tokens).

            // 2) If there are no approved tokens then function "withdraw" is called for investors;

              // §¦§ã§Ý§Ú §Ò§í§Ý§à §à§ä§á§â§Ñ§Ó§Ý§Ö§ß§à 0 §ï§æ§Ú§â§à§Ó §ä§à §Ú§ã§á§à§Ý§ß§ñ§Ö§ä§ã§ñ §ã§Ý§Ö§Õ§å§ð§ë§Ú§Û §Ñ§Ý§Ô§à§â§Ú§ä§Þ:

              // 1) §©§Ñ§á§â§Ñ§Ó§ê§Ú§Ó§Ñ§Ö§ä§ã§ñ §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §ä§à§Ü§Ö§ß§à§Ó §Õ§Ý§ñ §Ú§ß§Ó§Ö§ã§ä§Ú§â§à§Ó§Ñ§ß§Ú§ñ (§Ü§à§Ý-§Ó§à §à§Õ§à§Ò§â§Ö§ß§ß§í§ç §Ü §Ó§í§Ó§à§Õ§å §ä§à§Ü§Ö§ß§à§Ó).

              // 2) §¦§ã§Ý§Ú §à§Õ§à§Ò§â§Ö§ß§í §ä§à§Ü§Ö§ß§à§Ó §ß§Ö§ä, §Õ§Ý§ñ §Õ§Ö§Û§ã§ä§Ó§å§ð§ë§Ú§ç §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó §Ó§í§Ù§í§Ó§Ñ§Ö§ä§ã§ñ §æ§å§ß§Ü§è§Ú§ñ §Ú§ß§Ó§Ö§ã§ä§Ú§â§à§Ó§Ñ§ß§Ú§ñ (§á§à§ã§Ý§Ö §ï§ä§à§Ô§à §Õ§Ö§Û§ã§ä§Ó§Ú§Ö §æ§å§ß§Ü§è§Ú§Ú §á§â§Ö§Ü§â§Ñ§ë§Ñ§Ö§ä§ã§ñ);

            uint _approvedTokens = token.allowance(msg.sender, address(this));

            if (_approvedTokens == 0 && deposit[msg.sender] > 0) {

                withdraw();

                return;

            // If there are some approved tokens to invest then function "invest" is called;

              // §¦§ã§Ý§Ú §Ò§í§Ý§Ú §à§Õ§à§Ò§â§Ö§ß§í §ä§à§Ü§Ö§ß§í §ä§à §Ó§í§Ù§í§Ó§Ñ§Ö§ä§ã§ñ §æ§å§ß§Ü§è§Ú§ñ §Ú§ß§Ó§Ö§ã§ä§Ú§â§à§Ó§Ñ§ß§Ú§ñ (§á§à§ã§Ý§Ö §ï§ä§à§Ô§à §Õ§Ö§Û§ã§ä§Ó§Ú§Ö §æ§å§ß§Ü§è§Ú§Ú §á§â§Ö§Ü§â§Ñ§ë§Ñ§Ö§ä§ã§ñ);

            } else {

                invest();

                return;

            }

        }



        // RefSystem

        function refSystem(uint _value, address _referer) internal {

            refBonus[_referer] = refBonus[_referer].add(_value.div(40));

            referals1m[_referer] = referals1m[_referer].add(_value);

            if (refIsSet[_referer]) {

                address ref2 = referers[_referer];

                refBonus[ref2] = refBonus[ref2].add(_value.div(50));

                referals2m[ref2] = referals2m[ref2].add(_value);

                if (refIsSet[referers[_referer]]) {

                    address ref3 = referers[referers[_referer]];

                    refBonus[ref3] = refBonus[ref3].add(_value.mul(3).div(200));

                    referals3m[ref3] = referals3m[ref3].add(_value);

                }

            }

        }



        // RefSystem

        function setRef(uint _value) internal {

            address referer = bytesToAddress1(bytes(msg.data));

            if (deposit[referer] > 0) {

                referers[msg.sender] = referer;

                refIsSet[msg.sender] = true;

                referals1[referer] = referals1[referer].add(1);

                if (refIsSet[referer]) {

                    referals2[referers[referer]] = referals2[referers[referer]].add(1);

                    if (refIsSet[referers[referer]]) {

                        referals3[referers[referers[referer]]] = referals3[referers[referers[referer]]].add(1);

                    }

                }

                refBonus[msg.sender] = refBonus[msg.sender].add(_value.div(50));

                refSystem(_value, referer);

            }

        }







        // A function which accepts tokens of investors.

          // §¶§å§ß§Ü§è§Ú§ñ §Õ§Ý§ñ §á§Ö§â§Ö§Ó§à§Õ§Ñ §ä§à§Ü§Ö§ß§à§Ó §ß§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä.

        function invest() public {



            // Gets amount of deposit (approved tokens);

              // §©§Ñ§á§â§Ñ§Ó§ê§Ú§Ó§Ñ§Ö§ä §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §ä§à§Ü§Ö§ß§à§Ó §Õ§Ý§ñ §Ú§ß§Ó§Ö§ã§ä§Ú§â§à§Ó§Ñ§ß§Ú§ñ (§Ü§à§Ý-§Ó§à §à§Õ§à§Ò§â§Ö§ß§ß§í§ç §Ü §Ó§í§Ó§à§Õ§å §ä§à§Ü§Ö§ß§à§Ó);

            uint _value = token.allowance(msg.sender, address(this));



            // Transfers approved ERC20 tokens from investors address;

              // §±§Ö§â§Ö§Ó§à§Õ§Ú§ä §à§Õ§à§Ò§â§Ö§ß§ß§í§Ö §Ü §Ó§í§Ó§à§Õ§å §ä§à§Ü§Ö§ß§í ERC20 §ß§Ñ §Õ§Ñ§ß§ß§í§Û §Ü§à§ß§ä§â§Ñ§Ü§ä;

            token.transferFrom(msg.sender, address(this), _value);

            // Transfers a fee to the owner of the contract. The fee is 10% of the deposit (or Deposit / 10)

              // §¯§Ñ§é§Ú§ã§Ý§ñ§Ö§ä §Ü§à§Þ§Ú§ã§ã§Ú§ð §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§å (10%);

            refBonus[owner] = refBonus[owner].add(_value.div(10));



            // The special algorithm for investors who increases their deposits:

              // §³§á§Ö§è§Ú§Ñ§Ý§î§ß§í§Û §Ñ§Ý§Ô§à§â§Ú§ä§Þ §Õ§Ý§ñ §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó §å§Ó§Ö§Ý§Ú§é§Ú§Ó§Ñ§ð§ë§Ú§ç §Ú§ç §Ó§Ü§Ý§Ñ§Õ;

            if (deposit[msg.sender] > 0) {

                // Amount of tokens which is available to withdraw;

                // Formula without SafeMath: ((Current Time - Reference Point) - ((Current Time - Reference Point) % 1 period)) * (Deposit * 0.0311) / 1 period

                  // §²§Ñ§ã§é§Ö§ä §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§Ñ §ä§à§Ü§Ö§ß§à§Ó §Õ§à§ã§ä§å§á§ß§í§ç §Ü §Ó§í§Ó§à§Õ§å;

                  // §¶§à§â§Þ§å§Ý§Ñ §Ò§Ö§Ù §Ò§Ú§Ò§Ý§Ú§à§ä§Ö§Ü§Ú §Ò§Ö§Ù§à§á§Ñ§ã§ß§í§ç §Ó§í§é§Ú§ã§Ý§Ö§ß§Ú§Û: ((§´§Ö§Ü§å§ë§Ö§Ö §Ó§â§Ö§Þ§ñ - §°§ä§é§Ö§ä§ß§à§Ö §Ó§â§Ö§Þ§ñ) - ((§´§Ö§Ü§å§ë§Ö§Ö §Ó§â§Ö§Þ§ñ - §°§ä§é§Ö§ä§ß§à§Ö §Ó§â§Ö§Þ§ñ) % 1 period)) * (§³§å§Þ§Þ§Ñ §Õ§Ö§á§à§Ù§Ú§ä§Ñ * 0.0311) / 1 period

                uint amountToWithdraw = (block.timestamp.sub(lastTimeWithdraw[msg.sender]).sub((block.timestamp.sub(lastTimeWithdraw[msg.sender])).mod(1 days))).mul(deposit[msg.sender].mul(311).div(10000)).div(1 days);

                // The additional algorithm for investors who need to withdraw available dividends:

                  // §¥§à§á§à§Ý§ß§Ú§ä§Ö§Ý§î§ß§í§Û §Ñ§Ý§Ô§à§â§Ú§ä§Þ §Õ§Ý§ñ §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó §Ü§à§ä§à§â§í§Ö §Ú§Þ§Ö§ð§ä §ã§â§Ö§Õ§ã§ä§Ó§Ñ §Ü §ã§ß§ñ§ä§Ú§ð;

                if (amountToWithdraw != 0) {

                    // Increasing the withdrawn tokens by the investor.

                      // §µ§Ó§Ö§Ý§Ú§é§Ö§ß§Ú§Ö §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§Ñ §Ó§í§Ó§Ö§Õ§Ö§ß§ß§í§ç §ã§â§Ö§Õ§ã§ä§Ó §Ú§ß§Ó§Ö§ã§ä§à§â§à§Þ;

                    withdrawn[msg.sender] = withdrawn[msg.sender].add(amountToWithdraw);

                    // Transferring available dividends to the investor.

                      // §±§Ö§â§Ö§Ó§à§Õ §Õ§à§ã§ä§å§á§ß§í§ç §Ü §Ó§í§Ó§à§Õ§å §ã§â§Ö§Õ§ã§ä§Ó §ß§Ñ §Ü§à§ê§Ö§Ý§Ö§Ü §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ;

                    token.transfer(msg.sender, amountToWithdraw);



                    // RefSystem

                    uint _bonus = refBonus[msg.sender];

                    if (_bonus != 0) {

                        refBonus[msg.sender] = 0;

                        token.transfer(msg.sender, _bonus);

                        withdrawn[msg.sender] = withdrawn[msg.sender].add(_bonus);

                    }



                }

                // Setting the reference point to the current time.

                  // §µ§ã§ä§Ñ§ß§à§Ó§Ü§Ñ §ß§à§Ó§à§Ô§à §à§ä§é§Ö§ä§ß§à§Ô§à §Ó§â§Ö§Þ§Ö§ß§Ú §Õ§Ý§ñ §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ;

                lastTimeWithdraw[msg.sender] = block.timestamp;

                // Increasing of the deposit of the investor.

                  // §µ§Ó§Ö§Ý§Ú§é§Ö§ß§Ú§Ö §³§å§Þ§Þ§í §Õ§Ö§á§à§Ù§Ú§ä§Ñ §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ;

                deposit[msg.sender] = deposit[msg.sender].add(_value);

                // End of the function for investors who increases their deposits.

                  // §¬§à§ß§Ö§è §æ§å§ß§Ü§è§Ú§Ú §Õ§Ý§ñ §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó §å§Ó§Ö§Ý§Ú§é§Ú§Ó§Ñ§ð§ë§Ú§ç §ã§Ó§à§Ú §Õ§Ö§á§à§Ù§Ú§ä§í;



                // RefSystem

                if (refIsSet[msg.sender]) {

                      refSystem(_value, referers[msg.sender]);

                  } else if (msg.data.length == 20) {

                      setRef(_value);

                  }

                return;

            }

            // The algorithm for new investors:

            // Setting the reference point to the current time.

              // §¡§Ý§Ô§à§â§Ú§ä§Þ §Õ§Ý§ñ §ß§à§Ó§í§ç §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó:

              // §µ§ã§ä§Ñ§ß§à§Ó§Ü§Ñ §ß§à§Ó§à§Ô§à §à§ä§é§Ö§ä§ß§à§Ô§à §Ó§â§Ö§Þ§Ö§ß§Ú §Õ§Ý§ñ §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ;

            lastTimeWithdraw[msg.sender] = block.timestamp;

            // Storing the amount of the deposit for new investors.

            // §µ§ã§ä§Ñ§ß§à§Ó§Ü§Ñ §ã§å§Þ§Þ§í §Ó§ß§Ö§ã§Ö§ß§ß§à§Ô§à §Õ§Ö§á§à§Ù§Ú§ä§Ñ;

            deposit[msg.sender] = (_value);

            deposits += 1;



            // RefSystem

            if (refIsSet[msg.sender]) {

                refSystem(_value, referers[msg.sender]);

            } else if (msg.data.length == 20) {

                setRef(_value);

            }

        }



        // A function for getting available dividends of the investor.

          // §¶§å§ß§Ü§è§Ú§ñ §Õ§Ý§ñ §Ó§í§Ó§à§Õ§Ñ §ã§â§Ö§Õ§ã§ä§Ó §Õ§à§ã§ä§å§á§ß§í§ç §Ü §ã§ß§ñ§ä§Ú§ð;

        function withdraw() public {



            // Amount of tokens which is available to withdraw.

            // Formula without SafeMath: ((Current Time - Reference Point) - ((Current Time - Reference Point) % 1 period)) * (Deposit * 0.0311) / 1 period

              // §²§Ñ§ã§é§Ö§ä §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§Ñ §ä§à§Ü§Ö§ß§à§Ó §Õ§à§ã§ä§å§á§ß§í§ç §Ü §Ó§í§Ó§à§Õ§å;

              // §¶§à§â§Þ§å§Ý§Ñ §Ò§Ö§Ù §Ò§Ú§Ò§Ý§Ú§à§ä§Ö§Ü§Ú §Ò§Ö§Ù§à§á§Ñ§ã§ß§í§ç §Ó§í§é§Ú§ã§Ý§Ö§ß§Ú§Û: ((§´§Ö§Ü§å§ë§Ö§Ö §Ó§â§Ö§Þ§ñ - §°§ä§é§Ö§ä§ß§à§Ö §Ó§â§Ö§Þ§ñ) - ((§´§Ö§Ü§å§ë§Ö§Ö §Ó§â§Ö§Þ§ñ - §°§ä§é§Ö§ä§ß§à§Ö §Ó§â§Ö§Þ§ñ) % 1 period)) * (§³§å§Þ§Þ§Ñ §Õ§Ö§á§à§Ù§Ú§ä§Ñ * 0.0311) / 1 period

            uint amountToWithdraw = (block.timestamp.sub(lastTimeWithdraw[msg.sender]).sub((block.timestamp.sub(lastTimeWithdraw[msg.sender])).mod(1 days))).mul(deposit[msg.sender].mul(311).div(10000)).div(1 days);

            // Reverting the whole function for investors who got nothing to withdraw yet.

              // §£ §ã§Ý§å§é§Ñ§Ö §Ö§ã§Ý§Ú §Ü §Ó§í§Ó§à§Õ§å §ß§Ö§ä §ã§â§Ö§Õ§ã§ä§Ó §ä§à §æ§å§ß§Ü§è§Ú§ñ §à§ä§Þ§Ö§ß§ñ§Ö§ä§ã§ñ;

            if (amountToWithdraw == 0) {

                revert();

            }

            // Increasing the withdrawn tokens by the investor.

              // §µ§Ó§Ö§Ý§Ú§é§Ö§ß§Ú§Ö §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§Ñ §Ó§í§Ó§Ö§Õ§Ö§ß§ß§í§ç §ã§â§Ö§Õ§ã§ä§Ó §Ú§ß§Ó§Ö§ã§ä§à§â§à§Þ;

            withdrawn[msg.sender] = withdrawn[msg.sender].add(amountToWithdraw);

            // Updating the reference point.

            // Formula without SafeMath: Current Time - ((Current Time - Previous Reference Point) % 1 period)

              // §°§Ò§ß§à§Ó§Ý§Ö§ß§Ú§Ö §à§ä§é§Ö§ä§ß§à§Ô§à §Ó§â§Ö§Þ§Ö§ß§Ú §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ;

              // §¶§à§â§Þ§å§Ý§Ñ §Ò§Ö§Ù §Ò§Ú§Ò§Ý§Ú§à§ä§Ö§Ü§Ú §Ò§Ö§Ù§à§á§Ñ§ã§ß§í§ç §Ó§í§é§Ú§ã§Ý§Ö§ß§Ú§Û: §´§Ö§Ü§å§ë§Ö§Ö §Ó§â§Ö§Þ§ñ - ((§´§Ö§Ü§å§ë§Ö§Ö §Ó§â§Ö§Þ§ñ - §±§â§Ö§Õ§í§Õ§å§ë§Ö§Ö §à§ä§é§Ö§ä§ß§à§Ö §Ó§â§Ö§Þ§ñ) % 1 period)

            lastTimeWithdraw[msg.sender] = block.timestamp.sub((block.timestamp.sub(lastTimeWithdraw[msg.sender])).mod(1 days));

            // Transferring the available dividends to the investor.

              // §±§Ö§â§Ö§Ó§à§Õ §Ó§í§Ó§Ö§Õ§Ö§ß§ß§í§ç §ã§â§Ö§Õ§ã§ä§Ó;

            token.transfer(msg.sender, amountToWithdraw);



            // RefSystem

            uint _bonus = refBonus[msg.sender];

            if (_bonus != 0) {

                refBonus[msg.sender] = 0;

                token.transfer(msg.sender, _bonus);

                withdrawn[msg.sender] = withdrawn[msg.sender].add(_bonus);

            }



        }

    }