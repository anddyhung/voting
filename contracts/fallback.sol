//SPDX-License-Identifier:GPL-3.0
pragma solidity ^0.8.24;

contract Fallback {
    event Log(string func, uint gas);

    fallback() external payable {
        emit Log("fallback", gasleft());
    }

    receive() external payable {
        emit Log("receive", gasleft());
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract SentToFallback {
    function transferFallback(address payable _to) public payable {
        _to.transfer(msg.value);
    }

    function callFallback(address payable _to) public payable {
        (bool sent, ) = _to.call{value: msg.value}("");
        require(sent, "Fail to send Ether");
    }
}

contract FallbackInputOutput {
    address immutable _target;

    constructor(address target) {
        _target = target;
    }

    fallback(bytes calldata data) external payable returns (bytes memory) {
        (bool ok, bytes memory res) = _target.call{value: msg.value}(data);
        require(ok, "call failed");
        return res;
    }
}

contract Counter {
    uint public count;

    function get() external view returns (uint) {
        return count;
    }

    function inc() external returns (uint) {
        count += 1;
        return count;
    }
}

contract TestFallbackInputOutput {
    event Log(bytes res);

    function test(address _fallback, bytes calldata data) external {
        (bool ok, bytes memory res) = _fallback.call(data);
        require(ok, "fallback faild");
        emit Log(res);
    }

    function getTestData() external pure returns (bytes memory, bytes memory) {
        return (
            abi.encodeCall(Counter.get, ()),
            abi.encodeCall(Counter.inc, ())
        );
    }
}
