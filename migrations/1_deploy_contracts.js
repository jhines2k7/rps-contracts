const RPSContract = artifacts.require('RPSContract');

module.exports = function (deployer) {
  deployer.deploy(RPSContract);
};