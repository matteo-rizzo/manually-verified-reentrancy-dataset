/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

pragma solidity ^0.5.11;


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





/// @title Kyber Network interface



/// @title Compound Finance interface



/// @title Ownable Contract






/// @title Memento Fund Contract
contract Mementofund is Ownable {
    using SafeMath for uint256;
    
    
    
    //variables
    uint minRate;
    // uint256 public totalFundsInDAI;
    uint256 public developerFeeRate;
    uint public managerTransactionFee;
    uint public managerFundFee;
    uint accountIndexMax;
    uint userTokenCount;

    //Events
    event managerAddressUpdated(address newaddress);
    event kybertrade(address _src, uint256 _amount, address _dest, uint256 _destqty);
    event deposit(ERC20 _src, uint256 _amount);

    // addresses
    address public DAI_ADDR;
    address payable public CDAI_ADDR;
    address payable public KYBER_ADDR;
    address payable public ADMIN_ADDR;
    address payable public COMPOUND_ADDR;

    // Interfaces
    ERC20 internal dai;
    KyberNetworkProxyInterface internal kyber;
    CERC20 internal CDai;
    bytes public constant PERM_HINT = "PERM";

    // Constants
    ERC20 internal constant ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    uint constant internal PRECISION = (10**18);
    uint constant internal MAX_QTY   = (10**28); // 10B tokens
    uint constant internal ETH_DECIMALS = 18;
    uint constant internal MAX_DECIMALS = 18;

    //Structs

    struct Account{
        address payable benefactorAddress;
        string benefactorName;
        address payable managerAddress;
        address[] signatories;
        uint creationDate;
        uint unlockDate;
        uint preUnlockMonthlyquota;

    }


    struct Investment{
        uint256 timestamp;
        address depositedBy;
        address srcTokenAddress;
        uint256 srcAmount;
        address destTokenAddress;
        uint256 destAmount;
    }

    struct Memory{
        uint256 timestamp;
        address depositedBy;
        bytes ipfshash;
        string memoryText;
        string filetype;
    }

    //Mappings
    //Account Tracking
    mapping(address => mapping(uint => address)) public usertokenMapping;
    mapping(address => uint) public userTokens;

    mapping(address => mapping(address => uint256)) public userBalance;
    mapping(address => Account) public accounts;
    mapping(address => Investment[]) public userInvestments;
    // mapping(address => address) uniswapExchange;

    constructor(
        address payable _adminAddr,
        address _daiAddr,
        address payable _kyberAddr,
        address payable _cdaiAddr

      ) public {

        KYBER_ADDR = _kyberAddr;
        ADMIN_ADDR = _adminAddr;
        CDAI_ADDR = _cdaiAddr;
        DAI_ADDR = _daiAddr;
        dai = ERC20(DAI_ADDR);
        CDai = CERC20(CDAI_ADDR);
        kyber = KyberNetworkProxyInterface(_kyberAddr);
        // compound = Compound(_compoundAddr);
        
        
        bool daiApprovalResult = dai.approve(DAI_ADDR, 2**256-1);
        require(daiApprovalResult, "Failed to approve cDAI contract to spend DAI");
      }

    // Internal Utilities
    modifier onlyFundAdmin() {
        require(isFundAdmin(), "Only Fund Manger is Authorised to execute that function.");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isFundAdmin() public view returns (bool) {
        return msg.sender == ADMIN_ADDR;
    }


    function isRegisteredBenefactor(address _account) public view returns (bool) {

        if (accounts[_account].benefactorAddress != address(0x00)){
        return  true;
        }
    }

    function isAccountManager(address _account) public view returns (bool) {

        if (accounts[_account].managerAddress == msg.sender){
        return  true;
        }
    }
    
    
    
    function handleIndexes(address _account, address _token) internal {
        if (userBalance[_account][_token] == 0x00) {
                usertokenMapping[_account][userTokens[_account]] = _token;
                userTokens[_account] += 1;
            }
    }



    //Account Management Functions
    function registerAccount(address payable _benefactorAddress, string memory _benefactorName,
                             address payable _managerAddress, address[] memory _signatories, uint _unlockDate,
                             uint _preUnlockMonthlyquota) public returns(bool) {

        if (accounts[_benefactorAddress].benefactorAddress == address(0x00)){

            Account storage account = accounts[_benefactorAddress];
            account.benefactorAddress = _benefactorAddress;
            account.benefactorName = _benefactorName;
            account.managerAddress = _managerAddress;
            account.signatories = _signatories;
            account.creationDate = now;
            account.unlockDate = _unlockDate;
            account.preUnlockMonthlyquota = _preUnlockMonthlyquota;



        }


        }



    // Kyber Trading Function
    function _kybertrade(ERC20 _srcToken, uint256 _srcAmount, ERC20 _destToken)
    internal
    returns(
      uint256 _actualDestAmount
    )
  {
    require(_srcToken != _destToken, "Source matches Destination.");
    uint256 msgValue;
    uint256 rate;

    if (_srcToken != ETH_TOKEN_ADDRESS) {
      msgValue = 0;
      _srcToken.approve(KYBER_ADDR, 0);
      _srcToken.approve(KYBER_ADDR, _srcAmount);
    } else {
      msgValue = _srcAmount;
    }
    (,rate) = kyber.getExpectedRate(_srcToken, _destToken, _srcAmount);
    _actualDestAmount = kyber.tradeWithHint.value(msgValue)(
      _srcToken,
      _srcAmount,
      _destToken,
      address(uint160(address(this))),
      MAX_QTY,
      rate,
      address(0),
      PERM_HINT
    );
    require(_actualDestAmount > 0, "Destination value must be greater than 0");
    if (_srcToken != ETH_TOKEN_ADDRESS) {
      _srcToken.approve(KYBER_ADDR, 0);
        }
    }

    function investEthToDai(address _account) public payable returns (bool) {
        require(isRegisteredBenefactor(_account),"Specified account must be registered.");

        handleIndexes(_account, address(DAI_ADDR));

        uint256 destqty = _kybertrade(ETH_TOKEN_ADDRESS, msg.value, dai);

        userBalance[_account][address(DAI_ADDR)] = userBalance[_account][address(DAI_ADDR)].add(destqty);
        userInvestments[_account].push(Investment({
                                                timestamp: now,
                                                depositedBy: msg.sender,
                                                srcTokenAddress: address(ETH_TOKEN_ADDRESS),
                                                srcAmount: msg.value,
                                                destTokenAddress: address(DAI_ADDR),
                                                destAmount: destqty
                                                }));
        emit kybertrade(address(ETH_TOKEN_ADDRESS), msg.value, DAI_ADDR, destqty);

        return true;
    }

    function investEthToToken(address _account, ERC20 _token) external payable returns (bool) {
        require(isRegisteredBenefactor(_account),"Sepcified account must be registered");
        handleIndexes(_account, address(_token));

        uint256 destqty = _kybertrade(ETH_TOKEN_ADDRESS, msg.value, _token);
        userBalance[_account][address(_token)] = userBalance[_account][address(_token)].add(destqty);
        userInvestments[_account].push(Investment({
                                                timestamp: now,
                                                depositedBy: msg.sender,
                                                srcTokenAddress: address(ETH_TOKEN_ADDRESS),
                                                srcAmount: msg.value,
                                                destTokenAddress: address(_token),
                                                destAmount: destqty
                                                }));
        emit kybertrade(address(ETH_TOKEN_ADDRESS), msg.value, address(_token), destqty);
        return true;
    }

    function investToken(address _account, ERC20 _token, uint256 _amount) external  returns (bool) {
        require(isRegisteredBenefactor(_account),"Specified account must be registered");

        require(_token.balanceOf(msg.sender) >= _amount, "Sender balance Too Low.");
        require(_token.approve(address(this), _amount), "Fund not approved to transfer senders Token Balance");
        require(_token.transfer(address(this), _amount), "Sender hasn'tr transferred tokens.");

        handleIndexes(_account, address(_token));

        userBalance[_account][address(_token)] = userBalance[_account][address(_token)].add(_amount);
        userInvestments[_account].push(Investment({
                                                timestamp: now,
                                                depositedBy: msg.sender,
                                                srcTokenAddress: address(_token),
                                                srcAmount: _amount,
                                                destTokenAddress: address(_token),
                                                destAmount: _amount
                                                }));
        return true;
    }

    function investTokenToToken(address _account, ERC20 _token, uint256 _amount, ERC20 _dest) external  returns (bool) {
        require(isRegisteredBenefactor(_account), "Specified account must be registered");
        require(_token.balanceOf(msg.sender) >= _amount, "Account token balance must be greater that spscified amount");
        require(_token.approve(address(this), _amount), "Contract must be approved to transfer Specified token");
        require(_token.transfer(address(this), _amount), "Specified Token must be tranferred from caller to contract");

        handleIndexes(_account, address(_token));

        uint destqty = _kybertrade(_token, _amount, _dest);
        userBalance[_account][address(_token)] = userBalance[_account][address(_token)].add(destqty);
        userInvestments[_account].push(Investment({
                                                timestamp: now,
                                                depositedBy: msg.sender,
                                                srcTokenAddress: address(_token),
                                                srcAmount: _amount,
                                                destTokenAddress: address(_dest),
                                                destAmount: destqty
                                                }));
        emit deposit(_dest, destqty);
        return true;
    }

    function splitInvestEthToToken(address _account, address[] memory _tokens, uint[] memory _ratios) public payable {
        require(isRegisteredBenefactor(_account),"Specified account must be registered");
        require(msg.value > 0, "Transaction must have ether value");
        require(_tokens.length == _ratios.length, "unmatched array lengths");

        handleIndexes(_account, address(ETH_TOKEN_ADDRESS));

        uint256 msgValue = msg.value;

            require(_tokens.length > 0, "Array must be greater than 0.");
            uint quotaTotal;
            for (uint i = 0;i < _tokens.length; i++) {
                quotaTotal = quotaTotal.add(quotaTotal);
            }

            require(quotaTotal < 100, "Split Total Greater than 100.");

            for (uint i = 0; i < _tokens.length; i++) {
                handleIndexes(_account, address(_tokens[i]));
                uint256 quota = (msg.value * _ratios[i]) / 100;
                require(quota < msg.value, "Quota Split greater than Message Value");
                uint destqty = _kybertrade(ETH_TOKEN_ADDRESS, quota, ERC20(_tokens[i]));
                userBalance[_account][address(_tokens[i])] = userBalance[_account][address(_tokens[i])].add(destqty);
                userInvestments[_account].push(Investment({
                                                timestamp: now,
                                                depositedBy: msg.sender,
                                                srcTokenAddress: address(ETH_TOKEN_ADDRESS),
                                                srcAmount: quota,
                                                destTokenAddress: address(_tokens[i]),
                                                destAmount: destqty
                                                }));
                msgValue = msgValue.sub(quota);
                emit kybertrade(address(ETH_TOKEN_ADDRESS),quota, address(_tokens[i]), destqty);
            }
        userBalance[_account][address(ETH_TOKEN_ADDRESS)] = userBalance[_account][address(ETH_TOKEN_ADDRESS)].add(msgValue);
        userInvestments[_account].push(Investment({
                                        timestamp: now,
                                        depositedBy: msg.sender,
                                        srcTokenAddress: address(ETH_TOKEN_ADDRESS),
                                        srcAmount: msgValue,
                                        destTokenAddress: address(ETH_TOKEN_ADDRESS),
                                        destAmount: msgValue
                                        }));
    }

    function swapTokenToEther (address _account, ERC20 _src, uint _amount) public {
        require(isAccountManager(_account),"Caller must be registered as an Account Manager");
        uint destqty = _kybertrade(_src, _amount, ETH_TOKEN_ADDRESS);
        userBalance[_account][address(_src)] = userBalance[_account][address(_src)].sub(_amount);
        userBalance[_account][address(ETH_TOKEN_ADDRESS)] = userBalance[_account][address(ETH_TOKEN_ADDRESS)].add(destqty);

        emit kybertrade(address(_src), _amount, address(ETH_TOKEN_ADDRESS), destqty);

    }

    function swapEtherToToken (address _account, ERC20 _dest, uint _amount) public {
        require(isAccountManager(_account),"Caller must be registered as an Account Manager");
        uint destqty = _kybertrade(ETH_TOKEN_ADDRESS, _amount, _dest);
        userBalance[_account][address(_dest)] = userBalance[_account][address(_dest)].add(destqty);
        userBalance[_account][address(ETH_TOKEN_ADDRESS)] = userBalance[_account][address(ETH_TOKEN_ADDRESS)].sub(_amount);

        emit kybertrade(address(ETH_TOKEN_ADDRESS), _amount, address(_dest), destqty);

    }


    function swapTokenToToken(address _account, ERC20 _src, uint256 _amount, ERC20 _dest) public {
        require(isAccountManager(_account),"Caller must be registered as an Account Manager");
        uint destqty = _kybertrade(_src, _amount, _dest);
        userBalance[_account][address(_src)] = userBalance[_account][address(_src)].sub(_amount);
        userBalance[_account][address(_dest)] = userBalance[_account][address(_dest)].add(destqty);
        emit kybertrade(address(_src), _amount, address(_dest), destqty);

    }



    //Fund Admin Functions
    function updateAdminAddress(address payable _newaddress) external onlyFundAdmin returns (bool) {
        require(_newaddress != address(0),"New admin address must not be blank");
        require(_newaddress != ADMIN_ADDR, "New admin addres must not be current admin address");

        ADMIN_ADDR = _newaddress;
        emit managerAddressUpdated(_newaddress);

    }

    function updateDaiAddress(address payable _newaddress) external onlyFundAdmin returns (bool) {
        require(_newaddress != address(0),"New admin address must not be blank");
        require(_newaddress != DAI_ADDR, "New DAI Contract adress must not be current DAI Contract Address");

        DAI_ADDR = _newaddress;

    }

    function updateKyberAddress(address payable _newaddress) external onlyFundAdmin returns (bool) {
        require(_newaddress != address(0),"New admin address must not be blank");
        require(_newaddress != KYBER_ADDR, "New KYBER Contract address must be different from old Contract Address");

        KYBER_ADDR = _newaddress;

    }


    // function lend(address _account, )

    function getBalance(address _account, ERC20 _token) public view returns(uint256) {
        return userBalance[_account][address(_token)];
    }


    function withdraw(address payable _account, ERC20 _token, uint256 _amount) public {
        require(isRegisteredBenefactor(address(_account)));
        require(now > accounts[_account].unlockDate);
        require(userBalance[msg.sender][address(_token)] >= _amount);
        if (_token == ETH_TOKEN_ADDRESS) {
                userBalance[msg.sender][address(_token)] = userBalance[msg.sender][address(_token)].sub(_amount);
                msg.sender.transfer(_amount);
        } else {
                userBalance[msg.sender][address(_token)] = userBalance[msg.sender][address(_token)].sub(_amount);
                _token.transfer(msg.sender, _amount);
        }

    }

    function closeaccount(address payable _account) public {
        require(isRegisteredBenefactor(_account));
        require(block.timestamp > accounts[_account].unlockDate);
        require(userTokens[_account] > 0, "User Tokens must be greater than 0");



        for (uint i = 0; i < userTokens[msg.sender]; i++) {
            address token = usertokenMapping[msg.sender][i];
            uint256 balance = userBalance[msg.sender][token];
            withdraw(_account, ERC20(token), balance);
        }


    }

    //Management functions


    //fallback - send eth to manager so he can refund sender
    function () external payable {
        userBalance[ADMIN_ADDR][address(ETH_TOKEN_ADDRESS)] = userBalance[ADMIN_ADDR][address(ETH_TOKEN_ADDRESS)].add(msg.value);



    }
}