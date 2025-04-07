/**
 *Submitted for verification at Etherscan.io on 2021-09-10
*/

/*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Synthetix: SynthRedeemer.sol
*
* Latest source (may be newer): https://github.com/Synthetixio/synthetix/blob/master/contracts/SynthRedeemer.sol
* Docs: https://docs.synthetix.io/contracts/SynthRedeemer
*
* Contract Dependencies: 
*	- IAddressResolver
*	- ISynthRedeemer
*	- MixinResolver
*	- Owned
* Libraries: 
*	- SafeDecimalMath
*	- SafeMath
*
* MIT License
* ===========
*
* Copyright (c) 2021 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/



pragma solidity ^0.5.16;

// https://docs.synthetix.io/contracts/source/contracts/owned



// https://docs.synthetix.io/contracts/source/interfaces/iaddressresolver



// https://docs.synthetix.io/contracts/source/interfaces/isynth



// https://docs.synthetix.io/contracts/source/interfaces/iissuer



// Inheritance


// Internal references


// https://docs.synthetix.io/contracts/source/contracts/addressresolver
contract AddressResolver is Owned, IAddressResolver {
    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}

    /* ========== RESTRICTED FUNCTIONS ========== */

    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {
        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            bytes32 name = names[i];
            address destination = destinations[i];
            repository[name] = destination;
            emit AddressImported(name, destination);
        }
    }

    /* ========= PUBLIC FUNCTIONS ========== */

    function rebuildCaches(MixinResolver[] calldata destinations) external {
        for (uint i = 0; i < destinations.length; i++) {
            destinations[i].rebuildCache();
        }
    }

    /* ========== VIEWS ========== */

    function areAddressesImported(bytes32[] calldata names, address[] calldata destinations) external view returns (bool) {
        for (uint i = 0; i < names.length; i++) {
            if (repository[names[i]] != destinations[i]) {
                return false;
            }
        }
        return true;
    }

    function getAddress(bytes32 name) external view returns (address) {
        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address) {
        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    function getSynth(bytes32 key) external view returns (address) {
        IIssuer issuer = IIssuer(repository["Issuer"]);
        require(address(issuer) != address(0), "Cannot find Issuer address");
        return address(issuer.synths(key));
    }

    /* ========== EVENTS ========== */

    event AddressImported(bytes32 name, address destination);
}


// Internal references


// https://docs.synthetix.io/contracts/source/contracts/mixinresolver
contract MixinResolver {
    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    constructor(address _resolver) internal {
        resolver = AddressResolver(_resolver);
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function combineArrays(bytes32[] memory first, bytes32[] memory second)
        internal
        pure
        returns (bytes32[] memory combination)
    {
        combination = new bytes32[](first.length + second.length);

        for (uint i = 0; i < first.length; i++) {
            combination[i] = first[i];
        }

        for (uint j = 0; j < second.length; j++) {
            combination[first.length + j] = second[j];
        }
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    // Note: this function is public not external in order for it to be overridden and invoked via super in subclasses
    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {}

    function rebuildCache() public {
        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        // The resolver must call this function whenver it updates its state
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            // Note: can only be invoked once the resolver has all the targets needed added
            address destination =
                resolver.requireAndGetAddress(name, string(abi.encodePacked("Resolver missing target: ", name)));
            addressCache[name] = destination;
            emit CacheUpdated(name, destination);
        }
    }

    /* ========== VIEWS ========== */

    function isResolverCached() external view returns (bool) {
        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            // false if our cache is invalid or if the resolver doesn't have the required address
            if (resolver.getAddress(name) != addressCache[name] || addressCache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function requireAndGetAddress(bytes32 name) internal view returns (address) {
        address _foundAddress = addressCache[name];
        require(_foundAddress != address(0), string(abi.encodePacked("Missing address: ", name)));
        return _foundAddress;
    }

    /* ========== EVENTS ========== */

    event CacheUpdated(bytes32 name, address destination);
}


// https://docs.synthetix.io/contracts/source/interfaces/ierc20






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



// Libraries


// https://docs.synthetix.io/contracts/source/libraries/safedecimalmath



// Inheritence


// Libraries


// Internal references


contract SynthRedeemer is ISynthRedeemer, MixinResolver {
    using SafeDecimalMath for uint;

    bytes32 public constant CONTRACT_NAME = "SynthRedeemer";

    mapping(address => uint) public redemptions;

    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_SYNTHSUSD = "SynthsUSD";

    constructor(address _resolver) public MixinResolver(_resolver) {}

    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {
        addresses = new bytes32[](2);
        addresses[0] = CONTRACT_ISSUER;
        addresses[1] = CONTRACT_SYNTHSUSD;
    }

    function issuer() internal view returns (IIssuer) {
        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER));
    }

    function sUSD() internal view returns (IERC20) {
        return IERC20(requireAndGetAddress(CONTRACT_SYNTHSUSD));
    }

    function totalSupply(IERC20 synthProxy) public view returns (uint supplyInsUSD) {
        supplyInsUSD = synthProxy.totalSupply().multiplyDecimal(redemptions[address(synthProxy)]);
    }

    function balanceOf(IERC20 synthProxy, address account) external view returns (uint balanceInsUSD) {
        balanceInsUSD = synthProxy.balanceOf(account).multiplyDecimal(redemptions[address(synthProxy)]);
    }

    function redeemAll(IERC20[] calldata synthProxies) external {
        for (uint i = 0; i < synthProxies.length; i++) {
            _redeem(synthProxies[i], synthProxies[i].balanceOf(msg.sender));
        }
    }

    function redeem(IERC20 synthProxy) external {
        _redeem(synthProxy, synthProxy.balanceOf(msg.sender));
    }

    function redeemPartial(IERC20 synthProxy, uint amountOfSynth) external {
        // technically this check isn't necessary - Synth.burn would fail due to safe sub,
        // but this is a useful error message to the user
        require(synthProxy.balanceOf(msg.sender) >= amountOfSynth, "Insufficient balance");
        _redeem(synthProxy, amountOfSynth);
    }

    function _redeem(IERC20 synthProxy, uint amountOfSynth) internal {
        uint rateToRedeem = redemptions[address(synthProxy)];
        require(rateToRedeem > 0, "Synth not redeemable");
        require(amountOfSynth > 0, "No balance of synth to redeem");
        issuer().burnForRedemption(address(synthProxy), msg.sender, amountOfSynth);
        uint amountInsUSD = amountOfSynth.multiplyDecimal(rateToRedeem);
        sUSD().transfer(msg.sender, amountInsUSD);
        emit SynthRedeemed(address(synthProxy), msg.sender, amountOfSynth, amountInsUSD);
    }

    function deprecate(IERC20 synthProxy, uint rateToRedeem) external onlyIssuer {
        address synthProxyAddress = address(synthProxy);
        require(redemptions[synthProxyAddress] == 0, "Synth is already deprecated");
        require(rateToRedeem > 0, "No rate for synth to redeem");
        uint totalSynthSupply = synthProxy.totalSupply();
        uint supplyInsUSD = totalSynthSupply.multiplyDecimal(rateToRedeem);
        require(sUSD().balanceOf(address(this)) >= supplyInsUSD, "sUSD must first be supplied");
        redemptions[synthProxyAddress] = rateToRedeem;
        emit SynthDeprecated(address(synthProxy), rateToRedeem, totalSynthSupply, supplyInsUSD);
    }

    function requireOnlyIssuer() internal view {
        require(msg.sender == address(issuer()), "Restricted to Issuer contract");
    }

    modifier onlyIssuer() {
        requireOnlyIssuer();
        _;
    }

    event SynthRedeemed(address synth, address account, uint amountOfSynth, uint amountInsUSD);
    event SynthDeprecated(address synth, uint rateToRedeem, uint totalSynthSupply, uint supplyInsUSD);
}