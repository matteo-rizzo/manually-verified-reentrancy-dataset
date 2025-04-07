/**
 *Submitted for verification at Etherscan.io on 2021-09-24
*/

pragma solidity ^0.5.9;
pragma experimental ABIEncoderV2;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


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
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */


//Beneficieries (validators) template
//import "../helpers/ValidatorsOperations.sol";
contract DPRBridge {

        IERC20 public token;
        using SafeERC20 for IERC20;
        using SafeMath for uint256;

        enum Status {PENDING,WITHDRAW, CANCELED, CONFIRMED, CONFIRMED_WITHDRAW}
        
        struct DepositInfo{
            uint256 last_deposit_time;
            uint256 deposit_amount;
        }

        struct WithdrawInfo{
            uint256 last_withdraw_time;
            uint256 withdraw_amount;
        }
        struct Message {
            bytes32 messageID;
            address spender;
            bytes32 substrateAddress;
            uint availableAmount;
            Status status;
        }

    

        event RelayMessage(bytes32 messageID, address sender, bytes32 recipient, uint amount);
        event RevertMessage(bytes32 messageID, address sender, uint amount);
        event WithdrawMessage(bytes32 MessageID, address recipient , bytes32 substrateSender, uint amount, bytes sig);
        event ConfirmWithdrawMessage(bytes32 messageID);
        

        bytes constant internal SIGN_HASH_PREFIX = "\x19Ethereum Signed Message:\n32";
        mapping(bytes32 => Message) public messages;
        mapping(address => DepositInfo) public user_deposit_info;
        mapping(address => WithdrawInfo) public user_withdraw_info;
        DepositInfo public contract_deposit_info;
        WithdrawInfo public contract_withdraw_info;
        address public submiter;
        address public owner;
        uint256 private user_daily_max_deposit_and_withdraw_amount = 20000 * 10 ** 18; //init value
        uint256 private daily_max_deposit_and_withdraw_amount = 500000 * 10 ** 18; //init value
        uint256 private user_min_deposit_and_withdraw_amount = 1000 * 10 ** 18; //init value
        uint256 private user_max_deposit_and_withdraw_amount = 20000 * 10 ** 18; //init value



       /**
       * @notice Constructor.
       * @param _token  Address of DPR token
       */

        constructor (IERC20 _token,address _submiter) public {

            token = _token;
            submiter = _submiter;
        }  

        /*
            check that message is valid
        */
        modifier validMessage(bytes32 messageID, address spender, bytes32 substrateAddress, uint availableAmount) {
            require((messages[messageID].spender == spender)
                && (messages[messageID].substrateAddress == substrateAddress)
                && (messages[messageID].availableAmount == availableAmount), "Data is not valid");
            _;
        }


        modifier pendingMessage(bytes32 messageID) {
            require(messages[messageID].status ==  Status.PENDING, "DPRBridge: Message is not pending");
            _;
        }

        modifier onlyOwner(){
            require(msg.sender == owner, "DPRBridge: Not Owner");
        _;
        }

        modifier withdrawMessage(bytes32 messageID) {
            require(messages[messageID].status ==  Status.WITHDRAW, "Message is not withdrawed");
            _;
        }

        modifier  updateUserDepositInfo(address user, uint256 amount) {
            require(amount >= user_min_deposit_and_withdraw_amount && amount <= user_max_deposit_and_withdraw_amount, "DPRBridge: Not in the range");
            DepositInfo storage di = user_deposit_info[user];
            uint256 last_deposit_time = di.last_deposit_time;
            if(last_deposit_time == 0){
                require(amount <= user_daily_max_deposit_and_withdraw_amount,"DPRBridge: Execeed the daily limit");
                di.last_deposit_time = block.timestamp;
                di.deposit_amount = amount;
            }else{
                uint256 pass_time = block.timestamp.sub(last_deposit_time);
                if(pass_time <= 1 days){
                    uint256 total_deposit_amount = di.deposit_amount.add(amount);
                    require(total_deposit_amount <= user_daily_max_deposit_and_withdraw_amount, "DPRBridge: Execeed the daily limit");
                    di.deposit_amount = total_deposit_amount;
                }else{
                    require(amount <= user_daily_max_deposit_and_withdraw_amount, "DPRBridge: Execeed the daily limit");
                    di.last_deposit_time = block.timestamp;
                    di.deposit_amount = amount;

                }
            }
            _;
        }

        modifier updateContractDepositInfo(uint256 amount){
            DepositInfo storage cdi = contract_deposit_info;
            uint256 last_deposit_time = cdi.last_deposit_time;
            if(last_deposit_time == 0){
                cdi.last_deposit_time = block.timestamp;
                cdi.deposit_amount += amount;
            }else{
                uint256 pass_time = block.timestamp.sub(last_deposit_time);
                if(pass_time <= 1 days){
                    uint256 total_deposit_amount = cdi.deposit_amount.add(amount);
                    require(total_deposit_amount <= daily_max_deposit_and_withdraw_amount, "DPRBridge: Execeed contract deposit limit");
                    cdi.deposit_amount = total_deposit_amount;
                }else{
                    cdi.deposit_amount = amount;
                    cdi.last_deposit_time = block.timestamp;
                }
                
            }
            _;
            
        }

        modifier updateContractWithdrawInfo(uint256 amount){
            WithdrawInfo storage cdi = contract_withdraw_info;
            uint256 last_withdraw_time = cdi.last_withdraw_time;
            if(last_withdraw_time == 0){
                cdi.last_withdraw_time = block.timestamp;
                cdi.withdraw_amount += amount;
            }else{
                uint256 pass_time = block.timestamp.sub(last_withdraw_time);
                if(pass_time <= 1 days){
                    uint256 total_withdraw_amount = cdi.withdraw_amount.add(amount);
                    require(total_withdraw_amount <= daily_max_deposit_and_withdraw_amount, "DPRBridge: Execeed contract deposit limit");
                    cdi.withdraw_amount = total_withdraw_amount;
                }else{
                    cdi.withdraw_amount = amount;
                    cdi.last_withdraw_time = block.timestamp;
                }
                
            }
            _;
            
        }

        modifier  updateUserWithdrawInfo(address user, uint256 amount) {
            require(amount >= user_min_deposit_and_withdraw_amount && amount <= user_max_deposit_and_withdraw_amount, "DPRBridge: Not in the range");
            WithdrawInfo storage ui = user_withdraw_info[user];
            uint256 last_withdraw_time = ui.last_withdraw_time;
            if(last_withdraw_time == 0){
                require(amount <= user_daily_max_deposit_and_withdraw_amount,"DPRBridge: Execeed the daily limit");
                ui.last_withdraw_time = block.timestamp;
                ui.withdraw_amount = amount;
            }else{
                uint256 pass_time = block.timestamp.sub(last_withdraw_time);
                if(pass_time <= 1 days){
                    uint256 total_withdraw_amount = ui.withdraw_amount.add(amount);
                    require(total_withdraw_amount <= user_daily_max_deposit_and_withdraw_amount, "DPRBridge: Execeed the daily limit");
                    ui.withdraw_amount = total_withdraw_amount;
                }else{
                    require(amount <= user_daily_max_deposit_and_withdraw_amount, "DPRBridge: Execeed the daily limit");
                    ui.last_withdraw_time = block.timestamp;
                    ui.withdraw_amount = amount;

                }
            }
            _;
        }

        function changeSubmiter(address _newSubmiter)   external onlyOwner{
            submiter = _newSubmiter;
        }
        function setUserDailyMax(uint256 max_amount) external onlyOwner returns(bool){
            user_daily_max_deposit_and_withdraw_amount = max_amount;
            return true;
        }

        function setDailyMax(uint256 max_amount) external onlyOwner returns(bool){
            daily_max_deposit_and_withdraw_amount = max_amount;
            return true;
        }

        function setUserMin(uint256 min_amount) external onlyOwner returns(bool){
            user_min_deposit_and_withdraw_amount = min_amount;
            return true;
        }

         function setUserMax(uint256 max_amount) external onlyOwner returns(bool){
            user_max_deposit_and_withdraw_amount = max_amount;
            return true;
         }

        function setTransfer(uint amount, bytes32 substrateAddress) public  
            updateUserDepositInfo(msg.sender, amount) 
            updateContractDepositInfo(amount){
            require(token.allowance(msg.sender, address(this)) >= amount, "contract is not allowed to this amount");
            
            token.transferFrom(msg.sender, address(this), amount);

            bytes32 messageID = keccak256(abi.encodePacked(now));

            Message  memory message = Message(messageID, msg.sender, substrateAddress, amount, Status.CONFIRMED);
            messages[messageID] = message;

            emit RelayMessage(messageID, msg.sender, substrateAddress, amount);
        }

        /*
        * Widthdraw finance by message ID when transfer pending
        */
        function revertTransfer(bytes32 messageID) public pendingMessage(messageID) {
            Message storage message = messages[messageID];
            require(message.spender == msg.sender, "DPRBridge: Not spender");
            message.status = Status.CANCELED;
            DepositInfo storage di = user_deposit_info[msg.sender];
            di.deposit_amount = di.deposit_amount.sub(message.availableAmount);
            DepositInfo storage cdi = contract_deposit_info;
            cdi.deposit_amount.sub(message.availableAmount);
            token.transfer(msg.sender, message.availableAmount);

            emit RevertMessage(messageID, msg.sender, message.availableAmount);
        }


        /*
        * Withdraw tranfer by message ID after approve from Substrate
        */
        function withdrawTransfer(bytes32  substrateSender, address recipient, uint availableAmount,bytes memory sig)  public
        updateContractWithdrawInfo(availableAmount)
         {  
            //require(msg.value == fee, "DPRBridge: Fee not match");
            require(token.balanceOf(address(this)) >= availableAmount, "DPRBridge: Balance is not enough");
            bytes32 messageID = keccak256(abi.encodePacked(substrateSender, recipient, availableAmount, block.timestamp));
            setMessageAndEmitEvent(messageID, substrateSender, recipient, availableAmount, sig);
        }

        function setMessageAndEmitEvent(bytes32 messageID, bytes32  substrateSender, address recipient, uint availableAmount, bytes memory sig) private {
             Message  memory message = Message(messageID, recipient, substrateSender, availableAmount, Status.WITHDRAW);
             messages[messageID] = message;
             emit WithdrawMessage(messageID,msg.sender , substrateSender, availableAmount, sig);
        }

        /*
        * Confirm Withdraw tranfer by message ID after approve from Substrate
        */
        function confirmWithdrawTransfer(bytes32 messageID, bytes memory signature) public withdrawMessage(messageID) 
        //onlyManyValidatorsConfirm(messageID, msg.sender) 
        {
            bytes32 data = keccak256(abi.encodePacked(messageID));
            bytes32 sign_data = keccak256(abi.encodePacked(SIGN_HASH_PREFIX, data));
            address recover_address = ECDSA.recover(sign_data, signature);
            require(recover_address == submiter, "DPRBridge: Address not match");
            Message storage message = messages[messageID];
            uint256 withdraw_amount = message.availableAmount;
            //setWithdrawData(message.spender, withdraw_amount);
            message.status = Status.CONFIRMED_WITHDRAW;
            token.safeTransfer(message.spender, withdraw_amount);
            emit ConfirmWithdrawMessage(messageID);
            
            
        }

        function withdrawAllTokens(IERC20 _token, uint256 amount) external onlyOwner{
            _token.safeTransfer(owner, amount);
        }
}