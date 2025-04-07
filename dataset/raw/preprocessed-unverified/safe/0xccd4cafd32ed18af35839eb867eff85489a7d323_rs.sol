/**
 *Submitted for verification at Etherscan.io on 2021-10-04
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


abstract 




















abstract contract Router {
    using DisableFlags for uint256;
     
    uint256 public constant FLAG_UNISWAP = 0x01;
    uint256 public constant FLAG_SUSHI = 0x02;
    uint256 public constant FLAG_1INCH = 0x04;

    uint256 public constant totalDEX = 3;            // Total no of DEX aggregators or exchanges used
    
    mapping (address => uint256) _disabledDEX;
    enum OrderType {EthForTokens, TokensForEth, TokensForTokens}

    event Received(address, uint);
    event Error(address);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {
        revert();
    }
    
    event Caught(string stringFailure,uint index,uint256 amount);

    I1inch OneSplit;
    IUni Uni;
    IUni Sushi;
    IUni public uniV2Router;            // uniswap compatible router where we have to feed company token pair
    
    address constant ETH = address(0);

    // add these variables into contract and initialize it in constructor.
    // also, create setter functions for it with onlyOwner restriction.

    constructor(address _Uni, address _sushi, address _oneSplit) payable {
        // owner = payable(msg.sender);
        OneSplit = I1inch(_oneSplit);
        Uni = IUni(_Uni);
        Sushi = IUni(_sushi);
    }
    
    function setDisabledDEX(uint256 _disableFlag) external returns(bool) {
        _disabledDEX[msg.sender] = _disableFlag;
        return true;
    }
    
    function getDisabledDEX(address account) public view returns(uint256) {
        return _disabledDEX[account];
    }
    
    function calculateUniswapReturn( uint256 amountIn, address[] memory path, OrderType orderType,uint256 /*disableFlags*/) public view returns(uint256, uint256[] memory) {
        uint256[] memory uniAmounts =new uint[](path.length);
        uint256[] memory distribution;

        uniAmounts[path.length-1] = uint256(0);
        
        if(orderType == OrderType.EthForTokens){
            path[0] = Uni.WETH();
            try Uni.getAmountsOut(amountIn, path)returns(uint256[] memory _amounts) {
                uniAmounts = _amounts;
            }
            catch{}
        } 
        else if(orderType == OrderType.TokensForEth){
            path[path.length-1] = Uni.WETH();
            try Uni.getAmountsOut(amountIn, path)returns(uint256[] memory _amounts) {
                uniAmounts = _amounts;
            }catch{}
        } 
        else{
            try Uni.getAmountsOut(amountIn, path)returns(uint256[] memory _amounts) {
                uniAmounts = _amounts;
            }catch{}
        }
        
        return (uniAmounts[path.length-1],distribution);

    }
    
    function calculateSushiReturn( uint256 amountIn, address[] memory path, OrderType orderType,uint256 /*disableFlags*/) public view returns(uint256, uint256[] memory) {
        uint256[] memory sushiAmounts =new uint[](path.length);
        uint256[] memory distribution;

        sushiAmounts[path.length-1] = uint256(0);
        
        if(orderType == OrderType.EthForTokens){
            try Sushi.getAmountsOut(amountIn, path) returns(uint256[] memory _amounts) {
                sushiAmounts = _amounts;
            }catch{}
        } 
        else if(orderType == OrderType.TokensForEth){
            try Sushi.getAmountsOut(amountIn, path) returns(uint256[] memory _amounts) {
                sushiAmounts = _amounts;
            }catch{}
        } 
        else{
            try Sushi.getAmountsOut(amountIn, path) returns(uint256[] memory _amounts) {
                sushiAmounts = _amounts;
            }catch{}
        }
        
        return (sushiAmounts[path.length-1],distribution);

    }
    
    function calculate1InchReturn( uint256 amountIn, address[] memory path, OrderType orderType,uint256 /*disableFlags*/) public view returns(uint256,uint256[] memory) {
        uint256 returnAmount;
        uint256[] memory distribution;

        if(orderType == OrderType.EthForTokens){
            path[0] = ETH;
            try OneSplit.getExpectedReturn(IERC20(path[0]), IERC20(path[path.length-1]), amountIn, 100, 0) returns(uint256 _amount, uint256[] memory _distribution){
                returnAmount = _amount;
                distribution = _distribution;
            }catch{}
        }
        else if(orderType == OrderType.TokensForEth){
            path[path.length-1] = ETH;
            try OneSplit.getExpectedReturn(IERC20(path[0]), IERC20(path[path.length-1]), amountIn, 100, 0) returns(uint256 _amount, uint256[] memory _distribution){
                returnAmount = _amount;
                distribution = _distribution;
            }catch{}
        } 
        else{
            try OneSplit.getExpectedReturn(IERC20(path[0]), IERC20(path[path.length-1]), amountIn, 100, 0) returns(uint256 _amount, uint256[] memory _distribution){
                returnAmount = _amount;
                distribution = _distribution;
            }catch{}
        }
        
        return (returnAmount,distribution);

    }

    function _calculateNoReturn( uint256/* amountIn*/, address[] memory /*path*/, OrderType /*orderType*/,uint256 /*disableFlags*/) internal pure returns(uint256, uint256[] memory) {
        uint256[] memory distribution;
        return (uint256(0), distribution);
    }
    
    // returns : 
    // dexId ->  which dex gives highest amountOut 0-> 1inch 1-> uniswap 2-> sushiswap
    // minAmountExpected ->  how much tokens you will get after swap
    // distribution -> the route of swappping
    function getBestQuote(address[] memory path, uint256 amountIn, OrderType orderType, uint256 disableFlags) public view returns (uint256, uint256,uint256[] memory) {
        
        function(uint256, address[] memory, OrderType ,uint256 ) view returns(uint256,uint256[]memory)[3] memory reserves = [
            disableFlags.disabled(FLAG_1INCH)    ? _calculateNoReturn : _calculateNoReturn,
            disableFlags.disabled(FLAG_UNISWAP)  ? _calculateNoReturn : calculateUniswapReturn,
            disableFlags.disabled(FLAG_SUSHI)    ? _calculateNoReturn : calculateSushiReturn
        ];
        
        uint256[3] memory rates;
        uint256[][3] memory distribution;
        
        for (uint256 i = 0; i < rates.length; i++) {
            (rates[i],distribution[i]) = reserves[i](amountIn,path,orderType,disableFlags);
        }
        
        uint256 temp = 0;
        for(uint256 i = 1; i < rates.length; i++) {
            if(rates[i] > rates[temp]) {
                temp = i;
            }
        }
        return(temp, rates[temp], distribution[temp]);   
    
    }
 
    function oneInchSwap(address _fromToken, address _toToken, uint256 amountIn, uint256 minReturn, uint256[] memory distribution, uint256 flags)
    internal {
        if (_fromToken == ETH) {
            try OneSplit.swap{value: amountIn}(IERC20(ETH), IERC20(_toToken), amountIn, minReturn, distribution, flags)
             returns (uint256 amountOut){
                 TransferHelper.safeTransferFrom(_toToken, address(this), msg.sender, amountOut);
            } catch {
                emit Error(msg.sender);
                revert("Error");
            }
        } else {
             try OneSplit.swap(IERC20(_fromToken), IERC20(_toToken), amountIn, minReturn, distribution, flags)
              returns (uint256 amountOut){
                  if(_toToken == ETH){
                      payable(msg.sender).transfer(amountOut);
                  } else {
                      TransferHelper.safeTransferFrom(_toToken, address(this), msg.sender, amountOut);
                  }
             } catch {
                emit Error(msg.sender);
                revert("Error");
            }
        }
    }
}

 
contract Degen is Router, Ownable {
    using DisableFlags for uint256;
    
    address public _Uni = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //mainnet network address for uniswap (valid for Ropsten as well)
    address public _oneSplit = address(0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E); //INCORRECT! mainnet network address for oneInch
    address public _sushi = address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F); // Mainnet network address for sushiswap
    //address public _sushi = address(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506); // Ropsten network address for sushiswap
    //address public USDT = address(0x47A530f3Fa882502344DC491549cA9c058dbC7Da); // Ropsten test net USDT test token
    address public USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7); // USDT Token Address
    address public system;
    address public gatewayVault;
    uint256 public proccessingFee = 0 ;
    
    uint256 private deadlineLimit = 20*60;      // 20 minutes by default 
    
    uint256 private collectedFees = 1; // amount of collected fee (starts from 1 to avoid additional gas usage)
    address public feeReceiver; // address which receive the fee (by default is validator)


    IReimbursement public reimbursementContract;      // reimbursement contract address

    address public companyToken;        // company reimbursement token (BSWAP, DEGEN, SMART)
    address public companyVault;    // the vault address of our company registered in reimbursement contract

    ISwapFactory public swapFactory;
   
   modifier onlySystem() {
        require(msg.sender == system || owner() == msg.sender,"Caller is not the system");
        _;
    }
    
    
    constructor(address _companyToken, address _swapFactory, address _system, address _gatewayVault /*, address _companyVault, address _reimbursementContract*/) 
    Router( _Uni, _sushi, _oneSplit) {
        companyToken = _companyToken;
        // companyVault = _companyVault;
        // reimbursementContract = IReimbursement(_reimbursementContract);
        swapFactory = ISwapFactory(_swapFactory);
        system = _system;
        gatewayVault = _gatewayVault;
    }
    
    
    // function degenPrice() public view returns (uint256){
    //     (uint112 reserve0, uint112 reserve1,) = poolContract.getReserves();
    //     if(poolContract.token0() == Uni.WETH()){
    //         return ((reserve1 * (10**18)) /(reserve0));
    //     } else {
    //         return ((reserve0 * (10**18)) /(reserve1));
    //     }
    // }

    function setCompanyToken(address _companyToken) external onlyOwner {
        companyToken = _companyToken;
    }

    function setCompanyVault(address _comapnyVault) external onlyOwner returns(bool){
        companyVault = _comapnyVault;
        return true;
    }

    function setReimbursementContract(address _reimbursementContarct) external onlyOwner returns(bool){
        reimbursementContract = IReimbursement(_reimbursementContarct);
        return true;
    }

    function setProccessingFee(uint256 _processingFees) external onlySystem {
        proccessingFee = _processingFees;
    }

    function setSwapFactory(address _swapFactory) external onlyOwner {
        swapFactory = ISwapFactory(_swapFactory);

    }
    
    function setGatewayVault(address _gatewayVault) external onlyOwner returns(bool) {
        gatewayVault = _gatewayVault;
        return true;
    }
    
    function setSystem (address _system) external onlyOwner returns(bool) {
        system = _system;
        return true;
    }
    
    function setFeeReceiver(address _addr) external onlyOwner returns(bool) {
        feeReceiver = _addr;
        return true;
    }
    
    function getDeadlineLimit() public view returns(uint256) {
        return deadlineLimit;
    }
    
    function setDeadlineLimit(uint256 limit) external onlyOwner returns(bool) {
        deadlineLimit = limit;
        return true;
    }

    // get amount of collected fees that can be claimed
    function getColletedFees() external view returns (uint256) {
        // collectedFees starts from 1 to avoid additional gas usage to initiate storage (when collectedFees = 0)
        return collectedFees - 1;
    }

    // claim fees by feeReceiver
    function claimFee() external returns (uint256 feeAmount) {
        require(msg.sender == feeReceiver, "This fee can be claimed only by fee receiver!!");
        feeAmount = collectedFees - 1;
        collectedFees = 1;        
        TransferHelper.safeTransferETH(msg.sender, feeAmount);
    }
    
    
    // Call function processFee() at the end of main function for correct gas usage calculation.
    // txGas - is gasleft() on start of calling contract. Put `uint256 txGas = gasleft();` as a first command in function
    // feeAmount - fee amount that user paid
    // processing - processing fee (for cross-chain swaping)
    // licenseeVault - address that licensee received on registration and should provide when users comes from their site
    // user - address of user who has to get reimbursement (usually msg.sender)

    function processFee(uint256 txGas, uint256 feeAmount, uint256 processing, address licenseeVault, address user) internal {
        if (address(reimbursementContract) == address(0)) {
            payable(user).transfer(feeAmount); // return fee to sender if no reimbursement contract
            return;
        }
        
        uint256 licenseeFeeAmount;
        if (licenseeVault != address(0)) {
            uint256 companyFeeRate = reimbursementContract.getLicenseeFee(companyVault, address(this));
            uint256 licenseeFeeRate = reimbursementContract.getLicenseeFee(licenseeVault, address(this));
            if (licenseeFeeRate != 0)
                licenseeFeeAmount = (feeAmount * licenseeFeeRate)/(licenseeFeeRate + companyFeeRate);
            if (licenseeFeeAmount != 0) {
                address licenseeFeeTo = reimbursementContract.requestReimbursement(user, licenseeFeeAmount, licenseeVault);
                if (licenseeFeeTo == address(0)) {
                    payable(user).transfer(licenseeFeeAmount);    // refund to user
                } else {
                    payable(licenseeFeeTo).transfer(licenseeFeeAmount);  // transfer to fee receiver
                }
            }
        }
        feeAmount -= licenseeFeeAmount; // company's part of fee
        collectedFees += feeAmount; 
        
        if (processing != 0) 
            payable(system).transfer(processing);  // transfer to fee receiver
        
        txGas -= gasleft(); // get gas amount that was spent on Licensee fee
        txGas = txGas * tx.gasprice;
        // request reimbursement for user
        reimbursementContract.requestReimbursement(user, feeAmount+txGas+processing, companyVault);
    }
    
    
    function _swap( 
        OrderType orderType, 
        address[] memory path, 
        uint256 assetInOffered,
        uint256 minExpectedAmount, 
        address user,
        address to,
        uint256 dexId,
        uint256[] memory distribution,
        uint256 deadline
    ) internal returns(uint256) {
         
        require(dexId < totalDEX, "Invalid DEX Id!");
        require(deadline >= block.timestamp, "EXPIRED: Deadline for transaction already passed.");
        
        uint256 disableFlags = getDisabledDEX(user);
         
        // check conditions for disableFlags and return response accordingly. if disabled then minExpectedAmount will be uint(0)
        if( disableFlags.disabled(FLAG_1INCH) || disableFlags.disabled(FLAG_UNISWAP) || disableFlags.disabled(FLAG_SUSHI) ) {
            minExpectedAmount = uint256(0);
        }
        
        if(dexId == 0){
            if(orderType == OrderType.EthForTokens) {
                 path[0] = ETH;
            }
            else if (orderType == OrderType.TokensForEth) {
                path[path.length-1] = ETH;
            }
            oneInchSwap(path[0], path[path.length-1], assetInOffered, 0, distribution, 0);
        }

        
        else if(dexId == 1){
            uint[] memory swapResult;
            if(orderType == OrderType.EthForTokens) {
                 path[0] = Uni.WETH();
                 swapResult = Uni.swapExactETHForTokens{value:assetInOffered}(0, path, to,block.timestamp);
            }
            else if (orderType == OrderType.TokensForEth) {
                path[path.length-1] = Uni.WETH();
                TransferHelper.safeApprove(path[0], address(_Uni), assetInOffered);
                swapResult = Uni.swapExactTokensForETH(assetInOffered, 0, path,to, block.timestamp);
            }
            else if (orderType == OrderType.TokensForTokens) {
                TransferHelper.safeApprove(path[0], address(_Uni), assetInOffered);
                swapResult = Uni.swapExactTokensForTokens(assetInOffered, minExpectedAmount, path, to, block.timestamp);
            }
        } 
        
        else if(dexId == 2){
            uint[] memory swapResult;
            if(orderType == OrderType.EthForTokens) {
                 path[0] = Sushi.WETH();
                 swapResult = Sushi.swapExactETHForTokens{value:assetInOffered}(minExpectedAmount, path, to, block.timestamp);
            }
            else if (orderType == OrderType.TokensForEth) {
                path[path.length-1] = Sushi.WETH();
                TransferHelper.safeApprove(path[0], address(_sushi), assetInOffered);
                swapResult = Sushi.swapExactTokensForETH(assetInOffered, minExpectedAmount, path, to, block.timestamp);
            }
            else if (orderType == OrderType.TokensForTokens) {
                TransferHelper.safeApprove(path[0], address(_sushi), assetInOffered);
                swapResult = Sushi.swapExactTokensForTokens(assetInOffered, minExpectedAmount, path, to, block.timestamp);
            }
        }

        return minExpectedAmount;
    }
    
    
    function executeSwap(
        OrderType orderType, 
        address[] memory path, 
        uint256 assetInOffered, 
        uint256 fees, 
        uint256 minExpectedAmount,
        address licenseeVault,
        uint256 dexId,
        uint256[] memory distribution,
        uint256 deadline
    ) external payable {
        uint256 gasA = gasleft();
        uint256 receivedFees = 0;
        if(deadline == 0) {
            deadline = block.timestamp + deadlineLimit;
        }
        
        if(orderType == OrderType.EthForTokens){
            require(msg.value >= (assetInOffered + fees), "Payment = assetInOffered + fees");
            receivedFees = receivedFees + msg.value - assetInOffered;
        } else {
            require(msg.value >= fees, "fees not received");
            receivedFees = receivedFees + msg.value;
            TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), assetInOffered);
        }
        
        _swap(orderType, path, assetInOffered, minExpectedAmount, msg.sender, msg.sender, dexId, distribution, deadline);
   
        processFee(gasA, receivedFees, 0, licenseeVault, msg.sender);
    }
    
    
    function executeCrossExchange(
        address[] memory path, 
        OrderType orderType,
        uint256 crossOrderType,
        uint256 assetInOffered,
        uint256 fees, 
        uint256 minExpectedAmount,
        address licenseeVault,
        uint256[3] memory dexId_deadline, // dexId_deadline[0] - native swap dexId, dexId_deadline[1] - foreign swap dexId, dexId_deadline[2] - deadline
        uint256[] memory distribution
    ) external payable {
        uint256[2] memory feesPrice; 
        feesPrice[0] = gasleft();       // equivalent to gasA
        feesPrice[1] = 0;               // processing fees
        
        if (dexId_deadline[2] == 0) {   // if deadline == 0, set deadline to deadlineLimit
            dexId_deadline[2] = block.timestamp + deadlineLimit;
        }

        if(orderType == OrderType.EthForTokens){
            require(msg.value >= (assetInOffered + fees + proccessingFee), "Payment = assetInOffered + fees + proccessingFee");
            feesPrice[1] = msg.value - assetInOffered - fees;
        } else {
            require(msg.value >= (fees + proccessingFee), "fees not received");
            feesPrice[1] = msg.value - fees;
            TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), assetInOffered);
        }
        
        if(path[0] == USDT) {
            IERC20(USDT).approve(address(swapFactory), assetInOffered);
            swapFactory.swap(USDT, path[path.length-1], assetInOffered, msg.sender, crossOrderType, dexId_deadline[1], distribution, dexId_deadline[2]);
        }
        else {
            address tokenB = path[path.length-1];
            path[path.length-1] = USDT;
            uint256 minAmountExpected = _swap(orderType, path, assetInOffered, minExpectedAmount, msg.sender, address(this), dexId_deadline[0], distribution, dexId_deadline[2]);
                
            IERC20(USDT).approve(address(swapFactory),minAmountExpected);
            swapFactory.swap(USDT, tokenB, minAmountExpected, msg.sender, crossOrderType, dexId_deadline[1], distribution, dexId_deadline[2]);
        }        

        processFee(feesPrice[0], fees, feesPrice[1], licenseeVault, msg.sender);
    }

    function callbackCrossExchange( 
        OrderType orderType, 
        address[] memory path, 
        uint256 assetInOffered, 
        address user,
        uint256 dexId,
        uint256[] memory distribution,
        uint256 deadline
    ) external returns(bool) {
        require(msg.sender == address(swapFactory) , "Degen : caller is not SwapFactory");
        if(deadline==0) {
            deadline = block.timestamp + deadlineLimit;
        }
        _swap(orderType, path, assetInOffered, uint256(0), user, user, dexId, distribution, deadline);
        return true;
    }

}