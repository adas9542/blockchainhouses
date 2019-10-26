pragma solidity ^0.5.2;
contract BallotV4 {

    struct Voter {                     
        uint weight;
        bool voted;
        uint8 vote;
        uint8 votes;
        bool paymentinfo;
        bool purchasedToday;
    }
    struct Proposal {                  
        uint voteCount;
    }

    address chairperson;
    mapping(address => Voter) voters;  
    Proposal[] proposals;
    

    enum Phase {Init,Regs, Vote, Done}  
    Phase public state = Phase.Done; 
    
       //modifiers
   modifier validPhase(Phase reqPhase) 
    { require(state == reqPhase); 
      _; 
    } 
    modifier onlyChair() 
     {require(msg.sender == chairperson);
      _;
     }
     modifier hasVotes()
     {require(voters[msg.sender].votes >= 1);
      _;
     }
     modifier hasMoney()
     {require(voters[msg.sender].paymentinfo == true);
     _;
     }
     
    constructor (uint8 numProposals) public  {
        chairperson = msg.sender;
        voters[chairperson].weight = 2; // weight 2 for testing purposes
        proposals.length = numProposals;
        state = Phase.Regs;
    }
    
     function changeState(Phase x) onlyChair public {
        
        require (x > state );
       
        state = x;
     }
    
    function register(address voter) public validPhase(Phase.Regs) onlyChair {
       
        require (! voters[voter].voted);
        
        voters[voter].weight = 1;
        voters[voter].votes = 10;
        voters[voter].paymentinfo = true;
        voters[voter].purchasedToday = false;
        
       // voters[voter].voted = false;
    }

   
    function vote(uint8 toProposal) hasVotes() public{
      
        Voter memory sender = voters[msg.sender];
        
        require (!sender.voted); 
        require (toProposal < proposals.length); 
        require (sender.votes >= 1);
        
        sender.voted = true;
        sender.vote = toProposal;   
        proposals[toProposal].voteCount += 1;
        voters[msg.sender].votes -= 1;
    }

    function reqWinner() public validPhase(Phase.Done) view returns (uint8 winningProposal) {
       
        uint256 winningVoteCount = 0;
        for (uint8 prop = 0; prop < proposals.length; prop++) 
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                winningProposal = prop;
            }
       assert(winningVoteCount>=1);
    }
    
    function checkVotes() public view returns (uint8 votesLeft) {
        
        votesLeft = voters[msg.sender].votes;
    }
    
    function buyVotes() public hasMoney(){
        require(voters[msg.sender].purchasedToday = false);
        
        voters[msg.sender].votes += 10;
        voters[msg.sender].purchasedToday = true;
    }
}