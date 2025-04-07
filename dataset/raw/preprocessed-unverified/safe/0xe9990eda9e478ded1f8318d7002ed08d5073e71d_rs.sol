/**

 *Submitted for verification at Etherscan.io on 2019-03-28

*/



pragma solidity ^0.5.0;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood:

 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 *

 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for

 * all accounts just by listening to said events. Note that this isn't required by the specification, and other

 * compliant implementations may not do it.

 */

contract ERC20 is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowed;



    uint256 private _totalSupply;



    /**

    * @dev Total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param owner The address to query the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param owner address The address which owns the funds.

     * @param spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];

    }



    /**

    * @dev Transfer token for a specified address

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param spender The address which will spend the funds.

     * @param value The amount of tokens to be spent.

     */

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    /**

     * @dev Transfer tokens from one address to another.

     * Note that while this function emits an Approval event, this is not required as per the specification,

     * and other compliant implementations may not emit the event.

     * @param from address The address which you want to send tokens from

     * @param to address The address which you want to transfer to

     * @param value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        emit Approval(from, msg.sender, _allowed[from][msg.sender]);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

    * @dev Transfer token for a specified addresses

    * @param from The address to transfer from.

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    /**

     * @dev Internal function that mints an amount of the token and assigns it to

     * an account. This encapsulates the modification of balances such that the

     * proper events are emitted.

     * @param account The account that will receive the created tokens.

     * @param value The amount that will be created.

     */

    function _mint(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.add(value);

        _balances[account] = _balances[account].add(value);

        emit Transfer(address(0), account, value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account.

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burn(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.sub(value);

        _balances[account] = _balances[account].sub(value);

        emit Transfer(account, address(0), value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account, deducting from the sender's allowance for said account. Uses the

     * internal burn function.

     * Emits an Approval event (reflecting the reduced allowance).

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burnFrom(address account, uint256 value) internal {

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);

        _burn(account, value);

        emit Approval(account, msg.sender, _allowed[account][msg.sender]);

    }

}



// File: contracts/assettoken/library/AssetTokenL.sol



/*

    Copyright 2018, CONDA



    This program is free software: you can redistribute it and/or modify

    it under the terms of the GNU General Public License as published by

    the Free Software Foundation, either version 3 of the License, or

    (at your option) any later version.



    This program is distributed in the hope that it will be useful,

    but WITHOUT ANY WARRANTY; without even the implied warranty of

    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

    GNU General Public License for more details.



    You should have received a copy of the GNU General Public License

    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/







/** @title AssetTokenL library. */





// File: contracts/assettoken/abstract/IBasicAssetTokenFull.sol



contract IBasicAssetTokenFull {

    function checkCanSetMetadata() internal returns (bool);



    function getCap() public view returns (uint256);

    function getGoal() public view returns (uint256);

    function getStart() public view returns (uint256);

    function getEnd() public view returns (uint256);

    function getLimits() public view returns (uint256, uint256, uint256, uint256);

    function setMetaData(

        string calldata _name, 

        string calldata _symbol, 

        address _tokenBaseCurrency, 

        uint256 _cap, 

        uint256 _goal, 

        uint256 _startTime, 

        uint256 _endTime) 

        external;

    

    function getTokenRescueControl() public view returns (address);

    function getPauseControl() public view returns (address);

    function isTransfersPaused() public view returns (bool);



    function setMintControl(address _mintControl) public;

    function setRoles(address _pauseControl, address _tokenRescueControl) public;



    function setTokenAlive() public;

    function isTokenAlive() public view returns (bool);



    function balanceOf(address _owner) public view returns (uint256 balance);



    function approve(address _spender, uint256 _amount) public returns (bool success);



    function allowance(address _owner, address _spender) public view returns (uint256 remaining);



    function totalSupply() public view returns (uint256);



    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool);



    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool);



    function finishMinting() public returns (bool);



    function rescueToken(address _foreignTokenAddress, address _to) public;



    function balanceOfAt(address _owner, uint256 _specificTransfersAndMintsIndex) public view returns (uint256);



    function totalSupplyAt(uint256 _specificTransfersAndMintsIndex) public view returns(uint256);



    function enableTransfers(bool _transfersEnabled) public;



    function pauseTransfer(bool _transfersEnabled) public;



    function pauseCapitalIncreaseOrDecrease(bool _mintingEnabled) public;    



    function isMintingPaused() public view returns (bool);



    function mint(address _to, uint256 _amount) public returns (bool);



    function transfer(address _to, uint256 _amount) public returns (bool success);



    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);



    function enableTransferInternal(bool _transfersEnabled) internal;



    function reopenCrowdsaleInternal() internal returns (bool);



    function transferFromInternal(address _from, address _to, uint256 _amount) internal returns (bool success);

    function enforcedTransferFromInternal(address _from, address _to, uint256 _value, bool _fullAmountRequired) internal returns (bool);



    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event MintDetailed(address indexed initiator, address indexed to, uint256 amount);

    event MintFinished(address indexed initiator);

    event TransferPaused(address indexed initiator);

    event TransferResumed(address indexed initiator);

    event Reopened(address indexed initiator);

    event MetaDataChanged(address indexed initiator, string name, string symbol, address baseCurrency, uint256 cap, uint256 goal, uint256 startTime, uint256 endTime);

    event RolesChanged(address indexed initiator, address _pauseControl, address _tokenRescueControl);

    event MintControlChanged(address indexed initiator, address mintControl);

}



// File: contracts/assettoken/BasicAssetToken.sol



/*

    Copyright 2018, CONDA



    This program is free software: you can redistribute it and/or modify

    it under the terms of the GNU General Public License as published by

    the Free Software Foundation, either version 3 of the License, or

    (at your option) any later version.



    This program is distributed in the hope that it will be useful,

    but WITHOUT ANY WARRANTY; without even the implied warranty of

    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

    GNU General Public License for more details.



    You should have received a copy of the GNU General Public License

    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/











/** @title Basic AssetToken. This contract includes the basic AssetToken features */

contract BasicAssetToken is IBasicAssetTokenFull, Ownable {



    using SafeMath for uint256;

    using AssetTokenL for AssetTokenL.Supply;

    using AssetTokenL for AssetTokenL.Availability;

    using AssetTokenL for AssetTokenL.Roles;



///////////////////

// Variables

///////////////////



    string private _name;

    string private _symbol;



    // The token's name

    function name() public view returns (string memory) {

        return _name;

    }



    // Fixed number of 0 decimals like real world equity

    function decimals() public pure returns (uint8) {

        return 0;

    }



    // An identifier

    function symbol() public view returns (string memory) {

        return _symbol;

    }



    // 1000 is version 1

    uint16 public constant version = 2000;



    // Defines the baseCurrency of the token

    address public baseCurrency;



    // Supply: balance, checkpoints etc.

    AssetTokenL.Supply supply;



    // Availability: what's paused

    AssetTokenL.Availability availability;



    // Roles: who is entitled

    AssetTokenL.Roles roles;



///////////////////

// Simple state getters

///////////////////



    function isMintingPaused() public view returns (bool) {

        return availability.mintingPaused;

    }



    function isMintingPhaseFinished() public view returns (bool) {

        return availability.mintingPhaseFinished;

    }



    function getPauseControl() public view returns (address) {

        return roles.pauseControl;

    }



    function getTokenRescueControl() public view returns (address) {

        return roles.tokenRescueControl;

    }



    function getMintControl() public view returns (address) {

        return roles.mintControl;

    }



    function isTransfersPaused() public view returns (bool) {

        return !availability.transfersEnabled;

    }



    function isTokenAlive() public view returns (bool) {

        return availability.tokenAlive;

    }



    function getCap() public view returns (uint256) {

        return supply.cap;

    }



    function getGoal() public view returns (uint256) {

        return supply.goal;

    }



    function getStart() public view returns (uint256) {

        return supply.startTime;

    }



    function getEnd() public view returns (uint256) {

        return supply.endTime;

    }



    function getLimits() public view returns (uint256, uint256, uint256, uint256) {

        return (supply.cap, supply.goal, supply.startTime, supply.endTime);

    }



    function getCurrentHistoryIndex() public view returns (uint256) {

        return supply.tokenActionIndex;

    }



///////////////////

// Events

///////////////////



    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event MintDetailed(address indexed initiator, address indexed to, uint256 amount);

    event MintFinished(address indexed initiator);

    event TransferPaused(address indexed initiator);

    event TransferResumed(address indexed initiator);

    event MintingPaused(address indexed initiator);

    event MintingResumed(address indexed initiator);

    event Reopened(address indexed initiator);

    event MetaDataChanged(address indexed initiator, string name, string symbol, address baseCurrency, uint256 cap, uint256 goal, uint256 startTime, uint256 endTime);

    event RolesChanged(address indexed initiator, address pauseControl, address tokenRescueControl);

    event MintControlChanged(address indexed initiator, address mintControl);

    event TokenActionIndexIncreased(uint256 tokenActionIndex, uint256 blocknumber);



///////////////////

// Modifiers

///////////////////

    modifier onlyPauseControl() {

        require(msg.sender == roles.pauseControl, "pauseCtrl");

        _;

    }



    //can be overwritten in inherited contracts...

    function _canDoAnytime() internal view returns (bool) {

        return false;

    }



    modifier onlyOwnerOrOverruled() {

        if(_canDoAnytime() == false) { 

            require(isOwner(), "only owner");

        }

        _;

    }



    modifier canMint() {

        if(_canDoAnytime() == false) { 

            require(canMintLogic(), "canMint");

        }

        _;

    }



    function canMintLogic() private view returns (bool) {

        return msg.sender == roles.mintControl && availability.tokenAlive && !availability.mintingPhaseFinished && !availability.mintingPaused;

    }



    //can be overwritten in inherited contracts...

    function checkCanSetMetadata() internal returns (bool) {

        if(_canDoAnytime() == false) {

            require(isOwner(), "owner only");

            require(!availability.tokenAlive, "alive");

            require(!availability.mintingPhaseFinished, "finished");

        }



        return true;

    }



    modifier canSetMetadata() {

        checkCanSetMetadata();

        _;

    }



    modifier onlyTokenAlive() {

        require(availability.tokenAlive, "not alive");

        _;

    }



    modifier onlyTokenRescueControl() {

        require(msg.sender == roles.tokenRescueControl, "rescueCtrl");

        _;

    }



    modifier canTransfer() {

        require(availability.transfersEnabled, "paused");

        _;

    }



///////////////////

// Set / Get Metadata

///////////////////



    /// @notice Change the token's metadata.

    /// @dev Time is via block.timestamp (check crowdsale contract)

    /// @param _nameParam The name of the token.

    /// @param _symbolParam The symbol of the token.

    /// @param _tokenBaseCurrency The base currency.

    /// @param _cap The max amount of tokens that can be minted.

    /// @param _goal The goal of tokens that should be sold.

    /// @param _startTime Time when crowdsale should start.

    /// @param _endTime Time when crowdsale should end.

    function setMetaData(

        string calldata _nameParam, 

        string calldata _symbolParam, 

        address _tokenBaseCurrency, 

        uint256 _cap, 

        uint256 _goal, 

        uint256 _startTime, 

        uint256 _endTime) 

        external 

    canSetMetadata 

    {

        require(_cap >= _goal, "cap higher goal");



        _name = _nameParam;

        _symbol = _symbolParam;



        baseCurrency = _tokenBaseCurrency;

        supply.cap = _cap;

        supply.goal = _goal;

        supply.startTime = _startTime;

        supply.endTime = _endTime;



        emit MetaDataChanged(msg.sender, _nameParam, _symbolParam, _tokenBaseCurrency, _cap, _goal, _startTime, _endTime);

    }



    /// @notice Set mint control role. Usually this is CONDA's controller.

    /// @param _mintControl Contract address or wallet that should be allowed to mint.

    function setMintControl(address _mintControl) public canSetMetadata {

        roles.setMintControl(_mintControl);

    }



    /// @notice Set roles.

    /// @param _pauseControl address that is allowed to pause.

    /// @param _tokenRescueControl address that is allowed rescue tokens.

    function setRoles(address _pauseControl, address _tokenRescueControl) public 

    canSetMetadata

    {

        roles.setRoles(_pauseControl, _tokenRescueControl);

    }



    function setTokenAlive() public 

    onlyOwnerOrOverruled

    {

        availability.setTokenAlive();

    }



///////////////////

// ERC20 Methods

///////////////////



    /// @notice Send `_amount` tokens to `_to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _amount The amount of tokens to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address _to, uint256 _amount) public canTransfer returns (bool success) {

        supply.doTransfer(availability, msg.sender, _to, _amount);

        return true;

    }



    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition (requires allowance/approval)

    /// @param _from The address holding the tokens being transferred

    /// @param _to The address of the recipient

    /// @param _amount The amount of tokens to be transferred

    /// @return True if the transfer was successful

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {

        return transferFromInternal(_from, _to, _amount);

    }



    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition (requires allowance/approval)

    /// @dev modifiers in this internal method because also used by features.

    /// @param _from The address holding the tokens being transferred

    /// @param _to The address of the recipient

    /// @param _amount The amount of tokens to be transferred

    /// @return True if the transfer was successful

    function transferFromInternal(address _from, address _to, uint256 _amount) internal canTransfer returns (bool success) {

        return supply.transferFrom(availability, _from, _to, _amount);

    }



    /// @notice balance of `_owner` for this token

    /// @param _owner The address that's balance is being requested

    /// @return The balance of `_owner` now (at the current index)

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return supply.balanceOfNow(_owner);

    }



    /// @notice `msg.sender` approves `_spender` to spend `_amount` of his tokens

    /// @dev This is a modified version of the ERC20 approve function to be a bit safer

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _amount The amount of tokens to be approved for transfer

    /// @return True if the approval was successful

    function approve(address _spender, uint256 _amount) public returns (bool success) {

        return supply.approve(_spender, _amount);

    }



    /// @notice This method can check how much is approved by `_owner` for `_spender`

    /// @dev This function makes it easy to read the `allowed[]` map

    /// @param _owner The address of the account that owns the token

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens of _owner that _spender is allowed to spend

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return supply.allowed[_owner][_spender];

    }



    /// @notice This function makes it easy to get the total number of tokens

    /// @return The total number of tokens now (at current index)

    function totalSupply() public view returns (uint256) {

        return supply.totalSupplyNow();

    }





    /// @notice Increase the amount of tokens that an owner allowed to a spender.

    /// @dev approve should be called when allowed[_spender] == 0. To increment

    /// allowed value is better to use this function to avoid 2 calls (and wait until

    /// the first transaction is mined)

    /// From MonolithDAO Token.sol

    /// @param _spender The address which will spend the funds.

    /// @param _addedValue The amount of tokens to increase the allowance by.

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {

        return supply.increaseApproval(_spender, _addedValue);

    }



    /// @dev Decrease the amount of tokens that an owner allowed to a spender.

    /// approve should be called when allowed[_spender] == 0. To decrement

    /// allowed value is better to use this function to avoid 2 calls (and wait until

    /// the first transaction is mined)

    /// From MonolithDAO Token.sol

    /// @param _spender The address which will spend the funds.

    /// @param _subtractedValue The amount of tokens to decrease the allowance by.

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {

        return supply.decreaseApproval(_spender, _subtractedValue);

    }



////////////////

// Miniting 

////////////////



    /// @dev Can rescue tokens accidentally assigned to this contract

    /// @param _to The beneficiary who receives increased balance.

    /// @param _amount The amount of balance increase.

    function mint(address _to, uint256 _amount) public canMint returns (bool) {

        return supply.mint(_to, _amount);

    }



    /// @notice Function to stop minting new tokens

    /// @return True if the operation was successful.

    function finishMinting() public onlyOwnerOrOverruled returns (bool) {

        return availability.finishMinting();

    }



////////////////

// Rescue Tokens 

////////////////



    /// @dev Can rescue tokens accidentally assigned to this contract

    /// @param _foreignTokenAddress The address from which the balance will be retrieved

    /// @param _to beneficiary

    function rescueToken(address _foreignTokenAddress, address _to)

    public

    onlyTokenRescueControl

    {

        availability.rescueToken(_foreignTokenAddress, _to);

    }



////////////////

// Query balance and totalSupply in History

////////////////



    /// @notice Someone's token balance of this token

    /// @dev Queries the balance of `_owner` at `_specificTransfersAndMintsIndex`

    /// @param _owner The address from which the balance will be retrieved

    /// @param _specificTransfersAndMintsIndex The balance at index

    /// @return The balance at `_specificTransfersAndMintsIndex`

    function balanceOfAt(address _owner, uint256 _specificTransfersAndMintsIndex) public view returns (uint256) {

        return supply.balanceOfAt(_owner, _specificTransfersAndMintsIndex);

    }



    /// @notice Total amount of tokens at `_specificTransfersAndMintsIndex`.

    /// @param _specificTransfersAndMintsIndex The totalSupply at index

    /// @return The total amount of tokens at `_specificTransfersAndMintsIndex`

    function totalSupplyAt(uint256 _specificTransfersAndMintsIndex) public view returns(uint256) {

        return supply.totalSupplyAt(_specificTransfersAndMintsIndex);

    }



////////////////

// Enable tokens transfers

////////////////



    /// @dev this function is not public and can be overwritten

    function enableTransferInternal(bool _transfersEnabled) internal {

        availability.pauseTransfer(_transfersEnabled);

    }



    /// @notice Enables token holders to transfer their tokens freely if true

    /// @param _transfersEnabled True if transfers are allowed

    function enableTransfers(bool _transfersEnabled) public 

    onlyOwnerOrOverruled 

    {

        enableTransferInternal(_transfersEnabled);

    }



////////////////

// Pausing token for unforeseen reasons

////////////////



    /// @dev `pauseTransfer` is an alias for `enableTransfers` using the pauseControl modifier

    /// @param _transfersEnabled False if transfers are allowed

    function pauseTransfer(bool _transfersEnabled) public

    onlyPauseControl

    {

        enableTransferInternal(_transfersEnabled);

    }



    /// @dev `pauseCapitalIncreaseOrDecrease` can pause mint

    /// @param _mintingEnabled False if minting is allowed

    function pauseCapitalIncreaseOrDecrease(bool _mintingEnabled) public

    onlyPauseControl

    {

        availability.pauseCapitalIncreaseOrDecrease(_mintingEnabled);

    }



    /// @dev capitalControl (if exists) can reopen the crowdsale.

    /// this function is not public and can be overwritten

    function reopenCrowdsaleInternal() internal returns (bool) {

        return availability.reopenCrowdsale();

    }



    /// @dev capitalControl (if exists) can enforce a transferFrom e.g. in case of lost wallet.

    /// this function is not public and can be overwritten

    function enforcedTransferFromInternal(address _from, address _to, uint256 _value, bool _fullAmountRequired) internal returns (bool) {

        return supply.enforcedTransferFrom(availability, _from, _to, _value, _fullAmountRequired);

    }

}



// File: contracts/assettoken/interfaces/ICRWDControllerTransfer.sol







// File: contracts/assettoken/interfaces/IGlobalIndexControllerLocation.sol







// File: contracts/assettoken/abstract/ICRWDAssetToken.sol



contract ICRWDAssetToken is IBasicAssetTokenFull {

    function setGlobalIndexAddress(address _globalIndexAddress) public;

}



// File: contracts/assettoken/CRWDAssetToken.sol



/*

    Copyright 2018, CONDA



    This program is free software: you can redistribute it and/or modify

    it under the terms of the GNU General Public License as published by

    the Free Software Foundation, either version 3 of the License, or

    (at your option) any later version.



    This program is distributed in the hope that it will be useful,

    but WITHOUT ANY WARRANTY; without even the implied warranty of

    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

    GNU General Public License for more details.



    You should have received a copy of the GNU General Public License

    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/













/** @title CRWD AssetToken. This contract inherits basic functionality and extends calls to controller. */

contract CRWDAssetToken is BasicAssetToken, ICRWDAssetToken {



    using SafeMath for uint256;



    IGlobalIndexControllerLocation public globalIndex;



    function getControllerAddress() public view returns (address) {

        return globalIndex.getControllerAddress();

    }



    /** @dev ERC20 transfer function overlay to transfer tokens and call controller.

      * @param _to The recipient address.

      * @param _amount The amount.

      * @return A boolean that indicates if the operation was successful.

      */

    function transfer(address _to, uint256 _amount) public returns (bool success) {

        ICRWDControllerTransfer(getControllerAddress()).transferParticipantsVerification(baseCurrency, msg.sender, _to, _amount);

        return super.transfer(_to, _amount);

    }



    /** @dev ERC20 transferFrom function overlay to transfer tokens and call controller.

      * @param _from The sender address (requires approval).

      * @param _to The recipient address.

      * @param _amount The amount.

      * @return A boolean that indicates if the operation was successful.

      */

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {

        ICRWDControllerTransfer(getControllerAddress()).transferParticipantsVerification(baseCurrency, _from, _to, _amount);

        return super.transferFrom(_from, _to, _amount);

    }



    /** @dev Mint function overlay to mint/create tokens.

      * @param _to The address that will receive the minted tokens.

      * @param _amount The amount of tokens to mint.

      * @return A boolean that indicates if the operation was successful.

      */

    function mint(address _to, uint256 _amount) public canMint returns (bool) {

        return super.mint(_to,_amount);

    }



    /** @dev Set address of GlobalIndex.

      * @param _globalIndexAddress Address to be used for current destination e.g. controller lookup.

      */

    function setGlobalIndexAddress(address _globalIndexAddress) public onlyOwner {

        globalIndex = IGlobalIndexControllerLocation(_globalIndexAddress);

    }

}



// File: contracts/assettoken/feature/FeatureCapitalControl.sol



/*

    Copyright 2018, CONDA



    This program is free software: you can redistribute it and/or modify

    it under the terms of the GNU General Public License as published by

    the Free Software Foundation, either version 3 of the License, or

    (at your option) any later version.



    This program is distributed in the hope that it will be useful,

    but WITHOUT ANY WARRANTY; without even the implied warranty of

    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

    GNU General Public License for more details.



    You should have received a copy of the GNU General Public License

    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/





/** @title FeatureCapitalControl. */

contract FeatureCapitalControl is ICRWDAssetToken {

    

////////////////

// Variables

////////////////



    //if set can mint after finished. E.g. a notary.

    address public capitalControl;



////////////////

// Constructor

////////////////



    constructor(address _capitalControl) public {

        capitalControl = _capitalControl;

        enableTransferInternal(false); //disable transfer as default

    }



////////////////

// Modifiers

////////////////



    //override: skip certain modifier checks as capitalControl

    function _canDoAnytime() internal view returns (bool) {

        return msg.sender == capitalControl;

    }



    modifier onlyCapitalControl() {

        require(msg.sender == capitalControl, "permission");

        _;

    }



////////////////

// Functions

////////////////



    /// @notice set capitalControl

    /// @dev this looks unprotected but has a checkCanSetMetadata check.

    ///  depending on inheritance this can be done 

    ///  before alive and any time by capitalControl

    function setCapitalControl(address _capitalControl) public {

        require(checkCanSetMetadata(), "forbidden");



        capitalControl = _capitalControl;

    }



    /// @notice as capital control I can pass my ownership to a new address (e.g. private key leaked).

    /// @param _capitalControl new capitalControl address

    function updateCapitalControl(address _capitalControl) public onlyCapitalControl {

        capitalControl = _capitalControl;

    }



////////////////

// Reopen crowdsale (by capitalControl e.g. notary)

////////////////



    /// @notice capitalControl can reopen the crowdsale.

    function reopenCrowdsale() public onlyCapitalControl returns (bool) {        

        return reopenCrowdsaleInternal();

    }

}



// File: contracts/assettoken/feature/FeatureCapitalControlWithForcedTransferFrom.sol



/*

    Copyright 2018, CONDA



    This program is free software: you can redistribute it and/or modify

    it under the terms of the GNU General Public License as published by

    the Free Software Foundation, either version 3 of the License, or

    (at your option) any later version.



    This program is distributed in the hope that it will be useful,

    but WITHOUT ANY WARRANTY; without even the implied warranty of

    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

    GNU General Public License for more details.



    You should have received a copy of the GNU General Public License

    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/







/** @title FeatureCapitalControlWithForcedTransferFrom. */

contract FeatureCapitalControlWithForcedTransferFrom is FeatureCapitalControl {



///////////////////

// Constructor

///////////////////



    constructor(address _capitalControl) FeatureCapitalControl(_capitalControl) public { }



///////////////////

// Events

///////////////////



    event SelfApprovedTransfer(address indexed initiator, address indexed from, address indexed to, uint256 value);





///////////////////

// Overrides

///////////////////



    //override: transferFrom that has special self-approve behaviour when executed as capitalControl

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool)

    {

        if (msg.sender == capitalControl) {

            return enforcedTransferFromInternal(_from, _to, _value, true);

        } else {

            return transferFromInternal(_from, _to, _value);

        }

    }



}



// File: contracts/assettoken/STOs/AssetTokenT001.sol



/** @title AssetTokenT001 Token. A CRWDAssetToken with CapitalControl and LostWallet feature */

contract AssetTokenT001 is CRWDAssetToken, FeatureCapitalControlWithForcedTransferFrom

{    

    constructor(address _capitalControl) FeatureCapitalControlWithForcedTransferFrom(_capitalControl) public {}

}