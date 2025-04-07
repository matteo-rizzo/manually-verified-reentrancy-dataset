/**
 *Submitted for verification at Etherscan.io on 2020-11-25
*/

pragma solidity =0.5.16;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */





contract FnxVote is Ownable{
    using SafeMath for uint256;

    address public fnxToken = 0xeF9Cd7882c067686691B6fF49e650b43AFBBCC6B;
    address public uniswap = 0x722885caB8be10B27F359Fcb225808fe2Af07B16;
    address public fnxCollateral = 0x919a35A4F40c479B3319E3c3A2484893c06fd7de;
    address public uniMine = 0x702164396De92bF0f4a1315c00EFDb5a7ea287eC;

    function fnxTokenBalance(address _user) public view returns (uint256) {
        return IERC20(fnxToken).balanceOf(_user);
    }

    function fnxBalanceInUniswap(address _user) public view returns (uint256) {
        uint256 LpFnxBalance = IERC20(fnxToken).balanceOf(uniswap);
        if (LpFnxBalance == 0) {
            return 0;
        }
        if(IERC20(uniswap).totalSupply()==0) {
            return 0;
        }
        
        uint256 fnxPerUni = LpFnxBalance.mul(1e12).div(IERC20(uniswap).totalSupply());

        uint256 userUnimineLpBalance = IUniMinePool(uniMine).totalStakedFor(_user);
        uint256 userLpBalance = IERC20(uniswap).balanceOf(_user);

        return (userLpBalance.add(userUnimineLpBalance)).mul(fnxPerUni).div(1e12);
    }

    function fnxCollateralBalance(address _user) public view returns (uint256) {
       return ICollateralPool(fnxCollateral).getUserInputCollateral(_user,fnxToken);
    }
    
    function fnxBalanceAll(address _user) public view returns (uint256) {
       uint256 tokenNum = fnxTokenBalance(_user);
       uint256 uniTokenNum = fnxBalanceInUniswap(_user);
       uint256 colTokenNum = fnxCollateralBalance(_user);
       uint256 total = tokenNum.add(uniTokenNum).add(colTokenNum);
       
       return total;
    }

    function setPools(address _fnxToken,address _uniswap,address _collateral,address _uniMine) public onlyOwner{
        fnxToken = _fnxToken;
        uniswap = _uniswap;
        fnxCollateral = _collateral;
        uniMine = _uniMine;
    }
}