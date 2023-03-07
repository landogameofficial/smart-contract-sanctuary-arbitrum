/**
 *Submitted for verification at Arbiscan on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library Babylonian {
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;

        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;

        uint256 r1 = x / r;

        return (r < r1 ? r : r1);
    }
}

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract PancakeZapV1 is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Interface for Wrapped BNB (WBNB)
    IWETH public WBNB;

    // PancakeRouter interface
    IPancakeRouter02 public pancakeRouter;

    // Maximum integer (used for managing allowance)
    uint256 public constant MAX_INT = 2**256 - 1;

    // Minimum amount for a swap (derived from PancakeSwap)
    uint256 public constant MINIMUM_AMOUNT = 1000;

    // Maximum reverse zap ratio (100 --> 1%, 1000 --> 0.1%)
    uint256 public maxZapReverseRatio;

    // Address PancakeRouter
    address private pancakeRouterAddress;

    // Address Wrapped BNB (WBNB)
    address private WBNBAddress;

    // Owner recovers token
    event AdminTokenRecovery(address indexed tokenAddress, uint256 amountTokens);

    // Owner changes the maxZapReverseRatio
    event NewMaxZapReverseRatio(uint256 maxZapReverseRatio);

    // tokenToZap = 0x00 address if BNB
    event ZapIn(
        address indexed tokenToZap,
        address indexed lpToken,
        uint256 tokenAmountIn,
        uint256 lpTokenAmountReceived,
        address indexed user
    );

    // token0ToZap = 0x00 address if BNB
    event ZapInRebalancing(
        address indexed token0ToZap,
        address indexed token1ToZap,
        address lpToken,
        uint256 token0AmountIn,
        uint256 token1AmountIn,
        uint256 lpTokenAmountReceived,
        address indexed user
    );

    // tokenToReceive = 0x00 address if BNB
    event ZapOut(
        address indexed lpToken,
        address indexed tokenToReceive,
        uint256 lpTokenAmount,
        uint256 tokenAmountReceived,
        address indexed user
    );

    /*
     * @notice Fallback for WBNB
     */
    receive() external payable {
        assert(msg.sender == WBNBAddress);
    }

    /*
     * @notice Constructor
     * @param _WBNBAddress: address of the WBNB contract
     * @param _pancakeRouter: address of the PancakeRouter
     * @param _maxZapReverseRatio: maximum zap ratio
     */
    constructor(
        address _WBNBAddress,
        address _pancakeRouter,
        uint256 _maxZapReverseRatio
    ) {
        WBNBAddress = _WBNBAddress;
        WBNB = IWETH(_WBNBAddress);
        pancakeRouterAddress = _pancakeRouter;
        pancakeRouter = IPancakeRouter02(_pancakeRouter);
        maxZapReverseRatio = _maxZapReverseRatio;
    }

    /*
     * @notice Zap BNB in a WBNB pool (e.g. WBNB/token)
     * @param _lpToken: LP token address (e.g. CAKE/BNB)
     * @param _tokenAmountOutMin: minimum token amount (e.g. CAKE) to receive in the intermediary swap (e.g. BNB --> CAKE)
     */
    function zapInBNB(address _lpToken, uint256 _tokenAmountOutMin) external payable nonReentrant {
        WBNB.deposit{value: msg.value}();

        // Call zap function
        uint256 lpTokenAmountTransferred = _zapIn(WBNBAddress, msg.value, _lpToken, _tokenAmountOutMin);

        // Emit event
        emit ZapIn(
            address(0x0000000000000000000000000000000000000000),
            _lpToken,
            msg.value,
            lpTokenAmountTransferred,
            msg.sender
        );
    }

    /*
     * @notice Zap a token in (e.g. token/other token)
     * @param _tokenToZap: token to zap
     * @param _tokenAmountIn: amount of token to swap
     * @param _lpToken: LP token address (e.g. CAKE/BUSD)
     * @param _tokenAmountOutMin: minimum token to receive (e.g. CAKE) in the intermediary swap (e.g. BUSD --> CAKE)
     */
    function zapInToken(
        address _tokenToZap,
        uint256 _tokenAmountIn,
        address _lpToken,
        uint256 _tokenAmountOutMin
    ) external nonReentrant {
        // Transfer tokens to this contract
        IERC20(_tokenToZap).safeTransferFrom(msg.sender, address(this), _tokenAmountIn);

        // Call zap function
        uint256 lpTokenAmountTransferred = _zapIn(_tokenToZap, _tokenAmountIn, _lpToken, _tokenAmountOutMin);

        // Emit event
        emit ZapIn(_tokenToZap, _lpToken, _tokenAmountIn, lpTokenAmountTransferred, msg.sender);
    }

    /*
     * @notice Zap two tokens in, rebalance them to 50-50, before adding them to LP
     * @param _token0ToZap: address of token0 to zap
     * @param _token1ToZap: address of token1 to zap
     * @param _token0AmountIn: amount of token0 to zap
     * @param _token1AmountIn: amount of token1 to zap
     * @param _lpToken: LP token address (token0/token1)
     * @param _tokenAmountInMax: maximum token amount to sell (in token to sell in the intermediary swap)
     * @param _tokenAmountOutMin: minimum token to receive in the intermediary swap
     * @param _isToken0Sold: whether token0 is expected to be sold (if false, sell token1)
     */
    function zapInTokenRebalancing(
        address _token0ToZap,
        address _token1ToZap,
        uint256 _token0AmountIn,
        uint256 _token1AmountIn,
        address _lpToken,
        uint256 _tokenAmountInMax,
        uint256 _tokenAmountOutMin,
        bool _isToken0Sold
    ) external nonReentrant {
        // Transfer tokens to this contract
        IERC20(_token0ToZap).safeTransferFrom(msg.sender, address(this), _token0AmountIn);
        IERC20(_token1ToZap).safeTransferFrom(msg.sender, address(this), _token1AmountIn);

        // Call zapIn function
        uint256 lpTokenAmountTransferred = _zapInRebalancing(
            _token0ToZap,
            _token1ToZap,
            _token0AmountIn,
            _token1AmountIn,
            _lpToken,
            _tokenAmountInMax,
            _tokenAmountOutMin,
            _isToken0Sold
        );

        // Emit event
        emit ZapInRebalancing(
            _token0ToZap,
            _token1ToZap,
            _lpToken,
            _token0AmountIn,
            _token1AmountIn,
            lpTokenAmountTransferred,
            msg.sender
        );
    }

    /*
     * @notice Zap 1 token and BNB, rebalance them to 50-50, before adding them to LP
     * @param _token1ToZap: address of token1 to zap
     * @param _token1AmountIn: amount of token1 to zap
     * @param _lpToken: LP token address
     * @param _tokenAmountInMax: maximum token amount to sell (in token to sell in the intermediary swap)
     * @param _tokenAmountOutMin: minimum token to receive in the intermediary swap
     * @param _isToken0Sold: whether token0 is expected to be sold (if false, sell token1)
     */
    function zapInBNBRebalancing(
        address _token1ToZap,
        uint256 _token1AmountIn,
        address _lpToken,
        uint256 _tokenAmountInMax,
        uint256 _tokenAmountOutMin,
        bool _isToken0Sold
    ) external payable nonReentrant {
        WBNB.deposit{value: msg.value}();

        IERC20(_token1ToZap).safeTransferFrom(msg.sender, address(this), _token1AmountIn);

        // Call zapIn function
        uint256 lpTokenAmountTransferred = _zapInRebalancing(
            WBNBAddress,
            _token1ToZap,
            msg.value,
            _token1AmountIn,
            _lpToken,
            _tokenAmountInMax,
            _tokenAmountOutMin,
            _isToken0Sold
        );

        // Emit event
        emit ZapInRebalancing(
            address(0x0000000000000000000000000000000000000000),
            _token1ToZap,
            _lpToken,
            msg.value,
            _token1AmountIn,
            lpTokenAmountTransferred,
            msg.sender
        );
    }

    /*
     * @notice Zap a LP token out to receive BNB
     * @param _lpToken: LP token address (e.g. CAKE/WBNB)
     * @param _lpTokenAmount: amount of LP tokens to zap out
     * @param _tokenAmountOutMin: minimum amount to receive (in BNB/WBNB) in the intermediary swap (e.g. CAKE --> BNB)
     */
    function zapOutBNB(
        address _lpToken,
        uint256 _lpTokenAmount,
        uint256 _tokenAmountOutMin,
        uint256 _totalTokenAmountOutMin
    ) external nonReentrant {
        // Transfer LP token to this address
        IERC20(_lpToken).safeTransferFrom(msg.sender, address(_lpToken), _lpTokenAmount);

        // Call zapOut
        uint256 tokenAmountToTransfer = _zapOut(_lpToken, WBNBAddress, _tokenAmountOutMin, _totalTokenAmountOutMin);

        // Unwrap BNB
        WBNB.withdraw(tokenAmountToTransfer);

        // Transfer BNB to the msg.sender
        (bool success, ) = msg.sender.call{value: tokenAmountToTransfer}(new bytes(0));
        require(success, "BNB: transfer fail");

        // Emit event
        emit ZapOut(
            _lpToken,
            address(0x0000000000000000000000000000000000000000),
            _lpTokenAmount,
            tokenAmountToTransfer,
            msg.sender
        );
    }

    /*
     * @notice Zap a LP token out (to receive a token)
     * @param _lpToken: LP token address (e.g. CAKE/BUSD)
     * @param _tokenToReceive: one of the 2 tokens from the LP (e.g. CAKE or BUSD)
     * @param _lpTokenAmount: amount of LP tokens to zap out
     * @param _tokenAmountOutMin: minimum token to receive (e.g. CAKE) in the intermediary swap (e.g. BUSD --> CAKE)
     */
    function zapOutToken(
        address _lpToken,
        address _tokenToReceive,
        uint256 _lpTokenAmount,
        uint256 _tokenAmountOutMin,
        uint256 _totalTokenAmountOutMin
    ) external nonReentrant {
        // Transfer LP token to this address
        IERC20(_lpToken).safeTransferFrom(msg.sender, address(_lpToken), _lpTokenAmount);

        uint256 tokenAmountToTransfer = _zapOut(_lpToken, _tokenToReceive, _tokenAmountOutMin, _totalTokenAmountOutMin);

        IERC20(_tokenToReceive).safeTransfer(msg.sender, tokenAmountToTransfer);

        emit ZapOut(_lpToken, _tokenToReceive, _lpTokenAmount, tokenAmountToTransfer, msg.sender);
    }

    /**
     * @notice It allows the owner to change the risk parameter for quantities
     * @param _maxZapInverseRatio: new inverse ratio
     * @dev This function is only callable by owner.
     */
    function updateMaxZapInverseRatio(uint256 _maxZapInverseRatio) external onlyOwner {
        maxZapReverseRatio = _maxZapInverseRatio;
        emit NewMaxZapReverseRatio(_maxZapInverseRatio);
    }

    /**
     * @notice It allows the owner to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw (18 decimals)
     * @param _tokenAmount: the number of token amount to withdraw
     * @dev This function is only callable by owner.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        IERC20(_tokenAddress).safeTransfer(msg.sender, _tokenAmount);
        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /*
     * @notice View the details for single zap
     * @dev Use WBNB for _tokenToZap (if BNB is the input)
     * @param _tokenToZap: address of the token to zap
     * @param _tokenAmountIn: amount of token to zap inputed
     * @param _lpToken: address of the LP token
     * @return swapAmountIn: amount that is expected to get swapped in intermediary swap
     * @return swapAmountOut: amount that is expected to get received in intermediary swap
     * @return swapTokenOut: token address of the token that is used in the intermediary swap
     */
    function estimateZapInSwap(
        address _tokenToZap,
        uint256 _tokenAmountIn,
        address _lpToken
    )
        external
        view
        returns (
            uint256 swapAmountIn,
            uint256 swapAmountOut,
            address swapTokenOut
        )
    {
        address token0 = IPancakePair(_lpToken).token0();
        address token1 = IPancakePair(_lpToken).token1();

        require(_tokenToZap == token0 || _tokenToZap == token1, "Zap: Wrong tokens");

        // Convert to uint256 (from uint112)
        (uint256 reserveA, uint256 reserveB, ) = IPancakePair(_lpToken).getReserves();

        if (token0 == _tokenToZap) {
            swapTokenOut = token1;
            swapAmountIn = _calculateAmountToSwap(_tokenAmountIn, reserveA, reserveB);
            swapAmountOut = pancakeRouter.getAmountOut(swapAmountIn, reserveA, reserveB);
        } else {
            swapTokenOut = token0;
            swapAmountIn = _calculateAmountToSwap(_tokenAmountIn, reserveB, reserveA);
            swapAmountOut = pancakeRouter.getAmountOut(swapAmountIn, reserveB, reserveA);
        }

        return (swapAmountIn, swapAmountOut, swapTokenOut);
    }

    /*
     * @notice View the details for a rebalancing zap
     * @dev Use WBNB for _token0ToZap (if BNB is the input)
     * @param _token0ToZap: address of the token0 to zap
     * @param _token1ToZap: address of the token0 to zap
     * @param _token0AmountIn: amount for token0 to zap
     * @param _token1AmountIn: amount for token1 to zap
     * @param _lpToken: address of the LP token
     * @return swapAmountIn: amount that is expected to get swapped in intermediary swap
     * @return swapAmountOut: amount that is expected to get received in intermediary swap
     * @return isToken0Sold: whether the token0 is sold (false --> token1 is sold in the intermediary swap)
     */
    function estimateZapInRebalancingSwap(
        address _token0ToZap,
        address _token1ToZap,
        uint256 _token0AmountIn,
        uint256 _token1AmountIn,
        address _lpToken
    )
        external
        view
        returns (
            uint256 swapAmountIn,
            uint256 swapAmountOut,
            bool sellToken0
        )
    {
        require(
            _token0ToZap == IPancakePair(_lpToken).token0() || _token0ToZap == IPancakePair(_lpToken).token1(),
            "Zap: Wrong token0"
        );
        require(
            _token1ToZap == IPancakePair(_lpToken).token0() || _token1ToZap == IPancakePair(_lpToken).token1(),
            "Zap: Wrong token1"
        );

        require(_token0ToZap != _token1ToZap, "Zap: Same tokens");

        // Convert to uint256 (from uint112)
        (uint256 reserveA, uint256 reserveB, ) = IPancakePair(_lpToken).getReserves();

        if (_token0ToZap == IPancakePair(_lpToken).token0()) {
            sellToken0 = (_token0AmountIn * reserveB > _token1AmountIn * reserveA) ? true : false;

            // Calculate the amount that is expected to be swapped
            swapAmountIn = _calculateAmountToSwapForRebalancing(
                _token0AmountIn,
                _token1AmountIn,
                reserveA,
                reserveB,
                sellToken0
            );

            // Calculate the amount expected to be received in the intermediary swap
            if (sellToken0) {
                swapAmountOut = pancakeRouter.getAmountOut(swapAmountIn, reserveA, reserveB);
            } else {
                swapAmountOut = pancakeRouter.getAmountOut(swapAmountIn, reserveB, reserveA);
            }
        } else {
            sellToken0 = (_token0AmountIn * reserveA > _token1AmountIn * reserveB) ? true : false;
            // Calculate the amount that is expected to be swapped
            swapAmountIn = _calculateAmountToSwapForRebalancing(
                _token0AmountIn,
                _token1AmountIn,
                reserveB,
                reserveA,
                sellToken0
            );

            // Calculate the amount expected to be received in the intermediary swap
            if (sellToken0) {
                swapAmountOut = pancakeRouter.getAmountOut(swapAmountIn, reserveB, reserveA);
            } else {
                swapAmountOut = pancakeRouter.getAmountOut(swapAmountIn, reserveA, reserveB);
            }
        }

        return (swapAmountIn, swapAmountOut, sellToken0);
    }

    /*
     * @notice View the details for single zap
     * @dev Use WBNB for _tokenToReceive (if BNB is the asset to be received)
     * @param _lpToken: address of the LP token to zap out
     * @param _lpTokenAmount: amount of LP token to zap out
     * @param _tokenToReceive: token address to receive
     * @return swapAmountIn: amount that is expected to get swapped for intermediary swap
     * @return swapAmountOut: amount that is expected to get received for intermediary swap
     * @return swapTokenOut: address of the token that is sold in the intermediary swap
     */
    function estimateZapOutSwap(
        address _lpToken,
        uint256 _lpTokenAmount,
        address _tokenToReceive
    )
        external
        view
        returns (
            uint256 swapAmountIn,
            uint256 swapAmountOut,
            address swapTokenOut
        )
    {
        address token0 = IPancakePair(_lpToken).token0();
        address token1 = IPancakePair(_lpToken).token1();

        require(_tokenToReceive == token0 || _tokenToReceive == token1, "Zap: Token not in LP");

        // Convert to uint256 (from uint112)
        (uint256 reserveA, uint256 reserveB, ) = IPancakePair(_lpToken).getReserves();

        if (token1 == _tokenToReceive) {
            // sell token0
            uint256 tokenAmountIn = (_lpTokenAmount * reserveA) / IPancakePair(_lpToken).totalSupply();

            swapAmountIn = tokenAmountIn;
            swapAmountOut = pancakeRouter.getAmountOut(swapAmountIn, reserveA, reserveB);

            swapTokenOut = token0;
        } else {
            // sell token1
            uint256 tokenAmountIn = (_lpTokenAmount * reserveB) / IPancakePair(_lpToken).totalSupply();

            swapAmountIn = tokenAmountIn;
            swapAmountOut = pancakeRouter.getAmountOut(swapAmountIn, reserveB, reserveA);

            swapTokenOut = token1;
        }

        return (swapAmountIn, swapAmountOut, swapTokenOut);
    }

    /*
     * @notice Zap a token in (e.g. token/other token)
     * @param _tokenToZap: token to zap
     * @param _tokenAmountIn: amount of token to swap
     * @param _lpToken: LP token address
     * @param _tokenAmountOutMin: minimum token to receive in the intermediary swap
     */
    function _zapIn(
        address _tokenToZap,
        uint256 _tokenAmountIn,
        address _lpToken,
        uint256 _tokenAmountOutMin
    ) internal returns (uint256 lpTokenReceived) {
        require(_tokenAmountIn >= MINIMUM_AMOUNT, "Zap: Amount too low");

        address token0 = IPancakePair(_lpToken).token0();
        address token1 = IPancakePair(_lpToken).token1();

        require(_tokenToZap == token0 || _tokenToZap == token1, "Zap: Wrong tokens");

        // Retrieve the path
        address[] memory path = new address[](2);
        path[0] = _tokenToZap;

        // Initiates an estimation to swap
        uint256 swapAmountIn;

        {
            // Convert to uint256 (from uint112)
            (uint256 reserveA, uint256 reserveB, ) = IPancakePair(_lpToken).getReserves();

            require((reserveA >= MINIMUM_AMOUNT) && (reserveB >= MINIMUM_AMOUNT), "Zap: Reserves too low");

            if (token0 == _tokenToZap) {
                swapAmountIn = _calculateAmountToSwap(_tokenAmountIn, reserveA, reserveB);
                path[1] = token1;
                require(reserveA / swapAmountIn >= maxZapReverseRatio, "Zap: Quantity higher than limit");
            } else {
                swapAmountIn = _calculateAmountToSwap(_tokenAmountIn, reserveB, reserveA);
                path[1] = token0;
                require(reserveB / swapAmountIn >= maxZapReverseRatio, "Zap: Quantity higher than limit");
            }
        }

        // Approve token to zap if necessary
        _approveTokenIfNeeded(_tokenToZap, swapAmountIn);

        uint256[] memory swapedAmounts = pancakeRouter.swapExactTokensForTokens(
            swapAmountIn,
            _tokenAmountOutMin,
            path,
            address(this),
            block.timestamp
        );

        // Approve other token if necessary
        if (token0 == _tokenToZap) {
            _approveTokenIfNeeded(token1, swapAmountIn);
        } else {
            _approveTokenIfNeeded(token0, swapAmountIn);
        }

        // Add liquidity and retrieve the amount of LP received by the sender
        (, , lpTokenReceived) = pancakeRouter.addLiquidity(
            path[0],
            path[1],
            _tokenAmountIn - swapedAmounts[0],
            swapedAmounts[1],
            1,
            1,
            msg.sender,
            block.timestamp
        );

        return lpTokenReceived;
    }

    /*
     * @notice Zap two tokens in, rebalance them to 50-50, before adding them to LP
     * @param _token0ToZap: address of token0 to zap
     * @param _token1ToZap: address of token1 to zap
     * @param _token0AmountIn: amount of token0 to zap
     * @param _token1AmountIn: amount of token1 to zap
     * @param _lpToken: LP token address
     * @param _tokenAmountInMax: maximum token amount to sell (in token to sell in the intermediary swap)
     * @param _tokenAmountOutMin: minimum token to receive in the intermediary swap
     * @param _isToken0Sold: whether token0 is expected to be sold (if false, sell token1)
     */
    function _zapInRebalancing(
        address _token0ToZap,
        address _token1ToZap,
        uint256 _token0AmountIn,
        uint256 _token1AmountIn,
        address _lpToken,
        uint256 _tokenAmountInMax,
        uint256 _tokenAmountOutMin,
        bool _isToken0Sold
    ) internal returns (uint256 lpTokenReceived) {
        require(
            _token0ToZap == IPancakePair(_lpToken).token0() || _token0ToZap == IPancakePair(_lpToken).token1(),
            "Zap: Wrong token0"
        );
        require(
            _token1ToZap == IPancakePair(_lpToken).token0() || _token1ToZap == IPancakePair(_lpToken).token1(),
            "Zap: Wrong token1"
        );

        require(_token0ToZap != _token1ToZap, "Zap: Same tokens");

        // Initiates an estimation to swap
        uint256 swapAmountIn;

        {
            // Convert to uint256 (from uint112)
            (uint256 reserveA, uint256 reserveB, ) = IPancakePair(_lpToken).getReserves();

            require((reserveA >= MINIMUM_AMOUNT) && (reserveB >= MINIMUM_AMOUNT), "Zap: Reserves too low");

            if (_token0ToZap == IPancakePair(_lpToken).token0()) {
                swapAmountIn = _calculateAmountToSwapForRebalancing(
                    _token0AmountIn,
                    _token1AmountIn,
                    reserveA,
                    reserveB,
                    _isToken0Sold
                );
                require(reserveA / swapAmountIn >= maxZapReverseRatio, "Zap: Quantity higher than limit");
            } else {
                swapAmountIn = _calculateAmountToSwapForRebalancing(
                    _token0AmountIn,
                    _token1AmountIn,
                    reserveB,
                    reserveA,
                    _isToken0Sold
                );

                require(reserveB / swapAmountIn >= maxZapReverseRatio, "Zap: Quantity higher than limit");
            }
        }

        require(swapAmountIn <= _tokenAmountInMax, "Zap: Amount to swap too high");

        address[] memory path = new address[](2);

        // Define path for swapping and check whether to approve token to sell in intermediary swap
        if (_isToken0Sold) {
            path[0] = _token0ToZap;
            path[1] = _token1ToZap;
            _approveTokenIfNeeded(_token0ToZap, swapAmountIn);
        } else {
            path[0] = _token1ToZap;
            path[1] = _token0ToZap;
            _approveTokenIfNeeded(_token1ToZap, swapAmountIn);
        }

        // Execute the swap and retrieve quantity received
        uint256[] memory swapedAmounts = pancakeRouter.swapExactTokensForTokens(
            swapAmountIn,
            _tokenAmountOutMin,
            path,
            address(this),
            block.timestamp
        );

        // Check whether to approve other token and add liquidity to LP
        if (_isToken0Sold) {
            _approveTokenIfNeeded(_token1ToZap, swapAmountIn);

            (, , lpTokenReceived) = pancakeRouter.addLiquidity(
                path[0],
                path[1],
                (_token0AmountIn - swapedAmounts[0]),
                (_token1AmountIn + swapedAmounts[1]),
                1,
                1,
                msg.sender,
                block.timestamp
            );
        } else {
            _approveTokenIfNeeded(_token0ToZap, swapAmountIn);
            (, , lpTokenReceived) = pancakeRouter.addLiquidity(
                path[0],
                path[1],
                (_token1AmountIn - swapedAmounts[0]),
                (_token0AmountIn + swapedAmounts[1]),
                1,
                1,
                msg.sender,
                block.timestamp
            );
        }

        return lpTokenReceived;
    }

    /*
     * @notice Zap a LP token out to a token (e.g. token/other token)
     * @param _lpToken: LP token address
     * @param _tokenToReceive: token address
     * @param _tokenAmountOutMin: minimum token to receive in the intermediary swap
     */
    function _zapOut(
        address _lpToken,
        address _tokenToReceive,
        uint256 _tokenAmountOutMin,
        uint256 _totalTokenAmountOutMin
    ) internal returns (uint256) {
        address token0 = IPancakePair(_lpToken).token0();
        address token1 = IPancakePair(_lpToken).token1();

        require(_tokenToReceive == token0 || _tokenToReceive == token1, "Zap: Token not in LP");

        // Burn all LP tokens to receive the two tokens to this address
        (uint256 amount0, uint256 amount1) = IPancakePair(_lpToken).burn(address(this));

        require(amount0 >= MINIMUM_AMOUNT, "PancakeRouter: INSUFFICIENT_A_AMOUNT");
        require(amount1 >= MINIMUM_AMOUNT, "PancakeRouter: INSUFFICIENT_B_AMOUNT");

        address[] memory path = new address[](2);
        path[1] = _tokenToReceive;

        uint256 swapAmountIn;

        if (token0 == _tokenToReceive) {
            path[0] = token1;
            swapAmountIn = IERC20(token1).balanceOf(address(this));

            // Approve token to sell if necessary
            _approveTokenIfNeeded(token1, swapAmountIn);
        } else {
            path[0] = token0;
            swapAmountIn = IERC20(token0).balanceOf(address(this));

            // Approve token to sell if necessary
            _approveTokenIfNeeded(token0, swapAmountIn);
        }

        // Swap tokens
        pancakeRouter.swapExactTokensForTokens(swapAmountIn, _tokenAmountOutMin, path, address(this), block.timestamp);

        // Return full balance for the token to receive by the sender
        require(_totalTokenAmountOutMin < IERC20(_tokenToReceive).balanceOf(address(this)), "amount is not enough");
        return IERC20(_tokenToReceive).balanceOf(address(this));
    }

    /*
     * @notice Allows to zap a token in (e.g. token/other token)
     * @param _token: token address
     */
    function _approveTokenIfNeeded(address _token, uint256 _swapAmountIn) private {
        if (IERC20(_token).allowance(address(this), pancakeRouterAddress) < _swapAmountIn) {
            // Reset to 0
            IERC20(_token).safeApprove(pancakeRouterAddress, 0);
            // Re-approve
            IERC20(_token).safeApprove(pancakeRouterAddress, MAX_INT);
        }
    }

    /*
     * @notice Calculate the swap amount to get the price at 50/50 split
     * @param _token0AmountIn: amount of token 0
     * @param _reserve0: amount in reserve for token0
     * @param _reserve1: amount in reserve for token1
     * @return amountToSwap: swapped amount (in token0)
     */
    function _calculateAmountToSwap(
        uint256 _token0AmountIn,
        uint256 _reserve0,
        uint256 _reserve1
    ) private view returns (uint256 amountToSwap) {
        uint256 halfToken0Amount = _token0AmountIn / 2;
        uint256 nominator = pancakeRouter.getAmountOut(halfToken0Amount, _reserve0, _reserve1);
        uint256 denominator = pancakeRouter.quote(
            halfToken0Amount,
            _reserve0 + halfToken0Amount,
            _reserve1 - nominator
        );

        // Adjustment for price impact
        amountToSwap =
            _token0AmountIn -
            Babylonian.sqrt((halfToken0Amount * halfToken0Amount * nominator) / denominator);

        return amountToSwap;
    }

    /*
     * @notice Calculate the amount to swap to get the tokens at a 50/50 split
     * @param _token0AmountIn: amount of token 0
     * @param _token1AmountIn: amount of token 1
     * @param _reserve0: amount in reserve for token0
     * @param _reserve1: amount in reserve for token1
     * @param _isToken0Sold: whether token0 is expected to be sold (if false, sell token1)
     * @return amountToSwap: swapped amount in token0 (if _isToken0Sold is true) or token1 (if _isToken0Sold is false)
     */
    function _calculateAmountToSwapForRebalancing(
        uint256 _token0AmountIn,
        uint256 _token1AmountIn,
        uint256 _reserve0,
        uint256 _reserve1,
        bool _isToken0Sold
    ) private view returns (uint256 amountToSwap) {
        bool sellToken0 = (_token0AmountIn * _reserve1 > _token1AmountIn * _reserve0) ? true : false;

        require(sellToken0 == _isToken0Sold, "Zap: Wrong trade direction");

        if (sellToken0) {
            uint256 token0AmountToSell = (_token0AmountIn - (_token1AmountIn * _reserve0) / _reserve1) / 2;
            uint256 nominator = pancakeRouter.getAmountOut(token0AmountToSell, _reserve0, _reserve1);
            uint256 denominator = pancakeRouter.quote(
                token0AmountToSell,
                _reserve0 + token0AmountToSell,
                _reserve1 - nominator
            );

            // Calculate the amount to sell (in token0)
            token0AmountToSell =
                (_token0AmountIn - (_token1AmountIn * (_reserve0 + token0AmountToSell)) / (_reserve1 - nominator)) /
                2;

            // Adjustment for price impact
            amountToSwap =
                2 *
                token0AmountToSell -
                Babylonian.sqrt((token0AmountToSell * token0AmountToSell * nominator) / denominator);
        } else {
            uint256 token1AmountToSell = (_token1AmountIn - (_token0AmountIn * _reserve1) / _reserve0) / 2;
            uint256 nominator = pancakeRouter.getAmountOut(token1AmountToSell, _reserve1, _reserve0);

            uint256 denominator = pancakeRouter.quote(
                token1AmountToSell,
                _reserve1 + token1AmountToSell,
                _reserve0 - nominator
            );

            // Calculate the amount to sell (in token1)
            token1AmountToSell =
                (_token1AmountIn - ((_token0AmountIn * (_reserve1 + token1AmountToSell)) / (_reserve0 - nominator))) /
                2;

            // Adjustment for price impact
            amountToSwap =
                2 *
                token1AmountToSell -
                Babylonian.sqrt((token1AmountToSell * token1AmountToSell * nominator) / denominator);
        }

        return amountToSwap;
    }
}