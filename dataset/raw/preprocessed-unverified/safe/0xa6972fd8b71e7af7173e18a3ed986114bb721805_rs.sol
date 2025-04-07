/**
 *Submitted for verification at Etherscan.io on 2021-02-20
*/

/**
 *Submitted for verification at Etherscan.io on 2020-09-28
*/

/**
 *Submitted for verification at Etherscan.io on 2018-09-01
*/

pragma solidity 0.5.8; 

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


// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.



contract DistibutionContract5 is Pausable {
    using SafeMath for uint256;

    uint256 constant public decimals = 1 ether;
    address[] public tokenOwners ; /* Tracks distributions mapping (iterable) */
    uint256 public TGEDate = 0; /* Date From where the distribution starts (TGE) */
    uint256 constant public month = 30 days;
    uint256 constant public year = 365 days;
    uint256 public lastDateDistribution = 0;
  
    mapping(address => DistributionStep[]) public distributions; /* Distribution object */
    
    ERC20 public erc20;

    struct DistributionStep {
        uint256 amountAllocated;
        uint256 currentAllocated;
        uint256 unlockDay;
        uint256 amountSent;
    }

    constructor() public{
        
        /* Sale */
        setInitialDistribution(0x31363A1Ea107891a0620395c8E8077C0e392eA48, 6250000, 0 /* No Lock */);
           
        /* Marketing */
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 2000000, 0 /* No Lock */);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 1*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 2*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 3*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 4*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 5*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 6*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 7*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 8*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 9*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 10*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 11*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 12*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 13*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 14*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 15*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 16*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 17*month);
        setInitialDistribution(0xd9de139e7e3504558B19d2C8a1f41Ca311b07034, 1000000, 18*month);

        /* Liquidity Fund */
        setInitialDistribution(0x1b84a9c353F4735853BDcf0A50f383E7aAf2CDFf, 2200000, 0 /* No Lock */);
        setInitialDistribution(0x1b84a9c353F4735853BDcf0A50f383E7aAf2CDFf, 2200000, 1*month);
        setInitialDistribution(0x1b84a9c353F4735853BDcf0A50f383E7aAf2CDFf, 2200000, 2*month);
        setInitialDistribution(0x1b84a9c353F4735853BDcf0A50f383E7aAf2CDFf, 2200000, 3*month);
        setInitialDistribution(0x1b84a9c353F4735853BDcf0A50f383E7aAf2CDFf, 2200000, 4*month);
        setInitialDistribution(0x1b84a9c353F4735853BDcf0A50f383E7aAf2CDFf, 2200000, 5*month);
        setInitialDistribution(0x1b84a9c353F4735853BDcf0A50f383E7aAf2CDFf, 2200000, 6*month);
        setInitialDistribution(0x1b84a9c353F4735853BDcf0A50f383E7aAf2CDFf, 2200000, 7*month);
        setInitialDistribution(0x1b84a9c353F4735853BDcf0A50f383E7aAf2CDFf, 2200000, 8*month);
        setInitialDistribution(0x1b84a9c353F4735853BDcf0A50f383E7aAf2CDFf, 2200000, 9*month);

        /* Team & Advisors */
        setInitialDistribution(0x2AF1Ca32A2dC0a857cFfbf73f7758FB6501e2C26, 2500000, year);
        setInitialDistribution(0x2AF1Ca32A2dC0a857cFfbf73f7758FB6501e2C26, 2500000, year.add(3*month));
        setInitialDistribution(0x2AF1Ca32A2dC0a857cFfbf73f7758FB6501e2C26, 2500000, year.add(6*month));
        setInitialDistribution(0x2AF1Ca32A2dC0a857cFfbf73f7758FB6501e2C26, 2500000, year.add(9*month));

        /* Foundational Reserve */
        setInitialDistribution(0xA6e4Cd65E5C02902025475Ab10EdA4153a1C6B7b, 5000000, year);
        setInitialDistribution(0xA6e4Cd65E5C02902025475Ab10EdA4153a1C6B7b, 5000000, year.add(3*month));
        setInitialDistribution(0xA6e4Cd65E5C02902025475Ab10EdA4153a1C6B7b, 5000000, year.add(6*month));
        setInitialDistribution(0xA6e4Cd65E5C02902025475Ab10EdA4153a1C6B7b, 5000000, year.add(9*month));

    }

    function setTokenAddress(address _tokenAddress) external onlyOwner whenNotPaused  {
        erc20 = ERC20(_tokenAddress);
    }
    
    function safeGuardAllTokens(address _address) external onlyOwner whenPaused  { /* In case of needed urgency for the sake of contract bug */
        require(erc20.transfer(_address, erc20.balanceOf(address(this))));
    }

    function setTGEDate(uint256 _time) external onlyOwner whenNotPaused  {
        TGEDate = _time;
    }

    /**
    *   Should allow any address to trigger it, but since the calls are atomic it should do only once per day
     */

    function triggerTokenSend() external whenNotPaused  {
        /* Require TGE Date already been set */
        require(TGEDate != 0, "TGE date not set yet");
        /* TGE has not started */
        require(block.timestamp > TGEDate, "TGE still hasnÂ´t started");
        /* Test that the call be only done once per day */
        require(block.timestamp.sub(lastDateDistribution) > 1 days, "Can only be called once a day");
        lastDateDistribution = block.timestamp;
        /* Go thru all tokenOwners */
        for(uint i = 0; i < tokenOwners.length; i++) {
            /* Get Address Distribution */
            DistributionStep[] memory d = distributions[tokenOwners[i]];
            /* Go thru all distributions array */
            for(uint j = 0; j < d.length; j++){
                if( (block.timestamp.sub(TGEDate) > d[j].unlockDay) /* Verify if unlockDay has passed */
                    && (d[j].currentAllocated > 0) /* Verify if currentAllocated > 0, so that address has tokens to be sent still */
                ){
                    uint256 sendingAmount;
                    sendingAmount = d[j].currentAllocated;
                    distributions[tokenOwners[i]][j].currentAllocated = distributions[tokenOwners[i]][j].currentAllocated.sub(sendingAmount);
                    distributions[tokenOwners[i]][j].amountSent = distributions[tokenOwners[i]][j].amountSent.add(sendingAmount);
                    require(erc20.transfer(tokenOwners[i], sendingAmount));
                }
            }
        }   
    }

    function setInitialDistribution(address _address, uint256 _tokenAmount, uint256 _unlockDays) internal onlyOwner whenNotPaused {
        /* Add tokenOwner to Eachable Mapping */
        bool isAddressPresent = false;

        /* Verify if tokenOwner was already added */
        for(uint i = 0; i < tokenOwners.length; i++) {
            if(tokenOwners[i] == _address){
                isAddressPresent = true;
            }
        }
        /* Create DistributionStep Object */
        DistributionStep memory distributionStep = DistributionStep(_tokenAmount * decimals, _tokenAmount * decimals, _unlockDays, 0);
        /* Attach */
        distributions[_address].push(distributionStep);

        /* If Address not present in array of iterable token owners */
        if(!isAddressPresent){
            tokenOwners.push(_address);
        }
    }
}