const RPSContractFactory = artifacts.require('RPSContractFactory');

module.exports = function (deployer) {
  deployer.deploy(RPSContractFactory);
};