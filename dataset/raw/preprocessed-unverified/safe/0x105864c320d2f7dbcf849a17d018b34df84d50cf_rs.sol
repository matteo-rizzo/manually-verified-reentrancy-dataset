/**
 *Submitted for verification at Etherscan.io on 2020-07-06
*/

pragma solidity ^0.5.9;


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
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */


/* Token Swap 2020-07-06 */
contract TokenSwap is Ownable{
    using SafeMath for uint256;
    address private _tokenAddress;

    event TokenAddressChanged(address indexed previousTokenAddress, address indexed newTokenAddress);
    event ReturnTokens(address indexed owner, address indexed _token, uint256 amount);

    constructor (address tokenAddress) public {
        _tokenAddress = tokenAddress;
    }

    function tokenAddress() public view returns (address) {
        return _tokenAddress;
    }

    function setTokenAddress(address newTokenAddress) public onlyOwner {
        require(newTokenAddress != address(0));
        emit TokenAddressChanged(_tokenAddress, newTokenAddress);
        _tokenAddress = newTokenAddress;
    }
     function tokenSwapAfterVerification(address[] memory _addrs, uint256[] memory _values, uint256 totalValue) public onlyOwner {
        require(_addrs.length == _values.length);
        uint256 verificationValue = 0;

        for(uint256 i = 0; i < _values.length; i++) {
            verificationValue = verificationValue.add(_values[i]);
        }

        require(verificationValue == totalValue);
        IERC20 token = IERC20(_tokenAddress);

        for(uint256 i = 0; i < _addrs.length; i++) {
            require(token.transfer(_addrs[i], _values[i]));
        }
    }

    function tokenSwap(address[] memory _addrs, uint256[] memory _values) public onlyOwner {
        require(_addrs.length == _values.length);
        IERC20 token = IERC20(_tokenAddress);

        for(uint256 i = 0; i < _addrs.length; i++) {
            require(token.transfer(_addrs[i], _values[i]));
        }
    }

    function returnTokens(address _token, uint256 amount) public onlyOwner {
        IERC20 token = IERC20(_token);
        address thisAddress = address(this);
        uint256 tokenBalance = token.balanceOf(thisAddress);
        require(tokenBalance >= amount);

        address owner = msg.sender;
        token.transfer(owner, amount);
        emit ReturnTokens(owner, _token, amount);
    }
}