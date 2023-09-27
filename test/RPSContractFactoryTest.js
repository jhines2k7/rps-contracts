const RPSContractFactory = artifacts.require("RPSContractFactory");
const RPSContract = artifacts.require("RPSContract");

contract("RPSContractFactory", (accounts) => {
  let rpsContractFactory;
  const owner = accounts[0] // for testing purposes,the contract owner is the first ganache account 

  beforeEach(async () => {
    rpsContractFactory = await RPSContractFactory.new();
  });

  it("should create a new contract", async () => {
    const arbiterFeePercentage = 2; // Set the arbiter fee percentage as desired

    const result = await rpsContractFactory.createContract(
      arbiterFeePercentage, { from: accounts[0] }
    );

    const newContractAddress = result.logs[0].args._contract;
    const deployedContract = await RPSContractFactory.at(newContractAddress);

    assert.equal(
      newContractAddress,
      deployedContract.address,
      "Failed to create a new contract"
    );

    const contracts = await rpsContractFactory.getContracts();
    
    assert.equal(
      contracts.length,
      1,
      "Failed to get the list of contracts"
    );
    assert.equal(
      contracts[0],
      newContractAddress,
      "The newly created contract address is incorrect"
    );
  });

  it("should allow creating 4 RPS contracts", async () => {
    const arbiter = accounts[1];
    const arbiterFeePercentage = 10;

    const receipt1 = await rpsContractFactory.createContract(arbiterFeePercentage, { from: owner });
    const contractAddress1 = receipt1.logs[0].args._contract;

    const receipt2 = await rpsContractFactory.createContract(arbiterFeePercentage, { from: owner });
    const contractAddress2 = receipt2.logs[0].args._contract;

    const receipt3 = await rpsContractFactory.createContract(arbiterFeePercentage, { from: owner });
    const contractAddress3 = receipt3.logs[0].args._contract;

    const receipt4 = await rpsContractFactory.createContract(arbiterFeePercentage, { from: owner });
    const contractAddress4 = receipt4.logs[0].args._contract;

    const contracts = await rpsContractFactory.getContracts();
    assert.equal(contracts.length, 4, "Incorrect number of contracts");
    assert.equal(contracts[0], contractAddress1, "First contract address is incorrect");
    assert.equal(contracts[1], contractAddress2, "Second contract address is incorrect");
    assert.equal(contracts[2], contractAddress3, "Third contract address is incorrect");
    assert.equal(contracts[3], contractAddress4, "Fourth contract address is incorrect");
  });

  it('getContracts should return all contracts created by owner', async () => {
    await rpsContractFactory.createContract(2, {from: owner});
    await rpsContractFactory.createContract(3, {from: owner});
    await rpsContractFactory.createContract(4, {from: owner});

    const contracts = await rpsContractFactory.getContracts({from: owner}); 
    assert.equal(contracts.length, 3); 
  });

  it('getContracts should fail if called by other than owner', async () => {
    try {
      await rpsContractFactory.getContracts({from: accounts[1]}); //
      assert.fail('Expected getContracts to throw error');
    } catch (err) {
      assert.include(err.message, 'revert Only the contract owner can view all contracts', 'Expected revert for non-owner'); 
    }
  });
});
