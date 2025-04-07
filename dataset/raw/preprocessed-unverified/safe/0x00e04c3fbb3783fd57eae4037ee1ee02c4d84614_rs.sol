/**

 *Submitted for verification at Etherscan.io on 2018-11-29

*/



pragma solidity 0.4.25;















contract Controllable is Ownable {

    mapping(address => bool) controllers;



    modifier onlyController {

        require(_isController(msg.sender), "no controller rights");

        _;

    }



    function _isController(address _controller) internal view returns (bool) {

        return controllers[_controller];

    }



    function _setControllers(address[] _controllers) internal {

        for (uint256 i = 0; i < _controllers.length; i++) {

            _validateAddress(_controllers[i]);

            controllers[_controllers[i]] = true;

        }

    }

}



contract Upgradable is Controllable {

    address[] internalDependencies;

    address[] externalDependencies;



    function getInternalDependencies() public view returns(address[]) {

        return internalDependencies;

    }



    function getExternalDependencies() public view returns(address[]) {

        return externalDependencies;

    }



    function setInternalDependencies(address[] _newDependencies) public onlyOwner {

        for (uint256 i = 0; i < _newDependencies.length; i++) {

            _validateAddress(_newDependencies[i]);

        }

        internalDependencies = _newDependencies;

    }



    function setExternalDependencies(address[] _newDependencies) public onlyOwner {

        externalDependencies = _newDependencies;

        _setControllers(_newDependencies);

    }

}









//////////////CONTRACT//////////////









contract Random is Upgradable {

    using SafeMath256 for uint256;

    using SafeConvert for uint256;



    function _safeSub(uint256 a, uint256 b) internal pure returns (uint256) {

        return b > a ? 0 : a.sub(b);

    }



    modifier validBlock(uint256 _blockNumber) {

        require(

            _blockNumber < block.number &&

            _blockNumber >= _safeSub(block.number, 256),

            "not valid block number"

        );

        _;

    }



    function getRandom(

        uint256 _upper,

        uint256 _blockNumber

    ) internal view validBlock(_blockNumber) returns (uint256) {

        bytes32 _hash = keccak256(abi.encodePacked(blockhash(_blockNumber), now));

        return uint256(_hash) % _upper;

    }



    function random(uint256 _upper) external view returns (uint256) {

        return getRandom(_upper, block.number.sub(1));

    }



    function randomOfBlock(

        uint256 _upper,

        uint256 _blockNumber

    ) external view returns (uint256) {

        return getRandom(_upper, _blockNumber);

    }

}