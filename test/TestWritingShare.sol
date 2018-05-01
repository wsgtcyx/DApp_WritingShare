pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/WritingShare.sol";

contract TestWritingShare {
  WritingShare meta;
  uint public initialBalance = 10 ether;

  function beforeAll() {
    meta = new WritingShare();
    meta.setVotingTime(0);
    meta.setWritingTime(0);
    meta.setBeginCost(3);
    meta.setWritingCost(2);
    meta.setVotingCost(1);
  }

  function testBalance0(){
    Assert.equal(meta.balance, 0 ether, 'Check contact init balance');
    Assert.equal(this.balance, 10 ether, 'Check this init balance');
  }

  function testStage0() public {
    Assert.equal(meta.getStage(), 0, "Init smart contract! At stage 0.");
    Assert.equal(meta.getCurrentChapter(), 0, "At chapter0");
  }

  function testStage1() public {
    meta.createNewChapter.value(3 ether)();
    Assert.equal(meta.getStage(), 1, "Created the chapter0! At stage 1");
    Assert.equal(meta.getNumCandidate(), 0, "At chapter0");

    Assert.equal(meta.balance, 3 ether, 'Check balance');
    Assert.equal(this.balance, 7 ether, 'Check balance');

    meta.createNewCandidate.value(2 ether)('chapter-0, candidate-0');
    Assert.equal(meta.getNumCandidate(), 1, "Candidate Num = 1");
    meta.createNewCandidate.value(2 ether)('chapter-0, candidate-1');
    Assert.equal(meta.getNumCandidate(), 2, "Candidate Num = 2");

    Assert.equal(meta.balance, 7 ether, 'Check init balance');
    Assert.equal(this.balance, 3 ether, 'Check init balance');
  }

  function testStage2() public {
    meta.checkVoting();

    Assert.equal(meta.getStage(), 2, "Created the chapter0! At stage 2");
    Assert.equal(meta.getCurrentCandidateContent(0), 'chapter-0, candidate-0', 'Check Content0');
    Assert.equal(meta.getCurrentCandidateContent(1), 'chapter-0, candidate-1', 'Check Content1');
    Assert.equal(meta.getCandidateAddress(0), meta.getCandidateAddress(1), 'Check Address0 == Address1');

    meta.voting.value(1 ether)(0);
    Assert.equal(meta.getCandidateVotes(0), 1, 'Check votes of cancdidate 0');
    Assert.equal(meta.getCandidateVotes(1), 0, 'Check votes of cancdidate 0');

    Assert.equal(meta.balance, 8 ether, 'Check init balance');
    Assert.equal(this.balance, 2 ether, 'Check init balance');
  }

  function testStage3() public {
    meta.endVoting();
    Assert.equal(meta.getStage(), 3, "Created the chapter0! At stage 3");
    uint winnerIndex = meta.findWinnerIndex();
    Assert.equal(winnerIndex, 0, "winner is candidate 0");
    meta.rewardTheWinner();
    Assert.equal(meta.getWinnerContent(0), 'chapter-0, candidate-0', 'Check winner content');

    Assert.equal(meta.balance, 8 ether, 'Check balance');
    Assert.equal(this.balance, 2 ether, 'Check balance');
  }
}
