module.exports = {
  networks: {
     test: {
       host: "localhost",
       port: 8545,
       network_id: "*", // Match any network id
       gas: 999999999999999,
       from: '0xc1455d85e7ccde6e2668400a27ec5bfd18cf56d1'
       // gasPrice: 100
     }
   },
   mocha: {
    useColors: true
   }
};
