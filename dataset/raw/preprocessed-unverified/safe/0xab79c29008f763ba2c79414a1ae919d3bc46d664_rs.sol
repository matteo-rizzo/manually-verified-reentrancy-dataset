/**

 *Submitted for verification at Etherscan.io on 2019-06-01

*/



pragma solidity ^0.5.7;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error.

 */













/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */







/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://eips.ethereum.org/EIPS/eip-20

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

     * @dev Total number of tokens in existence.

     */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

     * @dev Gets the balance of the specified address.

     * @param owner The address to query the balance of.

     * @return A uint256 representing the amount owned by the passed address.

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

     * @dev Transfer token to a specified address.

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

        _approve(msg.sender, spender, value);

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

        _transfer(from, to, value);

        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when _allowed[msg.sender][spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));

        return true;

    }



    /**

     * @dev Transfer token for a specified addresses.

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

     * @dev Approve an address to spend another addresses' tokens.

     * @param owner The address that owns the tokens.

     * @param spender The address that will spend the tokens.

     * @param value The number of tokens that can be spent.

     */

    function _approve(address owner, address spender, uint256 value) internal {

        require(spender != address(0));

        require(owner != address(0));



        _allowed[owner][spender] = value;

        emit Approval(owner, spender, value);

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

        _burn(account, value);

        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));

    }

}



/**

 * @title ERC20Detailed token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract ERC20Detailed is IERC20 {

    string private _name;

    string private _symbol;

    uint8 private _decimals;



    constructor (string memory name, string memory symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }



    /**

     * @return the name of the token.

     */

    function name() public view returns (string memory) {

        return _name;

    }



    /**

     * @return the symbol of the token.

     */

    function symbol() public view returns (string memory) {

        return _symbol;

    }



    /**

     * @return the number of decimals of the token.

     */

    function decimals() public view returns (uint8) {

        return _decimals;

    }

}





contract ERC20Votable is ERC20{

    

    // Use itmap for all functions on the struct

    using IterableMap for IterableMap.IMap;

    using SafeMath for uint256;

    

    // event

    event MintToken(uint256 sessionID, address indexed beneficiary, uint256 amount);

    event MintFinished(uint256 sessionID);

    event BurnToken(uint256 sessionID, address indexed beneficiary, uint256 amount);

    event AddAuthority(uint256 sessionID, address indexed authority);

    event RemoveAuthority(uint256 sessionID, address indexed authority);

    event ChangeRequiredApproval(uint256 sessionID, uint256 from, uint256 to);

    

    event VoteAccept(uint256 sessionID, address indexed authority);

    event VoteReject(uint256 sessionID, address indexed authority);

    

    // constant

    uint256 constant NUMBER_OF_BLOCK_FOR_SESSION_EXPIRE = 5760;



    // Declare an iterable mapping

    IterableMap.IMap authorities;

    

    bool public isMintingFinished;

    

    struct Topic {

        uint8 BURN;

        uint8 MINT;

        uint8 MINT_FINISHED;

        uint8 ADD_AUTHORITY;

        uint8 REMOVE_AUTHORITY;

        uint8 CHANGE_REQUIRED_APPROVAL;

    }

    

    struct Session {

        uint256 id;

        uint8 topic;

        uint256 blockNo;

        uint256 referNumber;

        address referAddress;

        uint256 countAccept;

        uint256 countReject;

       // number of approval from authories to accept the current session

        uint256 requireAccept;

    }

    

    ERC20Votable.Topic topic;

    ERC20Votable.Session session;

    

    constructor() public {

        

        topic.BURN = 1;

        topic.MINT = 2;

        topic.MINT_FINISHED = 3;

        topic.ADD_AUTHORITY = 4;

        topic.REMOVE_AUTHORITY = 5;

        topic.CHANGE_REQUIRED_APPROVAL = 6;

        

        session.id = 1;

        session.requireAccept = 1;

    

        authorities.insert(msg.sender, session.id);

    }

    

    /**

     * @dev modifier

     */

    modifier onlyAuthority() {

        require(authorities.contains(msg.sender));

        _;

    }

    

    modifier onlySessionAvailable() {

        require(_isSessionAvailable());

        _;

    }

    

     modifier onlyHasSession() {

        require(!_isSessionAvailable());

        _;

    }

    

    function isAuthority(address _address) public view returns (bool){

        return authorities.contains(_address);

    }



    /**

     * @dev get session detail

     */

    function getSessionName() public view returns (string memory){

        

        bool isSession = !_isSessionAvailable();

        

        if(isSession){

            return (_getSessionName());

        }

        

        return "None";

    }

    

    function getSessionExpireAtBlockNo() public view returns (uint256){

        

        bool isSession = !_isSessionAvailable();

        

        if(isSession){

            return (session.blockNo.add(NUMBER_OF_BLOCK_FOR_SESSION_EXPIRE));

        }

        

        return 0;

    }

    

    function getSessionVoteAccept() public view returns (uint256){

      

        bool isSession = !_isSessionAvailable();

        

        if(isSession){

            return session.countAccept;

        }

        

        return 0;

    }

    

    function getSessionVoteReject() public view returns (uint256){

      

        bool isSession = !_isSessionAvailable();

        

        if(isSession){

            return session.countReject;

        }

        

        return 0;

    }

    

    function getSessionRequiredAcceptVote() public view returns (uint256){

      

        return session.requireAccept;

    }

    

    function getTotalAuthorities() public view returns (uint256){

      

        return authorities.size();

    }

    



    

    /**

     * @dev create session

     */

     

    function createSessionMintToken(address _beneficiary, uint256 _amount) public onlyAuthority onlySessionAvailable {

        

        require(!isMintingFinished);

        require(_amount > 0);

        require(_beneficiary != address(0));

       

        _createSession(topic.MINT);

        session.referNumber = _amount;

        session.referAddress = _beneficiary;

    }

    

    function createSessionMintFinished() public onlyAuthority onlySessionAvailable {

        

        require(!isMintingFinished);

        _createSession(topic.MINT_FINISHED);

        session.referNumber = 0;

        session.referAddress = address(0);

    }

    

    function createSessionBurnAuthorityToken(address _authority, uint256 _amount) public onlyAuthority onlySessionAvailable {

        

        require(_amount > 0);

        require(_authority != address(0));

        require(isAuthority(_authority));

       

        _createSession(topic.BURN);

        session.referNumber = _amount;

        session.referAddress = _authority;

    }

    

    function createSessionAddAuthority(address _authority) public onlyAuthority onlySessionAvailable {

        

        require(!authorities.contains(_authority));

        

        _createSession(topic.ADD_AUTHORITY);

        session.referNumber = 0;

        session.referAddress = _authority;

    }

    

    function createSessionRemoveAuthority(address _authority) public onlyAuthority onlySessionAvailable {

        

        require(authorities.contains(_authority));

        

        // at least 1 authority remain

        require(authorities.size() > 1);

      

        _createSession(topic.REMOVE_AUTHORITY);

        session.referNumber = 0;

        session.referAddress = _authority;

    }

    

    function createSessionChangeRequiredApproval(uint256 _to) public onlyAuthority onlySessionAvailable {

        

        require(_to != session.requireAccept);

        require(_to <= authorities.size());



        _createSession(topic.CHANGE_REQUIRED_APPROVAL);

        session.referNumber = _to;

        session.referAddress = address(0);

    }

    

    /**

     * @dev vote

     */

    function voteAccept() public onlyAuthority onlyHasSession {

        

        // already vote

        require(authorities.get(msg.sender) != session.id);

        

        authorities.insert(msg.sender, session.id);

        session.countAccept = session.countAccept.add(1);

        

        emit VoteAccept(session.id, session.referAddress);

        

        // execute

        if(session.countAccept >= session.requireAccept){

            

            if(session.topic == topic.BURN){

                

                _burnToken();

                

            }else if(session.topic == topic.MINT){

                

                _mintToken();

                

            }else if(session.topic == topic.MINT_FINISHED){

                

                _finishMinting();

                

            }else if(session.topic == topic.ADD_AUTHORITY){

                

                _addAuthority();    

            

            }else if(session.topic == topic.REMOVE_AUTHORITY){

                

                _removeAuthority();  

                

            }else if(session.topic == topic.CHANGE_REQUIRED_APPROVAL){

                

                _changeRequiredApproval();  

                

            }

        }

    }

    

    function voteReject() public onlyAuthority onlyHasSession {

        

        // already vote

        require(authorities.get(msg.sender) != session.id);

        

        authorities.insert(msg.sender, session.id);

        session.countReject = session.countReject.add(1);

        

        emit VoteReject(session.id, session.referAddress);

    }

    

    /**

     * @dev private

     */

    function _createSession(uint8 _topic) internal {

        

        session.topic = _topic;

        session.countAccept = 0;

        session.countReject = 0;

        session.id = session.id.add(1);

        session.blockNo = block.number;

    }

    

    function _getSessionName() internal view returns (string memory){

        

        string memory topicName = "";

        

        if(session.topic == topic.BURN){

          

           topicName = StringUtils.append3("Burn ", StringUtils.uint2str(session.referNumber) , " token(s)");

           

        }else if(session.topic == topic.MINT){

          

           topicName = StringUtils.append4("Mint ", StringUtils.uint2str(session.referNumber) , " token(s) to address 0x", StringUtils.toAsciiString(session.referAddress));

         

        }else if(session.topic == topic.MINT_FINISHED){

          

           topicName = "Finish minting";

         

        }else if(session.topic == topic.ADD_AUTHORITY){

          

           topicName = StringUtils.append3("Add 0x", StringUtils.toAsciiString(session.referAddress), " to authorities");

           

        }else if(session.topic == topic.REMOVE_AUTHORITY){

            

            topicName = StringUtils.append3("Remove 0x", StringUtils.toAsciiString(session.referAddress), " from authorities");

            

        }else if(session.topic == topic.CHANGE_REQUIRED_APPROVAL){

            

            topicName = StringUtils.append4("Change approval from ", StringUtils.uint2str(session.requireAccept), " to ", StringUtils.uint2str(session.referNumber));

            

        }

        

        return topicName;

    }

    

    function _isSessionAvailable() internal view returns (bool){

        

        // vote result accept

        if(session.countAccept >= session.requireAccept) return true;

        

         // vote result reject

        if(session.countReject > authorities.size().sub(session.requireAccept)) return true;

        

        // vote expire (1 day)

        if(block.number.sub(session.blockNo) > NUMBER_OF_BLOCK_FOR_SESSION_EXPIRE) return true;

        

        return false;

    }   

    

    function _addAuthority() internal {

        

        authorities.insert(session.referAddress, session.id);

        emit AddAuthority(session.id, session.referAddress);

    }

    

    function _removeAuthority() internal {

        

        authorities.remove(session.referAddress);

        if(authorities.size() < session.requireAccept){

            emit ChangeRequiredApproval(session.id, session.requireAccept, authorities.size());

            session.requireAccept = authorities.size();

        }

        emit RemoveAuthority(session.id, session.referAddress);

    }

    

    function _changeRequiredApproval() internal {

        

        emit ChangeRequiredApproval(session.id, session.requireAccept, session.referNumber);

        session.requireAccept = session.referNumber;

        session.countAccept = session.requireAccept;

    }

    

    function _mintToken() internal {

        

        require(!isMintingFinished);

        _mint(session.referAddress, session.referNumber);

        emit MintToken(session.id, session.referAddress, session.referNumber);

    }

    

    function _finishMinting() internal {

        

        require(!isMintingFinished);

        isMintingFinished = true;

        emit MintFinished(session.id);

    }

    

    function _burnToken() internal {

        

        _burn(session.referAddress, session.referNumber);

        emit BurnToken(session.id, session.referAddress, session.referNumber);

    }

}



contract WorldClassSmartFarmToken is ERC20Detailed, ERC20Votable {

    constructor (string memory name, string memory symbol, uint8 decimals)

        public

        ERC20Detailed(name, symbol, decimals)

    {

        

    }

}