/**
 *Submitted for verification at Etherscan.io on 2021-02-12
*/

pragma solidity 0.8.0;
// SPDX-License-Identifier: AGPL-3.0-or-later






abstract contract IMasset is MassetStructs {
    // Mint
    function mint(
        address _input,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 mintOutput);

    function mintMulti(
        address[] calldata _inputs,
        uint256[] calldata _inputQuantities,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 mintOutput);

    function getMintOutput(address _input, uint256 _inputQuantity)
        external
        view
        virtual
        returns (uint256 mintOutput);

    function getMintMultiOutput(address[] calldata _inputs, uint256[] calldata _inputQuantities)
        external
        view
        virtual
        returns (uint256 mintOutput);

    // Swaps
    function swap(
        address _input,
        address _output,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 swapOutput);

    function getSwapOutput(
        address _input,
        address _output,
        uint256 _inputQuantity
    ) external view virtual returns (uint256 swapOutput);

    // Redemption
    function redeem(
        address _output,
        uint256 _mAssetQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 outputQuantity);

    function redeemMasset(
        uint256 _mAssetQuantity,
        uint256[] calldata _minOutputQuantities,
        address _recipient
    ) external virtual returns (uint256[] memory outputQuantities);

    function redeemExactBassets(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities,
        uint256 _maxMassetQuantity,
        address _recipient
    ) external virtual returns (uint256 mAssetRedeemed);

    function getRedeemOutput(address _output, uint256 _mAssetQuantity)
        external
        view
        virtual
        returns (uint256 bAssetOutput);

    function getRedeemExactBassetsOutput(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities
    ) external view virtual returns (uint256 mAssetAmount);

    // Views
    function getBasket() external view virtual returns (bool, bool);

    function getBasset(address _token)
        external
        view
        virtual
        returns (BassetPersonal memory personal, BassetData memory data);

    function getBassets()
        external
        view
        virtual
        returns (BassetPersonal[] memory personal, BassetData[] memory data);

    function bAssetIndexes(address) external view virtual returns (uint8);

    // SavingsManager
    function collectInterest() external virtual returns (uint256 swapFeesGained, uint256 newSupply);

    function collectPlatformInterest()
        external
        virtual
        returns (uint256 mintAmount, uint256 newSupply);

    // Admin
    function setCacheSize(uint256 _cacheSize) external virtual;

    function upgradeForgeValidator(address _newForgeValidator) external virtual;

    function setFees(uint256 _swapFee, uint256 _redemptionFee) external virtual;

    function setTransferFeesFlag(address _bAsset, bool _flag) external virtual;

    function migrateBassets(address[] calldata _bAssets, address _newIntegration) external virtual;
}



/**
 * @dev Collection of functions related to the address type
 */










// 3 FLOWS
// 0 - SAVE
// 1 - MINT AND SAVE
// 2 - BUY AND SAVE (ETH via Uni)
contract SaveWrapper {

    using SafeERC20 for IERC20;

    // Constants - add to bytecode during deployment
    address public immutable save;
    address public immutable vault;
    address public immutable mAsset;

    IUniswapV2Router02 public immutable uniswap;

    constructor(
        address _save,
        address _vault,
        address _mAsset,
        address[] memory _bAssets,
        address _uniswapAddress
    ) {
        require(_save != address(0), "Invalid save address");
        save = _save;
        require(_vault != address(0), "Invalid vault address");
        vault = _vault;
        require(_mAsset != address(0), "Invalid mAsset address");
        mAsset = _mAsset;
        require(_uniswapAddress != address(0), "Invalid uniswap address");
        uniswap = IUniswapV2Router02(_uniswapAddress);

        IERC20(_mAsset).safeApprove(_save, 2**256 - 1);
        IERC20(_save).approve(_vault, 2**256 - 1);
        for(uint256 i = 0; i < _bAssets.length; i++ ) {
            IERC20(_bAssets[i]).safeApprove(_mAsset, 2**256 - 1);
        }
    }


    /**
     * @dev 0. Simply saves an mAsset and then into the vault
     * @param _amount Units of mAsset to deposit to savings
     */
    function saveAndStake(uint256 _amount) external {
        IERC20(mAsset).transferFrom(msg.sender, address(this), _amount);
        _saveAndStake(_amount, true);
    }

    /**
     * @dev 1. Mints an mAsset and then deposits to SAVE
     * @param _bAsset       bAsset address
     * @param _amt          Amount of bAsset to mint with
     * @param _minOut       Min amount of mAsset to get back
     * @param _stake        Add the imUSD to the Savings Vault?
     */
    function saveViaMint(address _bAsset, uint256 _amt, uint256 _minOut, bool _stake) external {
        // 1. Get the input bAsset
        IERC20(_bAsset).transferFrom(msg.sender, address(this), _amt);
        // 2. Mint
        IMasset mAsset_ = IMasset(mAsset);
        uint256 massetsMinted = mAsset_.mint(_bAsset, _amt, _minOut, address(this));
        // 3. Mint imUSD and optionally stake in vault
        _saveAndStake(massetsMinted, _stake);
    }


    /**
     * @dev 2. Buys a bAsset on Uniswap with ETH then mUSD on Curve
     * @param _amountOutMin  Min uniswap output in bAsset units
     * @param _path          Sell path on Uniswap (e.g. [WETH, DAI])
     * @param _minOutMStable Min amount of mUSD to receive
     * @param _stake         Add the imUSD to the Savings Vault?
     */
    function saveViaUniswapETH(
        uint256 _amountOutMin,
        address[] calldata _path,
        uint256 _minOutMStable,
        bool _stake
    ) external payable {
        // 1. Get the bAsset
        uint[] memory amounts = uniswap.swapExactETHForTokens{value: msg.value}(
            _amountOutMin,
            _path,
            address(this),
            block.timestamp + 1000
        );
        // 2. Purchase mUSD
        uint256 massetsMinted = IMasset(mAsset).mint(_path[_path.length-1], amounts[amounts.length-1], _minOutMStable, address(this));
        // 3. Mint imUSD and optionally stake in vault
        _saveAndStake(massetsMinted, _stake);
    }

    /**
     * @dev Gets estimated mAsset output from a WETH > bAsset > mAsset trade
     */
    function estimate_saveViaUniswapETH(
        uint256 _ethAmount,
        address[] calldata _path,
        int128 _curvePosition
    )
        external
        view
        returns (uint256 out)
    {
        uint256 estimatedBasset = _getAmountOut(_ethAmount, _path);
        return IMasset(mAsset).getMintOutput(_path[_path.length-1], estimatedBasset);
    }

    /** @dev Internal func to deposit into SAVE and optionally stake in the vault */
    function _saveAndStake(
        uint256 _amount,
        bool _stake
    ) internal {
        if(_stake){
            uint256 credits = ISavingsContractV2(save).depositSavings(_amount, address(this));
            IBoostedSavingsVault(vault).stake(msg.sender, credits);
        } else {
            ISavingsContractV2(save).depositSavings(_amount, msg.sender);
        }
    }

    /** @dev Internal func to get esimtated Uniswap output from WETH to token trade */
    function _getAmountOut(uint256 _amountIn, address[] memory _path) internal view returns (uint256) {
        uint256[] memory amountsOut = uniswap.getAmountsOut(_amountIn, _path);
        return amountsOut[amountsOut.length - 1];
    }
}