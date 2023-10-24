const RPSContract = artifacts.require('RPSContract');

module.exports = function (deployer) {
  deployer.deploy(RPSContract, 1350, '0x3b10f9d3773172f2f74bB1Bb8EfBCF18626b3bE8');
};