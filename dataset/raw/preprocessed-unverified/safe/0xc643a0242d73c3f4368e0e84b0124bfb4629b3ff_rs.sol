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



contract Random {

    function random(uint256) external view returns (uint256) {}

    function randomOfBlock(uint256, uint256) external view returns (uint256) {}

}









//////////////CONTRACT//////////////









contract Nest is Upgradable {

    using SafeMath8 for uint8;

    using SafeMath256 for uint256;



    Random random;



    uint256[2] eggs;

    uint256 lastBlockNumber;



    bool isFull;



    mapping (uint256 => bool) public inNest;



    function add(

        uint256 _id

    ) external onlyController returns (

        bool isHatched,

        uint256 hatchedId,

        uint256 randomForEggOpening

    ) {

        require(!inNest[_id], "egg is already in nest");

        require(block.number > lastBlockNumber, "only 1 egg in a block");



        lastBlockNumber = block.number;

        inNest[_id] = true;



        // if amount of egg = 3, then hatch one

        if (isFull) {

            isHatched = true;

            hatchedId = eggs[0];

            randomForEggOpening = random.random(2**256 - 1);

            eggs[0] = eggs[1];

            eggs[1] = _id;

            delete inNest[hatchedId];

        } else {

            uint8 _index = eggs[0] == 0 ? 0 : 1;

            eggs[_index] = _id;

            if (_index == 1) {

                isFull = true;

            }

        }

    }



    // GETTERS



    function getEggs() external view returns (uint256[2]) {

        return eggs;

    }



    // UPDATE CONTRACT



    function setInternalDependencies(address[] _newDependencies) public onlyOwner {

        super.setInternalDependencies(_newDependencies);



        random = Random(_newDependencies[0]);

    }

}