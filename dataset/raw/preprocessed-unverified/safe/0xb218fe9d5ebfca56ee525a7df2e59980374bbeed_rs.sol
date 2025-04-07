/**
 *Submitted for verification at Etherscan.io on 2021-05-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract PETH {
    using SafeMath for uint256;
    string public name     = "PairX ETH";
    string public symbol   = "PETH";
    uint8  public decimals = 18;

    uint256 public totalPETH = 0;
    uint256 public usedETH = 0;
    address public investAddr;
    address public managerAddr;

    bool private reEntrancyMutex = false;//Mutexes that prevent reentrant attacks
    bool private canDeposit = true;//Allow to deposit.

    event  Approval(address indexed src, address indexed guy, uint256 wad);
    event  Transfer(address indexed src, address indexed dst, uint256 wad);
    event  Deposit(address indexed dst, uint256 wad);
    event  Withdrawal(address indexed src, uint256 wad);
    event  Invest(address indexed src, uint256 wad);
    event  ChangeIvAddr(address indexed src, address indexed newAddr);
    event  ChangeMngAddr(address indexed src, address indexed newAddr);
    event  ChangeDeposit(address indexed src, bool canDeposit);

    mapping (address => uint256)                       public  balanceOf;
    mapping (address => mapping (address => uint256))  public  allowance;

    constructor(address _investAddr, address _managerAddr) public {
        investAddr = _investAddr;
        managerAddr = _managerAddr;
    }

    fallback() external payable {}
    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        if (msg.sender == investAddr) {
            usedETH = usedETH.sub(msg.value);
        } else {
            require(canDeposit);
            balanceOf[msg.sender] = msg.value.add(balanceOf[msg.sender]);
            totalPETH = msg.value.add(totalPETH);
            emit Transfer(address(0), msg.sender, msg.value);
        }
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint256 wad) public {
        require(!reEntrancyMutex);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(wad);
        totalPETH = totalPETH.sub(wad);

        reEntrancyMutex = true;
        msg.sender.transfer(wad);
        emit Transfer(msg.sender, address(0), wad);
        emit Withdrawal(msg.sender, wad);
        reEntrancyMutex = false;
    }
    function invest(uint256 wad) public {
        usedETH = usedETH.add(wad);
        address(uint160(investAddr)).transfer(wad);
        emit Invest(msg.sender, wad);
    }
    function changeIvAddr(address newAddr) public {
        require(msg.sender == investAddr, "Only investAddr can change Invest Address.");
        investAddr = newAddr;
        emit ChangeIvAddr(msg.sender, newAddr);
    }
    function changeMngAddr(address newAddr) public {
        require(msg.sender == managerAddr, "Only managerAddr can change Interest Address.");
        managerAddr = newAddr;
        emit ChangeMngAddr(msg.sender, newAddr);
    }
    function changeDeposit(bool _canDeposit) public {
        require(msg.sender == managerAddr, "Only managerAddr can change Deposit State.");
        canDeposit = _canDeposit;
        emit ChangeDeposit(msg.sender, _canDeposit);
    }

    function totalSupply() public view returns (uint256) {
        return totalPETH;
    }

    function approve(address guy, uint256 wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint256 wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint256 wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] = allowance[src][msg.sender].sub(wad);
        }

        balanceOf[src] = balanceOf[src].sub(wad);
        balanceOf[dst] = balanceOf[dst].add(wad);

        emit Transfer(src, dst, wad);

        return true;
    }
}