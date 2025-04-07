/**
 *Submitted for verification at Etherscan.io on 2019-09-17
*/

/**
 * Copyright 2017-2019, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.8;






contract UserContract {
    address public owner;
    mapping (address => bool) public controllers;

    constructor(
        address _owner,
        address[] memory _controllerList)
        public
    {
        owner = _owner;

        for(uint256 i=0; i < _controllerList.length; i++) {
            controllers[_controllerList[i]] = true;
        }
    }

    function transferAsset(
        address asset,
        address payable to,
        uint256 amount)
        public
        returns (uint256 transferAmount)
    {
        require(controllers[msg.sender] || msg.sender == owner);

        bool success;
        if (asset == address(0)) {
            transferAmount = amount == 0 ?
                address(this).balance :
                amount;
            (success, ) = to.call.value(transferAmount)("");
            require(success);
        } else {
            bytes memory data;
            if (amount == 0) {
                (,data) = asset.call(
                    abi.encodeWithSignature(
                        "balanceOf(address)",
                        address(this)
                    )
                );
                assembly {
                    transferAmount := mload(add(data, 32))
                }
            } else {
                transferAmount = amount;
            }
            (success,) = asset.call(
                abi.encodeWithSignature(
                    "transfer(address,uint256)",
                    to,
                    transferAmount
                )
            );
            require(success);
        }
    }

    function setControllers(
        address[] memory _controllerList,
        bool[] memory _toggle)
        public
    {
        require(msg.sender == owner && _controllerList.length == _toggle.length);

        for (uint256 i=0; i < _controllerList.length; i++) {
            controllers[_controllerList[i]] = _toggle[i];
        }
    }
}

contract UserContractRegistry is Ownable {

    mapping (address => bool) public controllers;
    mapping (address => UserContract) public userContracts;

    function setControllers(
        address[] memory controller,
        bool[] memory toggle)
        public
        onlyOwner
    {
        require(controller.length == toggle.length, "count mismatch");

        for (uint256 i=0; i < controller.length; i++) {
            controllers[controller[i]] = toggle[i];
        }
    }

    function setContract(
        address user,
        UserContract userContract)
        public
    {
        require(controllers[msg.sender], "unauthorized");
        userContracts[user] = userContract;
    }
}





contract ENSLoanOpenerStorage is Ownable {
    // tokenloan.eth
    bytes32 internal constant tokenloanHash = 0x412c2f8803a30232df76357316f10634835ba4cd288f6002d1d70cb72fac904b;

    address public bZxContract;
    address public bZxVault;
    address public loanTokenLender;
    address public loanTokenAddress;
    address public wethContract;

    UserContractRegistry public userContractRegistry;

    address[] public controllerList;

    uint256 public initialLoanDuration = 7884000; // approximately 3 months

    // ENS
    ENSSimple public ENSContract;
    ResolverSimple public ResolverContract;
}

contract ENSLoanOpenerProxy is ENSLoanOpenerStorage {

    address internal target_;

    constructor(
        address _newTarget)
        public
    {
        _setTarget(_newTarget);
    }

    function()
        external
        payable
    {
        address target = target_;
        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(gas, target, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function setTarget(
        address _newTarget)
        public
        onlyOwner
    {
        _setTarget(_newTarget);
    }

    function _setTarget(
        address _newTarget)
        internal
    {
        require(_isContract(_newTarget), "target not a contract");
        target_ = _newTarget;
    }

    function _isContract(
        address addr)
        internal
        view
        returns (bool)
    {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}