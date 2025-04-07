/**
 *Submitted for verification at Etherscan.io on 2020-11-09
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.6.12;








/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */


contract WSController is Ownable, IWSController {
    address public pairLogic;
    address public currentAdmin;

    /*
    * @dev Type variable:
    * 2 - Pair
    */
    uint256 constant public PAIR_TYPE = 2;

    event NewPairLogic(address indexed logic);
    event NewAdmin(address indexed adminAddress);
    event UpdateProxy(address indexed proxyAddress, address newLogic);
    event ChangeAdmin(address indexed proxyAddress, address newAdmin);

    constructor(address _pairLogic) public {
        require(_pairLogic != address(0), "WSController: Wrong pair logic address");
        currentAdmin = address(this);
        pairLogic = _pairLogic;
    }


    function updatePairLogic(address _logic) external override onlyOwner {
        pairLogic = _logic;
        emit NewPairLogic(_logic);
    }

    function updateCurrentAdmin(address _newAdmin) external override onlyOwner {
        currentAdmin = _newAdmin;
        emit NewAdmin(_newAdmin);
    }

    function updateProxyPair(address _proxy) external override {
        require(IWSImplementation(IWSProxy(_proxy).implementation()).getImplementationType() == PAIR_TYPE, "WSController: Wrong pair proxy for update.");
        IWSProxy(_proxy).upgradeTo(pairLogic);
        emit UpdateProxy(_proxy, pairLogic);
    }

    function setAdminForProxy(address _proxy) external override {
        IWSProxy(_proxy).changeAdmin(currentAdmin);
        emit ChangeAdmin(_proxy, currentAdmin);
    }

    function getLogicForPair() external view override returns(address) {
        return pairLogic;
    }

    function getCurrentAdmin() external view override returns(address){
        return currentAdmin;
    }

}