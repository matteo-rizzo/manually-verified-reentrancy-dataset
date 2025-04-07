/**

 *Submitted for verification at Etherscan.io on 2019-04-17

*/



pragma solidity 0.5.0;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title StateDrivenHashStore

 * @dev The contract has his state and getters

 */

contract HashStore is Ownable {

    mapping(bytes32 => uint256) private _hashes;

    event HashAdded(bytes32 hash);



    function addHash(bytes32 rootHash) external onlyOwner {

        require(_hashes[rootHash] == 0, "addHash: this hash was already deployed");



        _hashes[rootHash] = block.timestamp;

        emit HashAdded(rootHash);

    }



    function getHashTimestamp(bytes32 rootHash) external view returns (uint256) {

        return _hashes[rootHash];

    }

}