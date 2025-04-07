pragma solidity ^0.4.0;



contract Bank is Owned
{
    struct Depositor {
        uint amount;
        uint time;
    }

    event Deposit(address indexed depositor, uint amount);
    
    event Donation(address indexed donator, uint amount);
    
    event Withdrawal(address indexed to, uint amount);
    
    event DepositReturn(address indexed depositor, uint amount);
    
    address owner0l;
    uint numDeposits;
    uint releaseDate;
    mapping (address => Depositor) public Deposits;
    address[] public Depositors;
    
    function
    initBank(uint daysUntilRelease)
    public
    {
        numDeposits = 0;
        owner0l = msg.sender;
        releaseDate = now;
        if (daysUntilRelease > 0 && daysUntilRelease < (1 years * 5))
        {
            releaseDate += daysUntilRelease * 1 days;
        }
        else
        {
            // default 1 day
            releaseDate += 1 days;
        }
    }

    // Accept donations and deposits
    function
    ()
    public
    payable
    {
        if (msg.value > 0)
        {
            if (msg.value < 1 ether)
                Donation(msg.sender, msg.value);
            else
                deposit();
        }
    }
    
    // Accept deposit and create Depositor record
    function
    deposit()
    public
    payable
    returns (uint)
    {
        if (msg.value > 0)
            addDeposit();
        return getNumberOfDeposits();
    }
    
    // Track deposits
    function
    addDeposit()
    private
    {
        Depositors.push(msg.sender);
        Deposits[msg.sender].amount = msg.value;
        Deposits[msg.sender].time = now;
        numDeposits++;
        Deposit(msg.sender, msg.value);
    }
    
    function
    returnDeposit()
    public
    {
        if (now > releaseDate)
        {
            if (Deposits[msg.sender].amount > 1) {
                uint _wei = Deposits[msg.sender].amount;
                Deposits[msg.sender].amount = 0;
                msg.sender.send(_wei);
                DepositReturn(msg.sender, _wei);
            }
        }
    }

    // Depositor funds to be withdrawn after release period
    function
    withdrawDepositorFunds(address _to, uint _wei)
    public
    returns (bool)
    {
        if (_wei > 0)
        {
            if (isOwner() && Deposits[_to].amount > 0)
            {
                Withdrawal(_to, _wei);
                return _to.send(_wei);
            }
        }
    }

    function
    withdraw()
    public
    {
        if (isCreator() && now >= releaseDate)
        {
            Withdrawal(creator, this.balance);
            creator.send(this.balance);
        }
    }

    function
    getNumberOfDeposits()
    public
    constant
    returns (uint)
    {
        return numDeposits;
    }

    function
    kill()
    public
    {
        if (isOwner() || isCreator())
            selfdestruct(creator);
    }
}