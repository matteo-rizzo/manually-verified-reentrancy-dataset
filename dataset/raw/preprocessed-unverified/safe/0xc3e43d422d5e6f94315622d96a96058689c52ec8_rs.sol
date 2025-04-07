pragma solidity ^0.4.23;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */








contract BitNauticCrowdsaleTokenDistributor is Ownable {
    using SafeMath for uint256;

    uint256 public constant ICOStartTime = 1531267200; // 11 Jul 2018 00:00 GMT
    uint256 public constant ICOEndTime = 1536969600; // 15 Sep 2018 00:00 GMT

    uint256 public teamSupply =     3000000 * 10 ** 18; // 6% of token cap
    uint256 public bountySupply =   2500000 * 10 ** 18; // 5% of token cap
    uint256 public reserveSupply =  5000000 * 10 ** 18; // 10% of token cap
    uint256 public advisorSupply =  2500000 * 10 ** 18; // 5% of token cap
    uint256 public founderSupply =  2000000 * 10 ** 18; // 4% of token cap

    MintableToken public token;
    BitNauticWhitelist public whitelist;
    BitNauticCrowdsale public crowdsale;

    mapping (address => bool) public hasClaimedTokens;

    constructor(MintableToken _token, BitNauticWhitelist _whitelist, BitNauticCrowdsale _crowdsale) public {
        token = _token;
        whitelist = _whitelist;
        crowdsale = _crowdsale;
    }

    function privateSale(address beneficiary, uint256 tokenAmount) onlyOwner public {
        require(beneficiary != 0x0);

        assert(token.mint(beneficiary, tokenAmount));
    }

    // this function can be called by the contributor to claim his BTNT tokens at the end of the ICO
    function claimBitNauticTokens() public returns (bool) {
        return grantContributorTokens(msg.sender);
    }

    // if the ICO is finished and the goal has been reached, this function will be used to mint and transfer BTNT tokens to each contributor
    function grantContributorTokens(address contributor) public returns (bool) {
        require(!hasClaimedTokens[contributor]);
        require(crowdsale.creditOf(contributor) > 0);
        require(whitelist.AMLWhitelisted(contributor));
        require(now > ICOEndTime);

        assert(token.mint(contributor, crowdsale.creditOf(contributor)));
        hasClaimedTokens[contributor] = true;

        return true;
    }

    function transferTokenOwnership(address newTokenOwner) onlyOwner public returns (bool) {
        return token.transferOwnership(newTokenOwner);
    }

    function grantBountyTokens(address beneficiary) onlyOwner public {
        require(bountySupply > 0);

        token.mint(beneficiary, bountySupply);
        bountySupply = 0;
    }

    function grantReserveTokens(address beneficiary) onlyOwner public {
        require(reserveSupply > 0);

        token.mint(beneficiary, reserveSupply);
        reserveSupply = 0;
    }

    function grantAdvisorsTokens(address beneficiary) onlyOwner public {
        require(advisorSupply > 0);

        token.mint(beneficiary, advisorSupply);
        advisorSupply = 0;
    }

    function grantFoundersTokens(address beneficiary) onlyOwner public {
        require(founderSupply > 0);

        token.mint(beneficiary, founderSupply);
        founderSupply = 0;
    }

    function grantTeamTokens(address beneficiary) onlyOwner public {
        require(teamSupply > 0);

        token.mint(beneficiary, teamSupply);
        teamSupply = 0;
    }
}