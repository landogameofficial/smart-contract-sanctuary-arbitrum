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
pragma solidity ^0.8.9;

interface IRandomizer {
    function request(uint256 callbackGasLimit) external returns (uint256);

    function request(
        uint256 callbackGasLimit,
        uint256 confirmations
    ) external returns (uint256);

    function clientWithdrawTo(address _to, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IScratchGames {
    function scratchAndClaimAllCardsTreasury() external;

    function scratchAllCardsTreasury() external;

    function burnAllCardsTreasury() external;

    function endMint(uint256 _nonce, uint256[] calldata rngList) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ISupraRouter {
    function generateRequest(
        string memory _functionSig,
        uint8 _rngCount,
        uint256 _numConfirmations
    ) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IRandomizer.sol";
import "./interfaces/IScratchGames.sol";
import "./interfaces/ISupraRouter.sol";

contract VRFController is ISupraRouter, Ownable {
    IRandomizer public randomizer;

    mapping(address => bool) public isGame;
    mapping(uint256 => address) public requestIdToGame;
    mapping(uint256 => uint256) public requestIdToRngCount;

    uint256 public callbackGasLimit = 4e6;

    event Requested(uint256 id);
    event Callback(uint256 id, bytes32 value);

    constructor(address _randomizer) {
        randomizer = IRandomizer(_randomizer);
    }

    function setRandomizer(address _randomizer) external onlyOwner {
        randomizer = IRandomizer(_randomizer);
    }

    function addGame(address _game) external onlyOwner {
        require(isGame[_game], "VRFController: Game already added");
        isGame[_game] = true;
    }

    function removeGame(address _game) external onlyOwner {
        require(!isGame[_game], "VRFController: Game not added");
        isGame[_game] = false;
    }

    function generateRequest(
        string memory,
        uint8 _rngCount,
        uint256
    ) external returns (uint256) {
        require(
            address(randomizer) != address(0),
            "VRFController: Randomizer not set"
        );
        require(isGame[msg.sender], "VRFController: Not a game");
        uint256 id = randomizer.request(callbackGasLimit);
        requestIdToGame[id] = msg.sender;
        requestIdToRngCount[id] = _rngCount;
        emit Requested(id);
        return id;
    }

    function randomizerCallback(uint256 id, bytes32 value) external {
        require(msg.sender == address(randomizer), "Caller not Randomizer");
        require(
            requestIdToGame[id] != address(0),
            "VRFController: Invalid request ID"
        );
        uint256[] memory rngList = new uint256[](requestIdToRngCount[id]);
        for (uint256 i = 0; i < requestIdToRngCount[id]; i++) {
            rngList[i] = uint256(keccak256(abi.encodePacked(value, i)));
        }
        IScratchGames(requestIdToGame[id]).endMint(id, rngList);
        emit Callback(id, value);
    }

    function withdrawTo(address _to, uint256 _amount) external onlyOwner {
        randomizer.clientWithdrawTo(_to, _amount);
    }
}