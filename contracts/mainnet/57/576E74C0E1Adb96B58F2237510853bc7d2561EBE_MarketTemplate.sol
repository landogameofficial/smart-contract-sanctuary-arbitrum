// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

pragma solidity 0.8.12;

/**
 * @author InsureDAO
 * @title LP Token Contract for Pools
 * SPDX-License-Identifier: GPL-3.0
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract InsureDAOERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    bool tokenInitialized;
    string private _name = "InsureDAO LP Token";
    string private _symbol = "iLP";
    uint8 private _decimals = 18;

    function initializeToken(string memory name_, string memory symbol_, uint8 decimals_) internal {
        /***
         *@notice initialize token. Only called internally.
         *
         */
        require(!tokenInitialized, "Token is already initialized");
        tokenInitialized = true;
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() external view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() external view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) external virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) external view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool) {
        if (amount != 0) {
            uint256 currentAllowance = _allowances[sender][msg.sender];
            if (currentAllowance != type(uint256).max) {
                require(currentAllowance >= amount, "Transfer amount > allowance");
                unchecked {
                    _approve(sender, msg.sender, currentAllowance - amount);
                }
            }

            _transfer(sender, recipient, amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        if (addedValue != 0) {
            _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        }
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        if (subtractedValue != 0) {
            uint256 currentAllowance = _allowances[msg.sender][spender];
            require(currentAllowance >= subtractedValue, "Decreased allowance below zero");

            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        if (amount != 0) {
            require(sender != address(0), "Transfer from the zero address");
            require(recipient != address(0), "Transfer to the zero address");

            _beforeTokenTransfer(sender, recipient, amount);

            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "Transfer amount exceeds balance");

            unchecked {
                _balances[sender] = senderBalance - amount;
            }

            _balances[recipient] += amount;

            emit Transfer(sender, recipient, amount);

            _afterTokenTransfer(sender, recipient, amount);
        }
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        if (amount != 0) {
            require(account != address(0), "Mint to the zero address");

            _beforeTokenTransfer(address(0), account, amount);

            _totalSupply += amount;
            _balances[account] += amount;
            emit Transfer(address(0), account, amount);

            _afterTokenTransfer(address(0), account, amount);
        }
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        if (amount != 0) {
            require(account != address(0), "Burn from the zero address");

            _beforeTokenTransfer(account, address(0), amount);

            uint256 accountBalance = _balances[account];
            require(accountBalance >= amount, "Burn amount exceeds balance");
            unchecked {
                _balances[account] = accountBalance - amount;
            }

            _totalSupply -= amount;

            emit Transfer(account, address(0), amount);

            _afterTokenTransfer(account, address(0), amount);
        }
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

pragma solidity 0.8.12;

/**
 * @author InsureDAO
 * @title Market Template Contract
 * SPDX-License-Identifier: GPL-3.0
 */

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./InsureDAOERC20.sol";
import "../interfaces/IMarketTemplate.sol";
import "../interfaces/IUniversalPool.sol";
import "../interfaces/IParameters.sol";
import "../interfaces/IVault.sol";
import "../interfaces/IRegistry.sol";
import "../interfaces/IIndexTemplate.sol";

contract MarketTemplate is InsureDAOERC20, IMarketTemplate, IUniversalPool {
    event Deposit(address indexed depositor, uint256 amount, uint256 mint);
    event WithdrawRequested(address indexed withdrawer, uint256 amount, uint256 unlockTime);
    event Withdraw(address indexed withdrawer, uint256 amount, uint256 retVal);
    event Unlocked(uint256 indexed id, uint256 amount);
    event Insured(
        uint256 indexed id,
        uint256 amount,
        bytes32 target,
        uint256 startTime,
        uint256 endTime,
        address insured,
        address agent,
        uint256 premium
    );
    event Redeemed(uint256 indexed id, address insured, bytes32 target, uint256 amount, uint256 payout);
    event CoverApplied(
        uint256 pending,
        uint256 payoutNumerator,
        uint256 payoutDenominator,
        uint256 incidentTimestamp,
        bytes32 merkleRoot,
        string rawdata,
        string memo
    );
    event BountyPaid(uint256 amount, address contributor, uint256[] ids);

    event CreditIncrease(address indexed depositor, uint256 credit);
    event CreditDecrease(address indexed withdrawer, uint256 credit);
    event MarketStatusChanged(MarketStatus statusValue);
    event Paused(bool paused);
    event SetOpenDeposit(bool openDeposit);
    event MetadataChanged(string metadata);

    /// @notice Pool setting
    bool public initialized;
    bool public paused;
    bool public openDeposit;
    string public metadata;

    /// @notice External contract call addresses
    IParameters public parameters;
    IRegistry public registry;
    IVault public vault;

    /// @notice Market variables
    uint256 public attributionDebt; //market's attribution for indices
    uint256 public lockedAmount;
    uint256 public totalCredit;
    uint256 public rewardPerCredit; //Times MAGIC_SCALE_1E6. To avoid reward decimal truncation *See explanation below.
    uint256 public pendingEnd; //pending time when paying out

    /// @notice Market variables for margin account
    struct IndexInfo {
        uint256 credit; //How many credit (equal to liquidity) the index has allocated
        uint256 rewardDebt; // Reward debt. *See explanation below.
        uint256 slot; //index number within indexList. incremented by 1.
    }

    mapping(address => IndexInfo) public indices;
    address[] public indexList;

    ///@notice Market status transition management
    MarketStatus public marketStatus;

    ///@notice user's withdrawal status management
    struct Withdrawal {
        uint256 timestamp;
        uint256 amount;
    }
    mapping(address => Withdrawal) public withdrawalReq;

    ///@notice insurance status management
    struct Insurance {
        uint256 id; //each insuance has their own id
        uint48 startTime; //timestamp of starttime
        uint48 endTime; //timestamp of endtime
        uint256 amount; //insured amount
        bytes32 target; //target id in bytes32
        address insured; //the address holds the right to get insured
        address agent; //address have control. can be different from insured.
        bool status; //true if insurance is not expired or redeemed
    }
    mapping(uint256 => Insurance) public insurances;
    uint256 public allInsuranceCount;

    ///@notice incident status management
    struct Incident {
        uint256 payoutNumerator;
        uint256 payoutDenominator;
        uint256 incidentTimestamp;
        bytes32 merkleRoot;
    }
    Incident public incident;
    uint256 private constant MAGIC_SCALE_1E6 = 1e6; //internal multiplication scale 1e6 to reduce decimal truncation

    modifier onlyOwner() {
        require(msg.sender == parameters.getOwner(), "Caller is not allowed to operate");
        _;
    }

    constructor() {
        initialized = true;
    }

    /**
     * Initialize interaction
     */

    /**
     * @notice Initialize market
     * This function registers market conditions.
     * references[0] = target governance token address
     * references[1] = underlying token address
     * references[2] = registry
     * references[3] = parameter
     * conditions[0] = minimim deposit amount defined by the factory
     * conditions[1] = initial deposit amount defined by the creator
     * @param _metaData arbitrary string to store market information
     * @param _conditions array of conditions
     * @param _references array of references
     */
    function initialize(
        address _depositor,
        string calldata _metaData,
        uint256[] calldata _conditions,
        address[] calldata _references
    ) external {
        require(
            !initialized &&
                bytes(_metaData).length != 0 &&
                _references[0] != address(0) &&
                _references[1] != address(0) &&
                _references[2] != address(0) &&
                _references[3] != address(0) &&
                _conditions[0] <= _conditions[1],
            "INITIALIZATION_BAD_CONDITIONS"
        );
        initialized = true;
        openDeposit = true;

        string memory _name = "InsureDAO Insurance LP";
        string memory _symbol = "iNsure";

        try this.getTokenMetadata(_references[0]) returns (string memory name_, string memory symbol_) {
            _name = name_;
            _symbol = symbol_;
        } catch {}

        uint8 _decimals = IERC20Metadata(_references[1]).decimals();

        initializeToken(_name, _symbol, _decimals);

        registry = IRegistry(_references[2]);
        parameters = IParameters(_references[3]);
        vault = IVault(parameters.getVault(_references[1]));

        metadata = _metaData;

        marketStatus = MarketStatus.Trading;

        if (_conditions[1] != 0) {
            _depositFrom(_conditions[1], _depositor);
        }
    }

    function getTokenMetadata(address _token) external view returns (string memory _name, string memory _symbol) {
        _name = string(abi.encodePacked("InsureDAO ", IERC20Metadata(_token).name(), " Insurance LP"));
        _symbol = string(abi.encodePacked("i", IERC20Metadata(_token).symbol()));
    }

    /**
     * @notice A liquidity provider supplies tokens to the market and receives iTokens
     * @param _amount amount of tokens to deposit
     * @return _mintAmount the amount of iTokens minted
     */
    function deposit(uint256 _amount) external returns (uint256 _mintAmount) {
        require(openDeposit == true || msg.sender == parameters.getOwner(), "Deposit Prohibit");
        _mintAmount = _depositFrom(_amount, msg.sender);
    }

    /**
     * @notice Internal deposit function that allows third party to deposit
     * @param _amount amount of tokens to deposit
     * @param _from deposit beneficiary's address
     * @return _mintAmount the amount of iTokens minted from the transaction
     */
    function _depositFrom(uint256 _amount, address _from) internal returns (uint256 _mintAmount) {
        require(_amount != 0, "ERROR: DEPOSIT_ZERO");
        require(marketStatus == MarketStatus.Trading, "ERROR: Payingout");
        require(!paused, "ERROR: PAUSED");

        _mintAmount = worth(_amount);

        vault.addValue(_amount, _from, address(this));

        emit Deposit(_from, _amount, _mintAmount);

        //mint iToken
        _mint(_from, _mintAmount);
    }

    /**
     * @notice A liquidity provider request withdrawal of collateral
     * @param _amount amount of iTokens to burn
     */
    function requestWithdraw(uint256 _amount) external {
        require(_amount != 0, "ERROR: REQUEST_ZERO");
        require(balanceOf(msg.sender) >= _amount, "ERROR: REQUEST_EXCEED_BALANCE");

        uint256 _unlocksAt = block.timestamp + parameters.getRequestDuration(address(this));

        withdrawalReq[msg.sender].timestamp = _unlocksAt;
        withdrawalReq[msg.sender].amount = _amount;
        emit WithdrawRequested(msg.sender, _amount, _unlocksAt);
    }

    /**
     * @notice A liquidity provider burns iTokens and receives collateral from the Market
     * @param _amount amount of iTokens to burn
     * @return _retVal the amount underlying tokens returned
     */
    function withdraw(uint256 _amount) external returns (uint256 _retVal) {
        require(marketStatus == MarketStatus.Trading, "ERROR: WITHDRAWAL_MARKET_PENDING");

        Withdrawal memory request = withdrawalReq[msg.sender];

        require(request.timestamp < block.timestamp, "ERROR: WITHDRAWAL_QUEUE");
        require(
            request.timestamp + parameters.getWithdrawableDuration(address(this)) > block.timestamp,
            "WITHDRAWAL_NO_ACTIVE_REQUEST"
        );
        require(request.amount >= _amount, "WITHDRAWAL_EXCEEDED_REQUEST");
        require(_amount != 0, "ERROR: WITHDRAWAL_ZERO");

        uint256 _supply = totalSupply();
        require(_supply != 0, "ERROR: NO_AVAILABLE_LIQUIDITY");

        uint256 _liquidity = originalLiquidity();
        _retVal = (_amount * _liquidity) / _supply;

        require(_retVal <= _availableBalance(), "WITHDRAW_INSUFFICIENT_LIQUIDITY");

        //reduce requested amount
        unchecked {
            withdrawalReq[msg.sender].amount -= _amount;
        }

        //Burn iToken
        _burn(msg.sender, _amount);

        //Withdraw liquidity
        vault.withdrawValue(_retVal, msg.sender);

        emit Withdraw(msg.sender, _amount, _retVal);
    }

    /**
     * @notice Unlocks an array of insurances
     * @param _ids array of ids to unlock
     */
    function unlockBatch(uint256[] calldata _ids) external {
        require(marketStatus == MarketStatus.Trading, "ERROR: UNLOCK_BAD_COINDITIONS");
        uint256 idsLength = _ids.length;
        for (uint256 i; i < idsLength; ) {
            _unlock(_ids[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @param _id id of the insurance policy to unlock liquidity
     */
    function unlock(uint256 _id) external {
        require(marketStatus == MarketStatus.Trading, "ERROR: UNLOCK_BAD_COINDITIONS");
        _unlock(_id);
    }

    /**
     * @notice Unlock funds locked in the expired insurance (for internal usage)
     * @param _id id of the insurance policy to unlock liquidity
     */
    function _unlock(uint256 _id) internal {
        require(
            insurances[_id].status && insurances[_id].endTime + parameters.getUnlockGracePeriod(address(this)) < block.timestamp,
            "ERROR: UNLOCK_BAD_COINDITIONS"
        );
        insurances[_id].status = false;

        lockedAmount = lockedAmount - insurances[_id].amount;

        emit Unlocked(_id, insurances[_id].amount);
    }

    /**
     * Index interactions
     */
    function getIndicies() external view returns (address[] memory) {
        return indexList;
    }

    function registerIndex() external {
        require(IRegistry(registry).isListed(msg.sender), "Not an Official Pool");
        require(indices[msg.sender].slot == 0, "Already Registered");

        uint256 _nextArrayIndex = indexList.length;
        require(_nextArrayIndex <= parameters.getMaxList(address(this)), "Exceed max list");

        indexList.push(msg.sender);
        indices[msg.sender].slot = _nextArrayIndex + 1;
    }

    /**
     * @notice
     * @dev called by index pool
     */
    function unregisterIndex() external {
        require(marketStatus == MarketStatus.Trading, "Market is not Trading status");
        IndexInfo storage _index = indices[msg.sender];
        require(_index.slot != 0, "Not Registered");
        require(_index.credit == 0, "Credits allocated");

        _index.rewardDebt = 0;

        _removeIndex(_index);
    }

    function _removeIndex(IndexInfo storage _index) internal {
        //Delete old index
        uint256 _slot = _index.slot;
        _index.slot = 0;

        uint256 _latestArrayIndex = indexList.length - 1;

        //Shift array
        if (_latestArrayIndex != 0 && _slot - 1 != _latestArrayIndex) {
            // [A, B, C] => [C, B, C]
            address _latestAddress = indexList[_latestArrayIndex];

            indices[_latestAddress].slot = _slot;
            indexList[_slot - 1] = _latestAddress;
        }

        indexList.pop();
    }

    /**
     * @notice Allocate credit from an index. Allocated credits are deemed as equivalent liquidity as real token deposits.
     * @param _credit credit (liquidity amount) to be added to this market
     * @return _pending pending preium for the caller index
     */

    function allocateCredit(uint256 _credit) external returns (uint256 _pending) {
        IndexInfo storage _index = indices[msg.sender];
        require(_index.slot != 0, "ALLOCATE_CREDIT_BAD_CONDITIONS");

        uint256 _rewardPerCredit = rewardPerCredit;

        if (_index.credit != 0) {
            _pending = _sub((_index.credit * _rewardPerCredit) / MAGIC_SCALE_1E6, _index.rewardDebt);
            if (_pending != 0) {
                vault.transferAttribution(_pending, msg.sender);
                attributionDebt -= _pending;
            }
        }
        if (_credit != 0) {
            totalCredit += _credit;
            _index.credit += _credit;
            emit CreditIncrease(msg.sender, _credit);
        }
        _index.rewardDebt = (_index.credit * _rewardPerCredit) / MAGIC_SCALE_1E6;
    }

    /**
     * @notice An index withdraw credit and earn accrued premium
     * @param _credit credit (liquidity amount) to be withdrawn from this market
     * @return _pending pending preium for the caller index
     * @dev called from index pool
     */
    function withdrawCredit(uint256 _credit) external returns (uint256) {
        require(marketStatus == MarketStatus.Trading, "MARKET_IS_NOT_IN_TRADING_STATUS");

        return _withdrawCredit(_credit, msg.sender);
    }

    function _withdrawCredit(uint256 _credit, address _indexAddress) internal returns (uint256) {
        IndexInfo storage _index = indices[_indexAddress];

        require(_index.slot != 0, "not registered");
        require(_index.credit >= _credit, "exceed credit");
        require(_credit <= _availableBalance(), "exceed available credit");

        uint256 _rewardPerCredit = rewardPerCredit;

        //calculate acrrued premium
        uint256 _pending = _sub((_index.credit * _rewardPerCredit) / MAGIC_SCALE_1E6, _index.rewardDebt);

        //Withdraw liquidity
        if (_credit != 0) {
            totalCredit -= _credit;
            unchecked {
                _index.credit -= _credit;
            }
            emit CreditDecrease(_indexAddress, _credit);
        }

        //withdraw acrrued premium
        if (_pending != 0) {
            vault.transferAttribution(_pending, _indexAddress);
            attributionDebt -= _pending;
        }

        _index.rewardDebt = (_index.credit * _rewardPerCredit) / MAGIC_SCALE_1E6;

        return _pending;
    }

    /**
     * Insurance interactions
     */

    /**
     * @notice Get insured for the specified amount for specified span
     * @param _amount target amount to get covered
     * @param _maxCost maximum cost to pay for the premium. revert if the premium is higher
     * @param _span length to get covered(e.g. 7 days)
     * @param _target Insurance type id. eg Smart Contract Hacking Cover = 0x00..00
     * @return id of the insurance policy
     */
    function insure(uint256 _amount, uint256 _maxCost, uint256 _span, bytes32 _target, address _for, address _agent)
        external
        returns (uint256)
    {
        require(!paused, "ERROR: INSURE_MARKET_PAUSED");
        require(_for != address(0), "ERROR: ZERO_ADDRESS");
        require(_agent != address(0), "ERROR: ZERO_ADDRESS");
        require(marketStatus == MarketStatus.Trading, "ERROR: INSURE_MARKET_PENDING");
        require(_amount <= _availableBalance(), "INSURE_EXCEEDED_AVAIL_BALANCE");

        require(_span <= parameters.getMaxInsureSpan(address(this)), "ERROR: INSURE_EXCEEDED_MAX_SPAN");
        require(parameters.getMinInsureSpan(address(this)) <= _span, "ERROR: INSURE_SPAN_BELOW_MIN");

        //Distribute premium and fee
        uint256 _premium = getPremium(_amount, _span);
        require(_premium <= _maxCost, "ERROR: INSURE_EXCEEDED_MAX_COST");

        uint256 _endTime = _span + block.timestamp;
        uint256 _fee = parameters.getFeeRate(address(this));

        //current liquidity
        uint256 _liquidity = totalLiquidity();
        uint256 _totalCredit = totalCredit;

        //accrue premium/fee
        uint256[2] memory _newAttribution = vault.addValueBatch(
            _premium,
            msg.sender,
            [address(this), parameters.getOwner()],
            [MAGIC_SCALE_1E6 - _fee, _fee]
        );

        //Lock covered amount
        uint256 _id = allInsuranceCount;
        lockedAmount += _amount;
        insurances[_id] = Insurance(_id, (uint48)(block.timestamp), (uint48)(_endTime), _amount, _target, _for, _agent, true);

        unchecked {
            ++allInsuranceCount;
        }

        //Calculate liquidity for index
        if (_totalCredit != 0 && _liquidity != 0) {
            uint256 _attributionForIndex = (_newAttribution[0] * _totalCredit) / _liquidity;
            attributionDebt += _attributionForIndex;
            rewardPerCredit += ((_attributionForIndex * MAGIC_SCALE_1E6) / _totalCredit);
        }

        emit Insured(_id, _amount, _target, block.timestamp, _endTime, _for, _agent, _premium);

        return _id;
    }

    /**
     * @notice Redeem an insurance policy
     * @param _id the id of the insurance policy
     * @param _merkleProof merkle proof (similar to "verify" function of MerkleProof.sol of OpenZeppelin
     * Ref: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol
     */
    function redeem(uint256 _id, uint256 _loss, bytes32[] calldata _merkleProof) external {
        require(marketStatus == MarketStatus.Payingout, "ERROR: NO_APPLICABLE_INCIDENT");

        Insurance memory _insurance = insurances[_id];
        require(_insurance.status, "ERROR: INSURANCE_NOT_ACTIVE");
        require(_insurance.insured == msg.sender || _insurance.agent == msg.sender, "ERROR: NOT_YOUR_INSURANCE");
        uint48 _incidentTimestamp = (uint48)(incident.incidentTimestamp);
        require(
            _insurance.startTime <= _incidentTimestamp && _insurance.endTime >= _incidentTimestamp,
            "ERROR: INSURANCE_NOT_APPLICABLE"
        );

        bytes32 _targets = incident.merkleRoot;
        require(
            MerkleProof.verify(
                _merkleProof,
                _targets,
                keccak256(abi.encodePacked(_insurance.target, _insurance.insured, _loss))
            ) || MerkleProof.verify(_merkleProof, _targets, keccak256(abi.encodePacked(_insurance.target, address(0), _loss))),
            "ERROR: INSURANCE_EXEMPTED"
        );
        insurances[_id].status = false;
        lockedAmount -= _insurance.amount;

        _loss = (_loss * incident.payoutNumerator) / incident.payoutDenominator;
        uint256 _payoutAmount = _insurance.amount > _loss ? _loss : _insurance.amount;

        vault.borrowValue(_payoutAmount, _insurance.insured);

        emit Redeemed(_id, _insurance.insured, _insurance.target, _insurance.amount, _payoutAmount);
    }

    /**
     * @notice Get how much premium for the specified amount and span
     * @param _amount amount to get insured
     * @param _span span to get covered
     */
    function getPremium(uint256 _amount, uint256 _span) public view returns (uint256) {
        return parameters.getPremium(_amount, _span, totalLiquidity(), lockedAmount, address(this));
    }

    /**
     * Reporting interactions
     */

    /**
     * @notice Decision to make a payout
     * @param _pending length of time to allow policyholders to redeem their policy
     * @param _payoutNumerator Numerator of the payout *See below
     * @param _payoutDenominator Denominator of the payout *See below
     * @param _incidentTimestamp Unixtimestamp of the incident
     * @param _merkleRoot Merkle root of the payout id list
     * @param _rawdata raw data before the data set is coverted to merkle tree (to be emiｔted within event)
     * @param _memo additional memo for the payout report (to be emmited within event)
     * payout ratio is determined by numerator/denominator (e.g. 50/100 = 50% payout
     */
    function applyCover(
        uint256 _pending,
        uint256 _payoutNumerator,
        uint256 _payoutDenominator,
        uint256 _incidentTimestamp,
        bytes32 _merkleRoot,
        string calldata _rawdata,
        string calldata _memo
    ) external onlyOwner {
        require(_incidentTimestamp < block.timestamp, "ERROR: INCIDENT_DATE");

        incident.payoutNumerator = _payoutNumerator;
        incident.payoutDenominator = _payoutDenominator;
        incident.incidentTimestamp = _incidentTimestamp;
        incident.merkleRoot = _merkleRoot;
        marketStatus = MarketStatus.Payingout;
        pendingEnd = block.timestamp + _pending;

        uint256 _indexLength = indexList.length;
        for (uint256 i; i < _indexLength; ) {
            if (indices[indexList[i]].credit != 0) {
                IIndexTemplate(indexList[i]).lock();
            }
            unchecked {
                ++i;
            }
        }
        emit CoverApplied(_pending, _payoutNumerator, _payoutDenominator, _incidentTimestamp, _merkleRoot, _rawdata, _memo);
        emit MarketStatusChanged(MarketStatus.Payingout);
    }

    function applyBounty(uint256 _amount, address _contributor, uint256[] calldata _ids) external onlyOwner {
        require(marketStatus == MarketStatus.Trading, "ERROR: NOT_TRADING_STATUS");

        //borrow value just like redeem()
        vault.borrowValue(_amount, _contributor);

        _liquidation();

        //unlock policies
        uint256 totalAmountToUnlock;
        for (uint256 i; i < _ids.length; ++i) {
            uint256 _id = _ids[i];
            require(insurances[_id].status);

            uint256 unlockAmount = insurances[_id].amount;

            insurances[_id].status = false;
            totalAmountToUnlock += unlockAmount;
            emit Unlocked(_id, unlockAmount);
        }
        lockedAmount -= totalAmountToUnlock;

        emit BountyPaid(_amount, _contributor, _ids);
    }

    /**
     * @notice Anyone can resume the market after a pending period ends
     */
    function resume() external {
        require(marketStatus == MarketStatus.Payingout && block.timestamp > pendingEnd, "ERROR: UNABLE_TO_RESUME");

        _liquidation();

        marketStatus = MarketStatus.Trading;

        uint256 _indexLength = indexList.length;
        for (uint256 i; i < _indexLength; ) {
            IIndexTemplate(indexList[i]).adjustAlloc();
            unchecked {
                ++i;
            }
        }

        emit MarketStatusChanged(MarketStatus.Trading);
    }

    function _liquidation() internal {
        uint256 _totalLiquidity = totalLiquidity();
        uint256 _totalCredit = totalCredit;
        uint256 _debt = vault.debts(address(this));
        uint256 _deductionFromIndex;

        if (_totalLiquidity != 0) {
            _deductionFromIndex = (_debt * _totalCredit) / _totalLiquidity;
        }

        uint256 _actualDeduction;
        uint256 _indexLength = indexList.length;
        for (uint256 i; i < _indexLength; ) {
            address _index = indexList[i];
            uint256 _credit = indices[_index].credit;

            if (_credit != 0) {
                uint256 _shareOfIndex = (_credit * MAGIC_SCALE_1E6) / _totalCredit;
                uint256 _redeemAmount = (_deductionFromIndex * _shareOfIndex) / MAGIC_SCALE_1E6;
                _actualDeduction += IIndexTemplate(_index).compensate(_redeemAmount);
            }
            unchecked {
                ++i;
            }
        }

        uint256 _deductionFromMarket = _debt - _deductionFromIndex;
        uint256 _shortage = _deductionFromIndex - _actualDeduction;

        if (_deductionFromMarket != 0) {
            vault.offsetDebt(_deductionFromMarket, address(this));
        }

        vault.transferDebt(_shortage);
    }

    /**
     * Utilities
     */

    /**
     * @notice Get the exchange rate of LP tokens against underlying asset(scaled by MAGIC_SCALE_1E6)
     * @return The value against the underlying tokens balance.
     */
    function rate() external view returns (uint256) {
        uint256 _supply = totalSupply();
        uint256 _originalLiquidity = originalLiquidity();

        if (_originalLiquidity != 0 && _supply != 0) {
            return (_originalLiquidity * MAGIC_SCALE_1E6) / _supply;
        } else {
            return 0;
        }
    }

    /**
     * @notice Get the underlying balance of the `owner`
     * @param _owner the target address to look up value
     * @return The balance of underlying tokens for the specified address
     */
    function valueOfUnderlying(address _owner) external view returns (uint256) {
        uint256 _balance = balanceOf(_owner);
        uint256 _totalSupply = totalSupply();

        if (_balance != 0 || _totalSupply != 0) {
            return (_balance * originalLiquidity()) / _totalSupply;
        }
    }

    /**
     * @notice Get the accrued value for an index
     * @param _index the address of index
     * @return The pending premium for the specified index
     */
    function pendingPremium(address _index) external view returns (uint256) {
        uint256 _credit = indices[_index].credit;
        if (_credit != 0) {
            return _sub((_credit * rewardPerCredit) / MAGIC_SCALE_1E6, indices[_index].rewardDebt);
        }
    }

    /**
     * @notice Get token number for the specified underlying value
     * @param _value the amount of the underlying
     * @return _amount the number of the iTokens corresponding to _value
     */
    function worth(uint256 _value) public view returns (uint256 _amount) {
        uint256 _supply = totalSupply();
        uint256 _originalLiquidity = originalLiquidity();
        if (_supply != 0 && _originalLiquidity != 0) {
            _amount = (_value * _supply) / _originalLiquidity;
        } else if (_supply != 0 && _originalLiquidity == 0) {
            _amount = _value * _supply;
        } else {
            _amount = _value;
        }
    }

    /**
     * @notice Get allocated credit & available balance
     * @param _index address of an index
     * @return The balance of credit allocated by the specified index
     */
    function pairValues(address _index) external view returns (uint256, uint256) {
        return (indices[_index].credit, _availableBalance());
    }

    /**
     * @notice Returns the amount of underlying tokens available for withdrawals
     * @return available liquidity of this market
     */
    function availableBalance() external view returns (uint256) {
        return _availableBalance();
    }

    function _availableBalance() internal view returns (uint256) {
        uint256 _totalLiquidity = totalLiquidity();
        if (_totalLiquidity != 0) {
            return _totalLiquidity - lockedAmount;
        }
    }

    /**
     * @notice Returns the utilization rate for this market. Scaled by 1e6 (100% = 1e6)
     * @return utilization rate
     */
    function utilizationRate() external view returns (uint256) {
        uint256 _lockedAmount = lockedAmount;
        uint256 _totalLiquidity = totalLiquidity();

        if (_lockedAmount != 0 && _totalLiquidity != 0) {
            return (_lockedAmount * MAGIC_SCALE_1E6) / _totalLiquidity;
        }
    }

    /**
     * @notice Market's Total Liquidity (total insurable amount)
     * @return total liquidity of this market
     */
    function totalLiquidity() public view returns (uint256) {
        return originalLiquidity() + totalCredit;
    }

    /**
     * @notice Market's Pure Liquidity
     * @return total liquidity of this market
     */
    function originalLiquidity() public view returns (uint256) {
        return vault.underlyingValue(address(this)) - vault.attributionValue(attributionDebt);
    }

    /**
     * Admin functions
     */

    /**
     * @notice Used for changing settlementFeeRecipient
     * @param _state true to set paused and vice versa
     */
    function setPaused(bool _state) external onlyOwner {
        if (paused != _state) {
            paused = _state;
            emit Paused(_state);
        }
    }

    function setOpenDeposit(bool _state) external onlyOwner {
        if (openDeposit != _state) {
            openDeposit = _state;
            emit SetOpenDeposit(_state);
        }
    }

    /**
     * @notice Change metadata string
     * @param _metadata new metadata string
     */
    function changeMetadata(string calldata _metadata) external onlyOwner {
        metadata = _metadata;
        emit MetadataChanged(_metadata);
    }

    /**
     * Internal functions
     */

    /**
     * @notice Internal function to offset withdraw request and latest balance
     * @param from the account who send
     * @param to a
     * @param amount the amount of tokens to offset
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from != address(0)) {
            uint256 reqAmount = withdrawalReq[from].amount;
            if (reqAmount != 0) {
                uint256 _after = balanceOf(from) - amount;
                if (_after < reqAmount) {
                    withdrawalReq[from].amount = _after;
                }
            }
        }
    }

    /**
     * @notice Internal function for safe division
     */
    function _divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        uint256 c = a / b;
        if (a % b != 0) ++c;
        return c;
    }

    /**
     * @notice Internal function for overflow free subtraction
     */
    function _sub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a >= b) {
            unchecked {
                return a - b;
            }
        }
    }
}

pragma solidity 0.8.12;

interface IIndexTemplate {
    function compensate(uint256) external returns (uint256 _compensated);

    function lock() external;

    function resume() external;

    function adjustAlloc() external;

    //onlyOwner
    function setLeverage(uint256 _target) external;

    function set(
        uint256 _indexA,
        address _pool,
        uint256 _allocPoint
    ) external;
}

pragma solidity 0.8.12;

interface IMarketTemplate {
    enum MarketStatus {
        Trading,
        Payingout
    }

    function deposit(uint256 _amount) external returns (uint256 _mintAmount);

    function requestWithdraw(uint256 _amount) external;

    function withdraw(uint256 _amount) external returns (uint256 _retVal);

    function insure(
        uint256,
        uint256,
        uint256,
        bytes32,
        address,
        address
    ) external returns (uint256);

    function redeem(
        uint256 _id,
        uint256 _loss,
        bytes32[] calldata _merkleProof
    ) external;

    function getPremium(uint256 _amount, uint256 _span) external view returns (uint256);

    function unlockBatch(uint256[] calldata _ids) external;

    function unlock(uint256 _id) external;

    function registerIndex() external;

    function unregisterIndex() external;

    function allocateCredit(uint256 _credit) external returns (uint256 _mintAmount);

    function pairValues(address _index) external view returns (uint256, uint256);

    function resume() external;

    function rate() external view returns (uint256);

    function withdrawCredit(uint256 _credit) external returns (uint256 _retVal);

    function marketStatus() external view returns (MarketStatus);

    function availableBalance() external view returns (uint256 _balance);

    function utilizationRate() external view returns (uint256 _rate);

    function totalLiquidity() external view returns (uint256 _balance);

    function totalCredit() external view returns (uint256);

    function lockedAmount() external view returns (uint256);

    function valueOfUnderlying(address _owner) external view returns (uint256);

    function pendingPremium(address _index) external view returns (uint256);

    function paused() external view returns (bool);

    //onlyOwner
    function applyCover(
        uint256 _pending,
        uint256 _payoutNumerator,
        uint256 _payoutDenominator,
        uint256 _incidentTimestamp,
        bytes32 _merkleRoot,
        string calldata _rawdata,
        string calldata _memo
    ) external;

    function applyBounty(
        uint256 _amount,
        address _contributor,
        uint256[] calldata _ids
    ) external;
}

pragma solidity 0.8.12;

interface IParameters {
    function setVault(address _token, address _vault) external;

    function setRequestDuration(address _address, uint256 _target) external;

    function setUnlockGracePeriod(address _address, uint256 _target) external;

    function setMaxInsureSpan(address _address, uint256 _target) external;

    function setMinInsureSpan(address _address, uint256 _target) external;

    function setUpperSlack(address _address, uint256 _target) external;

    function setLowerSlack(address _address, uint256 _target) external;

    function setWithdrawableDuration(address _address, uint256 _target) external;

    function setPremiumModel(address _address, address _target) external;

    function setFeeRate(address _address, uint256 _target) external;

    function setMaxList(address _address, uint256 _target) external;

    function setCondition(bytes32 _reference, bytes32 _target) external;

    function getOwner() external view returns (address);

    function getVault(address _token) external view returns (address);

    function getPremium(
        uint256 _amount,
        uint256 _term,
        uint256 _totalLiquidity,
        uint256 _lockedAmount,
        address _target
    ) external view returns (uint256);

    function getFeeRate(address _target) external view returns (uint256);

    function getUpperSlack(address _target) external view returns (uint256);

    function getLowerSlack(address _target) external view returns (uint256);

    function getRequestDuration(address _target) external view returns (uint256);

    function getWithdrawableDuration(address _target) external view returns (uint256);

    function getUnlockGracePeriod(address _target) external view returns (uint256);

    function getMaxInsureSpan(address _target) external view returns (uint256);

    function getMinInsureSpan(address _target) external view returns (uint256);

    function getMaxList(address _target) external view returns (uint256);

    function getCondition(bytes32 _reference) external view returns (bytes32);

    function getPremiumModel(address _market) external view returns (address);
}

pragma solidity 0.8.12;

interface IRegistry {
    function isListed(address _market) external view returns (bool);

    function getReserve(address _address) external view returns (address);

    function confirmExistence(address _template, address _target) external view returns (bool);

    //onlyOwner
    function setFactory(address _factory) external;

    function addPool(address _market) external;

    function setExistence(address _template, address _target) external;

    function setReserve(address _address, address _reserve) external;
}

pragma solidity 0.8.12;

interface IUniversalPool {
    function initialize(
        address _depositor,
        string calldata _metaData,
        uint256[] calldata _conditions,
        address[] calldata _references
    ) external;

    //onlyOwner
    function setPaused(bool state) external;

    function changeMetadata(string calldata _metadata) external;
}

pragma solidity 0.8.12;

interface IVault {
    function addValueBatch(
        uint256 _amount,
        address _from,
        address[2] memory _beneficiaries,
        uint256[2] memory _shares
    ) external returns (uint256[2] memory _allocations);

    function addValue(
        uint256 _amount,
        address _from,
        address _attribution
    ) external returns (uint256 _attributions);

    function withdrawValue(uint256 _amount, address _to) external returns (uint256 _attributions);

    function transferValue(uint256 _amount, address _destination) external returns (uint256 _attributions);

    function withdrawAttribution(uint256 _attribution, address _to) external returns (uint256 _retVal);

    function withdrawAllAttribution(address _to) external returns (uint256 _retVal);

    function transferAttribution(uint256 _amount, address _destination) external;

    function attributionOf(address _target) external view returns (uint256);

    function underlyingValue(address _target) external view returns (uint256);

    function attributionValue(uint256 _attribution) external view returns (uint256);

    function utilize(uint256 _amount) external returns (uint256);

    function valueAll() external view returns (uint256);

    function token() external returns (address);

    function balance() external view returns (uint256);

    function available() external view returns (uint256);

    function borrowValue(uint256 _amount, address _to) external;

    /*
    function borrowAndTransfer(uint256 _amount, address _to)
        external
        returns (uint256 _attributions);
    */

    function offsetDebt(uint256 _amount, address _target) external returns (uint256 _attributions);

    function repayDebt(uint256 _amount, address _target) external;

    function debts(address _debtor) external view returns (uint256);

    function transferDebt(uint256 _amount) external;

    //onlyOwner
    function withdrawRedundant(address _token, address _to) external;

    function setController(address _controller) external;
}