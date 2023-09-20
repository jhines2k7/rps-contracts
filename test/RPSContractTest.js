const RPSContract = artifacts.require('RPSContract');

contract('RPSContract', (accounts) => {
  it('should allow players to join the contract', async () => {
    let contractInstance;
    contractInstance = await RPSContract.new(2);

    await contractInstance.joinContract({ from: accounts[2], value: web3.utils.toWei('1', 'ether') });
    const party1 = await contractInstance.party1();
    assert.equal(party1, accounts[2], 'Party1 address is incorrect');

    const stake1 = await contractInstance.stake1();
    assert.equal(stake1, web3.utils.toWei('1', 'ether'), 'Stake1 value is incorrect');

    await contractInstance.joinContract({ from: accounts[3], value: web3.utils.toWei('2', 'ether') });
    const party2 = await contractInstance.party2();
    assert.equal(party2, accounts[3], 'Party2 address is incorrect');

    const stake2 = await contractInstance.stake2();
    assert.equal(stake2, web3.utils.toWei('2', 'ether'), 'Stake2 value is incorrect');
  });

  it('should allow the arbiter to decide the winner', async () => {
    let contractInstance;
    contractInstance = await RPSContract.new(5);

    let contractBalance = await web3.eth.getBalance(contractInstance.address);
    const arbiterInitialBalance = await web3.eth.getBalance(accounts[1]);
    const party1InitialBalance = await web3.eth.getBalance(accounts[2]);
    const party2InitialBalance = await web3.eth.getBalance(accounts[3]);

    console.log(`contractBalance in ether: ${web3.utils.fromWei(contractBalance, 'ether')}`);
    console.log(`arbiterInitialBalance in ether: ${web3.utils.fromWei(arbiterInitialBalance, 'ether')}`);
    console.log(`party1 initial balance in ether: ${web3.utils.fromWei(party1InitialBalance, 'ether')}`);
    console.log(`party2 initial balance in ether: ${web3.utils.fromWei(party2InitialBalance, 'ether')}`);

    await contractInstance.joinContract({ from: accounts[2], value: web3.utils.toWei('2', 'ether') });
    await contractInstance.joinContract({ from: accounts[3], value: web3.utils.toWei('4', 'ether') });

    contractBalance = await web3.eth.getBalance(contractInstance.address);

    let party1Balance = await web3.eth.getBalance(accounts[2]);
    let party2Balance = await web3.eth.getBalance(accounts[3]);
    console.log(`party1 balance after stakes are paid: ${web3.utils.fromWei(party1Balance, 'ether')}`);
    console.log(`party2 balance after stakes are paid: ${web3.utils.fromWei(party2Balance, 'ether')}`);
    console.log(`contractBalance after stakes have been paid: ${web3.utils.fromWei(contractBalance, 'ether')}`);

    let result = await contractInstance.decideWinner(accounts[2], { from: accounts[1] });

    contractBalance = await web3.eth.getBalance(contractInstance.address);

    const arbiterBalance = await web3.eth.getBalance(accounts[1]);
    party1Balance = await web3.eth.getBalance(accounts[2]);
    party2Balance = await web3.eth.getBalance(accounts[3]);
    console.log(`contractBalance after winner decided: ${web3.utils.fromWei(contractBalance, 'ether')}`);
    console.log(`arbiter balance after winner decided: ${web3.utils.fromWei(arbiterBalance, 'ether')}`);
    console.log(`party1 balance after winner decided: ${web3.utils.fromWei(party1Balance, 'ether')}`);
    console.log(`party2 balance after winner decided: ${web3.utils.fromWei(party2Balance, 'ether')}`);

    // console.log('result.receipt', result.receipt);

    let gasPrice = Number(result.receipt.effectiveGasPrice); // Get the gas price
    let gasUsed = Number(result.receipt.gasUsed); // Get the gas used

    console.log('gasPrice', gasPrice);
    console.log('gasUsed', gasUsed);

    // Calculate the total gas cost
    let totalGasCost = web3.utils.toBN(gasPrice * gasUsed);

    console.log('totalGasCost', totalGasCost.toString());

    console.log(`arbiterFinalBalance in ether: ${web3.utils.fromWei(arbiterBalance, 'ether')}`);

    assert.equal(
      party1Balance > party1InitialBalance,
      true,
      'Party1 did not receive their winnings'
    );
    assert.equal(
      arbiterBalance > arbiterInitialBalance,
      true,
      'Arbiter did not receive his fee'
    );
  });

  it('should allow the arbiter to decide the winner when the arbiter percentage fee is a decimal', async () => {
    let arbiterFeePercentage = Math.round(5.5 * 10**2);
    console.log(`arbiterFeePercentage: ${arbiterFeePercentage}`);
    let contractInstance;
    contractInstance = await RPSContract.new(arbiterFeePercentage);

    let contractBalance = await web3.eth.getBalance(contractInstance.address);
    const arbiterInitialBalance = await web3.eth.getBalance(accounts[1]);
    const party1InitialBalance = await web3.eth.getBalance(accounts[2]);
    const party2InitialBalance = await web3.eth.getBalance(accounts[3]);

    console.log(`contractBalance in ether: ${web3.utils.fromWei(contractBalance, 'ether')}`);
    console.log(`arbiterInitialBalance in ether: ${web3.utils.fromWei(arbiterInitialBalance, 'ether')}`);
    console.log(`party1 initial balance in ether: ${web3.utils.fromWei(party1InitialBalance, 'ether')}`);
    console.log(`party2 initial balance in ether: ${web3.utils.fromWei(party2InitialBalance, 'ether')}`);

    await contractInstance.joinContract({ from: accounts[2], value: web3.utils.toWei('2', 'ether') });
    await contractInstance.joinContract({ from: accounts[3], value: web3.utils.toWei('4', 'ether') });

    contractBalance = await web3.eth.getBalance(contractInstance.address);

    let party1Balance = await web3.eth.getBalance(accounts[2]);
    let party2Balance = await web3.eth.getBalance(accounts[3]);
    console.log(`party1 balance after stakes are paid: ${web3.utils.fromWei(party1Balance, 'ether')}`);
    console.log(`party2 balance after stakes are paid: ${web3.utils.fromWei(party2Balance, 'ether')}`);
    console.log(`contractBalance after stakes have been paid: ${web3.utils.fromWei(contractBalance, 'ether')}`);

    let result = await contractInstance.decideWinner(accounts[2], { from: accounts[1] });

    contractBalance = await web3.eth.getBalance(contractInstance.address);

    const arbiterBalance = await web3.eth.getBalance(accounts[1]);
    party1Balance = await web3.eth.getBalance(accounts[2]);
    party2Balance = await web3.eth.getBalance(accounts[3]);
    console.log(`contractBalance after winner decided: ${web3.utils.fromWei(contractBalance, 'ether')}`);
    console.log(`arbiter balance after winner decided: ${web3.utils.fromWei(arbiterBalance, 'ether')}`);
    console.log(`party1 balance after winner decided: ${web3.utils.fromWei(party1Balance, 'ether')}`);
    console.log(`party2 balance after winner decided: ${web3.utils.fromWei(party2Balance, 'ether')}`);

    // console.log('result.receipt', result.receipt);

    let gasPrice = Number(result.receipt.effectiveGasPrice); // Get the gas price
    let gasUsed = Number(result.receipt.gasUsed); // Get the gas used

    console.log('gasPrice', gasPrice);
    console.log('gasUsed', gasUsed);

    // Calculate the total gas cost
    let totalGasCost = web3.utils.toBN(gasPrice * gasUsed);

    console.log('totalGasCost', totalGasCost.toString());

    console.log(`arbiterFinalBalance in ether: ${web3.utils.fromWei(arbiterBalance, 'ether')}`);

    assert.equal(
      party1Balance > party1InitialBalance,
      true,
      'Party1 did not receive their winnings'
    );
    assert.equal(
      arbiterBalance > arbiterInitialBalance,
      true,
      'Arbiter did not receive his fee'
    );
  });

  it("has correct balance when both parties have joined the contract", async () => {
    let arbiter = accounts[1];
    let party1 = accounts[2];
    let party2 = accounts[3];

    let stake1 = web3.utils.toWei("1", "ether");
    let stake2 = web3.utils.toWei("2", "ether");

    let contractInstance;
    contractInstance = await RPSContract.new(2);

    await contractInstance.joinContract({ from: party1, value: stake1 });
    await contractInstance.joinContract({ from: party2, value: stake2 });

    // Let's get actual balance of the contract (i.e., how much ether it has)
    let contractBalance = await web3.eth.getBalance(contractInstance.address);
    console.log(`contractBalance in wei: ${contractBalance}`);

    // Check that the paid amounts match the contract's balance
    let totalPaid = BigInt(stake1) + BigInt(stake2);
    console.log(`totalPaid in wei: ${totalPaid}`);

    assert.equal(contractBalance, totalPaid, "The contract's balance does not match the total stake");
  });

  it("should verify ending account balance for the winning player", async () => {
    const [owner, party1, party2, arbiter] = accounts;
    const stake1 = web3.utils.toWei("10", "ether");
    const stake2 = web3.utils.toWei("5", "ether"); // loser stake
    const arbiterFeePercentage = 5;

    const arbiterBalanceBefore = await web3.eth.getBalance(arbiter);
    const party1BalanceBefore = await web3.eth.getBalance(party1);
    const party2BalanceBefore = await web3.eth.getBalance(party2);
    console.log(`party1BalanceBefore in wei: ${party1BalanceBefore}`);
    console.log(`party2BalanceBefore in wei: ${party2BalanceBefore}`);
    console.log(`arbiterBalanceBefore in wei: ${arbiterBalanceBefore}`);

    const contractInstance = await RPSContract.new(arbiterFeePercentage);
    await contractInstance.joinContract({ from: party1, value: stake1 });
    await contractInstance.joinContract({ from: party2, value: stake2 });

    console.log(`party1Balance after paying stake in eth: ${web3.utils.fromWei(await web3.eth.getBalance(party1), 'ether')}`);
    console.log(`party2Balance after paying stake in eth: ${web3.utils.fromWei(await web3.eth.getBalance(party2), 'ether')}`);

    await contractInstance.decideWinner(party1, { from: arbiter });

    const arbiterBalanceAfter = await web3.eth.getBalance(arbiter);
    const party1BalanceAfter = await web3.eth.getBalance(party1);
    const party2BalanceAfter = await web3.eth.getBalance(party2);

    console.log(`party1BalanceAfter in wei: ${party1BalanceAfter}`);
    console.log(`party2BalanceAfter in wei: ${party2BalanceAfter}`);
    console.log(`arbiterBalanceAfter in wei: ${arbiterBalanceAfter}`);

    assert.equal(
      party1BalanceAfter > party1BalanceBefore,
      true,
      "Ending account balance for the winning player is incorrect"
    );

    assert.equal(
      party2BalanceAfter < party2BalanceBefore,
      true,
      "Ending account balance for the losing player is incorrect"
    );
  });

  it("should return the stakes to each player minus the arbiter fee in the case of a draw", async () => {
    const [owner, party1, party2, arbiter] = accounts;
    const stake1 = web3.utils.toWei("10", "ether");
    const stake2 = web3.utils.toWei("5", "ether"); // loser stake
    const arbiterFeePercentage = 5;

    const arbiterInitialBalance = await web3.eth.getBalance(arbiter);
    const party1InitialBalance = await web3.eth.getBalance(party1);
    const party2InitialBalance = await web3.eth.getBalance(party2);
    console.log(`party1InitialBalance in eth: ${web3.utils.fromWei(party1InitialBalance, 'ether')}`);
    console.log(`party2InitialBalance in eth: ${web3.utils.fromWei(party2InitialBalance, 'ether')}`);
    console.log(`arbiterInitialBalance in eth: ${web3.utils.fromWei(arbiterInitialBalance, 'ether')}`);

    const contractInstance = await RPSContract.new(arbiterFeePercentage);
    await contractInstance.joinContract({ from: party1, value: stake1 });
    await contractInstance.joinContract({ from: party2, value: stake2 });

    console.log(`party1Balance after paying stake in eth: ${web3.utils.fromWei(await web3.eth.getBalance(party1), 'ether')}`);
    console.log(`party2Balance after paying stake in eth: ${web3.utils.fromWei(await web3.eth.getBalance(party2), 'ether')}`);

    await contractInstance.decideWinner(arbiter, { from: arbiter });

    let totalStake = BigInt(stake1) + BigInt(stake2);
    console.log(`totalStake in wei: ${totalStake}`);

    const totalStakeInEther = web3.utils.fromWei(totalStake.toString(), 'ether');
    const arbiterFee = totalStakeInEther * (arbiterFeePercentage / 100);
    console.log(`Arbiter fee in ether: ${arbiterFee}`);
    const arbiterFeeInWei = web3.utils.toWei(arbiterFee.toString(), 'ether');
    console.log(`Arbiter fee in Wei: ${arbiterFeeInWei}`);

    const halfOfArbiterFee = BigInt(arbiterFeeInWei) / BigInt(2);
    console.log(`halfOfArbiterFee in wei: ${halfOfArbiterFee}`);

    let winnerPrize = BigInt(totalStake) - BigInt(arbiterFeeInWei);
    console.log(`winnerPrize in wei: ${winnerPrize}`);

    const party1FinalBalance = await web3.eth.getBalance(party1);
    console.log(`party1FinalBalance in wei: ${party1FinalBalance}`)
    const party2FinalBalance = await web3.eth.getBalance(party2);
    const arbiterFinalBalance = await web3.eth.getBalance(arbiter);
    console.log(`party1FinalBalance in eth: ${web3.utils.fromWei(party1FinalBalance, 'ether')}`);
    console.log(`party2FinalBalance in eth: ${web3.utils.fromWei(party2FinalBalance, 'ether')}`);
    console.log(`arbiterFinalBalance in eth: ${web3.utils.fromWei(arbiterFinalBalance, 'ether')}`);

    console.log(`Expected ending party1 account balance: ${BigInt(party1InitialBalance) - BigInt(halfOfArbiterFee)}`);

    assert.equal(
      party1FinalBalance < BigInt(party1InitialBalance) - BigInt(halfOfArbiterFee),
      true,
      "Ending account balance for party1 is incorrect"
    );

    assert.equal(
      party2FinalBalance < BigInt(party2InitialBalance) - BigInt(halfOfArbiterFee),
      true,
      "Ending account balance for party2 is incorrect"
    );
  });
});