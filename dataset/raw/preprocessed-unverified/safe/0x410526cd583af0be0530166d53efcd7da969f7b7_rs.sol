pragma solidity ^0.4.24;

/**
 * @title SafeMath v0.1.9
 * @dev Math operations with safety checks that throw on error
 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor
 * - added sqrt
 * - added sq
 * - added pwr 
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
 */
 

/*
 * NameFilter library
 */


/**
 interface : PlayerBookReceiverInterface
 */


/**
 contract : PlayerBook
 */
contract PlayerBook{
    /****************************************************************************************** 
     导入的库
     */
    using SafeMath for *;
    using NameFilter for string;
    /******************************************************************************************
     社区地址
     */
    address public communityAddr;
    function initCommunityAddr(address addr) isAdmin() public {
        require(address(addr) != address(0x0), "Empty address not allowed.");
        require(address(communityAddr) == address(0x0), "Community address has been set.");
        communityAddr = addr ;
    }
    /******************************************************************************************
     合约权限管理
     设计：会设计用户权限管理，
        9 => 管理员角色
        0 => 没有任何权限
     */

    // 用户地址到角色的表
    mapping(address => uint256)     private users ;
    // 初始化
    function initUsers() private {
        // 初始化下列地址帐户为管理员
        users[0x89b2E7Ee504afd522E07F80Ae7b9d4D228AF3fe2] = 9 ;
        users[msg.sender] = 9 ;
    }
    // 是否是管理员
    modifier isAdmin() {
        uint256 role = users[msg.sender];
        require((role==9), "Must be admin.");
        _;
    }
    /******************************************************************************************
     检查是帐户地址还是合约地址   
     */
    modifier isHuman {
        address _addr = msg.sender;
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "Humans only");
        _;
    }
    /****************************************************************************************** 
     事件定义
     */
    event onNewName
    (
        uint256 indexed playerID,
        address indexed playerAddress,
        bytes32 indexed playerName,
        bool isNewPlayer,
        uint256 affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 amountPaid,
        uint256 timeStamp
    );
    // 注册玩家信息
    struct Player {
        address addr;
        bytes32 name;
        uint256 laff;
        uint256 names;
    }
    /******************************************************************************************  
     注册费用：初始为 0.01 ether
     条件：
     1. 必须是管理员才可以更新
     */
    uint256 public registrationFee_ = 10 finney; 
    function setRegistrationFee(uint256 _fee) isAdmin() public {
        registrationFee_ = _fee ;
    }
    /******************************************************************************************
     注册游戏
     */
    // 注册的游戏列表
    mapping(uint256 => PlayerBookReceiverInterface) public games_;
    // 注册的游戏名称列表
    mapping(address => bytes32) public gameNames_;
    // 注册的游戏ID列表
    mapping(address => uint256) public gameIDs_;
    // 游戏数目
    uint256 public gID_;
    // 判断是否是注册游戏
    modifier isRegisteredGame() {
        require(gameIDs_[msg.sender] != 0);
        _;
    }
    /****************************************************************************************** 
     新增游戏
     条件：
     1. 游戏不存在
     */
    function addGame(address _gameAddress, string _gameNameStr) isAdmin() public {
        require(gameIDs_[_gameAddress] == 0, "Game already registered");
        gID_++;
        bytes32 _name = _gameNameStr.nameFilter();
        gameIDs_[_gameAddress] = gID_;
        gameNames_[_gameAddress] = _name;
        games_[gID_] = PlayerBookReceiverInterface(_gameAddress);
    }
    /****************************************************************************************** 
     玩家信息
     */
    // 玩家数目
    uint256 public pID_;
    // 玩家地址=>玩家ID
    mapping (address => uint256) public pIDxAddr_;
    // 玩家名称=>玩家ID
    mapping (bytes32 => uint256) public pIDxName_;  
    // 玩家ID => 玩家数据
    mapping (uint256 => Player) public plyr_; 
    // 玩家ID => 玩家名称 => 
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_;
    // 玩家ID => 名称编号 => 玩家名称
    mapping (uint256 => mapping (uint256 => bytes32)) public plyrNameList_; 
    /******************************************************************************************
     初始玩家 
     */
     function initPlayers() private {
        pID_ = 0;
     }
    /******************************************************************************************
     判断玩家名字是否有效（是否已经注册过）
     */
    function checkIfNameValid(string _nameStr) public view returns(bool){
        bytes32 _name = _nameStr.nameFilter();
        if (pIDxName_[_name] == 0) return (true);
        else return (false);
    }
    /******************************************************************************************
     构造函数
     */
    constructor() public {
        // 初始化用户
        initUsers() ;
        // 初始化玩家
        initPlayers();
        // 初始化社区基金地址
        communityAddr = address(0x3C07f9f7164Bf72FDBefd9438658fAcD94Ed4439);

    }
    /******************************************************************************************
     注册名字
     _nameString: 名字
     _affCode：推荐人编号
     _all：是否是注册到所有游戏中
     条件：
     1. 是账户地址
     2. 要付费
     */
    function registerNameXID(string _nameString, uint256 _affCode, bool _all) isHuman() public payable{
        // 要求注册费用,不需要付费
        //require (msg.value >= registrationFee_, "You have to pay the name fee");

        bytes32 _name = NameFilter.nameFilter(_nameString);
        address _addr = msg.sender;
        bool _isNewPlayer = determinePID(_addr);
        uint256 _pID = pIDxAddr_[_addr];
        if (_affCode != 0 && _affCode != plyr_[_pID].laff && _affCode != _pID) {
            plyr_[_pID].laff = _affCode;
        }else{
            _affCode = 0;
        }
        registerNameCore(_pID, _addr, _affCode, _name, _isNewPlayer, _all);
    }
    /**
     注册名字
     _nameString: 名字
     _affCode：推荐人地址
     _all：是否是注册到所有游戏中
     条件：
     1. 是账户地址
     2. 要付费
     */
    function registerNameXaddr(string _nameString, address _affCode, bool _all) isHuman() public payable{
        // 要求注册费用,不需要付费
        //require (msg.value >= registrationFee_, "You have to pay the name fee");
        
        bytes32 _name = NameFilter.nameFilter(_nameString);
        address _addr = msg.sender;
        bool _isNewPlayer = determinePID(_addr);
        uint256 _pID = pIDxAddr_[_addr];
        uint256 _affID;
        if (_affCode != address(0) && _affCode != _addr){
            _affID = pIDxAddr_[_affCode];
            if (_affID != plyr_[_pID].laff){
                plyr_[_pID].laff = _affID;
            }
        }
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
    }
    /**
     注册名字
     _nameString: 名字
     _affCode：推荐人名称
     _all：是否是注册到所有游戏中
     条件：
     1. 是账户地址
     2. 要付费
     */
    function registerNameXname(string _nameString, bytes32 _affCode, bool _all) isHuman() public payable{
        // 要求注册费用,不需要付费
        //require (msg.value >= registrationFee_, "You have to pay the name fee");
        
        bytes32 _name = NameFilter.nameFilter(_nameString);
        address _addr = msg.sender;
        bool _isNewPlayer = determinePID(_addr);
        uint256 _pID = pIDxAddr_[_addr];
        uint256 _affID;
        if (_affCode != "" && _affCode != _name){
            _affID = pIDxName_[_affCode];
            if (_affID != plyr_[_pID].laff){
                plyr_[_pID].laff = _affID;
            }
        }
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
    }

    /**
     注册
     _pID:          玩家编号
     _addr:         玩家地址
     _affID:        从属
     _name:         名称
    _isNewPlayer:   是否是新玩家
    _all:           是否注册到所有游戏
     */
    function registerNameCore(uint256 _pID, address _addr, uint256 _affID, bytes32 _name, bool _isNewPlayer, bool _all) private {
        // 判断是否已经注册过
        if (pIDxName_[_name] != 0)
            require(plyrNames_[_pID][_name] == true, "That names already taken");
        // 
        plyr_[_pID].name = _name;
        pIDxName_[_name] = _pID;
        if (plyrNames_[_pID][_name] == false) {
            plyrNames_[_pID][_name] = true;
            plyr_[_pID].names++;
            plyrNameList_[_pID][plyr_[_pID].names] = _name;
        }
        // 将注册费用转到社区基金合约账户中
        if(address(this).balance>0){
            if(address(communityAddr) != address(0x0)) {
                communityAddr.transfer(address(this).balance);
            }
        }

        if (_all == true)
            for (uint256 i = 1; i <= gID_; i++)
                games_[i].receivePlayerInfo(_pID, _addr, _name, _affID);
        
        emit onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, msg.value, now);
    }
    /**
     如果是新玩家，则返回真
     */
    function determinePID(address _addr) private returns (bool) {
        if (pIDxAddr_[_addr] == 0){
            pID_++;
            pIDxAddr_[_addr] = pID_;
            plyr_[pID_].addr = _addr;
            return (true) ;
        }else{
            return (false);
        }
    }
    /**
     */
    function addMeToGame(uint256 _gameID) isHuman() public {
        require(_gameID <= gID_, "Game doesn&#39;t exist yet");
        address _addr = msg.sender;
        uint256 _pID = pIDxAddr_[_addr];
        require(_pID != 0, "You dont even have an account");
        uint256 _totalNames = plyr_[_pID].names;
        
        // add players profile and most recent name
        games_[_gameID].receivePlayerInfo(_pID, _addr, plyr_[_pID].name, plyr_[_pID].laff);
        
        // add list of all names
        if (_totalNames > 1)
            for (uint256 ii = 1; ii <= _totalNames; ii++)
                games_[_gameID].receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);
    }

    function addMeToAllGames() isHuman() public {
        address _addr = msg.sender;
        uint256 _pID = pIDxAddr_[_addr];
        require(_pID != 0, "You dont even have an account");
        uint256 _laff = plyr_[_pID].laff;
        uint256 _totalNames = plyr_[_pID].names;
        bytes32 _name = plyr_[_pID].name;
        
        for (uint256 i = 1; i <= gID_; i++){
            games_[i].receivePlayerInfo(_pID, _addr, _name, _laff);
            if (_totalNames > 1)
                for (uint256 ii = 1; ii <= _totalNames; ii++)
                    games_[i].receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);
        }
    }

    function useMyOldName(string _nameString) isHuman() public {
        // filter name, and get pID
        bytes32 _name = _nameString.nameFilter();
        uint256 _pID = pIDxAddr_[msg.sender];
        
        // make sure they own the name 
        require(plyrNames_[_pID][_name] == true, "Thats not a name you own");
        
        // update their current name 
        plyr_[_pID].name = _name;
    }
    /**
     PlayerBookInterface Interface 
     */
    function getPlayerID(address _addr) external returns (uint256){
        determinePID(_addr);
        return (pIDxAddr_[_addr]);
    }

    function getPlayerName(uint256 _pID) external view returns (bytes32){
        return (plyr_[_pID].name);
    }

    function getPlayerLAff(uint256 _pID) external view returns (uint256) {
        return (plyr_[_pID].laff);
    }

    function getPlayerAddr(uint256 _pID) external view returns (address) {
        return (plyr_[_pID].addr);
    }

    function getNameFee() external view returns (uint256){
        return (registrationFee_);
    }
    
    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all) 
        isRegisteredGame()
        external payable returns(bool, uint256){
        // 要求注册费用,不需要付费
        //require (msg.value >= registrationFee_, "You have to pay the name fee");

        bool _isNewPlayer = determinePID(_addr);
        uint256 _pID = pIDxAddr_[_addr];
        uint256 _affID = _affCode;
        if (_affID != 0 && _affID != plyr_[_pID].laff && _affID != _pID) {
            plyr_[_pID].laff = _affID;
        } else if (_affID == _pID) {
            _affID = 0;
        }      
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
        return(_isNewPlayer, _affID);
    }
    //
    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all) 
        isRegisteredGame()
        external payable returns(bool, uint256){
        // 要求注册费用,不需要付费
        //require (msg.value >= registrationFee_, "You have to pay the name fee");

        bool _isNewPlayer = determinePID(_addr);
        uint256 _pID = pIDxAddr_[_addr];
        uint256 _affID;
        if (_affCode != address(0) && _affCode != _addr){
            _affID = pIDxAddr_[_affCode];
            if (_affID != plyr_[_pID].laff){
                plyr_[_pID].laff = _affID;
            }
        }
        
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
        
        return(_isNewPlayer, _affID);    
    }
    //
    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all) 
        isRegisteredGame()
        external payable returns(bool, uint256){
        // 要求注册费用,不需要付费
        //require (msg.value >= registrationFee_, "You have to pay the name fee");

        bool _isNewPlayer = determinePID(_addr);
        uint256 _pID = pIDxAddr_[_addr];
        uint256 _affID;
        if (_affCode != "" && _affCode != _name){
            _affID = pIDxName_[_affCode];
            if (_affID != plyr_[_pID].laff){
                plyr_[_pID].laff = _affID;
            }
        }
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
        return(_isNewPlayer, _affID);            
    }
}