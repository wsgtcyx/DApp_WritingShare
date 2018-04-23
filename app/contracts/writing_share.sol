pragma solidity ^0.4.17;

contract WritingShare {

	uint stage = 0; //0:have not begin ,1:begin, 2:vote begin, 3:vote finish
	uint beginMoney = 200;
	uint currentChapter = 0;
	uint charpterCount = 3;
	uint beginChapterTime;
	uint writingTime = 200;
	uint voteTime = 200;
	uint candidateCost = 10 ether;
	uint votingCost = 10 ether;
	address drawerAddress;

	modifier onlyDrawer() {
	    require(msg.sender == drawerAddress);
	    _;
  	}


	struct chapter{
		uint numCandidate;
		uint beginChapterTime;
		uint writingEnd;
		uint voteEnd;
		uint[] votes;
		mapping (uint=>address) addressCandidates;
		mapping (uint=>string) contentCandidates;
	}

	chapter[] private chapters;

	function WritingShare() public{

	}

	function createNewChapter() onlyDrawer payable public {


		require(stage==0);
		uint extra = msg.value;
		if(currentChapter==0){
			require(msg.value>=beginMoney);
			extra = msg.value - beginMoney;
		}
		if(extra>0){msg.sender.transfer(extra);}


		chapters.push(chapter({

			numCandidate: 0,
			votes: new uint[](0),
			beginChapterTime: now,
			writingEnd: now+writingTime,
			voteEnd:now+writingTime+voteTime
	    }));
	    stage = 1; 

	}

	function createNewCandidate(string _content) payable public{
		require(msg.value>=candidateCost);
		require(now<=chapters[currentChapter].writingEnd);

		uint extra = msg.value - candidateCost;
		if(extra>0){
			msg.sender.transfer(extra);
		}

		chapter storage ThisChapter = chapters[currentChapter];

		ThisChapter.addressCandidates[ThisChapter.numCandidate] = msg.sender;
		ThisChapter.contentCandidates[ThisChapter.numCandidate] = _content;
		ThisChapter.votes[ThisChapter.numCandidate] = 0;
		ThisChapter.numCandidate ++;
	}

	function voting(uint _indexVoteCandidate) payable public{
		require(stage==2);
		require(now<=chapters[currentChapter].voteEnd);
		require(msg.value>=votingCost);

		chapter storage ThisChapter = chapters[currentChapter];

		require(_indexVoteCandidate>=0 && _indexVoteCandidate<ThisChapter.numCandidate);

		uint extra = msg.value;

		extra = msg.value - votingCost;
		msg.sender.transfer(extra);

		ThisChapter.votes[_indexVoteCandidate] ++;

	}

	function endCandidate() onlyDrawer internal {
		chapter storage ThisChapter = chapters[currentChapter];		
		require(now>=ThisChapter.writingEnd);
		stage = 2;
		ThisChapter.voteEnd = now + voteTime;
	}


	function checkCurrentChapter() public view returns (uint) {
		return currentChapter;
	}	

	function checkStage() public view returns (uint) {
		return stage;
	}

	function checkBalance()  public view returns(uint){
		return this.balance;
  	}


}