/**
 *Submitted for verification at Etherscan.io on 2021-01-16
*/

pragma solidity ^0.7.0;



interface IERC1155 /* is ERC165 */ {
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _value, uint256 indexed _id);

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function creators(uint256 artwork) external view returns (address);
}



interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}









contract BAETrade {
  using SafeMath for uint256;
  //using SafeERC20 for IUniswapV2Pair;


  modifier onlyOwner {
    assert(msg.sender == owner);
    _;
  }

  mapping (bytes32 => uint256) public orderFills;
  address payable public owner;
  address payable public feeAccount;
  address public weth;
  address[] path = new address[](2);
  uint256[] amounts;
  address public baePay;
  address public router;
  address public baeContract;
  uint256 public fee = 40;
  uint256 public creatorFee = 50;
  mapping (bytes32 => bool) public traded;
  event Order(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Cancel(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Trade(uint256 tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, address get, address give, bytes32 hash);

  constructor(address router_, address baePay_, address baeContract_, address weth_) {
    owner = 0x486082148bc8Dc9DEe8c9E53649ea148291FF292;
    feeAccount = 0x44e86f37792D4c454cc836b91c84D7fe8224220b;
    weth = weth_;
    path[0] = weth_;
    baePay = baePay_;
    router = router_;//0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    baeContract = baeContract_;
    IERC20(weth).approve(router, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
  }

  modifier onlyAdmin {
    require(msg.sender == owner, "Not Owner");
    _;
  }

  receive() external payable {

  }

  function changeFee(uint256 _amount) public onlyAdmin{
    fee = _amount;
  }

  function changeCreatorFee(uint256 _amount) public onlyAdmin{
    creatorFee = _amount;
  }

  function invalidateOrder(uint256[5] memory tradeValues, address[2] memory tradeAddresses, uint8 v, bytes32[2] memory rs) public{
    bytes32 orderHash = keccak256(abi.encodePacked(address(this), tradeAddresses[0], tradeValues[0], tradeValues[1], tradeAddresses[1], tradeValues[2], tradeValues[3], tradeValues[4]));
    require(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", orderHash)), v, rs[0], rs[1]) == tradeAddresses[1], "Invalid Order");
    orderFills[orderHash] = tradeValues[1];
  }

  function isValidOrder(uint256[5] memory tradeValues, address[2] memory tradeAddresses, uint8 v, bytes32[2] memory rs) public view returns(bool) {
    bytes32 orderHash = keccak256(abi.encodePacked(address(this), tradeAddresses[0], tradeValues[0], tradeValues[1], tradeAddresses[1], tradeValues[2], tradeValues[3], tradeValues[4]));
    if(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", orderHash)), v, rs[0], rs[1]) != tradeAddresses[1]){
      return false;
    }
    if(IERC1155(baeContract).balanceOf(tradeAddresses[1], tradeValues[0]) < tradeValues[1] - orderFills[orderHash]){
      return false;
    }
    if(tradeValues[3] < block.timestamp){
      return false;
    }
    return true;
  }

  function isValidOffer(uint256[5] memory tradeValues, address[2] memory tradeAddresses, uint8 v, bytes32[2] memory rs) public view returns(bool) {
    bytes32 offerHash = keccak256(abi.encodePacked(address(this), tradeAddresses[0], tradeValues[0], tradeValues[1], tradeAddresses[1], tradeValues[2], tradeValues[3], tradeValues[4]));
    if(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", offerHash)), v, rs[0], rs[1]) != tradeAddresses[1]){
      return false;
    }
    if(tradeValues[3] < block.timestamp){
      return false;
    }
    return true;
  }

  function buyArtwork(uint256[6] memory tradeValues, address[2] memory tradeAddresses, uint8 v, bytes32[2] memory rs) public payable returns (bool success) {
    require(tradeValues[3] > block.timestamp, "Expired");
    require(tradeAddresses[0] != address(0), "ETH Trade");
    /* amount is in amountBuy terms */
    /* tradeValues
       [0] token
       [1] prints
       [2] price
       [3] expires
       [4] nonce
       [5] amount
     tradeAddressses
       [0] tokenSell
       [1] maker
     */
    bytes32 orderHash = keccak256(abi.encodePacked(address(this), tradeAddresses[0], tradeValues[0], tradeValues[1], tradeAddresses[1], tradeValues[2], tradeValues[3], tradeValues[4]));
    require(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", orderHash)), v, rs[0], rs[1]) == tradeAddresses[1], "Invalid Order");

    require(orderFills[orderHash].add(tradeValues[5]) <= tradeValues[1], "Trade amount too high");

    if(tradeAddresses[0] == baePay){
      path[1] = tradeAddresses[0];
      amounts = IUniswapV2Router02(router).swapETHForExactTokens{value: msg.value}(tradeValues[2].mul(tradeValues[5]), path, address(this), block.timestamp + 2000);
      IERC1155(baeContract).safeTransferFrom(tradeAddresses[1], msg.sender, tradeValues[0], tradeValues[5],"");
      IERC20(tradeAddresses[0]).transfer(tradeAddresses[1], tradeValues[2].mul(tradeValues[5]));
    }
    else if(tradeAddresses[0] != address(0)){
      path[1] = tradeAddresses[0];
      amounts = IUniswapV2Router02(router).swapETHForExactTokens{value: msg.value}(tradeValues[2].mul(tradeValues[5]), path, address(this), block.timestamp + 2000);
      IERC1155(baeContract).safeTransferFrom(tradeAddresses[1], msg.sender, tradeValues[0], tradeValues[5],"");
      IERC20(tradeAddresses[0]).transfer(feeAccount, tradeValues[2].mul(tradeValues[5]).mul(10).div(1000));
      IERC20(tradeAddresses[0]).transfer(owner, tradeValues[2].mul(tradeValues[5]).mul(fee).div(1000));
      IERC20(tradeAddresses[0]).transfer(IERC1155(baeContract).creators(tradeValues[0]), tradeValues[2].mul(tradeValues[5]).mul(creatorFee).div(1000));
      IERC20(tradeAddresses[0]).transfer(tradeAddresses[1], tradeValues[2].mul(tradeValues[5]).mul(1000 - fee - creatorFee - 10).div(1000));
    }

    (bool success4, ) = msg.sender.call{value: msg.value - amounts[0]}(new bytes(0));
    require(success4, 'Could Not return Leftover ETH');

    orderFills[orderHash] = orderFills[orderHash].add(tradeValues[5]);
    emit Trade(tradeValues[0], tradeValues[5], tradeAddresses[0], tradeValues[2].mul(tradeValues[5]), msg.sender, tradeAddresses[1], orderHash);
    return true;
  }

  function buyArtworkETH(uint256[6] memory tradeValues, address payable[2] memory tradeAddresses, uint8 v, bytes32[2] memory rs) public payable returns (bool success) {
    require(tradeValues[3] > block.timestamp, "Expired");
    require(tradeAddresses[0] == address(0), "Not an ETH Trade");
    /* amount is in amountBuy terms */
    /* tradeValues
       [0] token
       [1] prints
       [2] price
       [3] expires
       [4] nonce
       [5] amount
     tradeAddressses
       [0] tokenSell
       [1] maker
     */
    bytes32 orderHash = keccak256(abi.encodePacked(address(this), tradeAddresses[0], tradeValues[0], tradeValues[1], tradeAddresses[1], tradeValues[2], tradeValues[3], tradeValues[4]));
    require(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", orderHash)), v, rs[0], rs[1]) == tradeAddresses[1], "Invalid Order");

    require(orderFills[orderHash].add(tradeValues[5]) <= tradeValues[1], "Trade amount too high");

    require(msg.value >= tradeValues[2].mul(tradeValues[5]), "Insufficent Balance");
    uint256 amount = (tradeValues[2].mul(tradeValues[5]) );
    IERC1155(baeContract).safeTransferFrom(tradeAddresses[1], msg.sender, tradeValues[0], tradeValues[5],"");
    feeAccount.transfer(amount.mul(10).div(1000));
    owner.transfer(amount.mul(fee).div(1000));
    payable(IERC1155(baeContract).creators(tradeValues[0])).transfer(amount.mul(creatorFee).div(1000));
    tradeAddresses[1].transfer(amount.mul(1000 - fee - creatorFee - 10).div(1000));
    msg.sender.transfer(msg.value - amount);

    orderFills[orderHash] = orderFills[orderHash].add(tradeValues[5]);
    emit Trade(tradeValues[0], tradeValues[5], tradeAddresses[0], tradeValues[2].mul(tradeValues[5]), msg.sender, tradeAddresses[1], orderHash);
    return true;
  }

  function payWithBae(uint256[6] memory tradeValues, address[2] memory tradeAddresses, uint8 v, bytes32[2] memory rs) public payable returns (bool success) {
    require(tradeValues[3] > block.timestamp, "Expired");
    require(IERC20(baePay).balanceOf(msg.sender) >= tradeValues[2].mul(tradeValues[5]), "You Have Insufficient Balance");
    require(tradeAddresses[0] == baePay, "This Trade Does Not Accept BaePay");

    bytes32 orderHash = keccak256(abi.encodePacked(address(this), tradeAddresses[0], tradeValues[0], tradeValues[1], tradeAddresses[1], tradeValues[2], tradeValues[3], tradeValues[4]));
    require(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", orderHash)), v, rs[0], rs[1]) == tradeAddresses[1], "Invalid Order");

    require(orderFills[orderHash].add(tradeValues[5]) <= tradeValues[1], "Trade amount too high");

    IERC1155(baeContract).safeTransferFrom(tradeAddresses[1], msg.sender, tradeValues[0], tradeValues[5],"");
    IERC20(tradeAddresses[0]).transferFrom(msg.sender, tradeAddresses[1], tradeValues[2].mul(tradeValues[5]));
    orderFills[orderHash] = orderFills[orderHash].add(tradeValues[5]);
    emit Trade(tradeValues[0], tradeValues[5], tradeAddresses[0], tradeValues[2].mul(tradeValues[5]), msg.sender, tradeAddresses[1], orderHash);
    return true;
  }

  function acceptOfferRequest(uint256[6] memory tradeValues, address[2] memory tradeAddresses, uint8 v, bytes32[2] memory rs) public payable returns (bool success) {
    require(tradeValues[3] > block.timestamp, "Expired");
    //require(tradeAddresses[0] != baePay, "");
    /* amount is in amountBuy terms */
    /* tradeValues
       [0] token
       [1] prints
       [2] price
       [3] expires
       [4] nonce
       [5] tradeAmount
     tradeAddressses
       [0] tokenSell
       [1] maker
     */
     bytes32 orderHash = keccak256(abi.encodePacked(address(this), tradeAddresses[0], tradeValues[0], tradeValues[1], tradeAddresses[1], tradeValues[2], tradeValues[3], tradeValues[4], "Offer"));
     require(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", orderHash)), v, rs[0], rs[1]) == tradeAddresses[1], "Invalid Order");

     require(orderFills[orderHash].add(tradeValues[5]) <= tradeValues[1], "Trade amount too high");

     if(tradeAddresses[0] == baePay){
       IERC20(tradeAddresses[0]).transferFrom(tradeAddresses[1], msg.sender, tradeValues[2].mul(tradeValues[5]));
       IERC1155(baeContract).safeTransferFrom(msg.sender, tradeAddresses[1], tradeValues[0], tradeValues[5],"");
     }
     else if(tradeAddresses[0] != address(0)){
       IERC20(tradeAddresses[0]).transferFrom(tradeAddresses[1], address(this), tradeValues[2].mul(tradeValues[5]));
       IERC1155(baeContract).safeTransferFrom(msg.sender, tradeAddresses[1], tradeValues[0], tradeValues[5],"");
       IERC20(tradeAddresses[0]).transfer(feeAccount, tradeValues[2].mul(tradeValues[5]).mul(10).div(1000));
       IERC20(tradeAddresses[0]).transfer(owner, tradeValues[2].mul(tradeValues[5]).mul(fee).div(1000));
       IERC20(tradeAddresses[0]).transfer(IERC1155(baeContract).creators(tradeValues[0]), tradeValues[2].mul(tradeValues[5]).mul(creatorFee).div(1000));
       IERC20(tradeAddresses[0]).transfer(msg.sender, tradeValues[2].mul(tradeValues[5]).mul(1000 - fee - creatorFee - 10).div(1000));
     }
     orderFills[orderHash] = orderFills[orderHash].add(tradeValues[5]);
     emit Trade(tradeValues[0], tradeValues[5], tradeAddresses[0], tradeValues[2].mul(tradeValues[5]), tradeAddresses[1], msg.sender, orderHash);
     return true;
  }


}