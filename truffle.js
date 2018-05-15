module.exports = {
  networks: {
     development: {
       host: "localhost",
       port: 8545,
       network_id: "*", // Match any network id
       // gas: 400000,
       // from:'d0e8ff0764af46b31f7ab9114a1b517aabbef98b'
     }
   },
   mocha: {
    useColors: true
   }
};
