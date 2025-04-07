/**

 *Submitted for verification at Etherscan.io on 2018-10-30

*/



pragma solidity ^0.4.24;





/// @title Version

contract Version {

    string public semanticVersion;



    /// @notice Constructor saves a public version of the deployed Contract.

    /// @param _version Semantic version of the contract.

    constructor(string _version) internal {

        semanticVersion = _version;

    }

}





/// @title Factory

contract Factory is Version {

    event FactoryAddedContract(address indexed _contract);



    modifier contractHasntDeployed(address _contract) {

        require(contracts[_contract] == false);

        _;

    }



    mapping(address => bool) public contracts;



    constructor(string _version) internal Version(_version) {}



    function hasBeenDeployed(address _contract) public constant returns (bool) {

        return contracts[_contract];

    }



    function addContract(address _contract)

        internal

        contractHasntDeployed(_contract)

        returns (bool)

    {

        contracts[_contract] = true;

        emit FactoryAddedContract(_contract);

        return true;

    }

}





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */







contract SpendableWallet is Ownable {

    ERC20 public token;



    event ClaimedTokens(

        address indexed _token,

        address indexed _controller,

        uint256 _amount

    );



    constructor(address _token, address _owner) public {

        token = ERC20(_token);

        owner = _owner;

    }



    function spend(address _to, uint256 _amount) public onlyOwner {

        require(

            token.transfer(_to, _amount),

            "Token transfer could not be executed."

        );

    }



    /// @notice This method can be used by the controller to extract mistakenly

    ///  sent tokens to this contract.

    /// @param _token The address of the token contract that you want to recover

    ///  set to 0 in case you want to extract ether.

    function claimTokens(address _token) public onlyOwner {

        if (_token == 0x0) {

            owner.transfer(address(this).balance);

            return;

        }



        ERC20 erc20token = ERC20(_token);

        uint256 balance = erc20token.balanceOf(address(this));

        require(

            erc20token.transfer(owner, balance),

            "Token transfer could not be executed."

        );

        emit ClaimedTokens(_token, owner, balance);

    }

}





contract SpendableWalletFactory is Factory {

    // index of created contracts

    address[] public spendableWallets;



    constructor() public Factory("1.0.3") {}



    // deploy a new contract

    function newPaymentAddress(address _token, address _owner)

        public

        returns(address newContract)

    {

        SpendableWallet spendableWallet = new SpendableWallet(_token, _owner);

        spendableWallets.push(spendableWallet);

        addContract(spendableWallet);

        return spendableWallet;

    }

}