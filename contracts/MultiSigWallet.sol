// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.4;

contract MultiSigWallet{
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(address indexed owner, uint indexed txIndex, address indexed to, uint value, bytes data);
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address[] public owners;
    mapping(address=>bool) public isOwner;
    uint public numConfirmationRequired;
    struct Transaction{
        address to;
        uint value;
        bytes data;
        uint numConfirmation;
        bool executed;
    }
    mapping(uint =>mapping(address=>bool)) public isConfirmed;
    Transaction[] public transactions;

    modifier onlyOwner(){
        require(isOwner[msg.sender],'Not Owner');
        _;
    }

    modifier txExits(uint txIndex){
        require(txIndex<transactions.length, "Transaction not exits.");
        _;
    }

    modifier notConfirmed(uint txIndex){
        require(!isConfirmed[txIndex][msg.sender],"Transaction already confirmed.");
        _;
    }

    modifier notExecuted(uint txIndex){
        require(!transactions[txIndex].executed,"Transaction alreay executed.");
        _;
    }

    constructor(address[] memory _owners, uint _numConfirmationRequired){
        require(_owners.length>0,"owners required");
        require(_numConfirmationRequired>0 && _numConfirmationRequired<_owners.length,"Invalid number of confirmations");
        for(uint i=0;i<_owners.length;i++){
            address owner = _owners[i];
            require(owner!=address(0),"Invalid owner");
            require(!isOwner[owner],"Owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        numConfirmationRequired = _numConfirmationRequired;
    }

    receive() external payable{
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {
        uint txIndex = transactions.length;
        transactions.push(
            Transaction({
                to:_to,
                value:_value,
                data:_data,
                numConfirmation:0,
                executed:false
            })
        );
        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function confirmTransaction(uint txIndex) public onlyOwner notExecuted(txIndex) notConfirmed(txIndex) txExits(txIndex){
        Transaction storage transaction = transactions[txIndex];
        transaction.numConfirmation +=1;
        isConfirmed[txIndex][msg.sender] = true;
        emit ConfirmTransaction(msg.sender, txIndex);
    }

    function executeTransaction(uint txIndex) public onlyOwner txExits(txIndex) notExecuted(txIndex){
        Transaction storage transaction = transactions[txIndex];
        require(transaction.numConfirmation>numConfirmationRequired,"Cannot execute tx");
        transaction.executed = true;
        (bool success, ) = transaction.to.call{value:transaction.value}(transaction.data);
        require(success,"Transaction failed");

        emit ExecuteTransaction(msg.sender, txIndex);
    }

    function revokeConfirmation(uint txIndex) onlyOwner txExits(txIndex) notExecuted(txIndex) public{
        Transaction storage transaction = transactions[txIndex];
        require(isConfirmed[txIndex][msg.sender],"Transaction not confirmed");
        transaction.numConfirmation -=1;
        isConfirmed[txIndex][msg.sender]  = false;
        emit RevokeConfirmation(msg.sender, txIndex);
    }

    function getOwners() public view returns (address[] memory){
        return owners;
    }

    function getTransaction(uint txIndex) public view returns (address to, uint value, bytes memory data, bool executed, uint numConfirmation ){
        Transaction storage transaction = transactions[txIndex];
        return (transaction.to, transaction.value, transaction.data, transaction.executed, transaction.numConfirmation);
    }
}