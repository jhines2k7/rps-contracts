// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";

contract RPSContract {
  using SafeMath for uint256;

  address payable party1;
  address payable party2;
  address payable arbiter;
  uint256 stake1;
  uint256 stake2;
  bool party1Paid;
  bool party2Paid;
  uint256 arbiterFeePercentage;

  event StakePaid(address indexed _from, uint _value);
  event WinnerDecided(address indexed _winner, uint _value);
  event Draw(address indexed _party1, address indexed _party2, uint _value);
  event Log(string message);

  constructor(uint256 _arbiterFeePercentage) {
    arbiter = payable(0x3b10f9d3773172f2f74bB1Bb8EfBCF18626b3bE8);
    // change this to match an address on your local network
    // arbiter = payable(0x0bAdd78E46E443b213B0c6B3a35ad1686c2B697c);
    arbiterFeePercentage = _arbiterFeePercentage;
  }

  function joinContract() public payable {
    require(party1 == address(0) || party2 == address(0), "Game is full");
    require(msg.value > 0, "Must stake a positive amount of ether");

    if (party1 == address(0)) {
      party1 = payable(msg.sender);
      stake1 = msg.value;
      party1Paid = true;
      emit Log("Party 1 joined and paid stake");
      emit StakePaid(msg.sender, msg.value);
    } else {
      party2 = payable(msg.sender);
      party2Paid = true;
      stake2 = msg.value;
      emit Log("Party 2 joined and paid stake");
      emit StakePaid(msg.sender, msg.value);
    }
  }

  function decideWinner(address payable winner) public {
    require(
      msg.sender == arbiter,
      "Only the arbiter can decide the winner"
    );
    require(
      party1Paid && party2Paid,
      "All parties must have paid their stakes"
    );

    uint256 totalStake = stake1.add(stake2);
    uint256 arbiterFee = totalStake.mul(arbiterFeePercentage).div(10000);
    uint256 winnerPrize = totalStake.sub(arbiterFee);

    if (winner == arbiter) {
      // pay arbiter fee in any case, but return each stake to the proper party minus the arbiter fee
      arbiter.transfer(arbiterFee);
      uint256 halfArbiterFee = arbiterFee.div(2);
      party1.transfer(stake1.sub(halfArbiterFee));
      party2.transfer(stake2.sub(halfArbiterFee));
      emit Draw(party1, party2, totalStake);
    } else {
      arbiter.transfer(arbiterFee); // Pay arbiter their fee
      winner.transfer(winnerPrize); // Pay winner their stake and the winner prize
      emit WinnerDecided(winner, winnerPrize);
    }
  }
}

// contract RPSContractFactory is Ownable {
contract RPSContractFactory {
  address[] contracts;

  event ContractCreated(address indexed _contract);

  //  function createContract(uint arbiterFeePercentage) public onlyOwner {
  function createContract(uint arbiterFeePercentage) public {
    RPSContract newContract = new RPSContract(arbiterFeePercentage);
    contracts.push(address(newContract));

    emit ContractCreated(address(newContract));
  }

  // function getContracts() public onlyOwner view returns (address[] memory) {
  function getContracts() public view returns (address[] memory) {
    return contracts;
  }

  function getLatestContract() public view returns (address) {
    require(contracts.length > 0, "No contracts available");
    return contracts[contracts.length - 1];
  }
}
