// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

contract Voting {

    address public admin;
    uint public startTime;
    uint public endTime;

    struct Voter {
        string name;
        uint age;
        bool voted;
    }

    struct Candidate {
        string name;
        string party;
        string office;
        uint age;
    }

    uint public votingAge = 18;
    mapping(address => Voter) public voter;
    mapping (address => Candidate) public candidate;
    mapping (address => bool) public registeredCandidate;
    mapping(address => uint) public candidateVote;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }
    
    uint public votersCount;
    uint public candidateCount;

    function registerVoter(address _voter, string calldata _name, uint _age) public {
        require(!voter[_voter].voted, "Can't register");
        require(votingAge <= _age, 'Not eligible voting age');
        voter[_voter] = Voter(_name, _age,false );
        votersCount++;
    } 

    function registerCandidate(address _addr, string calldata _name, string calldata _party, string calldata _office, uint age) public onlyAdmin {
        require(!registeredCandidate[_addr], "Already a registered candidate");
        candidate[_addr] = Candidate(_name, _party, _office, age);
        registeredCandidate[_addr] = true;
        candidateCount++;
    }

    function startElection() public onlyAdmin {
        require(startTime == 0, "Election can't start");
        startTime = block.timestamp;
        endTime = startTime + 604800;
    }

    function vote(address _addr) public returns(bool success) {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Voting ended");
        require(!voter[msg.sender].voted, "Already voted, Can't vote");
        require(registeredCandidate[_addr], "Not a registered candidate");
        candidateVote[_addr]++;
        voter[msg.sender].voted = true;
        success = true; 
    }

    function viewVotes(address _candidate) public view onlyAdmin returns(uint) {
        if(block.timestamp >= endTime) return candidateVote[_candidate];
    }

    function resetBallot(address _candidateAddr, address _voterAddr) public onlyAdmin {
        require(block.timestamp > endTime, "Voting is ongoing");
        votersCount = 0;
        candidateCount = 0;
        delete candidate[_candidateAddr];
        delete voter[_voterAddr];
    }

}