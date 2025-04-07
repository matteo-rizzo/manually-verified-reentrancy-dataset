/**
 *Submitted for verification at Etherscan.io on 2020-06-11
*/

pragma solidity ^0.5.11;


// via https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol
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


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract SaleTokens is Ownable {
    using SafeMath for uint256;

    IERC1155 public erc1155Collection;

    // Address where funds are collected
    address payable private walletStoredFunds;
    address private walletStoredNFT;

    // prices in MANA by token id
    mapping(uint256 => uint256) public priceByTokenId;

    uint256 public rateMANAETH;

    uint256 public referralPercent = 25;

    address[] public referralList;

    event SoldNFT(
        address indexed _caller,
        uint256 indexed _tokenId,
        uint256 indexed _count
    );

    /**
     * @dev Constructor of the contract.
     * @param _walletStoredFunds - Address of the recipient of the funds
     * @param _walletStoredNFT - Address stored NFTs
     * @param _erc1155Collection - Address of the collection
     * @param _tokenIds - List token ids for prices
     * @param _prices - prices in MANA
     * @param _rateMANAETH - rate of MANA in WEI (1e18 = 1eth)
     */
    constructor(
        address payable _walletStoredFunds,
        address payable _walletStoredNFT,
        IERC1155 _erc1155Collection,
        uint256[] memory _tokenIds,
        uint256[] memory _prices,
        uint256 _rateMANAETH
    )
    public {
        require(_tokenIds.length == _prices.length, "length for tokenIds and prices arrays must equals");
        walletStoredFunds = _walletStoredFunds;
        walletStoredNFT = _walletStoredNFT;
        erc1155Collection = _erc1155Collection;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 id = _tokenIds[i];
            uint256 price = _prices[i];
            priceByTokenId[id] = price;
        }
        rateMANAETH = _rateMANAETH;
    }

    /**
* @dev Buy NFT for ETH
* @param _nftId - nft id
* @param _count - count
* @param _data - Data to pass if receiver is contract
* @param _referral -referral address
*/
    function buyNFTForETHWithReferral(uint256 _nftId, uint256 _count, bytes memory _data, address payable _referral) public payable {
        require(_count >= 1, "Count must more or equal 1");

        uint256 currentBalance = erc1155Collection.balanceOf(walletStoredNFT, _nftId);
        require(_count <= currentBalance, "Not enough NFTs");

        uint256 price = SafeMath.mul(priceByTokenId[_nftId], rateMANAETH);
        require(price > 0, "Price not correct");
        require(msg.value == SafeMath.mul(price, _count), "Received ETH value not correct");

        if (_referral == address(0)) {
            walletStoredFunds.transfer(msg.value);
        } else {
            bool referralRegistered = false;

            for (uint256 i = 0; i < referralList.length; i++) {
                if (_referral == referralList[i]) {
                    referralRegistered = true;
                    break;
                }
            }
            if (referralRegistered) {
                require(referralPercent < 50 || referralPercent >= 1, "referral Percent not correct");
                uint256 referralFee = SafeMath.div(SafeMath.mul(msg.value, referralPercent), 100);
                require(referralFee < msg.value, "referral Percent not correct");
                _referral.transfer(referralFee);
                walletStoredFunds.transfer(msg.value - referralFee);
            } else {
                walletStoredFunds.transfer(msg.value);
            }
        }

        erc1155Collection.safeTransferFrom(walletStoredNFT, msg.sender, _nftId, _count, _data);

        emit SoldNFT(msg.sender, _nftId, _count);
    }

    /**
    * @dev Buy NFT for ETH
    * @param _nftId - nft id
    * @param _count - count
    * @param _data -Data to pass if receiver is contract
    */
    function buyNFTForETH(uint256 _nftId, uint256 _count, bytes calldata _data) external payable {
        return buyNFTForETHWithReferral(_nftId, _count, _data, address(0));
    }

    function setPrices(
        uint256[] memory _tokenIds,
        uint256[] memory _prices
    ) public onlyOwner {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 id = _tokenIds[i];
            uint256 price = _prices[i];
            priceByTokenId[id] = price;
        }
    }

    function getPrices(uint256[] memory _tokenIds)
    public view returns (uint256[] memory prices)
    {
        prices = new uint256[](_tokenIds.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            prices[i] = priceByTokenId[_tokenIds[i]] * rateMANAETH;
        }
        return prices;
    }

    function setRate(
        uint256 _rateMANAETH
    ) public onlyOwner {
        rateMANAETH = _rateMANAETH;
    }

    function setReferralPercent(
        uint256 _val
    ) public onlyOwner {
        require(referralPercent < 50, "referral Percent not correct");
        require(referralPercent >= 1, "referral Percent not correct");
        referralPercent = _val;
    }

    function setWallet(
        address payable _wallet
    ) public onlyOwner {
        walletStoredFunds = _wallet;
    }

    function setWalletStoredNFT(
        address payable _wallet
    ) public onlyOwner {
        walletStoredNFT = _wallet;
    }

    function addReferrals(
        address[] memory _referralList
    ) public onlyOwner {
        for (uint256 i = 0; i < _referralList.length; i++) {
            referralList.push(_referralList[i]);
        }
    }
}