/**
 *Submitted for verification at Etherscan.io on 2021-07-21
*/

pragma solidity 0.7.2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



contract EthToBnbBridge is Ownable {
    IERC20 token;
    uint256 public fee;

    event FeeSet(uint256 _fee);
    event MovedToBnb(address _user, uint256 _amount);

    constructor(address _token) public {
        token = IERC20(_token);
    }

    function setFee(uint256 _feeAmountEth) external onlyOwner {
        fee = _feeAmountEth;

        emit FeeSet(_feeAmountEth);
    }

    function unlock(address _receiver, uint256 _amount) external onlyOwner {
        token.transfer(_receiver, _amount);
    }

    function moveToBnb(uint256 _amount) external payable returns(uint256) {
        require(msg.value == fee, "EthToBnbBridge: Invalid fee amount");

        token.transferFrom(msg.sender, address(this), _amount);

        emit MovedToBnb(msg.sender, _amount);
        return _amount;
    }

    function withdrawFee(uint256 _amount) external onlyOwner {
        (msg.sender).transfer(_amount);
    }
}