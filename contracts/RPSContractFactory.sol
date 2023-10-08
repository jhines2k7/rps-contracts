// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RPSContract is Ownable{
  using SafeMath for uint256;

  address payable private party1;
  address payable private party2;
  address payable private arbiter;
  uint256 private stake1;
  uint256 private stake2;
  uint256 private totalStake;
  uint256 private arbiterFee;
  bool private party1Paid;
  bool private party2Paid;
  bool private winnerDecided = false;
  uint256 private arbiterFeePercentage;
  string private contractGameId;
  uint256 private contractBalance;

  event StakePaid(address indexed _from, uint _value);
  event WinnerDecided(address indexed _winner, uint _value);
  event Draw(address indexed _party1, address indexed _party2, uint _value);
  event ContractLiquidated(address indexed _payee, uint _value);
  event Log(string message);

  constructor(uint256 _arbiterFeePercentage, string memory _gameId) Ownable(){
    arbiterFeePercentage = _arbiterFeePercentage;
    contractGameId = _gameId;
  }

  function joinContract(string memory gameId) public payable {
    require(keccak256(abi.encodePacked(gameId)) == keccak256(abi.encodePacked(contractGameId)), "Game ID does not match with contract's Game ID.");
    
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

    contractBalance += msg.value;
  }

  function refundWager(address payable payee, string memory gameId) public onlyOwner {
    require(keccak256(abi.encodePacked(gameId)) == keccak256(abi.encodePacked(contractGameId)), "Game ID does not match with contract's Game ID.");

    if (payee == party1) {
      party1.transfer(stake1);
      contractBalance -= stake1;
      emit Log("Contract owner refunded the stake to Party 1");
    } else {
      party2.transfer(stake2);
      contractBalance -= stake2;
      emit Log("Contract owner refunded the stake to Party 2");
    }
  }

  function decideWinner(address payable winner, string memory gameId) public onlyOwner {
    require(keccak256(abi.encodePacked(gameId)) == keccak256(abi.encodePacked(contractGameId)), "Game ID does not match with contract's Game ID.");

    require(
      party1Paid && party2Paid,
      "All parties must have paid their stakes"
    );

    totalStake = stake1.add(stake2);
    arbiterFee = totalStake.mul(arbiterFeePercentage).div(10000);
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

    contractBalance = 0;
    winnerDecided = true;
  }

  function setArbiter(address payable _arbiter, string memory gameId) public onlyOwner {
    require(keccak256(abi.encodePacked(gameId)) == keccak256(abi.encodePacked(contractGameId)), "Game ID does not match with contract's Game ID.");

    arbiter = _arbiter;
  }

  function liquidateContract(address payable _arbiter) public onlyOwner {
    if(!winnerDecided && contractBalance > 0) {
      _arbiter.transfer(contractBalance);
    }
  }
}

contract RPSContractFactory is Ownable{
  address[] contracts;

  event ContractCreated(address indexed _contract, string gameId);

  function createContract(uint arbiterFeePercentage, string memory gameId) public onlyOwner {
    RPSContract newContract = new RPSContract(arbiterFeePercentage, gameId);
    newContract.transferOwnership(msg.sender);
    contracts.push(address(newContract));

    emit ContractCreated(address(newContract), gameId);
  }

  function getContracts() public onlyOwner view returns (address[] memory) {
    return contracts;
  }

  function getLatestContract() public onlyOwner() view returns (address) {
    require(contracts.length > 0, "No contracts available");
    return contracts[contracts.length - 1];
  }
}
