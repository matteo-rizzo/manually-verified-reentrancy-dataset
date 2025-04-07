/**

 *Submitted for verification at Etherscan.io on 2019-05-20

*/



pragma solidity ^0.5.8;







contract AccountWallet is Ownable

{

    mapping(string => string) private btc;

    mapping(string => address) private eth;



    event SetAddress(string account, string btcAddress, address ethAddress);

    event UpdateAddress(string from, string to);

    event DeleteAddress(string account);



    function version() external pure returns(string memory)

    {

        return '1.0.0';

    }



    function getAddress(string calldata account) external view returns (string memory, address)

    {

        return (btc[account], eth[account]);

    }



    function setAddress(string calldata account, string calldata btcAddress, address ethAddress) external onlyMaster onlyWhenNotStopped

    {

        require(bytes(account).length > 0);



        btc[account] = btcAddress;

        eth[account] = ethAddress;



        emit SetAddress(account, btcAddress, ethAddress);

    }



    function updateAccount(string calldata from, string calldata to) external onlyMaster onlyWhenNotStopped

    {

        require(bytes(from).length > 0);

        require(bytes(to).length > 0);



        btc[to] = btc[from];

        eth[to] = eth[from];



        btc[from] = '';

        eth[from] = address(0);



        emit UpdateAddress(from, to);

    }



    function deleteAccount(string calldata account) external onlyMaster onlyWhenNotStopped

    {

        require(bytes(account).length > 0);



        btc[account] = '';

        eth[account] = address(0);



        emit DeleteAddress(account);

    }

}