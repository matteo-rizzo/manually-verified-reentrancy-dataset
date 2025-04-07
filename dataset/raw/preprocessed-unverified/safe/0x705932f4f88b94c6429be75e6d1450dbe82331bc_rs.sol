pragma solidity 0.4.21;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract CryptoRoboticsToken {

    uint256 public totalSupply;

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function burn(uint256 value) public;

}





contract RefundVault is Ownable {

    using SafeMath for uint256;



    enum State { Active, Refunding, Closed }



    mapping (address => uint256) public deposited;

    address public wallet;

    State public state;



    event Closed();

    event RefundsEnabled();

    event Refunded(address indexed beneficiary, uint256 weiAmount);



    /**

     * @param _wallet Vault address

     */

    function RefundVault(address _wallet) public {

        require(_wallet != address(0));

        wallet = _wallet;

        state = State.Active;

    }



    /**

     * @param investor Investor address

     */

    function deposit(address investor) onlyOwner public payable {

        require(state == State.Active);

        deposited[investor] = deposited[investor].add(msg.value);

    }



    function close() onlyOwner public {

        require(state == State.Active);

        state = State.Closed;

        emit Closed();

        wallet.transfer(address(this).balance);

    }



    function enableRefunds() onlyOwner public {

        require(state == State.Active);

        state = State.Refunding;

        emit RefundsEnabled();

    }



    /**

     * @param investor Investor address

     */

    function refund(address investor) public {

        require(state == State.Refunding);

        uint256 depositedValue = deposited[investor];

        deposited[investor] = 0;

        investor.transfer(depositedValue);

        emit Refunded(investor, depositedValue);

    }

}





contract Crowdsale is Ownable {

    using SafeMath for uint256;



    // The token being sold

    CryptoRoboticsToken public token;

    //MAKE APPROVAL TO Crowdsale

    address public reserve_fund = 0x7C88C296B9042946f821F5456bd00EA92a13B3BB;

    address preico;



    // Address where funds are collected

    address public wallet;



    // Amount of wei raised

    uint256 public weiRaised;



    uint256 public openingTime;

    uint256 public closingTime;



    bool public isFinalized = false;



    uint public currentStage = 0;



    uint256 public goal = 1000 ether;

    uint256 public cap  = 6840  ether;



    RefundVault public vault;







    //price in wei for stage

    uint[4] public stagePrices = [

    127500000000000 wei,     //0.000085 - ICO Stage 1

    135 szabo,     //0.000090 - ICO Stage 2

    142500000000000 wei,     //0.000095 - ICO Stage 3

    150 szabo     //0.0001 - ICO Stage 4

    ];



    //limit in wei for stage 612 + 1296 + 2052 + 2880

    uint[4] internal stageLimits = [

    612 ether,    //4800000 tokens 10% of ICO tokens (ICO token 40% of all (48 000 000) )

    1296 ether,    //9600000 tokens 20% of ICO tokens

    2052 ether,   //14400000 tokens 30% of ICO tokens

    2880 ether    //19200000 tokens 40% of ICO tokens

    ];



    mapping(address => bool) public referrals;

    mapping(address => uint) public reservedTokens;

    mapping(address => uint) public reservedRefsTokens;

    uint public amountReservedTokens;

    uint public amountReservedRefsTokens;



    event Finalized();

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event TokenReserved(address indexed beneficiary, uint256 value, uint256 amount, address referral);





    modifier onlyWhileOpen {

        require(now >= openingTime && now <= closingTime);

        _;

    }





    modifier onlyPreIco {

        require(msg.sender == preico);

        _;

    }





    function Crowdsale(CryptoRoboticsToken _token) public

    {

        require(_token != address(0));



        wallet = 0x3eb945fd746fbdf641f1063731d91a6fb381ea0f;

        token = _token;

        openingTime = 1526774400;

        closingTime = 1532044800;

        vault = new RefundVault(wallet);

    }





    function () external payable {

        buyTokens(msg.sender, address(0));

    }





    function buyTokens(address _beneficiary, address _ref) public payable {

        uint256 weiAmount = msg.value;

        _preValidatePurchase(_beneficiary, weiAmount);

        _getTokenAmount(weiAmount,true,_beneficiary,_ref);

    }





    function reserveTokens(address _ref) public payable {

        uint256 weiAmount = msg.value;

        _preValidateReserve(msg.sender, weiAmount, _ref);

        _getTokenAmount(weiAmount, false,msg.sender,_ref);

    }





    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view onlyWhileOpen {

        require(weiRaised.add(_weiAmount) <= cap);

        require(_weiAmount >= stagePrices[currentStage]);

        require(_beneficiary != address(0));



    }



    function _preValidateReserve(address _beneficiary, uint256 _weiAmount, address _ref) internal view {

        require(now < openingTime);

        require(referrals[_ref]);

        require(weiRaised.add(_weiAmount) <= cap);

        require(_weiAmount >= stagePrices[currentStage]);

        require(_beneficiary != address(0));

    }





    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {

        token.transfer(_beneficiary, _tokenAmount);

    }





    function _processPurchase(address _beneficiary, uint256 _tokenAmount, address _ref) internal {

        _tokenAmount = _tokenAmount * 1 ether;

        _deliverTokens(_beneficiary, _tokenAmount);

        if (referrals[_ref]) {

            uint _refTokens = valueFromPercent(_tokenAmount,10);

            token.transferFrom(reserve_fund, _ref, _refTokens);

        }

    }





    function _processReserve(address _beneficiary, uint256 _tokenAmount, address _ref) internal {

        _tokenAmount = _tokenAmount * 1 ether;

        _reserveTokens(_beneficiary, _tokenAmount);

        uint _refTokens = valueFromPercent(_tokenAmount,10);

        _reserveRefTokens(_ref, _refTokens);

    }





    function _reserveTokens(address _beneficiary, uint256 _tokenAmount) internal {

        reservedTokens[_beneficiary] = reservedTokens[_beneficiary].add(_tokenAmount);

        amountReservedTokens = amountReservedTokens.add(_tokenAmount);

    }





    function _reserveRefTokens(address _beneficiary, uint256 _tokenAmount) internal {

        reservedRefsTokens[_beneficiary] = reservedRefsTokens[_beneficiary].add(_tokenAmount);

        amountReservedRefsTokens = amountReservedRefsTokens.add(_tokenAmount);

    }





    function getReservedTokens() public {

        require(now >= openingTime);

        require(reservedTokens[msg.sender] > 0);

        amountReservedTokens = amountReservedTokens.sub(reservedTokens[msg.sender]);

        reservedTokens[msg.sender] = 0;

        token.transfer(msg.sender, reservedTokens[msg.sender]);

    }





    function getRefReservedTokens() public {

        require(now >= openingTime);

        require(reservedRefsTokens[msg.sender] > 0);

        amountReservedRefsTokens = amountReservedRefsTokens.sub(reservedRefsTokens[msg.sender]);

        reservedRefsTokens[msg.sender] = 0;

        token.transferFrom(reserve_fund, msg.sender, reservedRefsTokens[msg.sender]);

    }





    function valueFromPercent(uint _value, uint _percent) internal pure returns(uint amount)    {

        uint _amount = _value.mul(_percent).div(100);

        return (_amount);

    }





    function _getTokenAmount(uint256 _weiAmount, bool _buy, address _beneficiary, address _ref) internal {

        uint256 weiAmount = _weiAmount;

        uint _tokens = 0;

        uint _tokens_price = 0;

        uint _current_tokens = 0;



        for (uint p = currentStage; p < 4 && _weiAmount >= stagePrices[p]; p++) {

            if (stageLimits[p] > 0 ) {

                //§Ö§ã§Ý§Ú §Ý§Ú§Þ§Ú§ä §Ò§à§Ý§î§ê§Ö §é§Ö§Þ _weiAmount, §ä§à§Ô§Õ§Ñ §ã§é§Ú§ä§Ñ§Ö§Þ §Ó§ã§Ö §Ú§Ù §â§Ñ§ã§é§Ö§ä§Ñ §é§ä§à §Ó§á§Ú§ã§í§Ó§Ñ§Ö§Þ§ã§ñ §Ó §Ý§Ú§Þ§Ú§ä

                //§Ú §Ó§í§ç§à§Õ§Ú§Þ §Ú§Ù §è§Ú§Ü§Ý§Ñ

                if (stageLimits[p] > _weiAmount) {

                    //§Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §ä§à§Ü§Ö§ß§à§Ó §á§à §ä§Ö§Ü§å§ë§Ö§Þ§å §á§â§Ñ§Û§ã§å (§à§ã§ä§Ñ§ß§Ö§ä§ã§ñ §à§ã§ä§Ñ§ä§à§Ü §Ö§ã§Ý§Ú §á§â§Ú§ã§Ý§Ñ§Ý§Ú  §Ò§à§Ý§î§ê§Ö §é§Ö§Þ §ß§Ñ §ä§à§é§ß§à§Ö §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §Þ§à§ß§Ö§ä)

                    _current_tokens = _weiAmount.div(stagePrices[p]);

                    //§è§Ö§ß§Ñ §Ó§ã§Ö§ç §Þ§à§ß§Ö§ä, §é§ä§à§Ò§í §à§á§â§Ö§Õ§Ö§Ý§Ú§ä§î §à§ã§ä§Ñ§ä§à§Ü §ß§Ö§Ú§Ù§â§Ñ§ã§ç§à§Õ§à§Ó§Ñ§ß§ß§í§ç wei

                    _tokens_price = _current_tokens.mul(stagePrices[p]);

                    //§á§à§Ý§å§é§Ñ§Ö§Þ §à§ã§ä§Ñ§ä§à§Ü

                    _weiAmount = _weiAmount.sub(_tokens_price);

                    //§Õ§à§Ò§Ñ§Ó§Ý§ñ§Ö§Þ §ä§à§Ü§Ö§ß§í §ä§Ö§Ü§å§ë§Ö§Ô§à §ã§ä§ï§Û§Õ§Ø§Ñ §Ü §à§Ò§ë§Ö§Þ§å §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§å

                    _tokens = _tokens.add(_current_tokens);

                    //§à§Ò§ß§à§Ó§Ý§ñ§Ö§Þ §Ý§Ú§Þ§Ú§ä§í

                    stageLimits[p] = stageLimits[p].sub(_tokens_price);

                    break;

                } else { //§Ý§Ú§Þ§Ú§ä §Þ§Ö§ß§î§ê§Ö §é§Ö§Þ §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à wei

                    //§á§à§Ý§å§é§Ñ§Ö§Þ §Ó§ã§Ö §à§ã§ä§Ñ§Ó§ê§Ú§Ö§ã§ñ §ä§à§Ü§Ö§ß§í §Ó §ã§ä§Ö§Û§Õ§Ø§Ö

                    _current_tokens = stageLimits[p].div(stagePrices[p]);

                    _weiAmount = _weiAmount.sub(stageLimits[p]);

                    _tokens = _tokens.add(_current_tokens);

                    stageLimits[p] = 0;

                    _updateStage();

                }



            }

        }



        weiAmount = weiAmount.sub(_weiAmount);

        weiRaised = weiRaised.add(weiAmount);



        if (_buy) {

            _processPurchase(_beneficiary, _tokens, _ref);

            emit TokenPurchase(msg.sender, _beneficiary, weiAmount, _tokens);

        } else {

            _processReserve(msg.sender, _tokens, _ref);

            emit TokenReserved(msg.sender, weiAmount, _tokens, _ref);

        }



        //§à§ä§á§â§Ñ§Ó§Ý§ñ§Ö§Þ §à§Ò§â§Ñ§ä§ß§à §ß§Ö§Ú§Ù§â§Ñ§ã§ç§à§Õ§à§Ó§Ñ§ß§ß§í§Û §à§ã§ä§Ñ§ä§à§Ü

        if (_weiAmount > 0) {

            msg.sender.transfer(_weiAmount);

        }



        // update state





        _forwardFunds(weiAmount);

    }





    function _updateStage() internal {

        if ((stageLimits[currentStage] == 0) && currentStage < 3) {

            currentStage++;

        }

    }





    function _forwardFunds(uint _weiAmount) internal {

        vault.deposit.value(_weiAmount)(msg.sender);

    }





    function hasClosed() public view returns (bool) {

        return now > closingTime;

    }





    function capReached() public view returns (bool) {

        return weiRaised >= cap;

    }





    function goalReached() public view returns (bool) {

        return weiRaised >= goal;

    }





    function finalize() onlyOwner public {

        require(!isFinalized);

        require(hasClosed() || capReached());



        finalization();

        emit Finalized();



        isFinalized = true;

    }





    function finalization() internal {

        if (goalReached()) {

            vault.close();

        } else {

            vault.enableRefunds();

        }



        uint token_balace = token.balanceOf(this);

        token_balace = token_balace.sub(amountReservedTokens);//

        token.burn(token_balace);

    }





    function addReferral(address _ref) external onlyOwner {

        referrals[_ref] = true;

    }





    function removeReferral(address _ref) external onlyOwner {

        referrals[_ref] = false;

    }





    function setPreIco(address _preico) onlyOwner public {

        preico = _preico;

    }





    function setTokenCountFromPreIco(uint _value) onlyPreIco public{

        _value = _value.div(1 ether);

        uint weis = _value.mul(stagePrices[3]);

        stageLimits[3] = stageLimits[3].add(weis);

        cap = cap.add(weis);



    }





    function claimRefund() public {

        require(isFinalized);

        require(!goalReached());



        vault.refund(msg.sender);

    }



}