pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/WritingShare.sol";

contract TestWritingShareChapter0 {
  WritingShare meta;
  uint public initialBalance = 20 ether;

  function beforeAll() {
    meta = new WritingShare();
    meta.setVotingTime(0);
    meta.setWritingTime(0);
  }

  /* Test Chapter0 */
  function test_Chapter0_Balance0(){
    Assert.equal(meta.balance, 0 ether, 'Check contact init balance');
    Assert.equal(this.balance, 20 ether, 'Check this init balance');
  }

  function test_Chapter0_Stage0() public {
    Assert.equal(meta.getStage(), 0, "Init smart contract! At stage 0.");
    Assert.equal(meta.getCurrentChapter(), 0, "At chapter0");
  }

  function test_Chapter0_Stage1() public {
    meta.createNewChapter.value(3 ether)();
    Assert.equal(meta.getStage(), 1, "Created the chapter0! At stage 1");

    meta.createNewCandidate.value(2 ether)('chapter-0, candidate-0');
    Assert.equal(meta.getNumCandidate(), 1, "Candidate Num = 1");
    meta.createNewCandidate.value(2 ether)('chapter-0, candidate-1');
    Assert.equal(meta.getNumCandidate(), 2, "Candidate Num = 2");

    Assert.equal(meta.balance, 7 ether, 'Check init balance');
    Assert.equal(this.balance, 13 ether, 'Check init balance');
  }

  function test_Chapter0_Stage2() public {
    meta.checkVoting();

    Assert.equal(meta.getStage(), 2, "Created the chapter0! At stage 2");
    Assert.equal(meta.getCandidateAddress(0), meta.getCandidateAddress(1), 'Check Address0 == Address1');

    meta.voting.value(1 ether)(0);
    Assert.equal(meta.getCandidateVotes(0), 1, 'Check votes of cancdidate 0');
    Assert.equal(meta.getCandidateVotes(1), 0, 'Check votes of cancdidate 1');

    Assert.equal(meta.balance, 8 ether, 'Check init balance');
    Assert.equal(this.balance, 12 ether, 'Check init balance');
  }

  function test_Chapter0_Stage3() public {
    meta.endVoting();
    Assert.equal(meta.getStage(), 3, "Created the chapter0! At stage 3");
    Assert.equal(meta.findWinnerIndex(), 0, "winner is candidate 0");
    meta.rewardTheWinner();
    Assert.equal(meta.getWinnerContent(0), 'chapter-0, candidate-0', 'Check winner content');
  }

  function test_Chapter1_Stage0() public {
    Assert.equal(meta.getStage(), 0, "Init smart contract! At stage 0.");
    Assert.equal(meta.getCurrentChapter(), 1, "At chapter1");
  }

  function test_Chapter1_Stage1() public {
    meta.createNewChapter.value(3 ether)();
    Assert.equal(meta.getStage(), 1, "Created the chapter1! At stage 1");
    Assert.equal(meta.getNumCandidate(), 0, "getNumCandidate");

    Assert.equal(meta.balance, 11 ether, 'Check balance');
    Assert.equal(this.balance, 9 ether, 'Check balance');

    meta.createNewCandidate.value(2 ether)('chapter-1, candidate-0');
    meta.createNewCandidate.value(2 ether)('chapter-1, candidate-1');
    Assert.equal(meta.getNumCandidate(), 2, "Candidate Num = 2");

    Assert.equal(meta.balance, 15 ether, 'Check init balance');
    Assert.equal(this.balance, 5 ether, 'Check init balance');
  }

  function test_Chapter1_Stage2() public {
    meta.checkVoting();

    Assert.equal(meta.getStage(), 2, "Created the chapter0! At stage 2");
    Assert.equal(meta.getCandidateAddress(0), meta.getCandidateAddress(1), 'Check Address0 == Address1');

    meta.voting.value(1 ether)(0);
    Assert.equal(meta.getCandidateVotes(0), 1, 'Check votes of cancdidate 0');
    Assert.equal(meta.getCandidateVotes(1), 0, 'Check votes of cancdidate 0');

    Assert.equal(meta.balance, 16 ether, 'Check init balance');
    Assert.equal(this.balance, 4 ether, 'Check init balance');
  }

  function test_Chapter1_Stage3() public {
    meta.endVoting();
    Assert.equal(meta.getStage(), 3, "Created the chapter0! At stage 3");
    Assert.equal(meta.findWinnerIndex(), 0, "winner is candidate 0");
    meta.rewardTheWinner();
    Assert.equal(meta.getWinnerContent(0), 'chapter-0, candidate-0', 'Check winner content');
  }
}
