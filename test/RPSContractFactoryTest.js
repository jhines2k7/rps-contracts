const RPSContractFactory = artifacts.require("RPSContractFactory");
const RPSContract = artifacts.require("RPSContract");

contract("RPSContractFactory", (accounts) => {
  let rpsContractFactory;

  beforeEach(async () => {
    rpsContractFactory = await RPSContractFactory.new();
  });

  it("should create a new contract", async () => {
    const arbiterFeePercentage = 2; // Set the arbiter fee percentage as desired

    const result = await rpsContractFactory.createContract(
      arbiterFeePercentage
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

    const receipt1 = await rpsContractFactory.createContract(arbiterFeePercentage);
    const contractAddress1 = receipt1.logs[0].args._contract;
    const contract1 = await RPSContract.at(contractAddress1);
    assert.equal(await contract1.arbiter(), arbiter, 'Arbiter is different');
    console.log(`Arbiter fee from contract: ${await contract1.arbiterFeePercentage()}`);
    console.log(`Arbiter fee passed in to constructor: ${arbiterFeePercentage}`);
    assert.equal(await contract1.arbiterFeePercentage(), arbiterFeePercentage, 'arbiterFeePercentage is different');

    const receipt2 = await rpsContractFactory.createContract(arbiterFeePercentage);
    const contractAddress2 = receipt2.logs[0].args._contract;
    const contract2 = await RPSContract.at(contractAddress2);
    assert.equal(await contract2.arbiter(), arbiter, 'Arbiter is different');
    assert.equal(await contract2.arbiterFeePercentage(), arbiterFeePercentage, 'arbiterFeePercentage is different');

    const receipt3 = await rpsContractFactory.createContract(arbiterFeePercentage);
    const contractAddress3 = receipt3.logs[0].args._contract;
    const contract3 = await RPSContract.at(contractAddress3);
    assert.equal(await contract3.arbiter(), arbiter, 'Arbiter is different');
    assert.equal(await contract3.arbiterFeePercentage(), arbiterFeePercentage, 'arbiterFeePercentage is different');

    const receipt4 = await rpsContractFactory.createContract(arbiterFeePercentage);
    const contractAddress4 = receipt4.logs[0].args._contract;
    const contract4 = await RPSContract.at(contractAddress4);
    assert.equal(await contract4.arbiter(), arbiter, 'Arbiter is different');
    assert.equal(await contract4.arbiterFeePercentage(), arbiterFeePercentage, 'arbiterFeePercentage is different');

    const contracts = await rpsContractFactory.getContracts();
    assert.equal(contracts.length, 4, "Incorrect number of contracts");
    assert.equal(contracts[0], contractAddress1, "First contract address is incorrect");
    assert.equal(contracts[1], contractAddress2, "Second contract address is incorrect");
    assert.equal(contracts[2], contractAddress3, "Third contract address is incorrect");
    assert.equal(contracts[3], contractAddress4, "Fourth contract address is incorrect");
  });
});
