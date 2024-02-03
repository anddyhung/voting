//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import './IERC20.sol';

contract ERC20 is IERC20{
    uint public totalSupply;
    mapping(address=>uint) public balanceOf;
    mapping(address=>mapping(address=>uint)) public allowance;
    string public name = "Solidity by Example";
    string public symbol = "SOLBYEX";
    uint8 public decimal = 18;

    function transfer(address _to, uint _amount) external returns (bool){
        balanceOf[msg.sender] -=_amount;
        balanceOf[_to] +=_amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(address _spender, uint amount) external returns (bool){
        allowance[msg.sender][_spender] = amount;
        emit Approval(msg.sender, _spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) external returns(bool){
        allowance[sender][msg.sender] -=amount;
        balanceOf[sender] -=amount;
        balanceOf[recipient] +=amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint amount) external{
        balanceOf[msg.sender] +=amount;
        totalSupply +=amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external{
        balanceOf[msg.sender] -=amount;
        totalSupply -=amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}