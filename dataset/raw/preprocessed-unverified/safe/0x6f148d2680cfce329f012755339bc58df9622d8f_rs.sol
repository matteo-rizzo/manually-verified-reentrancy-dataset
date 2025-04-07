/**

 *Submitted for verification at Etherscan.io on 2018-08-20

*/



pragma solidity 0.4.24;



// File: contracts/ERC677Receiver.sol



contract ERC677Receiver {

  function onTokenTransfer(address _from, uint _value, bytes _data) external returns(bool);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: contracts/ERC677.sol



contract ERC677 is ERC20 {

    event Transfer(address indexed from, address indexed to, uint value, bytes data);



    function transferAndCall(address, uint, bytes) external returns (bool);



}



// File: contracts/IBurnableMintableERC677Token.sol



contract IBurnableMintableERC677Token is ERC677 {

    function mint(address, uint256) public returns (bool);

    function burn(uint256 _value) public;

    function claimTokens(address _token, address _to) public;

}



// File: contracts/IBridgeValidators.sol







// File: contracts/libraries/Message.sol







// File: contracts/libraries/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts/upgradeability/EternalStorage.sol



/**

 * @title EternalStorage

 * @dev This contract holds all the necessary state variables to carry out the storage of any contract.

 */

contract EternalStorage {



    mapping(bytes32 => uint256) internal uintStorage;

    mapping(bytes32 => string) internal stringStorage;

    mapping(bytes32 => address) internal addressStorage;

    mapping(bytes32 => bytes) internal bytesStorage;

    mapping(bytes32 => bool) internal boolStorage;

    mapping(bytes32 => int256) internal intStorage;



}



// File: contracts/upgradeable_contracts/Validatable.sol



contract Validatable is EternalStorage {

    function validatorContract() public view returns(IBridgeValidators) {

        return IBridgeValidators(addressStorage[keccak256(abi.encodePacked("validatorContract"))]);

    }



    modifier onlyValidator() {

        require(validatorContract().isValidator(msg.sender));

        _;

    }



    modifier onlyOwner() {

        require(validatorContract().owner() == msg.sender);

        _;

    }



    function requiredSignatures() public view returns(uint256) {

        return validatorContract().requiredSignatures();

    }



}



// File: contracts/upgradeable_contracts/BasicBridge.sol



contract BasicBridge is EternalStorage, Validatable {

    using SafeMath for uint256;

    event GasPriceChanged(uint256 gasPrice);

    event RequiredBlockConfirmationChanged(uint256 requiredBlockConfirmations);

    event DailyLimitChanged(uint256 newLimit);



    function setGasPrice(uint256 _gasPrice) public onlyOwner {

        require(_gasPrice > 0);

        uintStorage[keccak256(abi.encodePacked("gasPrice"))] = _gasPrice;

        emit GasPriceChanged(_gasPrice);

    }



    function gasPrice() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("gasPrice"))];

    }



    function setRequiredBlockConfirmations(uint256 _blockConfirmations) public onlyOwner {

        require(_blockConfirmations > 0);

        uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))] = _blockConfirmations;

        emit RequiredBlockConfirmationChanged(_blockConfirmations);

    }



    function requiredBlockConfirmations() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))];

    }



    function deployedAtBlock() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("deployedAtBlock"))];

    }



    function setTotalSpentPerDay(uint256 _day, uint256 _value) internal {

        uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _day))] = _value;

    }



    function totalSpentPerDay(uint256 _day) public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _day))];

    }



    function minPerTx() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("minPerTx"))];

    }



    function maxPerTx() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("maxPerTx"))];

    }



    function setInitialize(bool _status) internal {

        boolStorage[keccak256(abi.encodePacked("isInitialized"))] = _status;

    }



    function isInitialized() public view returns(bool) {

        return boolStorage[keccak256(abi.encodePacked("isInitialized"))];

    }



    function getCurrentDay() public view returns(uint256) {

        return now / 1 days;

    }



    function setDailyLimit(uint256 _dailyLimit) public onlyOwner {

        uintStorage[keccak256(abi.encodePacked("dailyLimit"))] = _dailyLimit;

        emit DailyLimitChanged(_dailyLimit);

    }



    function dailyLimit() public view returns(uint256) {

        return uintStorage[keccak256(abi.encodePacked("dailyLimit"))];

    }



    function setMaxPerTx(uint256 _maxPerTx) external onlyOwner {

        require(_maxPerTx < dailyLimit());

        uintStorage[keccak256(abi.encodePacked("maxPerTx"))] = _maxPerTx;

    }



    function setMinPerTx(uint256 _minPerTx) external onlyOwner {

        require(_minPerTx < dailyLimit() && _minPerTx < maxPerTx());

        uintStorage[keccak256(abi.encodePacked("minPerTx"))] = _minPerTx;

    }



    function withinLimit(uint256 _amount) public view returns(bool) {

        uint256 nextLimit = totalSpentPerDay(getCurrentDay()).add(_amount);

        return dailyLimit() >= nextLimit && _amount <= maxPerTx() && _amount >= minPerTx();

    }



    function claimTokens(address _token, address _to) public onlyOwner {

        require(_to != address(0));

        if (_token == address(0)) {

            _to.transfer(address(this).balance);

            return;

        }



        ERC20Basic token = ERC20Basic(_token);

        uint256 balance = token.balanceOf(this);

        require(token.transfer(_to, balance));

    }



}



// File: contracts/upgradeable_contracts/BasicForeignBridge.sol



contract BasicForeignBridge is EternalStorage, Validatable {

    using SafeMath for uint256;

    /// triggered when relay of deposit from HomeBridge is complete

    event RelayedMessage(address recipient, uint value, bytes32 transactionHash);

    function executeSignatures(uint8[] vs, bytes32[] rs, bytes32[] ss, bytes message) external {

        Message.hasEnoughValidSignatures(message, vs, rs, ss, validatorContract());

        address recipient;

        uint256 amount;

        bytes32 txHash;

        address contractAddress;

        (recipient, amount, txHash, contractAddress) = Message.parseMessage(message);

        require(contractAddress == address(this));

        require(!relayedMessages(txHash));

        setRelayedMessages(txHash, true);

        require(onExecuteMessage(recipient, amount));

        emit RelayedMessage(recipient, amount, txHash);

    }



    function onExecuteMessage(address, uint256) internal returns(bool){

        // has to be defined

    }



    function setRelayedMessages(bytes32 _txHash, bool _status) internal {

        boolStorage[keccak256(abi.encodePacked("relayedMessages", _txHash))] = _status;

    }



    function relayedMessages(bytes32 _txHash) public view returns(bool) {

        return boolStorage[keccak256(abi.encodePacked("relayedMessages", _txHash))];

    }

}



// File: contracts/upgradeable_contracts/erc20_to_erc20/ForeignBridgeErcToErc.sol



contract ForeignBridgeErcToErc is BasicBridge, BasicForeignBridge {

    event RelayedMessage(address recipient, uint value, bytes32 transactionHash);



    function initialize(

        address _validatorContract,

        address _erc20token

    ) public returns(bool) {

        require(!isInitialized());

        require(_validatorContract != address(0));

        addressStorage[keccak256(abi.encodePacked("validatorContract"))] = _validatorContract;

        setErc20token(_erc20token);

        uintStorage[keccak256(abi.encodePacked("deployedAtBlock"))] = block.number;

        setInitialize(true);

        return isInitialized();

    }



    function claimTokens(address _token, address _to) public onlyOwner {

        require(_token != address(erc20token()));

        super.claimTokens(_token, _to);

    }



    function erc20token() public view returns(ERC20Basic) {

        return ERC20Basic(addressStorage[keccak256(abi.encodePacked("erc20token"))]);

    }



    function onExecuteMessage(address _recipient, uint256 _amount) internal returns(bool){

        return erc20token().transfer(_recipient, _amount);

    }



    function setErc20token(address _token) private {

        require(_token != address(0));

        addressStorage[keccak256(abi.encodePacked("erc20token"))] = _token;

    }

}