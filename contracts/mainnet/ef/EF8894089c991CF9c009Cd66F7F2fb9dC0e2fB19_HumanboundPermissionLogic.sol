// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import { HumanboundPermissionState, HumanboundPermissionStorage } from "../../storage/HumanboundPermissionStorage.sol";
import "./IHumanboundPermissionLogic.sol";

contract HumanboundPermissionLogic is HumanboundPermissionExtension {
    function updateOperator(address newOperator) external onlyOwner {
        HumanboundPermissionState storage state = HumanboundPermissionStorage._getState();
        state.operator = newOperator;

        emit OperatorUpdated(newOperator);
    }

    function getOperator() external view returns (address) {
        HumanboundPermissionState storage state = HumanboundPermissionStorage._getState();
        return state.operator;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct HumanboundPermissionState {
    address operator;
}

library HumanboundPermissionStorage {
    bytes32 constant STORAGE_NAME = keccak256("humanboundtoken.v1:permission");

    function _getState() internal view returns (HumanboundPermissionState storage permissionState) {
        bytes32 position = keccak256(abi.encodePacked(address(this), STORAGE_NAME));
        assembly {
            permissionState.slot := position
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import "@violetprotocol/extendable/extensions/permissioning/PermissioningLogic.sol";

interface IHumanboundPermissionLogic {
    /**
     * @dev Emitted when `operator` is updated in any way
     */
    event OperatorUpdated(address newOperator);

    /**
     * @notice Updates the `operator` to `newOperator`
     */
    function updateOperator(address newOperator) external;

    /**
     * @notice Returns the current `operator`
     */
    function getOperator() external returns (address);
}

abstract contract HumanboundPermissionExtension is IHumanboundPermissionLogic, PermissioningLogic {
    /**
     * @dev see {IExtension-getSolidityInterface}
     */
    function getSolidityInterface() public pure virtual override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    super.getSolidityInterface(),
                    "function updateOperator(address newOperator) external;\n"
                    "function getOperator() external returns(address);\n"
                )
            );
    }

    /**
     * @dev see {IExtension-getInterface}
     */
    function getInterface() public virtual override returns (Interface[] memory interfaces) {
        interfaces = new Interface[](2);

        bytes4[] memory functions = new bytes4[](2);
        functions[0] = IHumanboundPermissionLogic.updateOperator.selector;
        functions[1] = IHumanboundPermissionLogic.getOperator.selector;

        interfaces[1] = super.getInterface()[0];
        interfaces[0] = Interface(type(IHumanboundPermissionLogic).interfaceId, functions);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Extension.sol";
import "./IPermissioningLogic.sol";
import {RoleState, Permissions} from "../../storage/PermissionStorage.sol";

/**
 * @dev Reference implementation for PermissioningLogic which defines the logic to control
 *      and define ownership of contracts
 *
 * Records address as `owner` in the PermissionStorage module. Modifications and access to 
 * the module affect the state wherever it is accessed by Extensions and can be read/written
 * from/to by other attached extensions.
 *
 * Currently used by the ExtendLogic reference implementation to restrict extend permissions
 * to only `owner`. Uses a common function from the storage library `_onlyOwner()` as a
 * modifier replacement. Can be wrapped in a modifier if preferred.
*/
contract PermissioningLogic is PermissioningExtension {
    /**
     * @dev see {Extension-constructor} for constructor
    */

    /**
     * @dev modifier that restricts caller of a function to only the most recent caller if they are `owner`
    */
    modifier onlyOwner virtual {
        address owner = Permissions._getState().owner;
        require(_lastCaller() == owner, "unauthorised");
        _;
    }

    /**
     * @dev see {IPermissioningLogic-init}
    */
    function init() override public virtual {
        RoleState storage state = Permissions._getState();
        require(state.owner == address(0x0), "PermissioningLogic: already initialised"); // make sure owner has yet to be set for delegator
        state.owner = _lastCaller();

        emit OwnerUpdated(_lastCaller());
    }

    /**
     * @dev see {IPermissioningLogic-updateOwner}
    */
    function updateOwner(address newOwner) override public onlyOwner virtual {
        require(newOwner != address(0x0), "new owner cannot be the zero address");
        RoleState storage state = Permissions._getState();
        state.owner = newOwner;

        emit OwnerUpdated(newOwner);
    }

    /**
     * @dev see {IPermissioningLogic-renounceOwnership}
    */
    function renounceOwnership() override public onlyOwner virtual {
        address NULL_ADDRESS = 0x000000000000000000000000000000000000dEaD;
        RoleState storage state = Permissions._getState();
        state.owner = NULL_ADDRESS;

        emit OwnerUpdated(NULL_ADDRESS);
    }

    /**
     * @dev see {IPermissioningLogic-getOwner}
    */
    function getOwner() override public virtual view returns(address) {
        RoleState storage state = Permissions._getState();
        return(state.owner);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IExtension.sol";
import "../errors/Errors.sol";
import "../utils/CallerContext.sol";
import "../erc165/IERC165Logic.sol";

/**
 *  ______  __  __  ______  ______  __   __  _____   ______  ______  __      ______    
 * /\  ___\/\_\_\_\/\__  _\/\  ___\/\ "-.\ \/\  __-./\  __ \/\  == \/\ \    /\  ___\
 * \ \  __\\/_/\_\/\/_/\ \/\ \  __\\ \ \-.  \ \ \/\ \ \  __ \ \  __<\ \ \___\ \  __\
 *  \ \_____\/\_\/\_\ \ \_\ \ \_____\ \_\\"\_\ \____-\ \_\ \_\ \_____\ \_____\ \_____\
 *   \/_____/\/_/\/_/  \/_/  \/_____/\/_/ \/_/\/____/ \/_/\/_/\/_____/\/_____/\/_____/
 *
 *  Base contract for Extensions in the Extendable Framework
 *  
 *  Inherit and implement this contract to create Extension contracts!
 *
 *  Implements the EIP-165 standard for interface detection of implementations during runtime.
 *  Uses the ERC165 singleton pattern where the actual implementation logic of the interface is
 *  deployed in a separate contract. See ERC165Logic. Deterministic deployment guarantees the
 *  ERC165Logic contract to always exist as static address 0x16C940672fA7820C36b2123E657029d982629070
 *
 *  Define your custom Extension interface and implement it whilst inheriting this contract:
 *      contract YourExtension is IYourExtension, Extension {...}
 *
 */
abstract contract Extension is CallerContext, IExtension, IERC165, IERC165Register {
    address constant ERC165LogicAddress = 0x16C940672fA7820C36b2123E657029d982629070;

    /**
     * @dev Constructor registers your custom Extension interface under EIP-165:
     *      https://eips.ethereum.org/EIPS/eip-165
    */
    constructor() {
        Interface[] memory interfaces = getInterface();
        for (uint256 i = 0; i < interfaces.length; i++) {
            Interface memory iface = interfaces[i];
            registerInterface(iface.interfaceId);

            for (uint256 j = 0; j < iface.functions.length; j++) {
                registerInterface(iface.functions[j]);
            }
        }

        registerInterface(type(IExtension).interfaceId);
    }

    function supportsInterface(bytes4 interfaceId) external override virtual returns(bool) {
        (bool success, bytes memory result) = ERC165LogicAddress.delegatecall(abi.encodeWithSignature("supportsInterface(bytes4)", interfaceId));

        if (!success) {
            assembly {
                revert(result, returndatasize())
            }
        }

        return abi.decode(result, (bool));
    }

    function registerInterface(bytes4 interfaceId) public override virtual {
        (bool success, ) = ERC165LogicAddress.delegatecall(abi.encodeWithSignature("registerInterface(bytes4)", interfaceId));

        if (!success) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    /**
     * @dev Unidentified function signature calls to any Extension reverts with
     *      ExtensionNotImplemented error
    */
    function _fallback() internal virtual {
        revert ExtensionNotImplemented();
    }

    /**
     * @dev Fallback function passes to internal _fallback() logic
    */
    fallback() external payable virtual {
        _fallback();
    }
    
    /**
     * @dev Payable fallback function passes to internal _fallback() logic
    */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Virtual override declaration of getFunctionSelectors() function to silence compiler
     *
     * Must be implemented in inherited contract.
    */
    function getInterface() override public virtual returns(Interface[] memory);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Extension.sol";

/**
 * @dev Interface for PermissioningLogic extension
*/
interface IPermissioningLogic {
    /**
     * @dev Emitted when `owner` is updated in any way
     */
    event OwnerUpdated(address newOwner);

    /**
     * @dev Initialises the `owner` of the contract as `msg.sender`
     *
     * Requirements:
     * - `owner` cannot already be assigned
    */
    function init() external;

    /**
     * @notice Updates the `owner` to `newOwner`
    */
    function updateOwner(address newOwner) external;

    /**
     * @notice Give up ownership of the contract.
     * Proceed with extreme caution as this action is irreversible!!
     *
     * Requirements:
     * - can only be called by the current `owner`
    */
    function renounceOwnership() external;

    /**
     * @notice Returns the current `owner`
    */
    function getOwner() external view returns(address);
}

/**
 * @dev Abstract Extension for PermissioningLogic
*/
abstract contract PermissioningExtension is IPermissioningLogic, Extension {
    /**
     * @dev see {IExtension-getSolidityInterface}
    */
    function getSolidityInterface() override virtual public pure returns(string memory) {
        return  "function init() external;\n"
                "function updateOwner(address newOwner) external;\n"
                "function renounceOwnership() external;\n"
                "function getOwner() external view returns(address);\n";
    }

    /**
     * @dev see {IExtension-getInterface}
    */
    function getInterface() override virtual public returns(Interface[] memory interfaces) {
        interfaces = new Interface[](1);

        bytes4[] memory functions = new bytes4[](4);
        functions[0] = IPermissioningLogic.init.selector;
        functions[1] = IPermissioningLogic.updateOwner.selector;
        functions[2] = IPermissioningLogic.renounceOwnership.selector;
        functions[3] = IPermissioningLogic.getOwner.selector;

        interfaces[0] = Interface(
            type(IPermissioningLogic).interfaceId,
            functions
        );
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev Storage struct used to hold state for Permissioning roles
 */
struct RoleState {
    address owner;
    // Can add more for DAOs/multisigs or more complex role capture for example:
    // address admin;
    // address manager:
}

/**
 * @dev Storage library to access storage slot for the state struct
 */
library Permissions {
    bytes32 constant private STORAGE_NAME = keccak256("extendable.framework.v1:permissions-state");

    function _getState()
        internal 
        view
        returns (RoleState storage roleState) 
    {
        bytes32 position = keccak256(abi.encodePacked(address(this), STORAGE_NAME));
        assembly {
            roleState.slot := position
        }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct Interface {
    bytes4 interfaceId;
    bytes4[] functions;
}

/**
 * @dev Interface for Extension
*/
interface IExtension {
    /**
     * @dev Returns a full view of the functional interface of the extension
     *
     * Must return a list of the functions in the interface of your custom Extension
     * in the same format and syntax as in the interface itself as a string, 
     * escaped-newline separated.
     *
     * OPEN TO SUGGESTIONS FOR IMPROVEMENT ON THIS METHODOLOGY FOR 
     * DEEP DESCRIPTIVE RUNTIME INTROSPECTION
     *
     * Intent is to allow developers that want to integrate with an Extendable contract
     * that will have a constantly evolving interface, due to the nature of Extendables,
     * to be able to easily inspect and query for the current state of the interface and
     * integrate with it.
     *
     * See {ExtendLogic-getSolidityInterface} for an example.
    */
    function getSolidityInterface() external pure returns(string memory);

    /**
     * @dev Returns the interface IDs that are implemented by the Extension
     *
     * These are full interface IDs and ARE NOT function selectors. Full interface IDs are
     * XOR'd function selectors of an interface. For example the interface ID of the ERC721
     * interface is 0x80ac58cd determined by the XOR or all function selectors of the interface.
     * 
     * If an interface only consists of a single function, then the interface ID is identical
     * to that function selector.
     * 
     * Provides a simple abstraction from the developer for any custom Extension to 
     * be EIP-165 compliant out-of-the-box simply by implementing this function. 
     *
     * Excludes any functions either already described by other interface definitions
     * that are not developed on top of this backbone i.e. EIP-165, IExtension
    */
    function getInterface() external returns(Interface[] memory interfaces);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev  ExtensionNotImplemented error is emitted by Extendable and Extensions
 *       where no implementation for a specified function signature exists
 *       in the contract
*/
error ExtensionNotImplemented();


/**
 * @dev  Utility library for contracts to catch custom errors
 *       Pass in a return `result` from a call, and the selector for your error message
 *       and the `catchCustomError` function will return `true` if the error was found
 *       or `false` otherwise
*/
library Errors {
    function catchCustomError(bytes memory result, bytes4 errorSelector) internal pure returns(bool) {
        bytes4 caught;
        assembly {
            caught := mload(add(result, 0x20))
        }

        return caught == errorSelector;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {CallerState, CallerContextStorage} from "../storage/CallerContextStorage.sol";

/**
 * @dev CallerContext contract provides Extensions with proper caller-scoped contexts.
 *      Inherit this contract with your Extension to make use of caller references.
 *
 * `msg.sender` may not behave as developer intends when using within Extensions as many
 * calls may be exchanged between intra-contract extensions which result in a `msg.sender` as self.
 * Instead of using `msg.sender`, replace it with 
 *      - `_lastExternalCaller()` for the most recent caller in the call chain that is external to this contract
 *      - `_lastCaller()` for the most recent caller
 *
 * CallerContext provides a deep callstack to track the caller of the Extension/Extendable contract
 * at any point in the execution cycle.
 *
*/
contract CallerContext {
    /**
     * @dev Returns the most recent caller of this contract that came from outside this contract.
     *
     * Used by extensions that require fetching msg.sender that aren't cross-extension calls.
     * Cross-extension calls resolve msg.sender as the current contract and so the actual
     * caller context is obfuscated.
     * 
     * This function should be used in place of `msg.sender` where external callers are read.
     */
    function _lastExternalCaller() internal view returns(address) {
        CallerState storage state = CallerContextStorage._getState();

        for (uint i = state.callerStack.length - 1; i >= 0; i--) {
            address lastSubsequentCaller = state.callerStack[i];
            if (lastSubsequentCaller != address(this)) {
                return lastSubsequentCaller;
            }
        }

        revert("_lastExternalCaller: end of stack");
    }

    /**
     * @dev Returns the most recent caller of this contract.
     *
     * Last caller may also be the current contract.
     *
     * If the call is directly to the contract, without passing an Extendable, return `msg.sender` instead
     */
    function _lastCaller() internal view returns(address) {
        CallerState storage state = CallerContextStorage._getState();
        if (state.callerStack.length > 0)
            return state.callerStack[state.callerStack.length - 1];
        else
            return msg.sender;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
    function supportsInterface(bytes4 interfaceId) external returns (bool);
}


/**
 * @dev Storage based implementation of the {IERC165} interface.
 *
 * Uses Extendable storage pattern to populate the registered interfaces storage variable.
 */
interface IERC165Register {
    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function registerInterface(bytes4 interfaceId) external;
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct CallerState {
    // Stores a list of callers in the order they are received
    // The current caller context is always the last-most address
    address[] callerStack;
}

library CallerContextStorage {
    bytes32 constant private STORAGE_NAME = keccak256("extendable.framework.v1:caller-state");

    function _getState()
        internal 
        view
        returns (CallerState storage callerState) 
    {
        bytes32 position = keccak256(abi.encodePacked(address(this), STORAGE_NAME));
        assembly {
            callerState.slot := position
        }
    }
}