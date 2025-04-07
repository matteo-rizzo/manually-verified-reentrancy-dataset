/**

 *Submitted for verification at Etherscan.io on 2018-09-07

*/



pragma solidity 0.4.24;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/// @title Interface for token controllers. The controller specifies whether a transfer can be done.

contract TokenControllerI {



    /// @dev Specifies whether a transfer is allowed or not.

    /// @return True if the transfer is allowed

    function transferAllowed(address _from, address _to)

        external

        view 

        returns (bool);

}















contract FoamTokenController is TokenControllerI, Ownable {

    using SafeMath for uint256;



    RegistryInterface public registry;

    SaleInterface public sale;



    uint256 public platformLaunchDate;



    uint256 public saleTokensPerUnit;

    uint256 public extraTokensPerUnit;



    mapping (address => bool) public isProtocolContract;



    mapping(address => address) public proposedPair;

    mapping(address => address) public pair;



    mapping(address => bool) public isBlacklisted;



    event ProposeWhitelisted(address _whitelistor, address _whitelistee);

    event ConfirmWhitelisted(address _whitelistor, address _whitelistee);



    // this is one of the TF multisigs.

    // We can then send the tokens onwards to wherever FOAM request for the tokens to be.

    address acceptedAddress = 0x36A9b165ef64767230A7Aded71B04F0911bB1283;



    constructor(RegistryInterface _registry, SaleInterface _sale, uint256 _launchDate) public {

        require(_registry != address(0));

        require(_sale != address(0));

        require(_launchDate != 0 && _launchDate <= now);



        registry = _registry;

        sale = _sale;

        platformLaunchDate = _launchDate;



        isProtocolContract[address(registry)] = true;



        saleTokensPerUnit = sale.saleTokensPerUnit();

        extraTokensPerUnit = sale.extraTokensPerUnit();

    }



    function setWhitelisted(address _whitelisted) public {

        require(_whitelisted != 0);



        require(pair[msg.sender] == 0);

        require(pair[_whitelisted] == 0);



        require(sale.unitContributions(msg.sender) != 0);

        require(sale.unitContributions(_whitelisted) == 0);



        proposedPair[msg.sender] = _whitelisted;

        emit ProposeWhitelisted(msg.sender, _whitelisted);

    }



    function confirmWhitelisted(address _whitelistor) public {

        require(pair[msg.sender] == 0);

        require(pair[_whitelistor] == 0);



        require(proposedPair[_whitelistor] == msg.sender);



        pair[msg.sender] = _whitelistor;

        pair[_whitelistor] = msg.sender;



        emit ConfirmWhitelisted(_whitelistor, msg.sender);

    }



    function blacklistAddresses(address[] _addresses, bool _isBlacklisted) public onlyOwner {

        for (uint256 i = 0; i < _addresses.length; i++) {

            isBlacklisted[_addresses[i]] = _isBlacklisted;

        }

    }



    function changeRegistry(RegistryInterface _newRegistry) public onlyOwner {

        require(_newRegistry != address(0));

        isProtocolContract[address(registry)] = false;

        isProtocolContract[address(_newRegistry)] = true;

        registry = _newRegistry;

    }



    function setPlatformLaunchDate(uint256 _launchDate) public onlyOwner {

        require(_launchDate != 0 && _launchDate <= now);

        platformLaunchDate = _launchDate;

    }



    function setProtocolContract(address _contract, bool _isProtocolContract) public onlyOwner {

        isProtocolContract[_contract] = _isProtocolContract;

    }



    function transferAllowed(address _from, address _to)

        external

        view

        returns (bool)

    {

        if(isBlacklisted[_from]) {

            if (_to == acceptedAddress) {

                return true;

            } else {

                return false;

            }

        }



        bool protocolTransfer = isProtocolContract[_from] || isProtocolContract[_to];

        bool whitelistedTransfer = pair[_from] == _to && pair[_to] == _from;



        if (protocolTransfer || whitelistedTransfer || platformLaunchDate + 1 years <= now) {

            return true;

        } else if (platformLaunchDate + 45 days > now) {

            return false;

        }

        return purchaseCheck(_from);

    }



    function purchaseCheck(address _contributor) internal view returns(bool) {

        address secondAddress = pair[_contributor];



        uint256 contributed = sale.unitContributions(_contributor);



        if (contributed == 0) {

            if (secondAddress == 0) {

                return true;

            } else {

                contributed = sale.unitContributions(secondAddress);

            }

        }



        uint256 tokensStaked = registry.totalStaked(_contributor);

        uint256 PoICreated = registry.numApplications(_contributor);



        if (secondAddress != 0) {

            tokensStaked = tokensStaked.add(registry.totalStaked(secondAddress));

            PoICreated = PoICreated.add(registry.numApplications(secondAddress));

        }



        uint256 tokensBought = contributed.mul(saleTokensPerUnit.add(extraTokensPerUnit));



        bool enoughStaked;

        if (contributed <= 10000) {

            enoughStaked = tokensStaked >= tokensBought.mul(25).div(100);

        } else {

            enoughStaked = tokensStaked >= tokensBought.mul(50).div(100);

        }



        return enoughStaked && PoICreated >= 10;

    }

}