/**
 *Submitted for verification at Etherscan.io on 2019-09-25
*/

/*
 * Copyright 2019 Dolomite
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;





/*
 * Implemented by all contracts that a deposit contract can be created with or 
 * upgraded to
 */



/*
 * Types used by the DepositContractRegistry
 */



/*
 * Helper functions for a Request struct type
 */



/*
 * Subclassable contract used to manage requests and verify wallet signatures
 */
contract Requestable {
  using RequestHelper for Types.Request;

  mapping(address => uint) nonces;

  function validateRequest(Types.Request memory request) internal {
    require(request.target == address(this), "INVALID_TARGET");
    require(request.getSigner() == request.owner, "INVALID_SIGNATURE");
    require(nonces[request.owner] + 1 == request.nonce, "INVALID_NONCE");
    
    if (request.fee.feeAmount > 0) {
      require(balanceOf(request.owner, request.fee.feeToken) >= request.fee.feeAmount, "INSUFFICIENT_FEE_BALANCE");
    }

    nonces[request.owner] += 1;
  }

  function completeRequest(Types.Request memory request) internal {
    if (request.fee.feeAmount > 0) {
      _payRequestFee(request.owner, request.fee.feeToken, request.fee.feeRecipient, request.fee.feeAmount);
    }
  }

  function nonceOf(address owner) public view returns (uint) {
    return nonces[owner];
  }

  // Abtract functions
  function balanceOf(address owner, address token) public view returns (uint);
  function _payRequestFee(address owner, address feeToken, address feeRecipient, uint feeAmount) internal;
}


/**
 * @title DepositContract
 * @author Zack Rubenstein
 *
 * Allows owner, parent (DepositContractRegistry) and the 
 * current set version (presumably of Dolomite Direct) to
 * call contract functions and transfer Ether from the context
 * of this address (pass-though functions).
 *
 * Using CREATE-2 this address can be sent tokens/Ether before it
 * is created.
 */
contract DepositContract {
  address public owner;
  address public parent;
  address public version;

  constructor(address _owner) public {
    parent = msg.sender;
    owner = _owner;
  }

  /*
   * Contract can receive Ether
   */
  function() external payable { }

  /*
   * Set the version that has access to this contracts 
   * `transfer` and `perform` functions. Can only be set by
   * the parent (DepositContractRegistry)
   */
  function setVersion(address newVersion) external {
    require(msg.sender == parent);
    version = newVersion;
  }

  /*
   * Will call a smart contract function from the context of this contract;
   * msg.sender on the receiving end will equal this contract's address.
   *
   * Only the owner, parent (DepositContractRegistry) and version are allowed to call
   * this function. When upgrading versions, make sure the code of the version being
   * upgraded to does not abuse this function.
   *
   * Because the msg.sender of the receiving end will equal this contract's address,
   * this function allows the caller to perform actions such as setting token approvals
   * and wrapping Ether (to WETH).
   *
   * If the signature is an empty string ("" where bytes(signature).length == 0) this method
   * will instead execute the transfer function, passing along the specified value
   */
  function perform(
    address addr, 
    string calldata signature, 
    bytes calldata encodedParams,
    uint value
  ) 
    external 
    returns (bytes memory) 
  {
    require(msg.sender == owner || msg.sender == parent || msg.sender == version, "NOT_PERMISSIBLE");

    if (bytes(signature).length == 0) {
      address(uint160(addr)).transfer(value); // convert address to address payable
    } else {
      bytes4 functionSelector = bytes4(keccak256(bytes(signature)));
      bytes memory payload = abi.encodePacked(functionSelector, encodedParams);
      
      (bool success, bytes memory returnData) = addr.call.value(value)(payload);
      require(success, "OPERATION_REVERTED");

      return returnData;
    }
  }
}


/*
 * Helper functions for a DepositContract instance
 */



/**
 * @title DepositContractRegistry
 * @author Zack Rubenstein
 *
 * Factory for creating and upgrading DepositContracts using
 * user signatures to ensure non-custodianship. Uses CREATE-2 to
 * enable deposit addresses to safely receive ERC20 Tokens/Ether prior
 * to the deposit contract being deployed
 */
contract DepositContractRegistry is Requestable {
  using DepositContractHelper for DepositContract;

  event CreatedDepositContract(address indexed owner, address indexed depositAddress);
  event UpgradedVersion(address indexed owner, address indexed depositAddress, address newVersion);

  bytes constant public DEPOSIT_CONTRACT_BYTECODE = type(DepositContract).creationCode;

  // =============================
  
  address public wethTokenAddress;
  mapping(address => address payable) public registry;
  mapping(address => address) public versions;

  constructor(address _wethTokenAddress) public {
    wethTokenAddress = _wethTokenAddress;
  }

  /*
   * Get the deterministic address of the given address's deposit contract.
   * Whether this contract has been created yet or not, the address returned
   * here will be the address of the deposit address
   */
  function depositAddressOf(address owner) public view returns (address payable) {
    bytes32 codeHash = keccak256(_getCreationBytecode(owner));
    bytes32 addressHash = keccak256(abi.encodePacked(byte(0xff), address(this), uint256(owner), codeHash));
    return address(uint160(uint256(addressHash)));
  }

  function isDepositContractCreatedFor(address owner) public view returns (bool) {
    return registry[owner] != address(0x0);
  }

  /*
   * Get the version of the deposit contract for a specified owner address
   */
  function versionOf(address owner) public view returns (address) {
    return versions[owner];
  }

  /*
   * Get the balance of the given token for the specified address's deposit address
   */
  function balanceOf(address owner, address token) public view returns (uint) {
    address depositAddress = depositAddressOf(owner);
    uint tokenBalance = IERC20(token).balanceOf(depositAddress);
    if (token == wethTokenAddress) tokenBalance = tokenBalance + depositAddress.balance;
    return tokenBalance;
  }

  /*
   * Create a deposit contract by providing a signed UpgradeRequest.
   * The deposit contract will be created and then immediately upgraded
   * to the version specified in the signed request
   */
  function createDepositContract(Types.Request memory request) public {
    validateRequest(request);
    _createDepositContract(request.owner);
    _upgradeVersion(request);
  }

  /*
   * Upgrade the version used by a deposit contract by providing a signed UpgradeRequest
   */
  function upgradeVersion(Types.Request memory request) public {
    validateRequest(request);
    _upgradeVersion(request);
  }

  // =============================
  // Internal functions

  function _payRequestFee(address owner, address feeToken, address feeRecipient, uint feeAmount) internal {
    DepositContract(registry[owner]).wrapAndTransferToken(feeToken, feeRecipient, feeAmount, wethTokenAddress);
  }

  function _getCreationBytecode(address owner) private view returns (bytes memory) {
    return abi.encodePacked(DEPOSIT_CONTRACT_BYTECODE, bytes12(0x000000000000000000000000), owner);
  }

  function _createDepositContract(address owner) private returns (address) {
    require(registry[owner] == address(0x0), "ALREADY_CREATED");

    address payable depositAddress;
    bytes memory code = _getCreationBytecode(owner);
    uint256 salt = uint256(owner);

    assembly {
      depositAddress := create2(0, add(code, 0x20), mload(code), salt)
      if iszero(extcodesize(depositAddress)) { revert(0, 0) }
    }

    emit CreatedDepositContract(owner, depositAddress);

    registry[owner] = depositAddress;
    return depositAddress;
  }

  function _upgradeVersion(Types.Request memory request) internal {
    require(registry[request.owner] != address(0x0), "NEEDS_CREATION");
    
    Types.UpdateRequest memory upgradeRequest = request.decodeUpdateRequest();
    address currentVersion = versions[request.owner];
    address payable depositAddress = registry[request.owner];

    // End usage of current version if one exists
    if (currentVersion != address(0x0)) {
      IVersionable(currentVersion).versionEndUsage(
        request.owner,
        depositAddress,
        upgradeRequest.version,
        upgradeRequest.additionalData
      );
    }

    // Payout request fee & set version before upgrading
    completeRequest(request);
    DepositContract(depositAddress).setVersion(upgradeRequest.version);
    versions[request.owner] = upgradeRequest.version;

    // Begin usage of new version
    IVersionable(upgradeRequest.version).versionBeginUsage(
      request.owner,
      depositAddress,
      currentVersion,
      upgradeRequest.additionalData
    );

    emit UpgradedVersion(request.owner, depositAddress, upgradeRequest.version);
  }
}