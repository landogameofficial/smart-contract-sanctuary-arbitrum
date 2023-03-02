//SPDX-License-Identifier: Unlicense

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

abstract contract IERC20Extented is IERC20 {
    function decimals() public view virtual returns (uint8);
}

contract GenIDO is Initializable {
    event allocationBought(address indexed _user, uint256 _amount, bool _nft);
    event claimed(address indexed _user, uint256 indexed _amount);
    event saleStartTimeUpdated(uint256 _timestamp);
    event idoSaleStausFlipped(bool _active);

    IERC20Extented private underlyingToken;
    IERC20Extented private usdt;

    uint256[] private trancheLength;
    uint256[] private trancheWeightage;
    uint256[] private maxTokenAllocPerUserPerTier;

    address public issuer;
    bool public active = false;

    mapping(address => bool) public blacklist;

    uint256 private totalTokenAllocation;
    uint256 private minTokenAllocationPermitted;
    uint256 private maxTokenAllocationPermitted;
    uint256 private tokensPurchased;
    uint256 private tokenPerUsd;
    uint256 private guranteedSaleDuration;
    uint256 private usdDec;

    uint256 private tokensDepositedByAdmin;
    uint256 private tokensWithdrawnByAdmin;

    uint256 public startTime;
    uint256 public TGE;

    struct Purchases {
        uint112 tokenAllocationBought; //tokens respective to payment
        uint112 position;
    }

    mapping(address => Purchases) public purchases;
    mapping(address => mapping(uint256 => uint256)) public tokensBought;

    modifier onlyIssuer() {
        require(msg.sender == issuer, "GenIDO: Only issuer can update");
        _;
    }

    // /// @custom:oz-upgrades-unsafe-allow constructor
    // constructor() {
    //     _disableInitializers();
    // } // Keep it or remove it??

    // make sure this cannot be re-initialized from implementation contract
    function initialize1(
        address _underlyingToken,
        uint256 _totalTokenAllocation, //enter details as per decimals of _underlyingToken
        uint256[] memory _maxTokenAllocPerUserPerTier, //enter details as per decimals of _underlyingToken
        uint256 _maxTokenAllocationPermitted,
        uint256 _tokenPerUsd,
        address _usdt,
        uint256[] memory _trancheWeightage, //in wei
        uint256[] memory _trancheLength, //in seconds
        uint256 _guranteedSaleDuration
    ) external initializer {
        underlyingToken = IERC20Extented(_underlyingToken);
        totalTokenAllocation = _totalTokenAllocation;
        usdt = IERC20Extented(_usdt);
        maxTokenAllocPerUserPerTier = _maxTokenAllocPerUserPerTier;
        trancheWeightage = _trancheWeightage;
        trancheLength = _trancheLength;
        guranteedSaleDuration = _guranteedSaleDuration;
        issuer = tx.origin;
        usdDec = usdt.decimals();
        tokenPerUsd = _tokenPerUsd;
        minTokenAllocationPermitted =
            _maxTokenAllocPerUserPerTier[
                _maxTokenAllocPerUserPerTier.length - 1
            ] /
            2;
        maxTokenAllocationPermitted = _maxTokenAllocationPermitted;
        TGE = type(uint256).max;
        startTime = type(uint256).max;
    }

    function updateTGE(uint256 timestamp) external onlyIssuer {
        require(getBlockTimestamp() < TGE, "GenIDO: TGE occurred");
        require(
            getBlockTimestamp() < timestamp,
            "GenIDO: New TGE must be in the future"
        );

        TGE = timestamp;
    }

    // This methods allows issuer to deposit tokens anytime - even after TGE until deposited amount equals totalTokenAllocation
    function submitTokens(uint256 _amount) external onlyIssuer {
        uint256 _tokensDepositedByAdmin = tokensDepositedByAdmin;
        require(
            (_tokensDepositedByAdmin + _amount) <= totalTokenAllocation,
            "GenIDO: Amount exceeds limit"
        );
        require(
            IERC20(underlyingToken).transferFrom(
                msg.sender,
                address(this),
                _amount
            )
        );
        _tokensDepositedByAdmin += _amount;
        tokensDepositedByAdmin = _tokensDepositedByAdmin;
        if (!active) active = true;
    }

    function updateStartTime(uint256 timestamp) external onlyIssuer {
        require(getBlockTimestamp() < startTime, "GenIDO: Start time occurred");
        require(
            getBlockTimestamp() < timestamp,
            "GenIDO: New start time must be in the future"
        );

        startTime = timestamp;
        emit saleStartTimeUpdated(timestamp);
    }

    // to end the sale and claim proceeds
    function flipIDOStatus() external onlyIssuer {
        if (active) {
            require(
                IERC20(usdt).transfer(msg.sender, usdt.balanceOf(address(this)))
            ); //18
        }
        active = !active;
        emit idoSaleStausFlipped(active);
    }

    // Buying from contract directly might lead to the loss of busd submitted
    function buyAnAllocation(uint256 _pay, uint256 _staked) external {
        require(_pay > 0, "GenIDO: Payment cannot be zero");
        require(active, "GenIDO: Market is not active");
        require(
            getBlockTimestamp() >= startTime,
            "GenIDO: Start time must pass"
        );
        uint256 pur = (_pay * tokenPerUsd) / 10 ** usdDec;
        require(
            tokensPurchased + pur <= totalTokenAllocation,
            "GenIDO: Sold Out"
        );

        uint256 id;
        Purchases memory selectedPurchase = purchases[msg.sender];

        if (_staked >= 30000 * 10 ** 18) {
            id = 0;
        } else if (_staked >= 15000 * 10 ** 18 && _staked < 30000 * 10 ** 18) {
            id = 1;
        } else if (_staked >= 7500 * 10 ** 18 && _staked < 15000 * 10 ** 18) {
            id = 2;
        } else if (_staked >= 2000 * 10 ** 18 && _staked < 7500 * 10 ** 18) {
            id = 3;
        } else {
            revert("GenIDO: Invalid User");
        }

        // Not keeping this check for both guranteed and fcfs sale
        // require(
        //     selectedPurchase.tokenAllocationBought + pur >=
        //         minTokenAllocationPermitted,
        //     "GenIDO: User min purchase violation"
        // );

        //following block only executes for for guranteed sale
        if (getBlockTimestamp() < startTime + guranteedSaleDuration) {
            require(
                selectedPurchase.tokenAllocationBought + pur >=
                    minTokenAllocationPermitted,
                "GenIDO: User min purchase violation"
            );
            require(
                selectedPurchase.tokenAllocationBought + pur <=
                    maxTokenAllocPerUserPerTier[id],
                "GenIDO: User max purchase violation"
            ); //6
            tokensBought[msg.sender][1] += pur;
        } else {
            require(
                selectedPurchase.tokenAllocationBought + pur <=
                    maxTokenAllocationPermitted,
                "GenIDO: Max Purchase Limit Reached"
            );
            tokensBought[msg.sender][2] += pur;
        }
        purchases[msg.sender].tokenAllocationBought += uint112(pur);
        tokensPurchased += pur;

        // payment made by User
        require(usdt.transferFrom(msg.sender, address(this), _pay));

        if (selectedPurchase.tokenAllocationBought == 0)
            emit allocationBought(msg.sender, pur, true);
        else emit allocationBought(msg.sender, pur, false);
    }

    //issuer's responsibility to decide on claim amount - in case of blacklisted user or any emergency case
    function withdrawTokens(uint256 _amount) external onlyIssuer {
        require(
            _amount <= underlyingToken.balanceOf(address(this)),
            "GenIDO: Invalid amount to withdraw"
        );
        require(underlyingToken.transfer(issuer, _amount));
        uint256 _tokensWithdrawnByAdmin = tokensWithdrawnByAdmin;
        _tokensWithdrawnByAdmin -= _amount;
        tokensWithdrawnByAdmin = _tokensWithdrawnByAdmin;
    }

    //for users who bought from contract rather than web app
    function setBlackList(
        address[] calldata addresses,
        bool blackListOn
    ) external onlyIssuer {
        require(
            addresses.length < 200,
            "GenIDO: Blacklist less than 200 at a time"
        );

        for (uint256 i = 0; i < addresses.length; ) {
            blacklist[addresses[i]] = blackListOn;
            unchecked {
                i++;
            }
        }
    }

    function redeem() public {
        require(!blacklist[msg.sender], "GenIDO: User in blacklist");
        require(getBlockTimestamp() > TGE, "GenIDO: Project TGE not occured");

        uint256 redeemablePercentage;
        Purchases memory selectedPurchase = purchases[msg.sender];
        uint256[] memory selectedTranchDurations = trancheLength;
        uint256 selectedTGE = TGE;
        require(
            selectedPurchase.position < selectedTranchDurations.length,
            "GenIDO: All tranches fully claimed"
        );

        for (
            uint256 i = selectedPurchase.position;
            i < selectedTranchDurations.length;

        ) {
            // remove equal

            if (
                selectedTGE + selectedTranchDurations[i] <= getBlockTimestamp()
            ) {
                redeemablePercentage += trancheWeightage[i];
                if (i == selectedTranchDurations.length - 1) {
                    purchases[msg.sender].position = uint112(
                        selectedTranchDurations.length
                    );
                    break;
                }
            } else {
                purchases[msg.sender].position = uint112(i);
                break;
            }
            unchecked {
                i++;
            }
        }
        redeemablePercentage = redeemablePercentage;
        require(
            redeemablePercentage > 0,
            "GenIDO: zero amount cannot be claimed"
        );
        uint256 tokens = (selectedPurchase.tokenAllocationBought *
            redeemablePercentage) / (10 ** 20);
        require(IERC20(underlyingToken).transfer(msg.sender, tokens));

        emit claimed(msg.sender, tokens);
    }

    function getTokensInfo()
        external
        view
        returns (
            uint256 _tokensSold,
            uint256 _tokensDepositedByAdmin,
            uint256 _tokensWithdrawnByAdmin
        )
    {
        return (
            tokensPurchased,
            tokensDepositedByAdmin,
            tokensWithdrawnByAdmin
        );
    }

    function getAmountRaised() external view returns (uint256 amountRaised) {
        amountRaised = (tokensPurchased * (10 ** usdDec)) / tokenPerUsd;
    }

    function getProjectInfo()
        external
        view
        returns (
            IERC20Extented _underlyingToken,
            IERC20Extented _usdt,
            uint256 _totalTokensAllocated,
            uint256 _tokenRate,
            uint256 _guranteedSaleDuration,
            uint256 _minTokenAllocationPermitted,
            uint256 _maxTokenAllocationPermitted,
            uint256[] memory _maxTokenAllocPerUserPerTier,
            uint256[] memory _trancheLength,
            uint256[] memory _trancheWeightage
        )
    {
        return (
            underlyingToken,
            usdt,
            totalTokenAllocation,
            tokenPerUsd,
            guranteedSaleDuration,
            minTokenAllocationPermitted,
            maxTokenAllocationPermitted,
            maxTokenAllocPerUserPerTier,
            trancheLength,
            trancheWeightage
        );
    }

    function getBlockTimestamp() internal view returns (uint256) {
        // solium-disable-next-line security/no-block-members
        return block.timestamp;
    }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}