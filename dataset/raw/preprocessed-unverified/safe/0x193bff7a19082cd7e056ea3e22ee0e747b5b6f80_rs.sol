/**
 *Submitted for verification at Etherscan.io on 2019-09-12
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-12
*/

pragma solidity 0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */





contract SlotMachine is Ownable {
    event LogDeposit(address indexed depositor, uint256 value);
    
    function withdraw(uint amount) external onlyOwner {
        require(amount != 0, "Withdraw amount can't be zero");
        require(address(this).balance >= amount, "Withdraw amount can't be more than contract balance.");

        msg.sender.transfer(amount);
    }

    // Fallback function
    function () external payable {
        emit LogDeposit(msg.sender, msg.value);
    }
}

contract SlotMachineSpinner is SlotMachine {
    using SafeMath for uint256;

    address private webAddress = 0x72cc1C4dE56D1cB8c1c35161798Ca289EA150741;
    uint public minimumWager = 0.001 ether;
    uint public maximumWager = 0.1 ether;
    uint8 public maximumMultiplier = 60;

    uint[6] private firstSlotProbabilities = [uint(385), 1538, 4231, 6154, 8077, 10000];
    uint[6] private secondSlotProbabilities = [uint(400), 800, 2800, 5200, 7600, 10000];
    uint[6] private thirdSlotProbabilities = [uint(400), 800, 2800, 5200, 7600, 10000];

    event LogSpinResult(
        address indexed spinner, 
        uint256 wager, 
        bool isWin, 
        string firstSymbol, 
        string secondSymbol, 
        string thirdSymbol, 
        uint8 multiplier, 
        uint256 rewardAmount
    );

    modifier mustSignWithECDSA(bytes32 hash, uint8 _v, bytes32 _r, bytes32 _s) {
        require(ecrecover(hash, _v, _r, _s) == webAddress, "public key & private key mismatch");
        _;
    }

    // External function
    function spin(bytes32 hash, uint8 _v, bytes32 _r, bytes32 _s)
        external
        payable
        mustSignWithECDSA(hash, _v, _r, _s)
    {
        // Conditions
        require(msg.value >= minimumWager, "wager must be greater than or equal minimumWager.");
        require(msg.value <= maximumWager, "wager must be lower than or equal maximumWager.");
        require(
            address(this).balance >= msg.value * maximumMultiplier, 
            "contract balance must greater than wager * maximumMultiplier."
        );
        require(msg.sender == tx.origin, 'only EOA can call this contract');

        
        //Interaction
        string memory firstSymbol;
        string memory secondSymbol;
        string memory thirdSymbol;
        uint rewardAmount = 0;
        uint8 multiplier = 0;
        uint8 cherryCount = 0;
        bool isWin = false;

        (firstSymbol, secondSymbol, thirdSymbol) = _findThreeSymbols(_s);
        
        if (_isWin(firstSymbol, secondSymbol, thirdSymbol)) {
            // Normal win
            isWin = true;
            (rewardAmount, multiplier) = _calculateRewardAmount(msg.value, firstSymbol);
            _sendReward(rewardAmount);
        } else {
            cherryCount = _countCherry(firstSymbol, secondSymbol, thirdSymbol);
            if (cherryCount > 0) {
                // Cherry win
                isWin = true;
                (rewardAmount, multiplier) = _calculateRewardAmountForCherry(msg.value, cherryCount);
                _sendCherryReward(rewardAmount);
            }
        }

        emit LogSpinResult(msg.sender, msg.value, isWin, firstSymbol, secondSymbol, thirdSymbol, multiplier, rewardAmount);
    }

    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }

    // Private function
    function _calculateRewardAmount(uint256 wager, string symbol) private pure returns (uint256, uint8) {
        uint8 multiplier = _findMultiplier(symbol);
        uint256 rewardAmount = wager.mul(multiplier);

        return (rewardAmount, multiplier);
    }

    function _calculateRewardAmountForCherry(uint256 wager, uint8 cherryCount) private pure returns (uint256, uint8) {
        uint8 multiplier = _findCherryMultiplier(cherryCount);
        uint256 rewardAmount = wager.mul(multiplier);

        return (rewardAmount, multiplier);
    }

    function _sendReward(uint256 rewardAmount) private {
        require(address(this).balance >= rewardAmount, "Contract not have enough balance to payout. [Normal]");

        msg.sender.transfer(rewardAmount);
    }

    function _sendCherryReward(uint256 rewardAmount) private {
        require(address(this).balance >= rewardAmount, "Contract not have enough balance to payout. [Cherry]");

        msg.sender.transfer(rewardAmount);
    }

    function _generateRandomNumber(bytes32 signature) private pure returns (uint, uint, uint) {
        uint modulus = 10001;
        uint firstRandomNumber = uint(signature) % modulus;
        uint secondRandomNumber = (uint(signature) / 10000) % modulus;
        uint thirdRandomNumber = (uint(signature) / 1000000) % modulus;

        return (firstRandomNumber, secondRandomNumber, thirdRandomNumber);
    }

    function _findSymbolInSlot(uint randomNumber, uint[6] probabilities) private pure returns (string) {
        if (randomNumber <= probabilities[0]) {
            return "bar";
        }

        if (randomNumber <= probabilities[1]) {
            return "seven";
        }

        if (randomNumber <= probabilities[2]) {
            return "cherry";
        }

        if (randomNumber <= probabilities[3]) {
            return "orange";
        }

        if (randomNumber <= probabilities[4]) {
            return "grape";
        }

        if (randomNumber <= probabilities[5]) {
            return "bell";
        }
    }
    
    function _findThreeSymbols(bytes32 _s) private view returns (string, string, string) {
        uint firstRandomNumber;
        uint secondRandomNumber;
        uint thirdRandomNumber;
        
        bytes32 entropy = _combineEntropy(_s);
        
        (firstRandomNumber, secondRandomNumber, thirdRandomNumber) = _generateRandomNumber(entropy);

        string memory firstSymbol = _findSymbolInSlot(firstRandomNumber, firstSlotProbabilities);
        string memory secondSymbol = _findSymbolInSlot(secondRandomNumber, secondSlotProbabilities);
        string memory thirdSymbol = _findSymbolInSlot(thirdRandomNumber, thirdSlotProbabilities);

        return (firstSymbol, secondSymbol, thirdSymbol);
    }


    function _combineEntropy(bytes32 _s) private view returns (bytes32) {
        bytes32 entropy = keccak256(
            abi.encodePacked(
                _s,
                block.timestamp, 
                block.number, 
                blockhash(block.number - 1), 
                block.difficulty, 
                block.gaslimit, 
                gasleft(),
                tx.gasprice,
                msg.sender
            )
        );
        return entropy;
    }

    function _findMultiplier(string symbol) private pure returns (uint8) {
        if (_compareString(symbol, "bar")) {
            return 60;
        }

        if (_compareString(symbol, "seven")) {
            return 40;
        }

        if (_compareString(symbol, "cherry")) {
            return 20;
        }

        if (_compareString(symbol, "orange")) {
            return 5;
        }

        if (_compareString(symbol, "grape")) {
            return 5;
        }

        if (_compareString(symbol, "bell")) {
            return 5;
        }
    }

    function _findCherryMultiplier(uint8 cherryCount) private pure returns (uint8) {
        if (cherryCount == 1) {
            return 1;    
        }

        if (cherryCount == 2) {
            return 3;
        }
    }

    function _compareString(string first, string second) private pure returns (bool) {
        return keccak256(abi.encodePacked(first)) == keccak256(abi.encodePacked(second));
    }

    function _isCherry(string symbol) private pure returns (bool) {
        return _compareString(symbol, "cherry");
    }

    function _isWin(string firstSymbol, string secondSymbol, string thirdSymbol) private pure returns (bool) {
        return (_compareString(firstSymbol, secondSymbol) && _compareString(firstSymbol, thirdSymbol));
    }

    function _countCherry(string firstSymbol, string secondSymbol, string thirdSymbol) private pure returns (uint8) {
        uint8 cherryCount = 0;
        
        if (_isCherry(firstSymbol)) {
            cherryCount++;
        }

        if (_isCherry(secondSymbol)) {
            cherryCount++;
        }

        if (_isCherry(thirdSymbol)) {
            cherryCount++;
        }
        
        return cherryCount;
    }
}