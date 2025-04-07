/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity ^0.4.24;

// File: contracts/math/SafeMath.sol

// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol

// @title SafeMath: overflow/underflow checks
// @notice Math operations with safety checks that throw on error


// File: contracts/interfaces/DBInterface.sol

// Database interface


// File: contracts/database/Events.sol

contract Events {
  DBInterface public database;

  constructor(address _database) public{
    database = DBInterface(_database);
  }

  function message(string _message)
  external
  onlyApprovedContract {
      emit LogEvent(_message, keccak256(abi.encodePacked(_message)), tx.origin);
  }

  function transaction(string _message, address _from, address _to, uint _amount, address _token)
  external
  onlyApprovedContract {
      emit LogTransaction(_message, keccak256(abi.encodePacked(_message)), _from, _to, _amount, _token, tx.origin);
  }

  function registration(string _message, address _account)
  external
  onlyApprovedContract {
      emit LogAddress(_message, keccak256(abi.encodePacked(_message)), _account, tx.origin);
  }

  function contractChange(string _message, address _account, string _name)
  external
  onlyApprovedContract {
      emit LogContractChange(_message, keccak256(abi.encodePacked(_message)), _account, _name, tx.origin);
  }

  function asset(string _message, string _uri, address _assetAddress, address _manager)
  external
  onlyApprovedContract {
      emit LogAsset(_message, keccak256(abi.encodePacked(_message)), _uri, keccak256(abi.encodePacked(_uri)), _assetAddress, _manager, tx.origin);
  }

  function escrow(string _message, address _assetAddress, bytes32 _escrowID, address _manager, uint _amount)
  external
  onlyApprovedContract {
      emit LogEscrow(_message, keccak256(abi.encodePacked(_message)), _assetAddress, _escrowID, _manager, _amount, tx.origin);
  }

  function order(string _message, bytes32 _orderID, uint _amount, uint _price)
  external
  onlyApprovedContract {
      emit LogOrder(_message, keccak256(abi.encodePacked(_message)), _orderID, _amount, _price, tx.origin);
  }

  function exchange(string _message, bytes32 _orderID, address _assetAddress, address _account)
  external
  onlyApprovedContract {
      emit LogExchange(_message, keccak256(abi.encodePacked(_message)), _orderID, _assetAddress, _account, tx.origin);
  }

  function operator(string _message, bytes32 _id, string _name, string _ipfs, address _account)
  external
  onlyApprovedContract {
      emit LogOperator(_message, keccak256(abi.encodePacked(_message)), _id, _name, _ipfs, _account, tx.origin);
  }

  function consensus(string _message, bytes32 _executionID, bytes32 _votesID, uint _votes, uint _tokens, uint _quorum)
  external
  onlyApprovedContract {
    emit LogConsensus(_message, keccak256(abi.encodePacked(_message)), _executionID, _votesID, _votes, _tokens, _quorum, tx.origin);
  }

  //Generalized events
  event LogEvent(string message, bytes32 indexed messageID, address indexed origin);
  event LogTransaction(string message, bytes32 indexed messageID, address indexed from, address indexed to, uint amount, address token, address origin); //amount and token will be empty on some events
  event LogAddress(string message, bytes32 indexed messageID, address indexed account, address indexed origin);
  event LogContractChange(string message, bytes32 indexed messageID, address indexed account, string name, address indexed origin);
  event LogAsset(string message, bytes32 indexed messageID, string uri, bytes32 indexed assetID, address asset, address manager, address indexed origin);
  event LogEscrow(string message, bytes32 indexed messageID, address asset, bytes32  escrowID, address indexed manager, uint amount, address indexed origin);
  event LogOrder(string message, bytes32 indexed messageID, bytes32 indexed orderID, uint amount, uint price, address indexed origin);
  event LogExchange(string message, bytes32 indexed messageID, bytes32 orderID, address indexed asset, address account, address indexed origin);
  event LogOperator(string message, bytes32 indexed messageID, bytes32 id, string name, string ipfs, address indexed account, address indexed origin);
  event LogConsensus(string message, bytes32 indexed messageID, bytes32 executionID, bytes32 votesID, uint votes, uint tokens, uint quorum, address indexed origin);


  // --------------------------------------------------------------------------------------
  // Caller must be registered as a contract through ContractManager.sol
  // --------------------------------------------------------------------------------------
  modifier onlyApprovedContract() {
      require(database.boolStorage(keccak256(abi.encodePacked("contract", msg.sender))));
      _;
  }

}

// File: contracts/interfaces/EscrowReserveInterface.sol



// File: contracts/roles/AssetManagerEscrow.sol



  

  // @title A contract to hold escrow as collateral against assets
  // @author Kyle Dewhurst, MyBit Foundation
  // @notice AssetManager can lock his escrow in this contract and retrieve it if asset funding fails or successfully returns ROI
  contract AssetManagerEscrow {

    using SafeMath for uint256;

    DBInterface public database;
    Events public events;
    EscrowReserveInterface private reserve;

    //uint public consensus = 66;

    // @notice constructor: initializes database
    // @param: the address for the database contract used by this platform
    constructor(address _database, address _events)
    public {
      database = DBInterface(_database);
      events = Events(_events);
      reserve = EscrowReserveInterface(database.addressStorage(keccak256(abi.encodePacked("contract", "EscrowReserve"))));
    }

    // @dev anybody can make the assetManager escrow if he leaves this contract with approval to transfer
    function lockEscrow(address _assetAddress, address _assetManager, uint _amount)
    public
    returns (bool) {
      require(lockEscrowInternal(_assetManager, _assetAddress, _amount));
      return true;
    }

    // @notice assetManager can unlock his escrow here once funding fails or asset returns sufficient ROI
    // @dev asset must have fundingDeadline = 0 or have ROI > 25%
    // @dev returns escrow according to ROI. 25% ROI returns 25% of escrow, 50% ROI returns 50% of escrow etc...
    function unlockEscrow(address _assetAddress)
    public
    returns (bool) {
      bytes32 assetManagerEscrowID = keccak256(abi.encodePacked(_assetAddress, msg.sender));
      require(database.uintStorage(keccak256(abi.encodePacked("asset.escrow", assetManagerEscrowID))) != 0, 'Asset escrow is zero');
      //require(database.uintStorage(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress))) < now, 'Before crowdsale deadline');
      address platformToken = database.addressStorage(keccak256(abi.encodePacked("platform.token")));
      uint totalEscrow = database.uintStorage(keccak256(abi.encodePacked("asset.escrow", assetManagerEscrowID)));
      uint escrowRedeemed = database.uintStorage(keccak256(abi.encodePacked("asset.escrowRedeemed", assetManagerEscrowID)));
      uint unlockAmount = totalEscrow.sub(escrowRedeemed);
      if(!database.boolStorage(keccak256(abi.encodePacked("crowdsale.finalized", _assetAddress)))){
        require(database.uintStorage(keccak256(abi.encodePacked("crowdsale.deadline", _assetAddress))) < now);
        //Crowdsale failed, return escrow
        emit NotFinalized();
        //If we're past deadline but crowdsale did NOT finalize, release all escrow
        require(removeAssetManager(_assetAddress));
        require(removeEscrowData(assetManagerEscrowID));
        require(reserve.issueERC20(msg.sender, unlockAmount, platformToken));
        return true;
      } else {
        //Crowdsale finalized. Only pay back based on ROI
        AssetManagerEscrow_DivToken token = AssetManagerEscrow_DivToken(_assetAddress);
        uint roiPercent = token.assetIncome().mul(100).div(token.totalSupply());   // Scaled up by 10^2  (approaches 100 as asset income increases)
        uint roiCheckpoints = roiPercent.div(25);       // How many quarterly increments have been reached?
        emit ROICheckpoint(roiCheckpoints);
        require(roiCheckpoints > 0);
        if(roiCheckpoints <= 4){
          // Can't unlock escrow past 100% ROI
          //  multiply the number of quarterly increments by a quarter of the escrow and subtract the escrow already redeemed.
          uint quarterEscrow = totalEscrow.div(4);
          unlockAmount = roiCheckpoints.mul(quarterEscrow).sub(escrowRedeemed);
        }
        require(unlockAmount > 0);
        database.setUint(keccak256(abi.encodePacked("asset.escrowRedeemed", assetManagerEscrowID)), escrowRedeemed.add(unlockAmount));
        require(reserve.issueERC20(msg.sender, unlockAmount, platformToken));
        return true;
      }
    }


    // @notice investors can vote to call this function for the new assetManager to then call
    // @dev new assetManager must approve this contract to transfer in and lock _ amount of platform tokens
    function changeAssetManager(address _assetAddress, address _newAssetManager, uint256 _amount, bool _withhold)
    external
    returns (bool) {
      require(_newAssetManager != address(0));
      require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("asset.dao.admin", _assetAddress))), "Only the asset DAO adminstrator contract may change the asset manager");
      address currentAssetManager = database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress)));
      require(currentAssetManager != _newAssetManager, "New asset manager is the same");
      //Remove current asset manager
      require(removeAssetManager(_assetAddress), 'Asset manager not removed');
      database.setAddress(keccak256(abi.encodePacked("asset.manager", _assetAddress)), _newAssetManager);
      if(!_withhold){
        processEscrow(_assetAddress, currentAssetManager);
      }
      require(lockEscrowInternal(_newAssetManager, _assetAddress, _amount), 'Failed to lock escrow');
      return true;
    }

    function returnEscrow(address _assetAddress, address _oldAssetManager)
    external
    {
      require(database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress))) == msg.sender);
      processEscrow(_assetAddress, _oldAssetManager);
    }

    function voteToBurn(address _assetAddress)
    external
    returns (bool) {
      require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("asset.dao.admin", _assetAddress))), "Only the asset DAO adminstrator contract may change the asset manager");
      bytes32 assetManagerEscrowID = keccak256(abi.encodePacked(_assetAddress, database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress)))));
      uint escrowRedeemed = database.uintStorage(keccak256(abi.encodePacked("asset.escrowRedeemed", assetManagerEscrowID)));
      uint escrowAmount = database.uintStorage(keccak256(abi.encodePacked("asset.escrow", assetManagerEscrowID)));
      require(reserve.burnERC20(escrowAmount.sub(escrowRedeemed), database.addressStorage(keccak256(abi.encodePacked("platform.token"))))); // burn manager tokens
      database.setUint(keccak256(abi.encodePacked("asset.escrowRedeemed", assetManagerEscrowID)), escrowAmount );  // mark burned _assetAddresss as redeemed
      return true;
    }

    /*
    //Burn platform tokens to unilaterally burn asset manager's escrow
    function mutualBurn(address _assetAddress, uint _amountToBurn)
    external
    returns (bool) {
      require(AssetManagerEscrow_DivToken(_assetAddress).balanceOf(msg.sender) > 0, 'Must be an asset holder');
      bytes32 assetManagerEscrowID = keccak256(abi.encodePacked(_assetAddress, database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress)))));
      uint escrowRedeemed = database.uintStorage(keccak256(abi.encodePacked("asset.escrowRedeemed", assetManagerEscrowID)));
      uint unlockAmount = database.uintStorage(keccak256(abi.encodePacked("asset.escrow", assetManagerEscrowID))).sub(escrowRedeemed);
      require(unlockAmount >= _amountToBurn, "asset manager has no escrow left");
      uint256 selfBurnAmount = _amountToBurn.getFractionalAmount(database.uintStorage(keccak256(abi.encodePacked("platform.burnRate"))));
      AssetManagerEscrow_ERC20 platformToken = AssetManagerEscrow_ERC20(database.addressStorage(keccak256(abi.encodePacked("platform.token"))));
      require(platformToken.balanceOf(msg.sender) >= selfBurnAmount);
      require(platformToken.burnFrom(msg.sender, selfBurnAmount));  // burn investor tokens
      require(reserve.burnERC20(_amountToBurn, address(platformToken))); // burn manager tokens
      database.setUint(keccak256(abi.encodePacked("asset.escrowRedeemed", assetManagerEscrowID)), escrowRedeemed.add(_amountToBurn));  // mark burned _assetAddresss as redeemed
      events.escrow('Escrow mutually burned', _assetAddress, assetManagerEscrowID, msg.sender, _amountToBurn);
      return true;
    }
    */

    // @notice platform owners can destroy contract here
    function destroy()
    onlyOwner
    external {
      events.transaction('AssetManagerEscrow destroyed', address(this), msg.sender, address(this).balance, address(0));
      selfdestruct(msg.sender);
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                            Internal/ Private Functions
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function processEscrow(address _assetAddress, address _oldAssetManager)
    private
    {
      bytes32 oldAssetManagerEscrowID = keccak256(abi.encodePacked(_assetAddress, _oldAssetManager));
      uint oldEscrowRemaining = database.uintStorage(keccak256(abi.encodePacked("asset.escrow", oldAssetManagerEscrowID))).sub(database.uintStorage(keccak256(abi.encodePacked("asset.escrowRedeemed", oldAssetManagerEscrowID))));
      require(removeEscrowData(oldAssetManagerEscrowID), 'Remove escrow data failed');
      if(oldEscrowRemaining > 0){
        require(reserve.issueERC20(_oldAssetManager, oldEscrowRemaining, database.addressStorage(keccak256(abi.encodePacked("platform.token")))), 'Funds not returned');
      }
    }

    function removeAssetManager(address _assetAddress)
    private
    returns (bool) {
        database.deleteAddress(keccak256(abi.encodePacked("asset.manager", _assetAddress)));
        return true;
    }

    function removeEscrowData(bytes32 _assetManagerEscrowID)
    private
    returns (bool) {
        database.deleteUint(keccak256(abi.encodePacked("asset.escrow", _assetManagerEscrowID)));
        database.deleteUint(keccak256(abi.encodePacked("asset.escrowRedeemed", _assetManagerEscrowID)));
        return true;
    }

    function lockEscrowInternal(address _assetManager, address _assetAddress, uint _amount)
    private
    returns (bool) {
      require(_assetManager == database.addressStorage(keccak256(abi.encodePacked("asset.manager", _assetAddress))));
      bytes32 assetManagerEscrowID = keccak256(abi.encodePacked(_assetAddress, _assetManager));
      require(database.uintStorage(keccak256(abi.encodePacked("asset.escrow", assetManagerEscrowID))) == 0, 'Asset escrow already set');
      AssetManagerEscrow_ERC20 platformToken = AssetManagerEscrow_ERC20(database.addressStorage(keccak256(abi.encodePacked("platform.token"))));
      require(platformToken.transferFrom(_assetManager, address(reserve), _amount));
      database.setUint(keccak256(abi.encodePacked("asset.escrow", assetManagerEscrowID)), _amount);
      events.escrow('Escrow locked', _assetAddress, assetManagerEscrowID, _assetManager, _amount);
      return true;
    }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //                                            Modifiers
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // @notice reverts if caller is not the owner
    modifier onlyOwner {
      require(database.boolStorage(keccak256(abi.encodePacked("owner", msg.sender))) == true);
      _;
    }

    event NotFinalized();
    event ROICheckpoint(uint checkpoint);
    /*
    event LogConsensus(bytes32 votesID, uint votes, uint _assetAddresss, bytes32 executionID, uint quorum);
    event LogEscrowBurned(bytes32 indexed _assetAddress, address indexed _assetManager, uint _amountBurnt);
    event LogEscrowLocked(bytes32 indexed _assetAddress, bytes32 indexed _assetManagerEscrowID, address indexed _assetManager, uint _amount);
    */
}