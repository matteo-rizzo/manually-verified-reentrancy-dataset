pragma solidity 0.6.4;


//ERC20 Interface

    



 



    
//======================================AXIA CONTRACT=========================================//
contract AXIATOKEN is ERC20 {
    
    using SafeMath for uint256;
    
//======================================AXIA EVENTS=========================================//

    event NewEpoch(uint epoch, uint emission, uint nextepoch);
    event NewDay(uint epoch, uint day, uint nextday);
    event BurnEvent(address indexed pool, address indexed burnaddress, uint amount);
    event emissions(address indexed root, address indexed pool, uint value);
    event TrigRewardEvent(address indexed root, address indexed receiver, uint value);
    event BasisPointAdded(uint value);
    
    
   // ERC-20 Parameters
    string public name; 
    string public symbol;
    uint public decimals; 
    uint public startdecimal;
    uint public override totalSupply;
    uint public initialsupply;
    
     //======================================STAKING POOLS=========================================//
    address public pool1;
    address public pool2;
    address public pool3;
    address public pool4;
    
    uint public pool1Amount;
    uint public pool2Amount;
    uint public pool3Amount;
    uint public poolAmount;
    
    
    // ERC-20 Mappings
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;
    
    
    // Public Parameters
    uint crypto; 
    uint startcrypto;
    uint public emission;
    uint public currentEpoch; 
    uint public currentDay;
    uint public daysPerEpoch; 
    uint public secondsPerDay;
    uint public genesis;
    uint public nextEpochTime; 
    uint public nextDayTime;
    uint public amountToEmit;
    uint public BPE;
    
    //======================================BASIS POINT VARIABLES=========================================//
    uint public bpValue;
    uint public actualValue;
    uint public TrigReward;
    uint public burnAmount;
    address administrator;
    uint totalEmitted;
    
    address public messagesender;
     
    // Public Mappings
    mapping(address=>bool) public Address_Whitelisted;
    mapping(address=>bool) public emission_Whitelisted;
    

    //=====================================CREATION=========================================//
    // Constructor
    constructor() public {
        name = "AXIA TOKEN (axiaprotocol.io)"; 
        symbol = "AXIA"; 
        decimals = 18; 
        startdecimal = 16;
        crypto = 1*10**decimals; 
        startcrypto =  1*10**startdecimal; 
        totalSupply = 3000000*crypto;                                 
        initialsupply = 40153125*startcrypto;
        emission = 7200*crypto; 
        currentEpoch = 1; 
        currentDay = 1;                             
        genesis = now;
        
        daysPerEpoch = 180; 
        secondsPerDay = 86400; 
       
        administrator = msg.sender;
        balanceOf[administrator] = initialsupply; 
        emit Transfer(administrator, address(this), initialsupply);                                
        nextEpochTime = genesis + (secondsPerDay * daysPerEpoch);                                   
        nextDayTime = genesis + secondsPerDay;                                                      
        
        Address_Whitelisted[administrator] = true;                                         
        
        
        
    }
    
//========================================CONFIGURATIONS=========================================//
    
       function poolconfigs(address _oracle, address _defi, address _univ2, address _axia) public onlyAdministrator returns (bool success) {
        pool1 = _oracle;
        pool2 = _defi;
        pool3 = _univ2;
        pool4 = _axia;
        
        return true;
    }
    
    modifier onlyAdministrator() {
        require(msg.sender == administrator, "Ownable: caller is not the owner");
        _;
    }
    
    modifier onlyASP() {
        require(msg.sender == pool4, "Authorization: Only the fourth pool can call on this");
        _;
    }
    
    function whitelist(address _address) public onlyAdministrator returns (bool success) {
       Address_Whitelisted[_address] = true;
        return true;
    }
    
    function unwhitelist(address _address) public onlyAdministrator returns (bool success) {
       Address_Whitelisted[_address] = false;
        return true;
    }
    
    
    function whitelistOnEmission(address _address) public onlyAdministrator returns (bool success) {
       emission_Whitelisted[_address] = true;
        return true;
    }
    
    function unwhitelistOnEmission(address _address) public onlyAdministrator returns (bool success) {
       emission_Whitelisted[_address] = false;
        return true;
    }
    
    
    function supplyeffect(uint _amount) public onlyASP returns (bool success) {
       totalSupply -= _amount;
       emit BurnEvent(pool4, address(0x0), _amount);
        return true;
    }
    
    function Burn(uint _amount) public returns (bool success) {
       
       require(balanceOf[msg.sender] >= _amount, "You do not have the amount of tokens you wanna burn in your wallet");
       balanceOf[msg.sender] -= _amount;
       totalSupply -= _amount;
       emit BurnEvent(msg.sender, address(0x0), _amount);
       return true;
       
    }
    
   //========================================ERC20=========================================//
    // ERC20 Transfer function
    function transfer(address to, uint value) public override returns (bool success) {
        _transfer(msg.sender, to, value);
        return true;
    }
    // ERC20 Approve function
    function approve(address spender, uint value) public override returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    // ERC20 TransferFrom function
    function transferFrom(address from, address to, uint value) public override returns (bool success) {
        require(value <= allowance[from][msg.sender], 'Must not send more than allowance');
        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }
    
  
    
    // Internal transfer function which includes the Fee
    function _transfer(address _from, address _to, uint _value) private {
        
        messagesender = msg.sender; //this is the person actually making the call on this function
        
        
        require(balanceOf[_from] >= _value, 'Must not send more than balance');
        require(balanceOf[_to] + _value >= balanceOf[_to], 'Balance overflow');
        
        balanceOf[_from] -= _value;
        if(Address_Whitelisted[msg.sender]){ //if the person making the transaction is whitelisted, the no burn on the transaction
        
          actualValue = _value;
          
        }else{
         
        bpValue = mulDiv(_value, 15, 10000); //this is 0.15% for basis point
        actualValue = _value - bpValue; //this is the amount to be sent
        
        balanceOf[address(this)] += bpValue; //this is adding the basis point charged to this contract
        emit Transfer(_from, address(this), bpValue);
        
        BPE += bpValue; //this is increasing the virtual basis point amount
        emit BasisPointAdded(bpValue); 
        
        
        }
        
        if(emission_Whitelisted[messagesender] == false){ //this is so that staking and unstaking will not trigger the emission
          
                if(now >= nextDayTime){
                
                amountToEmit = emittingAmount();
                pool1Amount = mulDiv(amountToEmit, 6500, 10000);
                poolAmount = mulDiv(amountToEmit, 20, 10000);
                
                pool1Amount = pool1Amount.sub(poolAmount);
                pool2Amount = mulDiv(amountToEmit, 2100, 10000);
                pool3Amount = mulDiv(amountToEmit, 1400, 10000);
                
                TrigReward = poolAmount;
                
                pool1Amount = pool1Amount.div(2);
                
                uint Ofrozenamount = ospfrozen();
                uint Dfrozenamount = dspfrozen();
                uint Ufrozenamount = uspfrozen();
                uint Afrozenamount = aspfrozen();
                
                if(Ofrozenamount > 0){
                    
                OSP(pool1).scaledToken(pool1Amount);
                balanceOf[pool1] += pool1Amount;
                emit Transfer(address(this), pool1, pool1Amount);
                
                
                    
                }else{
                  
                 balanceOf[address(this)] += pool1Amount; 
                 emit Transfer(address(this), address(this), pool1Amount);
                 
                 BPE += pool1Amount;
                    
                }
                
                if(Dfrozenamount > 0){
                    
                DSP(pool2).scaledToken(pool1Amount);
                balanceOf[pool2] += pool1Amount;
                emit Transfer(address(this), pool2, pool1Amount);
                
                
                    
                }else{
                  
                 balanceOf[address(this)] += pool1Amount; 
                 emit Transfer(address(this), address(this), pool1Amount);
                 BPE += pool1Amount;
                    
                }
                
                if(Ufrozenamount > 0){
                    
                USP(pool3).scaledToken(pool2Amount);
                balanceOf[pool3] += pool2Amount;
                emit Transfer(address(this), pool3, pool2Amount);
                
                    
                }else{
                  
                 balanceOf[address(this)] += pool2Amount; 
                 emit Transfer(address(this), address(this), pool2Amount);
                 BPE += pool2Amount;
                    
                }
                
                if(Afrozenamount > 0){
                    
                USP(pool4).scaledToken(pool3Amount);
                balanceOf[pool4] += pool3Amount;
                emit Transfer(address(this), pool4, pool3Amount);
                
                    
                }else{
                  
                 balanceOf[address(this)] += pool3Amount; 
                 emit Transfer(address(this), address(this), pool3Amount);
                 BPE += pool3Amount;
                    
                }
                
                nextDayTime += secondsPerDay;
                currentDay += 1; 
                emit NewDay(currentEpoch, currentDay, nextDayTime);
                
                //reward the wallet that triggered the EMISSION
                balanceOf[_from] += TrigReward; //this is rewardig the person that triggered the emission
                emit Transfer(address(this), _from, TrigReward);
                emit TrigRewardEvent(address(this), msg.sender, TrigReward);
                
            }
        
            
        }
       
       balanceOf[_to] += actualValue;
       emit Transfer(_from, _to, actualValue);
    }
    
    

    
   
    //======================================EMISSION========================================//
    // Internal - Update emission function
    
    function emittingAmount() internal returns(uint){
       
        if(now >= nextEpochTime){
            
            currentEpoch += 1;
            
            //if it is greater than the nextEpochTime, then it means we have entered the new epoch, 
            //thats why we are adding 1 to it, meaning new epoch emission
            
            if(currentEpoch > 10){
            
               emission = BPE;
               BPE -= emission.div(2);
               balanceOf[address(this)] -= emission.div(2);
            
               
            }
            emission = emission/2;
            nextEpochTime += (secondsPerDay * daysPerEpoch);
            emit NewEpoch(currentEpoch, emission, nextEpochTime);
          
        }
        
        return emission;
        
        
    }
  
  
  
    function ospfrozen() public view returns(uint){
        
        return OSP(pool1).totalFrozen();
       
    }
    
    function dspfrozen() public view returns(uint){
        
        return DSP(pool2).totalFrozen();
       
    }
    
    function uspfrozen() public view returns(uint){
        
        return USP(pool3).totalFrozen();
       
    } 
    
    function aspfrozen() public view returns(uint){
        
        return ASP(pool4).totalFrozen();
       
    }
    
     function mulDiv (uint x, uint y, uint z) public pure returns (uint) {
          (uint l, uint h) = fullMul (x, y);
          assert (h < z);
          uint mm = mulmod (x, y, z);
          if (mm > l) h -= 1;
          l -= mm;
          uint pow2 = z & -z;
          z /= pow2;
          l /= pow2;
          l += h * ((-pow2) / pow2 + 1);
          uint r = 1;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          return l * r;
    }
    
     function fullMul (uint x, uint y) private pure returns (uint l, uint h) {
          uint mm = mulmod (x, y, uint (-1));
          l = x * y;
          h = mm - l;
          if (mm < l) h -= 1;
    }
    
   
}