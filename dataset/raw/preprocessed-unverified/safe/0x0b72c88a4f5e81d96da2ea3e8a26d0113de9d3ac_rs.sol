/**
 *Submitted for verification at Etherscan.io on 2021-08-26
*/

pragma solidity ^0.8.0;


// SPDX-License-Identifier: MIT
// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */





/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}





contract MiningNFTMintingLimitationBase is Ownable{
    using SafeMath for uint256;

    IMinerManage public minerManage;
    IFilChainStatOracle public filChainStatOracle;
    IMiningNFTMintingLimitationData public limitationData;

    uint256 public mintAmountLimitationRatio = 200; // one-thousandth
    uint constant public RATIO_DENOMINATOR = 1000;

    event FilChainStatOracleChanged(address originalOracle, address newOracle);
    event LimitationRatioChanged(uint256 originalValue, uint256 newValue);
    event MiningNFTMintingLimitationDataChanged(address originalDataContract, address newDataContract);
    event MinerManageChanged(address originalMinerManage, address newMinerManage);

    constructor(IMinerManage _minerManage,IFilChainStatOracle _filChainStatOracle, IMiningNFTMintingLimitationData _limitationData){
        minerManage = _minerManage;
        filChainStatOracle = _filChainStatOracle;
        limitationData = _limitationData;
    }

    function setMinerManage(IMinerManage _minerManage) public onlyOwner{
        require(address(_minerManage)!=address(0), "address should not be 0");
        address original = address(minerManage);
        minerManage = _minerManage;
        emit MinerManageChanged(original, address(_minerManage));
    }

    function getTotalLimitationCap() public view returns(uint256){
        return filChainStatOracle.minerTotalAdjustedPower().mul(mintAmountLimitationRatio).div(RATIO_DENOMINATOR);
    }

    function getMinerLimitationCap(string memory minerId) public view returns(uint256){
        return filChainStatOracle.minerAdjustedPower(minerId).mul(mintAmountLimitationRatio).div(RATIO_DENOMINATOR);
    }

    function setFilChainStatOracle(IFilChainStatOracle _filChainStatOracle) public onlyOwner{
        require(address(_filChainStatOracle)!=address(0), "address should not be 0");
        address originalOracle = address(filChainStatOracle);
        filChainStatOracle = _filChainStatOracle;
        emit FilChainStatOracleChanged(originalOracle, address(_filChainStatOracle));
    }

    function setLimitationRatio(uint256 _mintAmountLimitationRatio) public onlyOwner{
        require(_mintAmountLimitationRatio > 0, "value should be > 0");
        uint256 originalValue = mintAmountLimitationRatio;
        mintAmountLimitationRatio = _mintAmountLimitationRatio;
        emit LimitationRatioChanged(originalValue, _mintAmountLimitationRatio);
    }

    function setMiningNFTMintingLimitationData(IMiningNFTMintingLimitationData _limitationData) public onlyOwner{
        require(address(_limitationData)!=address(0), "address should not be 0");
        address original = address(limitationData);
        limitationData = _limitationData;
        emit MiningNFTMintingLimitationDataChanged(original, address(_limitationData));
    }
   

}

contract Poster is Ownable{
    address public poster;
    event PosterChanged(address originalPoster, address newPoster);

    modifier onlyPoster(){
        require(poster == _msgSender(), "not poster");
        _;
    }

    function setPoster(address _poster) public onlyOwner{
        require(_poster != address(0), "address should not be 0");
        emit PosterChanged(poster, _poster);
        poster = _poster;
    }
}

contract MiningNFTMintingLimitation is Poster,MiningNFTMintingLimitationBase{
    using SafeMath for uint256;

    constructor(IMinerManage _minerManage, IFilChainStatOracle _filChainStatOracle, IMiningNFTMintingLimitationData _limitationData) MiningNFTMintingLimitationBase(_minerManage, _filChainStatOracle, _limitationData){
        
    }

    function increaseLimitation(uint256 _limitationDelta) public onlyPoster{
        require(limitationData.totalMintLimitationInTiB().add(_limitationDelta) <= getTotalLimitationCap(), "limitaion exceed hardcap");
        
        string[] memory minerList = minerManage.getMinerList();
        uint256 totalAdjustedPower = filChainStatOracle.minerTotalAdjustedPower();

        for(uint i=0; i<minerList.length; i++){
            string memory minerId = minerList[i];
            increaseMinerLimitation(minerId, _limitationDelta, totalAdjustedPower);
        }
    }

    function increaseLimitationBatch(string[] memory _minerList, uint256 _limitationDelta) public onlyPoster{
        require(limitationData.totalMintLimitationInTiB().add(_limitationDelta) <= getTotalLimitationCap(), "limitaion exceed hardcap");
        uint256 totalAdjustedPower = getTotalAdjustedPower(_minerList);

        for(uint i=0; i<_minerList.length; i++){
            string memory minerId = _minerList[i];
            increaseMinerLimitation(minerId, _limitationDelta, totalAdjustedPower);
        }
    }

    function increaseMinerLimitation(string memory _minerId, uint256 _limitationDelta, uint256 totalAdjustedPower) internal {
        uint256 minerAdjustedPower = filChainStatOracle.minerAdjustedPower(_minerId);
        uint256 minerLimitationHardCap = minerAdjustedPower.mul(mintAmountLimitationRatio).div(RATIO_DENOMINATOR);
        uint256 minerLimitationDelta = minerAdjustedPower.mul(_limitationDelta).div(totalAdjustedPower);
        uint256 minerLimitationPrev = limitationData.minerMintAmountLimitation(_minerId);
        
        if(minerLimitationPrev.add(minerLimitationDelta) > minerLimitationHardCap){
            minerLimitationDelta = minerLimitationHardCap.sub(minerLimitationPrev);
        }

        limitationData.increaseMinerLimitation(_minerId, minerLimitationDelta);
    }

    function decreaseLimitation(uint256 _limitationDelta) public onlyPoster{
        string[] memory minerList = minerManage.getMinerList();
        uint256 totalAdjustedPower = filChainStatOracle.minerTotalAdjustedPower();

        for(uint i=0; i<minerList.length; i++){
            string memory minerId = minerList[i];
            decreaseMinerLimitation(minerId, _limitationDelta, totalAdjustedPower);
        }
    }

    function decreaseLimitationBatch(string[] memory _minerList, uint256 _limitationDelta) public onlyPoster{
        uint256 totalAdjustedPower = getTotalAdjustedPower(_minerList);

        for(uint i=0; i<_minerList.length; i++){
            string memory minerId = _minerList[i];
            decreaseMinerLimitation(minerId, _limitationDelta, totalAdjustedPower);
        }
    }

    function decreaseMinerLimitation(string memory _minerId, uint256 _limitationDelta, uint256 totalAdjustedPower) internal{
        uint256 minerAdjustedPower = filChainStatOracle.minerAdjustedPower(_minerId);
        uint256 minerLimitationDelta = minerAdjustedPower.mul(_limitationDelta).div(totalAdjustedPower);

        limitationData.decreaseMinerLimitation(_minerId, minerLimitationDelta);
    }

    function getTotalAdjustedPower(string[] memory _minerList) internal view returns(uint256 totalAdjustedPower){
        for(uint i=0; i<_minerList.length; i++){
            string memory minerId = _minerList[i];
            uint256 minerAdjustedPower = filChainStatOracle.minerAdjustedPower(minerId);
            totalAdjustedPower = totalAdjustedPower.add(minerAdjustedPower);
        }
    }

    function checkLimitation(string memory _minerId, uint256 _minerTotalMinted, uint256 _allMinersTotalMinted) public view returns(bool, string memory){
        if(_minerTotalMinted > limitationData.minerMintAmountLimitation(_minerId)){
            return (false, "mint amount exceed miner limitation");
        }

        if(_allMinersTotalMinted > limitationData.totalMintLimitationInTiB()){
            return (false, "exceed platform total mint limitation");
        }

        return (true, "");
    }


}