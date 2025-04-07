/**

 *Submitted for verification at Etherscan.io on 2018-12-18

*/



pragma solidity ^0.4.25;



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: contracts/Batch.sol



contract Batch is Ownable {

    using SafeMath for uint256;



    address public constant daiContractAddress = 0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359;

    uint256 public constant daiGift = 1000000000000000000;

    uint256 public constant ethGift = 5500000000000000;

    uint256 public constant size = 80;



    function distributeEth(address[] _recipients)

        public

        payable

        onlyOwner

    {

        require(_recipients.length == size, "recipients array has incorrect size");

        require(msg.value == ethGift * size, "msg.value is not exact");



        for (uint i = 0; i < _recipients.length; i++) {

            _recipients[i].transfer(ethGift);

        }

    }



    function distributeDai(address[] _recipients)

        public

        onlyOwner

    {

        require(_recipients.length == size, "recipients array has incorrect size");



        uint256 distribution = daiGift.mul(size);

        IERC20 daiContract = IERC20(daiContractAddress);

        uint256 allowance = daiContract.allowance(msg.sender, address(this));

        require(

            allowance >= distribution,

            "contract not allowed to transfer enough tokens"

        );



        for (uint i = 0; i < _recipients.length; i++) {

            daiContract.transferFrom(msg.sender, _recipients[i], daiGift);

        }

    }

}