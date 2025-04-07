/**
 *Submitted for verification at Etherscan.io on 2021-06-01
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.3;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}






contract Custody is Ownable {
    using Address for address;

    mapping(address => bool) public authorized;
    IERC20 public token;

    modifier onlyAuthorized() {
        require(authorized[msg.sender], "Not authorized");
        _;
    }

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
        authorized[owner()] = true;
    }

    // Reject any ethers sent to this smart-contract
    receive() external payable {
        revert("Rejecting tx with ethers sent");
    }

    function authorize(address _account) public onlyOwner {
        authorized[_account] = true;
    }

    function forbid(address _account) public onlyOwner {
        require(_account != owner(), "Owner access cannot be forbidden!");

        authorized[_account] = false;
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        authorized[owner()] = false;
        super.transferOwnership(newOwner);
        authorized[owner()] = true;
    }

    function withdraw(uint256 amount) onlyAuthorized public {
        token.transfer(msg.sender, amount);
    }

    // Allow to withdraw any arbitrary token, should be used by
    // contract owner to recover accidentally received funds.
    function recover(address _tokenAddress, uint256 amount) onlyOwner public {
        IERC20(_tokenAddress).transfer(msg.sender, amount);
    }

    // Allows to withdraw funds into many addresses in one tx
    // (or to do mass bounty payouts)
    function payout(address[] calldata _recipients, uint256[] calldata _amounts) onlyOwner public {
        require(_recipients.length == _amounts.length, "Invalid array length");

        for (uint256 i = 0; i < _recipients.length; i++) {
            token.transfer(_recipients[i], _amounts[i]);
        }
    }
}