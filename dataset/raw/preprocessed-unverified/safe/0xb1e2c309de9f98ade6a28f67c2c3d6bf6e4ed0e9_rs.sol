/**
 *Submitted for verification at Etherscan.io on 2021-06-07
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;  
pragma experimental ABIEncoderV2;



abstract contract IDSProxy {
    // function execute(bytes memory _code, bytes memory _data)
    //     public
    //     payable
    //     virtual
    //     returns (address, bytes32);

    function execute(address _target, bytes memory _data) public payable virtual returns (bytes32);

    function setCache(address _cacheAddr) public payable virtual returns (bool);

    function owner() public view virtual returns (address);
}  



abstract contract DSGuard {
    function canCall(
        address src_,
        address dst_,
        bytes4 sig
    ) public view virtual returns (bool);

    function permit(
        bytes32 src,
        bytes32 dst,
        bytes32 sig
    ) public virtual;

    function forbid(
        bytes32 src,
        bytes32 dst,
        bytes32 sig
    ) public virtual;

    function permit(
        address src,
        address dst,
        bytes32 sig
    ) public virtual;

    function forbid(
        address src,
        address dst,
        bytes32 sig
    ) public virtual;
}

abstract contract DSGuardFactory {
    function newGuard() public virtual returns (DSGuard guard);
}  



abstract contract DSAuthority {
    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) public view virtual returns (bool);
}  





contract DSAuthEvents {
    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority public authority;
    address public owner;

    constructor() {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public auth {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_) public auth {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "Not authorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}  



abstract contract IDFSRegistry {
 
    function getAddr(bytes32 _id) public view virtual returns (address);

    function addNewContract(
        bytes32 _id,
        address _contractAddr,
        uint256 _waitPeriod
    ) public virtual;

    function startContractChange(bytes32 _id, address _newContractAddr) public virtual;

    function approveContractChange(bytes32 _id) public virtual;

    function cancelContractChange(bytes32 _id) public virtual;

    function changeWaitPeriod(bytes32 _id, uint256 _newWaitPeriod) public virtual;
}  



  



  



  







  



/// @title A stateful contract that holds and can change owner/admin
contract AdminVault {
    address public owner;
    address public admin;

    constructor() {
        owner = msg.sender;
        admin = 0x25eFA336886C74eA8E282ac466BdCd0199f85BB9;
    }

    /// @notice Admin is able to change owner
    /// @param _owner Address of new owner
    function changeOwner(address _owner) public {
        require(admin == msg.sender, "msg.sender not admin");
        owner = _owner;
    }

    /// @notice Admin is able to set new admin
    /// @param _admin Address of multisig that becomes new admin
    function changeAdmin(address _admin) public {
        require(admin == msg.sender, "msg.sender not admin");
        admin = _admin;
    }

}  








/// @title AdminAuth Handles owner/admin privileges over smart contracts
contract AdminAuth {
    using SafeERC20 for IERC20;

    address public constant ADMIN_VAULT_ADDR = 0xCCf3d848e08b94478Ed8f46fFead3008faF581fD;

    AdminVault public constant adminVault = AdminVault(ADMIN_VAULT_ADDR);

    modifier onlyOwner() {
        require(adminVault.owner() == msg.sender, "msg.sender not owner");
        _;
    }

    modifier onlyAdmin() {
        require(adminVault.admin() == msg.sender, "msg.sender not admin");
        _;
    }

    /// @notice withdraw stuck funds
    function withdrawStuckFunds(address _token, address _receiver, uint256 _amount) public onlyOwner {
        if (_token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(_receiver).transfer(_amount);
        } else {
            IERC20(_token).safeTransfer(_receiver, _amount);
        }
    }

    /// @notice Destroy the contract
    function kill() public onlyAdmin {
        selfdestruct(payable(msg.sender));
    }
}  



abstract contract IProxyRegistry {
    function proxies(address _owner) public virtual view returns (address);
    function build(address) public virtual returns (address);
}  







/// @title Checks Mcd registry and replaces the proxy addr if owner changed
contract DFSProxyRegistry is AdminAuth {
    IProxyRegistry public mcdRegistry = IProxyRegistry(0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4);

    mapping(address => address) public changedOwners;
    mapping(address => address[]) public additionalProxies;

    /// @notice Changes the proxy that is returned for the user
    /// @dev Used when the user changed DSProxy ownership himself
    function changeMcdOwner(address _user, address _proxy) public onlyOwner {
        if (IDSProxy(_proxy).owner() == _user) {
            changedOwners[_user] = _proxy;
        }
    }

    /// @notice Returns the proxy address associated with the user account
    /// @dev If user changed ownership of DSProxy admin can hardcode replacement
    function getMcdProxy(address _user) public view returns (address) {
        address proxyAddr = mcdRegistry.proxies(_user);

        // if check changed proxies
        if (changedOwners[_user] != address(0)) {
            return changedOwners[_user];
        }

        return proxyAddr;
    }

    function addAdditionalProxy(address _user, address _proxy) public onlyOwner {
        if (IDSProxy(_proxy).owner() == _user) {
            additionalProxies[_user].push(_proxy);
        }
    }
			
    function getAllProxies(address _user) public view returns (address, address[] memory) {
        return (getMcdProxy(_user), additionalProxies[_user]);
    }
}  







contract DSProxyView {
    DFSProxyRegistry registry = DFSProxyRegistry(0x29474FdaC7142f9aB7773B8e38264FA15E3805ed);

    struct ProxyData {
        address proxy;
        bool correctDSGuardOwner;
        bool isUserOwner;
    }

    function checkDSGuardOwner(address _proxy) public view returns (bool) {
        if (_proxy == address(0)) return false;

        address currAuthority = address(DSAuth(_proxy).authority());

        return DSAuth(currAuthority).owner() == _proxy;
    }

    function isUserProxyOwner(address _user, address _proxy) public view returns (bool) {
        return IDSProxy(_proxy).owner() == _user;
    }

    function getProxiesAndCheckDSGuard(address _user)
        public
        view
        returns (ProxyData[] memory proxies)
    {
        (address mcdProxy, address[] memory otherProxies) = registry.getAllProxies(_user);

        proxies = new ProxyData[](otherProxies.length + 1);

        proxies[0] = ProxyData({
            proxy: mcdProxy,
            correctDSGuardOwner: checkDSGuardOwner(mcdProxy),
            isUserOwner: isUserProxyOwner(_user, mcdProxy)
        });

        for (uint256 i = 0; i < otherProxies.length; ++i) {
            proxies[i + 1] = ProxyData({
                proxy: otherProxies[i],
                correctDSGuardOwner: checkDSGuardOwner(otherProxies[i]),
                isUserOwner: isUserProxyOwner(_user, otherProxies[i])
            });
        }
    }
}