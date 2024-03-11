// SPDX-License-Identifier: GPL-3.0
pragma solidity = 0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface MCOIN {
    function deposit(address token, uint256 amount) external returns (bool);
    function withdraw(address token, address destination, uint256 amount) external returns (bool);
}

contract DepositAccount {
    string public name = "mUSD-Deposit";
    uint public decimals = 18;

    event Deposit(address indexed dst, uint amount);
    event Withdrawal(address indexed src, uint amount);

    mapping(address => uint) public balanceOf;

    address proxy;
    address token;

    constructor(address myproxy, address mytoken) {
        proxy = myproxy;
        token = mytoken;
    }

    function deposit(uint amount) public returns (bool) {
        require(IERC20(token).balanceOf(msg.sender) >= amount);
        require(IERC20(token).transferFrom(msg.sender, address(this), amount));
        require(MCOIN(proxy).mint(msg.sender,amount));
        balanceOf[token] += amount;
        emit Deposit(msg.sender, amount);
        return true;
    }

    function withdraw(address destination, uint amount) public returns (bool) {
        require(IERC20(proxy).balanceOf(msg.sender) >= amount);
        require(MCOIN(proxy).burn(msg.sender,amount));
        balanceOf[token] -= amount;
        require(IERC20(token).transfer(destination, amount));
        emit Withdrawal(msg.sender, amount);
        return true;
    }

    function totalSupply() public view returns (uint) {
        return balanceOf[token];
    }
}