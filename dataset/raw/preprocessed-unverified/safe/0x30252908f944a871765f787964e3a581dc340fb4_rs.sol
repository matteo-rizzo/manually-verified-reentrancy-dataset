/**
 *Submitted for verification at Etherscan.io on 2021-03-18
*/

/**
 *Submitted for verification at Etherscan.io on 2021-03-15
*/

pragma solidity = 0.5.16;





contract IDO is Ownable {
    using SafeMath for uint256;

    //Private offering
    mapping(address => uint256) private _ordersOfPriIDO;
    uint256 public startHeightOfPriIDO;
    uint256 public endHeightOfPriIDO;
    uint256 public totalUsdtAmountOfPriIDO = 0;
    uint256 public constant supplyYouForPriIDO = 5 * 10 ** 11;//50ä¸‡YOU
    uint256 public reservedYouOfPriIDO = 0;
    uint256 public constant upperLimitUsdtOfPriIDO = 500 * 10 ** 6;//500USDT
    bool private _priOfferingFinished = false;
    bool private _priIDOWithdrawFinished = false;

    event PrivateOffering(address indexed participant, uint256 amountOfYou, uint256 amountOfUsdt);
    event PrivateOfferingClaimed(address indexed participant, uint256 amountOfYou);

    //Public offering
    mapping(address => uint256) private _ordersOfPubIDO;
    uint256 public constant targetUsdtAmountOfPubIDO = 2 * 10 ** 8;//200USDT
    uint256 public constant targetYouAmountOfPubIDO = 2 * 10 ** 9;//2000YOU
    uint256 public totalUsdtAmountOfPubIDO = 0;
    uint256 public startHeightOfPubIDO;
    uint256 public endHeightOfPubIDO;
    uint256 public constant bottomLimitUsdtOfPubIDO = 10 * 10 ** 6; //10USDT
    bool private _pubIDOWithdrawFinished = false;

    event PublicOffering(address indexed participant, uint256 amountOfUsdt);
    event PublicOfferingClaimed(address indexed participant, uint256 amountOfYou);
    event PublicOfferingRefund(address indexed participant, uint256 amountOfUsdt);

    mapping(address => uint8) private _whiteList;

    address private constant _usdtToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address private _youToken;

    uint256 public constant initialLiquidYou = 3 * 10 ** 12;//3 000 000YOU For initial Liquid
    address private constant _vault = 0x6B5C21a770dA1621BB28C9a2b6F282E5FC9154d5;

    uint private unlocked = 1;
    constructor(address youToken) public {
        _youToken = youToken;

        startHeightOfPriIDO = 12047150;
        endHeightOfPriIDO = 12048590;

        startHeightOfPubIDO = block.number;
        endHeightOfPubIDO = startHeightOfPubIDO + 60;
    }

    modifier lock() {
        require(unlocked == 1, 'YouSwap: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function initPubIDO(uint256 startHOfPubIDO, uint256 endHOfPubIDO) onlyOwner public {
        startHeightOfPubIDO = startHOfPubIDO;
        endHeightOfPubIDO = endHOfPubIDO;
        _pubIDOWithdrawFinished = false;
    }

    modifier inWhiteList() {
        require(_whiteList[msg.sender] == 1, "YouSwap: NOT_IN_WHITE_LIST");
        _;
    }

    function isInWhiteList(address account) external view returns (bool) {
        return _whiteList[account] == 1;
    }

    function addToWhiteList(address account) external onlyOwner {
        _whiteList[account] = 1;
    }

    function addBatchToWhiteList(address[] calldata accounts) external onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            _whiteList[accounts[i]] = 1;
        }
    }

    function removeFromWhiteList(address account) external onlyOwner {
        _whiteList[account] = 0;
    }

    function claim() inWhiteList external lock {
        require((block.number >= endHeightOfPriIDO && _ordersOfPriIDO[msg.sender] > 0)
            || (block.number >= endHeightOfPubIDO && _ordersOfPubIDO[msg.sender] > 0), 'YouSwap: FORBIDDEN');

        uint256 reservedYouFromPriIDO = _ordersOfPriIDO[msg.sender];
        if (block.number >= endHeightOfPriIDO && reservedYouFromPriIDO > 0) {
            _ordersOfPriIDO[msg.sender] = 0;
            _mintYou(_youToken, msg.sender, reservedYouFromPriIDO);
            emit PrivateOfferingClaimed(msg.sender, reservedYouFromPriIDO);
        }

        uint256 amountOfUsdtPayed = _ordersOfPubIDO[msg.sender];
        if (block.number >= endHeightOfPubIDO && amountOfUsdtPayed > 0) {
            uint256 reservedYouFromPubIDO = 0;
            if (totalUsdtAmountOfPubIDO > targetUsdtAmountOfPubIDO) {
                uint256 availableAmountOfUsdt = amountOfUsdtPayed.mul(targetUsdtAmountOfPubIDO).div(totalUsdtAmountOfPubIDO);
                reservedYouFromPubIDO = availableAmountOfUsdt.mul(10);
                uint256 usdtAmountToRefund = amountOfUsdtPayed.sub(availableAmountOfUsdt).sub(10);

                if (usdtAmountToRefund > 0) {
                    _transfer(_usdtToken, msg.sender, usdtAmountToRefund);
                    emit PublicOfferingRefund(msg.sender, usdtAmountToRefund);
                }
            }
            else {
                reservedYouFromPubIDO = amountOfUsdtPayed.mul(10);
            }

            _ordersOfPubIDO[msg.sender] = 0;
            _mintYou(_youToken, msg.sender, reservedYouFromPubIDO);
            emit PublicOfferingClaimed(msg.sender, reservedYouFromPubIDO);
        }
    }

    function withdrawPriIDO() onlyOwner external {
        require(block.number > endHeightOfPriIDO, 'YouSwap: BLOCK_HEIGHT_NOT_REACHED');
        require(!_priIDOWithdrawFinished, 'YouSwap: PRI_IDO_WITHDRAWN_ALREADY');

        _transfer(_usdtToken, _vault, totalUsdtAmountOfPriIDO);

        _priIDOWithdrawFinished = true;
    }

    function withdrawPubIDO() onlyOwner external {
        require(block.number > endHeightOfPubIDO, 'YouSwap: BLOCK_HEIGHT_NOT_REACHED');
        require(!_pubIDOWithdrawFinished, 'YouSwap: PUB_IDO_WITHDRAWN_ALREADY');

        uint256 amountToWithdraw = totalUsdtAmountOfPubIDO;
        if (totalUsdtAmountOfPubIDO > targetUsdtAmountOfPubIDO) {
            amountToWithdraw = targetUsdtAmountOfPubIDO;
        }

        _transfer(_usdtToken, _vault, amountToWithdraw);
        _mintYou(_youToken, _vault, initialLiquidYou);

        _pubIDOWithdrawFinished = true;
    }

    function privateOffering(uint256 amountOfUsdt) inWhiteList external lock returns (bool)  {
        require(block.number >= startHeightOfPriIDO, 'YouSwap:NOT_STARTED_YET');
        require(!_priOfferingFinished && block.number <= endHeightOfPriIDO, 'YouSwap:PRIVATE_OFFERING_ALREADY_FINISHED');
        require(_ordersOfPriIDO[msg.sender] == 0, 'YouSwap: ENROLLED_ALREADY');
        require(amountOfUsdt <= upperLimitUsdtOfPriIDO, 'YouSwap: EXCEEDS_THE_UPPER_LIMIT');
        require(amountOfUsdt > 0, "YouSwap: INVALID_AMOUNT");

        require(reservedYouOfPriIDO < supplyYouForPriIDO, 'YouSwap:INSUFFICIENT_YOU');
        uint256 amountOfYou = amountOfUsdt.mul(10);
        //0.1USDT/YOU
        if (reservedYouOfPriIDO.add(amountOfYou) >= supplyYouForPriIDO) {
            amountOfYou = supplyYouForPriIDO.sub(reservedYouOfPriIDO);
            amountOfUsdt = amountOfYou.div(10);

            _priOfferingFinished = true;
        }
        _transferFrom(_usdtToken, amountOfUsdt);

        _ordersOfPriIDO[msg.sender] = amountOfYou;
        reservedYouOfPriIDO = reservedYouOfPriIDO.add(amountOfYou);
        totalUsdtAmountOfPriIDO = totalUsdtAmountOfPriIDO.add(amountOfUsdt);
        emit PrivateOffering(msg.sender, amountOfYou, amountOfUsdt);

        return true;
    }

    function priOfferingFinished() public view returns (bool) {
        return block.number > endHeightOfPriIDO || _priOfferingFinished;
    }

    function pubOfferingFinished() public view returns (bool) {
        return block.number > endHeightOfPubIDO;
    }

    function publicOffering(uint256 amountOfUsdt) external lock returns (bool)  {
        require(block.number >= startHeightOfPubIDO, 'YouSwap:PUBLIC_OFFERING_NOT_STARTED_YET');
        require(block.number <= endHeightOfPubIDO, 'YouSwap:PUBLIC_OFFERING_ALREADY_FINISHED');
        require(amountOfUsdt >= bottomLimitUsdtOfPubIDO, 'YouSwap: 100USDT_AT_LEAST');

        _transferFrom(_usdtToken, amountOfUsdt);

        _ordersOfPubIDO[msg.sender] = _ordersOfPubIDO[msg.sender].add(amountOfUsdt);
        totalUsdtAmountOfPubIDO = totalUsdtAmountOfPubIDO.add(amountOfUsdt);

        emit PublicOffering(msg.sender, amountOfUsdt);

        _whiteList[msg.sender] = 1;

        return true;
    }

    function _transferFrom(address token, uint256 amount) private {
        bytes4 methodId = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(methodId, msg.sender, address(this), amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'YouSwap: TRANSFER_FAILED');
    }

    function _mintYou(address token, address recipient, uint256 amount) private {
        bytes4 methodId = bytes4(keccak256(bytes('mint(address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(methodId, recipient, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'YouSwap: TRANSFER_FAILED');
    }

    function _transfer(address token, address recipient, uint amount) private {
        bytes4 methodId = bytes4(keccak256(bytes('transfer(address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(methodId, recipient, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'YouSwap: TRANSFER_FAILED');
    }
}