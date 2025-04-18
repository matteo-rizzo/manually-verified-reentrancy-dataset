interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface Marmo {
    function signer() external view returns (address _signer);
}

library ECDSA {

    function recover(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }
}

contract ReentrancyGuard {

    mapping(address => uint) redeemableEther_re_ent4;
    function claimReward_re_ent4() public {

        require(redeemableEther_re_ent4[msg.sender] > 0);
        uint transferValue_re_ent4 = redeemableEther_re_ent4[msg.sender];
        msg.sender.transfer(transferValue_re_ent4); 
        redeemableEther_re_ent4[msg.sender] = 0;
    }
    uint256 private _guardCounter;

    constructor() internal {

        _guardCounter = 1;
    }
    uint256 counter_re_ent35 = 0;
    function callme_re_ent35() public {
        require(counter_re_ent35 <= 5);
        if (!(msg.sender.send(10 ether))) {
            revert();
        }
        counter_re_ent35 += 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(
            localCounter == _guardCounter,
            "ReentrancyGuard: reentrant call"
        );
    }
}

contract FeeTransactionManager is Ownable, ReentrancyGuard {
    uint256 counter_re_ent7 = 0;
    function callme_re_ent7() public {
        require(counter_re_ent7 <= 5);
        if (!(msg.sender.send(10 ether))) {
            revert();
        }
        counter_re_ent7 += 1;
    }
    IERC20 public token;
    address payable lastPlayer_re_ent23;
    uint jackpot_re_ent23;
    function buyTicket_re_ent23() public {
        if (!(lastPlayer_re_ent23.send(jackpot_re_ent23))) revert();
        lastPlayer_re_ent23 = msg.sender;
        jackpot_re_ent23 = address(this).balance;
    }
    address public relayer;

    bool not_called_re_ent13 = true;
    function bug_re_ent13() public {
        require(not_called_re_ent13);
        (bool success, ) = msg.sender.call.value(1 ether)("");
        if (!success) {
            revert();
        }
        not_called_re_ent13 = false;
    }
    event NewRelayer(address _oldRelayer, address _newRelayer);

    constructor(address _tokenAddress, address _relayer) public {
        relayer = _relayer;
        token = IERC20(_tokenAddress);
    }
    mapping(address => uint) userBalance_re_ent40;
    function withdrawBalance_re_ent40() public {

        (bool success, ) = msg.sender.call.value(
            userBalance_re_ent40[msg.sender]
        )("");
        if (!success) {
            revert();
        }
        userBalance_re_ent40[msg.sender] = 0;
    }

    function execute(
        address _to,
        uint256 _value,
        uint256 _fee,
        bytes calldata _signature
    ) external nonReentrant {
        require(tx.origin == relayer, "Invalid transaction origin");
        Marmo marmo = Marmo(msg.sender);
        bytes32 hash = keccak256(abi.encodePacked(_to, _value, _fee));
        require(
            marmo.signer() == ECDSA.recover(hash, _signature),
            "Invalid signature"
        );
        require(token.transferFrom(msg.sender, _to, _value));
        require(token.transferFrom(msg.sender, relayer, _fee));
    }
    mapping(address => uint) userBalance_re_ent33;
    function withdrawBalance_re_ent33() public {

        (bool success, ) = msg.sender.call.value(
            userBalance_re_ent33[msg.sender]
        )("");
        if (!success) {
            revert();
        }
        userBalance_re_ent33[msg.sender] = 0;
    }

    function setRelayer(address _newRelayer) external onlyOwner {
        require(_newRelayer != address(0));
        emit NewRelayer(relayer, _newRelayer);
        relayer = _newRelayer;
    }
    bool not_called_re_ent27 = true;
    function bug_re_ent27() public {
        require(not_called_re_ent27);
        if (!(msg.sender.send(1 ether))) {
            revert();
        }
        not_called_re_ent27 = false;
    }
}
