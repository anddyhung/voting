//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
contract TokenSwap{
    IERC20 public token1;
    address public owner1;
    uint public amount1;
    IERC20 public token2;
    address public owner2;
    uint public amount2;

    constructor(address _token1, address _token2, uint _amount1, uint _amount2, address _owner1, address _owner2){
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
        amount1 = _amount1;
        amount2 = _amount2;
        owner1 = _owner1;
        owner2 = _owner2;
    }

    function swap() public {
        require(msg.sender == owner1 || msg.sender == owner2, "Unauthorized ");
        require(token1.allowance(owner1, address(this))>=amount1,"Insufficient allowance for token1");
        require(token2.allowance(owner2, address(this))>=amount2, "Insufficient allowance for token2");

        _safeTransferFrom(token1, owner1, owner2, amount1);
        _safeTransferFrom(token2, owner2, owner1, amount2);
    }

        function _safeTransferFrom(IERC20 token, address sender, address recipient, uint amount) private {
            bool sent = token.transferFrom(sender, recipient, amount);
            require(sent, "Token Transaction Failed");
        }
    
}