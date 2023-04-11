// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/core/IVault.sol";
import "../interfaces/core/IVaultUtils.sol";
import "../interfaces/oracles/IOracleRouter.sol";
import "../interfaces/tokens/wlp/IPancakeFactory.sol";

contract Reader {
    uint32 private constant BASIS_POINTS_DIVISOR = 1e4;
    uint128 private constant PRICE_PRECISION = 1e30; 
    uint8 private constant USDW_DECIMALS = 18;

    address public vaultAddress;
    address public vaultUtilsAddress;

    constructor(
        address _vaultAddress,
        address _vaultUtilsAddress
    ) {
        vaultAddress = _vaultAddress;
        vaultUtilsAddress = _vaultUtilsAddress;
    }

    /**
     * @notice returns the maximum amount of tokenIn that can be sold in the WLP
     * @param _vault address of the vault
     * @param _tokenIn the address of the token to be sold
     * @param _tokenOut the address of the token being bought
     * @return amountIn amount of tokenIn that can be sold
     */
    function getMaxAmountIn(
        IVault _vault,
        address _tokenIn, 
        address _tokenOut) public view returns (uint256) {
        uint256 priceIn = _vault.getMinPrice(_tokenIn);
        uint256 priceOut = _vault.getMaxPrice(_tokenOut);
        uint256 tokenInDecimals = _vault.tokenDecimals(_tokenIn);
        uint256 tokenOutDecimals = _vault.tokenDecimals(_tokenOut);
        uint256 amountIn;
        {
            uint256 poolAmount = _vault.poolAmounts(_tokenOut);
            uint256 bufferAmount = _vault.bufferAmounts(_tokenOut);
            if (bufferAmount >= poolAmount) {
                return 0;
            }
            uint256 availableAmount = poolAmount - bufferAmount;
            amountIn = (((availableAmount * priceOut) / priceIn) * (10 ** tokenInDecimals)) / (10 ** tokenOutDecimals);
        }
        uint256 maxUsdwAmount = _vault.maxUsdwAmounts(_tokenIn);
        if (maxUsdwAmount != 0) {
            if (maxUsdwAmount < _vault.usdwAmounts(_tokenIn)) {
                return 0;
            }
            uint256 maxAmountIn = maxUsdwAmount - _vault.usdwAmounts(_tokenIn);
            maxAmountIn = (maxAmountIn * (10 ** tokenInDecimals)) / (10 ** USDW_DECIMALS);
            maxAmountIn = (maxAmountIn * PRICE_PRECISION) / priceIn;
            if (amountIn > maxAmountIn) {
                return maxAmountIn;
            }
        }
        return amountIn;
    }


    /**
     * @notice function that simulates a vault swap and tells the caller how much of _tokenOut they will receive (and how much fees will be paid)
     * @param _vault the address of the vault
     * @param _tokenIn the address of the token being sold
     * @param _tokenOut the address of the token being bought
     * @param _amountIn the amount of tokenIn to be sold
     * @return amountOutAfterFees the amount of tokenOut after the fee is deducted from it
     * @return feeAmount amount of swap fees that will be charged by the vault 
     * @dev the swap fee is always charged in the outgoing token!
     */
    function getAmountOut(
        IVault _vault, 
        address _tokenIn, 
        address _tokenOut, 
        uint256 _amountIn) public view returns (uint256, uint256) {
        uint256 priceIn = _vault.getMinPrice(_tokenIn);

        uint256 tokenInDecimals = _vault.tokenDecimals(_tokenIn);
        uint256 tokenOutDecimals = _vault.tokenDecimals(_tokenOut);

        uint256 feeBasisPoints;
        {
            uint256 usdwAmount = (_amountIn * priceIn) / PRICE_PRECISION;
            usdwAmount = usdwAmount * (10 ** USDW_DECIMALS) / (10 ** tokenInDecimals);
            bool isStableSwap = _vault.stableTokens(_tokenIn) && _vault.stableTokens(_tokenOut);
            uint256 baseBps = isStableSwap ? _vault.stableSwapFeeBasisPoints() : _vault.swapFeeBasisPoints();
            uint256 taxBps = isStableSwap ? _vault.stableTaxBasisPoints() : _vault.taxBasisPoints();
            uint256 feesBasisPoints0 = IVaultUtils(vaultUtilsAddress).getFeeBasisPoints(_tokenIn, usdwAmount, baseBps, taxBps, true);
            uint256 feesBasisPoints1 = IVaultUtils(vaultUtilsAddress).getFeeBasisPoints(_tokenOut, usdwAmount, baseBps, taxBps, false);
            // use the higher of the two fee basis points
            feeBasisPoints = feesBasisPoints0 > feesBasisPoints1 ? feesBasisPoints0 : feesBasisPoints1;
        }
        uint256 priceOut = _vault.getMaxPrice(_tokenOut);
        uint256 amountOut = (_amountIn * priceIn) / priceOut;
        // uint256 amountOut = _amountIn.mul(priceIn).div(priceOut);
        amountOut = amountOut * (10 ** tokenOutDecimals) / (10 ** tokenInDecimals);
        // amountOut = amountOut.mul(10 ** tokenOutDecimals).div(10 ** tokenInDecimals);
        uint256 amountOutAfterFees = (amountOut * (BASIS_POINTS_DIVISOR - feeBasisPoints))  / BASIS_POINTS_DIVISOR;
        // uint256 amountOutAfterFees = amountOut.mul(BASIS_POINTS_DIVISOR.sub(feeBasisPoints)).div(BASIS_POINTS_DIVISOR);
        uint256 feeAmount = amountOut - amountOutAfterFees;
        // uint256 feeAmount = amountOut.sub(amountOutAfterFees);
        return (amountOutAfterFees, feeAmount);
    }

    /**
     * @notice returns the amount of basis points the vault will charge for a swap
     * @param _vault the address of the vault
     * @param _tokenIn the address of the token (being sold)
     * @param _tokenOut the address of the token (being bought)
     * @param _amountIn the amount of tokenIn (being sold)
     * @return feeBasisPoints the actual basisPoint fee that will be charged for this swap
     * @return feesBasisPoints0 the swap fee component of tokenIn
     * @return feesBasisPoints1 the swap fee component of tokenOut
     * @dev take note that feesBasisPoints0 and feesBasisPoints1 are only relevant for context
     */
    function getSwapFeeBasisPoints(
        IVault _vault, 
        address _tokenIn, 
        address _tokenOut, 
        uint256 _amountIn) public view returns (uint256, uint256, uint256) {
        uint256 priceIn = _vault.getMinPrice(_tokenIn);
        uint256 tokenInDecimals = _vault.tokenDecimals(_tokenIn);
        uint256 usdwAmount = (_amountIn * priceIn) / PRICE_PRECISION;
        usdwAmount = (usdwAmount * (10 ** USDW_DECIMALS)) / (10 ** tokenInDecimals);
        bool isStableSwap = _vault.stableTokens(_tokenIn) && _vault.stableTokens(_tokenOut);
        uint256 baseBps = isStableSwap ? _vault.stableSwapFeeBasisPoints() : _vault.swapFeeBasisPoints();
        uint256 taxBps = isStableSwap ? _vault.stableTaxBasisPoints() : _vault.taxBasisPoints();
        uint256 feesBasisPoints0 = IVaultUtils(vaultUtilsAddress).getFeeBasisPoints(_tokenIn, usdwAmount, baseBps, taxBps, true);
        uint256 feesBasisPoints1 = IVaultUtils(vaultUtilsAddress).getFeeBasisPoints(_tokenOut, usdwAmount, baseBps, taxBps, false);
        // use the higher of the two fee basis points
        uint256 feeBasisPoints = feesBasisPoints0 > feesBasisPoints1 ? feesBasisPoints0 : feesBasisPoints1;
        return (feeBasisPoints, feesBasisPoints0, feesBasisPoints1);
    }

    /**
     * @notice returns an array with the accumulated swap fees per vault asset
     * @param _vault address of the vault
     * @param _tokens array with the tokens you want to know the accumulated fee reserves from
     */
    function getFees(address _vault, address[] memory _tokens) public view returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            amounts[i] = IVault(_vault).swapFeeReserves(_tokens[i]);
        }
        return amounts;
    }

    /**
     * @notice returns an array with the accumulated wager fees per vault asset
     * @param _vault address of the vault
     * @param _tokens array with the tokens you want to know the accumulated fee reserves from
     */
    function getWagerFees(address _vault, address[] memory _tokens) public view returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            amounts[i] = IVault(_vault).wagerFeeReserves(_tokens[i]);
        }
        return amounts;
    }

    /**
     * @notice view function that returns array with token pair ifno
     * @param _factory address of the tokenfactory contract (uniswap v2)
     * @param _tokens array with tokens to query the pairs on
     */
    function getPairInfo(
        address _factory, 
        address[] memory _tokens) public view returns (uint256[] memory) {
        uint256 inputLength = 2;
        uint256 propsLength = 2;
        uint256[] memory amounts = new uint256[](_tokens.length / inputLength * propsLength);
        for (uint256 i = 0; i < _tokens.length / inputLength; i++) {
            address token0 = _tokens[i * inputLength];
            address token1 = _tokens[i * inputLength + 1];
            address pair = IPancakeFactory(_factory).getPair(token0, token1);
            amounts[i * propsLength] = IERC20(token0).balanceOf(pair);
            amounts[i * propsLength + 1] = IERC20(token1).balanceOf(pair);
        }
        return amounts;
    }

    function getTokenSupply(
        IERC20 _token, 
        address[] memory _excludedAccounts) public view returns (uint256) {
        uint256 supply = _token.totalSupply();
        for (uint256 i = 0; i < _excludedAccounts.length; i++) {
            address account = _excludedAccounts[i];
            uint256 balance = _token.balanceOf(account);
            supply -=  balance;
        }
        return supply;
    }

    function getTotalBalance(
        IERC20 _token, 
        address[] memory _accounts) public view returns (uint256) {
        uint256 totalBalance = 0;
        for (uint256 i = 0; i < _accounts.length; i++) {
            address account = _accounts[i];
            uint256 balance = _token.balanceOf(account);
            totalBalance += balance;
        }
        return totalBalance;
    }

    function getTokenBalances(
        address _account, 
        address[] memory _tokens) public view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            if (token == address(0)) {
                balances[i] = _account.balance;
                continue;
            }
            balances[i] = IERC20(token).balanceOf(_account);
        }
        return balances;
    }

    function getTokenBalancesWithSupplies(
        address _account, 
        address[] memory _tokens) public view returns (uint256[] memory) {
        uint256 propsLength = 2;
        uint256[] memory balances = new uint256[](_tokens.length * propsLength);
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            if (token == address(0)) {
                balances[i * propsLength] = _account.balance;
                balances[i * propsLength + 1] = 0;
                continue;
            }
            balances[i * propsLength] = IERC20(token).balanceOf(_account);
            balances[i * propsLength + 1] = IERC20(token).totalSupply();
        }
        return balances;
    }

    /**
     * 
     * @param _priceFeed address of the price feed to query
     * @param _tokens array of tokens to query (muset be whitelisted)
     */
    function getPrices(
        IOracleRouter _priceFeed, 
        address[] memory _tokens) public view returns (uint256[] memory) {
        uint256 propsLength = 6;
        uint256[] memory amounts = new uint256[](_tokens.length * propsLength);
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            amounts[i * propsLength] = _priceFeed.getPrice(token, true, true, false);
            amounts[i * propsLength + 1] = _priceFeed.getPrice(token, false, true, false);
            amounts[i * propsLength + 2] = _priceFeed.getPrimaryPrice(token, true);
            amounts[i * propsLength + 3] = _priceFeed.getPrimaryPrice(token, false);
            amounts[i * propsLength + 4] = _priceFeed.isAdjustmentAdditive(token) ? 1 : 0;
            amounts[i * propsLength + 5] = _priceFeed.adjustmentBasisPoints(token);
        }
        return amounts;
    }

    function getVaultTokenInfo(
        address _vault, 
        address _weth, 
        uint256 _usdwAmount, 
        address[] memory _tokens) public view returns (uint256[] memory) {
        uint256 propsLength = 8;

        IVault vault = IVault(_vault);
        IOracleRouter priceOracleRouter = IOracleRouter(vault.priceOracleRouter());

        uint256[] memory amounts = new uint256[](_tokens.length * propsLength);
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            if (token == address(0)) {
                token = _weth;
            }
            amounts[i * propsLength] = vault.poolAmounts(token);
            amounts[i * propsLength + 1] = vault.usdwAmounts(token);
            amounts[i * propsLength + 2] = vault.getRedemptionAmount(token, _usdwAmount);
            amounts[i * propsLength + 3] = vault.tokenWeights(token);
            amounts[i * propsLength + 4] = vault.getMinPrice(token);
            amounts[i * propsLength + 5] = vault.getMaxPrice(token);
            amounts[i * propsLength + 6] = priceOracleRouter.getPrimaryPrice(token, false);
            amounts[i * propsLength + 7] = priceOracleRouter.getPrimaryPrice(token, true);
        }
        return amounts;
    }

    /**
     * @param _vault address of the vault
     * @param _weth wrapped eth address
     * @param _usdwAmount amount of usdw to query (1e18)
     * @param _tokens array of tokens to iterate over (vault asssets)
     */
    function getFullVaultTokenInfo(
        address _vault, 
        address _weth, 
        uint256 _usdwAmount, 
        address[] memory _tokens) public view returns (uint256[] memory) {
        uint256 propsLength = 10;

        IVault vault = IVault(_vault);
        IOracleRouter priceOracleRouter = IOracleRouter(vault.priceOracleRouter());

        uint256[] memory amounts = new uint256[](_tokens.length * propsLength);
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            if (token == address(0)) {
                token = _weth;
            }
            amounts[i * propsLength] = vault.poolAmounts(token);
            amounts[i * propsLength + 1] = vault.usdwAmounts(token);
            amounts[i * propsLength + 2] = vault.getRedemptionAmount(token, _usdwAmount);
            amounts[i * propsLength + 3] = vault.tokenWeights(token);
            amounts[i * propsLength + 4] = vault.bufferAmounts(token);
            amounts[i * propsLength + 5] = vault.maxUsdwAmounts(token);
            amounts[i * propsLength + 6] = vault.getMinPrice(token);
            amounts[i * propsLength + 7] = vault.getMaxPrice(token);
            amounts[i * propsLength + 8] = priceOracleRouter.getPrimaryPrice(token, false);
            amounts[i * propsLength + 9] = priceOracleRouter.getPrimaryPrice(token, true);
        }
        return amounts;
    }

    /**
     * @notice prices a certain amount of _tokenInAddress in _tokenOutAddress
     * @param _tokenInAddress address of the token the winnings are priced in
     * @param _tokenOutAddress address of the token that the player wants to win
     * @param _amountIn amount of the _tokenInAddress that we want to price in _tokenOutAddress
     */
    function amountOfTokenForToken(
        address _tokenInAddress,
        address _tokenOutAddress,
        uint256 _amountIn
    ) internal view returns(uint256 amountOut_) {
        IVault vault_ = IVault(vaultAddress);
        uint256 priceIn_ = vault_.getMinPrice(_tokenInAddress);
        uint256 priceOut_ = vault_.getMaxPrice(_tokenOutAddress);
        amountOut_ = (_amountIn * priceIn_) / priceOut_;
        amountOut_ = vault_.adjustForDecimals(
            amountOut_, 
            _tokenInAddress, 
            _tokenOutAddress
        );
        return amountOut_;
    }

    /**
     * @notice function that returns how much swap and wager fees a player will pay in a certain wager configuration
     * @dev this function is useful for players before they execute a game, since it tells them how much they will pay in fees
     * @param _tokenWager address of the token the player wagers in
     * @param _tokenWinnings address of the token the player has chosen to win
     * @param _amountWager amount of _tokenWager that is wagered
     * @param _winnings possible player winnings, denominated in _tokenWager
     * @return amountWon_ net amount of _tokenWinnings that player will receive 
     * @return wagerFeeToken_ amount of wagerfees (in _tokenWager deducted) paid by vault
     * @return swapFeeToken_ amount of swapfees (in _tokenWinnings deducted)
     */
    function getNetWinningsAmount(
        address _tokenWager,
        address _tokenWinnings,
        uint256 _amountWager,
        uint256 _winnings
    ) external view returns(
        uint256 amountWon_,
        uint256 wagerFeeToken_,
        uint256 swapFeeToken_
    ) {
        wagerFeeToken_ = (_amountWager *  IVault(vaultAddress).wagerFeeBasisPoints()) / 1e18;
        if (_tokenWager == _tokenWinnings) {
            // if tokenWager is the same as _tokenWinnings no swap is needed
            swapFeeToken_ = 0;
            amountWon_ = _winnings;
            return(amountWon_, wagerFeeToken_, swapFeeToken_);
        } else {
            // calculate how much will have to be swapped
            uint256 amountOutTotal_ = amountOfTokenForToken(_tokenWager, _tokenWinnings, _winnings);
            (, swapFeeToken_) = getAmountOut(
                IVault(vaultAddress), 
                _tokenWager, 
                _tokenWinnings, 
                (_amountWager - wagerFeeToken_)
            );
            amountWon_ = (amountOutTotal_ - swapFeeToken_);
            return(amountWon_, wagerFeeToken_, swapFeeToken_);
        }
    }

    /**
     * @notice function that returns how much of _tokenWager will be be swapped in the payout, also it returns the amount of basispoints to be charged
     * @param _tokenWager address of the token the player wagers in
     * @param _tokenWinnings address of the token the player has chosen to win
     * @param _amountWager amount of _tokenWager that is wagered
     * @return swapBasisPoints_ amount of swapfees in basis points that the player will have to pay
     * @return amountToBeSwapped_ amount of _tokenWager that needs to be swapped for _tokenWinnings
     */
    function getSwapBasisPoints(
        address _tokenWager,
        address _tokenWinnings,
        uint256 _amountWager
    ) external view returns(
        uint256 swapBasisPoints_,
        uint256 amountToBeSwapped_
    ) {
        uint256 wagerFeeToken_ = (_amountWager *  IVault(vaultAddress).wagerFeeBasisPoints()) / 1e18;
        if (_tokenWager == _tokenWinnings) {
            // if tokenWager is the same as _tokenWinnings no swap is needed
            swapBasisPoints_ = 0;
            return (swapBasisPoints_, 0);
        } else {
            // calculate how much will have to be swapped
            // uint256 amountOutTotal_ = amountOfTokenForToken(
            //     _tokenWager, 
            //     _tokenWinnings, 
            //     (_winnings - wagerFeeToken_)
            // );
            amountToBeSwapped_ = (_amountWager - wagerFeeToken_);
            (swapBasisPoints_,,) = getSwapFeeBasisPoints(
                IVault(vaultAddress), 
                _tokenWager, 
                _tokenWinnings, 
                amountToBeSwapped_
            );
            return (swapBasisPoints_, amountToBeSwapped_);
        }
    }

    function calcFeeToBePaid(
        uint256 _amountPrincipal,
        uint256 _basisPoints
    ) public pure returns(uint256 feeAmount_) {
        if(_basisPoints == 0) {
            return 0;
        } else {
            feeAmount_ = (_amountPrincipal * _basisPoints) / BASIS_POINTS_DIVISOR;
        }
    }

    function returnUsdwAmount(
        address _tokenIn,
        uint256 _amountIn
    ) public view returns(uint256 usdwAmount_) {
        IVault vault_ = IVault(vaultAddress);
        uint256 priceIn_ = vault_.getMinPrice(_tokenIn);
        usdwAmount_ = (_amountIn * priceIn_) / PRICE_PRECISION;
        uint256 tokenInDecimals_ = vault_.tokenDecimals(_tokenIn);
        usdwAmount_ = (usdwAmount_ * (10 ** USDW_DECIMALS)) / (10 ** tokenInDecimals_);
    }

    /**
     * @notice function that returns a swap fee matrix, allowing to access what the best route is
     * @dev take note that _addressTokenOut assumes that 1e30 represents $1 USD (so don't plug 1e18 value since this value represents fractions of a cent and will break for example swapping to BTC)
     * @param _usdValueOfSwapAsset USD value of the asset that is considered to be traded into the WLP - scaled 1e30!!
     * @return swapFeeArray_ matrix with the swap fees for each possible swap route
     * @dev to check what index belongs to what swap, the sequence of the whitelisted tokens need to be informed!
     */
    function getSwapFeePercentageMatrix(
        uint256 _usdValueOfSwapAsset
    ) external view returns(uint256[] memory) {
        IVault vault_ = IVault(vaultAddress);
        uint256 length_ = vault_.allWhitelistedTokensLength();
        uint256[] memory swapFeeArray_ = new uint256[](length_ * length_);
        uint256 count_;
        for (uint i=0; i < length_; i++) {
            address tokenIn_ = vault_.allWhitelistedTokens(i);
            uint256 tokenAmountIn_ = vault_.usdToTokenMin(tokenIn_, _usdValueOfSwapAsset);
            for (uint b=0; b < length_; b++) {
                address tokenOut_ = vault_.allWhitelistedTokens(b);
                uint256 swapFeePercentage_;
                // it is not possible to swap the same token (and not needed)
                if(tokenOut_ == tokenIn_) {
                    swapFeePercentage_ = 0;
                } else {
                    swapFeePercentage_ = IVaultUtils(vaultUtilsAddress).getSwapFeeBasisPoints(
                        tokenIn_,
                        tokenOut_,
                        returnUsdwAmount(tokenIn_, tokenAmountIn_)
                    );
                }
                swapFeeArray_[count_] = swapFeePercentage_;
                count_ += 1;
            }
        }
        return swapFeeArray_;
    }

    /**
     * @notice this function returns to the player what asset the player should wager and what player should configure to win to pay as little swap fee as possible
     * @param _usdValueWager usd value (needs to be scaled 1e30) of what the player is planning to wager
     * @return wagerAsset_ address of the asset that can best be wagered
     * @return winAsset_ address of the asset that can best be won
     * @return basisPoint_ amount of basispoints (if any) the player will have to pay
     */
    function whatIsTheCheapestWagerWinningLeg(
        uint256 _usdValueWager
    ) external view returns(
        address wagerAsset_,
        address winAsset_,
        uint256 basisPoint_
    ) {
        // we start with a 100% swap rate, since if we keep this variable at 0, we will never find a lower rate (any return of getSwapFeeBasisPoints)
        basisPoint_ = 10000;
        IVault vault_ = IVault(vaultAddress);
        uint256 length_ = vault_.allWhitelistedTokensLength();
        for (uint i=0; i < length_; i++) {
            address tokenIn_ = vault_.allWhitelistedTokens(i);
            uint256 tokenAmountIn_ = vault_.usdToTokenMin(tokenIn_, _usdValueWager);
            for (uint b=0; b < length_; b++) {
                address tokenOut_ = vault_.allWhitelistedTokens(b);
                // if the tokens are the same, no swap is possible or needed
                if(tokenOut_ == tokenIn_) {
                    // continue the loop, but don't store/overwrite the results so far!
                    continue;
                }
               (uint256 swapFeePercentage_,,) = getSwapFeeBasisPoints(
                    vault_,
                    tokenIn_,
                    tokenOut_,
                    tokenAmountIn_
                );
                // we found a more favorable swap route! so we store it
                if(swapFeePercentage_ < basisPoint_) {
                    basisPoint_ = swapFeePercentage_;
                    wagerAsset_ = tokenIn_;
                    winAsset_ = tokenOut_;
                } 
            }
        }
    return(wagerAsset_, winAsset_, basisPoint_);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "./IVaultUtils.sol";

interface IVault {
    /*==================== Events *====================*/
    event BuyUSDW(
        address account, 
        address token, 
        uint256 tokenAmount, 
        uint256 usdwAmount, 
        uint256 feeBasisPoints
    );
    event SellUSDW(
        address account, 
        address token, 
        uint256 usdwAmount, 
        uint256 tokenAmount, 
        uint256 feeBasisPoints
    );
    event Swap(
        address account, 
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn, 
        uint256 indexed amountOut, 
        uint256 indexed amountOutAfterFees, 
        uint256 indexed feeBasisPoints
    );
    event DirectPoolDeposit(address token, uint256 amount);
    error TokenBufferViolation(address tokenAddress);
    error PriceZero();

    event PayinWLP(
        // address of the token sent into the vault 
        address tokenInAddress,
        // amount payed in (was in escrow)
        uint256 amountPayin
    );

    event PlayerPayout(
        // address the player receiving the tokens (do we need this? i guess it does not matter to who we send tokens for profit/loss calculations?)
        address recipient,
        // address of the token paid to the player
        address tokenOut,
        // net amount sent to the player (this is NOT the net loss, since it includes the payed in tokens, excludes wagerFee and swapFee!)
        uint256 amountPayoutTotal
    );

    event AmountOutNull();

    event WithdrawAllFees(
        address tokenCollected,
        uint256 swapFeesCollected,
        uint256 wagerFeesCollected,
        uint256 referralFeesCollected
    );

    event RebalancingWithdraw(
        address tokenWithdrawn,
        uint256 amountWithdrawn
    );

    event RebalancingDeposit(
        address tokenDeposit,
        uint256 amountDeposit
    );

    event WagerFeeChanged(
        uint256 newWagerFee
    );

    /*==================== Operational Functions *====================*/
    function isInitialized() external view returns (bool);
    function isSwapEnabled() external view returns (bool);
    function setVaultUtils(IVaultUtils _vaultUtils) external;
    function setError(uint256 _errorCode, string calldata _error) external;
    function router() external view returns (address);
    function usdw() external view returns (address);
    function feeCollector() external returns(address);
    function hasDynamicFees() external view returns (bool);
    function totalTokenWeights() external view returns (uint256);
    function getTargetUsdwAmount(address _token) external view returns (uint256);
    function inManagerMode() external view returns (bool);
    function isManager(address _account) external view returns (bool);
    function tokenBalances(address _token) external view returns (uint256);
    function setInManagerMode(bool _inManagerMode) external;
    function setManager(address _manager, bool _isManager, bool _isWLPManager) external;
    function setIsSwapEnabled(bool _isSwapEnabled) external;
    function setUsdwAmount(address _token, uint256 _amount) external;
    function setBufferAmount(address _token, uint256 _amount) external;
    function setFees(
        uint256 _taxBasisPoints,
        uint256 _stableTaxBasisPoints,
        uint256 _mintBurnFeeBasisPoints,
        uint256 _swapFeeBasisPoints,
        uint256 _stableSwapFeeBasisPoints,
        uint256 _minimumBurnMintFee,
        bool _hasDynamicFees
    ) external;
    function setTokenConfig(
        address _token,
        uint256 _tokenDecimals,
        uint256 _redemptionBps,
        uint256 _maxUsdwAmount,
        bool _isStable
    ) external;
    function setPriceFeedRouter(address _priceFeed) external;
    function withdrawAllFees(address _token) external returns (uint256,uint256,uint256);
    function directPoolDeposit(address _token) external;
    function deposit(address _tokenIn, address _receiver) external returns (uint256);
    function withdraw(address _tokenOut, address _receiverTokenOut) external returns (uint256);
    function swap(address _tokenIn, address _tokenOut, address _receiver) external returns (uint256);
    function tokenToUsdMin(address _tokenToPrice, uint256 _tokenAmount) external view returns (uint256);
    function priceOracleRouter() external view returns (address);
    function taxBasisPoints() external view returns (uint256);
    function stableTaxBasisPoints() external view returns (uint256);
    function mintBurnFeeBasisPoints() external view returns (uint256);
    function swapFeeBasisPoints() external view returns (uint256);
    function stableSwapFeeBasisPoints() external view returns (uint256);
    function minimumBurnMintFee() external view returns (uint256);
    function allWhitelistedTokensLength() external view returns (uint256);
    function allWhitelistedTokens(uint256) external view returns (address);
    function whitelistedTokens(address _token) external view returns (bool);
    function stableTokens(address _token) external view returns (bool);
    function swapFeeReserves(address _token) external view returns (uint256);
    function tokenDecimals(address _token) external view returns (uint256);
    function tokenWeights(address _token) external view returns (uint256);
    function poolAmounts(address _token) external view returns (uint256);
    function bufferAmounts(address _token) external view returns (uint256);
    function usdwAmounts(address _token) external view returns (uint256);
    function maxUsdwAmounts(address _token) external view returns (uint256);
    function getRedemptionAmount(address _token, uint256 _usdwAmount) external view returns (uint256);
    function getMaxPrice(address _token) external view returns (uint256);
    function getMinPrice(address _token) external view returns (uint256);
    function setVaultManagerAddress(address _vaultManagerAddress) external;
    function vaultManagerAddress() external view returns (address);
    function wagerFeeBasisPoints() external view returns (uint256);
    function setWagerFee(uint256 _wagerFee) external;
    function wagerFeeReserves(address _token) external view returns(uint256);
    function referralReserves(address _token) external view returns(uint256);
    function setFeeLessForPayout(bool _setting) external;
    function getReserve() external view returns (uint256);
    function getDollarValue(address _token) external view returns (uint256);
    function getWlpValue() external view returns (uint256);
    function usdToTokenMin(address _token, uint256 _usdAmount) external view returns(uint256);
    function usdToTokenMax(address _token, uint256 _usdAmount) external view returns(uint256);
    function usdToToken(address _token, uint256 _usdAmount, uint256 _price) external view returns(uint256);
    function returnTotalInAndOut(address token_) external view returns(uint256 totalOutAllTime_, uint256 totalInAllTime_);

    function adjustForDecimals(
        uint256 _amount, 
        address _tokenDiv, 
        address _tokenMul) external view returns (uint256 scaledAmount_);

    function payout(
        address[2] memory _tokens,
        address _escrowAddress,
        uint256 _escrowAmount,
        address _recipient,
        uint256 _totalAmount
    ) external;

    function payin(
        address _inputToken,
        address _escrowAddress,
        uint256 _escrowAmount
    ) external;

    function setAsideReferral(
        address _token,
        uint256 _amount
    ) external;

    function rebalanceWithdraw(
        address _tokenToRebalanceWith,
        uint256 _amountToRebalanceWith
    ) external;

    function rebalanceDeposit(
        address _tokenInDeposited,
        uint256 _amountDeposited
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

interface IVaultUtils {
    function getBuyUsdwFeeBasisPoints(address _token, uint256 _usdwAmount) external view returns (uint256);
    function getSellUsdwFeeBasisPoints(address _token, uint256 _usdwAmount) external view returns (uint256);
    function getSwapFeeBasisPoints(address _tokenIn, address _tokenOut, uint256 _usdwAmount) external view returns (uint256);
    function getFeeBasisPoints(address _token, uint256 _usdwDelta, uint256 _feeBasisPoints, uint256 _taxBasisPoints, bool _increment) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

interface IOracleRouter {
    function getPrice(address _token, bool _maximise, bool _includeAmmPrice, bool _useSwapPricing) external view returns (uint256);
    function getPriceMax(address _token) external view returns (uint256);
    function primaryPriceFeed() external view returns (address);
    function getPriceMin(address _token) external view returns (uint256);
    function getPrimaryPrice(address _token, bool _maximise) external view returns (uint256);
    function isAdjustmentAdditive(address _token) external view returns (bool);
    function adjustmentBasisPoints(address _token) external view returns (uint256);
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}