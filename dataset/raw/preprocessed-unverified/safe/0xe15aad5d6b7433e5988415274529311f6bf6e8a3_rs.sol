/**
 *Submitted for verification at Etherscan.io on 2020-10-06
*/

pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;




contract IMasset is MassetStructs {

    /** @dev Calc interest */
    function collectInterest() external returns (uint256 massetMinted, uint256 newTotalSupply);

    /** @dev Minting */
    function mint(address _basset, uint256 _bassetQuantity)
        external returns (uint256 massetMinted);
    function mintTo(address _basset, uint256 _bassetQuantity, address _recipient)
        external returns (uint256 massetMinted);
    function mintMulti(address[] calldata _bAssets, uint256[] calldata _bassetQuantity, address _recipient)
        external returns (uint256 massetMinted);

    /** @dev Swapping */
    function swap( address _input, address _output, uint256 _quantity, address _recipient)
        external returns (uint256 output);
    function getSwapOutput( address _input, address _output, uint256 _quantity)
        external view returns (bool, string memory, uint256 output);

    /** @dev Redeeming */
    function redeem(address _basset, uint256 _bassetQuantity)
        external returns (uint256 massetRedeemed);
    function redeemTo(address _basset, uint256 _bassetQuantity, address _recipient)
        external returns (uint256 massetRedeemed);
    function redeemMulti(address[] calldata _bAssets, uint256[] calldata _bassetQuantities, address _recipient)
        external returns (uint256 massetRedeemed);
    function redeemMasset(uint256 _mAssetQuantity, address _recipient) external;

    /** @dev Setters for the Manager or Gov to update module info */
    function upgradeForgeValidator(address _newForgeValidator) external;

    /** @dev Setters for Gov to set system params */
    function setSwapFee(uint256 _swapFee) external;

    /** @dev Getters */
    function getBasketManager() external view returns(address);
    function forgeValidator() external view returns (address);
    function totalSupply() external view returns (uint256);
    function swapFee() external view returns (uint256);
}

contract IBasketManager is MassetStructs {

    /** @dev Setters for mAsset to update balances */
    function increaseVaultBalance(
        uint8 _bAsset,
        address _integrator,
        uint256 _increaseAmount) external;
    function increaseVaultBalances(
        uint8[] calldata _bAsset,
        address[] calldata _integrator,
        uint256[] calldata _increaseAmount) external;
    function decreaseVaultBalance(
        uint8 _bAsset,
        address _integrator,
        uint256 _decreaseAmount) external;
    function decreaseVaultBalances(
        uint8[] calldata _bAsset,
        address[] calldata _integrator,
        uint256[] calldata _decreaseAmount) external;
    function collectInterest() external
        returns (uint256 interestCollected, uint256[] memory gains);

    /** @dev Setters for Gov to update Basket composition */
    function addBasset(
        address _basset,
        address _integration,
        bool _isTransferFeeCharged) external returns (uint8 index);
    function setBasketWeights(address[] calldata _bassets, uint256[] calldata _weights) external;
    function setTransferFeesFlag(address _bAsset, bool _flag) external;

    /** @dev Getters to retrieve Basket information */
    function getBasket() external view returns (Basket memory b);
    function prepareForgeBasset(address _token, uint256 _amt, bool _mint) external
        returns (bool isValid, BassetDetails memory bInfo);
    function prepareSwapBassets(address _input, address _output, bool _isMint) external view
        returns (bool, string memory, BassetDetails memory, BassetDetails memory);
    function prepareForgeBassets(address[] calldata _bAssets, uint256[] calldata _amts, bool _mint) external
        returns (ForgePropsMulti memory props);
    function prepareRedeemMulti() external view
        returns (RedeemPropsMulti memory props);
    function getBasset(address _token) external view
        returns (Basset memory bAsset);
    function getBassets() external view
        returns (Basset[] memory bAssets, uint256 len);
    function paused() external view returns (bool);

    /** @dev Recollateralisation */
    function handlePegLoss(address _basset, bool _belowPeg) external returns (bool actioned);
    function negateIsolation(address _basset) external;
}





contract IForgeValidator is MassetStructs {
    function validateMint(uint256 _totalVault, Basset calldata _basset, uint256 _bAssetQuantity)
        external pure returns (bool, string memory);
    function validateMintMulti(uint256 _totalVault, Basset[] calldata _bassets, uint256[] calldata _bAssetQuantities)
        external pure returns (bool, string memory);
    function validateSwap(uint256 _totalVault, Basset calldata _inputBasset, Basset calldata _outputBasset, uint256 _quantity)
        external pure returns (bool, string memory, uint256, bool);
    function validateRedemption(
        bool basketIsFailed,
        uint256 _totalVault,
        Basset[] calldata _allBassets,
        uint8[] calldata _indices,
        uint256[] calldata _bassetQuantities) external pure returns (bool, string memory, bool);
    function calculateRedemptionMulti(
        uint256 _mAssetQuantity,
        Basset[] calldata _allBassets) external pure returns (bool, string memory, uint256[] memory);
}





/**
 * @title   MStableHelper
 * @author  Stability Labs Pty. Ltd.
 * @notice  Returns the validity and output of a given redemption
 * @dev     VERSION: 1.0
 *          DATE:    2020-06-18
 */
contract MStableHelper is IMStableHelper, MassetStructs {

    using StableMath for uint256;
    using SafeMath for uint256;


    /***************************************
                MINT/SWAP/REDEEM
    ****************************************/

    /**
     * @dev Returns a valid bAsset with which to mint
     * @param _mAsset Masset addr
     * @return valid bool
     * @return string message
     * @return address of bAsset to mint
     */
    function suggestMintAsset(
        address _mAsset
    )
        external
        view
        returns (
            bool,
            string memory,
            address
        )
    {
        require(_mAsset != address(0), "Invalid mAsset");
        // Get the data
        IBasketManager basketManager = IBasketManager(
            IMasset(_mAsset).getBasketManager()
        );
        Basket memory basket = basketManager.getBasket();
        uint256 totalSupply = IMasset(_mAsset).totalSupply();

        // Calc the max weight delta (i.e is X% away from Max weight)
        uint256 len = basket.bassets.length;
        uint256[] memory maxWeightDelta = new uint256[](len);
        for(uint256 i = 0; i < len; i++){
            Basset memory bAsset = basket.bassets[i];
            uint256 scaledBasset = bAsset.vaultBalance.mulRatioTruncate(bAsset.ratio);
            // e.g. (1e21 * 1e18) / 1e23 = 1e16 or 1%
            uint256 weight = scaledBasset.divPrecisely(totalSupply);
            maxWeightDelta[i] = weight > bAsset.maxWeight ? 0 : bAsset.maxWeight.sub(weight);
            if(bAsset.status != BassetStatus.Normal){
                return (false, "No assets available", address(0));
            }
        }
        // Ideal delta is the bAsset > 10 but closest
        uint256 idealMaxWeight = 0;
        address selected = address(0);
        for(uint256 j = 0; j < len; j++){
            uint256 bAssetDelta = maxWeightDelta[j];
            if(bAssetDelta >= 1e17){
                if(selected == address(0) || bAssetDelta < idealMaxWeight){
                    idealMaxWeight = bAssetDelta;
                    selected = basket.bassets[j].addr;
                }
            }
        }
        if(selected == address(0)){
            return (false, "No assets available", address(0));
        }
        return (true, "", selected);
    }


    /**
     * @dev Gets the maximum input for a valid swap pair
     * @param _mAsset mAsset address (e.g. mUSD)
     * @param _input Asset to input only bAssets accepted
     * @param _output Either a bAsset or the mAsset
     * @return valid
     * @return validity reason
     * @return max input units (in native decimals)
     * @return how much output this input would produce (in native decimals, after any fee)
     */
    function getMaxSwap(
        address _mAsset,
        address _input,
        address _output
    )
        external
        view
        returns (
            bool,
            string memory,
            uint256,
            uint256
        )
    {
        Data memory data = _getData(_mAsset, _input, _output);
        if(!data.isValid) {
          return (false, data.reason, 0, 0);
        }
        uint256 inputMaxWeightUnits = data.totalSupply.mulTruncate(data.input.maxWeight);
        uint256 inputVaultBalanceScaled = data.input.vaultBalance.mulRatioTruncate(
            data.input.ratio
        );
        if (data.isMint) {
            // M = ((t * maxW) - c)/(1-maxW)
            // M = max mint (scaled)
            // t = totalSupply before
            // maxW = max weight %
            // c = vault balance (scaled)
            // num = (t * maxW) - c
            // e.g. 1e22 - 1e21 = 9e21
            uint256 num = inputMaxWeightUnits.sub(inputVaultBalanceScaled);
            // den = 1e18 - maxW
            // e.g. 1e18 - 75e16 = 25e16
            uint256 den = StableMath.getFullScale().sub(data.input.maxWeight);
            uint256 maxMintScaled = den > 0 ? num.divPrecisely(den) : num;
            uint256 maxMint = maxMintScaled.divRatioPrecisely(data.input.ratio);
            maxMintScaled = maxMint.mulRatioTruncate(data.input.ratio);
            return (true, "", maxMint, maxMintScaled);
        } else {
            // get max input
            uint256 maxInputScaled = inputMaxWeightUnits.sub(inputVaultBalanceScaled);
            // get max output
            uint256 outputMaxWeight = data.totalSupply.mulTruncate(data.output.maxWeight);
            uint256 outputVaultBalanceScaled = data.output.vaultBalance.mulRatioTruncate(data.output.ratio);
            // If maxInput = 2, outputVaultBalance = 1, then clamp to 1
            uint256 clampedMax = maxInputScaled > outputVaultBalanceScaled ? outputVaultBalanceScaled : maxInputScaled;
            // if output is overweight, no fee, else fee
            bool applyFee = outputVaultBalanceScaled < outputMaxWeight;
            uint256 maxInputUnits = clampedMax.divRatioPrecisely(data.input.ratio);
            uint256 outputUnitsIncFee = maxInputUnits.mulRatioTruncate(data.input.ratio).divRatioPrecisely(data.output.ratio);

            uint256 fee = applyFee ? data.mAsset.swapFee() : 0;
            uint256 outputFee = outputUnitsIncFee.mulTruncate(fee);
            return (true, "", maxInputUnits, outputUnitsIncFee.sub(outputFee));
        }
    }

    /**
     * @dev Returns a valid bAsset to redeem
     * @param _mAsset Masset addr
     * @return valid bool
     * @return string message
     * @return address of bAsset to redeem
     */
    function suggestRedeemAsset(
        address _mAsset
    )
        external
        view
        returns (
            bool,
            string memory,
            address
        )
    {
        require(_mAsset != address(0), "Invalid mAsset");
        // Get the data
        IBasketManager basketManager = IBasketManager(
            IMasset(_mAsset).getBasketManager()
        );
        Basket memory basket = basketManager.getBasket();
        uint256 totalSupply = IMasset(_mAsset).totalSupply();

        // Calc the max weight delta (i.e is X% away from Max weight)
        uint256 len = basket.bassets.length;
        uint256 overweightCount = 0;
        uint256[] memory maxWeightDelta = new uint256[](len);
        
        for(uint256 i = 0; i < len; i++){
            Basset memory bAsset = basket.bassets[i];
            uint256 scaledBasset = bAsset.vaultBalance.mulRatioTruncate(bAsset.ratio);
            // e.g. (1e21 * 1e18) / 1e23 = 1e16 or 1%
            uint256 weight = scaledBasset.divPrecisely(totalSupply);
            if(weight > bAsset.maxWeight) {
                overweightCount++;
            }
            maxWeightDelta[i] = weight > bAsset.maxWeight ? uint256(-1) : bAsset.maxWeight.sub(weight);
            if(bAsset.status != BassetStatus.Normal){
                return (false, "No assets available", address(0));
            }
        }

        // if > 1 overweight, fail
        if(overweightCount > 1) {
            return (false, "No assets available", address(0));
        } else if(overweightCount == 1){
            // if 1 overweight, choose asset
            for(uint256 j = 0; j < len; j++){
                if(maxWeightDelta[j] == uint256(-1)){
                    return (true, "", basket.bassets[j].addr);
                }
            }
        }
        // else choose highest %
        uint256 lowestDelta = uint256(-1);
        address selected = address(0);
        for(uint256 k = 0; k < len; k++){
            if(maxWeightDelta[k] < lowestDelta) {
                selected = basket.bassets[k].addr;
                lowestDelta = maxWeightDelta[k];
            }
        }
        return (true, "", selected);
    }

    /**
     * @dev Determines if a given Redemption is valid
     * @param _mAsset Address of the given mAsset (e.g. mUSD)
     * @param _mAssetQuantity Amount of mAsset to redeem (in mUSD units)
     * @param _outputBasset Desired output bAsset
     * @return valid
     * @return validity reason
     * @return output in bAsset units
     * @return bAssetQuantityArg - required input argument to the 'redeem' call
     */
    function getRedeemValidity(
        address _mAsset,
        uint256 _mAssetQuantity,
        address _outputBasset
    )
        external
        view
        returns (
            bool,
            string memory,
            uint256 output,
            uint256 bassetQuantityArg
        )
    {
        // Convert the `mAssetQuantity` (input) into bAsset units
        IBasketManager basketManager = IBasketManager(
            IMasset(_mAsset).getBasketManager()
        );
        Basset memory bAsset = basketManager.getBasset(_outputBasset);
        uint256 bAssetQuantity = _mAssetQuantity.divRatioPrecisely(
            bAsset.ratio
        );

        // Prepare params for internal validity
        address[] memory bAssets = new address[](1);
        uint256[] memory quantities = new uint256[](1);
        bAssets[0] = _outputBasset;
        quantities[0] = bAssetQuantity;
        (
            bool valid,
            string memory reason,
            uint256 bAssetOutput
        ) = _getRedeemValidity(_mAsset, bAssets, quantities);
        return (valid, reason, bAssetOutput, bAssetQuantity);
    }


    /***************************************
                    SAVE
    ****************************************/

    /**
     * @dev Gets the users savings balance in Masset terms
     * @param _save SAVE contract address
     * @param _user Address of the user
     * @return balance in Masset units
     */
    function getSaveBalance(
        ISavingsContract _save,
        address _user
    )
        external
        view
        returns (
            uint256
        )
    {
        require(address(_save) != address(0), "Invalid contract");
        require(_user != address(0), "Invalid user");

        uint256 credits = _save.creditBalances(_user);
        uint256 rate = _save.exchangeRate();
        require(rate > 0, "Invalid rate");

        return credits.mulTruncate(rate);
    }

    /**
     * @dev Returns the 'credit' units required to withdraw a certain
     * amount of Masset from the SAVE contract
     * @param _save SAVE contract address
     * @param _mAssetUnits Amount of mAsset to redeem from SAVE
     * @return input for the redeem function (ie. credit units to redeem)
     */
    function getSaveRedeemInput(
        ISavingsContract _save,
        uint256 _mAssetUnits
    )
        external
        view
        returns (
            uint256
        )
    {
        require(address(_save) != address(0), "Invalid contract");

        uint256 rate = _save.exchangeRate();
        require(rate > 0, "Invalid rate");

        uint256 credits = _mAssetUnits.divPrecisely(rate);

        // Add 1 because the amounts always round down
        // e.g. i have 51 credits, e4 10 = 20.4
        // to withdraw 20 i need 20*10/4 = 50 + 1
        return credits + 1;
    }


    /***************************************
                    INTERNAL
    ****************************************/

    struct Data {
        bool isValid;
        string reason;
        IMasset mAsset;
        IBasketManager basketManager;
        bool isMint;
        uint256 totalSupply;
        Basset input;
        Basset output;
    }

    function _getData(address _mAsset, address _input, address _output) internal view returns (Data memory) {
        bool isMint = _output == _mAsset;
        IMasset mAsset = IMasset(_mAsset);
        IBasketManager basketManager = IBasketManager(
            mAsset.getBasketManager()
        );
        (bool isValid, string memory reason, ) = mAsset
            .getSwapOutput(_input, _output, 1);
        uint256 totalSupply = mAsset.totalSupply();
        Basset memory input = basketManager.getBasset(_input);
        Basset memory output = !isMint ? basketManager.getBasset(_output) : Basset({
            addr: _output,
            ratio: StableMath.getRatioScale(),
            maxWeight: 0,
            vaultBalance: 0,
            status: BassetStatus.Normal,
            isTransferFeeCharged: false
        });
        return Data({
            isValid: isValid,
            reason: reason,
            mAsset: mAsset,
            basketManager: basketManager,
            isMint: isMint,
            totalSupply: totalSupply,
            input: input,
            output: output
        });
    }


    function _getRedeemValidity(
        address _mAsset,
        address[] memory _bAssets,
        uint256[] memory _bAssetQuantities
    )
        internal
        view
        returns (
            bool,
            string memory,
            uint256 output
        )
    {
        uint256 bAssetCount = _bAssetQuantities.length;
        require(
            bAssetCount == 1 && bAssetCount == _bAssets.length,
            "Input array mismatch"
        );

        IMasset mAsset = IMasset(_mAsset);
        IBasketManager basketManager = IBasketManager(
            mAsset.getBasketManager()
        );

        Basket memory basket = basketManager.getBasket();

        if (basket.undergoingRecol || basketManager.paused()) {
            return (false, "Invalid basket state", 0);
        }

        (
            bool redemptionValid,
            string memory reason,
            bool applyFee
        ) = _validateRedeem(
            mAsset,
            _bAssetQuantities,
            _bAssets[0],
            basket.failed,
            mAsset.totalSupply(),
            basket.bassets
        );
        if (!redemptionValid) {
            return (false, reason, 0);
        }
        uint256 fee = applyFee ? mAsset.swapFee() : 0;
        uint256 feeAmount = _bAssetQuantities[0].mulTruncate(fee);
        uint256 outputMinusFee = _bAssetQuantities[0].sub(feeAmount);
        return (true, "", outputMinusFee);
    }


    function _validateRedeem(
        IMasset mAsset,
        uint256[] memory quantities,
        address bAsset,
        bool failed,
        uint256 supply,
        Basset[] memory allBassets
    )
        internal
        view
        returns (
            bool,
            string memory,
            bool
        )
    {
        IForgeValidator forgeValidator = IForgeValidator(
            mAsset.forgeValidator()
        );
        uint8[] memory bAssetIndexes = new uint8[](1);
        for (uint8 i = 0; i < uint8(allBassets.length); i++) {
            if (allBassets[i].addr == bAsset) {
                bAssetIndexes[0] = i;
                break;
            }
        }
        return
            forgeValidator.validateRedemption(
                failed,
                supply,
                allBassets,
                bAssetIndexes,
                quantities
            );
    }

}