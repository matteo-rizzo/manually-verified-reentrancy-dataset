/**
 *Submitted for verification at Etherscan.io on 2021-07-18
*/

// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




contract VoterController {

    address public owner;
    address private mintr = address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);
    address private voter = address(0xdc66DBa57c6f9213c641a8a216f8C3D9d83573cd);

    constructor() public {
        owner = msg.sender;
    }

    function setKeeper(address _owner) external {
        require(msg.sender == owner, "!auth");
        owner = _owner;
    }

    function setRewards(address _owner) external {
        require(msg.sender == owner, "!auth");
        Voter(voter).setGovernance(_owner);
    }

    function kill() external {
        require(msg.sender == owner, "!auth");
        selfdestruct(msg.sender);
    }

    function mints(address[] calldata _gauges) external {
        for(uint256 i = 0; i < _gauges.length; ++i) {
            Voter(voter).execute(mintr, 0, abi.encodeWithSignature("mint(address)", _gauges[i]));
        }
    }

    function pulls(address[] calldata _tokens) external {
        for(uint256 i = 0; i < _tokens.length; ++i) {
            Voter(voter).execute(_tokens[i], 0, abi.encodeWithSignature("transfer(address,uint256)", owner, IERC20(_tokens[i]).balanceOf(voter)));
        }
    }

    function allows(address[] calldata _tokens) external {
        for(uint256 i = 0; i < _tokens.length; ++i) {
            Voter(voter).execute(_tokens[i], 0, abi.encodeWithSignature("approve(address,uint256)", owner, uint(-1)));
        }
    }

    function claims(address[] calldata _gs) external {
        for(uint256 i = 0; i < _gs.length; ++i) {
            Voter(_gs[i]).claim_rewards(voter);
        }
    }
}