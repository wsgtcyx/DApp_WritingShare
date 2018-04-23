contract("WritingShare", function() {

  this.timeout(0);
  before(function(done) {
    this.timeout(0);

    //config({
    //  node: "http://localhost:8545"
    //});

    var contractsConfig = {
      "WritingShare": {
        args: [100]
      }
    };
    EmbarkSpec.deployAll(contractsConfig, () => { done() });
  });



});