const RPSContractV2 = artifacts.require('RPSContractV2');

module.exports = function (deployer) {
  deployer.deploy(RPSContractV2);
};