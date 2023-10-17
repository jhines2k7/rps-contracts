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
  event Log(string message, uint _value);

  constructor(uint256 _arbiterFeePercentage, string memory _gameId) Ownable(){
    arbiterFeePercentage = _arbiterFeePercentage;
    contractGameId = _gameId;
  }

  function joinContract(string memory _gameId) public payable {
    require(keccak256(abi.encodePacked(_gameId)) == keccak256(abi.encodePacked(contractGameId)), "Game ID does not match with contract's Game ID.");
    
    require(party1 == address(0) || party2 == address(0), "Game is full");
    
    require(msg.value > 0, "Must stake a positive amount of ether");

    if (party1 == address(0)) {
      party1 = payable(msg.sender);
      stake1 = msg.value;
      party1Paid = true;
      emit Log("Party 1 joined and paid stake ", stake1);
      emit StakePaid(msg.sender, msg.value);
    } else {
      party2 = payable(msg.sender);
      party2Paid = true;
      stake2 = msg.value;
      emit Log("Party 2 joined and paid stake ", stake2);
      emit StakePaid(msg.sender, msg.value);
    }

    contractBalance += msg.value;
  }

  function refundWager(address payable payee, string memory _gameId) public onlyOwner {
    require(keccak256(abi.encodePacked(_gameId)) == keccak256(abi.encodePacked(contractGameId)), "Game ID does not match with contract's Game ID.");

    if (payee == party1) {
      party1.transfer(stake1);
      contractBalance -= stake1;
      emit Log("Contract owner refunded the stake to Party 1", stake1);
    } else {
      party2.transfer(stake2);
      contractBalance -= stake2;
      emit Log("Contract owner refunded the stake to Party 2", stake2);
    }

    emit Log("Contract balance after refund ", contractBalance);
  }

  function decideWinner(address payable winner, string memory _gameId) public onlyOwner {
    require(keccak256(abi.encodePacked(_gameId)) == keccak256(abi.encodePacked(contractGameId)), "Game ID does not match with contract's Game ID.");

    require(
      party1Paid && party2Paid,
      "All parties must have paid their stakes"
    );

    uint256 stake1ArbiterFee = stake1.mul(arbiterFeePercentage).div(10000);
    emit Log("Stake 1 arbiter fee ", stake1ArbiterFee);
    uint256 stake2ArbiterFee = stake2.mul(arbiterFeePercentage).div(10000);
    emit Log("Stake 2 arbiter fee ", stake2ArbiterFee);

    uint256 winnerPrize = stake1.sub(stake1ArbiterFee).add(stake2).sub(stake2ArbiterFee);
    arbiterFee = stake1ArbiterFee.add(stake2ArbiterFee);
    emit Log("Arbiter fee calculated ", arbiterFee);

    arbiter.transfer(arbiterFee);

    if (winner == arbiter) {
      party1.transfer(stake1.sub(stake1ArbiterFee));
      party2.transfer(stake2.sub(stake2ArbiterFee));
      emit Draw(party1, party2, totalStake);
    } else {
      emit Log("Winner prize ", winnerPrize);
      winner.transfer(winnerPrize); // Pay winner the winner prize
      emit WinnerDecided(winner, winnerPrize);
    }

    contractBalance = 0;
    winnerDecided = true;
  }

  function setArbiter(address payable _arbiter, string memory _gameId) public onlyOwner {
    require(keccak256(abi.encodePacked(_gameId)) == keccak256(abi.encodePacked(contractGameId)), "Game ID does not match with contract's Game ID.");

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

  function createContract(uint arbiterFeePercentage, string memory _gameId) public onlyOwner {
    RPSContract newContract = new RPSContract(arbiterFeePercentage, _gameId);
    newContract.transferOwnership(msg.sender);
    contracts.push(address(newContract));

    emit ContractCreated(address(newContract), _gameId);
  }

  function getContracts() public onlyOwner view returns (address[] memory) {
    return contracts;
  }

  function getLatestContract() public onlyOwner() view returns (address) {
    require(contracts.length > 0, "No contracts available");
    return contracts[contracts.length - 1];
  }
}
