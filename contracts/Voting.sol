//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Voting{
    struct Voter{
        uint256 weight;
        bool voted;
        address delegate;
        uint vote;
    }
    struct Proposal{
        bytes32 name;
        uint voteCount;
    }
    address public chairperson;
    mapping(address=>Voter) public voters;
    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames){
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        for (uint i = 0; i<proposalNames.length; i++){
            proposals.push(Proposal({
                name:proposalNames[i],
                voteCount :0
            }));
        }
    }
    function giveRightVote(address voter) external{
        require(
            msg.sender == chairperson,
            "Only chairperson can give right vote!"
        );
        require(
            !voters[voter].voted,
            "The voter already votted!"
        );
        require(
            voters[voter].weight ==0
            );
        voters[voter].weight = 1;
    }

    function delegate (address to) external{
        Voter storage sender = voters[msg.sender];
        require(sender.weight!=0,"You have no right to vote");
        require(!sender.voted,"You have already voted");
        require(to!=msg.sender,"You are not allowed to vite yourself");
        while(voters[to].delegate !=  address(0)){
            to = voters[to].delegate;
            require(to!=msg.sender,"Found loop in delegation");
        }
        Voter storage delegate_ = voters[to];
        require(delegate_.weight>=1);
        sender.voted = true;
        sender.delegate = to;
        if(delegate_.voted){
            proposals[delegate_.vote].voteCount += sender.weight;
        }
        else{
            delegate_.weight+=sender.weight;
        }
    }

    function winningProposal() public view returns (uint winningProposal_){
        uint winningVoteCount = 0;
        for(uint i=0; i<proposals.length;i++){
            if(proposals[i].voteCount>winningVoteCount){
                winningVoteCount = proposals[i].voteCount;
                winningProposal_ = i;
            }
        }
    }

    function winnerName() external view returns (bytes32 winnerName_){
        winnerName_ = proposals[winningProposal()].name;
    }
}