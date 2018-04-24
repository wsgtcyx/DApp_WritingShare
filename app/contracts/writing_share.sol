pragma solidity ^0.4.17;



contract WritingShare {

    
    //variables about stages and chapters
    uint stage = 0; //0:have not begin   1:begin candidate  2:vote begin   3:vote finish and distribute money
    uint currentChapter = 0;   //index of currentChapter, begin with 0
    uint constant chapterAmount = 3;   // chapterAmount   
    
    // variables about time 
    uint writingTime = 200;    // the time for candidates to write and broadcast
    uint votingTime = 200;       // the time for voting
    //varaibles about cost
    uint beginCost = 200; //the amount Drawer initially sends to the contract
    uint writingCost = 10 ether;  //  the price for each candidate
    uint votingCost = 10 ether;    //  the price for each voting tiket in voting stage
    //varaiable about reward
    uint rewardPercentOfCandidate = 40; // represent as percentages
    uint rewardPercentOfDrawer = 40;
    
    address drawerAddress;   // the address of drawer
    address ownerAddress;
    modifier onlyOwner(){
        require(msg.sender==ownerAddress);
        _;
    }
    modifier onlyDrawer() {
        require(msg.sender == drawerAddress);
        _;
    }
    modifier onlyStage0(){
        require(stage==0);
        _;
    }    
    modifier onlyStage1(){
        require(stage==1);
        _;
    }
    modifier onlyStage2(){
        require(stage==2);
        _;
    }
    modifier onlyStage3(){
        require(stage==3);
        _;
    }
    
    struct chapter{
        uint numCandidates;
        uint beginChapterTime;
        uint writingEnd;
        uint votingEnd;
        uint[] votes;
        uint totalMoney;
        mapping (uint=>address) addressCandidates;
        mapping (uint=>string) contentCandidates;
    }
    //data structure to store all chapters
    chapter[] private chapters;
    //arrays to store all currentCandidateContent
    string [] public currentCandidateContent = new string[](0);
    //arrays to store all contents of final winner
    string [] public allWinnerContent = new string[](0);

    function WritingShare(address _drawerAddress) public{
        drawerAddress = _drawerAddress;
        ownerAddress = msg.sender;
    }
    
    
    function createNewChapter() payable public onlyDrawer onlyStage0 {
        require(currentChapter<=chapterAmount);
        //pay money
        uint extra = msg.value;
        if(currentChapter==0){
            require(msg.value>=beginCost);
            extra = msg.value - beginCost;
        }
        if(extra>0){msg.sender.transfer(extra);}

        //create new chapter
        chapters.push(chapter({
            numCandidates: 0,
            votes: new uint[](0),
            beginChapterTime: now,
            totalMoney:0,
            writingEnd: now+writingTime,
            votingEnd:now + writingTime+votingTime
        }));

        stage = 1; 
    }

    function createNewCandidate(string _content) payable public onlyStage1 {
        //pay money
        require(msg.value>=writingCost);
        uint extra = msg.value - writingCost;
        if(extra>0){msg.sender.transfer(extra);}

        //add candidates
        chapter storage ThisChapter = chapters[currentChapter];

        ThisChapter.addressCandidates[ThisChapter.numCandidates] = msg.sender;
        ThisChapter.contentCandidates[ThisChapter.numCandidates] = _content;
        ThisChapter.votes.push(0);
        ThisChapter.numCandidates ++;
        ThisChapter.totalMoney += writingCost;
        currentCandidateContent.push(_content);

        //safety check
        if (now>=chapters[currentChapter].writingEnd){
            stage2;
        }

    }
    function beginVoting() public onlyDrawer onlyStage1{
        require(now>=chapters[currentChapter].writingEnd);
        stage = 2;
    }

    function voting(uint _indexVoteCandidate) payable public onlyStage2{
        
        // make sure that the index is valid
        chapter storage ThisChapter = chapters[currentChapter];
        require(_indexVoteCandidate>=0 && _indexVoteCandidate<ThisChapter.numCandidates);
        
        //pay money
        require(msg.value>=votingCost);
        uint extra = msg.value;
        while(extra>=votingCost){
            extra = extra - votingCost;
            ThisChapter.votes[_indexVoteCandidate] ++;  //take a vote
            ThisChapter.totalMoney +=votingCost;  
        }
        if(extra>0){msg.sender.transfer(extra);}

    }
    
    function endVoting() public onlyDrawer onlyStage2 {
        //change stage
        chapter storage ThisChapter = chapters[currentChapter]; 
        require(now>=ThisChapter.votingEnd);
        stage = 3;
        
        reward();
        
        
        if(currentChapter<chapterAmount){
            stage = 0;
            currentChapter +=1;
            currentCandidateContent = new string[](0);

        }
        else{//finish all 
            //keep stage=3
            drawerAddress.transfer(beginCost);
        }
            

    }

    function reward() internal onlyDrawer onlyStage3{
        chapter storage ThisChapter = chapters[currentChapter]; 
        
        //make sure there is at least one candidate for this chapter
        require(ThisChapter.numCandidates>0);
        
        //find the index of winner
        uint indexWinner = 0;
        for(uint i=1;i<ThisChapter.numCandidates;i++){
            if(ThisChapter.votes[i]>ThisChapter.votes[indexWinner]){
                indexWinner = i;
            }
        }
        
        address winnerAddress = ThisChapter.addressCandidates[indexWinner];
        uint256 moneyForWinner = div(uint256(ThisChapter.totalMoney*rewardPercentOfCandidate),uint256(100));
        winnerAddress.transfer(moneyForWinner);
        
        uint256 moneyForDrawer = div(uint256(ThisChapter.totalMoney*rewardPercentOfDrawer),uint256(100));
        drawerAddress.transfer(moneyForDrawer);

        //publish the centent
        allWinnerContent.push(ThisChapter.contentCandidates[indexWinner]);

    }
      /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    
    function getCurrentChapter() public view returns (uint) {
        return currentChapter;
    }   

    function getStage() public view returns (uint) {
        return stage;
    }

    function getBalance()  public onlyOwner view returns(uint){
        return this.balance;
    }

    function getNumCandidate() public view returns(uint){
        return chapters[currentChapter].numCandidates;
    }
    function getCurrentCandidateContent(uint _indexCandidate) public onlyStage2 view returns(string){
        require(_indexCandidate>=0 && _indexCandidate<currentCandidateContent.length);
        return currentCandidateContent[_indexCandidate];
    }
    function getWinnerContent(uint _indexChapter) public view returns(string){
        require(_indexChapter>=0 && _indexChapter<allWinnerContent.length);
        return allWinnerContent[_indexChapter];
    }

    function () payable public{

    }


}