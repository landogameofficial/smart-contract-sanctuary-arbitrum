// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AggregatorInterface.sol";
import "./AggregatorV3Interface.sol";

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface {}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC20} from "./IERC20.sol";

interface ICrv2Pool is IERC20 {
    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount)
        external
        returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount
    ) external returns (uint256);

    function get_virtual_price() external view returns (uint256);
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

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IPriceOracle {
    function getCollateralPrice() external view returns (uint256);

    function getUnderlyingPrice() external view returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Interfaces
import {AggregatorV2V3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV2V3Interface.sol";
import {IPriceOracle} from "../../interfaces/IPriceOracle.sol";
import {ICrv2Pool} from "../../external/interfaces/ICrv2Pool.sol";

contract StEthCallPriceOracle is IPriceOracle {
    uint256 public constant GRACE_PERIOD_TIME = 3600;

    error SequencerDown();
    error GracePeriodNotOver();
    error HeartbeatNotFulfilled();

    // stETH/USD
    AggregatorV2V3Interface public constant ST_ETH_PRICE_FEED =
        AggregatorV2V3Interface(0x07C5b924399cc23c24a95c8743DE4006a32b7f2a);

    // wstETH/stETH
    AggregatorV2V3Interface public constant WST_ETH_PRICE_FEED =
        AggregatorV2V3Interface(0xB1552C5e96B312d0Bf8b554186F846C40614a540);

    AggregatorV2V3Interface public constant SEQUENCER_UPTIME_FEED =
        AggregatorV2V3Interface(0xFdB631F5EE196F0ed6FAa767959853A9F217697D);

    /**
     * Network: Arbitrum Mainnet
     * Data Feed: stETH/USD
     * Data Feed Proxy Address: 0x07C5b924399cc23c24a95c8743DE4006a32b7f2a
     * Sequencer Uptime Proxy Address: 0xFdB631F5EE196F0ed6FAa767959853A9F217697D
     */

    /// @notice Returns the collateral price
    function getUnderlyingPrice() external view returns (uint256) {
        return _getPrice(ST_ETH_PRICE_FEED);
    }

    /**
     * Network: Arbitrum Mainnet
     * Data Feed: wstETH/stETH
     * Data Feed Proxy Address: 0xc373B9DB0707fD451Bc56bA5E9b029ba26629DF0
     * Sequencer Uptime Proxy Address: 0xFdB631F5EE196F0ed6FAa767959853A9F217697D
     */
    /// @notice Returns the underlying price
    function getCollateralPrice() external view returns (uint256) {
        return
            (_getPrice(WST_ETH_PRICE_FEED) * _getPrice(ST_ETH_PRICE_FEED)) /
            1e18;
    }

    function _getPrice(AggregatorV2V3Interface _priceFeed)
        private
        view
        returns (uint256)
    {
        (, int256 answer, uint256 startedAt, , ) = SEQUENCER_UPTIME_FEED
            .latestRoundData();

        // Answer == 0: Sequencer is up
        // Answer == 1: Sequencer is down
        bool isSequencerUp = answer == 0;
        if (!isSequencerUp) {
            revert SequencerDown();
        }

        // Make sure the grace period has passed after the sequencer is back up.
        uint256 timeSinceUp = block.timestamp - startedAt;
        if (timeSinceUp <= GRACE_PERIOD_TIME) {
            revert GracePeriodNotOver();
        }

        (, int256 price, , uint256 updatedAt, ) = _priceFeed.latestRoundData();

        if ((block.timestamp - updatedAt) > 86400) {
            revert HeartbeatNotFulfilled();
        }

        return uint256(price);
    }
}