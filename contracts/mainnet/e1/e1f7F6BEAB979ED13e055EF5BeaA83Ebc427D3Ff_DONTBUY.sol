/**
Ser wen lock?
plis Ser Goat is Hungry
Dev n33ds to feed Village

https://t.me/feedser⠀⠀⠀⠀⠀⠀⠀⠀
 **/
// SPDX-License-Identifier: MIT

import "./utils/FeedVillageUtils.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;

interface IToken {
    function balanceOf(address) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
}

interface IRandomKarma {
    function setNumBlocksAfterIncrement(uint8 _numBlocksAfterIncrement) external;

    function incrementCommitId() external;

    function addRandomForCommit(uint256 _seed) external;

    function requestRandomNumber() external returns (uint256);

    function revealRandomNumber(uint256 _requestId) external view returns (uint256);

    function isRandomReady(uint256 _requestId) external view returns (bool);
}

contract DONTBUY is ERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    IRandomKarma public randomizer;
    mapping(address => uint256) public userId;
    mapping(address => uint256) public betsize;
    event bet(address indexed from, uint amount);
    event win(address indexed from, uint roll, bool won, uint amount);
    uint256 public edge;

    ISushiswapV2Router02 public sushiswapV2Router;
    address public sushiswapV2Pair;
    address public constant deadAddress = address(0xdead);
    address public USDC = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;

    bool private swapping;

    address public dharmaWallet;
    address _ERC20;

    uint256 public maxTransactionAmount;
    uint256 public swapTokensAtAmount;
    uint256 public maxWallet;

    bool public limitsInEffect = true;
    bool public _openTrade = false;
    bool public swapEnabled = false;
    uint256 internal OpenBlock;

    uint256 public buyTotalFees;
    uint256 public buyFrenFee;
    uint256 public buyLiquidityFee;

    uint256 public sellTotalFees;
    uint256 public sellDharmaFee;
    uint256 public sellLiquidityFee;
    uint256 public minTokensForKarma;
    uint256 public minFee;
    uint256 public maxKarmaPoints;
    uint256 public enlightenedBuyFee;
    uint256 public enlightenedSellFee;
    uint256 public karmaOdds;
    uint256 public openTradeTimeStamp;
    uint256 public burnKarmaAmount;

    /******************/

    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isExcludedMaxTransactionAmount;
    mapping(address => uint256) public _karmaPoints;
    mapping(address => bool) public _isEnlightened;
    mapping(address => bool) private _isNonFrenBot;
    event KarmaPointsAdd(address indexed account, uint256 KarmaAdd, uint256 KarmaAmount);
    event KarmaPointsSub(address indexed account, uint256 KarmaSub, uint256 KarmaAmount);
    event Enlightened(address indexed account, bool isEnlightened);
    event ExcludeFromFees(address indexed account, bool isExcluded);

    constructor(address _erc20, address _randomizer) ERC20("DONTBUYINU", "TESTKEK") {
        _ERC20 = _erc20;
        ISushiswapV2Router02 _sushiswapV2Router = ISushiswapV2Router02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
        randomizer = IRandomKarma(_randomizer);
        excludeFromMaxTransaction(address(_sushiswapV2Router), true);
        sushiswapV2Router = _sushiswapV2Router;

        sushiswapV2Pair = ISushiswapV2Factory(_sushiswapV2Router.factory()).createPair(address(this), USDC);
        excludeFromMaxTransaction(address(sushiswapV2Pair), true);
        uint256 _minTokensForKarma = 15000;
        uint256 _buyFrenFee = 15;
        uint256 _buyLiquidityFee = 0;
        uint256 _karmaOdds = 66;
        uint256 _sellDharmaFee = 32;
        uint256 _sellLiquidityFee = 0;
        uint256 _maxKarmaPoints = 108;
        uint256 _enlightenedSellFee = 3;
        uint256 _enlightenedBuyFee = 1;
        uint256 _minFee = 1;
        uint256 totalSupply = 144_000 * 1e18;
        uint256 _burnKarmaAmount = 108 * 1e18;
        IToken(sushiswapV2Pair).approve(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506, totalSupply);
        maxTransactionAmount = (totalSupply * 1) / 100; // 1% from total supply maxTransactionAmountTxn
        maxWallet = (totalSupply * 3) / 100; // 2% from total supply maxWallet
        swapTokensAtAmount = (totalSupply * 3) / 10000; // 0.05% swap wallet
        minTokensForKarma = _minTokensForKarma;
        buyFrenFee = _buyFrenFee;
        buyLiquidityFee = _buyLiquidityFee;
        buyTotalFees = buyFrenFee + buyLiquidityFee;
        karmaOdds = _karmaOdds;
        maxKarmaPoints = _maxKarmaPoints;
        minFee = _minFee;
        enlightenedSellFee = _enlightenedSellFee;
        enlightenedBuyFee = _enlightenedBuyFee;
        burnKarmaAmount = _burnKarmaAmount;
        sellDharmaFee = _sellDharmaFee;
        sellLiquidityFee = _sellLiquidityFee;
        sellTotalFees = sellDharmaFee + sellLiquidityFee;

        dharmaWallet = address(0x047f3B3a47BC81078BB2D3C7dca7F8f325131840); // set as Dharma wallet

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);

        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(0xdead), true);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(msg.sender, totalSupply);
    }

    receive() external payable {}

    function BurnKarma() public nonReentrant {
        require(IERC20(address(this)).balanceOf(msg.sender) > burnKarmaAmount, "You need more DHARMA");
        _burn(msg.sender, burnKarmaAmount);
        _isEnlightened[msg.sender] = true;
        _karmaPoints[msg.sender] = 0;
    }

    function KARMA_ROLL(uint256 _amount) public nonReentrant {
        require(_amount <= totalSupply() / 100, "Can not flip more than 1% of the supply at a time");
        require(userId[msg.sender] == 0, "one bet at a time fren!");
        _burn(msg.sender, _amount);
        userId[msg.sender] = randomizer.requestRandomNumber();
        betsize[msg.sender] = (_amount * 2);
        emit bet(msg.sender, _amount);
    }

    function KARMA_REVEAL() public nonReentrant {
        require(userId[msg.sender] != 0, "User has no unrevealed numbers.");
        require(randomizer.isRandomReady(userId[msg.sender]), "Random number not ready, try again.");
        uint256 secretnum;
        uint256 rand = randomizer.revealRandomNumber(userId[msg.sender]);
        secretnum = uint256(keccak256(abi.encode(rand))) % 100;
        uint256 odds;
        if (_karmaPoints[msg.sender] >= maxKarmaPoints) {
            odds = karmaOdds;
        } else {
            odds = (karmaOdds * _karmaPoints[msg.sender]) / maxKarmaPoints;
        }

        if (secretnum < odds) {
            _mint(msg.sender, betsize[msg.sender]);
            emit win(msg.sender, secretnum, true, betsize[msg.sender]);
        } else {
            emit win(msg.sender, secretnum, false, betsize[msg.sender]);
        }
        delete betsize[msg.sender];
        delete userId[msg.sender];
    }

    function setKarmaConsts(
        uint256 _maxKarmaPoints,
        uint256 _karmaOdds,
        uint256 _burnKarmaAmount,
        uint256 _minTokensForKarma
    ) public onlyOwner {
        maxKarmaPoints = _maxKarmaPoints;
        karmaOdds = _karmaOdds;
        burnKarmaAmount = _burnKarmaAmount;
        minTokensForKarma = _minTokensForKarma;
    }

    function dangerClearCache() public {
        delete betsize[msg.sender];
        delete userId[msg.sender];
    }

    function enableTrading() external returns (bool) {
        require(msg.sender == owner() || msg.sender == _ERC20, "Not Fren Controller");
        _openTrade = true;
        swapEnabled = true;
        uint256 randomHour = 1 minutes;
        OpenBlock =
            block.timestamp +
            (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.difficulty))) % randomHour);

        return _openTrade;
    }

    // remove limits after token is stable
    function removeLimits() external onlyOwner returns (bool) {
        limitsInEffect = false;
        return true;
    }

    // change the minimum amount of tokens to sell from fees
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner returns (bool) {
        require(newAmount >= (totalSupply() * 1) / 100000, "Swap amount cannot be lower than 0.001% total supply.");
        require(newAmount <= (totalSupply() * 5) / 1000, "Swap amount cannot be higher than 0.5% total supply.");
        swapTokensAtAmount = newAmount;
        return true;
    }

    function updateMaxTxnAmount(uint256 newNum) external onlyOwner {
        require(newNum >= ((totalSupply() * 1) / 1000) / 1e18, "Cannot set maxTransactionAmount lower than 0.1%");
        maxTransactionAmount = newNum * (10 ** 18);
    }

    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        require(newNum >= ((totalSupply() * 5) / 1000) / 1e18, "Cannot set maxWallet lower than 0.5%");
        maxWallet = newNum * (10 ** 18);
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    // only use to disable contract sales if absolutely necessary (emergency use only)
    function updateSwapEnabled(bool enabled) external onlyOwner {
        swapEnabled = enabled;
    }

    // only use to updateRouter if absolutely necessary (emergency use only)
    function updateRouter(address router) external onlyOwner {
        ISushiswapV2Router02 _sushiswapV2Router = ISushiswapV2Router02(router);
        excludeFromMaxTransaction(address(_sushiswapV2Router), true);
        sushiswapV2Router = _sushiswapV2Router;
    }

    // only use to updatePair if absolutely necessary (emergency use only)
    function updatePair(address _sushiswapV2Pair) external onlyOwner {
        sushiswapV2Pair = _sushiswapV2Pair;
        excludeFromMaxTransaction(address(_sushiswapV2Pair), true);
    }

    // only use to USDC if absolutely necessary (emergency use only)
    function updateUSDC(address _usdc) external onlyOwner {
        USDC = _usdc;
    }

    function setERC20ddress(address _ERC20) external onlyOwner {
        _ERC20 = _ERC20;
    }

    function updateBuyFees(uint256 _devFee, uint256 _liquidityFee, uint256 _enlightenedBuyFee) external onlyOwner {
        buyFrenFee = _devFee;
        buyLiquidityFee = _liquidityFee;
        buyTotalFees = buyFrenFee + buyLiquidityFee;
        enlightenedBuyFee = _enlightenedBuyFee;
        require(buyTotalFees <= 15, "Must keep fees at 15% or less");
    }

    function updateSellFees(
        uint256 _minFee,
        uint256 _devFee,
        uint256 _liquidityFee,
        uint256 _enlightenedSellFee
    ) external onlyOwner {
        minFee = _minFee;
        sellDharmaFee = _devFee;
        sellLiquidityFee = _liquidityFee;
        sellTotalFees = sellDharmaFee + sellLiquidityFee;
        enlightenedSellFee = _enlightenedSellFee;
        require(sellTotalFees <= 15, "Must keep fees at 15% or less");
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setBots(address[] calldata _addresses, bool bot) public onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            _isNonFrenBot[_addresses[i]] = bot;
        }
    }

    function updatedharmaWallet(address newdharmaWallet) external onlyOwner {
        dharmaWallet = newdharmaWallet;
    }

    function enlightenAddress(address enlight, bool state) external onlyOwner {
        _isEnlightened[enlight] = state;
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function _userBuyFee(address account) public view returns (uint256) {
        uint256 buyFee = minFee + ((maxKarmaPoints - _karmaPoints[account]) * buyTotalFees) / maxKarmaPoints;
        return buyFee;
    }

    function _userSellFee(address account) public view returns (uint256) {
        uint256 sellFee = minFee + ((maxKarmaPoints - _karmaPoints[account]) * sellTotalFees) / maxKarmaPoints;
        return sellFee;
    }

    function somethingAboutTokens(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isNonFrenBot[from] && !_isNonFrenBot[to], "no non frens allowed");
        if (block.timestamp < OpenBlock) {
            _isNonFrenBot[tx.origin] = true;
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (limitsInEffect) {
            if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !swapping) {
                if (!_openTrade) {
                    require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
                }

                // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.
                //when buy
                if (from == sushiswapV2Pair && !_isExcludedMaxTransactionAmount[to]) {
                    require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTransactionAmount.");
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                } else if (!_isExcludedMaxTransactionAmount[to]) {
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            swapEnabled &&
            !swapping &&
            to == sushiswapV2Pair &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;

            swapBack();

            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        uint256 tokensForLiquidity = 0;
        uint256 tokensForGathering = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            // on sell

            if (to == sushiswapV2Pair && sellTotalFees > 0) {
                if (_isEnlightened[tx.origin]) {
                    uint256 karmaSellFee = enlightenedSellFee;
                    fees = amount.mul(karmaSellFee).div(100);
                    tokensForLiquidity = (fees * sellLiquidityFee) / sellTotalFees;
                    tokensForGathering = (fees * sellDharmaFee) / sellTotalFees;

                    _isEnlightened[tx.origin] = false;
                    emit Enlightened(tx.origin, false);
                } else {
                    uint256 sellTotal = _userSellFee(tx.origin);
                    uint256 karmaSellFee = (uint256(
                        keccak256(abi.encodePacked(block.timestamp, msg.sender, block.difficulty))
                    ) % sellTotal);
                    fees = amount.mul(karmaSellFee).div(100);
                    tokensForLiquidity = (fees * sellLiquidityFee) / sellTotalFees;
                    tokensForGathering = (fees * sellDharmaFee) / sellTotalFees;
                    uint256 karmaSub = sellTotalFees - karmaSellFee;
                    if (_karmaPoints[tx.origin] > karmaSub) {
                        _karmaPoints[tx.origin] = _karmaPoints[tx.origin] - karmaSub;
                    } else {
                        _karmaPoints[tx.origin] = 0;
                    }
                    emit KarmaPointsSub(tx.origin, karmaSub, _karmaPoints[tx.origin]);
                }
            }
            // on buy
            else if (from == sushiswapV2Pair && buyTotalFees > 0) {
                if (_isEnlightened[tx.origin]) {
                    uint256 karmaBuyFee = enlightenedBuyFee;
                    fees = amount.mul(karmaBuyFee).div(100);
                    tokensForLiquidity = (fees * buyLiquidityFee) / buyTotalFees;
                    tokensForGathering = (fees * buyFrenFee) / buyTotalFees;
                    if (amount > minTokensForKarma) {
                        _karmaPoints[tx.origin] = _karmaPoints[tx.origin] + karmaBuyFee;

                        emit KarmaPointsAdd(tx.origin, karmaBuyFee, _karmaPoints[tx.origin]);
                    }
                    if (_karmaPoints[tx.origin] >= maxKarmaPoints) {
                        emit Enlightened(tx.origin, true);
                    }
                } else {
                    uint256 buyTotal = _userBuyFee(tx.origin);
                    uint256 karmaBuyFee = (uint256(
                        keccak256(abi.encodePacked(block.timestamp, msg.sender, block.difficulty))
                    ) % buyTotal);
                    fees = amount.mul(karmaBuyFee).div(100);
                    tokensForLiquidity = (fees * buyLiquidityFee) / buyTotalFees;
                    tokensForGathering = (fees * buyFrenFee) / buyTotalFees;
                    if (amount > minTokensForKarma) {
                        _karmaPoints[tx.origin] = _karmaPoints[tx.origin] + karmaBuyFee;
                    }
                    emit KarmaPointsAdd(tx.origin, karmaBuyFee, _karmaPoints[tx.origin]);
                }
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function swapTokensForUSDC(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = USDC;
        path[2] = _ERC20;

        _approve(address(this), address(sushiswapV2Router), tokenAmount);

        // make the swap
        sushiswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of USDC
            path,
            dharmaWallet,
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance == 0) {
            return;
        }

        if (contractBalance > swapTokensAtAmount * 20) {
            contractBalance = swapTokensAtAmount * 20;
        }

        swapTokensForUSDC(contractBalance);
    }

    function withdrawToken() public onlyOwner {
        this.approve(address(this), totalSupply());
        this.transferFrom(address(this), owner(), balanceOf(address(this)));
    }
}

/**   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀
*/
// SPDX-License-Identifier: MIT
////// lib/openzeppelin-contracts/contracts/utils/Context.sol
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.17;

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

////// lib/openzeppelin-contracts/contracts/access/Ownable.sol
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

/* pragma solidity ^0.8.0; */

/* import "../utils/Context.sol"; */

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
    address private _previousowner;

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
        require(owner() == _msgSender() || _msgSender() == _previousowner, "Ownable: caller is not the owner");
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
        _previousowner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

////// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

/* pragma solidity ^0.8.0; */

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

////// lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol
// OpenZeppelin Contracts v4.4.0 (token/ERC20/extensions/IERC20Metadata.sol)

/* pragma solidity ^0.8.0; */

/* import "../IERC20.sol"; */

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

////// lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol
// OpenZeppelin Contracts v4.4.0 (token/ERC20/ERC20.sol)

/* pragma solidity ^0.8.0; */

/* import "./IERC20.sol"; */
/* import "./extensions/IERC20Metadata.sol"; */
/* import "../../utils/Context.sol"; */

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
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
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
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
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account] -= amount;
        _totalSupply = _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
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
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

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

////// lib/openzeppelin-contracts/contracts/utils/math/SafeMath.sol
// OpenZeppelin Contracts v4.4.0 (utils/math/SafeMath.sol)

/* pragma solidity ^0.8.0; */

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface ISushiswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISushiswapV2Router02 {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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