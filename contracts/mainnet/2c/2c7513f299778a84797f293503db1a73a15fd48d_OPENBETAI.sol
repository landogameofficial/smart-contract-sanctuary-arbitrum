/**
 *Submitted for verification at Arbiscan on 2023-02-28
*/

// File: contracts/opb2.sol


pragma solidity 0.8.13;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
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
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
 
contract ERC20 is Ownable, IERC20, IERC20Metadata {
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
    constructor(address recipient) {
        require(recipient != address(0), "Parameter can't be zero address");
        uint256 TOTAL_SUPPLY = 10 * 10**6 * 10**18;
        _name = "OpenbetAI";
        _symbol = "OPENBET";
        _mint(recipient,TOTAL_SUPPLY);
        emit Transfer(address(0), recipient, TOTAL_SUPPLY);
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}




interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract OPENBETAI is ERC20 {
  IUniswapV2Router02 public constant uniswapV2Router= IUniswapV2Router02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
  address public immutable pair;

  address public developmentWallet;
  address public marketingWallet;
  address public rewardWallet;

  uint256 public maxWallet;

  uint256 public swapThreshold;
  bool public swapEnabled;

  bool tradingEnabled;
  bool inSwap;

  uint256 public buyTax = 500;
  uint256 public sellTax = 500;
  uint256 public transferTax = 0;
  uint256 public rewardShare = 600;
  uint256 public marketingShare = 200;
  uint256 public developmentShare = 200;
  uint256 totalShares = 1000;
  uint256 constant TAX_DENOMINATOR = 10000;

  uint256 public transferGas = 25000;

  mapping (address => bool) public isWhitelisted;
  mapping (address => bool) public isCEX;
  mapping (address => bool) public isMarketMaker;

  event EnableTrading();
  event TriggerSwapBack();
  event Burn(uint256 amount);
  event RecoverETH(uint256 amount);
  event RecoverERC20(address indexed token, uint256 amount);
  event SetWhitelisted(address indexed account, bool indexed status);
  event SetCEX(address indexed account, bool indexed exempt);
  event SetMarketMaker(address indexed account, bool indexed isMM);
  event SetTaxes(uint256 reward, uint256 liquidity, uint256 marketing);
  event SetShares(uint256 rewardShare, uint256 developmentShare, uint256 marketingShare);
  event SetSwapBackSettings(bool enabled, uint256 amount);
  event SetTransferGas(uint256 newGas, uint256 oldGas);
  event SetDevelopmentWallet(address newWallet, address oldWallet);
  event SetMarketingWallet(address newWallet, address oldWallet);
  event SetrewardWallet(address newAddress, address oldAddress);
  event DepositDevelopment(address indexed wallet, uint256 amount);
  event DepositMarketing(address indexed wallet, uint256 amount);
  event DepositRewards(address indexed wallet, uint256 amount);
  event UpdatedmaxWallet(uint256 amount);

  modifier swapping() { 
    inSwap = true;
    _;
    inSwap = false;
  }

  constructor(
    address owner,
    address marketing,
    address development,
    address reward
  ) ERC20(owner) {
    require(development != address(0) && reward != address(0), "Parameter can't be zero address");

    pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(uniswapV2Router.WETH(), address(this));
    _approve(address(this), address(uniswapV2Router), type(uint256).max);
    isMarketMaker[pair] = true;

    rewardWallet = reward;
    marketingWallet = marketing;
    developmentWallet = development;
    isWhitelisted[marketingWallet] = true;
    isWhitelisted[owner] = true;

    uint256 maxWalletPcnt = 2;   
    maxWallet = totalSupply() * maxWalletPcnt / 1000; // 0.2% max wallet
  }

  // Override

  function _transfer(address sender, address recipient, uint256 amount) internal override {
    if (isWhitelisted[sender] || isWhitelisted[recipient] || inSwap) {
      super._transfer(sender, recipient, amount);
      return;
    }
    
    require(tradingEnabled, "Trading is disabled");
    if (isMarketMaker[sender]) {
      require(amount + balanceOf(recipient) <= maxWallet, "Max wallet exceeded");
    }

    if (_shouldSwapBack(recipient)) { _swapBack(); }

    uint256 amountAfterTaxes = _takeTax(sender, recipient, amount);

    super._transfer(sender, recipient, amountAfterTaxes);
  }

  receive() external payable {}

  // Private

  function _takeTax(address sender, address recipient, uint256 amount) private returns (uint256) {
    if (amount == 0) { return amount; }

    uint256 taxAmount = amount * _getTotalTax(sender, recipient) / TAX_DENOMINATOR;
    if (taxAmount > 0) { super._transfer(sender, address(this), taxAmount); }

    return amount - taxAmount;
  }

  function _getTotalTax(address sender, address recipient) private view returns (uint256) {
    if (isCEX[recipient]) { return 0; }
    if (isCEX[sender]) { return buyTax; }

    if (isMarketMaker[sender]) {
      return buyTax;
    } else if (isMarketMaker[recipient]) {
      return sellTax;
    } else {
      return transferTax;
    }
  }

  function _shouldSwapBack(address recipient) private view returns (bool) {
    return isMarketMaker[recipient] && swapEnabled && balanceOf(address(this)) >= swapThreshold;
  }

  function _swapBack() private swapping {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();
    uint256 balanceBefore = address(this).balance;

    uniswapV2Router.swapExactTokensForETH(
      swapThreshold,
      0,
      path,
      address(this),
      block.timestamp
    );

    uint256 amountETH = address(this).balance - balanceBefore;
    uint256 amountETHDevelopment = amountETH * developmentShare / totalShares;
    uint256 amountETHMarketing = amountETH * marketingShare / totalShares;
    uint256 amountETHRewards = amountETH * rewardShare / totalShares;

    (bool developmentSuccess,) = payable(developmentWallet).call{value: amountETHDevelopment, gas: transferGas}("");
    if (developmentSuccess) { emit DepositDevelopment(developmentWallet, amountETHDevelopment); }

    (bool marketingSuccess,) = payable(marketingWallet).call{value: amountETHMarketing, gas: transferGas}("");
    if (marketingSuccess) { emit DepositMarketing(marketingWallet, amountETHMarketing); }

    (bool rewardSuccess,) = payable(rewardWallet).call{value: amountETHRewards, gas: transferGas}("");
    if (rewardSuccess) { emit DepositRewards(rewardWallet, amountETHRewards); }
  }

  function updateMaxWallet(uint256 amount) external onlyOwner {
        require(amount >= 1,"Minimum value is 1.");
        maxWallet = totalSupply() * amount / 1000; // 0.2% max wallet
        emit UpdatedmaxWallet(amount);
    }



  // Owner

  function enableTrading() external onlyOwner {
    tradingEnabled = true;
    emit EnableTrading();
  }


  function triggerSwapBack() external onlyOwner {
    _swapBack();
    emit TriggerSwapBack();
  }

  function burnFromStorage(uint256 amount) external onlyOwner {
    uint256 tokenAmount = amount * 10**decimals();
    super._transfer(address(this), address(0xdead), tokenAmount);
    emit Burn(amount);
  }

  function recoverETH() external onlyOwner {
    uint256 amount = address(this).balance;
    (bool sent,) = payable(marketingWallet).call{value: amount, gas: transferGas}("");
    require(sent, "Tx failed");
    emit RecoverETH(amount);
  }

  function recoverERC20(IERC20 token, address recipient) external onlyOwner {
    require(address(token) != address(this), "Can't withdraw OPENBET");
    uint256 amount = token.balanceOf(address(this));
    token.transfer(recipient, amount);
    emit RecoverERC20(address(token), amount);
  }

  function setIsWhitelisted(address account, bool value) external onlyOwner {
    isWhitelisted[account] = value;
    emit SetWhitelisted(account, value);
  }

  function setIsCEX(address account, bool value) external onlyOwner {
    isCEX[account] = value;
    emit SetCEX(account, value);
  }

  function setIsMarketMaker(address account, bool value) external onlyOwner {
    require(account != pair, "Can't modify pair");
    isMarketMaker[account] = value;
    emit SetMarketMaker(account, value);
  }

  function setTaxes(uint256 newBuyTax, uint256 newSellTax, uint256 newTransferTax) external onlyOwner {
    require(newBuyTax <= 1000 && newSellTax <= 2000, "Too high taxes");
    buyTax = newBuyTax;
    sellTax = newSellTax;
    transferTax = newTransferTax;
    emit SetTaxes(buyTax, sellTax, transferTax);
  }

  function setShares(
    uint256 newRewardShare,
    uint256 newDevelopmentShare,
    uint256 newMarketingShare
  ) external onlyOwner {
    totalShares = rewardShare + developmentShare + marketingShare;
    require(totalShares>0,"Total shares must be greater than 0.");
    rewardShare = newRewardShare;
    developmentShare = newDevelopmentShare;
    marketingShare = newMarketingShare;
    
    emit SetShares(rewardShare, developmentShare, marketingShare);
  }

  function setSwapBackSettings(bool enabled, uint256 amount) external onlyOwner {
    swapEnabled = enabled;
    swapThreshold = amount;
    emit SetSwapBackSettings(enabled, amount);
  }

  function setTransferGas(uint256 newGas) external onlyOwner {
    require(newGas >= 21000 && newGas <= 50000, "Invalid gas parameter");
    emit SetTransferGas(newGas, transferGas);
    transferGas = newGas;
  }

  function setDevelopmentWallet(address newWallet) external onlyOwner {
    require(newWallet != address(0), "New development wallet is the zero address");
    emit SetDevelopmentWallet(newWallet, developmentWallet);
    developmentWallet = newWallet;
  }

  function setMarketingWallet(address newWallet) external onlyOwner {
    require(newWallet != address(0), "New marketing wallet is the zero address");
    emit SetMarketingWallet(newWallet, marketingWallet);
    marketingWallet = newWallet;
  }

  function setrewardWallet(address newAddress) external onlyOwner {
    require(newAddress != address(0), "New reward pool is the zero address");
    emit SetrewardWallet(newAddress, rewardWallet);
    rewardWallet = newAddress;
  }
}