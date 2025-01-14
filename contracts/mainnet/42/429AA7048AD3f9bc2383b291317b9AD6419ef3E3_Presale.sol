// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./sources/IERC20.sol";

contract Presale {
    uint public publicPrice;
    uint public privatePrice;
    uint public maxAlloc;

    address public owner;
    address public token;
    address public usdc;

    bool public presaleIsOpen;
    bool public claimIsOpen;

    mapping(address => uint) public alloc;
    mapping(address => bool) public isWhitelisted;

    constructor(
        uint _publicPrice,
        uint _privatePrice,
        uint _maxAlloc,
        address _token
    ) {
        owner = msg.sender;
        publicPrice = _publicPrice;
        privatePrice = _privatePrice;
        maxAlloc = _maxAlloc;
        token = _token;
    }

    function enterPublic(uint _tokenAmount) public {
        require(presaleIsOpen == true, "Presale is closed");
        require(_tokenAmount > 0, "Wrong value");
        require(
            alloc[msg.sender] + _tokenAmount <= maxAlloc,
            "Max alloc reached"
        );

        uint price = _tokenAmount * publicPrice / 1e18;
        IERC20(usdc).transferFrom(msg.sender, address(this), price);
        alloc[msg.sender] += _tokenAmount;
    }

    function enterPrivate(uint _tokenAmount) public {
        require(presaleIsOpen == true, "Presale is closed");
        require(isWhitelisted[msg.sender] == true, "Not whitelisted");
        require(_tokenAmount > 0, "Wrong value");
        require(
            alloc[msg.sender] + _tokenAmount <= maxAlloc,
            "Max alloc reached"
        );

        uint price = _tokenAmount * privatePrice / 1e18;
        IERC20(usdc).transferFrom(msg.sender, address(this), price);
        alloc[msg.sender] += _tokenAmount;
    }

    function claim() public {
        require(claimIsOpen == true, "Claim closed");
        require(alloc[msg.sender] > 0, "Nothing to claim");
        IERC20(token).transfer(msg.sender, alloc[msg.sender]);
        alloc[msg.sender] = 0;
    }

    function whitelistUser(address _user) public onlyOwner {
        isWhitelisted[_user] = true;
    }

    function whitelistTwenty(address[20] memory _users) public onlyOwner {
        for (uint i; i < 20; i++) {
            isWhitelisted[_users[i]] = true;
        }
    }

    function openPresale() public onlyOwner {
        presaleIsOpen = true;
    }

    function closePresale() public onlyOwner {
        presaleIsOpen = false;
    }

    function openClaim() public onlyOwner {
        claimIsOpen = true;
    }

    function closeClaim() public onlyOwner {
        claimIsOpen = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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