//SPDX-License-Identifier:GPL-3.0

pragma solidity ^0.8.4;

contract Receiver {
    event Receive(address caller, uint value, string message);

    receive() payable external{
        emit Receive(msg.sender, msg.value, 'Fallback was called');
    }

    function foo(string memory _message, uint _x) public payable returns(uint){
        emit Receive(msg.sender, msg.value, _message);
        return _x+1;
    }
}

contract Caller {
    event Response(bool success, bytes data);

    function testCallFoo(address payable _addr) public payable{
        (bool success, bytes memory data) = _addr.call{value:msg.value, gas:5000}(
            abi.encodeWithSignature('foo(string, uint256)', 'call foo', 123)
        );
        emit Response(success, data);
    }

    function testCallDoesNotExit(address payable _addr) public payable{
        (bool success, bytes memory data) = _addr.call{value:msg.value}(
            abi.encodeWithSignature("doesNotExit()")
        );
        emit Response(success, data);
    }
}