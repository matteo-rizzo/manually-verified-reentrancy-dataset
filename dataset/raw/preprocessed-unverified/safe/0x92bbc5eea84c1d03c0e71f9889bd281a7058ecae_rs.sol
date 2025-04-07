/**

 *Submitted for verification at Etherscan.io on 2019-05-20

*/



pragma solidity ^0.5.8;







contract ChannelWallet is Ownable

{

    mapping(string => address) private addressMap;



    event SetAddress(string channelId, address _address);

    event UpdateAddress(string from, string to);

    event DeleteAddress(string account);



    function version() external pure returns(string memory)

    {

        return '0.0.1';

    }



    function getAddress(string calldata channelId) external view returns (address)

    {

        return addressMap[channelId];

    }



    function setAddress(string calldata channelId, address _address) external onlyMaster onlyWhenNotStopped

    {

        require(bytes(channelId).length > 0);



        addressMap[channelId] = _address;



        emit SetAddress(channelId, _address);

    }



    function updateChannel(string calldata from, string calldata to, address _address) external onlyMaster onlyWhenNotStopped

    {

        require(bytes(from).length > 0);

        require(bytes(to).length > 0);

        require(addressMap[to] == address(0));



        addressMap[to] = _address;



        addressMap[from] = address(0);



        emit UpdateAddress(from, to);

    }



    function deleteChannel(string calldata channelId) external onlyMaster onlyWhenNotStopped

    {

        require(bytes(channelId).length > 0);



        addressMap[channelId] = address(0);



        emit DeleteAddress(channelId);

    }

}