// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Interfaces
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC20} from "../external/interfaces/IERC20.sol";

// Structs
import {Addresses, EpochData, EpochStrikeData, VaultCheckpoint} from "./SsovV3Structs.sol";

/// @title SSOV V3 interface
interface ISsovV3 is IERC721Enumerable {
    function isPut() external view returns (bool);

    function currentEpoch() external view returns (uint256);

    function collateralPrecision() external view returns (uint256);

    function addresses() external view returns (Addresses memory);

    function collateralToken() external view returns (IERC20);

    function deposit(
        uint256 strikeIndex,
        uint256 amount,
        address to
    ) external returns (uint256 tokenId);

    function purchase(
        uint256 strikeIndex,
        uint256 amount,
        address to
    ) external returns (uint256 premium, uint256 totalFee);

    function settle(
        uint256 strikeIndex,
        uint256 amount,
        uint256 epoch,
        address to
    ) external returns (uint256 pnl);

    function withdraw(uint256 tokenId, address to)
        external
        returns (
            uint256 collateralTokenWithdrawAmount,
            uint256[] memory rewardTokenWithdrawAmounts
        );

    function getUnderlyingPrice() external view returns (uint256);

    function getCollateralPrice() external view returns (uint256);

    function getVolatility(uint256 _strike) external view returns (uint256);

    function calculatePremium(
        uint256 _strike,
        uint256 _amount,
        uint256 _expiry
    ) external view returns (uint256 premium);

    function calculatePnl(
        uint256 price,
        uint256 strike,
        uint256 amount
    ) external view returns (uint256);

    function calculatePurchaseFees(uint256 strike, uint256 amount)
        external
        view
        returns (uint256);

    function calculateSettlementFees(uint256 pnl)
        external
        view
        returns (uint256);

    function getEpochTimes(uint256 epoch)
        external
        view
        returns (uint256 start, uint256 end);

    function writePosition(uint256 tokenId)
        external
        view
        returns (
            uint256 epoch,
            uint256 strike,
            uint256 collateralAmount,
            uint256 checkpointIndex,
            uint256[] memory rewardDistributionRatios
        );

    function getEpochData(uint256 epoch)
        external
        view
        returns (EpochData memory);

    function getEpochStrikeData(uint256 epoch, uint256 strike)
        external
        view
        returns (EpochStrikeData memory);

    function getEpochStrikeCheckpointsLength(uint256 epoch, uint256 strike)
        external
        view
        returns (uint256);

    function checkpoints(
        uint256 epoch,
        uint256 strike,
        uint256 index
    ) external view returns (VaultCheckpoint memory);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

struct Addresses {
    address feeStrategy;
    address stakingStrategy;
    address optionPricing;
    address priceOracle;
    address volatilityOracle;
    address feeDistributor;
    address optionsTokenImplementation;
}

struct EpochData {
    bool expired;
    uint256 startTime;
    uint256 expiry;
    uint256 settlementPrice;
    uint256 totalCollateralBalance; // Premium + Deposits from all strikes
    uint256 collateralExchangeRate; // Exchange rate for collateral to underlying (Only applicable to CALL options)
    uint256 settlementCollateralExchangeRate; // Exchange rate for collateral to underlying on settlement (Only applicable to CALL options)
    uint256[] strikes;
    uint256[] totalRewardsCollected;
    uint256[] rewardDistributionRatios;
    address[] rewardTokensToDistribute;
}

struct EpochStrikeData {
    address strikeToken;
    uint256 totalCollateral;
    uint256 activeCollateral;
    uint256 totalPremiums;
    uint256 checkpointPointer;
    uint256[] rewardStoredForPremiums;
    uint256[] rewardDistributionRatiosForPremiums;
}

struct VaultCheckpoint {
    uint256 activeCollateral;
    uint256 totalCollateral;
    uint256 accruedPremium;
}

struct WritePosition {
    uint256 epoch;
    uint256 strike;
    uint256 collateralAmount;
    uint256 checkpointIndex;
    uint256[] rewardDistributionRatios;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * NOTE: Modified to include symbols and decimals.
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Interfaces
import {ISsovV3} from "../core/ISsovV3.sol";
import {IERC20} from "../external/interfaces/IERC20.sol";

// Structs
import {VaultCheckpoint, WritePosition, EpochStrikeData, EpochData} from "../core/SsovV3Structs.sol";

contract SsovV3Viewer {
    /// @notice Returns the strike token addresses for an epoch
    /// @param epoch target epoch
    /// @param ssov target ssov
    function getEpochStrikeTokens(uint256 epoch, ISsovV3 ssov)
        public
        view
        returns (address[] memory strikeTokens)
    {
        uint256[] memory strikes = ssov.getEpochData(epoch).strikes;
        strikeTokens = new address[](strikes.length);

        for (uint256 i; i < strikes.length; ) {
            EpochStrikeData memory _temp = ssov.getEpochStrikeData(
                epoch,
                strikes[i]
            );
            strikeTokens[i] = _temp.strikeToken;

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Returns total epoch strike deposits array for an epoch
    /// @param epoch target epoch
    /// @param ssov target ssov
    function getTotalEpochStrikeDeposits(uint256 epoch, ISsovV3 ssov)
        external
        view
        returns (uint256[] memory totalEpochStrikeDeposits)
    {
        uint256[] memory strikes = ssov.getEpochData(epoch).strikes;
        totalEpochStrikeDeposits = new uint256[](strikes.length);
        for (uint256 i; i < strikes.length; ) {
            uint256 strike = strikes[i];
            VaultCheckpoint[] memory checkpoints = getCheckpoints(
                epoch,
                strike,
                ssov
            );

            for (uint256 j; j < checkpoints.length; ) {
                totalEpochStrikeDeposits[i] += checkpoints[j].totalCollateral;

                unchecked {
                    ++j;
                }
            }

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Returns total epoch options purchased array for an epoch
    /// @param epoch target epoch
    /// @param ssov target ssov
    function getTotalEpochOptionsPurchased(uint256 epoch, ISsovV3 ssov)
        external
        view
        returns (uint256[] memory _totalEpochOptionsPurchased)
    {
        address[] memory strikeTokens = getEpochStrikeTokens(epoch, ssov);
        _totalEpochOptionsPurchased = new uint256[](strikeTokens.length);
        for (uint256 i; i < strikeTokens.length; ) {
            _totalEpochOptionsPurchased[i] = IERC20(strikeTokens[i])
                .totalSupply();

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Returns the total epoch premium for each strike for an epoch
    /// @param epoch target epoch
    /// @param ssov target ssov
    function getTotalEpochPremium(uint256 epoch, ISsovV3 ssov)
        external
        view
        returns (uint256[] memory _totalEpochPremium)
    {
        uint256[] memory strikes = ssov.getEpochData(epoch).strikes;
        _totalEpochPremium = new uint256[](strikes.length);

        uint256 strike;

        for (uint256 i; i < strikes.length; ) {
            strike = strikes[i];
            EpochStrikeData memory _temp = ssov.getEpochStrikeData(
                epoch,
                strike
            );
            _totalEpochPremium[i] = _temp.totalPremiums;

            unchecked {
                ++i;
            }
        }
    }

    /// @dev Internal function to get the estimated collateral usage for a checkpoint
    /// @param _checkpoint The checkpoint
    /// @param ssov The ssov
    /// @param strike The strike
    /// @param collateralAmount The collateral amount
    function _getEstimatedCollateralUsage(
        VaultCheckpoint memory _checkpoint,
        ISsovV3 ssov,
        uint256 strike,
        uint256 collateralAmount
    ) private view returns (uint256) {
        return
            ((_checkpoint.totalCollateral -
                ssov.calculatePnl(
                    ssov.getUnderlyingPrice(),
                    strike,
                    ssov.isPut()
                        ? (_checkpoint.activeCollateral * 1e8) / strike
                        : _checkpoint.activeCollateral
                )) * collateralAmount) / _checkpoint.totalCollateral;
    }

    /// @notice Returns the premium & rewards collected for a write position
    /// @param tokenId token id of the write position
    /// @param ssov target ssov
    function getWritePositionValue(uint256 tokenId, ISsovV3 ssov)
        external
        view
        returns (
            uint256 estimatedCollateralUsage,
            uint256 accruedPremium,
            uint256[] memory rewardTokenWithdrawAmounts
        )
    {
        (
            uint256 epoch,
            uint256 strike,
            uint256 collateralAmount,
            uint256 checkpointIndex,
            uint256[] memory rewardDistributionRatios
        ) = ssov.writePosition(tokenId);

        EpochStrikeData memory epochStrikeData = ssov.getEpochStrikeData(
            epoch,
            strike
        );

        EpochData memory epochData = ssov.getEpochData(epoch);

        // Get the checkpoint
        VaultCheckpoint memory _checkpoint = getCheckpoints(
            epoch,
            strike,
            ssov
        )[checkpointIndex];

        accruedPremium =
            (_checkpoint.accruedPremium * collateralAmount) /
            _checkpoint.totalCollateral;

        // Calculate the withdrawable collateral amount
        estimatedCollateralUsage = _getEstimatedCollateralUsage(
            _checkpoint,
            ssov,
            strike,
            collateralAmount
        );

        rewardTokenWithdrawAmounts = new uint256[](
            epochData.rewardTokensToDistribute.length
        );

        for (uint256 i; i < rewardTokenWithdrawAmounts.length; ) {
            rewardTokenWithdrawAmounts[i] +=
                ((epochData.rewardDistributionRatios[i] -
                    rewardDistributionRatios[i]) * collateralAmount) /
                1e18;
            if (epochStrikeData.totalPremiums > 0)
                rewardTokenWithdrawAmounts[i] +=
                    (accruedPremium *
                        epochStrikeData.rewardStoredForPremiums[i]) /
                    epochStrikeData.totalPremiums;
            unchecked {
                i++;
            }
        }
    }

    /// @notice Returns the tokenIds owned by a wallet of a particular ssov
    /// @param owner wallet owner
    /// @param ssov target ssov
    function walletOfOwner(address owner, ISsovV3 ssov)
        public
        view
        returns (uint256[] memory tokenIds)
    {
        uint256 ownerTokenCount = ssov.balanceOf(owner);
        tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; ) {
            tokenIds[i] = ssov.tokenOfOwnerByIndex(owner, i);

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Gets the checkpoints of an ssov for an epoch and strike
    /// @param epoch The epoch
    /// @param strike The strike
    /// @param ssov The ssov
    function getCheckpoints(
        uint256 epoch,
        uint256 strike,
        ISsovV3 ssov
    ) public view returns (VaultCheckpoint[] memory checkpoints) {
        uint256 len = ssov.getEpochStrikeCheckpointsLength(epoch, strike);

        checkpoints = new VaultCheckpoint[](len);

        for (uint256 i; i < len; ) {
            checkpoints[i] = ssov.checkpoints(epoch, strike, i);

            unchecked {
                ++i;
            }
        }
    }
}