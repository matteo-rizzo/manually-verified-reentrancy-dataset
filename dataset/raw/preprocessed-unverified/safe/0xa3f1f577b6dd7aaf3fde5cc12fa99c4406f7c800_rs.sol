pragma solidity 0.4.18;

// File: contracts/wrapperContracts/KyberRegisterWallet.sol




contract KyberRegisterWallet {

    BurnerWrapperProxy public feeBurnerWrapperProxyContract;

    function KyberRegisterWallet(BurnerWrapperProxy feeBurnerWrapperProxy) public {
        require(feeBurnerWrapperProxy != address(0));

        feeBurnerWrapperProxyContract = feeBurnerWrapperProxy;
    }

    function registerWallet(address wallet) public {
        feeBurnerWrapperProxyContract.registerWallet(wallet);
    }
}