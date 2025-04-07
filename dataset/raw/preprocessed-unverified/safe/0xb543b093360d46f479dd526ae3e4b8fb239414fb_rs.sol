/**
 *Submitted for verification at Etherscan.io on 2021-03-14
*/

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */










/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
 string private _name;
 string private _symbol;
 uint8 private _decimals;

 /**
 * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
 * these values are immutable: they can only be set once during
 * construction.
 */
 constructor (string memory name, string memory symbol, uint8 decimals) public {
 _name = name;
 _symbol = symbol;
 _decimals = decimals;
 }

 /**
 * @dev Returns the name of the token.
 */
 function name() public view returns (string memory) {
 return _name;
 }

 /**
 * @dev Returns the symbol of the token, usually a shorter version of the
 * name.
 */
 function symbol() public view returns (string memory) {
 return _symbol;
 }

 /**
 * @dev Returns the number of decimals used to get its user representation.
 * For example, if `decimals` equals `2`, a balance of `505` tokens should
 * be displayed to a user as `5,05` (`505 / 10 ** 2`).
 *
 * Tokens usually opt for a value of 18, imitating the relationship between
 * Ether and Wei.
 *
 * NOTE: This information is only used for _display_ purposes: it in
 * no way affects any of the arithmetic of the contract, including
 * {IERC20-balanceOf} and {IERC20-transfer}.
 */
 function decimals() public view returns (uint8) {
 return _decimals;
 }
}





/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
 // Empty internal constructor, to prevent people from mistakenly deploying
 // an instance of this contract, which should be used via inheritance.
 constructor () internal { }
 // solhint-disable-previous-line no-empty-blocks

 function _msgSender() internal view returns (address payable) {
 return msg.sender;
 }

 function _msgData() internal view returns (bytes memory) {
 this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
 return msg.data;
 }
}




/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
 using SafeMath for uint256;

 mapping (address => uint256) private _balances;

 mapping (address => mapping (address => uint256)) private _allowances;

 uint256 private _totalSupply;

 /**
 * @dev See {IERC20-totalSupply}.
 */
 function totalSupply() public view returns (uint256) {
 return _totalSupply;
 }

 /**
 * @dev See {IERC20-balanceOf}.
 */
 function balanceOf(address account) public view returns (uint256) {
 return _balances[account];
 }

 /**
 * @dev See {IERC20-transfer}.
 *
 * Requirements:
 *
 * - `recipient` cannot be the zero address.
 * - the caller must have a balance of at least `amount`.
 */
 function transfer(address recipient, uint256 amount) public returns (bool) {
 _transfer(_msgSender(), recipient, amount);
 return true;
 }

 /**
 * @dev See {IERC20-allowance}.
 */
 function allowance(address owner, address spender) public view returns (uint256) {
 return _allowances[owner][spender];
 }

 /**
 * @dev See {IERC20-approve}.
 *
 * Requirements:
 *
 * - `spender` cannot be the zero address.
 */
 function approve(address spender, uint256 amount) public returns (bool) {
 _approve(_msgSender(), spender, amount);
 return true;
 }

 /**
 * @dev See {IERC20-transferFrom}.
 *
 * Emits an {Approval} event indicating the updated allowance. This is not
 * required by the EIP. See the note at the beginning of {ERC20};
 *
 * Requirements:
 * - `sender` and `recipient` cannot be the zero address.
 * - `sender` must have a balance of at least `amount`.
 * - the caller must have allowance for `sender`'s tokens of at least
 * `amount`.
 */
 function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
 _transfer(sender, recipient, amount);
 _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
 return true;
 }

 /**
 * @dev Atomically increases the allowance granted to `spender` by the caller.
 *
 * This is an alternative to {approve} that can be used as a mitigation for
 * problems described in {IERC20-approve}.
 *
 * Emits an {Approval} event indicating the updated allowance.
 *
 * Requirements:
 *
 * - `spender` cannot be the zero address.
 */
 function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
 _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
 return true;
 }

 /**
 * @dev Atomically decreases the allowance granted to `spender` by the caller.
 *
 * This is an alternative to {approve} that can be used as a mitigation for
 * problems described in {IERC20-approve}.
 *
 * Emits an {Approval} event indicating the updated allowance.
 *
 * Requirements:
 *
 * - `spender` cannot be the zero address.
 * - `spender` must have allowance for the caller of at least
 * `subtractedValue`.
 */
 function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
 _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
 return true;
 }

 /**
 * @dev Moves tokens `amount` from `sender` to `recipient`.
 *
 * This is internal function is equivalent to {transfer}, and can be used to
 * e.g. implement automatic token fees, slashing mechanisms, etc.
 *
 * Emits a {Transfer} event.
 *
 * Requirements:
 *
 * - `sender` cannot be the zero address.
 * - `recipient` cannot be the zero address.
 * - `sender` must have a balance of at least `amount`.
 */
 function _transfer(address sender, address recipient, uint256 amount) internal {
 require(sender != address(0), "ERC20: transfer from the zero address");
 require(recipient != address(0), "ERC20: transfer to the zero address");

 _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
 _balances[recipient] = _balances[recipient].add(amount);
 emit Transfer(sender, recipient, amount);
 }

 /** @dev Creates `amount` tokens and assigns them to `account`, increasing
 * the total supply.
 *
 * Emits a {Transfer} event with `from` set to the zero address.
 *
 * Requirements
 *
 * - `to` cannot be the zero address.
 */
 function _mint(address account, uint256 amount) internal {
 require(account != address(0), "ERC20: mint to the zero address");

 _totalSupply = _totalSupply.add(amount);
 _balances[account] = _balances[account].add(amount);
 emit Transfer(address(0), account, amount);
 }

 /**
 * @dev Destroys `amount` tokens from `account`, reducing the
 * total supply.
 *
 * Emits a {Transfer} event with `to` set to the zero address.
 *
 * Requirements
 *
 * - `account` cannot be the zero address.
 * - `account` must have at least `amount` tokens.
 */
 function _burn(address account, uint256 amount) internal {
 require(account != address(0), "ERC20: burn from the zero address");

 _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
 _totalSupply = _totalSupply.sub(amount);
 emit Transfer(account, address(0), amount);
 }

 /**
 * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
 *
 * This is internal function is equivalent to `approve`, and can be used to
 * e.g. set automatic allowances for certain subsystems, etc.
 *
 * Emits an {Approval} event.
 *
 * Requirements:
 *
 * - `owner` cannot be the zero address.
 * - `spender` cannot be the zero address.
 */
 function _approve(address owner, address spender, uint256 amount) internal {
 require(owner != address(0), "ERC20: approve from the zero address");
 require(spender != address(0), "ERC20: approve to the zero address");

 _allowances[owner][spender] = amount;
 emit Approval(owner, spender, amount);
 }

 /**
 * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
 * from the caller's allowance.
 *
 * See {_burn} and {_approve}.
 */
 function _burnFrom(address account, uint256 amount) internal {
 _burn(account, amount);
 _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
 }
}




/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
 address private _owner;

 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 /**
 * @dev Initializes the contract setting the deployer as the initial owner.
 */
 constructor () internal {
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
 require(isOwner(), "Ownable: caller is not the owner");
 _;
 }

 /**
 * @dev Returns true if the caller is the current owner.
 */
 function isOwner() public view returns (bool) {
 return _msgSender() == _owner;
 }

 /**
 * @dev Leaves the contract without owner. It will not be possible to call
 * `onlyOwner` functions anymore. Can only be called by the current owner.
 *
 * NOTE: Renouncing ownership will leave the contract without an owner,
 * thereby removing any functionality that is only available to the owner.
 */
 function renounceOwnership() public onlyOwner {
 emit OwnershipTransferred(_owner, address(0));
 _owner = address(0);
 }

 /**
 * @dev Transfers ownership of the contract to a new account (`newOwner`).
 * Can only be called by the current owner.
 */
 function transferOwnership(address newOwner) public onlyOwner {
 _transferOwnership(newOwner);
 }

 /**
 * @dev Transfers ownership of the contract to a new account (`newOwner`).
 */
 function _transferOwnership(address newOwner) internal {
 require(newOwner != address(0), "Ownable: new owner is the zero address");
 emit OwnershipTransferred(_owner, newOwner);
 _owner = newOwner;
 }
}


contract KiiAToken is ERC20, ERC20Detailed, Ownable {

 //Token percentages
 uint256 private tokenSaleRatio = 50;
 uint256 private foundersRatio = 10;
 uint256 private marketingRatio = 40;
 uint256 private foundersplit = 20; 

 //Constructor
 constructor(
 string memory _name, 
 string memory _symbol, 
 uint8 _decimals,
 address _founder1,
 address _founder2,
 address _founder3,
 address _founder4,
 address _founder5,
 address _marketing,
 address _publicsale,
 uint256 _initialSupply
 )
 ERC20Detailed(_name, _symbol, _decimals)
 public
 {
 uint256 tempInitialSupply = _initialSupply * (10 ** uint256(_decimals));

 uint256 publicSupply = tempInitialSupply.mul(tokenSaleRatio).div(100);
 uint256 marketingSupply = tempInitialSupply.mul(marketingRatio).div(100);
 uint256 tempfounderSupply = tempInitialSupply.mul(foundersRatio).div(100);
 uint256 founderSupply = tempfounderSupply.mul(foundersplit).div(100);

 _mint(_publicsale, publicSupply);
 _mint(_marketing, marketingSupply);
 _mint(_founder1, founderSupply);
 _mint(_founder2, founderSupply);
 _mint(_founder3, founderSupply);
 _mint(_founder4, founderSupply);
 _mint(_founder5, founderSupply);

 }

}


// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.00
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit | Range | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0 | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year | 1970 ... 2345 |
// month | 1 ... 12 |
// day | 1 ... 31 |
// hour | 0 ... 23 |
// minute | 0 ... 59 |
// second | 0 ... 59 |
// dayOfWeek | 1 ... 7 | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
//
// GNU Lesser General Public License 3.0
// https://www.gnu.org/licenses/lgpl-3.0.en.html
// ----------------------------------------------------------------------------




contract KiiADefi{

 string public name = "KiiA Token Farm";
 address public onlyOwner;
 KiiAToken public kiiaToken;
 using SafeMath for uint256;

 using BokkyPooBahsDateTimeLibrary for uint;
 
 function _diffDays(uint fromTimestamp, uint toTimestamp) public pure returns (uint _days) {
 _days = BokkyPooBahsDateTimeLibrary.diffDays(fromTimestamp, toTimestamp);
 }

 function _getTotalDays(uint _months) public view returns(uint){
 uint fromday = now;
 uint today = fromday.addMonths(_months);
 uint pendindays = _diffDays(fromday,today);
 return (pendindays);
 }

 //Deposit structure to hold all the variables
 struct Deposits {
 uint deposit_id;
 address investorAddress;
 uint planid;
 uint plantype;
 uint month;
 uint interest;
 uint256 invested;
 uint256 totalBonusToReceive;
 uint256 principalPmt;
 uint256 dailyEarnings;
 uint nthDay;
 uint daysToClose;
 bool isUnlocked;
 bool withdrawn;
 }
 
 //PlanDetails structure
 struct PlanDetails {
 uint planid;
 uint month;
 uint interest;
 uint plantype;
 bool isActive;
 }
 
 //Events to capture deposit event
 event addDepositEvent(
 uint depositId,
 address investorAddress
 );
 
 //Events to capture add plan
 event addPlanEvent(
 uint index,
 uint planid
 );
 
 //Events to capture update/edit plan
 event updateorEditPlanEvent(
 uint planid
 );
 
 event dummyEvent(
 address text1, 
 bytes32 text2
 );
 
 event dummyEventint(
 uint text1, 
 bool text2,
 uint text3
 );
 
 //Events to capture whitelist event
 event whiteListEvent(
 address owner,
 address investor
 );
 
 //Event to capture calculate bonus
 event calculateBonusEvent(
 uint depositid,
 address investorAddress
 );
 
 //Events to capture unlock event
 event addUnlockEvent(
 uint indexed _id,
 address _investorAddress,
 uint _planid
 ); 
 
 //Events to capture lock event
 event addlockEvent(
 uint indexed _id,
 address _investorAddress,
 uint _planid
 ); 
 
 //Events to capture Withdraw event 
 event addWithdrawEvent(
 uint indexed _id,
 address _investorAddress,
 uint _planid
 ); 
 
 uint public depositCounter;
 uint public planCounter;
 
 Deposits[] public allDeposits;
 PlanDetails[] public allPlanDetails;
 
 //to view deposit information
 mapping(address=>Deposits[]) public depositDetails;
 mapping(address=>mapping(uint=>Deposits[])) public viewDeposit;

 mapping(address => bool) public whitelistAddresses;
 address[] public whiteListed;
 address[] public stakers;
 mapping(address => bool) public hasStaked;
 
 //address -> plan -> staking or not
 mapping(address => mapping(uint => bool)) public isStaking;
 
 //plan active state
 mapping(uint =>bool) public isPlanActive;

 constructor(KiiAToken _kiiaToken, address _owneraddr) public payable {
 kiiaToken = _kiiaToken;
 onlyOwner = _owneraddr;
 }
 
 function addEth() public payable {
 //function to accept ether 
 }
 
 //Function to whitelist address
 function whiteListIt(address _beneficiary) public returns(uint) {
 // Only owner can call this function
 require(msg.sender == onlyOwner, "caller must be the owner");
 require(whitelistAddresses[_beneficiary]==false, "Already whitelisted");
 whitelistAddresses[_beneficiary] = true;
 whiteListed.push(_beneficiary);
 emit whiteListEvent(msg.sender,_beneficiary);
 return 0;
 }
 
 //Function to whitelist address in bulk fashion
 function bulkwhiteListIt(address[] memory _beneficiary) public returns(uint) {
 // Only owner can call this function
 require(msg.sender == onlyOwner, "caller must be the owner");
 uint tot = _beneficiary.length;
 if(tot<=255){
 for(uint i=0;i<tot; i++){
 if(!whitelistAddresses[_beneficiary[i]]){
 whitelistAddresses[_beneficiary[i]] = true;
 whiteListed.push(_beneficiary[i]);
 emit whiteListEvent(msg.sender,_beneficiary[i]);
 }
 }
 return 0; 
 }
 }
 
 //Function to bulk remove from bulkremoveFromwhiteListIt
 function bulkremoveFromwhiteListIt(address[] memory _beneficiary) public returns(uint) {
 // Only owner can call this function
 require(msg.sender == onlyOwner, "caller must be the owner");
 uint tot = _beneficiary.length;
 if(tot<=255){
 for(uint i=0;i<tot; i++){
 if(!whitelistAddresses[_beneficiary[i]]){
 whitelistAddresses[_beneficiary[i]] = false;
 whiteListed.push(_beneficiary[i]);
 emit whiteListEvent(msg.sender,_beneficiary[i]);
 }
 }
 return 0; 
 }
 }
 
 //remove from whiteList
 function removefromWhiteList(address _beneficiary) public returns(uint) {
 // Only owner can call this function
 require(msg.sender == onlyOwner, "caller must be the owner");
 require(whitelistAddresses[_beneficiary]==true, "Already in graylist");
 whitelistAddresses[_beneficiary] = false;
 emit whiteListEvent(msg.sender,_beneficiary);
 return 0;
 }
 
 //Getter Function for getplan by id
 function getPlanById(uint _planid) public view returns(uint plan_id,uint month,uint interest,uint plantype,bool isActive){
 uint tot = allPlanDetails.length;
 for(uint i=0;i<tot;i++){
 if(allPlanDetails[i].planid==_planid){
 return(allPlanDetails[i].planid,allPlanDetails[i].month,allPlanDetails[i].interest,allPlanDetails[i].plantype,allPlanDetails[i].isActive);
 }
 }
 }
 
 //Getter Function for getplan by id
 function getPlanDetails(uint _planid) internal view returns(uint month,uint interest,uint plantype){
 uint tot = allPlanDetails.length;
 for(uint i=0;i<tot;i++){
 if(allPlanDetails[i].planid==_planid){
 return(allPlanDetails[i].month,allPlanDetails[i].interest,allPlanDetails[i].plantype);
 }
 }

 }
 
 //this function is to avoid stack too deep error
 function _deposits(uint _month, uint _amount, uint256 _interest) internal view returns (uint _nthdayv2,uint _pendingDaysv2,uint256 _totalBonusToReceivev2,uint256 _dailyEarningsv2,uint _principalPmtDailyv2) {
 uint256 _pendingDaysv1 = _getTotalDays(_month);
 uint256 _interesttoDivide = _interest.mul(1000000).div(100) ;
 uint256 _totalBonusToReceivev1 = _amount.mul(_interesttoDivide).div(1000000);
 uint _nthdayv1 = 0;
 uint _principalPmtDaily = 0;
 uint _dailyEarningsv1 = 0;
 return (_nthdayv1,_pendingDaysv1,_totalBonusToReceivev1,_dailyEarningsv1,_principalPmtDaily);
 } 
 
 function depositTokens(uint _plan,uint256 _plandate, uint _amount) public{
 // check if user is whitelisted
 require(whitelistAddresses[msg.sender]==true,"Only whitelisted user is allowed to deposit tokens");
 require(_amount > 0, "amount cannot be 0");
 require(isPlanActive[_plan]==true,"Plan is not active"); // To check if plan is active 
 
 (uint _month,uint _interest,uint _plantype) = getPlanDetails(_plan);
 
 require(_interest > 0, "interest rate cannot be 0");
 require(_month > 0,"_months cannot be 0");
 
 // Trasnfer kiiA tokens to this contract for staking
 kiiaToken.transferFrom(msg.sender, address(this), _amount);
 
 //scope to remove the error Stack too deep
 (uint _nthday,uint _daystoclose,uint _totalBonusToReceive,uint _dailyEarnings,uint _principalPmtDaily) = _deposits(_month,_amount,_interest);
 
 uint _localid = allDeposits.length++;
 //deposit token in defi
 allDeposits[allDeposits.length-1] = Deposits(_plandate, 
 msg.sender,
 _plan,
 _plantype,
 _month,
 _interest,
 _amount,
 _totalBonusToReceive,
 _principalPmtDaily,
 _dailyEarnings,
 _nthday,
 _daystoclose,
 false,
 false
 );
 
 //Add Deposit details
 depositDetails[msg.sender].push(allDeposits[allDeposits.length-1]);
 
 //is Staking in this plan 
 isStaking[msg.sender][_plandate] = true;

 // Add user to stakers array *only* if they haven't staked already
 if(!hasStaked[msg.sender]) {
 stakers.push(msg.sender);
 } 
 hasStaked[msg.sender] = true;
 
 emit addDepositEvent(_localid, msg.sender);
 
 }
 
 //Setter function for plan
 function registerPlan(uint _planid, uint _month,uint _interest,uint _plantype) public returns(uint){
 require(msg.sender == onlyOwner, "caller must be the owner");
 require(_planid > 0, "Plan Id cannot be 0");
 require(_month > 0, "Month cannot be 0");
 require(_interest > 0, "Interest cannot be 0");
 require(_plantype >= 0, "Plantype can be either 0 or 1");
 require(_plantype <= 1, "Plantype can be either 0 or 1");
 require(isPlanActive[_planid]==false,"Plan already exists in active status"); 

 planCounter = planCounter + 1;
 uint _localid = allPlanDetails.length++;
 allPlanDetails[allPlanDetails.length-1] = PlanDetails(_planid,
 _month,
 _interest,
 _plantype,
 true
 ); 
 isPlanActive[_planid] = true;
 emit addPlanEvent(_localid,_planid);
 return 0;
 }
 
 //Setter function for plan
 function updatePlan(uint _planid, uint _month,uint _interest,uint _plantype) public returns(uint){
 require(msg.sender == onlyOwner, "caller must be the owner");
 require(_planid > 0, "Plan Id cannot be 0");
 require(_month > 0, "Month cannot be 0");
 require(_interest > 0, "Interest cannot be 0");

 uint tot = allPlanDetails.length;
 for(uint i=0;i<tot;i++){
 if(allPlanDetails[i].planid==_planid){
 allPlanDetails[i].month = _month;
 allPlanDetails[i].interest = _interest;
 allPlanDetails[i].plantype = _plantype;
 }
 }
 emit updateorEditPlanEvent(_planid);
 return 0;
 }
 
 //Deactivate plan
 function deactivatePlan(uint _planid) public returns(uint){
 require(msg.sender == onlyOwner, "caller must be the owner");
 require(isPlanActive[_planid]==true, "Plan already deactivated");
 isPlanActive[_planid]= false;
 emit updateorEditPlanEvent(_planid);
 return 0;
 }
 
 //Reactivate plan
 function reactivatePlan(uint _planid) public returns(uint){
 require(msg.sender == onlyOwner, "caller must be the owner");
 require(isPlanActive[_planid]==false, "Plan already activated");
 isPlanActive[_planid]= true;
 emit updateorEditPlanEvent(_planid);
 return 0;
 }
 
 //To calculate bonus - this function should be called once per day by owner
 function calcBonus() public returns(uint){
 require(msg.sender == onlyOwner, "caller must be the owner");
 uint totDep = allDeposits.length;
 for(uint i=0; i<totDep;i++){
 uint _plantype = allDeposits[i].plantype;
 uint _nthDay = allDeposits[i].nthDay;
 uint _invested = allDeposits[i].invested;
 uint _daysToClose= allDeposits[i].daysToClose;
 uint _principalPmt = _invested.div(_daysToClose);

 //check if already withdrawn, if yes, then dont calculate
 bool _withdrawn = allDeposits[i].withdrawn;
 emit dummyEventint(_plantype,_withdrawn,0);
 if(_plantype==0){
 if(_nthDay<_daysToClose){
 allDeposits[i].nthDay = _nthDay.add(1);
 allDeposits[i].principalPmt = allDeposits[i].principalPmt + _principalPmt;
 //emit event
 emit calculateBonusEvent(allDeposits[i].deposit_id,allDeposits[i].investorAddress);
 } 
 }
 if(_plantype==1){
 if(_nthDay<_daysToClose){
 allDeposits[i].nthDay = _nthDay.add(1);
 allDeposits[i].principalPmt = allDeposits[i].principalPmt + _principalPmt;
 //emit event
 emit calculateBonusEvent(allDeposits[i].deposit_id,allDeposits[i].investorAddress);
 }
 }
 }

 }
 
 //Get deposit by address
 uint[] depNewArray;
 function getDepositidByAddress(address _beneficiary) public returns(uint[] memory){
 uint tot = allDeposits.length;
 uint[] memory tmparray;
 depNewArray = tmparray;
 for(uint i =0; i< tot; i++){
 if(allDeposits[i].investorAddress==_beneficiary){
 depNewArray.push(allDeposits[i].deposit_id);
 }
 }
 return depNewArray;
 }
 
 
 function getDepositByAddress(address _beneficiary,uint _deposit_id) public view returns(uint256,uint,uint,uint,uint,uint256,uint256,uint,uint,uint,bool){
 uint tot = allDeposits.length;
 for(uint i=0;i<tot;i++){
 if(_beneficiary==allDeposits[i].investorAddress){
 if(allDeposits[i].deposit_id==_deposit_id){
 return(allDeposits[i].invested,
 allDeposits[i].planid,
 allDeposits[i].plantype,
 allDeposits[i].month,
 allDeposits[i].interest,
 allDeposits[i].totalBonusToReceive,
 allDeposits[i].dailyEarnings,
 allDeposits[i].principalPmt,
 allDeposits[i].daysToClose,
 allDeposits[i].nthDay,
 allDeposits[i].isUnlocked
 );
 }
 }
 }
 }
 
 // Unlock address
 function setLock(address _beneficiary,uint _deposit_id) public returns(uint) {
 // Only owner can call this function
 require(msg.sender == onlyOwner, "caller must be the owner");
 // set lock
 uint totDep = allDeposits.length;
 for(uint i=0;i<totDep; i++){
 if(allDeposits[i].investorAddress==_beneficiary){
 if (allDeposits[i].deposit_id==_deposit_id){
 allDeposits[i].isUnlocked = false;
 emit addlockEvent(allDeposits[i].deposit_id,allDeposits[i].investorAddress,allDeposits[i].planid);
 }
 }
 }
 return 0;
 }
 
 // Unlock address
 function unlock(address _beneficiary,uint _deposit_id) public returns(uint) {
 // Only owner can call this function
 require(msg.sender == onlyOwner, "caller must be the owner");
 // Unlock
 uint totDep = allDeposits.length;
 for(uint i=0;i<totDep; i++){
 if(allDeposits[i].investorAddress==_beneficiary){
 if (allDeposits[i].deposit_id==_deposit_id){
 allDeposits[i].isUnlocked = true;
 emit addUnlockEvent(allDeposits[i].deposit_id,allDeposits[i].investorAddress,allDeposits[i].planid);
 }
 }
 }
 return 0;
 }

 // Bulk Unlock address
 function bulkunlock(address[] memory _beneficiary, uint256[] memory _deposit_id) public returns(uint) {
 // Only owner can call this function
 require(msg.sender == onlyOwner, "caller must be the owner");
 require(_beneficiary.length == _deposit_id.length,"Array length must be equal");
 // Unlock
 uint totDep = allDeposits.length;
 for (uint j = 0; j < _beneficiary.length; j++) {
 for(uint i=0;i<totDep; i++){
 if(allDeposits[i].investorAddress==_beneficiary[j]){
 if (allDeposits[i].deposit_id==_deposit_id[j]){
 allDeposits[i].isUnlocked = true;
 }
 }
 }
 }
 return 0;
 }

 // Bring staker list Getter function
 function stakerlist() public view returns(address[] memory){
 return stakers;
 }
 
 // Bring whitelisted addresss list 
 address[] whiteArray;
 function whiteListedAddress() public returns(address[] memory){
 uint tot = whiteListed.length;
 address[] memory tmparray;
 whiteArray = tmparray;
 for(uint i=0;i<tot; i++){
 whiteArray.push(whiteListed[i]);
 emit dummyEvent(whiteListed[i],"testing");
 }
 return whiteArray;
 }
 
 // Bring bloacklisted addresss list 
 address[] blackArray;
 function blackListedAddress() public returns(address[] memory){
 uint tot = whiteListed.length;
 address[] memory tmparray;
 blackArray = tmparray;
 for(uint i=0;i<tot; i++){
 if(whitelistAddresses[whiteListed[i]]==false){
 blackArray.push(whiteListed[i]);
 }
 }
 return blackArray;
 }
 
 // Unstaking Tokens (Withdraw)
 function withDrawTokens(uint _deposit_id, uint _plantype) public returns(uint) {
 uint totDep = allDeposits.length;
 for(uint i=0;i<totDep; i++){
 if(allDeposits[i].investorAddress==msg.sender){
 if (allDeposits[i].deposit_id==_deposit_id){
 require(allDeposits[i].invested > 0, "Staking balance cannot be 0");
 require(allDeposits[i].withdrawn==false, "Plan is already withdrawn by user");
 require(allDeposits[i].isUnlocked==true, "User account must be unlocked by owner to withdraw");
 require(isStaking[msg.sender][_deposit_id]==true,"User is not staking any amount in this plan");
 uint balance = allDeposits[i].invested;
 
 //Regular Plan withdrawal
 if(_plantype==0){
 uint _principalPmt = allDeposits[i].principalPmt;
 uint _toTransfer1 = balance.sub(_principalPmt);
 // Transfer back KiiA tokens to this address
 kiiaToken.transfer(msg.sender, _toTransfer1);
 allDeposits[i].principalPmt = _principalPmt.add(_toTransfer1);
 allDeposits[i].totalBonusToReceive = 0;
 allDeposits[i].withdrawn = true;
 isStaking[msg.sender][_deposit_id]=false;
 emit addWithdrawEvent(allDeposits[i].deposit_id,allDeposits[i].investorAddress,allDeposits[i].planid);
 return 0;
 }
 
 //Fixed Plan withdrawal
 if(_plantype==1){
 uint nthDay = allDeposits[i].nthDay;
 uint dailyEarnings = allDeposits[i].dailyEarnings;
 uint256 _interestAccumulated = nthDay.mul(dailyEarnings);
 uint256 _toTransfer2 = balance.add(_interestAccumulated);
 // Transfer back KiiA tokens to this address
 kiiaToken.transfer(msg.sender, _toTransfer2);
 allDeposits[i].totalBonusToReceive = 0;
 allDeposits[i].withdrawn = true;
 isStaking[msg.sender][_deposit_id]=false;
 emit addWithdrawEvent(allDeposits[i].deposit_id,allDeposits[i].investorAddress,allDeposits[i].planid);
 return 0;
 }
 }
 }
 }
 }
}