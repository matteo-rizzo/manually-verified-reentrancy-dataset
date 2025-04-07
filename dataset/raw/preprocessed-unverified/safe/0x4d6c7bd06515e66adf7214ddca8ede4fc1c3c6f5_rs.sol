/**
 *Submitted for verification at Etherscan.io on 2020-02-20
*/

pragma solidity 0.5.10;






contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}





contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}







contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant COL  = 10 ** 8;
    uint constant WAD  = 10 ** 18;
    uint constant RAY  = 10 ** 27;

    function cmul(uint x, uint y) public pure returns (uint z) {
        z = add(mul(x, y), COL / 2) / COL;
    }
    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function cdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, COL), y / 2) / y;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract Medianizer {
    function peek() external view returns (bytes32, bool);
    function read() external returns (bytes32);
    function poke() external;
    function poke(bytes32) external;
    function fund (uint256 amount, ERC20 token) external;
}

contract Loans is DSMath {
    FundsInterface funds;
    Medianizer med;
    SalesInterface sales;
    CollateralInterface col;

    uint256 public constant APPROVE_EXP_THRESHOLD = 2 hours;    
    uint256 public constant ACCEPT_EXP_THRESHOLD = 2 days;      
    uint256 public constant LIQUIDATION_EXP_THRESHOLD = 7 days; 
    uint256 public constant SEIZURE_EXP_THRESHOLD = 2 days;     
    uint256 public constant LIQUIDATION_DISCOUNT = 930000000000000000; 
    uint256 public constant MAX_NUM_LIQUIDATIONS = 3; 
    uint256 public constant MAX_UINT_256 = 2**256-1;

    mapping (bytes32 => Loan)                     public loans;
    mapping (bytes32 => PubKeys)                  public pubKeys;             
    mapping (bytes32 => SecretHashes)             public secretHashes;        
    mapping (bytes32 => Bools)                    public bools;               
    mapping (bytes32 => bytes32)                  public fundIndex;           
    mapping (bytes32 => uint256)                  public repayments;          
    mapping (address => bytes32[])                public borrowerLoans;
    mapping (address => bytes32[])                public lenderLoans;
    mapping (address => mapping(uint256 => bool)) public addressToTimestamp;
    uint256                                       public loanIndex;           

    ERC20 public token; 
    uint256 public decimals;

    address deployer;

    
    struct Loan {
        address borrower;
        address lender;
        address arbiter;
        uint256 createdAt;
        uint256 loanExpiration;
        uint256 requestTimestamp;
        uint256 closedTimestamp;
        uint256 principal;
        uint256 interest;
        uint256 penalty;
        uint256 fee;
        uint256 liquidationRatio;
    }

    
    struct PubKeys {
        bytes   borrowerPubKey;
        bytes   lenderPubKey;
        bytes   arbiterPubKey;
    }

    
    struct SecretHashes {
        bytes32    secretHashA1;
        bytes32[3] secretHashAs;
        bytes32    secretHashB1;
        bytes32[3] secretHashBs;
        bytes32    secretHashC1;
        bytes32[3] secretHashCs;
        bytes32    withdrawSecret;
        bytes32    acceptSecret;
        bool       set;
    }

    
    struct Bools {
        bool funded;
        bool approved;
        bool withdrawn;
        bool sale;
        bool paid;
        bool off;
    }

    event Create(bytes32 loan);

    event SetSecretHashes(bytes32 loan);

    event FundLoan(bytes32 loan);

    event Approve(bytes32 loan);

    event Withdraw(bytes32 loan, bytes32 secretA1);

    event Repay(bytes32 loan, uint256 amount);

    event Refund(bytes32 loan);

    event Cancel(bytes32 loan, bytes32 secret);

    event Accept(bytes32 loan, bytes32 secret);

    event Liquidate(bytes32 loan, bytes32 secretHash, bytes20 pubKeyHash);

    
    function borrower(bytes32 loan) external view returns (address) {
        return loans[loan].borrower;
    }

    
    function lender(bytes32 loan) external view returns (address) {
        return loans[loan].lender;
    }

    
    function arbiter(bytes32 loan) external view returns (address) {
        return loans[loan].arbiter;
    }

    
    function approveExpiration(bytes32 loan) public view returns (uint256) { 
        return add(loans[loan].createdAt, APPROVE_EXP_THRESHOLD);
    }

    
    function acceptExpiration(bytes32 loan) public view returns (uint256) { 
        return add(loans[loan].loanExpiration, ACCEPT_EXP_THRESHOLD);
    }

    
    function liquidationExpiration(bytes32 loan) public view returns (uint256) { 
        return add(loans[loan].loanExpiration, LIQUIDATION_EXP_THRESHOLD);
    }

    
    function seizureExpiration(bytes32 loan) public view returns (uint256) {
        return add(liquidationExpiration(loan), SEIZURE_EXP_THRESHOLD);
    }

    
    function principal(bytes32 loan) public view returns (uint256) {
        return loans[loan].principal;
    }

    
    function interest(bytes32 loan) public view returns (uint256) {
        return loans[loan].interest;
    }

    
    function fee(bytes32 loan) public view returns (uint256) {
        return loans[loan].fee;
    }

    
    function penalty(bytes32 loan) public view returns (uint256) {
        return loans[loan].penalty;
    }

    
    function collateral(bytes32 loan) public view returns (uint256) {
        return col.collateral(loan);
    }

    
    function refundableCollateral(bytes32 loan) external view returns (uint256) {
        return col.refundableCollateral(loan);
    }

    
    function seizableCollateral(bytes32 loan) external view returns (uint256) {
        return col.seizableCollateral(loan);
    }

    
    function temporaryRefundableCollateral(bytes32 loan) external view returns (uint256) {
        return col.temporaryRefundableCollateral(loan);
    }

    
    function temporarySeizableCollateral(bytes32 loan) external view returns (uint256) {
        return col.temporarySeizableCollateral(loan);
    }

    
    function repaid(bytes32 loan) public view returns (uint256) { 
        return repayments[loan];
    }

    
    function liquidationRatio(bytes32 loan) public view returns (uint256) {
        return loans[loan].liquidationRatio;
    }

    
    function owedToLender(bytes32 loan) public view returns (uint256) { 
        return add(principal(loan), interest(loan));
    }

    
    function owedForLoan(bytes32 loan) public view returns (uint256) { 
        return add(owedToLender(loan), fee(loan));
    }

    
    function owedForLiquidation(bytes32 loan) external view returns (uint256) { 
        return add(owedForLoan(loan), penalty(loan));
    }

    
    function owing(bytes32 loan) external view returns (uint256) {
        return sub(owedForLoan(loan), repaid(loan));
    }

    
    function funded(bytes32 loan) external view returns (bool) {
        return bools[loan].funded;
    }

    
    function approved(bytes32 loan) external view returns (bool) {
        return bools[loan].approved;
    }

    
    function withdrawn(bytes32 loan) external view returns (bool) {
        return bools[loan].withdrawn;
    }

    
    function sale(bytes32 loan) public view returns (bool) {
        return bools[loan].sale;
    }

    
    function paid(bytes32 loan) external view returns (bool) {
        return bools[loan].paid;
    }

    
    function off(bytes32 loan) public view returns (bool) {
        return bools[loan].off;
    }

    
    function dmul(uint x) public view returns (uint256) {
        return mul(x, (10 ** sub(18, decimals)));
    }

    
    function ddiv(uint x) public view returns (uint256) {
        return div(x, (10 ** sub(18, decimals)));
    }

    
    function borrowerLoanCount(address borrower_) external view returns (uint256) {
        return borrowerLoans[borrower_].length;
    }

    
    function lenderLoanCount(address lender_) external view returns (uint256) {
        return lenderLoans[lender_].length;
    }

    
    function minSeizableCollateral(bytes32 loan) public view returns (uint256) {
        (bytes32 val, bool set) = med.peek();
        require(set, "Loans.minSeizableCollateral: Medianizer must be set");
        uint256 price = uint(val);
        return div(wdiv(dmul(sub(owedForLoan(loan), repaid(loan))), price), div(WAD, COL));
    }

    
    function collateralValue(bytes32 loan) public view returns (uint256) {
        (bytes32 val, bool set) = med.peek();
        require(set, "Loans.collateralValue: Medianizer must be set");
        uint256 price = uint(val);
        return cmul(price, collateral(loan));
    }

    
    function minCollateralValue(bytes32 loan) public view returns (uint256) {
        return rmul(dmul(sub(owedForLoan(loan), repaid(loan))), liquidationRatio(loan));
    }

    
    function discountCollateralValue(bytes32 loan) public view returns (uint256) {
        return wmul(collateralValue(loan), LIQUIDATION_DISCOUNT);
    }

    
    function safe(bytes32 loan) public view returns (bool) {
        return collateralValue(loan) >= minCollateralValue(loan);
    }

    
    constructor (FundsInterface funds_, Medianizer med_, ERC20 token_, uint256 decimals_) public {
        require(address(funds_) != address(0), "Funds address must be non-zero");
        require(address(med_) != address(0), "Medianizer address must be non-zero");
        require(address(token_) != address(0), "Token address must be non-zero");

        deployer = msg.sender;
        funds = funds_;
        med = med_;
        token = token_;
        decimals = decimals_;
        require(token.approve(address(funds), MAX_UINT_256), "Token approve failed");
    }

    
    
    
    
    
    

    
    function setSales(SalesInterface sales_) external {
        require(msg.sender == deployer, "Loans.setSales: Only the deployer can perform this");
        require(address(sales) == address(0), "Loans.setSales: The Sales address has already been set");
        require(address(sales_) != address(0), "Loans.setSales: Sales address must be non-zero");
        sales = sales_;
    }

    
    function setCollateral(CollateralInterface col_) external {
        require(msg.sender == deployer, "Loans.setCollateral: Only the deployer can perform this");
        require(address(col) == address(0), "Loans.setCollateral: The Collateral address has already been set");
        require(address(col_) != address(0), "Loans.setCollateral: Collateral address must be non-zero");
        col = col_;
    }
    

    
    function create(
        uint256             loanExpiration_,
        address[3] calldata usrs_,
        uint256[7] calldata vals_,
        bytes32             fund
    ) external returns (bytes32 loan) {
        if (fund != bytes32(0)) {
            require(funds.lender(fund) == usrs_[1], "Loans.create: Lender of Fund not in args");
        }
        require(!addressToTimestamp[usrs_[0]][vals_[6]], "Loans.create: Duplicate request timestamps are not allowed");
        require(loanExpiration_ > now, "Loans.create: loanExpiration must be greater than `now`");
        require(usrs_[0] != address(0) && usrs_[1] != address(0), "Loans.create: Borrower and Lender address must be non-zero");
        require(vals_[0] != 0 && vals_[4] != 0, "Loans.create: Principal and Collateral must be non-zero");
        require(vals_[5] != 0 && vals_[6] != 0, "Loans.create: Liquidation ratio and Request timestamp must be non-zero");

        loanIndex = add(loanIndex, 1);
        loan = bytes32(loanIndex);
        loans[loan].createdAt = now;
        loans[loan].loanExpiration = loanExpiration_;
        loans[loan].borrower = usrs_[0];
        loans[loan].lender = usrs_[1];
        loans[loan].arbiter = usrs_[2];
        loans[loan].principal = vals_[0];
        loans[loan].interest = vals_[1];
        loans[loan].penalty = vals_[2];
        loans[loan].fee = vals_[3];
        uint256 minSeizableCol = minSeizableCollateral(loan);
        col.setCollateral(loan, sub(vals_[4], minSeizableCol), minSeizableCol);
        loans[loan].liquidationRatio = vals_[5];
        loans[loan].requestTimestamp = vals_[6];
        fundIndex[loan] = fund;
        secretHashes[loan].set = false;
        borrowerLoans[usrs_[0]].push(bytes32(loanIndex));
        lenderLoans[usrs_[1]].push(bytes32(loanIndex));
        addressToTimestamp[usrs_[0]][vals_[6]] = true;

        emit Create(loan);
    }

    
    function setSecretHashes(
        bytes32             loan,
        bytes32[4] calldata borrowerSecretHashes,
        bytes32[4] calldata lenderSecretHashes,
        bytes32[4] calldata arbiterSecretHashes,
        bytes      calldata borrowerPubKey_,
        bytes      calldata lenderPubKey_,
        bytes      calldata arbiterPubKey_
    ) external {
        require(!secretHashes[loan].set, "Loans.setSecretHashes: Secret hashes must not already be set");
        require(
            msg.sender == loans[loan].borrower || msg.sender == loans[loan].lender || msg.sender == address(funds),
            "Loans.setSecretHashes: msg.sender must be Borrower, Lender or Funds Address"
        );
        secretHashes[loan].secretHashA1 = borrowerSecretHashes[0];
        secretHashes[loan].secretHashAs = [ borrowerSecretHashes[1], borrowerSecretHashes[2], borrowerSecretHashes[3] ];
        secretHashes[loan].secretHashB1 = lenderSecretHashes[0];
        secretHashes[loan].secretHashBs = [ lenderSecretHashes[1], lenderSecretHashes[2], lenderSecretHashes[3] ];
        secretHashes[loan].secretHashC1 = arbiterSecretHashes[0];
        secretHashes[loan].secretHashCs = [ arbiterSecretHashes[1], arbiterSecretHashes[2], arbiterSecretHashes[3] ];
        pubKeys[loan].borrowerPubKey = borrowerPubKey_;
        pubKeys[loan].lenderPubKey = lenderPubKey_;
        pubKeys[loan].arbiterPubKey = arbiterPubKey_;
        secretHashes[loan].set = true;
    }

    
    function fund(bytes32 loan) external {
        require(secretHashes[loan].set, "Loans.fund: Secret hashes must be set");
        require(bools[loan].funded == false, "Loans.fund: Loan is already funded");
        bools[loan].funded = true;
        require(token.transferFrom(msg.sender, address(this), principal(loan)), "Loans.fund: Failed to transfer tokens");

        emit FundLoan(loan);
    }

    
    function approve(bytes32 loan) external { 
    	require(bools[loan].funded == true, "Loans.approve: Loan must be funded");
    	require(loans[loan].lender == msg.sender, "Loans.approve: Only the lender can approve the loan");
        require(now <= approveExpiration(loan), "Loans.approve: Loan is past the approve deadline");
    	bools[loan].approved = true;

        emit Approve(loan);
    }

    
    function withdraw(bytes32 loan, bytes32 secretA1) external {
        require(!off(loan), "Loans.withdraw: Loan cannot be inactive");
        require(bools[loan].funded == true, "Loans.withdraw: Loan must be funded");
        require(bools[loan].approved == true, "Loans.withdraw: Loan must be approved");
        require(bools[loan].withdrawn == false, "Loans.withdraw: Loan principal has already been withdrawn");
        require(sha256(abi.encodePacked(secretA1)) == secretHashes[loan].secretHashA1, "Loans.withdraw: Secret does not match");
        bools[loan].withdrawn = true;
        require(token.transfer(loans[loan].borrower, principal(loan)), "Loans.withdraw: Failed to transfer tokens");

        secretHashes[loan].withdrawSecret = secretA1;
        if (address(col.onDemandSpv()) != address(0)) {col.requestSpv(loan);}

        emit Withdraw(loan, secretA1);
    }

    
    function repay(bytes32 loan, uint256 amount) external {
        require(!off(loan), "Loans.repay: Loan cannot be inactive");
        require(!sale(loan), "Loans.repay: Loan cannot be undergoing a liquidation");
        require(bools[loan].withdrawn == true, "Loans.repay: Loan principal must be withdrawn");
        require(now <= loans[loan].loanExpiration, "Loans.repay: Loan cannot have expired");
        require(add(amount, repaid(loan)) <= owedForLoan(loan), "Loans.repay: Cannot repay more than the owed amount");
        require(token.transferFrom(msg.sender, address(this), amount), "Loans.repay: Failed to transfer tokens");
        repayments[loan] = add(amount, repayments[loan]);
        if (repaid(loan) == owedForLoan(loan)) {
            bools[loan].paid = true;
            if (address(col.onDemandSpv()) != address(0)) {col.cancelSpv(loan);}
        }

        emit Repay(loan, amount);
    }

    
    function refund(bytes32 loan) external {
        require(!off(loan), "Loans.refund: Loan cannot be inactive");
        require(!sale(loan), "Loans.refund: Loan cannot be undergoing a liquidation");
        require(now > acceptExpiration(loan), "Loans.refund: Cannot request refund until after acceptExpiration");
        require(bools[loan].paid == true, "Loans.refund: The loan must be repaid");
        require(msg.sender == loans[loan].borrower, "Loans.refund: Only the borrower can request a refund");
        bools[loan].off = true;
        loans[loan].closedTimestamp = now;
        if (funds.custom(fundIndex[loan]) == false) {
            funds.decreaseTotalBorrow(loans[loan].principal);
            funds.calcGlobalInterest();
        }
        require(token.transfer(loans[loan].borrower, owedForLoan(loan)), "Loans.refund: Failed to transfer tokens");

        emit Refund(loan);
    }

    
    function cancel(bytes32 loan, bytes32 secret) external {
        accept(loan, secret);

        emit Cancel(loan, secret);
    }

    
    function cancel(bytes32 loan) external {
        require(!off(loan), "Loans.cancel: Loan must not be inactive");
        require(bools[loan].withdrawn == false, "Loans.cancel: Loan principal must not be withdrawn");
        require(now >= seizureExpiration(loan), "Loans.cancel: Seizure deadline has not been reached");
        require(bools[loan].sale == false, "Loans.cancel: Loan must not be undergoing liquidation");
        close(loan);

        emit Cancel(loan, bytes32(0));
    }

    
    function accept(bytes32 loan, bytes32 secret) public {
        require(!off(loan), "Loans.accept: Loan must not be inactive");
        require(bools[loan].withdrawn == false || bools[loan].paid == true, "Loans.accept: Loan must be either not withdrawn or repaid");
        require(msg.sender == loans[loan].lender || msg.sender == loans[loan].arbiter, "Loans.accept: msg.sender must be lender or arbiter");
        require(now <= acceptExpiration(loan), "Loans.accept: Acceptance deadline has past");
        require(bools[loan].sale == false, "Loans.accept: Loan must not be going under liquidation");
        require(
            sha256(abi.encodePacked(secret)) == secretHashes[loan].secretHashB1 || sha256(abi.encodePacked(secret)) == secretHashes[loan].secretHashC1,
            "Loans.accept: Invalid secret"
        );
        secretHashes[loan].acceptSecret = secret;
        close(loan);

        emit Accept(loan, secret);
    }

    
    function close(bytes32 loan) private {
        bools[loan].off = true;
        loans[loan].closedTimestamp = now;
        
        if (bools[loan].withdrawn == false) {
            if (fundIndex[loan] == bytes32(0)) {
                require(token.transfer(loans[loan].lender, loans[loan].principal), "Loans.close: Failed to transfer principal to Lender");
            } else {
                if (funds.custom(fundIndex[loan]) == false) {
                    funds.decreaseTotalBorrow(loans[loan].principal);
                }
                funds.deposit(fundIndex[loan], loans[loan].principal);
            }
        }
        
        else {
            if (fundIndex[loan] == bytes32(0)) {
                require(token.transfer(loans[loan].lender, owedToLender(loan)), "Loans.close: Failed to transfer owedToLender to Lender");
            } else {
                if (funds.custom(fundIndex[loan]) == false) {
                    funds.decreaseTotalBorrow(loans[loan].principal);
                }
                funds.deposit(fundIndex[loan], owedToLender(loan));
            }
            require(token.transfer(loans[loan].arbiter, fee(loan)), "Loans.close: Failed to transfer fee to Arbiter");
        }
    }

    
    function liquidate(bytes32 loan, bytes32 secretHash, bytes20 pubKeyHash) external returns (bytes32 sale_) {
        require(!off(loan), "Loans.liquidate: Loan must not be inactive");
        require(bools[loan].withdrawn == true, "Loans.liquidate: Loan principal must be withdrawn");
        require(msg.sender != loans[loan].borrower && msg.sender != loans[loan].lender, "Loans.liquidate: Liquidator must be a third-party");
        require(secretHash != bytes32(0) && pubKeyHash != bytes20(0), "Loans.liquidate: secretHash and pubKeyHash must be non-zero");
        
        if (sales.next(loan) == 0) {
            
            if (now > loans[loan].loanExpiration) {
                require(bools[loan].paid == false, "Loans.liquidate: loan must not have already been repaid");
            } else {
                require(!safe(loan), "Loans.liquidate: collateralization must be below min-collateralization ratio");
            }
            
            if (funds.custom(fundIndex[loan]) == false) {
                funds.decreaseTotalBorrow(loans[loan].principal);
                funds.calcGlobalInterest();
            }
        } else {
            
            require(sales.next(loan) < MAX_NUM_LIQUIDATIONS, "Loans.liquidate: Max number of liquidations reached");
            require(!sales.accepted(sales.saleIndexByLoan(loan, sales.next(loan) - 1)), "Loans.liquidate: Previous liquidation already accepted");
            require(
                now > sales.settlementExpiration(sales.saleIndexByLoan(loan, sales.next(loan) - 1)),
                "Loans.liquidate: Previous liquidation settlement expiration hasn't expired"
            );
        }
        require(token.balanceOf(msg.sender) >= ddiv(discountCollateralValue(loan)), "Loans.liquidate: insufficient balance to liquidate");
        require(token.transferFrom(msg.sender, address(sales), ddiv(discountCollateralValue(loan))), "Loans.liquidate: Token transfer failed");
        SecretHashes storage h = secretHashes[loan];
        uint256 i = sales.next(loan);
        
        sale_ = sales.create(
            loan, loans[loan].borrower, loans[loan].lender, loans[loan].arbiter, msg.sender,
            h.secretHashAs[i], h.secretHashBs[i], h.secretHashCs[i], secretHash, pubKeyHash
        );
        if (bools[loan].sale == false) {
            bools[loan].sale = true;
            require(token.transfer(address(sales), repaid(loan)), "Loans.liquidate: Token transfer to Sales contract failed");
        }
        
        if (address(col.onDemandSpv()) != address(0)) {col.cancelSpv(loan);}

        emit Liquidate(loan, secretHash, pubKeyHash);
    }
}





contract ISPVRequestManager is DSMath {

  mapping (uint256 => Request) public requests;
  uint256 public requestIndex; 

  event NewProofRequest (
      address indexed _requester,
      uint256 indexed _requestID,
      uint64 _paysValue,
      bytes _spends,
      bytes _pays
  );

  event RequestClosed(uint256 indexed _requestID);
  event RequestFilled(bytes32 indexed _txid, uint256 indexed _requestID);

  struct Request {
    bytes32 spends;
    bytes32 pays;
    uint64  paysValue;
    uint8   state;
    address consumer;
    address requester;
    uint8   numConfs;
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  function request(
      bytes calldata _spends,
      bytes calldata _pays,
      uint64 _paysValue,
      address _consumer,
      uint8 _numConfs
  ) external returns (uint256) {
    requestIndex = add(requestIndex, 1);
    requests[requestIndex].paysValue = _paysValue;
    requests[requestIndex].spends    = keccak256(abi.encodePacked(_spends));
    requests[requestIndex].pays      = keccak256(abi.encodePacked(_pays));
    requests[requestIndex].state     = 1;
    requests[requestIndex].consumer  = _consumer;
    requests[requestIndex].requester = msg.sender;
    requests[requestIndex].numConfs  = _numConfs;

    emit NewProofRequest(msg.sender, requestIndex, _paysValue, _spends, _pays);
    return requestIndex;
  }

  
  
  
  
  function cancelRequest(uint256 _requestID) external returns (bool) {
    requests[_requestID].state = 2;
    emit RequestClosed(_requestID);
    return true;
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  function fillRequest(
    bytes32 _txid,
    bytes calldata _vin,
    bytes calldata _vout,
    uint256 _requestID,
    uint8 _inputIndex,
    uint8 _outputIndex
  ) external returns (bool) {
    ISPVConsumer onDemandSpv = ISPVConsumer(requests[_requestID].consumer);
    onDemandSpv.spv(_txid, _vin, _vout, _requestID, _inputIndex, _outputIndex);

    emit RequestFilled(_txid, _requestID);
    return true;
  }

  
  
  
  
  
  
  
  
  function getRequest(
      uint256 _requestID
  ) external view returns (
      bytes32 spends,
      bytes32 pays,
      uint64 paysValue,
      uint8 state,
      address consumer,
      address requester,
      uint8 numConfs
  ) {
    return (
      requests[_requestID].spends,
      requests[_requestID].pays,
      requests[_requestID].paysValue,
      requests[_requestID].state,
      requests[_requestID].consumer,
      requests[_requestID].requester,
      requests[_requestID].numConfs
    );
  }
}

contract Collateral is DSMath {
    P2WSHInterface p2wsh;
    Loans loans;
    ISPVRequestManager public onDemandSpv;

    uint256 public constant ADD_COLLATERAL_EXPIRY = 4 hours;

    mapping (bytes32 => CollateralDetails)   public collaterals;
    mapping (bytes32 => LoanRequests)        public loanRequests;
    mapping (uint256 => RequestDetails)      public requestsDetails;
    mapping (uint256 => uint256)             public finalRequestToInitialRequest;

    mapping (bytes32 => CollateralDetails)                     public temporaryCollaterals;
    mapping (bytes32 => mapping(uint256 => CollateralDeposit)) public collateralDeposits;
    mapping (bytes32 => uint256)                               public collateralDepositIndex;
    mapping (bytes32 => uint256)                               public collateralDepositFinalizedIndex;

    mapping (bytes32 => mapping(uint8 => uint256))             public txidToOutputIndexToCollateralDepositIndex;
    mapping (bytes32 => mapping(uint8 => bool))                public txidToOutputToRequestValid;

    address deployer;

    
    struct CollateralDetails {
        uint256 refundableCollateral;
        uint256 seizableCollateral;
        uint256 unaccountedRefundableCollateral; 
    }

    
    struct CollateralDeposit {
        uint256 amount;
        bool    finalized; 
        bool    seizable;
        uint256 expiry;
    }

    
    struct RequestDetails {
        bytes32 loan;
        bool    finalized;
        bool    seizable;
        bytes32 p2wshAddress;
    }

    
    struct LoanRequests {
        uint256 refundRequestIDOneConf;
        uint256 refundRequestIDSixConf;
        uint256 seizeRequestIDOneConf;
        uint256 seizeRequestIDSixConf;
    }

    event Spv(bytes32 _txid, bytes _vout, uint256 _requestID, uint8 _outputIndex);

    event RequestSpv(bytes32 loan);

    event CancelSpv(bytes32 loan);

    
    function collateral(bytes32 loan) public view returns (uint256) {
        
        
        
        
        
        if (collateralDepositIndex[loan] != collateralDepositFinalizedIndex[loan] &&
            add(collaterals[loan].seizableCollateral, temporaryCollaterals[loan].seizableCollateral) >= loans.minSeizableCollateral(loan) &&
            now < collateralDeposits[loan][collateralDepositFinalizedIndex[loan]].expiry) {
            return add(add(refundableCollateral(loan), seizableCollateral(loan)), add(temporaryCollaterals[loan].refundableCollateral, temporaryCollaterals[loan].seizableCollateral));
        } else {
            return add(refundableCollateral(loan), seizableCollateral(loan));
        }
    }

    
    function refundableCollateral(bytes32 loan) public view returns (uint256) {
        return collaterals[loan].refundableCollateral;
    }

    
    function seizableCollateral(bytes32 loan) public view returns (uint256) {
        return collaterals[loan].seizableCollateral;
    }

    
    function temporaryRefundableCollateral(bytes32 loan) external view returns (uint256) {
        return temporaryCollaterals[loan].refundableCollateral;
    }

    
    function temporarySeizableCollateral(bytes32 loan) external view returns (uint256) {
        return temporaryCollaterals[loan].seizableCollateral;
    }

    
    constructor (Loans loans_) public {
        require(address(loans_) != address(0), "Loans address must be non-zero");

        loans = loans_;
        deployer = msg.sender;
    }

    
    function setP2WSH(P2WSHInterface p2wsh_) external {
        require(msg.sender == deployer, "Loans.setP2WSH: Only the deployer can perform this");
        require(address(p2wsh) == address(0), "Loans.setP2WSH: The P2WSH address has already been set");
        require(address(p2wsh_) != address(0), "Loans.setP2WSH: P2WSH address must be non-zero");
        p2wsh = p2wsh_;
    }

    
    function setOnDemandSpv(ISPVRequestManager onDemandSpv_) external {
        require(msg.sender == deployer, "Loans.setOnDemandSpv: Only the deployer can perform this");
        require(address(onDemandSpv) == address(0), "Loans.setOnDemandSpv: The OnDemandSpv address has already been set");
        require(address(onDemandSpv_) != address(0), "Loans.setOnDemandSpv: OnDemandSpv address must be non-zero");
        onDemandSpv = onDemandSpv_;
    }

    
    function unsetOnDemandSpv() external {
        require(msg.sender == deployer, "Loans.setOnDemandSpv: Only the deployer can perform this");
        require(address(onDemandSpv) != address(0), "Loans.setOnDemandSpv: The OnDemandSpv address has not been set");
        onDemandSpv = ISPVRequestManager(address(0));
    }

    
    function setCollateral(bytes32 loan, uint256 refundableCollateral_, uint256 seizableCollateral_) external {
        require(msg.sender == address(loans), "Loans.setCollateral: Only the loans contract can perform this");

        collaterals[loan].refundableCollateral = refundableCollateral_;
        collaterals[loan].seizableCollateral = seizableCollateral_;
    }

    
    function spv(bytes32 _txid, bytes calldata, bytes calldata _vout, uint256 _requestID, uint8, uint8 _outputIndex) external {
        require(msg.sender == address(onDemandSpv), "Collateral.spv: Only the onDemandSpv can perform this");

        require(_txid != bytes32(0), "Collateral.spv: txid should be non-zero");
        require(BytesLib.toBytes32(_vout) != bytes32(0), "Collateral.spv: vout should be non-zero");

        bytes memory outputAtIndex = BTCUtils.extractOutputAtIndex(_vout, _outputIndex);
        uint256 amount = uint(BTCUtils.extractValue(outputAtIndex));

        bytes32 loan = requestsDetails[_requestID].loan;

        require(
            BytesLib.toBytes32(BTCUtils.extractHash(outputAtIndex)) == requestsDetails[_requestID].p2wshAddress,
            "Collateral.spv: Incorrect P2WSH address"
        );

        
        if (requestsDetails[_requestID].finalized) {
            
            if (txidToOutputToRequestValid[_txid][_outputIndex]) {
                
                if (requestsDetails[_requestID].seizable) {
                    
                    collaterals[loan].seizableCollateral = add(collaterals[loan].seizableCollateral, amount);

                    
                    temporaryCollaterals[loan].seizableCollateral = sub(temporaryCollaterals[loan].seizableCollateral, amount);
                } else {
                    
                    if (collaterals[loan].seizableCollateral >= loans.minSeizableCollateral(loan)) {
                        collaterals[loan].refundableCollateral = add(collaterals[loan].refundableCollateral, amount);
                    } else {
                        collaterals[loan].unaccountedRefundableCollateral = add(collaterals[loan].unaccountedRefundableCollateral, amount);
                    }

                    
                    temporaryCollaterals[loan].refundableCollateral = sub(temporaryCollaterals[loan].refundableCollateral, amount);
                }

                
                collateralDeposits[loan][txidToOutputIndexToCollateralDepositIndex[_txid][_outputIndex]].finalized = true;

                _updateCollateralDepositFinalizedIndex(loan);
            }
            
            else {
                
                if (amount >= div(collateral(loan), 100)) {
                    
                    txidToOutputToRequestValid[_txid][_outputIndex] = true;

                    _setCollateralDeposit(loan, collateralDepositIndex[loan], amount, requestsDetails[_requestID].seizable);
                    collateralDeposits[loan][collateralDepositIndex[loan]].finalized = true;
                    txidToOutputIndexToCollateralDepositIndex[_txid][_outputIndex] = collateralDepositIndex[loan];
                    collateralDepositIndex[loan] = add(collateralDepositIndex[loan], 1);

                    
                    if (requestsDetails[_requestID].seizable) {
                        
                        collaterals[loan].seizableCollateral = add(collaterals[loan].seizableCollateral, amount);
                    } else {
                        
                        collaterals[loan].refundableCollateral = add(collaterals[loan].refundableCollateral, amount);
                    }

                    _updateExistingRefundableCollateral(loan);
                    _updateCollateralDepositFinalizedIndex(loan);
                }
            }
        }
        
        else {
            
            if (amount >= div(collateral(loan), 100) && !txidToOutputToRequestValid[_txid][_outputIndex]) {
                
                txidToOutputToRequestValid[_txid][_outputIndex] = true;

                _setCollateralDeposit(loan, collateralDepositIndex[loan], amount, requestsDetails[_requestID].seizable);
                txidToOutputIndexToCollateralDepositIndex[_txid][_outputIndex] = collateralDepositIndex[loan];
                collateralDepositIndex[loan] = add(collateralDepositIndex[loan], 1);

                
                if (requestsDetails[_requestID].seizable) {
                    
                    temporaryCollaterals[loan].seizableCollateral = add(temporaryCollaterals[loan].seizableCollateral, amount);
                } else {
                    
                    temporaryCollaterals[loan].refundableCollateral = add(temporaryCollaterals[loan].refundableCollateral, amount);
                }

                _updateExistingRefundableCollateral(loan);
            }
        }

        emit Spv(_txid, _vout, _requestID, _outputIndex);
    }

    function _setCollateralDeposit (bytes32 loan, uint256 collateralDepositIndex_, uint256 amount_, bool seizable_) private {
        collateralDeposits[loan][collateralDepositIndex_].amount = amount_;
        collateralDeposits[loan][collateralDepositIndex_].seizable = seizable_;
        collateralDeposits[loan][collateralDepositIndex_].expiry = now + ADD_COLLATERAL_EXPIRY;
    }

    function _updateExistingRefundableCollateral (bytes32 loan) private {
        if (add(collaterals[loan].seizableCollateral, temporaryCollaterals[loan].seizableCollateral) >= loans.minSeizableCollateral(loan) &&
            collaterals[loan].unaccountedRefundableCollateral != 0) {
            collaterals[loan].refundableCollateral = add(collaterals[loan].refundableCollateral, collaterals[loan].unaccountedRefundableCollateral);
            collaterals[loan].unaccountedRefundableCollateral = 0;
        }
    }

    function _updateCollateralDepositFinalizedIndex (bytes32 loan) private {
        
        for (uint i = collateralDepositFinalizedIndex[loan]; i <= collateralDepositIndex[loan]; i++) {
            if (collateralDeposits[loan][i].finalized == true) {
                collateralDepositFinalizedIndex[loan] = add(collateralDepositFinalizedIndex[loan], 1);
            } else {
                break;
            }
        }
    }

    
    function requestSpv(bytes32 loan) external {
        require(msg.sender == address(loans), "Collateral.requestSpv: Only the loans contract can perform this");

        (, bytes32 refundableP2WSH) = p2wsh.getP2WSH(loan, false); 
        (, bytes32 seizableP2WSH) = p2wsh.getP2WSH(loan, true); 

        uint256 onePercentOfCollateral = div(collateral(loan), 100);

        uint256 refundRequestIDOneConf = onDemandSpv
            .request(hex"", abi.encodePacked(hex"220020", refundableP2WSH), uint64(onePercentOfCollateral), address(this), 1);
        uint256 refundRequestIDSixConf = onDemandSpv
            .request(hex"", abi.encodePacked(hex"220020", refundableP2WSH), uint64(onePercentOfCollateral), address(this), 6);

        uint256 seizeRequestIDOneConf = onDemandSpv
            .request(hex"", abi.encodePacked(hex"220020", seizableP2WSH), uint64(onePercentOfCollateral), address(this), 1);
        uint256 seizeRequestIDSixConf = onDemandSpv
            .request(hex"", abi.encodePacked(hex"220020", seizableP2WSH), uint64(onePercentOfCollateral), address(this), 6);

        loanRequests[loan].refundRequestIDOneConf = refundRequestIDOneConf;
        loanRequests[loan].refundRequestIDSixConf = refundRequestIDSixConf;
        loanRequests[loan].seizeRequestIDOneConf = seizeRequestIDOneConf;
        loanRequests[loan].seizeRequestIDSixConf = seizeRequestIDSixConf;

        requestsDetails[refundRequestIDOneConf].loan = loan;
        requestsDetails[refundRequestIDOneConf].p2wshAddress = refundableP2WSH;

        requestsDetails[refundRequestIDSixConf].loan = loan;
        requestsDetails[refundRequestIDSixConf].finalized = true;
        requestsDetails[refundRequestIDSixConf].p2wshAddress = refundableP2WSH;

        finalRequestToInitialRequest[refundRequestIDSixConf] = refundRequestIDOneConf;

        requestsDetails[seizeRequestIDOneConf].loan = loan;
        requestsDetails[seizeRequestIDOneConf].seizable = true;
        requestsDetails[seizeRequestIDOneConf].p2wshAddress = seizableP2WSH;

        requestsDetails[seizeRequestIDSixConf].loan = loan;
        requestsDetails[seizeRequestIDSixConf].seizable = true;
        requestsDetails[seizeRequestIDSixConf].finalized = true;
        requestsDetails[seizeRequestIDSixConf].p2wshAddress = seizableP2WSH;

        finalRequestToInitialRequest[seizeRequestIDSixConf] = seizeRequestIDOneConf;

        emit RequestSpv(loan);
    }

    
    function cancelSpv(bytes32 loan) external {
        require(msg.sender == address(loans), "Collateral.cancelSpv: Only the loans contract can perform this");

        require(onDemandSpv.cancelRequest(loanRequests[loan].refundRequestIDOneConf), "Collateral.cancelSpv: refundRequestIDOneConf failed");
        require(onDemandSpv.cancelRequest(loanRequests[loan].refundRequestIDSixConf), "Collateral.cancelSpv: refundRequestIDSixConf failed");
        require(onDemandSpv.cancelRequest(loanRequests[loan].seizeRequestIDOneConf), "Collateral.cancelSpv: seizeRequestIDOneConf failed");
        require(onDemandSpv.cancelRequest(loanRequests[loan].seizeRequestIDSixConf), "Collateral.cancelSpv: seizeRequestIDSixConf failed");

        emit CancelSpv(loan);
    }
}