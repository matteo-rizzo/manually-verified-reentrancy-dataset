/**
 *Submitted for verification at Etherscan.io on 2021-09-01
*/

/**
 *Submitted for verification at Etherscan.io on 2021-08-25
 */

/**
 *Submitted for verification at Etherscan.io on 2021-08-10
 */

// SPDX-License-Identifier: none
pragma solidity ^0.8.4;





contract MigrationETH {
    address public admin;
    IToken public token;
    IERC20 public token_;
    uint256 public nonce;
    address public feepayer;
    mapping(uint256 => bool) public processedNonces;
    address fromAddr = address(this);

    enum Step {
        TransferTo,
        TransferFrom
    }
    event Transfer(
        address from,
        address to,
        uint256 amount,
        uint256 date,
        uint256 nonce,
        Step indexed step
    );

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor(address _token) {
        admin = msg.sender;
        token = IToken(_token);
        token_ = IERC20(_token);
    }

    // transfer Ownership to other address
    function transferOwnership(address _newOwner) public {
        require(_newOwner != address(0x0));
        require(msg.sender == admin);
        emit OwnershipTransferred(admin, _newOwner);
        admin = _newOwner;
    }

    // transfer Ownership to other address
    function transferTokenOwnership(address _newOwner) public {
        require(_newOwner != address(0x0));
        require(msg.sender == admin);
        token.changeOwnership(_newOwner);
    }

    function transferFromContract(
        address to,
        uint256 amount,
        uint256 otherChainNonce
    ) external {
        require(msg.sender == admin, "only admin");
        require(
            processedNonces[otherChainNonce] == false,
            "transfer already processed"
        );
        processedNonces[otherChainNonce] = true;
        token_.transfer(to, amount);
        emit Transfer(
            msg.sender,
            to,
            amount,
            block.timestamp,
            otherChainNonce,
            Step.TransferFrom
        );
    }
}