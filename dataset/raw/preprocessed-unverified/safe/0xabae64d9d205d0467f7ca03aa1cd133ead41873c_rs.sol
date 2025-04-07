/**
 *Submitted for verification at Etherscan.io on 2021-06-09
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.12;



abstract contract Context {
    function _msgSender() internal virtual view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

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

contract PresaleSettings is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Settings {
        uint256 BASE_FEE; // base fee divided by 1000
        uint256 TOKEN_FEE; // token fee divided by 1000
        address payable ETH_FEE_ADDRESS;
        address payable TOKEN_FEE_ADDRESS;
        uint256 ETH_CREATION_FEE; // fee to generate a presale contract on the platform
    }

    Settings public SETTINGS;

    constructor() public {
        SETTINGS.BASE_FEE = 10; // 1%
        SETTINGS.TOKEN_FEE = 0; // 0%
        SETTINGS.ETH_CREATION_FEE = 500000000000000000; // 0.5 ETH
        SETTINGS.ETH_FEE_ADDRESS = 0x48B16bE81b5e5b3ADe688Da283869016FaBd6c4B;
        SETTINGS.TOKEN_FEE_ADDRESS = 0x48B16bE81b5e5b3ADe688Da283869016FaBd6c4B;
    }

    function getBaseFee() external view returns (uint256) {
        return SETTINGS.BASE_FEE;
    }

    function getTokenFee() external view returns (uint256) {
        return SETTINGS.TOKEN_FEE;
    }

    function getEthCreationFee() external view returns (uint256) {
        return SETTINGS.ETH_CREATION_FEE;
    }

    function getEthAddress() external view returns (address payable) {
        return SETTINGS.ETH_FEE_ADDRESS;
    }

    function getTokenAddress() external view returns (address payable) {
        return SETTINGS.TOKEN_FEE_ADDRESS;
    }

    function setFeeAddresses(
        address payable _ethAddress,
        address payable _tokenFeeAddress
    ) external onlyOwner {
        SETTINGS.ETH_FEE_ADDRESS = _ethAddress;
        SETTINGS.TOKEN_FEE_ADDRESS = _tokenFeeAddress;
    }

    function setFees(
        uint256 _baseFee,
        uint256 _tokenFee,
        uint256 _ethCreationFee
    ) external onlyOwner {
        SETTINGS.BASE_FEE = _baseFee;
        SETTINGS.TOKEN_FEE = _tokenFee;
        SETTINGS.ETH_CREATION_FEE = _ethCreationFee;
    }
}