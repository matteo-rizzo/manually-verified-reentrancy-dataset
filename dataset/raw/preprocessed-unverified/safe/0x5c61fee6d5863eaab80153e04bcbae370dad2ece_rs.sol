/**

 *Submitted for verification at Etherscan.io on 2019-04-01

*/



pragma solidity ^0.5.2;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

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





contract TokenSwap is Ownable {

    using SafeMath for uint256;



    IERC20 private _fromToken;

    IERC20 private _toToken;

    uint256 private _rate;



    event Swap(address indexed sender, uint256 indexed fromTokenAmount, uint256 indexed toTokenAmount);

    event Burn(uint256 indexed amount);



    constructor(

        address fromToken,

        address toToken,

        uint256 rate

    ) Ownable() public {

        require(fromToken != address(0x0) && toToken != address(0x0), "token address can not be 0.");

        require(rate > 0, "swap rate can not be 0.");



        _fromToken = IERC20(fromToken);

        _toToken = IERC20(toToken);

        _rate = rate;

    }



    function swap() external returns (bool) {

        uint256 allowance = _fromToken.allowance(msg.sender, address(this));

        require(allowance > 0, "sender need to approve token to swap contract.");



        if (_fromToken.transferFrom(msg.sender, address(0x0), allowance)) {

            // It only works correctly when the rate is 1000. 

            uint256 swappedValue = allowance.add(999);

            swappedValue = swappedValue.div(_rate);



            require(_toToken.transferFrom(Ownable.owner(), msg.sender, swappedValue));



            emit Swap(msg.sender, allowance, swappedValue);

        }



        return true;

    }



    function () external onlyOwner {

        uint256 reserve = _fromToken.balanceOf(address(this));

        require(_fromToken.transfer(address(0x0), reserve));



        emit Burn(reserve);

    }

}