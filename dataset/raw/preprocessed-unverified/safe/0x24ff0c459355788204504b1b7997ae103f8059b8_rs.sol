/* Description:
 * Clearing authorizedtomint_0x35f3b5babdfe0be01c8acdaf806e400828108525 value
 */
pragma solidity ^0.7.1;

contract DFOHubGeneratedProposal {

    string private _metadataLink;

    constructor(string memory metadataLink) {
        _metadataLink = metadataLink;
    }

    function getMetadataLink() public view returns(string memory) {
        return _metadataLink;
    }

    function callOneTime(address proposal) public {
        IStateHolder holder = IStateHolder(IMVDProxy(msg.sender).getStateHolderAddress());
        holder.clear("authorizedtomint_0x35f3b5babdfe0be01c8acdaf806e400828108525");
    }
}



