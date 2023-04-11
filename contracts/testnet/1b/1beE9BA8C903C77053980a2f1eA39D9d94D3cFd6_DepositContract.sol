// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
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
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
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

pragma solidity ^0.8.4;

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

        uint256 chainID;
        assembly {
            chainID := chainid()
        }

        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = chainID;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {

        uint256 chainID;
        assembly {
            chainID := chainid()
        }

        if (chainID == _CACHED_CHAIN_ID) {
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
        uint256 chainID;
        assembly {
            chainID := chainid()
        }

        return keccak256(abi.encode(typeHash, nameHash, versionHash, chainID, address(this)));
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
pragma solidity 0.8.4;

// Importing SafeMath library to prevent integer overflow errors
import "./libraries/SafeMath.sol";
// Importing SafeERC20 library to prevent errors with ERC20 tokens
import "./libraries/SafeERC20.sol";
// Importing IERC20 interface for interacting with ERC20 tokens
import "./interfaces/IERC20.sol";
// Importing FarmCoin interface for interacting with FarmCoin
import "./interfaces/IFarmCoin.sol";
// Importing IERC20Permit interface for interacting with ERC20 tokens with permit() function
import "./interfaces/IERC20Permit.sol";
// Importing ERC20Permit type for supporting ERC20 tokens with permit() function
import "./types/ERC20Permit.sol";
// Importing FarmCoinAccessControlled type for access control on FarmCoin related functions
import "./types/FarmCoinAccessControlled.sol";

contract DepositContract is FarmCoinAccessControlled {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IFarmCoin;

    // Tokens
    IFarmCoin public immutable FarmCoin; // FarmCoin token contract address
    IERC20 public DepositToken; // ERC20 token contract address

    // Deposit matrix & interest
    // Struct for storing deposit information
    struct Deposit {
        uint256 depositTime; // Timestamp when the deposit was made
        uint256 depositAmount; // Amount of tokens deposited
        uint256 expire; // Timestamp when the deposit expires
        uint256 rewardPerSecond; // Rate of reward tokens per second
        uint256 lastClaimTime; // Timestamp when the last reward was claimed
        string currency; // Currency of the deposited tokens (ETH or USDC)
        address user; // Address of the depositor
        bool isWithdrawn; // Boolean flag to indicate whether the deposit has been withdrawn
    }
    // Mapping for storing the balance of Ether for each address
    mapping(address => uint) public etherBalanceOf;
    // Mapping for storing the deposit start time for each address
    mapping(address => uint) public depositStart;
    // Mapping for storing whether an address has made a deposit
    mapping(address => bool) public isDeposited;
    // Event for depositing Ether
    event DepositETH(address indexed user, uint etherAmount, uint timeStart);
    // Event for withdrawing Ether
    event WithdrawETH(
        address indexed user,
        uint etherAmount,
        uint depositTime,
        uint interest
    );

    mapping(address => Deposit[]) depositorMatrix;
    // Array for storing the interest rate for each duration
    uint256[] public interestArray = [5, 10, 15, 20];

    // Constructor for initializing the contract
    constructor(
        address _FarmCoin,
        address _DepositToken,
        address _authority
    ) FarmCoinAccessControlled(IFarmCoinAuthority(_authority)) {
        // Checking that the FarmCoin token address is not a zero address
        require(_FarmCoin != address(0), "Constructor: Zero address: FarmCoin");
        // Initializing the FarmCoin token address
        FarmCoin = IFarmCoin(_FarmCoin);

        // Checking that the deposit token address is not a zero address
        require(
            _DepositToken != address(0),
            "Constructor: Zero address: DepositToken"
        );
        // Initializing the deposit token address
        DepositToken = IERC20(_DepositToken);
    }

    /**
     @dev Allows a user to deposit tokens and earn rewards for a specified duration.
     @param _amount The amount of tokens to be deposited.
     @param _duration The duration for which the tokens are to be deposited. Must be either 1, 2, 3, or 4 representing 1 day, 2 days, 3 days, or 4 days, respectively.
     */
    function deposit(uint256 _amount, uint256 _duration) external {
        address account = msg.sender;

        require(
            _duration == 1 ||
                _duration == 2 ||
                _duration == 3 ||
                _duration == 4,
            "Deposit: Deposit duration incorrect"
        );

        require(
            DepositToken.balanceOf(account) >= _amount,
            "Deposit: Balance infuluence"
        );
        
        require(depositorMatrix[account].length < 5, "Deposit: Maximum number of stakes reached");

        require(
            _amount >= 100000000, // 100 USDC 
            "Deposit: Amount below minimum requirement"
        );

        uint256 _rewardPerSecond;
        if (_duration == 1) {
            _rewardPerSecond = uint256(5 ** 18).div(1 days);
        } else if (_duration == 2) {
            _rewardPerSecond = uint256(10 ** 18).div(1 days);
        } else if (_duration == 3) {
            _rewardPerSecond = uint256(15 ** 18).div(1 days);
        } else if (_duration == 4) {
            _rewardPerSecond = uint256(20 ** 18).div(1 days);
        }

        DepositToken.safeTransferFrom(account, address(this), _amount);

        depositorMatrix[account].push(
            Deposit({
                depositTime: block.timestamp,
                depositAmount: _amount,
                expire: block.timestamp.add(_duration * 1 days),
                rewardPerSecond: _rewardPerSecond,
                lastClaimTime: block.timestamp,
                currency: "USDC",
                user: account,
                isWithdrawn: false
            })
        );
    }

    /**
    @dev Allows a user to deposit ETH and earn rewards for a specified duration.
     @param _duration The duration for which the tokens are to be deposited. Must be either 1, 2, 3, or 4 representing 1 day, 2 days, 3 days, or 4 days, respectively.
     */
    function depositETH(uint256 _duration) external payable {
        address account = msg.sender;
        uint256 _amount = msg.value;
        require(
            _duration == 1 ||
                _duration == 2 ||
                _duration == 3 ||
                _duration == 4,
            "Deposit: Deposit duration incorrect"
        );
        require(depositorMatrix[account].length < 5, "Deposit: Maximum number of stakes reached");
        require(_amount >= 1e10, "Error, deposit must be >= 0.0000001 ETH");

        uint256 _rewardPerSecond;
        if (_duration == 1) {
            _rewardPerSecond = uint256(5 ** 18).div(1 days);
        } else if (_duration == 2) {
            _rewardPerSecond = uint256(10 ** 18).div(1 days);
        } else if (_duration == 3) {
            _rewardPerSecond = uint256(15 ** 18).div(1 days);
        } else if (_duration == 4) {
            _rewardPerSecond = uint256(20 ** 18).div(1 days);
        }

        depositorMatrix[account].push(
            Deposit({
                depositTime: block.timestamp,
                depositAmount: _amount,
                expire: block.timestamp.add(_duration * 1 days),
                rewardPerSecond: _rewardPerSecond,
                lastClaimTime: block.timestamp,
                currency: "ETH",
                user: account,
                isWithdrawn: false
            })
        );
    }

    /**
      @dev Withdraws the deposit made in ETH by the specified depositor and the corresponding rewards
      @param account The address of the depositor
      @param index The index of the deposit to withdraw
       Requirements:
        The caller must be a valid depositor.
        The deposit index must be within bounds.
        Only the depositor can withdraw their deposit and rewards.
        The deposit currency must be ETH.
        The deposit duration must have passed.
     */
    function withdrawETH(address account, uint256 index) external {
        require(isDepositor(account), "Withdraw: No Depositor");
        Deposit[] storage deposits = depositorMatrix[account];
        require(index < deposits.length, "Withdraw: Invalid deposit index");

        Deposit storage currentdeposit = deposits[index];
        require(
            currentdeposit.user == account,
            "Withdraw: Only depositor can withdraw"
        );

        if (
            currentdeposit.depositAmount > 0 &&
            keccak256(bytes(currentdeposit.currency)) == keccak256(bytes("ETH"))
        ) {
            uint256 refundRate = 100;
            uint256 refundAmount = currentdeposit
                .depositAmount
                .mul(refundRate)
                .div(100);

            if (block.timestamp < currentdeposit.expire) {
                revert("Withdraw: Deposit duration not yet passed");
            }

            currentdeposit.lastClaimTime = block.timestamp;
            currentdeposit.isWithdrawn = true;

            payable(account).transfer(refundAmount);
        } else {
            revert("Withdraw: Invalid deposit currency");
        }
    }

    /**
    @dev Withdraws the deposit made in USDC by the specified depositor and the corresponding rewards
    @param account The address of the depositor
    @param index The index of the deposit to withdraw
      Requirements:
        The caller must be a valid depositor.
        The deposit index must be within bounds.
        Only the depositor can withdraw their deposit and rewards.
        The deposit currency must be USDC.
        The deposit duration must have passed.
     */
    function withdrawUSDC(address account, uint256 index) external {
        require(isDepositor(account), "Withdraw: No Depositor");
        Deposit[] storage deposits = depositorMatrix[account];
        uint256 depositCount = deposits.length;
        require(depositCount > 0, "Withdraw: No Deposits Found");
        require(index < deposits.length, "Withdraw: Invalid deposit index");
        uint256 totalUSDCRefundAmount = 0;

        Deposit storage userdeposit = deposits[index];
        require(
            userdeposit.user == account,
            "Withdraw: Only depositor can withdraw rewards"
        );
        require(
            keccak256(bytes(userdeposit.currency)) == keccak256(bytes("USDC")),
            "Withdraw: Invalid currency"
        );

        if (userdeposit.depositAmount > 0 && !userdeposit.isWithdrawn) {
            uint256 refundRate = 100;
            uint256 refundAmount = userdeposit
                .depositAmount
                .mul(refundRate)
                .div(100);
            if (block.timestamp >= userdeposit.expire) {
                totalUSDCRefundAmount += refundAmount;
                userdeposit.lastClaimTime = block.timestamp;
                userdeposit.isWithdrawn = true;
            } else {
                revert("Withdraw: Deposit duration not yet passed");
            }
        }

        require(totalUSDCRefundAmount > 0, "Withdraw: No USDC Deposits Found");

        DepositToken.safeTransfer(account, totalUSDCRefundAmount);
    }

    /**

    @dev Allows a depositor to claim and delete all rewards in ETH for a specific deposit.
    @param depositor The address of the depositor.
    @param index The index of the deposit to claim rewards from.
    Requirements:
    The depositor must be registered as a depositor.
    The index must be valid for the depositor's deposits.
    The deposit currency must be ETH.
    The depositor must be the owner of the deposit.
    The deposit must have been withdrawn.
    The deposit must have been claimed at least once.
    There must be rewards available to claim.
    */
    function claimAndDeleteAllRewardsETH(
        address depositor,
        uint256 index
    ) external {
        require(
            isDepositor(depositor),
            "Claim And Delete All ETH: No Depositor"
        );

        Deposit[] storage deposits = depositorMatrix[depositor];

        uint256 totalReward = 0;

        require(
            index < deposits.length,
            "Claim And Delete All ETH: Invalid index"
        );

        Deposit storage currentuserdeposit = deposits[index];

        require(
            currentuserdeposit.lastClaimTime != 0,
            "Claim And Delete All ETH: Deposit has not been claimed yet"
        );
        require(index < deposits.length, "Withdraw: Invalid deposit index");
        require(
            keccak256(bytes(currentuserdeposit.currency)) ==
                keccak256(bytes("ETH")),
            "Claim And Delete All ETH: Invalid currency"
        );

        require(
            currentuserdeposit.user == depositor,
            "Claim And Delete All ETH: Only depositor can claim rewards"
        );

        require(
            currentuserdeposit.isWithdrawn,
            "Claim And Delete All ETH: ETH not withdrawn"
        );

        uint256 availableReward = calculateRewards(currentuserdeposit);
        totalReward += availableReward;

        require(
            totalReward > 0,
            "Claim And Delete All ETH: No rewards available"
        );

        FarmCoin.safeTransfer(depositor, totalReward);

        // Delete the deposit
        delete depositorMatrix[depositor][index];
    }

    /**
    @dev Allows a depositor to claim and delete a reward in USDC for a specific deposit.
    @param depositor The address of the depositor.
    @param index The index of the deposit to claim rewards from.
    Requirements:
    The depositor must be registered as a depositor.
    The index must be valid for the depositor's deposits.
    The deposit currency must be USDC.
    The depositor must be the owner of the deposit.
    The deposit must have been withdrawn.
    The deposit must have been claimed at least once.
    There must be rewards available to claim.
    */
    function claimAndDeleteRewardUSDC(
        address depositor,
        uint256 index
    ) external {
        require(
            isDepositor(depositor),
            "Claim and Delete Reward USDC: No Depositor"
        );
        Deposit[] storage deposits = depositorMatrix[depositor];
        require(
            index < deposits.length,
            "Claim and Delete Reward USDC: Invalid index"
        );

        Deposit storage rewarddeposit = deposits[index];
        require(
            rewarddeposit.lastClaimTime != 0,
            "Claim And Delete All ETH: Deposit has not been claimed yet"
        );
        require(index < deposits.length, "Withdraw: Invalid deposit index");
        require(
            keccak256(bytes(rewarddeposit.currency)) ==
                keccak256(bytes("USDC")),
            "Claim and Delete Reward USDC: Invalid currency"
        );
        require(
            rewarddeposit.user == depositor,
            "Claim and Delete Reward USDC: Only depositor can claim rewards"
        );
        require(
            rewarddeposit.isWithdrawn,
            "Claim and Delete Reward USDC: USDC not withdrawn"
        );

        uint256 availableReward = calculateRewards(rewarddeposit);

        require(
            availableReward > 0,
            "Claim and Delete Reward USDC: No rewards available"
        );

        FarmCoin.safeTransfer(depositor, availableReward);

        // Delete the deposit
        delete depositorMatrix[depositor][index];
    }

    /**
    @dev Returns the available rewards for the deposit at the given index for the caller.
    @param index The index of the deposit for which the rewards are to be calculated.
    @return The available rewards for the deposit at the given index.
    Requirements:
    The caller must be a depositor.
    */
    function getRewardByIndex(uint256 index) external view returns (uint256) {
        address account = msg.sender;

        require(isDepositor(account), "Claim By Index: No Depositor");

        Deposit[] storage deposits = depositorMatrix[account];

        Deposit storage depoistData = getDepositDataByIndex(deposits, index);

        uint256 availableReward = calculateRewards(depoistData);

        return availableReward;
    }

    /**
    @dev Internal function that checks whether an account has made any deposits or not.
    @param account The address to check.
    @return A boolean indicating whether the account has made any deposits or not.
    */
    function isDepositor(address account) internal view returns (bool) {
        return depositorMatrix[address(account)].length > 0;
    }

    /**
    @dev Retrieves the deposit data by index from an array of deposits.
    @param deposits An array of deposits belonging to a depositor.
    @param index The index of the deposit to retrieve.
    @return The deposit data at the specified index.
    @dev Requires that the depositor has made at least one deposit, and that the index is within the range of the array.
    */
    function getDepositDataByIndex(
        Deposit[] storage deposits,
        uint256 index
    ) private view returns (Deposit storage) {
        uint256 numberOfDeposits = deposits.length;

        require(numberOfDeposits > 0, "Get Index: No Depositor");

        require(index < numberOfDeposits, "Get Index: Index overflow");

        return deposits[index];
    }

    /**
    @dev This function returns all the deposit data for the calling depositor.
    @return An array of Deposit struct, each containing depositTime, depositAmount, expire, index, lastClaimTime, currency, user, and isWithdrawn fields.
    The struct array contains all active and past deposits of the depositor.
    If there are no active deposits, an empty Deposit array is returned.
    */
    function getallDepositData() public view returns (Deposit[] memory) {
        address depositor = msg.sender;
        Deposit[] storage deposits = depositorMatrix[depositor];
        uint256 depositCount = deposits.length;

        Deposit[] memory result = new Deposit[](depositCount);
        uint256 resultIndex = 0;

        for (uint256 i = 0; i < depositCount; i++) {
            Deposit storage datadeposit = deposits[i];

            if (datadeposit.depositAmount > 0) {
                result[resultIndex] = Deposit(
                    datadeposit.depositTime,
                    datadeposit.depositAmount,
                    datadeposit.expire,
                    i,
                    datadeposit.lastClaimTime,
                    datadeposit.currency,
                    datadeposit.user,
                    datadeposit.isWithdrawn
                );
                resultIndex++;
            }
        }

        if (resultIndex == 0) {
            // no staking right now
            return new Deposit[](0);
        }

        Deposit[] memory finalResult = new Deposit[](resultIndex);
        for (uint256 i = 0; i < resultIndex; i++) {
            finalResult[i] = result[i];
        }

        return finalResult;
    }

    /**
    @dev Calculates the available reward for a deposit by taking the difference between the current block timestamp and the last time the reward was claimed,
    then multiplying it by the reward per second.
    @param _depoistData The deposit data for which to calculate the available reward.
    @return The available reward for the deposit.
    */
    function calculateRewards(
        Deposit storage _depoistData
    ) internal view returns (uint256) {
        uint256 passedTime = block.timestamp.sub(_depoistData.lastClaimTime);
        return _depoistData.rewardPerSecond.mul(passedTime);
    }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

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
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
     * @dev Sets `value` as th xe allowance of `spender` over ``owner``'s tokens,
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

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "./IERC20.sol";

interface IFarmCoin is IERC20 {
  function mint(address account_, uint256 amount_) external;

  function burn(uint256 amount) external;

  function burnFrom(address account_, uint256 amount_) external;
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

interface IFarmCoinAuthority {
    /* ========== EVENTS ========== */
    
    event GovernorPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event GuardianPushed(address indexed from, address indexed to, bool _effectiveImmediately);    
    event PolicyPushed(address indexed from, address indexed to, bool _effectiveImmediately);    
    event VaultPushed(address indexed from, address indexed to, bool _effectiveImmediately);    

    event GovernorPulled(address indexed from, address indexed to);
    event GuardianPulled(address indexed from, address indexed to);
    event PolicyPulled(address indexed from, address indexed to);
    event VaultPulled(address indexed from, address indexed to);

    /* ========== VIEW ========== */
    
    function governor() external view returns (address);
    function guardian() external view returns (address);
    function policy() external view returns (address);
    function vault() external view returns (address);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "./SafeMath.sol";

library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.4;

import {IERC20} from "../interfaces/IERC20.sol";

/// @notice Safe IERC20 and ETH transfer library that safely handles missing return values.
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/libraries/TransferHelper.sol)
/// Taken from Solmate
library SafeERC20 {
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
    }

    function safeApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.approve.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
    }

    function safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}(new bytes(0));

        require(success, "ETH_TRANSFER_FAILED");
    }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;


// TODO(zx): Replace all instances of SafeMath with OZ implementation
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    // Only used in the  BondingCalculator.sol
    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }

}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

import "../libraries/SafeMath.sol";

import "../interfaces/IERC20.sol";


abstract contract ERC20 is IERC20 {

    using SafeMath for uint256;

    // TODO comment actual hash value.
    bytes32 constant private ERC20TOKEN_ERC1820_INTERFACE_ID = keccak256( "ERC20Token" );
    
    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    string internal _name;
    
    string internal _symbol;
    
    uint8 internal immutable _decimals;

    constructor (string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

  function _beforeTokenTransfer( address from_, address to_, uint256 amount_ ) internal virtual { }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/IERC20Permit.sol";
import "./ERC20.sol";
import "../cryptography/EIP712.sol";
import "../cryptography/ECDSA.sol";
import "../libraries/Counters.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.4;

import "../interfaces/IFarmCoinAuthority.sol";

abstract contract FarmCoinAccessControlled {

    /* ========== EVENTS ========== */

    event AuthorityUpdated(IFarmCoinAuthority indexed authority);

    string UNAUTHORIZED = "UNAUTHORIZED"; // save gas

    /* ========== STATE VARIABLES ========== */

    IFarmCoinAuthority public authority;


    /* ========== Constructor ========== */

    constructor(IFarmCoinAuthority _authority) {
        authority = _authority;
        emit AuthorityUpdated(_authority);
    }
    

    /* ========== MODIFIERS ========== */
    
    modifier onlyGovernor() {
        require(msg.sender == authority.governor(), UNAUTHORIZED);
        _;
    }
    
    modifier onlyGuardian() {
        require(msg.sender == authority.guardian(), UNAUTHORIZED);
        _;
    }
    
    modifier onlyPolicy() {
        require(msg.sender == authority.policy(), UNAUTHORIZED);
        _;
    }

    modifier onlyVault() {
        require(msg.sender == authority.vault(), UNAUTHORIZED);
        _;
    }
    
    /* ========== GOV ONLY ========== */
    
    function setAuthority(IFarmCoinAuthority _newAuthority) external onlyGovernor {
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }
}