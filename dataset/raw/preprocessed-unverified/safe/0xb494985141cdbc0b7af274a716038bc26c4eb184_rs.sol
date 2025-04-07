/**
 *Submitted for verification at Etherscan.io on 2020-02-24
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

    uint256 public constant APPROVE_EXP_THRESHOLD = 4 hours;    
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









contract Helpers is DSMath {

    address public comptroller;

    
    function getComptrollerAddress() public view returns (address) {
        
        
        
        return comptroller;
    }

    function enterMarket(address cErc20) internal {
        TrollerInterface troller = TrollerInterface(getComptrollerAddress());
        address[] memory markets = troller.getAssetsIn(address(this));
        bool isEntered = false;
        for (uint i = 0; i < markets.length; i++) {
            if (markets[i] == cErc20) {
                isEntered = true;
            }
        }
        if (!isEntered) {
            address[] memory toEnter = new address[](1);
            toEnter[0] = cErc20;
            troller.enterMarkets(toEnter);
        }
    }

    
    function setApproval(address erc20, uint srcAmt, address to) internal {
        ERC20Interface erc20Contract = ERC20Interface(erc20);
        uint tokenAllowance = erc20Contract.allowance(address(this), to);
        if (srcAmt > tokenAllowance) {
            erc20Contract.approve(to, 2**255);
        }
    }

}

contract ALCompound is Helpers {
    
    function mintCToken(address erc20, address cErc20, uint tokenAmt) internal {
        enterMarket(cErc20);
        ERC20Interface token = ERC20Interface(erc20);
        uint toDeposit = token.balanceOf(address(this));
        if (toDeposit > tokenAmt) {
            toDeposit = tokenAmt;
        }
        CERC20Interface cToken = CERC20Interface(cErc20);
        setApproval(erc20, toDeposit, cErc20);
        assert(cToken.mint(toDeposit) == 0);
    }

    
    function redeemUnderlying(address cErc20, uint tokenAmt) internal {
        CTokenInterface cToken = CTokenInterface(cErc20);
        setApproval(cErc20, 10**50, cErc20);
        uint toBurn = cToken.balanceOf(address(this));
        uint tokenToReturn = wmul(toBurn, cToken.exchangeRateCurrent());
        if (tokenToReturn > tokenAmt) {
            tokenToReturn = tokenAmt;
        }
        require(cToken.redeemUnderlying(tokenToReturn) == 0, "something went wrong");
    }

    
    function redeemCToken(address cErc20, uint cTokenAmt) internal {
        CTokenInterface cToken = CTokenInterface(cErc20);
        uint toBurn = cToken.balanceOf(address(this));
        if (toBurn > cTokenAmt) {
            toBurn = cTokenAmt;
        }
        setApproval(cErc20, toBurn, cErc20);
        require(cToken.redeem(toBurn) == 0, "something went wrong");
    }
}

contract Funds is DSMath, ALCompound {
    Loans loans;

    uint256 public constant DEFAULT_LIQUIDATION_RATIO = 1400000000000000000000000000;   
    uint256 public constant DEFAULT_LIQUIDATION_PENALTY = 1000000000937303470807876289; 
    uint256 public constant DEFAULT_MIN_LOAN_AMT = 25 ether; 
    uint256 public constant DEFAULT_MAX_LOAN_AMT = 2**256-1; 
    uint256 public constant DEFAULT_MIN_LOAN_DUR = 6 hours;  
    uint256 public constant NUM_SECONDS_IN_YEAR = 365 days;
    uint256 public constant MAX_LOAN_LENGTH = 10 * NUM_SECONDS_IN_YEAR;
    uint256 public constant MAX_UINT_256 = 2**256-1;

    mapping (address => bytes32[]) public secretHashes;    
    mapping (address => uint256)   public secretHashIndex; 

    mapping (address => bytes)     public pubKeys;  

    mapping (bytes32 => Fund)      public funds;
    mapping (address => bytes32)   public fundOwner;
    mapping (bytes32 => Bools)     public bools;
    uint256                        public fundIndex;

    uint256 public lastGlobalInterestUpdated;
    uint256 public tokenMarketLiquidity;
    uint256 public cTokenMarketLiquidity;
    uint256 public marketLiquidity;
    uint256 public totalBorrow;
    uint256 public globalInterestRateNumerator;
    uint256 public lastUtilizationRatio;
    uint256 public globalInterestRate;
    uint256 public maxUtilizationDelta;
    uint256 public utilizationInterestDivisor;
    uint256 public maxInterestRateNumerator;
    uint256 public minInterestRateNumerator;
    uint256 public interestUpdateDelay;
    uint256 public defaultArbiterFee;

    ERC20 public token;
    uint256 public decimals;
    CTokenInterface public cToken;
    bool compoundSet;

    address deployer;

    
    struct Fund {
        address  lender;
        uint256  minLoanAmt;
        uint256  maxLoanAmt;
        uint256  minLoanDur;
        uint256  maxLoanDur;
        uint256  fundExpiry;
        uint256  interest;
        uint256  penalty;
        uint256  fee;
        uint256  liquidationRatio;
        address  arbiter;
        uint256  balance;
        uint256  cBalance;
    }

    
    struct Bools {
        bool     custom;
        bool     compoundEnabled;
    }

    event Create(bytes32 fund);

    event Deposit(bytes32 fund, uint256 amount_);

    event Update(bytes32  fund, uint256  maxLoanDur_, uint256  fundExpiry_, address  arbiter_);

    event Request(bytes32 fund, address borrower_, uint256 amount_, uint256 collateral_, uint256 loanDur_, uint256 requestTimestamp_);

    event Withdraw(bytes32 fund, uint256 amount_, address recipient_);

    event EnableCompound(bytes32 fund);

    event DisableCompound(bytes32 fund);

    
    
    constructor(
        ERC20   token_,
        uint256 decimals_
    ) public {
        require(address(token_) != address(0), "Funds.constructor: Token address must be non-zero");
        require(decimals_ != 0, "Funds.constructor: Decimals must be non-zero");

        deployer = msg.sender;
        token = token_;
        decimals = decimals_;
        utilizationInterestDivisor = 10531702972595856680093239305; 
        maxUtilizationDelta = 95310179948351216961192521; 
        globalInterestRateNumerator = 95310179948351216961192521; 
        maxInterestRateNumerator = 182321557320989604265864303; 
        minInterestRateNumerator = 24692612600038629323181834; 
        interestUpdateDelay = 86400; 
        defaultArbiterFee = 1000000000236936036262880196; 
        globalInterestRate = add(RAY, div(globalInterestRateNumerator, NUM_SECONDS_IN_YEAR)); 
    }

    
    
    
    
    
    

    
    function setLoans(Loans loans_) external {
        require(msg.sender == deployer, "Funds.setLoans: Only the deployer can perform this");
        require(address(loans) == address(0), "Funds.setLoans: Loans address has already been set");
        require(address(loans_) != address(0), "Funds.setLoans: Loans address must be non-zero");
        loans = loans_;
        require(token.approve(address(loans_), MAX_UINT_256), "Funds.setLoans: Tokens cannot be approved");
    }

    
    function setCompound(CTokenInterface cToken_, address comptroller_) external {
        require(msg.sender == deployer, "Funds.setCompound: Only the deployer can enable Compound lending");
        require(!compoundSet, "Funds.setCompound: Compound address has already been set");
        require(address(cToken_) != address(0), "Funds.setCompound: cToken address must be non-zero");
        require(comptroller_ != address(0), "Funds.setCompound: comptroller address must be non-zero");
        cToken = cToken_;
        comptroller = comptroller_;
        compoundSet = true;
    }
    

    
    
    
    
    
    
    

    
    function setUtilizationInterestDivisor(uint256 utilizationInterestDivisor_) external {
        require(msg.sender == deployer, "Funds.setUtilizationInterestDivisor: Only the deployer can perform this");
        require(utilizationInterestDivisor_ != 0, "Funds.setUtilizationInterestDivisor: utilizationInterestDivisor is zero");
        utilizationInterestDivisor = utilizationInterestDivisor_;
    }

    
    function setMaxUtilizationDelta(uint256 maxUtilizationDelta_) external {
        require(msg.sender == deployer, "Funds.setMaxUtilizationDelta: Only the deployer can perform this");
        require(maxUtilizationDelta_ != 0, "Funds.setMaxUtilizationDelta: maxUtilizationDelta is zero");
        maxUtilizationDelta = maxUtilizationDelta_;
    }

    
    function setGlobalInterestRateNumerator(uint256 globalInterestRateNumerator_) external {
        require(msg.sender == deployer, "Funds.setGlobalInterestRateNumerator: Only the deployer can perform this");
        require(globalInterestRateNumerator_ != 0, "Funds.setGlobalInterestRateNumerator: globalInterestRateNumerator is zero");
        globalInterestRateNumerator = globalInterestRateNumerator_;
    }

    
    function setGlobalInterestRate(uint256 globalInterestRate_) external {
        require(msg.sender == deployer, "Funds.setGlobalInterestRate: Only the deployer can perform this");
        require(globalInterestRate_ != 0, "Funds.setGlobalInterestRate: globalInterestRate is zero");
        globalInterestRate = globalInterestRate_;
    }

    
    function setMaxInterestRateNumerator(uint256 maxInterestRateNumerator_) external {
        require(msg.sender == deployer, "Funds.setMaxInterestRateNumerator: Only the deployer can perform this");
        require(maxInterestRateNumerator_ != 0, "Funds.setMaxInterestRateNumerator: maxInterestRateNumerator is zero");
        maxInterestRateNumerator = maxInterestRateNumerator_;
    }

    
    function setMinInterestRateNumerator(uint256 minInterestRateNumerator_) external {
        require(msg.sender == deployer, "Funds.setMinInterestRateNumerator: Only the deployer can perform this");
        require(minInterestRateNumerator_ != 0, "Funds.setMinInterestRateNumerator: minInterestRateNumerator is zero");
        minInterestRateNumerator = minInterestRateNumerator_;
    }

    
    function setInterestUpdateDelay(uint256 interestUpdateDelay_) external {
        require(msg.sender == deployer, "Funds.setInterestUpdateDelay: Only the deployer can perform this");
        require(interestUpdateDelay_ != 0, "Funds.setInterestUpdateDelay: interestUpdateDelay is zero");
        interestUpdateDelay = interestUpdateDelay_;
    }

    
    function setDefaultArbiterFee(uint256 defaultArbiterFee_) external {
        require(msg.sender == deployer, "Funds.setDefaultArbiterFee: Only the deployer can perform this");
        require(defaultArbiterFee_ <= 1000000000315522921573372069, "Funds.setDefaultArbiterFee: defaultArbiterFee cannot be less than -1%"); 
        defaultArbiterFee = defaultArbiterFee_;
    }
    

    
    function lender(bytes32 fund) public view returns (address) {
        return funds[fund].lender;
    }

    
    function minLoanAmt(bytes32 fund) public view returns (uint256) {
        if (bools[fund].custom) {return funds[fund].minLoanAmt;}
        else                    {return div(DEFAULT_MIN_LOAN_AMT, (10 ** sub(18, decimals)));}
    }

    
    function maxLoanAmt(bytes32 fund) public view returns (uint256) {
        if (bools[fund].custom) {return funds[fund].maxLoanAmt;}
        else                    {return DEFAULT_MAX_LOAN_AMT;}
    }

    
    function minLoanDur(bytes32 fund) public view returns (uint256) {
        if (bools[fund].custom) {return funds[fund].minLoanDur;}
        else                    {return DEFAULT_MIN_LOAN_DUR;}
    }

    
    function maxLoanDur(bytes32 fund) public view returns (uint256) {
        return funds[fund].maxLoanDur;
    }

    
    function fundExpiry(bytes32 fund) public view returns (uint256) {
        return funds[fund].fundExpiry;
    }

    
    function interest(bytes32 fund) public view returns (uint256) {
        if (bools[fund].custom) {return funds[fund].interest;}
        else                    {return globalInterestRate;}
    }

    
    function penalty(bytes32 fund) public view returns (uint256) {
        if (bools[fund].custom) {return funds[fund].penalty;}
        else                    {return DEFAULT_LIQUIDATION_PENALTY;}
    }

    
    function fee(bytes32 fund) public view returns (uint256) {
        if (bools[fund].custom) {return funds[fund].fee;}
        else                    {return defaultArbiterFee;}
    }

    
    function liquidationRatio(bytes32 fund) public view returns (uint256) {
        if (bools[fund].custom) {return funds[fund].liquidationRatio;}
        else                    {return DEFAULT_LIQUIDATION_RATIO;}
    }

    
    function arbiter(bytes32 fund) public view returns (address) {
        return funds[fund].arbiter;
    }

    
    function balance(bytes32 fund) public returns (uint256) {
        if (bools[fund].compoundEnabled) {
            return wmul(funds[fund].cBalance, cToken.exchangeRateCurrent());
        } else {
            return funds[fund].balance;
        }
    }

    function cTokenExchangeRate() public returns (uint256) {
        if (compoundSet) {
            return cToken.exchangeRateCurrent();
        } else {
            return 0;
        }
    }

    
    function custom(bytes32 fund) public view returns (bool) {
        return bools[fund].custom;
    }

    
    function secretHashesCount(address addr_) public view returns (uint256) {
        return secretHashes[addr_].length;
    }

    
    function create(
        uint256  maxLoanDur_,
        uint256  fundExpiry_,
        address  arbiter_,
        bool     compoundEnabled_,
        uint256  amount_
    ) external returns (bytes32 fund) {
        
        
        
        require(funds[fundOwner[msg.sender]].lender != msg.sender, "Funds.create: Only one loan fund allowed per address"); 
        
        require(
            ensureNotZero(maxLoanDur_, false) < MAX_LOAN_LENGTH && ensureNotZero(fundExpiry_, true) < now + MAX_LOAN_LENGTH,
            "Funds.create: fundExpiry and maxLoanDur cannot exceed 10 years"
        ); 
        if (!compoundSet) {require(compoundEnabled_ == false, "Funds.create: Cannot enable Compound as it has not been configured");}
        fundIndex = add(fundIndex, 1);
        fund = bytes32(fundIndex);
        funds[fund].lender = msg.sender;
        funds[fund].maxLoanDur = ensureNotZero(maxLoanDur_, false);
        funds[fund].fundExpiry = ensureNotZero(fundExpiry_, true);
        funds[fund].arbiter = arbiter_;
        bools[fund].custom = false;
        bools[fund].compoundEnabled = compoundEnabled_;
        fundOwner[msg.sender] = bytes32(fundIndex);
        if (amount_ > 0) {deposit(fund, amount_);}

        emit Create(fund);
    }

    
    function createCustom(
        uint256  minLoanAmt_,
        uint256  maxLoanAmt_,
        uint256  minLoanDur_,
        uint256  maxLoanDur_,
        uint256  fundExpiry_,
        uint256  liquidationRatio_,
        uint256  interest_,
        uint256  penalty_,
        uint256  fee_,
        address  arbiter_,
        bool     compoundEnabled_,
        uint256  amount_
    ) external returns (bytes32 fund) {
        
        
        
        require(funds[fundOwner[msg.sender]].lender != msg.sender, "Funds.create: Only one loan fund allowed per address"); 
        
        require(
            ensureNotZero(maxLoanDur_, false) < MAX_LOAN_LENGTH && ensureNotZero(fundExpiry_, true) < now + MAX_LOAN_LENGTH,
            "Funds.createCustom: fundExpiry and maxLoanDur cannot exceed 10 years"
        ); 
        require(maxLoanAmt_ >= minLoanAmt_, "Funds.createCustom: maxLoanAmt must be greater than or equal to minLoanAmt");
        require(ensureNotZero(maxLoanDur_, false) >= minLoanDur_, "Funds.createCustom: maxLoanDur must be greater than or equal to minLoanDur");

        if (!compoundSet) {require(compoundEnabled_ == false, "Funds.createCustom: Cannot enable Compound as it has not been configured");}
        fundIndex = add(fundIndex, 1);
        fund = bytes32(fundIndex);
        funds[fund].lender = msg.sender;
        funds[fund].minLoanAmt = minLoanAmt_;
        funds[fund].maxLoanAmt = maxLoanAmt_;
        funds[fund].minLoanDur = minLoanDur_;
        funds[fund].maxLoanDur = ensureNotZero(maxLoanDur_, false);
        funds[fund].fundExpiry = ensureNotZero(fundExpiry_, true);
        funds[fund].interest = interest_;
        funds[fund].penalty = penalty_;
        funds[fund].fee = fee_;
        funds[fund].liquidationRatio = liquidationRatio_;
        funds[fund].arbiter = arbiter_;
        bools[fund].custom = true;
        bools[fund].compoundEnabled = compoundEnabled_;
        fundOwner[msg.sender] = bytes32(fundIndex);
        if (amount_ > 0) {deposit(fund, amount_);}

        emit Create(fund);
    }

    
    function deposit(bytes32 fund, uint256 amount_) public {
        require(token.transferFrom(msg.sender, address(this), amount_), "Funds.deposit: Failed to transfer tokens");
        if (bools[fund].compoundEnabled) {
            mintCToken(address(token), address(cToken), amount_);
            uint256 cTokenToAdd = div(mul(amount_, WAD), cToken.exchangeRateCurrent());
            funds[fund].cBalance = add(funds[fund].cBalance, cTokenToAdd);
            if (!custom(fund)) {cTokenMarketLiquidity = add(cTokenMarketLiquidity, cTokenToAdd);}
        } else {
            funds[fund].balance = add(funds[fund].balance, amount_);
            if (!custom(fund)) {tokenMarketLiquidity = add(tokenMarketLiquidity, amount_);}
        }
        if (!custom(fund)) {calcGlobalInterest();}

        emit Deposit(fund, amount_);
    }

    
    function update(
        bytes32  fund,
        uint256  maxLoanDur_,
        uint256  fundExpiry_,
        address  arbiter_
    ) public {
        require(msg.sender == lender(fund), "Funds.update: Only the lender can update the fund");
        require(
            ensureNotZero(maxLoanDur_, false) <= MAX_LOAN_LENGTH && ensureNotZero(fundExpiry_, true) <= now + MAX_LOAN_LENGTH,
            "Funds.update: fundExpiry and maxLoanDur cannot exceed 10 years"
        );  
        funds[fund].maxLoanDur = maxLoanDur_;
        funds[fund].fundExpiry = fundExpiry_;
        funds[fund].arbiter = arbiter_;

        emit Update(fund, maxLoanDur_, fundExpiry_, arbiter_);
    }

    
    function updateCustom(
        bytes32  fund,
        uint256  minLoanAmt_,
        uint256  maxLoanAmt_,
        uint256  minLoanDur_,
        uint256  maxLoanDur_,
        uint256  fundExpiry_,
        uint256  interest_,
        uint256  penalty_,
        uint256  fee_,
        uint256  liquidationRatio_,
        address  arbiter_
    ) external {
        require(bools[fund].custom, "Funds.updateCustom: Fund must be a custom fund");
        require(maxLoanAmt_ >= minLoanAmt_, "Funds.updateCustom: maxLoanAmt must be greater than or equal to minLoanAmt");
        require(ensureNotZero(maxLoanDur_, false) >= minLoanDur_, "Funds.updateCustom: maxLoanDur must be greater than or equal to minLoanDur");
        update(fund, maxLoanDur_, fundExpiry_, arbiter_);
        funds[fund].minLoanAmt = minLoanAmt_;
        funds[fund].maxLoanAmt = maxLoanAmt_;
        funds[fund].minLoanDur = minLoanDur_;
        funds[fund].interest = interest_;
        funds[fund].penalty = penalty_;
        funds[fund].fee = fee_;
        funds[fund].liquidationRatio = liquidationRatio_;
    }

    
    function request(
        bytes32             fund,
        address             borrower_,
        uint256             amount_,
        uint256             collateral_,
        uint256             loanDur_,
        uint256             requestTimestamp_,
        bytes32[8] calldata secretHashes_,
        bytes      calldata pubKeyA_,
        bytes      calldata pubKeyB_
    ) external returns (bytes32 loanIndex) {
        require(msg.sender == lender(fund), "Funds.request: Only the lender can fulfill a loan request");
        require(amount_ <= balance(fund), "Funds.request: Insufficient balance");
        require(amount_ >= minLoanAmt(fund), "Funds.request: Amount requested must be greater than minLoanAmt");
        require(amount_ <= maxLoanAmt(fund), "Funds.request: Amount requested must be less than maxLoanAmt");
        require(loanDur_ >= minLoanDur(fund), "Funds.request: Loan duration must be greater than minLoanDur");
        require(loanDur_ <= sub(fundExpiry(fund), now) && loanDur_ <= maxLoanDur(fund), "Funds.request: Loan duration must be less than maxLoanDur and expiry");
        require(borrower_ != address(0), "Funds.request: Borrower address must be non-zero");
        require(secretHashes_[0] != bytes32(0) && secretHashes_[1] != bytes32(0), "Funds.request: SecretHash1 & SecretHash2 should be non-zero");
        require(secretHashes_[2] != bytes32(0) && secretHashes_[3] != bytes32(0), "Funds.request: SecretHash3 & SecretHash4 should be non-zero");
        require(secretHashes_[4] != bytes32(0) && secretHashes_[5] != bytes32(0), "Funds.request: SecretHash5 & SecretHash6 should be non-zero");
        require(secretHashes_[6] != bytes32(0) && secretHashes_[7] != bytes32(0), "Funds.request: SecretHash7 & SecretHash8 should be non-zero");

        loanIndex = createLoan(fund, borrower_, amount_, collateral_, loanDur_, requestTimestamp_);
        loanSetSecretHashes(fund, loanIndex, secretHashes_, pubKeyA_, pubKeyB_);
        loanUpdateMarketLiquidity(fund, amount_);
        loans.fund(loanIndex);

        emit Request(fund, borrower_, amount_, collateral_, loanDur_, requestTimestamp_);
    }

    
    function withdraw(bytes32 fund, uint256 amount_) external {
        withdrawTo(fund, amount_, msg.sender);
    }

    
    function withdrawTo(bytes32 fund, uint256 amount_, address recipient_) public {
        require(msg.sender == lender(fund), "Funds.withdrawTo: Only the lender can withdraw tokens");
        require(balance(fund) >= amount_, "Funds.withdrawTo: Insufficient balance");
        if (bools[fund].compoundEnabled) {
            uint256 cBalanceBefore = cToken.balanceOf(address(this));
            redeemUnderlying(address(cToken), amount_);
            uint256 cBalanceAfter = cToken.balanceOf(address(this));
            uint256 cTokenToRemove = sub(cBalanceBefore, cBalanceAfter);
            funds[fund].cBalance = sub(funds[fund].cBalance, cTokenToRemove);
            require(token.transfer(recipient_, amount_), "Funds.withdrawTo: Token transfer failed");
            if (!custom(fund)) {cTokenMarketLiquidity = sub(cTokenMarketLiquidity, cTokenToRemove);}
        } else {
            funds[fund].balance = sub(funds[fund].balance, amount_);
            require(token.transfer(recipient_, amount_), "Funds.withdrawTo: Token transfer failed");
            if (!custom(fund)) {tokenMarketLiquidity = sub(tokenMarketLiquidity, amount_);}
        }
        if (!custom(fund)) {calcGlobalInterest();}

        emit Withdraw(fund, amount_, recipient_);
    }

    
    function generate(bytes32[] calldata secretHashes_) external {
        for (uint i = 0; i < secretHashes_.length; i++) {
            secretHashes[msg.sender].push(secretHashes_[i]);
        }
    }

    
    function setPubKey(bytes calldata pubKey_) external { 
        pubKeys[msg.sender] = pubKey_;
    }

    
    function enableCompound(bytes32 fund) external {
        require(compoundSet, "Funds.enableCompound: Cannot enable Compound as it has not been configured");
        require(bools[fund].compoundEnabled == false, "Funds.enableCompound: Compound is already enabled");
        require(msg.sender == lender(fund), "Funds.enableCompound: Only the lender can enable Compound");
        uint256 cBalanceBefore = cToken.balanceOf(address(this));
        mintCToken(address(token), address(cToken), funds[fund].balance);
        uint256 cBalanceAfter = cToken.balanceOf(address(this));
        uint256 cTokenToReturn = sub(cBalanceAfter, cBalanceBefore);
        tokenMarketLiquidity = sub(tokenMarketLiquidity, funds[fund].balance);
        cTokenMarketLiquidity = add(cTokenMarketLiquidity, cTokenToReturn);
        bools[fund].compoundEnabled = true;
        funds[fund].balance = 0;
        funds[fund].cBalance = cTokenToReturn;

        emit EnableCompound(fund);
    }

    
    function disableCompound(bytes32 fund) external {
        require(bools[fund].compoundEnabled, "Funds.disableCompound: Compound is already disabled");
        require(msg.sender == lender(fund), "Funds.disableCompound: Only the lender can disable Compound");
        uint256 balanceBefore = token.balanceOf(address(this));
        redeemCToken(address(cToken), funds[fund].cBalance);
        uint256 balanceAfter = token.balanceOf(address(this));
        uint256 tokenToReturn = sub(balanceAfter, balanceBefore);
        tokenMarketLiquidity = add(tokenMarketLiquidity, tokenToReturn);
        cTokenMarketLiquidity = sub(cTokenMarketLiquidity, funds[fund].cBalance);
        bools[fund].compoundEnabled = false;
        funds[fund].cBalance = 0;
        funds[fund].balance = tokenToReturn;

        emit DisableCompound(fund);
    }

    
    function decreaseTotalBorrow(uint256 amount_) external {
        require(msg.sender == address(loans), "Funds.decreaseTotalBorrow: Only the Loans contract can perform this");
        totalBorrow = sub(totalBorrow, amount_);
    }

    
    function calcGlobalInterest() public {
        marketLiquidity = add(tokenMarketLiquidity, wmul(cTokenMarketLiquidity, cTokenExchangeRate()));

        if (now > (add(lastGlobalInterestUpdated, interestUpdateDelay))) {
            uint256 utilizationRatio;
            if (totalBorrow != 0) {utilizationRatio = rdiv(totalBorrow, add(marketLiquidity, totalBorrow));}

            if (utilizationRatio > lastUtilizationRatio) {
                uint256 changeUtilizationRatio = sub(utilizationRatio, lastUtilizationRatio);
                globalInterestRateNumerator = min(maxInterestRateNumerator, add(globalInterestRateNumerator, rdiv(min(maxUtilizationDelta, changeUtilizationRatio), utilizationInterestDivisor)));
            } else {
                uint256 changeUtilizationRatio = sub(lastUtilizationRatio, utilizationRatio);
                globalInterestRateNumerator = max(minInterestRateNumerator, sub(globalInterestRateNumerator, rdiv(min(maxUtilizationDelta, changeUtilizationRatio), utilizationInterestDivisor)));
            }

            globalInterestRate = add(RAY, div(globalInterestRateNumerator, NUM_SECONDS_IN_YEAR));

            lastGlobalInterestUpdated = now;
            lastUtilizationRatio = utilizationRatio;
        }
    }

    
    function calcInterest(uint256 amount_, uint256 rate_, uint256 loanDur_) public pure returns (uint256) {
        return sub(rmul(amount_, rpow(rate_, loanDur_)), amount_);
    }

    
    function ensureNotZero(uint256 value, bool addNow) public view returns (uint256) {
        if (value == 0) {
            if (addNow) {
                return now + MAX_LOAN_LENGTH;
            }
            return MAX_LOAN_LENGTH;
        }
        return value;
    }

    
    function createLoan(
        bytes32  fund,
        address  borrower_,
        uint256  amount_,
        uint256  collateral_,
        uint256  loanDur_,
        uint256  requestTimestamp_
    ) private returns (bytes32 loanIndex) {
        loanIndex = loans.create(
            now + loanDur_,
            [borrower_, lender(fund), funds[fund].arbiter],
            [
                amount_,
                calcInterest(amount_, interest(fund), loanDur_),
                calcInterest(amount_, penalty(fund), loanDur_),
                calcInterest(amount_, fee(fund), loanDur_),
                collateral_,
                liquidationRatio(fund),
                requestTimestamp_
            ],
            fund
        );
    }

    
    function loanSetSecretHashes(
        bytes32           fund,
        bytes32           loan,
        bytes32[8] memory secretHashes_,
        bytes      memory pubKeyA_,
        bytes      memory pubKeyB_
    ) private {
        loans.setSecretHashes(
            loan,
            [ secretHashes_[0], secretHashes_[1], secretHashes_[2], secretHashes_[3] ],
            [ secretHashes_[4], secretHashes_[5], secretHashes_[6], secretHashes_[7] ],
            getSecretHashesForLoan(arbiter(fund)),
            pubKeyA_,
            pubKeyB_,
            pubKeys[arbiter(fund)]
        );
    }

    
    function loanUpdateMarketLiquidity(bytes32 fund, uint256 amount_) private {
        if (bools[fund].compoundEnabled) {
            uint256 cBalanceBefore = cToken.balanceOf(address(this));
            redeemUnderlying(address(cToken), amount_);
            uint256 cBalanceAfter = cToken.balanceOf(address(this));
            uint256 cTokenToRemove = sub(cBalanceBefore, cBalanceAfter);
            funds[fund].cBalance = sub(funds[fund].cBalance, cTokenToRemove);
            if (!custom(fund)) {cTokenMarketLiquidity = sub(cTokenMarketLiquidity, cTokenToRemove);}
        } else {
            funds[fund].balance = sub(funds[fund].balance, amount_);
            if (!custom(fund)) {tokenMarketLiquidity = sub(tokenMarketLiquidity, amount_);}
        }
        if (!custom(fund)) {
            totalBorrow = add(totalBorrow, amount_);
            calcGlobalInterest();
        }
    }

    
    function getSecretHashesForLoan(address addr_) private returns (bytes32[4] memory) {
        secretHashIndex[addr_] = add(secretHashIndex[addr_], 4);
        require(secretHashesCount(addr_) >= secretHashIndex[addr_], "Funds.getSecretHashesForLoan: Not enough secrets generated");
        return [
            secretHashes[addr_][sub(secretHashIndex[addr_], 4)],
            secretHashes[addr_][sub(secretHashIndex[addr_], 3)],
            secretHashes[addr_][sub(secretHashIndex[addr_], 2)],
            secretHashes[addr_][sub(secretHashIndex[addr_], 1)]
        ];
    }
}