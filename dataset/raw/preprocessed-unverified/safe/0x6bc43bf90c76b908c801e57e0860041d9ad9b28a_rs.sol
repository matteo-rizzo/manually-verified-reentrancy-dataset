/**

 *Submitted for verification at Etherscan.io on 2019-05-30

*/



pragma solidity ^0.5.7;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error.

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */





/**

 * @title SDU Exchange contract

 * @author https://grox.solutions

 */

contract SDUExchange is Ownable {

    using SafeMath for uint256;



    IERC20 public SDUM;

    IERC20 public SDU;



    mapping (address => User) _users;



    struct User {

        uint256 deposit;

        uint256 checkpoint;

        uint256 reserved;

    }



    event Exchanged(address user, uint256 amount);

    event Withdrawn(address user, uint256 amount);



    constructor(address SDUMAddr, address SDUAddr, address initialOwner) public Ownable(initialOwner) {

        require(SDUMAddr != address(0) && SDUAddr != address(0));



        SDUM = IERC20(SDUMAddr);

        SDU = IERC20(SDUAddr);

    }



    function receiveApproval(address from, uint256 amount, address token, bytes calldata extraData) external {

        require(token == address(SDUM));

        exchange(from, amount);

    }



    function exchange(address from, uint256 amount) public {

        SDUM.burnFrom(from, amount);



        SDU.transfer(from, amount);



        if (_users[from].deposit != 0) {

            _users[from].reserved = getDividends(msg.sender);

        }



        _users[from].checkpoint = block.timestamp;

        _users[from].deposit = _users[from].deposit.add(amount);



        emit Exchanged(from, amount);

    }



    function() external payable {

        withdraw();

    }



    function withdraw() public {

        uint256 payout = getDividends(msg.sender);



        if (_users[msg.sender].reserved != 0) {

            payout = payout.add(_users[msg.sender].reserved);

            _users[msg.sender].reserved = 0;

        }



        _users[msg.sender].checkpoint = block.timestamp;

        SDU.transfer(msg.sender, payout);



        emit Withdrawn(msg.sender, payout);

    }



    function getDeposit(address addr) public view returns(uint256) {

        return _users[addr].deposit;

    }



    function getDividends(address addr) public view returns(uint256) {

        return (_users[addr].deposit.div(10)).mul(block.timestamp.sub(_users[addr].checkpoint)).div(30 days);

    }



    function withdrawERC20(address ERC20Token, address recipient) external onlyOwner {



        uint256 amount = IERC20(ERC20Token).balanceOf(address(this));

        IERC20(ERC20Token).transfer(recipient, amount);



    }



}