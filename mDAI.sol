// SPDX-License-Identifier: GPL-3.0
pragma solidity = 0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function increaseAllowance(address spender, uint256 value) external returns (bool);
    function decreaseAllowance(address spender, uint256 value) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract ERC20 {
    string public name = 'Murioil-DAI';
    string public symbol = 'mDAI';
    uint public decimals = 18;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => bool) public isUser;
    address[] public users;
    address public minter;
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);    

    constructor() {
        minter = msg.sender;
    }

    function changeMinter(address newminter) external returns (bool) {
        require (msg.sender == minter);
        minter = newminter;
        return true;
    }

    function mint(address to, uint value) external returns (bool) {
        require (msg.sender == minter);
        if(!isUser[to]) {
            isUser[to] = true;
            users.push(to);
        }
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
        return true;
    }

    function burn(address from, uint value) external returns (bool) {
        require (msg.sender == minter);
        totalSupply -= value;
        balanceOf[from] -= value;
        emit Transfer(from, address(0), value);
        return true;
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        if(!isUser[to]) {
            isUser[to] = true;
            users.push(to);
        }
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint value) external returns (bool) {
        allowance[msg.sender][spender] += value;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }
    
    function decreaseAllowance(address spender, uint value) external returns (bool) {
        allowance[msg.sender][spender] -= value;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {
        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }
}