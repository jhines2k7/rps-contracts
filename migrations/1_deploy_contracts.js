const RPSContract = artifacts.require('RPSContract');

module.exports = function (deployer) {
  deployer.deploy(RPSContract, 1350, '0x5361b326d932dA0885b97AAb86B659d099bdb7f2');
};