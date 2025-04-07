/**
 *Submitted for verification at Etherscan.io on 2020-12-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// import ierc20 & safemath & non-standard






contract PresaleDistributor is Ownable {
    using SafeMath for uint256;

    IPresale public presaleContract;
    IERC20 public token;

    mapping(address => bool) public isClaimed;

    event ClaimTokenEvent(address user, uint256 amount);

    constructor(address _presaleContract, address _token) public {
        presaleContract = IPresale(_presaleContract);
        token = IERC20(_token);
    }

    modifier isPresaleOver() {
        require(presaleContract.presale() == true, "The presale is not over");
        _;
    }

    function claimToken() external isPresaleOver {
        // check uint in claimable mapping for msg.sender and transfer erc20 to msg.sender
        require(
            presaleContract.claimable(msg.sender) > 0,
            "No tokens to be claimed"
        );
        require(isClaimed[msg.sender] == false, "Tokens already claimed");
        uint256 amount = presaleContract.claimable(msg.sender);
        isClaimed[msg.sender] = true;
        token.transfer(msg.sender, amount);
        emit ClaimTokenEvent(msg.sender, 0);
    }

    function getEthBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function adminTokenTrans() external onlyOwner {
        require(getTokenBalance() > 0, "the contract has no pry tokens");
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function adminTransferFund(uint256 value) external onlyOwner {
        msg.sender.call{value: value}("");
    }
}