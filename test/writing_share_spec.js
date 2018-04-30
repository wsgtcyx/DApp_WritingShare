describe("WritingShare", function() {
  before(function(done) {
    this.timeout(0);
    EmbarkSpec.deployAll({}, done);
  });

  it("check stage0", function(done) {
    WritingShare.stage(function(err, result) {
      assert.equal(result.toNumber(), 0);
      done();
    });
  });

  it("check stage1", function(done) {
    WritingShare.createNewChapter({value:300}, function(err, result) {
      WritingShare.getStage(function(err, result) {
        assert.equal(result.toNumber(), 1);
        done();
      });
    });
  });

  

});
