pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20BasicInterface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);

    uint8 public decimals;
}


/**
 * @title AirDropContract
 * Simply do the airdrop.
 */
contract AirDrop is Ownable {
    using SafeMath for uint256;

    // the amount that owner wants to send each time
    uint public airDropAmount;

    // the mapping to judge whether each address has already been airDropped
    mapping ( address => bool ) public invalidAirDrop;

    // flag to stop airdrop
    bool public stop = false;

    ERC20BasicInterface public erc20;

    uint256 public startTime;
    uint256 public endTime;

    // event
    event LogAirDrop(address indexed receiver, uint amount);
    event LogStop();
    event LogStart();
    event LogWithdrawal(address indexed receiver, uint amount);

    /**
    * @dev Constructor to set _airDropAmount and _tokenAddresss.
    * @param _airDropAmount The amount of token that is sent for doing airDrop.
    * @param _tokenAddress The address of token.
    */
    function AirDrop(uint256 _startTime, uint256 _endTime, uint _airDropAmount, address _tokenAddress) public {
        require(_startTime >= now &&
            _endTime >= _startTime &&
            _airDropAmount > 0 &&
            _tokenAddress != address(0)
        );
        startTime = _startTime;
        endTime = _endTime;
        erc20 = ERC20BasicInterface(_tokenAddress);
        uint tokenDecimals = erc20.decimals();
        airDropAmount = _airDropAmount.mul(10 ** tokenDecimals);
    }

    /**
    * @dev Confirm that airDrop is available.
    * @return A bool to confirm that airDrop is available.
    */
    function isValidAirDropForAll() public view returns (bool) {
        bool validNotStop = !stop;
        bool validAmount = erc20.balanceOf(this) >= airDropAmount;
        bool validPeriod = now >= startTime && now <= endTime;
        return validNotStop && validAmount && validPeriod;
    }

    /**
    * @dev Confirm that airDrop is available for msg.sender.
    * @return A bool to confirm that airDrop is available for msg.sender.
    */
    function isValidAirDropForIndividual() public view returns (bool) {
        bool validNotStop = !stop;
        bool validAmount = erc20.balanceOf(this) >= airDropAmount;
        bool validPeriod = now >= startTime && now <= endTime;
        bool validAmountForIndividual = !invalidAirDrop[msg.sender];
        return validNotStop && validAmount && validPeriod && validAmountForIndividual;
    }

    /**
    * @dev Do the airDrop to msg.sender
    */
    function receiveAirDrop() public {
        require(isValidAirDropForIndividual());

        // set invalidAirDrop of msg.sender to true
        invalidAirDrop[msg.sender] = true;

        // execute transferFrom
        require(erc20.transfer(msg.sender, airDropAmount));

        LogAirDrop(msg.sender, airDropAmount);
    }

    /**
    * @dev Change the state of stop flag
    */
    function toggle() public onlyOwner {
        stop = !stop;

        if (stop) {
            LogStop();
        } else {
            LogStart();
        }
    }

    /**
    * @dev Withdraw the amount of token that is remaining in this contract.
    * @param _address The address of EOA that can receive token from this contract.
    */
    function withdraw(address _address) public onlyOwner {
        require(stop || now > endTime);
        require(_address != address(0));
        uint tokenBalanceOfContract = erc20.balanceOf(this);
        require(erc20.transfer(_address, tokenBalanceOfContract));
        LogWithdrawal(_address, tokenBalanceOfContract);
    }
}