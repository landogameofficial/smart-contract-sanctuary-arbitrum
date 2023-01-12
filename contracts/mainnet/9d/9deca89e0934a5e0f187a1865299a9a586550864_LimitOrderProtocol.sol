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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1271.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * _Available since v4.1._
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.1) (utils/cryptography/SignatureChecker.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";
import "../Address.sol";
import "../../interfaces/IERC1271.sol";

/**
 * @dev Signature verification helper that can be used instead of `ECDSA.recover` to seamlessly support both ECDSA
 * signatures from externally owned accounts (EOAs) as well as ERC1271 signatures from smart contract wallets like
 * Argent and Gnosis Safe.
 *
 * _Available since v4.1._
 */
library SignatureChecker {
    /**
     * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
     * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECDSA.recover`.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);
        if (error == ECDSA.RecoverError.NoError && recovered == signer) {
            return true;
        }

        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(IERC1271.isValidSignature.selector, hash, signature)
        );
        return (success &&
            result.length == 32 &&
            abi.decode(result, (bytes32)) == bytes32(IERC1271.isValidSignature.selector));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248) {
        require(value >= type(int248).min && value <= type(int248).max, "SafeCast: value doesn't fit in 248 bits");
        return int248(value);
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240) {
        require(value >= type(int240).min && value <= type(int240).max, "SafeCast: value doesn't fit in 240 bits");
        return int240(value);
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232) {
        require(value >= type(int232).min && value <= type(int232).max, "SafeCast: value doesn't fit in 232 bits");
        return int232(value);
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224) {
        require(value >= type(int224).min && value <= type(int224).max, "SafeCast: value doesn't fit in 224 bits");
        return int224(value);
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216) {
        require(value >= type(int216).min && value <= type(int216).max, "SafeCast: value doesn't fit in 216 bits");
        return int216(value);
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208) {
        require(value >= type(int208).min && value <= type(int208).max, "SafeCast: value doesn't fit in 208 bits");
        return int208(value);
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200) {
        require(value >= type(int200).min && value <= type(int200).max, "SafeCast: value doesn't fit in 200 bits");
        return int200(value);
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192) {
        require(value >= type(int192).min && value <= type(int192).max, "SafeCast: value doesn't fit in 192 bits");
        return int192(value);
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184) {
        require(value >= type(int184).min && value <= type(int184).max, "SafeCast: value doesn't fit in 184 bits");
        return int184(value);
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176) {
        require(value >= type(int176).min && value <= type(int176).max, "SafeCast: value doesn't fit in 176 bits");
        return int176(value);
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168) {
        require(value >= type(int168).min && value <= type(int168).max, "SafeCast: value doesn't fit in 168 bits");
        return int168(value);
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160) {
        require(value >= type(int160).min && value <= type(int160).max, "SafeCast: value doesn't fit in 160 bits");
        return int160(value);
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152) {
        require(value >= type(int152).min && value <= type(int152).max, "SafeCast: value doesn't fit in 152 bits");
        return int152(value);
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144) {
        require(value >= type(int144).min && value <= type(int144).max, "SafeCast: value doesn't fit in 144 bits");
        return int144(value);
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136) {
        require(value >= type(int136).min && value <= type(int136).max, "SafeCast: value doesn't fit in 136 bits");
        return int136(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120) {
        require(value >= type(int120).min && value <= type(int120).max, "SafeCast: value doesn't fit in 120 bits");
        return int120(value);
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112) {
        require(value >= type(int112).min && value <= type(int112).max, "SafeCast: value doesn't fit in 112 bits");
        return int112(value);
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104) {
        require(value >= type(int104).min && value <= type(int104).max, "SafeCast: value doesn't fit in 104 bits");
        return int104(value);
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96) {
        require(value >= type(int96).min && value <= type(int96).max, "SafeCast: value doesn't fit in 96 bits");
        return int96(value);
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88) {
        require(value >= type(int88).min && value <= type(int88).max, "SafeCast: value doesn't fit in 88 bits");
        return int88(value);
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80) {
        require(value >= type(int80).min && value <= type(int80).max, "SafeCast: value doesn't fit in 80 bits");
        return int80(value);
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72) {
        require(value >= type(int72).min && value <= type(int72).max, "SafeCast: value doesn't fit in 72 bits");
        return int72(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56) {
        require(value >= type(int56).min && value <= type(int56).max, "SafeCast: value doesn't fit in 56 bits");
        return int56(value);
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48) {
        require(value >= type(int48).min && value <= type(int48).max, "SafeCast: value doesn't fit in 48 bits");
        return int48(value);
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40) {
        require(value >= type(int40).min && value <= type(int40).max, "SafeCast: value doesn't fit in 40 bits");
        return int40(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24) {
        require(value >= type(int24).min && value <= type(int24).max, "SafeCast: value doesn't fit in 24 bits");
        return int24(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/*
“Copyright (c) 2019-2021 1inch 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions: 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software. 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE”.
*/

import '@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol';
import './OrderMixin.sol';
import './OrderRFQMixin.sol';

/// @title Kyber Limit Order Protocol
contract LimitOrderProtocol is
  EIP712('Kyber Limit Order Protocol', '2'),
  OrderMixin,
  OrderRFQMixin
{
  // solhint-disable-next-line func-name-mixedcase
  function DOMAIN_SEPARATOR() external view returns (bytes32) {
    return _domainSeparatorV4();
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/*
“Copyright (c) 2019-2021 1inch 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions: 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software. 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE”.
*/

import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol';
import '@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import './helpers/AmountCalculator.sol';
import './helpers/ChainlinkCalculator.sol';
import './helpers/NonceManager.sol';
import './helpers/PredicateHelper.sol';
import './interfaces/InteractiveNotificationReceiver.sol';
import './interfaces/ILimitOrderCallee.sol';
import './libraries/ArgumentsDecoder.sol';
import './libraries/Permitable.sol';

/// @title Regular Limit Order mixin
abstract contract OrderMixin is
  EIP712,
  AmountCalculator,
  ChainlinkCalculator,
  NonceManager,
  PredicateHelper,
  Permitable,
  Ownable
{
  using Address for address;
  using ArgumentsDecoder for bytes;

  /// @notice Emitted every time order gets filled, including partial fills
  event OrderFilled(
    address indexed taker,
    bytes32 orderHash,
    uint256 remaining,
    uint256 makingAmount,
    uint256 takingAmount
  );

  /// @notice Emitted when order gets cancelled
  event OrderCanceled(address indexed maker, bytes32 orderHash, uint256 remainingRaw);

  /// @notice Emitted when update interaction target whitelist
  event UpdatedInteractionWhitelist(address _address, bool isWhitelist);

  // Fixed-size order part with core information
  struct StaticOrder {
    uint256 salt;
    address makerAsset;
    address takerAsset;
    address maker;
    address receiver;
    address allowedSender; // equals to Zero address on public orders
    uint256 makingAmount;
    uint256 takingAmount;
    address feeRecipient;
    uint32 makerTokenFeePercent;
  }

  // `StaticOrder` extension including variable-sized additional order meta information
  struct Order {
    uint256 salt;
    address makerAsset;
    address takerAsset;
    address maker;
    address receiver;
    address allowedSender; // equals to Zero address on public orders
    uint256 makingAmount;
    uint256 takingAmount;
    address feeRecipient;
    uint32 makerTokenFeePercent;
    bytes makerAssetData;
    bytes takerAssetData;
    bytes getMakerAmount; // this.staticcall(abi.encodePacked(bytes, swapTakerAmount)) => (swapMakerAmount)
    bytes getTakerAmount; // this.staticcall(abi.encodePacked(bytes, swapMakerAmount)) => (swapTakerAmount)
    bytes predicate; // this.staticcall(bytes) => (bool)
    bytes permit; // On first fill: permit.1.call(abi.encodePacked(permit.selector, permit.2))
    bytes interaction;
  }

  struct FillOrderParams {
    Order order;
    bytes signature;
    uint256 makingAmount;
    uint256 takingAmount;
    uint256 thresholdAmount;
    address target;
    bytes callbackData;
  }

  struct FillBatchOrdersParams {
    Order[] orders;
    bytes[] signatures;
    uint256 takingAmount;
    uint256 thresholdAmount;
    address target;
  }

  bytes32 public constant LIMIT_ORDER_TYPEHASH =
    keccak256(
      'Order(uint256 salt,address makerAsset,address takerAsset,address maker,address receiver,address allowedSender,uint256 makingAmount,uint256 takingAmount,address feeRecipient,uint32 makerTokenFeePercent,bytes makerAssetData,bytes takerAssetData,bytes getMakerAmount,bytes getTakerAmount,bytes predicate,bytes permit,bytes interaction)'
    );
  uint256 private constant _ORDER_DOES_NOT_EXIST = 0;
  uint256 private constant _ORDER_FILLED = 1;
  uint16 internal constant BPS = 10000;

  /// @notice Stores unfilled amounts for each order plus one
  /// Therefore 0 means order doesn't exist and 1 means order was filled
  mapping(bytes32 => uint256) private _remaining;
  mapping(address => bool) interactionWhitelist;

  /// @notice Update interaction target whitelist
  function updateInteractionWhitelist(address _address, bool isWhitelist) external onlyOwner {
    interactionWhitelist[_address] = isWhitelist;
    emit UpdatedInteractionWhitelist(_address, isWhitelist);
  }

  /// @notice Returns unfilled amount for order. Throws if order does not exist
  function remaining(bytes32 orderHash) external view returns (uint256) {
    uint256 amount = _remaining[orderHash];
    require(amount != _ORDER_DOES_NOT_EXIST, 'LOP: Unknown order');
    unchecked {
      amount -= 1;
    }
    return amount;
  }

  /// @notice Returns unfilled amount for order
  /// @return Result Unfilled amount of order plus one if order exists. Otherwise 0
  function remainingRaw(bytes32 orderHash) external view returns (uint256) {
    return _remaining[orderHash];
  }

  /// @notice Same as `remainingRaw` but for multiple orders
  function remainingsRaw(bytes32[] memory orderHashes) external view returns (uint256[] memory) {
    uint256[] memory results = new uint256[](orderHashes.length);
    for (uint256 i = 0; i < orderHashes.length; i++) {
      results[i] = _remaining[orderHashes[i]];
    }
    return results;
  }

  /**
   * @notice Calls every target with corresponding data. Then reverts with CALL_RESULTS_0101011 where zeroes and ones
   * denote failure or success of the corresponding call
   * @param targets Array of addresses that will be called
   * @param data Array of data that will be passed to each call
   */
  function simulateCalls(address[] calldata targets, bytes[] calldata data) external {
    require(targets.length == data.length, 'LOP: array size mismatch');
    bytes memory reason = new bytes(targets.length);
    for (uint256 i = 0; i < targets.length; i++) {
      // solhint-disable-next-line avoid-low-level-calls
      (bool success, bytes memory result) = targets[i].call(data[i]);
      if (success && result.length > 0) {
        success = result.length == 32 && result.decodeBool();
      }
      reason[i] = success ? bytes1('1') : bytes1('0');
    }

    // Always revert and provide per call results
    revert(string(abi.encodePacked('CALL_RESULTS_', reason)));
  }

  /// @notice Cancels order by setting remaining amount to zero
  function cancelOrder(Order memory order) public {
    require(order.maker == msg.sender, 'LOP: Access denied');

    bytes32 orderHash = hashOrder(order);
    uint256 orderRemaining = _remaining[orderHash];
    require(orderRemaining != _ORDER_FILLED, 'LOP: already filled');
    emit OrderCanceled(msg.sender, orderHash, orderRemaining);
    _remaining[orderHash] = _ORDER_FILLED;
  }

  /// @notice Cancels multiple orders by setting remaining amount to zero
  function cancelBatchOrders(Order[] memory orders) external {
    for (uint256 i = 0; i < orders.length; ++i) {
      cancelOrder(orders[i]);
    }
  }

  /// @notice Fills an order. If one doesn't exist (first fill) it will be created using order.makerAssetData
  /// @param order Order quote to fill
  /// @param signature Signature to confirm quote ownership
  /// @param makingAmount Making amount
  /// @param takingAmount Taking amount
  /// @param thresholdAmount Specifies maximum allowed takingAmount when takingAmount is zero, otherwise specifies minimum allowed makingAmount
  /// @param callbackData CallbackData to callback to the msg.sender after receiving the makingAmount, the msg.sender transfer takingAmount to the maker after this call
  /// @return actualMakingAmount
  /// @return actualTakingAmount
  function fillOrder(
    Order memory order,
    bytes calldata signature,
    uint256 makingAmount,
    uint256 takingAmount,
    uint256 thresholdAmount,
    bytes calldata callbackData
  )
    external
    returns (
      uint256, /* actualMakingAmount */
      uint256 /* actualTakingAmount */
    )
  {
    return
      fillOrderTo(
        FillOrderParams(
          order,
          signature,
          makingAmount,
          takingAmount,
          thresholdAmount,
          msg.sender,
          callbackData
        ),
        false
      );
  }

  /// @notice Same as `fillOrder` but calls permit first,
  /// allowing to approve token spending and make a swap in one transaction.
  /// Also allows to specify funds destination instead of `msg.sender`
  /// @param order Order quote to fill
  /// @param signature Signature to confirm quote ownership
  /// @param makingAmount Making amount
  /// @param takingAmount Taking amount
  /// @param thresholdAmount Specifies maximum allowed takingAmount when takingAmount is zero, otherwise specifies minimum allowed makingAmount
  /// @param target Address that will receive swap funds
  /// @param permit Should consist of abiencoded token address and encoded `IERC20Permit.permit` call.
  /// @dev See tests for examples
  function fillOrderToWithPermit(
    Order memory order,
    bytes calldata signature,
    uint256 makingAmount,
    uint256 takingAmount,
    uint256 thresholdAmount,
    address target,
    bytes calldata permit,
    bytes calldata callbackData
  )
    external
    returns (
      uint256, /* actualMakingAmount */
      uint256 /* actualTakingAmount */
    )
  {
    /* permit */
    {
      require(permit.length >= 20, 'LOP: permit length too low');
      (address token, bytes calldata permitData) = permit.decodeTargetAndData();
      _permit(token, permitData);
    }
    return
      fillOrderTo(
        FillOrderParams(
          order,
          signature,
          makingAmount,
          takingAmount,
          thresholdAmount,
          target,
          callbackData
        ),
        false
      );
  }

  /// @notice Same as `fillOrder`
  /// @param params FillOrderParams:
  ///   - Order order: quote to fill
  ///   - bytes signature: Signature to confirm quote ownership
  ///   - uint256 makingAmount: Making amount
  ///   - uint256 takingAmount: Taking amount
  ///   - uint256 thresholdAmount : Specifies maximum allowed takingAmount when takingAmount is zero, otherwise specifies minimum allowed makingAmount
  ///   - address target: Maker asset recipient
  ///   - bytes callbackData: CallbackData to callback to the msg.sender after receiving the makingAmount, the msg.sender transfer takingAmount to the maker after this call
  /// @param isForcedFill if isForcedFill is true, no matter the maker's balance or allowance is not enough, still try to fill with a new makingAmount = min(makerBalance, makerAllowance)
  /// @return actualMakingAmount
  /// @return actualTakingAmount
  function fillOrderTo(FillOrderParams memory params, bool isForcedFill)
    public
    returns (
      uint256, /* actualMakingAmount */
      uint256 /* actualTakingAmount */
    )
  {
    require(params.target != address(0), 'LOP: zero target is forbidden');
    bytes32 orderHash = hashOrder(params.order);

    {
      // Stack too deep
      uint256 remainingMakerAmount = _remaining[orderHash];
      if (remainingMakerAmount == _ORDER_FILLED) return (0, 0);
      require(
        params.order.allowedSender == address(0) || params.order.allowedSender == msg.sender,
        'LOP: private order'
      );
      if (remainingMakerAmount == _ORDER_DOES_NOT_EXIST) {
        // First fill: validate order and permit maker asset
        require(
          SignatureChecker.isValidSignatureNow(params.order.maker, orderHash, params.signature),
          'LOP: bad signature'
        );
        remainingMakerAmount = params.order.makingAmount;
        if (params.order.permit.length >= 20) {
          // proceed only if permit length is enough to store address
          (address token, bytes memory permit) = params.order.permit.decodeTargetAndCalldata();
          _permitMemory(token, permit);
          require(_remaining[orderHash] == _ORDER_DOES_NOT_EXIST, 'LOP: reentrancy detected');
        }
      } else {
        unchecked {
          remainingMakerAmount -= 1;
        }
      }

      // Check if order is valid
      if (params.order.predicate.length > 0) {
        bool isValidPredicate = checkPredicate(params.order);
        if (isForcedFill) {
          if (!isValidPredicate) return (0, 0);
        } else {
          require(isValidPredicate, 'LOP: predicate returned false');
        }
      }

      // Compute maker and taker assets amount
      if ((params.takingAmount == 0) == (params.makingAmount == 0)) {
        revert('LOP: only one amount should be 0');
      } else if (params.takingAmount == 0) {
        uint256 requestedMakingAmount = params.makingAmount;
        if (params.makingAmount > remainingMakerAmount) {
          params.makingAmount = remainingMakerAmount;
        }
        /// If isForcedFill is true, set params.makingAmount = min(params.makingAmount, makerBalance, makerAllowance)
        if (isForcedFill) {
          (, params.makingAmount) = _modifyMakingAmount(
            params.order.makerAsset,
            params.order.maker,
            params.makingAmount
          );
        }

        params.takingAmount = _callGetter(
          params.order.getTakerAmount,
          params.order.makingAmount,
          params.makingAmount,
          params.order.takingAmount
        );
        // check that actual rate is not worse than what was expected
        // takingAmount / makingAmount <= thresholdAmount / requestedMakingAmount
        require(
          params.takingAmount * requestedMakingAmount <=
            params.thresholdAmount * params.makingAmount,
          'LOP: taking amount too high'
        );
      } else {
        uint256 requestedTakingAmount = params.takingAmount;
        params.makingAmount = _callGetter(
          params.order.getMakerAmount,
          params.order.takingAmount,
          params.takingAmount,
          params.order.makingAmount
        );
        /// If isForcedFill is true, set params.makingAmount = min(params.makingAmount, remainingMakerAmount, makerBalance, makerAllowance)
        bool isModified = false;
        if (isForcedFill) {
          (isModified, params.makingAmount) = _modifyMakingAmount(
            params.order.makerAsset,
            params.order.maker,
            params.makingAmount
          );
        }
        if (isModified || params.makingAmount > remainingMakerAmount) {
          params.makingAmount = params.makingAmount > remainingMakerAmount
            ? remainingMakerAmount
            : params.makingAmount;
          params.takingAmount = _callGetter(
            params.order.getTakerAmount,
            params.order.makingAmount,
            params.makingAmount,
            params.order.takingAmount
          );
        }
        // check that actual rate is not worse than what was expected
        // makingAmount / takingAmount >= thresholdAmount / requestedTakingAmount
        require(
          params.makingAmount * requestedTakingAmount >=
            params.thresholdAmount * params.takingAmount,
          'LOP: making amount too low'
        );
      }

      require(params.makingAmount > 0 && params.takingAmount > 0, "LOP: can't swap 0 amount");

      // Update remaining amount in storage
      unchecked {
        remainingMakerAmount = remainingMakerAmount - params.makingAmount;
        _remaining[orderHash] = remainingMakerAmount + 1;
      }
      emit OrderFilled(
        msg.sender,
        orderHash,
        remainingMakerAmount,
        params.makingAmount,
        params.takingAmount
      );
    }

    // Maker => FeeRecipient
    uint256 feeAmount = 0;
    if (params.order.feeRecipient != address(0) && params.order.makerTokenFeePercent > 0) {
      feeAmount = (params.makingAmount * params.order.makerTokenFeePercent + BPS - 1) / BPS;
      _makeCall(
        params.order.makerAsset,
        abi.encodePacked(
          IERC20.transferFrom.selector,
          uint256(uint160(params.order.maker)),
          uint256(uint160(params.order.feeRecipient)),
          feeAmount,
          params.order.makerAssetData
        )
      );
    }

    // Maker => Taker
    _makeCall(
      params.order.makerAsset,
      abi.encodePacked(
        IERC20.transferFrom.selector,
        uint256(uint160(params.order.maker)),
        uint256(uint160(params.target)),
        params.makingAmount - feeAmount,
        params.order.makerAssetData
      )
    );

    // Callback to msg.sender
    if (params.callbackData.length > 0) {
      ILimitOrderCallee(msg.sender).limitOrderCall(
        params.makingAmount,
        params.takingAmount,
        params.callbackData
      );
    }

    // Taker => Maker
    _makeCall(
      params.order.takerAsset,
      abi.encodePacked(
        IERC20.transferFrom.selector,
        uint256(uint160(msg.sender)),
        uint256(
          uint160(params.order.receiver == address(0) ? params.order.maker : params.order.receiver)
        ),
        params.takingAmount,
        params.order.takerAssetData
      )
    );

    // Maker can handle funds interactively
    if (params.order.interaction.length >= 20) {
      // proceed only if interaction length is enough to store address
      (address interactionTarget, bytes memory interactionData) = params
        .order
        .interaction
        .decodeTargetAndCalldata();
      require(
        interactionWhitelist[interactionTarget],
        'LOP: the interaction target is not whitelisted'
      );
      InteractiveNotificationReceiver(interactionTarget).notifyFillOrder(
        msg.sender,
        params.order.makerAsset,
        params.order.takerAsset,
        params.makingAmount,
        params.takingAmount,
        interactionData
      );
    }

    return (params.makingAmount, params.takingAmount);
  }

  /// @notice Try to fulfill the takingAmount across multiple orders that have the same makerAsset and takerAsset
  /// @param params FillBatchOrdersParams:
  ///   - Order[] orders: Order list to fill one by one until fulfill the takingAmount
  ///   - bytes[] signatures: Signatures of the orders to confirm quote ownership
  ///   - uint256 takingAmount: Taking amount
  ///   - uint256 thresholdAmount: Minimun makingAmount is acceptable
  ///   - address target: Recipient address for maker asset
  /// @return actualMakingAmount
  /// @return actualTakingAmount
  function fillBatchOrdersTo(FillBatchOrdersParams memory params)
    external
    returns (
      uint256, /* actualMakingAmount */
      uint256 /* actualTakingAmount */
    )
  {
    require(params.orders.length > 0, 'LOP: empty array');
    require(params.orders.length == params.signatures.length, 'LOP: array size mismatch');
    require(params.takingAmount != 0, 'LOP: zero takingAmount');

    address makerAsset = params.orders[0].makerAsset;
    address takerAsset = params.orders[0].takerAsset;
    uint256 actualMakingAmount = 0;
    uint256 remainingTakingAmount = params.takingAmount;
    for (uint256 i = 0; i < params.orders.length; i++) {
      require(
        makerAsset == params.orders[i].makerAsset && takerAsset == params.orders[i].takerAsset,
        'LOP: invalid pair'
      );
      (uint256 _makingAmount, uint256 _takingAmount) = fillOrderTo(
        FillOrderParams(
          params.orders[i],
          params.signatures[i],
          0,
          remainingTakingAmount,
          0,
          params.target,
          ''
        ),
        true
      );
      actualMakingAmount += _makingAmount;
      remainingTakingAmount -= _takingAmount;
      if (remainingTakingAmount == 0) break;
    }
    require(remainingTakingAmount == 0, 'LOP: cannot fulfill');
    require(actualMakingAmount >= params.thresholdAmount, 'LOP: making amount too low');
    return (actualMakingAmount, params.takingAmount);
  }

  /// @notice Checks order predicate
  function checkPredicate(Order memory order) public view returns (bool) {
    bytes memory result = address(this).functionStaticCall(
      order.predicate,
      'LOP: predicate call failed'
    );
    require(result.length == 32, 'LOP: invalid predicate return');
    return result.decodeBool();
  }

  function hashOrder(Order memory order) public view returns (bytes32) {
    StaticOrder memory staticOrder;
    assembly {
      // solhint-disable-line no-inline-assembly
      staticOrder := order
    }
    return
      _hashTypedDataV4(
        keccak256(
          abi.encode(
            LIMIT_ORDER_TYPEHASH,
            staticOrder,
            keccak256(order.makerAssetData),
            keccak256(order.takerAssetData),
            keccak256(order.getMakerAmount),
            keccak256(order.getTakerAmount),
            keccak256(order.predicate),
            keccak256(order.permit),
            keccak256(order.interaction)
          )
        )
      );
  }

  function _makeCall(address asset, bytes memory assetData) private {
    bytes memory result = asset.functionCall(assetData, 'LOP: asset.call failed');
    if (result.length > 0) {
      require(result.length == 32 && result.decodeBool(), 'LOP: asset.call bad result');
    }
  }

  function _callGetter(
    bytes memory getter,
    uint256 orderExpectedAmount,
    uint256 amount,
    uint256 orderResultAmount
  ) private view returns (uint256) {
    if (getter.length == 0) {
      // On empty getter calldata only exact amount is allowed
      require(amount == orderExpectedAmount, 'LOP: wrong amount');
      return orderResultAmount;
    } else {
      bytes memory result = address(this).functionStaticCall(
        abi.encodePacked(getter, amount),
        'LOP: getAmount call failed'
      );
      require(result.length == 32, 'LOP: invalid getAmount return');
      return result.decodeUint256();
    }
  }

  /// @notice Returns makingAmount = min(params.makingAmount, makerBalance, makerAllowance)
  /// @param makerAsset Maker asset address
  /// @param maker Maker address
  /// @param makingAmount Making amount
  /// @return isModified
  /// @return makingAmount
  function _modifyMakingAmount(
    address makerAsset,
    address maker,
    uint256 makingAmount
  ) private view returns (bool, uint256) {
    uint256 makerBalance = IERC20(makerAsset).balanceOf(maker);
    uint256 makerAllowance = IERC20(makerAsset).allowance(maker, address(this));

    if (makingAmount > makerBalance || makingAmount > makerAllowance) {
      makingAmount = makerBalance > makerAllowance ? makerAllowance : makerBalance;
      return (true, makingAmount);
    }

    return (false, makingAmount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/*
“Copyright (c) 2019-2021 1inch 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions: 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software. 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE”.
*/

import '@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol';
import '@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

import './helpers/AmountCalculator.sol';
import './libraries/Permitable.sol';

/// @title RFQ Limit Order mixin
abstract contract OrderRFQMixin is EIP712, AmountCalculator, Permitable {
  using SafeERC20 for IERC20;

  /// @notice Emitted when RFQ gets filled
  event OrderFilledRFQ(
    address indexed taker,
    bytes32 indexed orderHash,
    uint256 makingAmount,
    uint256 takingAmount
  );

  struct OrderRFQ {
    uint256 info; // lowest 64 bits is the order id, next 64 bits is the expiration timestamp
    IERC20 makerAsset;
    IERC20 takerAsset;
    address maker;
    address allowedSender; // equals to Zero address on public orders
    uint256 makingAmount;
    uint256 takingAmount;
    uint256 makingAmountThreshold;
  }

  bytes32 public constant LIMIT_ORDER_RFQ_TYPEHASH =
    keccak256(
      'OrderRFQ(uint256 info,address makerAsset,address takerAsset,address maker,address allowedSender,uint256 makingAmount,uint256 takingAmount)'
    );

  mapping(address => mapping(uint256 => uint256)) private _invalidator;

  /// @notice Returns bitmask for double-spend invalidators based on lowest byte of order.info and filled quotes
  /// @return Result Each bit represents whether corresponding was already invalidated
  function invalidatorForOrderRFQ(address maker, uint256 slot) external view returns (uint256) {
    return _invalidator[maker][slot];
  }

  /// @notice Cancels order's quote
  function cancelOrderRFQ(uint256 orderInfo) external {
    _invalidateOrder(msg.sender, orderInfo);
  }

  /// @notice Fills order's quote, fully or partially (whichever is possible)
  /// @param order Order quote to fill
  /// @param signature Signature to confirm quote ownership
  /// @param makingAmount Making amount
  /// @param takingAmount Taking amount
  function fillOrderRFQ(
    OrderRFQ memory order,
    bytes calldata signature,
    uint256 makingAmount,
    uint256 takingAmount
  )
    external
    returns (
      uint256, /* actualMakingAmount */
      uint256 /* actualTakingAmount */
    )
  {
    return fillOrderRFQTo(order, signature, makingAmount, takingAmount, msg.sender);
  }

  /// @notice Fills Same as `fillOrderRFQ` but calls permit first,
  /// allowing to approve token spending and make a swap in one transaction.
  /// Also allows to specify funds destination instead of `msg.sender`
  /// @param order Order quote to fill
  /// @param signature Signature to confirm quote ownership
  /// @param makingAmount Making amount
  /// @param takingAmount Taking amount
  /// @param target Address that will receive swap funds
  /// @param permit Should consist of abiencoded token address and encoded `IERC20Permit.permit` call.
  /// @dev See tests for examples
  function fillOrderRFQToWithPermit(
    OrderRFQ memory order,
    bytes calldata signature,
    uint256 makingAmount,
    uint256 takingAmount,
    address target,
    bytes calldata permit
  )
    external
    returns (
      uint256, /* actualMakingAmount */
      uint256 /* actualTakingAmount */
    )
  {
    _permit(address(order.takerAsset), permit);
    return fillOrderRFQTo(order, signature, makingAmount, takingAmount, target);
  }

  /// @notice Same as `fillOrderRFQ` but allows to specify funds destination instead of `msg.sender`
  /// @param order Order quote to fill
  /// @param signature Signature to confirm quote ownership
  /// @param makingAmount Making amount
  /// @param takingAmount Taking amount
  /// @param target Address that will receive swap funds
  function fillOrderRFQTo(
    OrderRFQ memory order,
    bytes calldata signature,
    uint256 makingAmount,
    uint256 takingAmount,
    address target
  )
    public
    returns (
      uint256, /* actualMakingAmount */
      uint256 /* actualTakingAmount */
    )
  {
    require(target != address(0), 'LOP: zero target is forbidden');

    address maker = order.maker;

    // Validate order
    require(
      order.allowedSender == address(0) || order.allowedSender == msg.sender,
      'LOP: private order'
    );
    bytes32 orderHash = _hashTypedDataV4(keccak256(abi.encode(LIMIT_ORDER_RFQ_TYPEHASH, order)));
    require(
      SignatureChecker.isValidSignatureNow(maker, orderHash, signature),
      'LOP: bad signature'
    );

    {
      // Stack too deep
      uint256 info = order.info;
      // Check time expiration
      uint256 expiration = uint128(info) >> 64;
      require(expiration == 0 || block.timestamp <= expiration, 'LOP: order expired'); // solhint-disable-line not-rely-on-time
      _invalidateOrder(maker, info);
    }

    {
      // stack too deep
      uint256 orderMakingAmount = order.makingAmount;
      uint256 orderTakingAmount = order.takingAmount;
      // Compute partial fill if needed
      if (takingAmount == 0 && makingAmount == 0) {
        // Two zeros means whole order
        makingAmount = orderMakingAmount;
        takingAmount = orderTakingAmount;
      } else if (takingAmount == 0) {
        require(makingAmount <= orderMakingAmount, 'LOP: making amount exceeded');
        takingAmount = getTakerAmount(orderMakingAmount, orderTakingAmount, makingAmount);
      } else if (makingAmount == 0) {
        require(takingAmount <= orderTakingAmount, 'LOP: taking amount exceeded');
        makingAmount = getMakerAmount(orderMakingAmount, orderTakingAmount, takingAmount);
      } else {
        revert('LOP: both amounts are non-zero');
      }
    }

    require(makingAmount > 0 && takingAmount > 0, "LOP: can't swap 0 amount");
    require(makingAmount >= order.makingAmountThreshold, 'LOP: not enough filled amount');
    // Maker => Taker, Taker => Maker
    order.makerAsset.safeTransferFrom(maker, target, makingAmount);
    order.takerAsset.safeTransferFrom(msg.sender, maker, takingAmount);

    emit OrderFilledRFQ(msg.sender, orderHash, makingAmount, takingAmount);
    return (makingAmount, takingAmount);
  }

  function _invalidateOrder(address maker, uint256 orderInfo) private {
    uint256 invalidatorSlot = uint64(orderInfo) >> 8;
    uint256 invalidatorBit = 1 << uint8(orderInfo);
    mapping(uint256 => uint256) storage invalidatorStorage = _invalidator[maker];
    uint256 invalidator = invalidatorStorage[invalidatorSlot];
    require(invalidator & invalidatorBit == 0, 'LOP: invalidated order');
    invalidatorStorage[invalidatorSlot] = invalidator | invalidatorBit;
  }

  function hashOrderRFQ(OrderRFQ memory order) public view returns (bytes32) {
    return _hashTypedDataV4(keccak256(abi.encode(LIMIT_ORDER_RFQ_TYPEHASH, order)));
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;
pragma abicoder v1;

/*
“Copyright (c) 2019-2021 1inch 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions: 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software. 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE”.
*/

import '@openzeppelin/contracts/utils/Address.sol';

/// @title A helper contract for calculations related to order amounts
contract AmountCalculator {
  using Address for address;

  /// @notice Calculates maker amount
  /// @return Result Floored maker amount
  function getMakerAmount(
    uint256 orderMakerAmount,
    uint256 orderTakerAmount,
    uint256 swapTakerAmount
  ) public pure returns (uint256) {
    return (swapTakerAmount * orderMakerAmount) / orderTakerAmount;
  }

  /// @notice Calculates taker amount
  /// @return Result Ceiled taker amount
  function getTakerAmount(
    uint256 orderMakerAmount,
    uint256 orderTakerAmount,
    uint256 swapMakerAmount
  ) public pure returns (uint256) {
    return (swapMakerAmount * orderTakerAmount + orderMakerAmount - 1) / orderMakerAmount;
  }

  /// @notice Performs an arbitrary call to target with data
  /// @return Result Bytes transmuted to uint256
  function arbitraryStaticCall(address target, bytes memory data) external view returns (uint256) {
    bytes memory result = target.functionStaticCall(data, 'AC: arbitraryStaticCall');
    return abi.decode(result, (uint256));
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;
pragma abicoder v1;

/*
“Copyright (c) 2019-2021 1inch 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions: 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software. 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE”.
*/

import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import '@openzeppelin/contracts/utils/math/SafeCast.sol';

/// @title A helper contract for interactions with https://docs.chain.link
contract ChainlinkCalculator {
  using SafeCast for int256;

  uint256 private constant _SPREAD_DENOMINATOR = 1e9;
  uint256 private constant _ORACLE_EXPIRATION_TIME = 30 minutes;
  uint256 private constant _INVERSE_MASK = 1 << 255;

  /// @notice Calculates price of token relative to oracle unit (ETH or USD)
  /// @param inverseAndSpread concatenated inverse flag and spread.
  /// Lowest 254 bits specify spread amount. Spread is scaled by 1e9, i.e. 101% = 1.01e9, 99% = 0.99e9.
  /// Highest bit is set when oracle price should be inverted,
  /// e.g. for DAI-ETH oracle, inverse=false means that we request DAI price in ETH
  /// and inverse=true means that we request ETH price in DAI
  /// @return Amount * spread * oracle price
  function singlePrice(
    AggregatorV3Interface oracle,
    uint256 inverseAndSpread,
    uint256 amount
  ) external view returns (uint256) {
    (, int256 latestAnswer, , uint256 latestTimestamp, ) = oracle.latestRoundData();
    // solhint-disable-next-line not-rely-on-time
    require(latestTimestamp + _ORACLE_EXPIRATION_TIME > block.timestamp, 'CC: stale data');
    bool inverse = inverseAndSpread & _INVERSE_MASK > 0;
    uint256 spread = inverseAndSpread & (~_INVERSE_MASK);
    if (inverse) {
      return
        (amount * spread * (10**oracle.decimals())) /
        latestAnswer.toUint256() /
        _SPREAD_DENOMINATOR;
    } else {
      return
        (amount * spread * latestAnswer.toUint256()) /
        (10**oracle.decimals()) /
        _SPREAD_DENOMINATOR;
    }
  }

  /// @notice Calculates price of token A relative to token B. Note that order is important
  /// @return Result Token A relative price times amount
  function doublePrice(
    AggregatorV3Interface oracle1,
    AggregatorV3Interface oracle2,
    uint256 spread,
    uint256 amount
  ) external view returns (uint256) {
    require(oracle1.decimals() == oracle2.decimals(), "CC: oracle decimals don't match");

    (, int256 latestAnswer1, , uint256 latestTimestamp1, ) = oracle1.latestRoundData();
    (, int256 latestAnswer2, , uint256 latestTimestamp2, ) = oracle2.latestRoundData();
    // solhint-disable-next-line not-rely-on-time
    require(latestTimestamp1 + _ORACLE_EXPIRATION_TIME > block.timestamp, 'CC: stale data O1');
    // solhint-disable-next-line not-rely-on-time
    require(latestTimestamp2 + _ORACLE_EXPIRATION_TIME > block.timestamp, 'CC: stale data O2');

    return
      (amount * spread * latestAnswer1.toUint256()) /
      latestAnswer2.toUint256() /
      _SPREAD_DENOMINATOR;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;
pragma abicoder v1;

/*
“Copyright (c) 2019-2021 1inch 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions: 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software. 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE”.
*/

/// @title A helper contract for managing nonce of tx sender
contract NonceManager {
  event NonceIncreased(address indexed maker, uint256 oldNonce, uint256 newNonce);

  mapping(address => uint256) public nonce;

  /// @notice Advances nonce by one
  function increaseNonce() external {
    advanceNonce(1);
  }

  /// @notice Advances nonce by specified amount
  function advanceNonce(uint8 amount) public {
    uint256 newNonce = nonce[msg.sender] + amount;
    nonce[msg.sender] = newNonce;
    emit NonceIncreased(msg.sender, newNonce - amount, newNonce);
  }

  /// @notice Checks if `makerAddress` has specified `makerNonce`
  /// @return Result True if `makerAddress` has specified nonce. Otherwise, false
  function nonceEquals(address makerAddress, uint256 makerNonce) external view returns (bool) {
    return nonce[makerAddress] == makerNonce;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/*
“Copyright (c) 2019-2021 1inch 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions: 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software. 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE”.
*/

import '@openzeppelin/contracts/utils/Address.sol';

/// @title A helper contract for executing boolean functions on arbitrary target call results
contract PredicateHelper {
  using Address for address;

  /// @notice Calls every target with corresponding data
  /// @return Result True if call to any target returned True. Otherwise, false
  function or(address[] calldata targets, bytes[] calldata data) external view returns (bool) {
    require(targets.length == data.length, 'PH: input array size mismatch');
    for (uint256 i = 0; i < targets.length; i++) {
      bytes memory result = targets[i].functionStaticCall(data[i], "PH: 'or' subcall failed");
      require(result.length == 32, 'PH: invalid call result');
      if (abi.decode(result, (bool))) {
        return true;
      }
    }
    return false;
  }

  /// @notice Calls every target with corresponding data
  /// @return Result True if calls to all targets returned True. Otherwise, false
  function and(address[] calldata targets, bytes[] calldata data) external view returns (bool) {
    require(targets.length == data.length, 'PH: input array size mismatch');
    for (uint256 i = 0; i < targets.length; i++) {
      bytes memory result = targets[i].functionStaticCall(data[i], "PH: 'and' subcall failed");
      require(result.length == 32, 'PH: invalid call result');
      if (!abi.decode(result, (bool))) {
        return false;
      }
    }
    return true;
  }

  /// @notice Calls target with specified data and tests if it's equal to the value
  /// @param value Value to test
  /// @return Result True if call to target returns the same value as `value`. Otherwise, false
  function eq(
    uint256 value,
    address target,
    bytes memory data
  ) external view returns (bool) {
    bytes memory result = target.functionStaticCall(data, 'PH: eq');
    require(result.length == 32, 'PH: invalid call result');
    return abi.decode(result, (uint256)) == value;
  }

  /// @notice Calls target with specified data and tests if it's lower than value
  /// @param value Value to test
  /// @return Result True if call to target returns value which is lower than `value`. Otherwise, false
  function lt(
    uint256 value,
    address target,
    bytes memory data
  ) external view returns (bool) {
    bytes memory result = target.functionStaticCall(data, 'PH: lt');
    require(result.length == 32, 'PH: invalid call result');
    return abi.decode(result, (uint256)) < value;
  }

  /// @notice Calls target with specified data and tests if it's bigger than value
  /// @param value Value to test
  /// @return Result True if call to target returns value which is bigger than `value`. Otherwise, false
  function gt(
    uint256 value,
    address target,
    bytes memory data
  ) external view returns (bool) {
    bytes memory result = target.functionStaticCall(data, 'PH: gt');
    require(result.length == 32, 'PH: invalid call result');
    return abi.decode(result, (uint256)) > value;
  }

  /// @notice Checks passed time against block timestamp
  /// @return Result True if current block timestamp is lower than `time`. Otherwise, false
  function timestampBelow(uint256 time) external view returns (bool) {
    return block.timestamp < time; // solhint-disable-line not-rely-on-time
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;
pragma abicoder v1;

/// @title Interface for DAI-style permits
interface IDaiLikePermit {
  function permit(
    address holder,
    address spender,
    uint256 nonce,
    uint256 expiry,
    bool allowed,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/// @title Interface for DAI-style permits
interface ILimitOrderCallee {
  function limitOrderCall(
    uint256 makingAmount,
    uint256 takingAmount,
    bytes memory callbackData
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;
pragma abicoder v1;

/// @title Interface for interactor which acts between `maker => taker` and `taker => maker` transfers.
interface InteractiveNotificationReceiver {
  /// @notice Callback method that gets called after taker transferred funds to maker but before
  /// the opposite transfer happened
  function notifyFillOrder(
    address taker,
    address makerAsset,
    address takerAsset,
    uint256 makingAmount,
    uint256 takingAmount,
    bytes memory interactiveData
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;
pragma abicoder v1;

/*
“Copyright (c) 2019-2021 1inch 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions: 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software. 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE”.
*/

/// @title Library with gas efficient alternatives to `abi.decode`
library ArgumentsDecoder {
  function decodeUint256(bytes memory data) internal pure returns (uint256) {
    uint256 value;
    assembly {
      // solhint-disable-line no-inline-assembly
      value := mload(add(data, 0x20))
    }
    return value;
  }

  function decodeBool(bytes memory data) internal pure returns (bool) {
    bool value;
    assembly {
      // solhint-disable-line no-inline-assembly
      value := eq(mload(add(data, 0x20)), 1)
    }
    return value;
  }

  function decodeTargetAndCalldata(bytes memory data)
    internal
    pure
    returns (address, bytes memory)
  {
    address target;
    bytes memory args;
    assembly {
      // solhint-disable-line no-inline-assembly
      target := mload(add(data, 0x14))
      args := add(data, 0x14)
      mstore(args, sub(mload(data), 0x14))
    }
    return (target, args);
  }

  function decodeTargetAndData(bytes calldata data)
    internal
    pure
    returns (address, bytes calldata)
  {
    address target;
    bytes calldata args;
    assembly {
      // solhint-disable-line no-inline-assembly
      target := shr(96, calldataload(data.offset))
    }
    args = data[20:];
    return (target, args);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;
pragma abicoder v1;

/*
“Copyright (c) 2019-2021 1inch 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions: 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software. 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE”.
*/

import '@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol';
import './RevertReasonParser.sol';
import '../interfaces/IDaiLikePermit.sol';

/// @title Base contract with common permit handling logics
abstract contract Permitable {
  function _permit(address token, bytes calldata permit) internal {
    if (permit.length > 0) {
      bool success;
      bytes memory result;
      if (permit.length == 32 * 7) {
        // solhint-disable-next-line avoid-low-level-calls
        (success, result) = token.call(abi.encodePacked(IERC20Permit.permit.selector, permit));
      } else if (permit.length == 32 * 8) {
        // solhint-disable-next-line avoid-low-level-calls
        (success, result) = token.call(abi.encodePacked(IDaiLikePermit.permit.selector, permit));
      } else {
        revert('Wrong permit length');
      }
      if (!success) {
        revert(RevertReasonParser.parse(result, 'Permit failed: '));
      }
    }
  }

  function _permitMemory(address token, bytes memory permit) internal {
    if (permit.length > 0) {
      bool success;
      bytes memory result;
      if (permit.length == 32 * 7) {
        // solhint-disable-next-line avoid-low-level-calls
        (success, result) = token.call(abi.encodePacked(IERC20Permit.permit.selector, permit));
      } else if (permit.length == 32 * 8) {
        // solhint-disable-next-line avoid-low-level-calls
        (success, result) = token.call(abi.encodePacked(IDaiLikePermit.permit.selector, permit));
      } else {
        revert('Wrong permit length');
      }
      if (!success) {
        revert(RevertReasonParser.parse(result, 'Permit failed: '));
      }
    }
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;
pragma abicoder v1;

/*
“Copyright (c) 2019-2021 1inch 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions: 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software. 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE”.
*/

/// @title Library that allows to parse unsuccessful arbitrary calls revert reasons.
/// See https://solidity.readthedocs.io/en/latest/control-structures.html#revert for details.
/// Note that we assume revert reason being abi-encoded as Error(string) so it may fail to parse reason
/// if structured reverts appear in the future.
///
/// All unsuccessful parsings get encoded as Unknown(data) string
library RevertReasonParser {
  bytes4 private constant _PANIC_SELECTOR = bytes4(keccak256('Panic(uint256)'));
  bytes4 private constant _ERROR_SELECTOR = bytes4(keccak256('Error(string)'));

  function parse(bytes memory data, string memory prefix) internal pure returns (string memory) {
    if (data.length >= 4) {
      bytes4 selector;

      assembly {
        // solhint-disable-line no-inline-assembly
        selector := mload(add(data, 0x20))
      }

      // 68 = 4-byte selector + 32 bytes offset + 32 bytes length
      if (selector == _ERROR_SELECTOR && data.length >= 68) {
        uint256 offset;
        bytes memory reason;
        assembly {
          // solhint-disable-line no-inline-assembly
          // 36 = 32 bytes data length + 4-byte selector
          offset := mload(add(data, 36))
          reason := add(data, add(36, offset))
        }
        /*
                    revert reason is padded up to 32 bytes with ABI encoder: Error(string)
                    also sometimes there is extra 32 bytes of zeros padded in the end:
                    https://github.com/ethereum/solidity/issues/10170
                    because of that we can't check for equality and instead check
                    that offset + string length + extra 36 bytes is less than overall data length
                */
        require(data.length >= 36 + offset + reason.length, 'Invalid revert reason');
        return string(abi.encodePacked(prefix, 'Error(', reason, ')'));
      }
      // 36 = 4-byte selector + 32 bytes integer
      else if (selector == _PANIC_SELECTOR && data.length == 36) {
        uint256 code;
        assembly {
          // solhint-disable-line no-inline-assembly
          // 36 = 32 bytes data length + 4-byte selector
          code := mload(add(data, 36))
        }
        return string(abi.encodePacked(prefix, 'Panic(', _toHex(code), ')'));
      }
    }

    return string(abi.encodePacked(prefix, 'Unknown(', _toHex(data), ')'));
  }

  function _toHex(uint256 value) private pure returns (string memory) {
    return _toHex(abi.encodePacked(value));
  }

  function _toHex(bytes memory data) private pure returns (string memory) {
    bytes16 alphabet = 0x30313233343536373839616263646566;
    bytes memory str = new bytes(2 + data.length * 2);
    str[0] = '0';
    str[1] = 'x';
    for (uint256 i = 0; i < data.length; i++) {
      str[2 * i + 2] = alphabet[uint8(data[i] >> 4)];
      str[2 * i + 3] = alphabet[uint8(data[i] & 0x0f)];
    }
    return string(str);
  }
}