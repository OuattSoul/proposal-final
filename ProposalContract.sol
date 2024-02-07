// SPDX-License-Identifier: MIT


pragma solidity ^0.8.18;
contract ProposalContract {

    address owner;
    address[] private voted_addresses;

    uint256 private counter;

    event VoteEvent(uint8 indexed vote_choice, string _message);
    event VoteEnd(string _message);

    struct Proposal {
        string description; // Description of the proposal
        string proposal_title; // Proposal's title
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether if passes of fails
        bool is_active; // This shows if others can vote to our contract
        
    }

    mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals
    mapping(address => bool) has_voted;

    
    /* constructor second line deleted because when the admin deploys the contract, he's considered as a voter by default*/
    constructor(){
        owner = msg.sender;
    }

    // ***** Modifiers  ***** //

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can do this");
        _;
    }

    modifier active() {
        require(proposal_history[counter].is_active == true, "The proposal is not active");
        _;
    }

    
    modifier newVoter(address _address) {
        require (!isVoted(_address), "This address already voted");
        _;
    }
    

    // ***** Modifiers End ***** //


    /*** External Functions Start ***/


    function createProposal(string memory _proposal_title, string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
        ++counter; // priotize the prefix incrementation
        proposal_history[counter] = Proposal(_proposal_title, _description, 0, 0, 0, _total_vote_to_end, false, true);
        
    }


    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }


    function vote(uint8 choice) external active newVoter(msg.sender){
        
        Proposal storage proposal = proposal_history[counter];    
        has_voted[msg.sender] = true;
        
        emit VoteEvent(choice, "Someone has voted"); // emit a log over the network when there is a vote 
        
        if (choice == 1) {
            ++proposal.approve;
        } else if (choice == 2) {
            ++proposal.reject;
        } else if (choice == 0) {
            ++proposal.pass;
        }

        // In the initial contract, when total_vote_end is set to a number, users can vote up to this number
        // So I have limited the number of total_vote to be equal to total_vote_end
        
        if ((proposal.approve + proposal.reject + proposal.pass == proposal.total_vote_to_end) ){
            proposal.is_active = false;
        }

        // Proposal passing or failure condition
        if(proposal.approve >= proposal.reject + proposal.pass){
            proposal.current_state = true;
        }else{
            proposal.current_state = false;
        }

        
    }

    function teminateProposal() external onlyOwner active {
        proposal_history[counter].is_active = false;
        emit VoteEnd("Voting is actually closed"); // emit a message to inform the participants that voting is closed
    }   

    function getProposal(uint256 number) external view returns(Proposal memory) {
        return proposal_history[number];
    }

    function getCurrentProposal() external view returns(Proposal memory) {
        return proposal_history[counter];
    }

    /*** External Functions End ***/


    /*** Public Functions Start ***/

    function isVoted(address _address) public view returns (bool){
        return has_voted[_address];
    }

    /*** Public Functions End ***/

}
