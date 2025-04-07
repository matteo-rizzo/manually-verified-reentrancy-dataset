/**
 *Submitted for verification at Etherscan.io on 2020-07-14
*/

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;





contract Helpers {

    struct CompData {
        uint balanceOfUser;
        uint borrowBalanceStoredUser;
    }
    struct data {
        address user;
        CompData[] tokensData;
    }
}


contract Resolver is Helpers {
    
    function getDSAWallets(uint len) public view returns(address[] memory) {
        address[] memory wallets = new address[](len);
        for (uint i = 0; i < len; i++) {
            ListInterface list = ListInterface(0x4c8a1BEb8a87765788946D6B19C6C6355194AbEb);
            wallets[i] = list.accountAddr(uint64(i+1));
        }
        return wallets;
    }

    function getCompoundData(address owner, address[] memory cAddress) public view returns (CompData[] memory) {
        CompData[] memory tokensData = new CompData[](cAddress.length);
        for (uint i = 0; i < cAddress.length; i++) {
            CTokenInterface cToken = CTokenInterface(cAddress[i]);
            tokensData[i] = CompData(
                cToken.balanceOf(owner),
                cToken.borrowBalanceStored(owner)
            );
        }

        return tokensData;
    }

    function getPosition(
        address[] memory owners,
        address[] memory cAddress
    )
        public
        view
        returns (data[] memory)
    {
        data[] memory datas = new data[](owners.length);
        for (uint i = 0; i < cAddress.length; i++) {
            datas[i] = data(
                owners[i],
                getCompoundData(owners[i], cAddress)
            );
        }
        return datas;
    }

}