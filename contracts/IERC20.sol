//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function transfer(address _to, uint _amount) external returns (bool);

    function balanceOf(address _account) external view returns (uint);

    function allowance(address _owner, address _spender) external view returns (uint);

    function approve(address _to, uint _amount) external returns (bool);

    function transferFrom(address _sender, address _recipient, uint _amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint amount);
    
    event Approval(address indexed owner, address indexed spender, uint value);
}
