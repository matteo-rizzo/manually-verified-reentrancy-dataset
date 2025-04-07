/**

 *Submitted for verification at Etherscan.io on 2018-12-13

*/



pragma solidity 0.4.25;



// File: openzeppelin-solidity/contracts/cryptography/ECDSA.sol



/**

 * @title Elliptic curve signature operations

 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d

 * TODO Remove this library once solidity supports passing a signature to ecrecover.

 * See https://github.com/ethereum/solidity/issues/864

 */







// File: contracts/Web3Provider.sol



contract Web3Provider {

    

    using ECDSA for bytes32;

    

    uint256 constant public REQUEST_PRICE = 100 wei;

    

    uint256 public clientDeposit;

    uint256 public chargedService;

    address public clientAddress;

    address public web3provider;

    uint256 public timelock;

    bool public charged;

    

    

    constructor() public {

        web3provider = msg.sender;

    }

    

    function() external {}

    

    function subscribeForProvider()

        external

        payable

    {

        require(clientAddress == address(0));

        require(msg.value % REQUEST_PRICE == 0);

        

        clientDeposit = msg.value;

        clientAddress = msg.sender;

        timelock = now + 1 days;

    }

    

    function chargeService(uint256 _amountRequests, bytes _sig) 

        external

    {

        require(charged == false);

        require(now <= timelock);

        require(msg.sender == web3provider);

        

        bytes32 hash = keccak256(abi.encodePacked(_amountRequests));

        require(hash.recover(_sig) == clientAddress);

        chargedService = _amountRequests*REQUEST_PRICE;

        require(chargedService <= clientDeposit);

        charged = true;

        web3provider.transfer(chargedService);

    }

    

    function withdrawDeposit()

        external

    {

        require(msg.sender == clientAddress);

        require(now > timelock);

        clientAddress.transfer(address(this).balance);

    }

}