pragma solidity ^0.4.21;



// File: contracts/ExchangeHandler.sol



/// @title Interface for all exchange handler contracts





// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract Token is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */











contract BancorHandler is ExchangeHandler, Ownable {

    address public totlePrimary;

    uint256 constant MAX_UINT = 2**256 - 1;



    modifier onlyTotle() {

        require(msg.sender == totlePrimary);

        _;

    }



    function BancorHandler(

        address _totlePrimary

    ) public {

        require(_totlePrimary != address(0x0));

        totlePrimary = _totlePrimary;

    }



    // Public functions

    function getAvailableAmount(

        address[8] orderAddresses, // [converterAddress, conversionPath ... ]

        uint256[6] orderValues, // [amountToGive, minReturn, EMPTY, EMPTY, EMPTY, EMPTY]

        uint256 exchangeFee, // ignore

        uint8 v, // ignore

        bytes32 r, // ignore

        bytes32 s // ignore

    ) external returns (uint256) {

        // Return amountToGive

        return orderValues[0];

    }



    function performBuy(

        address[8] orderAddresses, // [converterAddress, conversionPath ... ]

        uint256[6] orderValues, // [amountToGive, minReturn, EMPTY, EMPTY, EMPTY, EMPTY]

        uint256 exchangeFee, // ignore

        uint256 amountToFill, // ignore

        uint8 v, // ignore

        bytes32 r, // ignore

        bytes32 s // ignore

    ) external payable onlyTotle returns (uint256 amountObtained) {

        address destinationToken;

        (amountObtained, destinationToken) = trade(orderAddresses, orderValues);

        transferTokenToSender(destinationToken, amountObtained);

    }



    function performSell(

        address[8] orderAddresses, // [converterAddress, conversionPath ... ]

        uint256[6] orderValues, // [amountToGive, minReturn, EMPTY, EMPTY, EMPTY, EMPTY]

        uint256 exchangeFee, // ignore

        uint256 amountToFill, // ignore

        uint8 v, // ignore

        bytes32 r, // ignore

        bytes32 s // ignore

    ) external onlyTotle returns (uint256 amountObtained) {

        approveExchange(orderAddresses[0], orderAddresses[1]);

        (amountObtained, ) = trade(orderAddresses, orderValues);

        transferEtherToSender(amountObtained);

    }



    function trade(

        address[8] orderAddresses, // [converterAddress, conversionPath ... ]

        uint256[6] orderValues // [amountToGive, minReturn, EMPTY, EMPTY, EMPTY, EMPTY]

    ) internal returns (uint256 amountObtained, address destinationToken) {

        // Find the length of the conversion path

        uint256 len;

        for(len = 1; len < orderAddresses.length; len++) {

            if(orderAddresses[len] == 0) {

                require(len > 1);

                destinationToken = orderAddresses[len - 1];

                len--;

                break;

            } else if(len == orderAddresses.length - 1) {

                destinationToken = orderAddresses[len];

                break;

            }

        }

        // Create an array of that length

        address[] memory conversionPath = new address[](len);



        // Move the contents from orderAddresses to conversionPath

        for(uint256 i = 0; i < len; i++) {

            conversionPath[i] = orderAddresses[i + 1];

        }



        amountObtained = BancorConverter(orderAddresses[0])

                            .quickConvert.value(msg.value)(conversionPath, orderValues[0], orderValues[1]);

    }



    function transferTokenToSender(address token, uint256 amount) internal {

        require(Token(token).transfer(msg.sender, amount));

    }



    function transferEtherToSender(uint256 amount) internal {

        msg.sender.transfer(amount);

    }



    function approveExchange(address exchange, address token) internal {

        if(Token(token).allowance(address(this), exchange) == 0) {

            require(Token(token).approve(exchange, MAX_UINT));

        }

    }



    function withdrawToken(address _token, uint _amount) external onlyOwner returns (bool) {

        return Token(_token).transfer(owner, _amount);

    }



    function withdrawETH(uint _amount) external onlyOwner returns (bool) {

        owner.transfer(_amount);

    }



    function setTotle(address _totlePrimary) external onlyOwner {

        require(_totlePrimary != address(0));

        totlePrimary = _totlePrimary;

    }



    function() public payable {

        // Check in here that the sender is a contract! (to stop accidents)

        uint256 size;

        address sender = msg.sender;

        assembly {

            size := extcodesize(sender)

        }

        require(size > 0);

    }

}