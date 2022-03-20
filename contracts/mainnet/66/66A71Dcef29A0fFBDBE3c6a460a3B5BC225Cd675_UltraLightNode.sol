// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "@layerzerolabs/proof-evm/contracts/ILayerZeroValidationLibrary.sol";

import "./interfaces/ILayerZeroMessagingLibrary.sol";
import "./interfaces/ILayerZeroReceiver.sol";
import "./interfaces/ILayerZeroRelayer.sol";
import "./interfaces/ILayerZeroTreasury.sol";
import "./interfaces/ILayerZeroOracle.sol";
import "./interfaces/ILayerZeroUltraLightNodeV1.sol";
import "./interfaces/ILayerZeroEndpoint.sol";

contract UltraLightNode is ILayerZeroMessagingLibrary, ILayerZeroUltraLightNodeV1, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    struct BlockData {
        uint confirmations;
        bytes32 data;
    }

    // Application config
    uint public constant CONFIG_TYPE_INBOUND_PROOF_LIBRARY_VERSION = 1;
    uint public constant CONFIG_TYPE_INBOUND_BLOCK_CONFIRMATIONS = 2;
    uint public constant CONFIG_TYPE_RELAYER = 3;
    uint public constant CONFIG_TYPE_OUTBOUND_PROOF_TYPE = 4;
    uint public constant CONFIG_TYPE_OUTBOUND_BLOCK_CONFIRMATIONS = 5;
    uint public constant CONFIG_TYPE_ORACLE = 6;

    struct ApplicationConfiguration {
        uint16 inboundProofLibraryVersion;
        uint64 inboundBlockConfirmations;
        address relayer;
        uint16 outboundProofType;
        uint64 outboundBlockConfirmations;
        address oracle;
    }

    // Token and Contracts
    IERC20 public layerZeroToken;
    ILayerZeroTreasury public treasuryContract;

    // Fee management
    uint public constant BP_DENOMINATOR = 10000;
    // treasury and relayer share the protocol fee, either in native token or ZRO
    uint8 public constant WITHDRAW_TYPE_TREASURY_PROTOCOL_FEES = 0;
    uint8 public constant WITHDRAW_TYPE_ORACLE_QUOTED_FEES = 1; // quoted fee refers to the fee in block relaying
    uint8 public constant WITHDRAW_TYPE_RELAYER_QUOTED_FEES = 2; //quoted fee refers the fee in msg relaying

    mapping(address => uint) public oracleQuotedFees;
    mapping(address => uint) public relayerQuotedFees;
    uint public treasuryNativeFees;
    uint public treasuryZROFees;

    // User Application
    mapping(address => mapping(uint16 => ApplicationConfiguration)) public appConfig; // app address => chainId => config
    mapping(uint16 => ApplicationConfiguration) public defaultAppConfig; // default UA settings if no version specified
    mapping(uint16 => mapping(uint16 => bytes)) public defaultAdapterParams;

    // Validation
    mapping(uint16 => mapping(uint16 => address)) public inboundProofLibrary; // chainId => library Id => inboundProofLibrary contract
    mapping(uint16 => uint16) public maxInboundProofLibrary; // chainId => inboundProofLibrary
    mapping(uint16 => mapping(uint16 => bool)) public supportedOutboundProof; // chainId => outboundProofType => enabled
    mapping(uint16 => uint) public chainAddressSizeMap;
    mapping(address => mapping(uint16 => mapping(bytes32 => BlockData))) public hashLookup;
    mapping(uint16 => bytes32) public ulnLookup; // remote ulns

    ILayerZeroEndpoint public immutable endpoint;

    // Events
    event AppConfigUpdated(address userApplication, uint configType, bytes newConfig);
    event AddInboundProofLibraryForChain(uint16 chainId, address lib);
    event EnableSupportedOutboundProof(uint16 chainId, uint16 proofType);
    event HashReceived(uint16 srcChainId, address oracle, uint confirmations, bytes32 blockhash);
    event Packet(uint16 chainId, bytes payload);
    event RelayerParams(uint16 chainId, uint64 nonce, uint16 outboundProofType, bytes adapterParams);
    event SetChainAddressSize(uint16 chainId, uint size);
    event SetDefaultConfigForChainId(uint16 chainId, uint16 inboundProofLib, uint64 inboundBlockConfirm, address relayer, uint16 outboundProofType, uint16 outboundBlockConfirm, address oracle);
    event SetDefaultAdapterParamsForChainId(uint16 chainId, uint16 proofType, bytes adapterParams);
    event SetLayerZeroToken(address tokenAddress);
    event SetRelayerFeeContract(address relayerFeeContract);
    event SetRemoteUln(uint16 chainId, bytes32 uln);
    event SetTreasury(address treasuryAddress);
    event WithdrawZRO(address _msgSender, address _to, uint _amount);
    event WithdrawNative(uint8 _type, address _owner, address _msgSender, address _to, uint _amount);

    constructor(address _endpoint) {
        require(_endpoint != address(0x0), "LayerZero: endpoint cannot be zero address");
        endpoint = ILayerZeroEndpoint(_endpoint);
    }

    // only the endpoint can call SEND() and setConfig()
    modifier onlyEndpoint() {
        require(address(endpoint) == msg.sender, "LayerZero: only endpoint");
        _;
    }

    //----------------------------------------------------------------------------------
    // PROTOCOL

    // This function completes delivery of a LayerZero message.
    //
    // In order to deliver the message, this function:
    // (a) takes the _transactionProof submitted by UA's relayer, and
    // (b) retrieve UA's validation library
    // (c) takes the _blockData submitted by the UA's oracle given the their configuration (and blockConfirmations),
    // (d) decodes using UA's validation library using (a) and (c)
    //  then, this functions asserts that
    // (e) the payload originated from the known Ultra Light Node from source chain, and
    // (f) the _dstAddress the specified destination contract
    function validateTransactionProof(uint16 _srcChainId, address _dstAddress, uint _gasLimit, bytes32 _lookupHash, bytes calldata _transactionProof) external override {
        // retrieve UA's configuration using the _dstAddress from arguments.
        ApplicationConfiguration memory uaConfig = getAppConfig(_srcChainId, _dstAddress);

        // (a) assert that the caller == UA's relayer
        require(uaConfig.relayer == msg.sender, "LayerZero: invalid relayer");

        LayerZeroPacket.Packet memory _packet;
        {
            // (b) retrieve UA's validation library
            address inboundProofLib = inboundProofLibrary[_srcChainId][uaConfig.inboundProofLibraryVersion];

            // (c) assert that the data submitted by UA's oracle have no fewer confirmations than UA's configuration
            BlockData storage blockData = hashLookup[uaConfig.oracle][_srcChainId][_lookupHash];
            require(blockData.confirmations >= uaConfig.inboundBlockConfirmations, "LayerZero: not enough block confirmations");

            // (d) decode
            uint remoteAddressSize = chainAddressSizeMap[_srcChainId];
            _packet = ILayerZeroValidationLibrary(inboundProofLib).validateProof(blockData.data, _transactionProof, remoteAddressSize);
        }

        // (e) assert that the packet was emitted by the source ultra light node
        require(ulnLookup[_srcChainId] == _packet.ulnAddress, "LayerZero: _packet.ulnAddress is invalid");

        // (f) assert that the _packet._dstAddress == the _dstAddress specified by the UAs message
        require(_packet.dstAddress == _dstAddress, "LayerZero: invalid dst address");

        // publish the payload and _gasLimit to the endpoint for calling lzReceive at _dstAddress
        endpoint.receivePayload(_packet.srcChainId, _packet.srcAddress, _packet.dstAddress, _packet.nonce, _gasLimit, _packet.payload);
    }

    // Called (by the Endpoint) with the information required to send a LayerZero message for a User Application.
    // This function:
    // (a) pays the protocol (native token or ZRO), oracle (native token) and relayer (native token) for their roles in sending the message.
    // (b) generates the message payload and emits events of the message and adapterParams
    // (c) notifies the oracle
    function send(address _ua, uint64 _nonce, uint16 _chainId, bytes calldata _destination, bytes calldata _payload, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable override onlyEndpoint {
        ApplicationConfiguration memory uaConfig = getAppConfig(_chainId, _ua);
        address ua = _ua;
        uint64 nonce = _nonce;
        uint16 chainId = _chainId;
        require(ulnLookup[chainId] != bytes32(0), "LayerZero: chainId does not exist");

        uint totalNativeFee;
        {
            uint oracleFee;
            // (a - 1), pay the oracle
            {
                oracleFee = ILayerZeroOracle(uaConfig.oracle).getPrice(chainId, uaConfig.outboundProofType);
                oracleQuotedFees[uaConfig.oracle] = oracleQuotedFees[uaConfig.oracle].add(oracleFee);
            }

            // (a - 2), pay the relayer
            {
                uint payloadSize = _payload.length;
                ILayerZeroRelayer relayer = ILayerZeroRelayer(uaConfig.relayer);
                if (_adapterParams.length == 0) {
                    bytes memory defaultAdaptorParam = defaultAdapterParams[chainId][uaConfig.outboundProofType];
                    totalNativeFee = relayer.getPrice(chainId, uaConfig.outboundProofType, ua, payloadSize, defaultAdaptorParam);
                    relayer.notifyRelayer(chainId, uaConfig.outboundProofType, defaultAdaptorParam);
                } else {
                    totalNativeFee = relayer.getPrice(chainId, uaConfig.outboundProofType, ua, payloadSize, _adapterParams);
                    relayer.notifyRelayer(chainId, uaConfig.outboundProofType, _adapterParams);
                }
                relayerQuotedFees[uaConfig.relayer] = relayerQuotedFees[uaConfig.relayer].add(totalNativeFee); // totalNativeFee == relayerFee here

                // emit the param events
                emit RelayerParams(chainId, nonce, uaConfig.outboundProofType, _adapterParams);
            }

            // (a - 3), pay the protocol
            {
                // if no ZRO token or not specifying a payment address, pay in native token
                bool payInNative = _zroPaymentAddress == address(0x0) || address(layerZeroToken) == address(0x0);
                uint protocolFee = treasuryContract.getFees(!payInNative, totalNativeFee, oracleFee); // totalNativeFee == relayerFee here

                if (protocolFee > 0) {
                    if (payInNative) {
                        treasuryNativeFees = treasuryNativeFees.add(protocolFee);
                        totalNativeFee = totalNativeFee.add(protocolFee);
                    } else {
                        // zro payment address must equal the _ua or the tx.origin otherwise the transaction reverts
                        require(_zroPaymentAddress == ua || _zroPaymentAddress == tx.origin, "LayerZero: must be paid by sender or origin");

                        // transfer the LayerZero token to this contract from the payee
                        layerZeroToken.safeTransferFrom(_zroPaymentAddress, address(this), protocolFee);

                        treasuryZROFees = treasuryZROFees.add(protocolFee);
                    }
                }
            }

            totalNativeFee = totalNativeFee.add(oracleFee);
        }

        // (b) emit payload and the adapterParams if any
        {
            bytes memory encodedPayload = abi.encodePacked(nonce, ua, _destination, _payload);
            emit Packet(chainId, encodedPayload);
            // (c) notify the oracle
            ILayerZeroOracle(uaConfig.oracle).notifyOracle(chainId, uaConfig.outboundProofType, uaConfig.outboundBlockConfirmations);
        }

        require(totalNativeFee <= msg.value, "LayerZero: not enough native for fees");
        // refund if they send too much
        uint amount = msg.value.sub(totalNativeFee);
        if (amount > 0) {
            (bool success, ) = _refundAddress.call{value: amount}("");
            require(success, "LayerZero: failed to refund");
        }
    }

    // Can be called by any address to update a block header
    // can only upload new block data or the same block data with more confirmations
    function updateHash(uint16 _srcChainId, bytes32 _lookupHash, uint _confirmations, bytes32 _data) external override {
        // this function may revert with a default message if the oracle address is not an ILayerZeroOracle
        BlockData storage bd = hashLookup[msg.sender][_srcChainId][_lookupHash];
        // if it has a record, requires a larger confirmation.
        require(bd.confirmations < _confirmations, "LayerZero: oracle data can only update if it has more confirmations");

        // set the new information into storage
        bd.confirmations = _confirmations;
        bd.data = _data;

        emit HashReceived(_srcChainId, msg.sender, _confirmations, _lookupHash);
    }

    //----------------------------------------------------------------------------------
    // Other Library Interfaces

    // default to DEFAULT setting if ZERO value
    function getAppConfig(uint16 _chainId, address userApplicationAddress) public view returns (ApplicationConfiguration memory) {
        ApplicationConfiguration memory config = appConfig[userApplicationAddress][_chainId];
        ApplicationConfiguration storage defaultConfig = defaultAppConfig[_chainId];

        if (config.inboundProofLibraryVersion == 0) {
            config.inboundProofLibraryVersion = defaultConfig.inboundProofLibraryVersion;
        }

        if (config.inboundBlockConfirmations == 0) {
            config.inboundBlockConfirmations = defaultConfig.inboundBlockConfirmations;
        }

        if (config.relayer == address(0x0)) {
            config.relayer = defaultConfig.relayer;
        }

        if (config.outboundProofType == 0) {
            config.outboundProofType = defaultConfig.outboundProofType;
        }

        if (config.outboundBlockConfirmations == 0) {
            config.outboundBlockConfirmations = defaultConfig.outboundBlockConfirmations;
        }

        if (config.oracle == address(0x0)) {
            config.oracle = defaultConfig.oracle;
        }

        return config;
    }

    function setConfig(uint16 chainId, address _ua, uint _configType, bytes calldata _config) external override onlyEndpoint {
        ApplicationConfiguration storage uaConfig = appConfig[_ua][chainId];
        if (_configType == CONFIG_TYPE_INBOUND_PROOF_LIBRARY_VERSION) {
            uint16 inboundProofLibraryVersion = abi.decode(_config, (uint16));
            require(inboundProofLibraryVersion <= maxInboundProofLibrary[chainId], "LayerZero: invalid inbound proof library version");
            uaConfig.inboundProofLibraryVersion = inboundProofLibraryVersion;
        } else if (_configType == CONFIG_TYPE_INBOUND_BLOCK_CONFIRMATIONS) {
            uint64 blockConfirmations = abi.decode(_config, (uint64));
            uaConfig.inboundBlockConfirmations = blockConfirmations;
        } else if (_configType == CONFIG_TYPE_RELAYER) {
            address relayer = abi.decode(_config, (address));
            uaConfig.relayer = relayer;
        } else if (_configType == CONFIG_TYPE_OUTBOUND_PROOF_TYPE) {
            uint16 outboundProofType = abi.decode(_config, (uint16));
            require(supportedOutboundProof[chainId][outboundProofType] || outboundProofType == 0, "LayerZero: invalid outbound proof type");
            uaConfig.outboundProofType = outboundProofType;
        } else if (_configType == CONFIG_TYPE_OUTBOUND_BLOCK_CONFIRMATIONS) {
            uint64 blockConfirmations = abi.decode(_config, (uint64));
            uaConfig.outboundBlockConfirmations = blockConfirmations;
        } else if (_configType == CONFIG_TYPE_ORACLE) {
            address oracle = abi.decode(_config, (address));
            uaConfig.oracle = oracle;
        } else {
            revert("LayerZero: Invalid config type");
        }

        emit AppConfigUpdated(_ua, _configType, _config);
    }

    function getConfig(uint16 _chainId, address userApplicationAddress, uint _configType) external view override returns (bytes memory) {
        ApplicationConfiguration storage uaConfig = appConfig[userApplicationAddress][_chainId];

        if (_configType == CONFIG_TYPE_INBOUND_PROOF_LIBRARY_VERSION) {
            if (uaConfig.inboundProofLibraryVersion == 0) {
                return abi.encode(defaultAppConfig[_chainId].inboundProofLibraryVersion);
            }
            return abi.encode(uaConfig.inboundProofLibraryVersion);
        } else if (_configType == CONFIG_TYPE_INBOUND_BLOCK_CONFIRMATIONS) {
            if (uaConfig.inboundBlockConfirmations == 0) {
                return abi.encode(defaultAppConfig[_chainId].inboundBlockConfirmations);
            }
            return abi.encode(uaConfig.inboundBlockConfirmations);
        } else if (_configType == CONFIG_TYPE_RELAYER) {
            if (uaConfig.relayer == address(0x0)) {
                return abi.encode(defaultAppConfig[_chainId].relayer);
            }
            return abi.encode(uaConfig.relayer);
        } else if (_configType == CONFIG_TYPE_OUTBOUND_PROOF_TYPE) {
            if (uaConfig.outboundProofType == 0) {
                return abi.encode(defaultAppConfig[_chainId].outboundProofType);
            }
            return abi.encode(uaConfig.outboundProofType);
        } else if (_configType == CONFIG_TYPE_OUTBOUND_BLOCK_CONFIRMATIONS) {
            if (uaConfig.outboundBlockConfirmations == 0) {
                return abi.encode(defaultAppConfig[_chainId].outboundBlockConfirmations);
            }
            return abi.encode(uaConfig.outboundBlockConfirmations);
        } else if (_configType == CONFIG_TYPE_ORACLE) {
            if (uaConfig.oracle == address(0x0)) {
                return abi.encode(defaultAppConfig[_chainId].oracle);
            }
            return abi.encode(uaConfig.oracle);
        } else {
            revert("LayerZero: Invalid config type");
        }
    }

    // returns the native fee the UA pays to cover fees
    function estimateFees(uint16 _chainId, address _ua, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParams) external view override returns (uint nativeFee, uint zroFee) {
        uint16 chainId = _chainId;
        address ua = _ua;
        uint payloadSize = _payload.length;
        bytes memory adapterParam = _adapterParams;

        ApplicationConfiguration memory uaConfig = getAppConfig(chainId, ua);

        // Relayer Fee
        uint relayerFee;
        {
            if (adapterParam.length == 0) {
                bytes memory defaultAdaptorParam = defaultAdapterParams[chainId][uaConfig.outboundProofType];
                relayerFee = ILayerZeroRelayer(uaConfig.relayer).getPrice(chainId, uaConfig.outboundProofType, ua, payloadSize, defaultAdaptorParam);
            } else {
                relayerFee = ILayerZeroRelayer(uaConfig.relayer).getPrice(chainId, uaConfig.outboundProofType, ua, payloadSize, adapterParam);
            }
        }

        // Oracle Fee
        uint oracleFee = ILayerZeroOracle(uaConfig.oracle).getPrice(chainId, uaConfig.outboundProofType);

        // LayerZero Fee
        {
            uint protocolFee = treasuryContract.getFees(_payInZRO, relayerFee, oracleFee);
            _payInZRO ? zroFee = protocolFee : nativeFee = protocolFee;
        }

        // return the sum of fees
        nativeFee = nativeFee.add(relayerFee).add(oracleFee);
    }

    //---------------------------------------------------------------------------
    // Claim Fees

    // universal withdraw ZRO token function
    function withdrawZRO(address _to, uint _amount) external override nonReentrant {
        require(msg.sender == address(treasuryContract), "LayerZero: only treasury");
        treasuryZROFees = treasuryZROFees.sub(_amount);
        layerZeroToken.safeTransfer(_to, _amount);
        emit WithdrawZRO(msg.sender, _to, _amount);
    }

    // universal withdraw native token function.
    // the source contract should perform all the authentication control
    // safemath overflow if the amount is not enough
    function withdrawNative(uint8 _type, address _owner, address payable _to, uint _amount) external override nonReentrant {
        if (_type == WITHDRAW_TYPE_TREASURY_PROTOCOL_FEES) {
            require(msg.sender == address(treasuryContract), "LayerZero:only treasury");
            treasuryNativeFees = treasuryNativeFees.sub(_amount);
        } else if (_type == WITHDRAW_TYPE_ORACLE_QUOTED_FEES) {
            oracleQuotedFees[msg.sender] = oracleQuotedFees[msg.sender].sub(_amount);
        } else if (_type == WITHDRAW_TYPE_RELAYER_QUOTED_FEES) {
            relayerQuotedFees[msg.sender] = relayerQuotedFees[msg.sender].sub(_amount);
        } else {
            revert("LayerZero: unsupported withdraw type");
        }

        (bool success, ) = _to.call{value: _amount}("");
        require(success, "LayerZero: withdraw failed");
        emit WithdrawNative(_type, _owner, msg.sender, _to, _amount);
    }

    //---------------------------------------------------------------------------
    // Owner calls, configuration only.
    function setLayerZeroToken(address _layerZeroToken) external onlyOwner {
        require(_layerZeroToken != address(0x0), "LayerZero: _layerZeroToken cannot be zero address");
        layerZeroToken = IERC20(_layerZeroToken);
        emit SetLayerZeroToken(_layerZeroToken);
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0x0), "LayerZero: treasury cannot be zero address");
        treasuryContract = ILayerZeroTreasury(_treasury);
        emit SetTreasury(_treasury);
    }

    function addInboundProofLibraryForChain(uint16 _chainId, address _library) external onlyOwner {
        require(_library != address(0x0), "LayerZero: library cannot be zero address");
        require(maxInboundProofLibrary[_chainId] < 65535, "LayerZero: can not add new library");
        maxInboundProofLibrary[_chainId]++;
        inboundProofLibrary[_chainId][maxInboundProofLibrary[_chainId]] = _library;
        emit AddInboundProofLibraryForChain(_chainId, _library);
    }

    function enableSupportedOutboundProof(uint16 _chainId, uint16 _proofType) external onlyOwner {
        supportedOutboundProof[_chainId][_proofType] = true;
        emit EnableSupportedOutboundProof(_chainId, _proofType);
    }

    function setDefaultConfigForChainId(uint16 _chainId, uint16 _inboundProofLibraryVersion, uint64 _inboundBlockConfirmations, address _relayer, uint16 _outboundProofType, uint16 _outboundBlockConfirmations, address _oracle) external onlyOwner {
        require(_inboundProofLibraryVersion <= maxInboundProofLibrary[_chainId] && _inboundProofLibraryVersion > 0, "LayerZero: invalid inbound proof library version");
        require(_inboundBlockConfirmations > 0, "LayerZero: invalid inbound block confirmation");
        require(_relayer != address(0x0), "LayerZero: invalid relayer address");
        require(supportedOutboundProof[_chainId][_outboundProofType], "LayerZero: invalid outbound proof type");
        require(_outboundBlockConfirmations > 0, "LayerZero: invalid outbound block confirmation");
        require(_oracle != address(0x0), "LayerZero: invalid oracle address");
        defaultAppConfig[_chainId] = ApplicationConfiguration(_inboundProofLibraryVersion, _inboundBlockConfirmations, _relayer, _outboundProofType, _outboundBlockConfirmations, _oracle);
        emit SetDefaultConfigForChainId(_chainId, _inboundProofLibraryVersion, _inboundBlockConfirmations, _relayer, _outboundProofType, _outboundBlockConfirmations, _oracle);
    }

    function setDefaultAdapterParamsForChainId(uint16 _chainId, uint16 _proofType, bytes calldata _adapterParams) external onlyOwner {
        defaultAdapterParams[_chainId][_proofType] = _adapterParams;
        emit SetDefaultAdapterParamsForChainId(_chainId, _proofType, _adapterParams);
    }

    function setRemoteUln(uint16 _remoteChainId, bytes32 _remoteUln) external onlyOwner {
        require(ulnLookup[_remoteChainId] == bytes32(0), "LayerZero: remote uln already set");
        ulnLookup[_remoteChainId] = _remoteUln;
        emit SetRemoteUln(_remoteChainId, _remoteUln);
    }

    function setChainAddressSize(uint16 _chainId, uint _size) external onlyOwner {
        require(chainAddressSizeMap[_chainId] == 0, "LayerZero: remote chain address size already set");
        chainAddressSizeMap[_chainId] = _size;
        emit SetChainAddressSize(_chainId, _size);
    }

    //----------------------------------------------------------------------------------
    // view functions
    function getBlockHeaderData(address _oracle, uint16 _remoteChainId, bytes32 _lookupHash) external view returns (BlockData memory blockData) {
        return hashLookup[_oracle][_remoteChainId][_lookupHash];
    }

    function oracleQuotedAmount(address _oracle) external view override returns (uint) {
        return oracleQuotedFees[_oracle];
    }

    function relayerQuotedAmount(address _relayer) external view override returns (uint) {
        return relayerQuotedFees[_relayer];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

pragma solidity ^0.7.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.7.0;
pragma abicoder v2;

import "./utility/LayerZeroPacket.sol";

interface ILayerZeroValidationLibrary {
    function validateProof(bytes32 blockData, bytes calldata _data, uint _remoteAddressSize) external returns (LayerZeroPacket.Packet memory packet);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.7.0;

import "./ILayerZeroUserApplicationConfig.sol";

interface ILayerZeroMessagingLibrary {
    // send(), messages will be inflight.
    function send(address _userApplication, uint64 _lastNonce, uint16 _chainId, bytes calldata _destination, bytes calldata _payload, address payable refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable;

    // estimate native fee at the send side
    function estimateFees(uint16 _chainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParam) external view returns (uint nativeFee, uint zroFee);

    //---------------------------------------------------------------------------
    // setConfig / getConfig are User Application (UA) functions to specify Oracle, Relayer, blockConfirmations, libraryVersion
    function setConfig(uint16 _chainId, address _userApplication, uint _configType, bytes calldata _config) external;

    function getConfig(uint16 _chainId, address _userApplication, uint _configType) external view returns (bytes memory);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.5.0;

interface ILayerZeroReceiver {
    // @notice LayerZero endpoint will invoke this function to deliver the message on the destination
    // @param _srcChainId - the source endpoint identifier
    // @param _srcAddress - the source sending contract address from the source chain
    // @param _nonce - the ordered message nonce
    // @param _payload - the signed payload is the UA bytes has encoded to be sent
    function lzReceive(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.7.0;

interface ILayerZeroRelayer {
    // @notice query the relayer price for relaying the payload and its proof to the destination chain
    // @param _dstChainId - the destination endpoint identifier
    // @param _outboundProofType - the proof type identifier to specify proof to be relayed
    // @param _userApplication - the source sending contract address. relayers may apply price discrimination to user apps
    // @param _payloadSize - the length of the payload. it is an indicator of gas usage for relaying cross-chain messages
    // @param _adapterParams - optional parameters for extra service plugins, e.g. sending dust tokens at the destination chain
    function getPrice(uint16 _dstChainId, uint16 _outboundProofType, address _userApplication, uint _payloadSize, bytes calldata _adapterParams) external view returns (uint price);

    // @notice Ultra-Light Node notifies the Oracle of a new block information relaying request
    // @param _dstChainId - the destination endpoint identifier
    // @param _outboundProofType - the proof type identifier to specify the data to be relayed
    // @param _adapterParams - optional parameters for extra service plugins, e.g. sending dust tokens at the destination chain
    function notifyRelayer(uint16 _dstChainId, uint16 _outboundProofType, bytes calldata _adapterParams) external;

    // @notice query if the address is an approved actor for privileges like data submission and fee withdrawal etc.
    // @param _address - the address to be checked
    function isApproved(address _address) external view returns (bool approved);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.5.0;

interface ILayerZeroTreasury {
    function getFees(bool payInZro, uint relayerFee, uint oracleFee) external view returns (uint);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.7.0;

interface ILayerZeroOracle {
    // @notice query the oracle price for relaying block information to the destination chain
    // @param _dstChainId the destination endpoint identifier
    // @param _outboundProofType the proof type identifier to specify the data to be relayed
    function getPrice(uint16 _dstChainId, uint16 _outboundProofType) external view returns (uint price);

    // @notice Ultra-Light Node notifies the Oracle of a new block information relaying request
    // @param _dstChainId the destination endpoint identifier
    // @param _outboundProofType the proof type identifier to specify the data to be relayed
    // @param _outboundBlockConfirmations the number of source chain block confirmation needed
    function notifyOracle(uint16 _dstChainId, uint16 _outboundProofType, uint64 _outboundBlockConfirmations) external;

    // @notice query if the address is an approved actor for privileges like data submission and fee withdrawal etc.
    // @param _address the address to be checked
    function isApproved(address _address) external view returns (bool approved);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.7.0;

interface ILayerZeroUltraLightNodeV1 {
    // a Relayer can execute the validateTransactionProof()
    function validateTransactionProof(uint16 _srcChainId, address _dstAddress, uint _gasLimit, bytes32 _lookupHash, bytes calldata _transactionProof) external;

    // an Oracle delivers the block data using updateHash()
    function updateHash(uint16 _remoteChainId, bytes32 _lookupHash, uint _confirmations, bytes32 _data) external;

    // can only withdraw the receivable of the msg.sender
    function withdrawNative(uint8 _type, address _owner, address payable _to, uint _amount) external;

    function withdrawZRO(address _to, uint _amount) external;

    // view functions
    function oracleQuotedAmount(address _oracle) external view returns (uint);

    function relayerQuotedAmount(address _relayer) external view returns (uint);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.5.0;

import "./ILayerZeroUserApplicationConfig.sol";

interface ILayerZeroEndpoint is ILayerZeroUserApplicationConfig {
    // @notice send a LayerZero message to the specified address at a LayerZero endpoint.
    // @param _dstChainId - the destination chain identifier
    // @param _destination - the address on destination chain (in bytes). address length/format may vary by chains
    // @param _payload - a custom bytes payload to send to the destination contract
    // @param _refundAddress - if the source transaction is cheaper than the amount of value passed, refund the additional amount to this address
    // @param _zroPaymentAddress - the address of the ZRO token holder who would pay for the transaction
    // @param _adapterParams - parameters for custom functionality. e.g. receive airdropped native gas from the relayer on destination
    function send(uint16 _dstChainId, bytes calldata _destination, bytes calldata _payload, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable;

    // @notice used by the messaging library to publish verified payload
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source contract (as bytes) at the source chain
    // @param _dstAddress - the address on destination chain
    // @param _nonce - the unbound message ordering nonce
    // @param _gasLimit - the gas limit for external contract execution
    // @param _payload - verified payload to send to the destination contract
    function receivePayload(uint16 _srcChainId, bytes calldata _srcAddress, address _dstAddress, uint64 _nonce, uint _gasLimit, bytes calldata _payload) external;

    // @notice get the inboundNonce of a receiver from a source chain which could be EVM or non-EVM chain
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    function getInboundNonce(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (uint64);

    // @notice get the outboundNonce from this source chain which, consequently, is always an EVM
    // @param _srcAddress - the source chain contract address
    function getOutboundNonce(uint16 _dstChainId, address _srcAddress) external view returns (uint64);

    // @notice gets a quote in source native gas, for the amount that send() requires to pay for message delivery
    // @param _dstChainId - the destination chain identifier
    // @param _userApplication - the user app address on this EVM chain
    // @param _payload - the custom message to send over LayerZero
    // @param _payInZRO - if false, user app pays the protocol fee in native token
    // @param _adapterParam - parameters for the adapter service, e.g. send some dust native token to dstChain
    function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParam) external view returns (uint nativeFee, uint zroFee);

    // @notice get this Endpoint's immutable source identifier
    function getChainId() external view returns (uint16);

    // @notice the interface to retry failed message on this Endpoint destination
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    // @param _payload - the payload to be retried
    function retryPayload(uint16 _srcChainId, bytes calldata _srcAddress, bytes calldata _payload) external;

    // @notice query if any STORED payload (message blocking) at the endpoint.
    // @param _srcChainId - the source chain identifier
    // @param _srcAddress - the source chain contract address
    function hasStoredPayload(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (bool);

    // @notice query if the _libraryAddress is valid for sending msgs.
    // @param _userApplication - the user app address on this EVM chain
    function getSendLibraryAddress(address _userApplication) external view returns (address);

    // @notice query if the _libraryAddress is valid for receiving msgs.
    // @param _userApplication - the user app address on this EVM chain
    function getReceiveLibraryAddress(address _userApplication) external view returns (address);

    // @notice query if the non-reentrancy guard for send() is on
    // @return true if the guard is on. false otherwise
    function isSendingPayload() external view returns (bool);

    // @notice query if the non-reentrancy guard for receive() is on
    // @return true if the guard is on. false otherwise
    function isReceivingPayload() external view returns (bool);

    // @notice get the configuration of the LayerZero messaging library of the specified version
    // @param _version - messaging library version
    // @param _chainId - the chainId for the pending config change
    // @param _userApplication - the contract address of the user application
    // @param _configType - type of configuration. every messaging library has its own convention.
    function getConfig(uint16 _version, uint16 _chainId, address _userApplication, uint _configType) external view returns (bytes memory);

    // @notice get the send() LayerZero messaging library version
    // @param _userApplication - the contract address of the user application
    function getSendVersion(address _userApplication) external view returns (uint16);

    // @notice get the lzReceive() LayerZero messaging library version
    // @param _userApplication - the contract address of the user application
    function getReceiveVersion(address _userApplication) external view returns (uint16);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Buffer.sol";

library LayerZeroPacket {
    using Buffer for Buffer.buffer;
    using SafeMath for uint;

    //---------------------------------------------------------------------------
    // packet
    struct Packet {
        uint16 srcChainId;
        uint16 dstChainId;
        uint64 nonce;
        address dstAddress;
        bytes srcAddress;
        bytes32 ulnAddress;
        bytes payload;
    }

    function getPacket(bytes memory data, uint16 srcChain, uint sizeOfSrcAddress, bytes32 ulnAddress) internal pure returns (Packet memory) {
        uint16 dstChainId;
        address dstAddress;
        uint size;
        uint64 nonce;

        // The log consists of the destination chain id and then a bytes payload
        //      0--------------------------------------------31
        // 0   |  destination chain id
        // 32  |  defines bytes array
        // 64  |
        // 96  |  bytes array size
        // 128 |  payload
        assembly {
            dstChainId := mload(add(data, 32))
            size := mload(add(data, 96)) /// size of the byte array
            nonce := mload(add(data, 104)) // offset to convert to uint64  128  is index -24
            dstAddress := mload(add(data, sub(add(128, sizeOfSrcAddress), 4))) // offset to convert to address 12 -8
        }

        Buffer.buffer memory srcAddressBuffer;
        srcAddressBuffer.init(sizeOfSrcAddress);
        srcAddressBuffer.writeRawBytes(0, data, 136, sizeOfSrcAddress); // 128 + 8

        uint payloadSize = size.sub(20).sub(sizeOfSrcAddress);
        Buffer.buffer memory payloadBuffer;
        payloadBuffer.init(payloadSize);
        payloadBuffer.writeRawBytes(0, data, sizeOfSrcAddress.add(156), payloadSize); // 148 + 8
        return Packet(srcChain, dstChainId, nonce, address(dstAddress), srcAddressBuffer.buf, ulnAddress, payloadBuffer.buf);
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.7.0;

/**
 * @dev A library for working with mutable byte buffers in Solidity.
 *
 * Byte buffers are mutable and expandable, and provide a variety of primitives
 * for writing to them. At any time you can fetch a bytes object containing the
 * current contents of the buffer. The bytes object should not be stored between
 * operations, as it may change due to resizing of the buffer.
 */
library Buffer {
    /**
     * @dev Represents a mutable buffer. Buffers have a current value (buf) and
     *      a capacity. The capacity may be longer than the current value, in
     *      which case it can be extended without the need to allocate more memory.
     */
    struct buffer {
        bytes buf;
        uint capacity;
    }

    /**
     * @dev Initializes a buffer with an initial capacity.a co
     * @param buf The buffer to initialize.
     * @param capacity The number of bytes of space to allocate the buffer.
     * @return The buffer, for chaining.
     */
    function init(buffer memory buf, uint capacity) internal pure returns (buffer memory) {
        if (capacity % 32 != 0) {
            capacity += 32 - (capacity % 32);
        }
        // Allocate space for the buffer data
        buf.capacity = capacity;
        assembly {
            let ptr := mload(0x40)
            mstore(buf, ptr)
            mstore(ptr, 0)
            mstore(0x40, add(32, add(ptr, capacity)))
        }
        return buf;
    }

    /**
     * @dev Initializes a new buffer from an existing bytes object.
     *      Changes to the buffer may mutate the original value.
     * @param b The bytes object to initialize the buffer with.
     * @return A new buffer.
     */
    function fromBytes(bytes memory b) internal pure returns (buffer memory) {
        buffer memory buf;
        buf.buf = b;
        buf.capacity = b.length;
        return buf;
    }

    function resize(buffer memory buf, uint capacity) private pure {
        bytes memory oldbuf = buf.buf;
        init(buf, capacity);
        append(buf, oldbuf);
    }

    function max(uint a, uint b) private pure returns (uint) {
        if (a > b) {
            return a;
        }
        return b;
    }

    /**
     * @dev Sets buffer length to 0.
     * @param buf The buffer to truncate.
     * @return The original buffer, for chaining..
     */
    function truncate(buffer memory buf) internal pure returns (buffer memory) {
        assembly {
            let bufptr := mload(buf)
            mstore(bufptr, 0)
        }
        return buf;
    }

    /**
     * @dev Writes a byte string to a buffer. Resizes if doing so would exceed
     *      the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param off The start offset to write to.
     * @param data The data to append.
     * @param len The number of bytes to copy.
     * @return The original buffer, for chaining.
     */
    function write(buffer memory buf, uint off, bytes memory data, uint len) internal pure returns (buffer memory) {
        require(len <= data.length);

        if (off + len > buf.capacity) {
            resize(buf, max(buf.capacity, len + off) * 2);
        }

        uint dest;
        uint src;
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Length of existing buffer data
            let buflen := mload(bufptr)
            // Start address = buffer address + offset + sizeof(buffer length)
            dest := add(add(bufptr, 32), off)
            // Update buffer length if we're extending it
            if gt(add(len, off), buflen) {
                mstore(bufptr, add(len, off))
            }
            src := add(data, 32)
        }

        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256**(32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }

        return buf;
    }

    /**
     * @dev Writes a byte string to a buffer. Resizes if doing so would exceed
     *      the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param off The start offset to write to.
     * @param rawData The data to append.
     * @param len The number of bytes to copy.
     * @return The original buffer, for chaining.
     */
    function writeRawBytes(buffer memory buf, uint off, bytes memory rawData, uint offData, uint len) internal pure returns (buffer memory) {
        if (off + len > buf.capacity) {
            resize(buf, max(buf.capacity, len + off) * 2);
        }

        uint dest;
        uint src;
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Length of existing buffer data
            let buflen := mload(bufptr)
            // Start address = buffer address + offset + sizeof(buffer length)
            dest := add(add(bufptr, 32), off)
            // Update buffer length if we're extending it
            if gt(add(len, off), buflen) {
                mstore(bufptr, add(len, off))
            }
            src := add(rawData, offData)
        }

        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256**(32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }

        return buf;
    }

    /**
     * @dev Appends a byte string to a buffer. Resizes if doing so would exceed
     *      the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @param len The number of bytes to copy.
     * @return The original buffer, for chaining.
     */
    function append(buffer memory buf, bytes memory data, uint len) internal pure returns (buffer memory) {
        return write(buf, buf.buf.length, data, len);
    }

    /**
     * @dev Appends a byte string to a buffer. Resizes if doing so would exceed
     *      the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @return The original buffer, for chaining.
     */
    function append(buffer memory buf, bytes memory data) internal pure returns (buffer memory) {
        return write(buf, buf.buf.length, data, data.length);
    }

    /**
     * @dev Writes a byte to the buffer. Resizes if doing so would exceed the
     *      capacity of the buffer.
     * @param buf The buffer to append to.
     * @param off The offset to write the byte at.
     * @param data The data to append.
     * @return The original buffer, for chaining.
     */
    function writeUint8(buffer memory buf, uint off, uint8 data) internal pure returns (buffer memory) {
        if (off >= buf.capacity) {
            resize(buf, buf.capacity * 2);
        }

        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Length of existing buffer data
            let buflen := mload(bufptr)
            // Address = buffer address + sizeof(buffer length) + off
            let dest := add(add(bufptr, off), 32)
            mstore8(dest, data)
            // Update buffer length if we extended it
            if eq(off, buflen) {
                mstore(bufptr, add(buflen, 1))
            }
        }
        return buf;
    }

    /**
     * @dev Appends a byte to the buffer. Resizes if doing so would exceed the
     *      capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @return The original buffer, for chaining.
     */
    function appendUint8(buffer memory buf, uint8 data) internal pure returns (buffer memory) {
        return writeUint8(buf, buf.buf.length, data);
    }

    /**
     * @dev Writes up to 32 bytes to the buffer. Resizes if doing so would
     *      exceed the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param off The offset to write at.
     * @param data The data to append.
     * @param len The number of bytes to write (left-aligned).
     * @return The original buffer, for chaining.
     */
    function write(buffer memory buf, uint off, bytes32 data, uint len) private pure returns (buffer memory) {
        if (len + off > buf.capacity) {
            resize(buf, (len + off) * 2);
        }

        uint mask = 256**len - 1;
        // Right-align data
        data = data >> (8 * (32 - len));
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Address = buffer address + sizeof(buffer length) + off + len
            let dest := add(add(bufptr, off), len)
            mstore(dest, or(and(mload(dest), not(mask)), data))
            // Update buffer length if we extended it
            if gt(add(off, len), mload(bufptr)) {
                mstore(bufptr, add(off, len))
            }
        }
        return buf;
    }

    /**
     * @dev Writes a bytes20 to the buffer. Resizes if doing so would exceed the
     *      capacity of the buffer.
     * @param buf The buffer to append to.
     * @param off The offset to write at.
     * @param data The data to append.
     * @return The original buffer, for chaining.
     */
    function writeBytes20(buffer memory buf, uint off, bytes20 data) internal pure returns (buffer memory) {
        return write(buf, off, bytes32(data), 20);
    }

    /**
     * @dev Appends a bytes20 to the buffer. Resizes if doing so would exceed
     *      the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @return The original buffer, for chhaining.
     */
    function appendBytes20(buffer memory buf, bytes20 data) internal pure returns (buffer memory) {
        return write(buf, buf.buf.length, bytes32(data), 20);
    }

    function appendBytes8(buffer memory buf, bytes8 data) internal pure returns (buffer memory) {
        return write(buf, buf.buf.length, bytes32(data), 8);
    }

    /**
     * @dev Appends a bytes32 to the buffer. Resizes if doing so would exceed
     *      the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @return The original buffer, for chaining.
     */
    function appendBytes32(buffer memory buf, bytes32 data) internal pure returns (buffer memory) {
        return write(buf, buf.buf.length, data, 32);
    }

    /**
     * @dev Writes an integer to the buffer. Resizes if doing so would exceed
     *      the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param off The offset to write at.
     * @param data The data to append.
     * @param len The number of bytes to write (right-aligned).
     * @return The original buffer, for chaining.
     */
    function writeInt(buffer memory buf, uint off, uint data, uint len) private pure returns (buffer memory) {
        if (len + off > buf.capacity) {
            resize(buf, (len + off) * 2);
        }

        uint mask = 256**len - 1;
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Address = buffer address + off + sizeof(buffer length) + len
            let dest := add(add(bufptr, off), len)
            mstore(dest, or(and(mload(dest), not(mask)), data))
            // Update buffer length if we extended it
            if gt(add(off, len), mload(bufptr)) {
                mstore(bufptr, add(off, len))
            }
        }
        return buf;
    }

    /**
     * @dev Appends a byte to the end of the buffer. Resizes if doing so would
     * exceed the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @return The original buffer.
     */
    function appendInt(buffer memory buf, uint data, uint len) internal pure returns (buffer memory) {
        return writeInt(buf, buf.buf.length, data, len);
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.5.0;

interface ILayerZeroUserApplicationConfig {
    // @notice set the configuration of the LayerZero messaging library of the specified version
    // @param _version - messaging library version
    // @param _chainId - the chainId for the pending config change
    // @param _configType - type of configuration. every messaging library has its own convention.
    // @param _config - configuration in the bytes. can encode arbitrary content.
    function setConfig(uint16 _version, uint16 _chainId, uint _configType, bytes calldata _config) external;

    // @notice set the send() LayerZero messaging library version to _version
    // @param _version - new messaging library version
    function setSendVersion(uint16 _version) external;

    // @notice set the lzReceive() LayerZero messaging library version to _version
    // @param _version - new messaging library version
    function setReceiveVersion(uint16 _version) external;

    // @notice Only when the UA needs to resume the message flow in blocking mode and clear the stored payload
    // @param _srcChainId - the chainId of the source chain
    // @param _srcAddress - the contract address of the source contract at the source chain
    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external;
}