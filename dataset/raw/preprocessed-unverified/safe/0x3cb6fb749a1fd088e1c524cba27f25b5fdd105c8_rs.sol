/**
 *Submitted for verification at Etherscan.io on 2020-10-05
*/

pragma solidity ^0.6.9;

//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//::::::::::: @#::::::::::: @#:::::::::::: #@j:::::::::::::::::::::::::
//::::::::::: ##::::::::::: @#:::::::::::: #@j:::::::::::::::::::::::::
//::::::::::: ##::::::::::: @#:::::::::::: #@j:::::::::::::::::::::::::
//::::: ########: ##:: jU* DUTCh>: ihD%Ky: #@Whdqy:::::::::::::::::::::
//::: ###... ###: ##:: #@j: @B... @@7...t: N@N.. R@K:::::::::::::::::::
//::: ##::::: ##: ##::.Q@t: @Q::: @Q.::::: N@j:: z@Q:::::::::::::::::::
//:::: ##DuTCH##: %@QQ@@S`: hQQQh <R@QN@Q* N@j:: z@Q:::::::::::::::::::
//::::::.......: =Q@y....:::....:::......::...:::...:::::::::::::::::::
//:::::::::::::: h@W? sWAP@! 'DW;::::::.KK. ydSWAP@t: NNKNQBdt:::::::::
//:::::::::::::: 'zqRqj*. L@R h@w: QQ: L@5 Q@z.. d@@: @@U... @Q::::::::
//:::::::::::::::::...... Q@^ ^@@N@wt@BQ@ <@Q^::: @@: @@}::: @@:::::::: 
//:::::::::::::::::: U@@QKt... D@@L...B@Q.. KDUTCH@Q: @@QQ#QQq:::::::::
//:::::::::::::::::::.....::::::...:::...::::.......: @@!.....:::::::::
//::::::::::::::::::::::::::::::::::::::::::::::::::: @@!::::::::::::::
//::::::::::::::::::::::::::::::::::::::::::::::::::: @@!::::::::::::::
//::::::::::::::01101100:01101111:01101111:01101011::::::::::::::::::::
//:::::01100100:01100101:01100101:01110000:01111001:01110010:::::::::::
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//
// DutchSwap Factory
//
// Authors:
// * Adrian Guerrera / Deepyr Pty Ltd
//
// Appropriated from BokkyPooBah's Fixed Supply Token ðŸ‘Š Factory
// https://www.ethervendingmachine.io
// Thanks Bokky!
// ----------------------------------------------------------------------------
// SPDX-License-Identifier: GPL-3.0-or-later



// SPDX-License-Identifier: UNLICENSED








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


// ----------------------------------------------------------------------------
// CloneFactory.sol
// From
// https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
// ----------------------------------------------------------------------------

/*
The MIT License (MIT)
Copyright (c) 2018 Murray Software, LLC.
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//solhint-disable max-line-length
//solhint-disable no-inline-assembly

contract CloneFactory {

  function createClone(address target) internal returns (address result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }

  function isClone(address target, address query) internal view returns (bool result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2d)
      result := and(
        eq(mload(clone), mload(other)),
        eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
      )
    }
  }
}

// ----------------------------------------------------------------------------
// White List interface
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------



contract DutchSwapFactory is  Owned, CloneFactory {
    using SafeMath for uint256;

    address public dutchAuctionTemplate;

    struct Auction {
        bool exists;
        uint256 index;
    }

    address public newAddress;
    uint256 public minimumFee = 0 ether;
    mapping(address => Auction) public isChildAuction;
    address[] public auctions;

    event DutchAuctionDeployed(address indexed owner, address indexed addr, address dutchAuction, uint256 fee);
    event AuctionRemoved(address dutchAuction, uint256 index );
    event FactoryDeprecated(address newAddress);
    event MinimumFeeUpdated(uint oldFee, uint newFee);
    event AuctionTemplateUpdated(address oldDutchAuction, address newDutchAuction );

    function initDutchSwapFactory( address _dutchAuctionTemplate, uint256 _minimumFee) public  {
        _initOwned(msg.sender);
        dutchAuctionTemplate = _dutchAuctionTemplate;
        minimumFee = _minimumFee;
    }

    function numberOfAuctions() public view returns (uint) {
        return auctions.length;
    }
    function removeFinalisedAuction(address _auction) public  {
        require(isChildAuction[_auction].exists);
        bool finalised = IDutchAuction(_auction).auctionEnded();
        require(finalised);
        uint removeIndex = isChildAuction[_auction].index;
        emit AuctionRemoved(_auction, auctions.length - 1);
        uint lastIndex = auctions.length - 1;
        address lastIndexAddress = auctions[lastIndex];
        auctions[removeIndex] = lastIndexAddress;
        isChildAuction[lastIndexAddress].index = removeIndex;
        if (auctions.length > 0) {
            auctions.pop();
        }
    }

    function deprecateFactory(address _newAddress) public  {
        require(isOwner());
        require(newAddress == address(0));
        emit FactoryDeprecated(_newAddress);
        newAddress = _newAddress;
    }
    function setMinimumFee(uint256 _minimumFee) public  {
        require(isOwner());
        emit MinimumFeeUpdated(minimumFee, _minimumFee);
        minimumFee = _minimumFee;
    }

    function setDutchAuctionTemplate( address _dutchAuctionTemplate) public  {
        require(isOwner());
        emit AuctionTemplateUpdated(dutchAuctionTemplate, _dutchAuctionTemplate);
        dutchAuctionTemplate = _dutchAuctionTemplate;
    }

    function deployDutchAuction(
        address _token, 
        uint256 _tokenSupply, 
        uint256 _startDate, 
        uint256 _endDate, 
        address _paymentCurrency,
        uint256 _startPrice, 
        uint256 _minimumPrice, 
        address payable _wallet
    )
        public payable returns (address dutchAuction)
    {
        dutchAuction = createClone(dutchAuctionTemplate);
        isChildAuction[address(dutchAuction)] = Auction(true, auctions.length - 1);
        auctions.push(address(dutchAuction));
        require(IERC20(_token).transferFrom(msg.sender, address(this), _tokenSupply)); 
        require(IERC20(_token).approve(dutchAuction, _tokenSupply));
        IDutchAuction(dutchAuction).initDutchAuction(address(this), _token,_tokenSupply,_startDate,_endDate,_paymentCurrency,_startPrice,_minimumPrice,_wallet);
        emit DutchAuctionDeployed(msg.sender, address(dutchAuction), dutchAuctionTemplate, msg.value);
    }

    // footer functions
    function transferAnyERC20Token(address tokenAddress, uint256 tokens) public returns (bool success) {
        require(isOwner());
        return IERC20(tokenAddress).transfer(owner(), tokens);
    }
    receive () external payable {
        revert();
    }
}